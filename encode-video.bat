@echo off
setlocal enabledelayedexpansion
title Video Encoder

echo.
echo ==========================================
echo       VIDEO ENCODER - DRAG & DROP
echo ==========================================
echo.

:: Check if files were provided
if "%~1"=="" (
    echo ERROR: No files detected!
    echo.
    echo How to use:
    echo 1. Drag and drop one or MORE video files onto this script
    echo 2. Enter MB to reduce each file by
    echo 3. Compressed videos saved in "Ready" folder
    echo.
    echo Supported: MP4, MKV, AVI, MOV, FLV, WMV, WebM
    echo.
    pause
    exit /b 1
)

:: Check FFmpeg
ffmpeg -version >nul 2>&1
if !ERRORLEVEL! neq 0 (
    echo ERROR: FFmpeg not found!
    echo Install from: https://ffmpeg.org/download.html
    echo.
    pause
    exit /b 1
)

echo Detected files ready to encode
echo.

:: Prompt for reduction amount
:prompt_mb
set "REDUCE_MB="
set /p REDUCE_MB=Enter MB to reduce each file by: 
if "!REDUCE_MB!"=="" (
    echo ERROR: Cannot be empty. Try again.
    echo.
    goto :prompt_mb
)

echo.
echo Encoding to MP4 format...
echo.

set "TOTAL=0"
set "SUCCESS=0"
set "FAILED=0"

:: Process each file
:next_file
if "%~1"=="" goto :done

set "FILE=%~1"
set "OUTDIR=%~dp1Ready"
set "OUTFILE=!OUTDIR!\%~n1_compressed.mp4"

set /a TOTAL+=1
echo [!TOTAL!] %~nx1

:: Check file exists
if not exist "!FILE!" (
    echo     ERROR - File not found
    set /a FAILED+=1
    shift
    goto :next_file
)

:: Create output directory
if not exist "!OUTDIR!" mkdir "!OUTDIR!" 2>nul

:: Get original file size in MB
for %%S in ("!FILE!") do set /a "ORIG_MB=%%~zS/1048576"
set /a "TARGET_MB=ORIG_MB-REDUCE_MB"
if !TARGET_MB! lss 10 set "TARGET_MB=10"

:: Get duration
for /f "tokens=*" %%D in ('ffmpeg -i "!FILE!" 2^>^&1 ^| findstr /i "Duration"') do set "DUR=%%D"
if "!DUR!"=="" (
    echo     ERROR - Cannot read duration
    set /a FAILED+=1
    shift
    goto :next_file
)

set "DUR=!DUR:~12,11!"
for /f "tokens=1,2,3 delims=:." %%H in ("!DUR!") do set /a "SECS=%%H*3600+%%I*60+%%J"
if !SECS! lss 1 set "SECS=1"

:: Calculate bitrate
set /a "KBITS=(TARGET_MB * 8192) / SECS"
if !KBITS! lss 500 set "KBITS=500"

echo     !ORIG_MB!MB -^> !TARGET_MB!MB @ !KBITS!kbit/s

ffmpeg -hide_banner -loglevel error -stats -i "!FILE!" -c:v libx264 -b:v !KBITS!k -c:a aac -b:a 128k "!OUTFILE!" -y >nul 2>&1

if !ERRORLEVEL! equ 0 (
    for %%S in ("!OUTFILE!") do set /a "OUT_MB=%%~zS/1048576"
    echo     OK - !OUT_MB!MB saved
    set /a SUCCESS+=1
) else (
    echo     ERROR - Encoding failed
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
echo Output folder: Ready\
echo.
pause
exit /b
