@echo off
setlocal enabledelayedexpansion

:: === CONFIG ===================================================
set "FFMPEG=C:\Tools\ffmpeg-7.1.1-full_build\bin\ffmpeg.exe"
set "MAX_MB=10"               & rem Discord free limit
:: ==============================================================

if not exist "%FFMPEG%" (
    echo ffmpeg.exe not found at:
    echo %FFMPEG%
    echo.
    echo Please correct the path above inside this batch file.
    pause & exit /b 1
)

:: === PROCESS ALL VIDEOS IN ONE GO =============================
:: If nothing is dragged onto the script, default to its own folder
if "%~1"=="" (
    set "SOURCE=%~dp0"
) else (
    set "SOURCE=%~1"
)

if exist "%SOURCE%\" (
    for /r "%SOURCE%" %%F in (*.mp4 *.mov *.mkv *.avi *.flv *.wmv *.webm) do (
        call :process "%%~fF"
    )
) else (
    call :process "%SOURCE%"
)
goto :eof
:: ==============================================================

:: === PER-FILE PROCESSING ======================================
:process
set "IN=%~1"
set "OUT=%~dp1DiscordReady\%~n1_discord.mp4"
if not exist "%~dp1DiscordReady" mkdir "%~dp1DiscordReady"

:: Get duration in seconds
for /f "tokens=*" %%D in ('"%FFMPEG%" -i "%IN%" 2^>^&1 ^| findstr /i "Duration"') do (
    set "DUR_LINE=%%D"
)
set "DUR_LINE=%DUR_LINE:~12,11%"
for /f "tokens=1,2,3 delims=:." %%H in ("%DUR_LINE%") do (
    set /a "SECS=%%H*3600+%%I*60+%%J"
)

:: Calculate target bitrate (kbit/s) for MAX_MB
set /a "MAX_KBITS=(%MAX_MB% * 8192) / %SECS% - 128"
if %MAX_KBITS% lss 200 set "MAX_KBITS=200"

echo:
echo Processing "%~n1"  (%SECS%s  -^>  %MAX_MB% MB)
"%FFMPEG%" -hide_banner -loglevel error -stats ^
  -i "%IN%" ^
  -c:v libx264 -b:v %MAX_KBITS%k -pass 1 -an -f mp4 -y NUL
"%FFMPEG%" -hide_banner -loglevel error -stats ^
  -i "%IN%" ^
  -c:v libx264 -b:v %MAX_KBITS%k -pass 2 ^
  -c:a aac -b:a 96k -movflags +faststart ^
  "%OUT%" -y
goto :eof