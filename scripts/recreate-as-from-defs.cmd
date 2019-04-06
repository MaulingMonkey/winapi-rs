@setlocal
:: dlltool creates a lot of temporary files in the CWD which clutters up vscode views etc.
@pushd "%TEMP%"

:: Configuration
@set ROOT=%~dp0..
@if not defined DLLTOOL (where dlltool >NUL 2>NUL) && set DLLTOOL=dlltool
@if not defined DLLTOOL if exist "C:\msys64\mingw64\bin\dlltool.exe" set DLLTOOL=C:\msys64\mingw64\bin\dlltool.exe
@if not defined DLLTOOL if exist "C:\msys32\mingw32\bin\dlltool.exe" set DLLTOOL=C:\msys32\mingw32\bin\dlltool.exe
@if not defined DLLTOOL echo Cannot find dlltool.exe&& exit /b 1

:: Initiaize
@set ERRORS=0
rmdir /s "%ROOT%\i686\lib"
rmdir /s "%ROOT%\x86_64\lib"

:: Do stuff
@call :export-defs-to-libs "%ROOT%\i686"   "--as-flags=--32 --machine i386:x86"
@call :export-defs-to-libs "%ROOT%\x86_64" "--as-flags=--64 --machine i386:x86-64"

:: Cleanup, report, exit
@if "%ERRORS%" == "0" popd && endlocal && exit /b 0
@echo.
@echo %ERRORS% Error(s)
@echo.
@popd
@endlocal
@exit /b 1



:export-defs-to-libs
@set ARCH_DIR=%~1
@set EXTRA_FLAGS=%~2
mkdir "%ARCH_DIR%\lib"
@"%DLLTOOL%" --version > "%ARCH_DIR%\lib\_version.txt"
@for /f "" %%d in ('dir /B "%ARCH_DIR%\def\*.def"') do @call :export-def-to-lib "%ARCH_DIR%" "%EXTRA_FLAGS%" "%%d"
@exit /b 0

:export-def-to-lib
@set ARCH_DIR=%~1
@set EXTRA_FLAGS=%~2
@set DEF_NAME=%~3
@set LIB_NAME=libwinapi_%DEF_NAME:~0,-4%.a
"%DLLTOOL%" %EXTRA_FLAGS% --input-def "%ARCH_DIR%\def\%DEF_NAME%" --output-lib "%ARCH_DIR%\lib\%LIB_NAME%"
@if ERRORLEVEL 1 set /A ERRORS=ERRORS+1
@exit /b %ERRORLEVEL%
