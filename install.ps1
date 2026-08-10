$ErrorActionPreference = "Stop"
function Update-Path { $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") }

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "Установка Node.js..."
    $nodeUrl = "https://nodejs.org/dist/v20.18.1/node-v20.18.1-x64.msi"
    $nodeInstaller = "$env:TEMP\node.msi"
    Invoke-WebRequest -Uri $nodeUrl -OutFile $nodeInstaller -UseBasicParsing
    Start-Process msiexec -ArgumentList "/i `"$nodeInstaller`" /quiet /norestart" -Wait
    Remove-Item $nodeInstaller -Force
    Update-Path
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Установка Git..."
    $gitUrl = "https://github.com/git-for-windows/git/releases/download/v2.47.0.windows.1/Git-2.47.0-64-bit.exe"
    $gitInstaller = "$env:TEMP\git.exe"
    Invoke-WebRequest -Uri $gitUrl -OutFile $gitInstaller -UseBasicParsing
    Start-Process -FilePath $gitInstaller -ArgumentList "/VERYSILENT /NORESTART /SUPPRESSMSGBOXES" -Wait
    Remove-Item $gitInstaller -Force
    Update-Path
}

$InstallDir = "$env:USERPROFILE\Documents\dreamworld-bot"
$RepoUrl = "https://github.com/Xryakva/sssssx.git"

if (Test-Path $InstallDir) {
    Set-Location $InstallDir
    git pull
} else {
    git clone $RepoUrl $InstallDir
    Set-Location $InstallDir
}

if (-not (Test-Path "node_modules")) {
    Write-Host "Установка зависимостей..."
    npm install
}

Write-Host "Запуск бота..."
cmd /k "node server.js"
