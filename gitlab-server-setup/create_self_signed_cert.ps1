$conditionForReboot = "false"
$scriptPath = Join-Path $PSScriptRoot "created_self_signed_cert.ps1"

$opensslExists = Get-Command openssl -ErrorAction SilentlyContinue
# Check if OpenSSL is already installed
if (-not $opensslExists) {
    $userInputOpenSSL = Read-Host "OpenSSL is not found. Would you like to install now? (y/n)"

    switch ($userInputOpenSSL){
        "y" {
            
            $chocoExists = Get-Command choco -ErrorAction SilentlyContinue
            # Check if Chocolatey is already installed
            if (-not $chocoExists) {
                $userInputChoco = Read-Host "Chocolatey is not found. Would you like to install now? (y/n)"
                switch ($userInputChoco){
                    "y" {
                        Write-Output "Start installing Chocolatey:"
                        Set-ExecutionPolicy Bypass -Scope Process -Force;
	                    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
	                    iex ((Invoke-WebRequest -Uri https://chocolatey.org/install.ps1).Content)
                    }
                    "n" {
                        Write-Output "Please, Install Chocolatey from here: https://chocolatey.org/install"
                        return
                    }
                    
                    default{
                        Write-Output "Wrong input! try again."
                        return
                    }
                }
            }
            choco install openssl -y
            Write-Output "OpenSSL successfully installed!"
            $conditionForReboot = "true"
        }
        "n" {
            Write-Output "Please, Manually install OpenSSL from the following link: https://www.openssl.org/source/"
            return
        }
        default{
            Write-Output "Wrong input! try again."
            return
        }
    }
}

if ($conditionForReboot == "true") {
    $response = Read-Host "After install openSSL, the device restart is important. Would you like to restart now? (y/n)"

    switch($response){
        "y"{
            $taskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File '$scriptPath'"
            $taskTrigger = New-ScheduledTaskTrigger -AtStartup
            $taskPrincipal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount
            Register-ScheduledTask -Action $taskAction -Trigger $taskTrigger -TaskName "RunCertScriptAfterReboot" -Principal $taskPrincipal -Force
            Restart-Computer -Confirm:$false
        }
        "n"{
            Write-Host "Can not continue the Cretification generating procces without restart your device!"
            exit
        }
        default{
            Write-Output "Wrong input! try again."
            return
        }
    }
}
# Generate private key
openssl genrsa -out ${DOMAIN}.key 2048

# Generate certificate signing request
openssl req -new -key ${DOMAIN}.key -out ${DOMAIN}.csr -subj "/C=Hun/ST=Csongrad/L=Szeged/O=Organization/CN=${DOMAIN}"

# Generate self-signed certificate
openssl x509 -req -days 365 -in ${DOMAIN}.csr -signkey ${DOMAIN}.key -out ${DOMAIN}.crt

Write-Output "Self-signed certificates successfully created: ${DOMAIN}.crt and ${DOMAIN}.key"
