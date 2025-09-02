@echo off
setlocal enabledelayedexpansion

:: === CONFIG ===================================================
set "FFMPEG=C:\Tools\ffmpeg-7.1.1-full_build\bin\ffmpeg.exe"
set "AUDIO_EXT=ogg"        & rem "ogg" (Opus) or "m4a" (AAC)
:: ==============================================================

:: === PROMPT USER FOR SIZE REDUCTION ===
set /p REDUCE_MB="Enter the amount (in MB) to reduce each file by: "
if "%REDUCE_MB%"=="" (
    echo No reduction amount entered. Exiting.
    exit /b 1
)

if not exist "%FFMPEG%" (
    echo ffmpeg.exe not found at:
    echo %FFMPEG%
    echo.
    echo Please correct the path above inside this batch file.
    pause & exit /b 1
)

:: === PROCESS ALL AUDIO IN ONE GO ==============================
if "%~1"=="" (
    set "SOURCE=%~dp0"
) else (
    set "SOURCE=%~1"
)

if exist "%SOURCE%\" (
    for %%F in ("%SOURCE%"\*.mp3 "%SOURCE%"\*.flac "%SOURCE%"\*.wav "%SOURCE%"\*.m4a "%SOURCE%"\*.aac "%SOURCE%"\*.ogg "%SOURCE%"\*.opus "%SOURCE%"\*.wma) do (
        if exist "%%F" call :process "%%F"
    )
) else (
    call :process "%SOURCE%"
)
goto :eof
:: ==============================================================

:: === PER-FILE PROCESSING ======================================
:process
set "IN=%~1"
set "OUT=%~dp1DiscordReady\%~n1_discord.%AUDIO_EXT%"
if not exist "%~dp1DiscordReady" mkdir "%~dp1DiscordReady"

:: Get original file size in MB
for %%S in ("%IN%") do set /a "ORIG_MB=%%~zS/1048576"
set /a "MAX_MB=ORIG_MB-REDUCE_MB"
if %MAX_MB% lss 1 set "MAX_MB=1"

:: Get duration in seconds
for /f "tokens=*" %%D in ('"%FFMPEG%" -i "%IN%" 2^>^&1 ^| findstr /i "Duration"') do (
    set "DUR_LINE=%%D"
)
set "DUR_LINE=%DUR_LINE:~12,11%"
for /f "tokens=1,2,3 delims=:." %%H in ("%DUR_LINE%") do (
    set /a "SECS=%%H*3600+%%I*60+%%J"
)

:: Calculate target bitrate (kbit/s) for MAX_MB
set /a "MAX_KBITS=(%MAX_MB% * 8192) / %SECS%"
if %MAX_KBITS% lss 48 set "MAX_KBITS=48"

echo:
echo Processing "%~n1"  (%SECS%s  -^>  %MAX_MB% MB @ %MAX_KBITS% kbit/s)

if /i "%AUDIO_EXT%"=="m4a" (
    "%FFMPEG%" -hide_banner -loglevel error -stats ^
      -i "%IN%" -c:a aac -b:a %MAX_KBITS%k -movflags +faststart "%OUT%" -y
) else (
    "%FFMPEG%" -hide_banner -loglevel error -stats ^
      -i "%IN%" -c:a libopus -b:a %MAX_KBITS%k "%OUT%" -y
)
goto :eof