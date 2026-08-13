@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0generate-publish-navigation.ps1" %*
exit /b %ERRORLEVEL%
