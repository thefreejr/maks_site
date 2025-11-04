# PowerShell скрипт для генерации самоподписанного SSL сертификата
# Использование: .\generate-ssl.ps1 [доменное_имя]

param(
    [string]$Domain = "lean-tpm.ru"
)

$sslDir = "./ssl"

# Создаем директорию для сертификатов
if (-not (Test-Path $sslDir)) {
    New-Item -ItemType Directory -Path $sslDir | Out-Null
}

# Генерируем самоподписанный сертификат
$cert = New-SelfSignedCertificate `
    -CertStoreLocation "cert:\CurrentUser\My" `
    -DnsName $Domain `
    -KeyAlgorithm RSA `
    -KeyLength 2048 `
    -Provider "Microsoft RSA SChannel Cryptographic Provider" `
    -KeyExportPolicy Exportable `
    -KeyUsage DigitalSignature, KeyEncipherment `
    -Type SSLServerAuthentication

# Экспортируем приватный ключ в PEM формат
$certPath = "Cert:\CurrentUser\My\$($cert.Thumbprint)"
$keyPath = "$sslDir\key.pem"
$certPathOut = "$sslDir\cert.pem"

# Экспортируем сертификат в PEM формат
$certBytes = $cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert)
$base64Cert = [System.Convert]::ToBase64String($certBytes)
$certPem = "-----BEGIN CERTIFICATE-----`n"
$certPem += ($base64Cert -replace ".{64}", "`$0`n")
$certPem += "`n-----END CERTIFICATE-----"
$certPem | Out-File -FilePath $certPathOut -Encoding ASCII -NoNewline

# Экспортируем приватный ключ (требует дополнительных инструментов или использование OpenSSL)
Write-Host "Внимание: Для экспорта приватного ключа в PEM формате на Windows требуется OpenSSL." -ForegroundColor Yellow
Write-Host "Вы можете использовать OpenSSL для Windows или создать ключ через generate-ssl.sh в WSL/Git Bash." -ForegroundColor Yellow
Write-Host ""
Write-Host "Альтернативный способ - использовать OpenSSL для Windows:" -ForegroundColor Yellow
Write-Host "1. Установите OpenSSL для Windows" -ForegroundColor Yellow
Write-Host "2. Запустите generate-ssl.sh в Git Bash или используйте команды OpenSSL:" -ForegroundColor Yellow
Write-Host "   openssl genrsa -out ssl/key.pem 2048" -ForegroundColor Cyan
Write-Host "   openssl req -new -x509 -key ssl/key.pem -out ssl/cert.pem -days 365 -subj `/CN=$Domain`" -ForegroundColor Cyan

# Удаляем сертификат из хранилища (опционально)
# Remove-Item $certPath

Write-Host ""
Write-Host "Сертификат создан в: $certPathOut" -ForegroundColor Green
Write-Host "Для полной настройки рекомендуется использовать OpenSSL или generate-ssl.sh" -ForegroundColor Yellow

