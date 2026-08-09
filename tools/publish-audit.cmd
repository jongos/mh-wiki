@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0publish-audit.ps1" %*
