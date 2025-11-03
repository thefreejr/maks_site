# PowerShell скрипт для создания директории логов перед запуском Docker

if (-not (Test-Path "logs\nginx")) {
    New-Item -ItemType Directory -Path "logs\nginx" -Force | Out-Null
    Write-Host "Директория для логов создана: logs\nginx" -ForegroundColor Green
} else {
    Write-Host "Директория для логов уже существует: logs\nginx" -ForegroundColor Yellow
}

