@echo off
setlocal enabledelayedexpansion
title File Converter

echo.
echo ==========================================
echo       FILE CONVERTER - DRAG & DROP
echo ==========================================
echo.

:: Require at least one file
if "%~1"=="" (
    echo ERROR: No files detected!
    echo.
    echo How to use:
    echo 1. Drag and drop one or MORE files onto this script
    echo 2. Enter the desired output format
    echo 3. Files will be converted in the same folder
    echo.
    echo Supported: ppt/pptx/doc/docx to PDF, images to other formats
    echo.
    pause
    exit /b 1
)

echo Detected %* files ready to convert
echo.


:: Prompt for output extension
:prompt_extension
set "OUTEXT="
set /p OUTEXT=Enter output format (pdf, jpg, png, etc.):
if "!OUTEXT!"=="" (
    echo ERROR: Cannot be empty. Try again.
    echo.
    goto :prompt_extension
)

:: Remove leading dot
set "OUTEXT=!OUTEXT:.=!"

echo.
echo Converting to .!OUTEXT! format...
echo.

set "TOTAL=0"
set "SUCCESS=0"
set "FAILED=0"

:: Process each file
:next_file
if "%~1"=="" goto :done

set "FILE=%~1"
set "EXT=%~x1"
set "EXT=!EXT:~1!"
set "OUTFILE=%~dpn1.!OUTEXT!"

set /a TOTAL+=1
echo [!TOTAL!] %~nx1

:: Check file exists
if not exist "!FILE!" (
    echo     ERROR - File not found
    set /a FAILED+=1
    shift
    goto :next_file
)

:: PowerPoint to PDF
if /i "!OUTEXT!"=="pdf" (
    if /i "!EXT!"=="pptx" goto :do_ppt
    if /i "!EXT!"=="ppt" goto :do_ppt
    if /i "!EXT!"=="docx" goto :do_word
    if /i "!EXT!"=="doc" goto :do_word
)

:: Images
if /i "!EXT!"=="jpg" goto :do_image
if /i "!EXT!"=="jpeg" goto :do_image
if /i "!EXT!"=="png" goto :do_image
if /i "!EXT!"=="bmp" goto :do_image
if /i "!EXT!"=="gif" goto :do_image
if /i "!EXT!"=="tiff" goto :do_image
if /i "!EXT!"=="tif" goto :do_image
if /i "!EXT!"=="webp" goto :do_image
if /i "!EXT!"=="pdf" goto :do_pdf_image

echo     SKIP - .!EXT! to .!OUTEXT! not supported
set /a FAILED+=1
shift
goto :next_file

:do_ppt
powershell -NoProfile -Command "$ppt = New-Object -ComObject PowerPoint.Application; $pres = $ppt.Presentations.Open('!FILE!', $true, $true, $false); $pres.SaveAs('!OUTFILE!', 32); $pres.Close(); $ppt.Quit()" >nul 2>&1
if !ERRORLEVEL! equ 0 (
    echo     OK - Saved as %~n1.!OUTEXT!
    set /a SUCCESS+=1
) else (
    echo     ERROR - Conversion failed
    set /a FAILED+=1
)
shift
goto :next_file

:do_word
powershell -NoProfile -Command "$word = New-Object -ComObject Word.Application; $word.Visible = $false; $doc = $word.Documents.Open('!FILE!'); $doc.SaveAs('!OUTFILE!', 17); $doc.Close(); $word.Quit()" >nul 2>&1
if !ERRORLEVEL! equ 0 (
    echo     OK - Saved as %~n1.!OUTEXT!
    set /a SUCCESS+=1
) else (
    echo     ERROR - Conversion failed
    set /a FAILED+=1
)
shift
goto :next_file

:do_image
powershell -NoProfile -Command "Add-Type -AssemblyName System.Drawing; $img = [System.Drawing.Image]::FromFile('!FILE!'); $img.Save('!OUTFILE!'); $img.Dispose()" >nul 2>&1
if !ERRORLEVEL! equ 0 (
    echo     OK - Saved as %~n1.!OUTEXT!
    set /a SUCCESS+=1
) else (
    echo     ERROR - Conversion failed
    set /a FAILED+=1
)
shift
goto :next_file

:do_pdf_image
magick "!FILE!" "!OUTFILE!" >nul 2>&1
if !ERRORLEVEL! neq 0 (
    convert "!FILE!" "!OUTFILE!" >nul 2>&1
)
if !ERRORLEVEL! equ 0 (
    echo     OK - Saved as %~n1.!OUTEXT!
    set /a SUCCESS+=1
) else (
    echo     ERROR - PDF conversion requires ImageMagick installed
    set /a FAILED+=1
)
shift
goto :next_file

:done
echo.
echo ==========================================
echo Processed: !TOTAL! files
echo Success:   !SUCCESS!
echo Failed:    !FAILED!
echo ==========================================
echo.
pause
exit /b
