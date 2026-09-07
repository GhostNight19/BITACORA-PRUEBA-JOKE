@echo off
chcp 65001 >nul
cd /d "%~dp0"

echo.
echo ================================================================
echo   SYNCRORED EFESUR - actualizar pautas, boletines y grafico
echo ================================================================
echo.
echo   Antes de correr esto, deja los archivos nuevos en su carpeta:
echo.
echo     pautas_excel      las pautas diarias (.xlsx)
echo     boletines_excel   los boletines de via C (.xlsx)
echo     graficos_excel    el grafico del mes (.xlsx)
echo.
echo ----------------------------------------------------------------

set PY=py
where py >nul 2>nul || set PY=python

echo.
echo [1/4] Pautas diarias
%PY% -X utf8 convertir_pautas.py
if errorlevel 1 goto :error

echo.
echo [2/4] Boletines de via
%PY% -X utf8 convertir_boletin.py
if errorlevel 1 goto :error

echo.
echo [3/4] Grafico del mes
%PY% -X utf8 convertir_grafico.py
if errorlevel 1 goto :error

echo.
echo [4/4] Version sin Modo Conduccion
%PY% -X utf8 generar_sin_conduccion.py
if errorlevel 1 goto :error

echo.
echo ================================================================
echo   LISTO
echo.
echo   Sube al repositorio la carpeta "SIN CONDUCCION" completa.
echo   Si tambien usas la version con Modo Conduccion, sube ademas
echo   las carpetas pautas, prevenciones, grafico y personal de aqui.
echo ================================================================
echo.
pause
exit /b 0

:error
echo.
echo ================================================================
echo   ALGO FALLO. Mira el mensaje de arriba: casi siempre es un
echo   archivo que no se pudo leer o una fecha que no se dedujo.
echo   No se subio nada; el paso que fallo no dejo archivos a medias.
echo ================================================================
echo.
pause
exit /b 1
