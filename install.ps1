# install.ps1 – полностью автономная установка бота
$ErrorActionPreference = "Stop"

function Update-Path {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

# Проверяем и устанавливаем Node.js
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "Node.js не найден. Устанавливаем..."
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install OpenJS.NodeJS --silent --accept-package-agreements
    } else {
        $nodeUrl = "https://nodejs.org/dist/v20.18.1/node-v20.18.1-x64.msi"
        $nodeInstaller = "$env:TEMP\node.msi"
        Invoke-WebRequest -Uri $nodeUrl -OutFile $nodeInstaller -UseBasicParsing
        Start-Process msiexec -ArgumentList "/i `"$nodeInstaller`" /quiet /norestart" -Wait
        Remove-Item $nodeInstaller -Force
    }
    Update-Path
}

# Проверяем и устанавливаем Git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Git не найден. Устанавливаем..."
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install Git.Git --silent --accept-package-agreements
    } else {
        $gitUrl = "https://github.com/git-for-windows/git/releases/download/v2.47.0.windows.1/Git-2.47.0-64-bit.exe"
        $gitInstaller = "$env:TEMP\git.exe"
        Invoke-WebRequest -Uri $gitUrl -OutFile $gitInstaller -UseBasicParsing
        Start-Process -FilePath $gitInstaller -ArgumentList "/VERYSILENT /NORESTART /SUPPRESSMSGBOXES" -Wait
        Remove-Item $gitInstaller -Force
    }
    Update-Path
}

$InstallDir = "$env:USERPROFILE\Documents\dreamworld-bot"
$RepoUrl = "https://github.com/Xryakva/Tetst.git"

# Клонируем или обновляем репозиторий
if (Test-Path $InstallDir) {
    Set-Location $InstallDir
    git pull
} else {
    git clone $RepoUrl $InstallDir
    Set-Location $InstallDir
}

# Устанавливаем зависимости (npm уже должен быть виден)
if (-not (Test-Path "node_modules")) {
    Write-Host "Установка зависимостей..."
    npm install
}

# Устанавливаем PM2
if (-not (Get-Command pm2 -ErrorAction SilentlyContinue)) {
    Write-Host "Установка PM2..."
    npm install -g pm2
    Update-Path
}

# Запускаем бота через PM2
Write-Host "Запуск бота..."
cmd /c "pm2 stop dreamworld-bot 2>nul"
cmd /c "pm2 delete dreamworld-bot 2>nul"
cmd /c "pm2 start server.js --name dreamworld-bot"
cmd /c "pm2 save"

Write-Host "Бот успешно запущен!"
exit
