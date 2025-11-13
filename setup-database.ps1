# Zaryah Database Setup Script for Windows
# Run this script to create the PostgreSQL database

Write-Host "Zaryah Database Setup" -ForegroundColor Green
Write-Host "=====================" -ForegroundColor Green
Write-Host ""

# Check if PostgreSQL is installed
$psqlPath = Get-Command psql -ErrorAction SilentlyContinue

if (-not $psqlPath) {
    Write-Host "ERROR: PostgreSQL is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install PostgreSQL from: https://www.postgresql.org/download/windows/" -ForegroundColor Yellow
    exit 1
}

Write-Host "PostgreSQL found!" -ForegroundColor Green
Write-Host ""

# Get PostgreSQL credentials
Write-Host "Enter your PostgreSQL credentials:" -ForegroundColor Cyan
$username = Read-Host "Username (default: postgres)"
if ([string]::IsNullOrWhiteSpace($username)) {
    $username = "postgres"
}

$password = Read-Host "Password" -AsSecureString
$passwordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
)

Write-Host ""
Write-Host "Creating database 'zaryah'..." -ForegroundColor Yellow

# Set password environment variable
$env:PGPASSWORD = $passwordPlain

# Create database
$createDbCommand = "psql -U $username -h localhost -c `"CREATE DATABASE zaryah;`" postgres"
try {
    Invoke-Expression $createDbCommand
    Write-Host "Database 'zaryah' created successfully!" -ForegroundColor Green
} catch {
    Write-Host "Database might already exist or there was an error." -ForegroundColor Yellow
}

# Update .env file
Write-Host ""
Write-Host "Updating .env file..." -ForegroundColor Yellow

$envPath = Join-Path $PSScriptRoot ".env"
if (Test-Path $envPath) {
    $envContent = Get-Content $envPath -Raw
    $newDatabaseUrl = "DATABASE_URL=`"postgresql://${username}:${passwordPlain}@localhost:5432/zaryah?schema=public`""
    $envContent = $envContent -replace 'DATABASE_URL=".*"', $newDatabaseUrl
    Set-Content -Path $envPath -Value $envContent
    Write-Host ".env file updated with database credentials!" -ForegroundColor Green
} else {
    Write-Host "ERROR: .env file not found!" -ForegroundColor Red
}

# Clear password from environment
Remove-Item Env:\PGPASSWORD

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. npm run prisma:generate" -ForegroundColor White
Write-Host "2. npm run prisma:migrate" -ForegroundColor White
Write-Host "3. npm run seed" -ForegroundColor White
Write-Host "4. npm start" -ForegroundColor White
Write-Host ""
