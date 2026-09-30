# FocusPulse Quick Runner Script
Write-Host "========================================" -ForegroundColor Green
Write-Host "       FocusPulse - App Launcher        " -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

# 1. Verify Flutter
$flutterCmd = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $flutterCmd) {
    Write-Host "[!] Flutter command not found on PATH." -ForegroundColor Yellow
    Write-Host "Please ensure Flutter SDK is installed and added to your System PATH." -ForegroundColor Yellow
    Write-Host "Visit: https://docs.flutter.dev/get-started/install/windows/mobile" -ForegroundColor Cyan
    exit 1
}

Write-Host "[+] Found Flutter at: $($flutterCmd.Source)" -ForegroundColor Green

# 2. Pub Get
Write-Host "`n[+] Fetching dependencies..." -ForegroundColor Cyan
flutter pub get

# 3. Check connected devices
Write-Host "`n[+] Checking connected devices..." -ForegroundColor Cyan
flutter devices

# 4. Prompt to Run
Write-Host "`nChoose an option to launch:" -ForegroundColor White
Write-Host "  1) Android Emulator / Connected Phone" -ForegroundColor Yellow
Write-Host "  2) Chrome Browser (Fast UI Inspection)" -ForegroundColor Yellow
$choice = Read-Host "Enter 1 or 2 (Default: 1)"

if ($choice -eq "2") {
    Write-Host "`n[+] Launching in Chrome..." -ForegroundColor Green
    flutter run -d chrome
} else {
    Write-Host "`n[+] Launching on Android..." -ForegroundColor Green
    flutter run
}
