@echo off
setlocal enabledelayedexpansion

:: === Detect file type ===
if "%~1"=="" (
    echo Please drag and drop a file onto this script.
    pause
    exit /b
)
set "INFILE=%~1"
set "EXT=%~x1"
echo Detected file type: %EXT%

:: === Prompt for output extension ===
set /p OUTEXT=Enter desired output extension (e.g. pdf, docx, jpg): 

:: === Prepare output filename ===
set "OUTFILE=%~dp1%~n1.%OUTEXT%"
echo Input file: %INFILE%
echo Output file: %OUTFILE%

:: === Placeholder for conversion command ===
echo [Conversion command would go here]
:: Example: powershell or other tool to convert "%INFILE%" to "%OUTFILE%"

pause
exit /b

