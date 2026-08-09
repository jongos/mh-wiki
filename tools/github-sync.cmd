@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0github-sync.ps1" %*
