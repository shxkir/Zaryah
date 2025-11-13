# Interactive Database Setup Script for Zaryah

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "  Zaryah Database Setup" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Get PostgreSQL password
$pgPassword = Read-Host "Enter your PostgreSQL password" -AsSecureString
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pgPassword)
$plainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

Write-Host ""
Write-Host "Step 1: Updating .env file..." -ForegroundColor Yellow

# Update .env file
$envPath = Join-Path $PSScriptRoot ".env"
$envContent = Get-Content $envPath -Raw

# Replace the DATABASE_URL line
$newDatabaseUrl = "DATABASE_URL=`"postgresql://postgres:$plainPassword@localhost:5432/zaryah?schema=public`""
$envContent = $envContent -replace 'DATABASE_URL="postgresql://postgres:.*?@localhost:5432/zaryah\?schema=public"', $newDatabaseUrl

Set-Content -Path $envPath -Value $envContent -NoNewline

Write-Host "✓ .env file updated" -ForegroundColor Green
Write-Host ""

Write-Host "Step 2: Creating database..." -ForegroundColor Yellow

# Set password environment variable
$env:PGPASSWORD = $plainPassword

# Try to create database
try {
    $psqlPath = "C:\Program Files\PostgreSQL\18\bin\psql.exe"

    # Check if database exists
    $checkDb = & $psqlPath -U postgres -lqt | Select-String "zaryah"

    if (-not $checkDb) {
        & $psqlPath -U postgres -c "CREATE DATABASE zaryah;" 2>&1 | Out-Null
        Write-Host "✓ Database 'zaryah' created" -ForegroundColor Green
    } else {
        Write-Host "✓ Database 'zaryah' already exists" -ForegroundColor Green
    }
} catch {
    Write-Host "⚠ Could not create database automatically. Please create it manually using pgAdmin." -ForegroundColor Yellow
    Write-Host "  1. Open pgAdmin" -ForegroundColor Gray
    Write-Host "  2. Right-click 'Databases' → Create → Database" -ForegroundColor Gray
    Write-Host "  3. Name: zaryah" -ForegroundColor Gray
    Write-Host "  4. Click Save" -ForegroundColor Gray
    Write-Host ""
    $continue = Read-Host "Press Enter after creating the database, or type 'skip' to continue anyway"
}

# Clear password from environment
$env:PGPASSWORD = $null

Write-Host ""
Write-Host "Step 3: Running Prisma migrations..." -ForegroundColor Yellow
npm run prisma:migrate 2>&1

Write-Host ""
Write-Host "Step 4: Seeding database with 30 users..." -ForegroundColor Yellow
npm run seed

Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "  Setup Complete!" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Run: npm start" -ForegroundColor White
Write-Host "2. In new terminal: cd flutter-app && flutter run" -ForegroundColor White
Write-Host ""
Write-Host "Test login:" -ForegroundColor Yellow
Write-Host "  Email: sarah.johnson@example.com" -ForegroundColor White
Write-Host "  Password: password123" -ForegroundColor White
