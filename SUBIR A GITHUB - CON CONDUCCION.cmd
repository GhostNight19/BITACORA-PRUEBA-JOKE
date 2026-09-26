@echo off
chcp 65001 >nul
cd /d "%~dp0"

title SyncroRed EFESUR - Subir CON Modo Conduccion

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0publicar-github.ps1" -Destino con
set RESULTADO=%ERRORLEVEL%

echo.
if not "%RESULTADO%"=="0" (
  echo La subida no termino. Revisa el mensaje de arriba.
)
echo.
pause
exit /b %RESULTADO%
