@echo off
echo.
echo 🛠️  Building Release APK...
echo.

REM Clean the project
flutter clean

REM Get dependencies
flutter pub get

REM Build the release APK
flutter build apk --release

echo.
echo ✅ Release APK built successfully!
echo.
echo 📱 APK File Location:
echo.
echo The release APK is located at:
echo build\app\outputs\flutter-apk\app-release.apk
echo.
echo To install on your Android device:
echo 1. Copy the APK file to your phone
echo 2. Enable "Install from unknown sources" in settings
echo 3. Open the file on your phone and install
echo.
echo Press any key to open the folder...
pause >nul
explorer "build\app\outputs\flutter-apk"
