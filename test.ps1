
$ip = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias Ethernet).IPAddress

if (Test-Path "installState.txt") {
    $installState = Get-Content "installState.txt"
} else {
    $installState = "start"
}

switch ($installState) {
    "start" {
        if (-not $chocoExists) {
            $userInputChoco = Read-Host "Chocolatey is not found. Would you like to install now? (y/n)"
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
        "chocoInstalled" | Out-File "installState.txt"
        Restart-Computer
    }

    "chocoInstalled" {
        # OpenSSl install 
        if (-not $opensslExists) {
            $userInputOpenSSL = Read-Host "OpenSSL is not found. Would you like to install now? (y/n)"
        
            switch ($userInputOpenSSL){
                "y" {
                    Write-Output "Start installing OpenSSl:"
                    choco install openssl -y
                    if (-not (Test-Path ../certs/ -PathType Container)) {
                        mkdir ../certs/
                        $confContent = Get-Content .\sslcert.cnf -Raw
                        $confContent = $confContent.Replace("REPLACE_WITH_IP", $ip)
                        Set-Content .\sslcert.cnf -Value $confContent
                        # Generate ssl certs
                        openssl req -x509 -nodes -days 730 -newkey rsa:2048 -keyout ../certs/$ip.key -out ../certs/$ip.crt -config sslcert.cnf -extensions 'v3_req'
                        Write-Output "Self-signed certificates successfully created: $ip.crt and $ip.key"
                    }
                    "OpenSSLInstalled" | Out-File "installState.txt"
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
        
        
        "OpenSSLInstalled" | Out-File "installState.txt"
        
    }

    "OpenSSLInstalled" {
        Write-Output "Start installing Docker desktop:"
        choco install docker-desktop -y
        wsl --update
        "dockerInstalled" | Out-File "installState.txt"
        Restart-Computer

    }
    "dockerInstalled" {
        Write-Output "Enabling Hyper-V and container:"
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
	    Enable-WindowsOptionalFeature -Online -FeatureName Containers -All
        "hyperVSetup" | Out-File "installState.txt"
        Restart-Computer
    }
    "hyperVSetup" {
        Write-Output "Start installing GitLab:"
        if((docker info --format '{{ .OSType }}') -eq 'windows'){
            & $Env:ProgramFiles\Docker\Docker\DockerCli.exe -SwitchDaemon
        }
        $composeContent = Get-Content .\docker-compose.yml -Raw
        $composeContent = $composeContent.Replace("REPLACE_WITH_IP", $ip)
        Set-Content .\docker-compose.yml -Value $composeContent
        docker-compose up -d
        Write-Output "Wait a couple minutes for GitLab server to be ready, and contiue the setup."
        Start-Sleep -Seconds 180
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
                cat "~/.ssh/$sshKeyName.pub" | xclip -selection clipboard
                Write-Host "SSH Public Key has been copied to clipboard."
                # Configure SSH for custom port
                $env:GIT_SSH_COMMAND = "ssh -i C:\Users\[username]\.ssh\[$sshKeyName] -p 23022"
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
        Write-Host "Now, log in to GitLab at https://$ip:23443 using 'root' as the username and the provided root password. Add your SSH key to your profile, and you're all set to clone repositories!"

    }
}