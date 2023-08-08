
if (-not (Test-Path ../certs/ -PathType Container)) {
    mkdir ../certs/
}

# Generate private key
openssl genrsa -out ../certs/gitlab.key 2048

# Generate certificate signing request
openssl req -new -key ../certs/gitlab.key -out ../certs/gitlab.csr -subj "/C=HU/ST=Csongrad/L=Szeged/O=Organization/CN=localhost"

# Generate self-signed certificate
openssl x509 -req -days 365 -in ../certs/gitlab.csr -signkey ../certs/gitlab.key -out ../certs/gitlab.crt

Write-Output "Self-signed certificates successfully created: ${DOMAIN}.crt and ${DOMAIN}.key"

docker --version
# we need linux container management for run gitlab server
if((docker info --format '{{ .OSType }}') -eq 'windows'){
    & $Env:ProgramFiles\Docker\Docker\DockerCli.exe -SwitchDaemon
}

$ip = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias Ethernet).IPAddress
$composeContent = Get-Content .\docker-compose.yml -Raw
$composeContent = $composeContent.Replace("REPLACE_WITH_IP", $ip)
Set-Content .\docker-compose.yml -Value $composeContent

docker-compose up -d
