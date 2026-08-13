@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0wiki-test.ps1" %*
exit /b %ERRORLEVEL%
