$ErrorActionPreference = "Stop"
function Update-Path { $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") }

if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    if (Get-Command refreshenv -ErrorAction SilentlyContinue) { refreshenv } else { Update-Path }
}
Update-Path

choco install nodejs git -y --limit-output
Update-Path

$InstallDir = "$env:USERPROFILE\Documents\dreamworld-bot"
$RepoUrl = "https://github.com/Xryakva/Tetst.git"
if (Test-Path $InstallDir) { Set-Location $InstallDir; git pull } else { git clone $RepoUrl $InstallDir; Set-Location $InstallDir }
if (-not (Test-Path "node_modules")) { npm install }
if (-not (Get-Command pm2 -ErrorAction SilentlyContinue)) { npm install -g pm2; Update-Path }

pm2 stop dreamworld-bot 2>$null; pm2 delete dreamworld-bot 2>$null
pm2 start server.js --name dreamworld-bot --silent
pm2 save
exit
