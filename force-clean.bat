@echo off
echo ========================================
echo FORCE CLEANING FLUTTER PROJECT
echo ========================================
echo.

echo Stopping processes...
taskkill /F /IM java.exe /T >nul 2>&1
taskkill /F /IM javaw.exe /T >nul 2>&1
taskkill /F /IM dart.exe /T >nul 2>&1
taskkill /F /IM flutter.exe /T >nul 2>&1
taskkill /F /IM adb.exe /T >nul 2>&1
taskkill /F /IM Code.exe /T >nul 2>&1

echo Waiting 3 seconds...
timeout /t 3 /nobreak >nul

echo.
echo Deleting build folders...
rd /s /q build 2>nul
rd /s /q .dart_tool 2>nul
rd /s /q android\.gradle 2>nul
rd /s /q android\app\build 2>nul
rd /s /q android\build 2>nul

echo.
echo Deleting ephemeral files...
del /f /q .flutter-plugins 2>nul
del /f /q .flutter-plugins-dependencies 2>nul
del /f /q .packages 2>nul
del /f /q pubspec.lock 2>nul

echo.
echo Running flutter pub get...
flutter pub get

echo.
echo ========================================
echo CLEANUP COMPLETE!
echo ========================================
pause
