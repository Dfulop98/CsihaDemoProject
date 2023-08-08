$scriptPath = Join-Path $PSScriptRoot "setup_docker.ps1"
$conditionForReboot = "false"

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    
    # Telepíti a Docker Desktop-ot
    choco install docker-desktop -y
    # Hyper-V és Containers engedélyezése   
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
    Enable-WindowsOptionalFeature -Online -FeatureName Containers -All
    $conditionForReboot = "true"
}



$response = Read-Host "After settings hyper-v and container, windows have to be restart. Would you like to restart now? (y/n)"
if ($conditionForReboot = "true"){
    switch($response){
        "y"{
            $taskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File '$scriptPath'"
            $taskTrigger = New-ScheduledTaskTrigger -AtStartup
            $taskPrincipal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount
            Register-ScheduledTask -Action $taskAction -Trigger $taskTrigger -TaskName "RunDockerSetupScriptAfterReboot" -Principal $taskPrincipal -Force
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

docker --version
# we need linux container management for run gitlab server
if(docker info --format '{{ .OSType }}' == "windows"){
    & $Env:ProgramFiles\Docker\Docker\DockerCli.exe -SwitchDaemon
}
docker-compose up -d
