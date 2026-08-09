$ErrorActionPreference = "Continue"
function Update-Path { $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") }

Write-Host "Начинаем установку DreamWorld Bot..." -ForegroundColor Cyan

# Проверяем и устанавливаем Node.js
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "Node.js не найден. Скачиваем и устанавливаем..." -ForegroundColor Yellow
    $nodeUrl = "https://nodejs.org/dist/v20.18.1/node-v20.18.1-x64.msi"
    $nodeInstaller = "$env:TEMP\node.msi"
    try {
        Invoke-WebRequest -Uri $nodeUrl -OutFile $nodeInstaller -UseBasicParsing
        Start-Process msiexec -ArgumentList "/i `"$nodeInstaller`" /quiet /norestart" -Wait
        Remove-Item $nodeInstaller -Force
        Update-Path
        Write-Host "Node.js установлен." -ForegroundColor Green
    } catch {
        Write-Host "Ошибка установки Node.js: $_" -ForegroundColor Red
        Read-Host "Нажмите Enter для выхода"
        exit 1
    }
} else {
    Write-Host "Node.js уже установлен." -ForegroundColor Green
}

# Проверяем и устанавливаем Git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Git не найден. Скачиваем и устанавливаем..." -ForegroundColor Yellow
    $gitUrl = "https://github.com/git-for-windows/git/releases/download/v2.47.0.windows.1/Git-2.47.0-64-bit.exe"
    $gitInstaller = "$env:TEMP\git.exe"
    try {
        Invoke-WebRequest -Uri $gitUrl -OutFile $gitInstaller -UseBasicParsing
        Start-Process -FilePath $gitInstaller -ArgumentList "/VERYSILENT /NORESTART /SUPPRESSMSGBOXES" -Wait
        Remove-Item $gitInstaller -Force
        Update-Path
        Write-Host "Git установлен." -ForegroundColor Green
    } catch {
        Write-Host "Ошибка установки Git: $_" -ForegroundColor Red
        Read-Host "Нажмите Enter для выхода"
        exit 1
    }
} else {
    Write-Host "Git уже установлен." -ForegroundColor Green
}

# Клонируем или обновляем репозиторий
$InstallDir = "$env:USERPROFILE\Documents\dreamworld-bot"
$RepoUrl = "https://github.com/Xryakva/Tetst.git"

Write-Host "Клонирование/обновление репозитория..." -ForegroundColor Yellow
if (Test-Path $InstallDir) {
    Set-Location $InstallDir
    git pull
} else {
    git clone $RepoUrl $InstallDir
    Set-Location $InstallDir
}

# Устанавливаем зависимости
if (-not (Test-Path "node_modules")) {
    Write-Host "Установка зависимостей..." -ForegroundColor Yellow
    npm install
}

# Устанавливаем PM2
if (-not (Get-Command pm2 -ErrorAction SilentlyContinue)) {
    Write-Host "Установка PM2..." -ForegroundColor Yellow
    npm install -g pm2
    Update-Path
}

# Запускаем бота
Write-Host "Запуск бота через PM2..." -ForegroundColor Yellow
pm2 stop dreamworld-bot 2>$null
pm2 delete dreamworld-bot 2>$null
pm2 start server.js --name dreamworld-bot
pm2 save

Write-Host "Бот успешно запущен!" -ForegroundColor Green
Write-Host "Проверьте статус: pm2 status" -ForegroundColor Cyan
Read-Host "Нажмите Enter для выхода"
exit
