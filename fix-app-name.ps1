# Fix App Name - Change Zarayah back to Zaryah

Write-Host "Fixing app name from Zarayah to Zaryah..." -ForegroundColor Yellow

$files = @(
    "flutter-app\lib\main.dart",
    "flutter-app\lib\screens\login_screen.dart",
    "flutter-app\lib\screens\chatbot_screen.dart"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        $content = Get-Content $file -Raw
        $content = $content -replace 'Zarayah', 'Zaryah'
        Set-Content -Path $file -Value $content
        Write-Host "  Fixed: $file" -ForegroundColor Green
    }
}

Write-Host "Done! App name is now Zaryah" -ForegroundColor Green
