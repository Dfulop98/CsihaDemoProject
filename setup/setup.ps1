
$ip = (Get-NetIPAddress | Where-Object { ($_.InterfaceAlias -like "*Wi-Fi*" -or $_.InterfaceAlias -like "*Ethernet*") -and $_.AddressState -eq "Preferred" -and $_.ValidLifetime -lt "24:00:00" }).IPAddress

if (Test-Path "installState.txt") {
    $installState = Get-Content "installState.txt"
} else {
    $installState = "start"
}
Write-Output "This installing process is totally 4 part. After each part the computer will restart, and you have to run again the script."
switch ($installState){
    "start" {
        $chocoExists = (Get-Command choco -ErrorAction SilentlyContinue) -ne $null
        if (-not $chocoExists) {
            $userInputChoco = Read-Host "Chocolatey is not found. Would you like to install now? (y/n)[1/4]"
            switch ($userInputChoco){
                "y" {
                    Write-Output "Start installing Chocolatey:"
                    Set-ExecutionPolicy Bypass -Scope Process -Force;
                    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
                    iex ((Invoke-WebRequest -Uri https://chocolatey.org/install.ps1).Content)
                    "chocoInstalled" | Out-File "installState.txt"
                    Restart-Computer
                }
                "n" {
                    Write-Output "Please, Install Chocolatey from here: https://chocolatey.org/install"
                    exit
                }
                
                default{
                    Write-Output "Wrong input! try again."
                    return
                }
            }

        }
        Write-Output "You already have Chocolatey installed. Part 1 skipped. Please run the script again."
        "chocoInstalled" | Out-File "installState.txt"
    }

    "chocoInstalled" {
        $restart = $false
        # OpenSSl install 
        $opensslExists = (Get-Command openssl -ErrorAction SilentlyContinue) -ne $null
        if (-not $opensslExists) {
            $userInputOpenSSL = Read-Host "OpenSSL is not found. Would you like to install now? (y/n)[2/4]"
        
            switch ($userInputOpenSSL){
                "y" {
                    Write-Output "Start installing OpenSSl:"
                    choco install openssl -y
                }
                "n" {
                    Write-Output "Please, Manually install OpenSSL from the following link: https://www.openssl.org/source/"
                    exit
                }
                default{
                    Write-Output "Wrong input! try again."
                    return
                }
            }
        }
        Write-Output "Start generating ssl certs.......(named by your local ip)"
        if (-not (Test-Path ../certs/ -PathType Container)) {
                        mkdir ../certs/
                        $confContent = Get-Content .\sslcert.cnf -Raw
                        $confContent = $confContent.Replace("REPLACE_WITH_IP", $ip)
                        Set-Content .\sslcert.cnf -Value $confContent
                        # Generate ssl certs
                        openssl req -x509 -nodes -days 730 -newkey rsa:2048 -keyout ../certs/$ip.key -out ../certs/$ip.crt -config sslcert.cnf -extensions 'v3_req'
                        Write-Output "Self-signed certificates successfully created: $ip.crt and $ip.key"
                    }
        Write-Output "Start installing Docker desktop:"
        $dockerInstalled = $null -ne (Get-Command docker -ErrorAction SilentlyContinue)
        if (-not $dockerInstalled) {
            choco install docker-desktop -y
            $restart = $true
        }
        wsl --update
        "dockerOpenSSLInstalled" | Out-File "installState.txt"
        if($restart){
            Restart-Computer
        }
    }

    "dockerOpenSSLInstalled" {
        $restart = $false
        Write-Output "Enabling Hyper-V and container:[3/4]"
        Write-Output "Checking Hyper-V..."
        $hyperVEnabled = (dism.exe /online /get-featureinfo /featurename:Microsoft-Hyper-V) -like "*State : Enabled*"

        if(-not $hyperVEnabled){
            Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
            $restart = $true
        }
        else{
            Write-Output "Hyper-V is already enabled."
        }
        Write-Output "Checking Containers..."
        $containersEnabled = (dism.exe /online /get-featureinfo /featurename:Containers) -like "*State : Enabled*"
        if(-not $containersEnabled){
            Enable-WindowsOptionalFeature -Online -FeatureName Containers -All
            $restart = $true
        }
        else{
            Write-Output "Containers are already enabled."
        }
        "hyperVSetup" | Out-File "installState.txt"
        if($restart){
            Restart-Computer
        }
        else{
            exit
        }
    }

    "hyperVSetup" {
        Write-Output "Start installing GitLab:[4/4]"
        if((docker info --format '{{ .OSType }}') -eq 'windows'){
            & $Env:ProgramFiles\Docker\Docker\DockerCli.exe -SwitchDaemon
        }
        $serverComposeContent = Get-Content .\docker-compose.server.yml -Raw
        $runnersComposeContent = Get-Content .\docker-compose.runners.yml -Raw
        $serverComposeContent = $serverComposeContent.Replace("REPLACE_WITH_IP", $ip)
        $runnersComposeContent = $runnersComposeContent.Replace("REPLACE_WITH_IP", $ip)
        Set-Content .\docker-compose.server.yml -Value $serverComposeContent
        Set-Content .\docker-compose.runners.yml -Value $runnersComposeContent
        try {
            docker-compose -f docker-compose.server.yml up -d
        } catch {
            Write-Output "Error starting docker-compose: $_"
            exit 1
        }
        Write-Output "Wait a couple minutes for GitLab server to be ready, and contiue the setup."
        Start-Sleep -Seconds 30
        docker exec -it gitlab-server gitlab-ctl reconfigure
        docker restart gitlab-server
        $response = Read-Host "For perminission to access the repostiories through SSH, would you like generate ssh key? (y/n)"
        switch($response){
            "y"{
                $sshKeyName = Read-Host "Please, enter the name of the SSH key"
                $yourEmail = Read-Host "Please, enter your email"
                if (Test-Path "~/.ssh/$sshKeyName") {
                    Write-Output "SSH key already exists!"
                    return
                }
                ssh-keygen -t rsa -b 4096 -C $yourEmail -f "~/.ssh/$sshKeyName"
                # Copy SSH Key to Clipboard
                Get-Content "~/.ssh/$sshKeyName.pub" | Set-Clipboard
                Write-Host "SSH Public Key has been copied to clipboard."
                # Configure SSH for custom port
                $env:GIT_SSH_COMMAND = "ssh -i C:\Users\$env:USERNAME\.ssh\[$sshKeyName] -p 23022"
                Write-Host "SSH Configuration completed."
            }
            "n"{
                Write-Host "Please , Manually generate SSH key(or use existing) and link it to the gitlab account"
                exit
            }
            default{
                Write-Output "Wrong input! try again."
                return
            }
        }
        Write-Host "Your password: " docker exec -it gitlab-server cat /etc/gitlab/initial_root_password | Select-String "Password:" | ForEach-Object { $_.ToString().Split(':')[1].Trim() }
        Write-Host "Now, log in to GitLab at https://$ip:23443 using 'root' as the username and the provided root password. Add your SSH key to your profile, and you're all set to clone repositories!"

    }
}
