Write-Host "Zaryah Database Setup" -ForegroundColor Cyan
Write-Host ""

$pgPassword = Read-Host "Enter your PostgreSQL password"
$openAiApiKey = Read-Host "Enter your OpenAI API key"
$pineconeApiKey = Read-Host "Enter your Pinecone API key"

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

# OpenAI API Key (for chatbot)
OPENAI_API_KEY="$openAiApiKey"

# Pinecone API Key
PINECONE_API_KEY="$pineconeApiKey"
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
