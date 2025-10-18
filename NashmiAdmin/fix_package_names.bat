@echo off
echo Fixing package names in Dart files...
for /r lib %%f in (*.dart) do (
    powershell -Command "(Get-Content '%%f') -replace 'package:nashmi_admin/', 'package:nashmi_admin_v2/' | Set-Content '%%f'"
)
echo Package names fixed successfully!
pause
