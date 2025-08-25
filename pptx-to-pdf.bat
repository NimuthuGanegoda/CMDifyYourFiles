@echo off
setlocal enabledelayedexpansion

:: === CONFIG ===================================================
set "OFFICE_APP=PowerPoint.Application"
:: ==============================================================

:: === PROCESS ALL PPTX IN ONE GO ===============================
if "%~1"=="" (
    set "SOURCE=%~dp0"
) else (
    set "SOURCE=%~1"
)

if exist "%SOURCE%\" (
    for /r "%SOURCE%" %%F in (*.pptx *.ppt) do (
        call :process "%%~fF"
    )
) else (
    call :process "%SOURCE%"
)
goto :eof
:: ==============================================================

:: === PER-FILE CONVERSION ======================================
:process
set "IN=%~1"
set "OUT=%~dp1PDFs\%~n1.pdf"
if not exist "%~dp1PDFs" mkdir "%~dp1PDFs"
echo Converting "%~n1"...

powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
  "$pp = New-Object -ComObject PowerPoint.Application;" ^
  "$pres = $pp.Presentations.Open('%~f1', 0, 0, 0);" ^
  "$pres.SaveAs('%~dp1PDFs\%~n1.pdf', 32);" ^
  "$pres.Close();" ^
  "$pp.Quit();"
goto :eof