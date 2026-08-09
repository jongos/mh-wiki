@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0wiki-diagnostics.ps1" %*
