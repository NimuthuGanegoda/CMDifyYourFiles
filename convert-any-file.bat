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

:: === Conversion logic ===

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

:: No conversion found
echo No conversion logic implemented for %EXT% to %OUTEXT%
echo Please add conversion command for this file type.
goto :end

:ppt_to_pdf
echo Converting PowerPoint to PDF...
powershell -ExecutionPolicy Bypass -Command "$ppt = New-Object -ComObject PowerPoint.Application; $pres = $ppt.Presentations.Open('%INFILE%', $true, $true, $false); $pres.SaveAs('%OUTFILE%', 32); $pres.Close(); $ppt.Quit(); [System.Runtime.Interopservices.Marshal]::ReleaseComObject($ppt) | Out-Null"
if !ERRORLEVEL! equ 0 (
    echo Conversion successful: %OUTFILE%
) else (
    echo Conversion failed. Make sure PowerPoint is installed.
)
goto :end

:word_to_pdf
echo Converting Word document to PDF...
powershell -ExecutionPolicy Bypass -Command "$word = New-Object -ComObject Word.Application; $word.Visible = $false; $doc = $word.Documents.Open('%INFILE%'); $doc.SaveAs('%OUTFILE%', 17); $doc.Close(); $word.Quit(); [System.Runtime.Interopservices.Marshal]::ReleaseComObject($word) | Out-Null"
if !ERRORLEVEL! equ 0 (
    echo Conversion successful: %OUTFILE%
) else (
    echo Conversion failed. Make sure Word is installed.
)
goto :end

:image_convert
echo Converting image format...
powershell -ExecutionPolicy Bypass -Command "Add-Type -AssemblyName System.Drawing; $img = [System.Drawing.Image]::FromFile('%INFILE%'); $img.Save('%OUTFILE%'); $img.Dispose()"
if !ERRORLEVEL! equ 0 (
    echo Conversion successful: %OUTFILE%
) else (
    echo Conversion failed. Image format may not be supported.
)
goto :end

:end

pause
exit /b

