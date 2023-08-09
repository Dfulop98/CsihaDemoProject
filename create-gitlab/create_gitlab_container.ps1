$ip = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias Ethernet).IPAddress

if (-not (Test-Path ../certs/ -PathType Container)) {
    mkdir ../certs/
    $confContent = Get-Content .\sslcert.cnf -Raw
    $confContent = $confContent.Replace("REPLACE_WITH_IP", $ip)
    Set-Content .\sslcert.cnf -Value $confContent
    # Generate ssl certs
    openssl req -x509 -nodes -days 730 -newkey rsa:2048 -keyout ../certs/$ip.key -out ../certs/$ip.crt -config sslcert.cnf -extensions 'v3_req'

    Write-Output "Self-signed certificates successfully created: $ip.crt and $ip.key"
}


docker --version
# we need linux container management for run gitlab server
if((docker info --format '{{ .OSType }}') -eq 'windows'){
    & $Env:ProgramFiles\Docker\Docker\DockerCli.exe -SwitchDaemon
}

$composeContent = Get-Content .\docker-compose.yml -Raw
$composeContent = $composeContent.Replace("REPLACE_WITH_IP", $ip)
Set-Content .\docker-compose.yml -Value $composeContent

docker-compose up -d

# Wait for a few minutes for GitLab server to be ready
Start-Sleep -Seconds 180

# GitLab reconfiguration
docker exec -it gitlab-server gitlab-ctl reconfigure
docker restart gitlab-server

# Fetch initial root password
$rootPassword = docker exec -it gitlab-server cat /etc/gitlab/intial_root_password
Write-Host "Initial root password is: $rootPassword"

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

if (-not (Test-Path "~/.ssh/$sshKeyName")) {
    ssh-keygen -t rsa -b 4096 -C $yourEmail -f "~/.ssh/$sshKeyName"
}

Write-Host "Now, log in to GitLab at https://$ip:23443 using 'root' as the username and the provided root password. Add your SSH key to your profile, and you're all set to clone repositories!"


