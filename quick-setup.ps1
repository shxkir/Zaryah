Write-Host "Zaryah Database Setup" -ForegroundColor Cyan
Write-Host ""

$pgPassword = Read-Host "Enter your PostgreSQL password"

Write-Host ""
Write-Host "Updating .env file..." -ForegroundColor Yellow

$envPath = "c:\Users\ismai\Downloads\Zaryah\.env"
$envContent = @"
# Database
DATABASE_URL="postgresql://postgres:$pgPassword@localhost:5432/zaryah?schema=public"

# JWT Secret (change this in production)
JWT_SECRET="zaryah-super-secret-jwt-key-2024-change-in-production"

# Server Port
PORT=3000

# Google AI Studio API Key (Gemini)
GOOGLE_API_KEY="AIzaSyBFqV-xtwHZynh_c35LXuaTRWBRxH_GcSc"

# Pinecone API Key
PINECONE_API_KEY="pcsk_41qBGm_Nz3myudzw61exBfqE1SWG5yPfEkXDSt9nNwe8kFju3HEshAR9tz3m6kMdTsXPJ2"
"@

Set-Content -Path $envPath -Value $envContent

Write-Host "Done!" -ForegroundColor Green
Write-Host ""
Write-Host "Creating database..." -ForegroundColor Yellow

$env:PGPASSWORD = $pgPassword
& "C:\Program Files\PostgreSQL\18\bin\psql.exe" -U postgres -c "CREATE DATABASE zaryah;" 2>&1

$env:PGPASSWORD = $null

Write-Host ""
Write-Host "Running migrations..." -ForegroundColor Yellow
Set-Location "c:\Users\ismai\Downloads\Zaryah"
npm run prisma:migrate

Write-Host ""
Write-Host "Seeding database..." -ForegroundColor Yellow
npm run seed

Write-Host ""
Write-Host "Setup complete!" -ForegroundColor Green
