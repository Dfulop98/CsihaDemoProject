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
