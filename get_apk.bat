@echo off
echo.
echo 📱 APK File Location:
echo.
echo The APK file is located at:
echo build\app\outputs\flutter-apk\app-debug.apk
echo.
echo To install on your Android device:
echo 1. Copy the APK file to your phone
echo 2. Enable "Install from unknown sources" in settings
echo 3. Open the file on your phone and install
echo.
echo Press any key to open the folder...
pause >nul
explorer "build\app\outputs\flutter-apk"
