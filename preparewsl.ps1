#Requires -RunAsAdministrator

New-Item -ItemType Directory -Force -Path C:\Temp
$wslenabled = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux | Select-Object -Property State

if($wslenabled.State -eq "Disabled")
{
    Write-Host "WSL is not enabled.  Enabling now." -ForegroundColor Yellow -BackgroundColor DarkGreen
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
    Write-Host "Please reboot, then run this script again." -ForegroundColor Yellow -BackgroundColor DarkGreen
    exit
}

Write-Host "WSL already enabled. Moving on." -ForegroundColor Yellow -BackgroundColor DarkGreen

if(!(Test-Path "C:\Temp\UBU1804.appx"))
{
    Write-Host "Downloading the Ubuntu 18.04 image. Please wait." -ForegroundColor Yellow -BackgroundColor DarkGreen
    Invoke-WebRequest -Uri "https://aka.ms/wsl-ubuntu-1804" -OutFile "C:\Temp\UBU1804.appx" -UseBasicParsing 
}
else 
{
    Write-Host "The Ubuntu 18.04 image was already at C:\Temp\UBU1804.appx. Moving on." -ForegroundColor Yellow -BackgroundColor DarkGreen
}

$ubu1804appxinstalled = Get-AppxPackage -Name CanonicalGroupLimited.Ubuntu18.04onWindows

if($ubu1804appxinstalled){
    Write-Host "Ubuntu 18.04 appx is already installed. Moving on." -ForegroundColor Yellow -BackgroundColor DarkGreen
}
else {
    Write-Host "Installing the Ubuntu 18.04 Appx distro. Please wait." -ForegroundColor Yellow -BackgroundColor DarkGreen
    Add-AppxPackage -Path "C:\Temp\UBU1804.appx"

}

Write-Host "Configuring Ubuntu 18.04... " -ForegroundColor Yellow -BackgroundColor DarkGreen
Write-Host "Initialise Ubuntu distro" -ForegroundColor Yellow -BackgroundColor DarkGreen
Start-Process "ubuntu1804.exe" -ArgumentList "install --root" -Wait -NoNewWindow
Write-Host "Set /c/ as mount point"
Start-Process "ubuntu1804.exe" -ArgumentList "run echo '[automount]' > /etc/wsl.conf" -Wait -NoNewWindow
Start-Process "ubuntu1804.exe" -ArgumentList "run echo 'root = /' >> /etc/wsl.conf" -Wait -NoNewWindow
Start-Process "ubuntu1804.exe" -ArgumentList "run echo 'options = \""metadata,umask=22,fmask=11,uid=1000,gid=1000\""' >> /etc/wsl.conf " -Wait -NoNewWindow
Restart-Service LxssManager
Start-Sleep -s 5

$username = Read-Host -Prompt 'The WSL user name you want'

Write-Host "Create the $username user " -ForegroundColor Yellow -BackgroundColor DarkGreen
Start-Process "ubuntu1804.exe" -ArgumentList "run adduser $username --gecos 'First,Last,RoomNumber,WorkPhone,HomePhone' --disabled-password" -Wait -NoNewWindow
Write-Host "Add $username to sudo group" -ForegroundColor Yellow -BackgroundColor DarkGreen
Start-Process "ubuntu1804.exe" -ArgumentList "run usermod -aG sudo $username" -Wait -NoNewWindow
Write-Host "Allow $username to run apt updates" -ForegroundColor Yellow -BackgroundColor DarkGreen
Start-Process "ubuntu1804.exe" -ArgumentList "run echo '$username ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers" -Wait -NoNewWindow
Write-Host "Ask for $username password to set" -ForegroundColor Yellow -BackgroundColor DarkGreen
Start-Process "ubuntu1804.exe" -ArgumentList "run passwd $username" -Wait -NoNewWindow
Write-Host "Set WSL default user to $username" -ForegroundColor Yellow -BackgroundColor DarkGreen
Start-Process "ubuntu1804.exe" -ArgumentList "config --default-user $username" -Wait -NoNewWindow
Write-Host "Configure Ubuntu, install docker, set environment..." -ForegroundColor Yellow -BackgroundColor DarkGreen
Start-Process "WSL" -ArgumentList "bash preparewsl.sh" -Wait -NoNewWindow


Write-Host "Installing Docker Desktop" -ForegroundColor Yellow -BackgroundColor DarkGreen

if(!(Test-Path "C:\Temp\docker-desktop-installer.exe"))
{
    Write-Host "Downloading the Docker Desktop installer." -ForegroundColor Yellow -BackgroundColor DarkGreen
    Start-BitsTransfer -Source "https://download.docker.com/win/stable/Docker%20Desktop%20Installer.exe" -Destination "C:\Temp\docker-desktop-installer.exe" -Description "Downloading Docker Desktop"
}

Start-Process 'C:\Temp\docker-desktop-installer.exe' -ArgumentList 'install --quiet' -Wait -NoNewWindow

Stop-Service *docker*

Write-Host "Setting Docker to allow TCP port 2375" -ForegroundColor Yellow -BackgroundColor DarkGreen

$dockerpath = "$env:APPDATA\Docker\settings.json"
$settings = Get-Content $dockerpath | ConvertFrom-Json

$settings.exposeDockerAPIOnTCP2375 = $true

$settings | ConvertTo-Json | Set-Content $dockerpath

Start-Service *docker*  

Write-Host "Starting Docker Desktop" -ForegroundColor Yellow -BackgroundColor DarkGreen
& 'C:\Program Files\Docker\Docker\Docker Desktop.exe'


Write-Host "Done." -ForegroundColor Yellow -BackgroundColor DarkGreen