@echo off
setlocal enabledelayedexpansion

:: === Detect input (file or folder) ===
if "%~1"=="" (
    echo Please drag and drop a file or folder onto this script.
    pause
    exit /b
)
set "INPUT=%~1"

:: === If folder: bulk convert recursively ===
if exist "%INPUT%\" (
    set /p OUTEXT=Enter desired output extension for all files (e.g. pdf, jpg): 
    if "%OUTEXT%"=="" (
        echo No output extension provided.
        goto :end
    )
    for /r "%INPUT%" %%F in (*.*) do (
        call :convert_one "%%~fF" "%%~xF" "%OUTEXT%"
    )
    goto :end
)

:: === Single file path ===
set "INFILE=%INPUT%"
set "EXT=%~x1"
echo Detected file type: %EXT%
set /p OUTEXT=Enter desired output extension (e.g. pdf, docx, jpg): 
if "%OUTEXT%"=="" (
    echo No output extension provided.
    goto :end
)
call :convert_one "%INFILE%" "%EXT%" "%OUTEXT%"
goto :end

:: === Per-file conversion ===
:convert_one
set "INFILE=%~1"
set "EXT=%~2"
set "OUTEXT=%~3"
set "OUTFILE=%~dp1%~n1.%OUTEXT%"
echo Input file: %INFILE%
echo Output file: %OUTFILE%

:: PowerPoint to PDF (PPTX/PPT)
if /i "%OUTEXT%"=="pdf" (
    if /i "%EXT%"==".pptx" goto :ppt_to_pdf
    if /i "%EXT%"==".ppt" goto :ppt_to_pdf
)

:: Word to PDF (DOCX/DOC)
if /i "%OUTEXT%"=="pdf" (
    if /i "%EXT%"==".docx" goto :word_to_pdf
    if /i "%EXT%"==".doc" goto :word_to_pdf
)

:: Image conversions (JPG, PNG, BMP, GIF, TIFF, WEBP)
if /i "%EXT%"==".jpg" goto :image_convert
if /i "%EXT%"==".jpeg" goto :image_convert
if /i "%EXT%"==".png" goto :image_convert
if /i "%EXT%"==".bmp" goto :image_convert
if /i "%EXT%"==".gif" goto :image_convert
if /i "%EXT%"==".tiff" goto :image_convert
if /i "%EXT%"==".tif" goto :image_convert
if /i "%EXT%"==".webp" goto :image_convert

echo No conversion logic implemented for %EXT% to %OUTEXT%
goto :return

:ppt_to_pdf
echo Converting PowerPoint to PDF...
powershell -ExecutionPolicy Bypass -Command "$ppt = New-Object -ComObject PowerPoint.Application; $pres = $ppt.Presentations.Open('%INFILE%', $true, $true, $false); $pres.SaveAs('%OUTFILE%', 32); $pres.Close(); $ppt.Quit(); [System.Runtime.Interopservices.Marshal]::ReleaseComObject($ppt) | Out-Null"
if !ERRORLEVEL! equ 0 (
    echo Conversion successful: %OUTFILE%
) else (
    echo Conversion failed. Make sure PowerPoint is installed.
)
goto :return

:word_to_pdf
echo Converting Word document to PDF...
powershell -ExecutionPolicy Bypass -Command "$word = New-Object -ComObject Word.Application; $word.Visible = $false; $doc = $word.Documents.Open('%INFILE%'); $doc.SaveAs('%OUTFILE%', 17); $doc.Close(); $word.Quit(); [System.Runtime.Interopservices.Marshal]::ReleaseComObject($word) | Out-Null"
if !ERRORLEVEL! equ 0 (
    echo Conversion successful: %OUTFILE%
) else (
    echo Conversion failed. Make sure Word is installed.
)
goto :return

:image_convert
echo Converting image format...
powershell -ExecutionPolicy Bypass -Command "Add-Type -AssemblyName System.Drawing; $img = [System.Drawing.Image]::FromFile('%INFILE%'); $img.Save('%OUTFILE%'); $img.Dispose()"
if !ERRORLEVEL! equ 0 (
    echo Conversion successful: %OUTFILE%
) else (
    echo Conversion failed. Image format may not be supported.
)
goto :return

:end

pause
exit /b

:return
rem Return to caller when bulk processing
exit /b

