$conditionForReboot = $false
$scriptPath = Join-Path $PSScriptRoot "created_self_signed_cert.ps1"
$DOMAIN = "$1"

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
            $conditionForReboot = $true
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


if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    
    # Telepíti a Docker Desktop-ot
    choco install docker-desktop -y
    # Wsl update
    wsl --update
    $conditionForReboot = $true
}



if ($conditionForReboot) {
    $response = Read-Host "After installation process, the device restart is important. Would you like to restart now? (y/n)"

    switch($response){
        "y"{
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