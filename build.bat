@echo off
rem Build savestate.dll and GTASA-Savestates.exe (x86) with MSVC.
rem Finds Visual Studio or the Build Tools (any version with the C++ tools) using vswhere.
rem Run from an x86 Developer Command Prompt to use that environment instead.
setlocal
cd /d "%~dp0"

if /i "%VSCMD_ARG_TGT_ARCH%"=="x86" goto build

set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist "%VSWHERE%" goto novs
set "VSDIR="
for /f "usebackq delims=" %%i in (`"%VSWHERE%" -latest -prerelease -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do set "VSDIR=%%i"
if not defined VSDIR goto novs
if not exist "%VSDIR%\VC\Auxiliary\Build\vcvars32.bat" goto novs
echo using %VSDIR%
call "%VSDIR%\VC\Auxiliary\Build\vcvars32.bat" >nul || exit /b 1

:build
if not exist build mkdir build
cl /nologo /O2 /MT /LD /EHsc /std:c++17 /W3 /DNDEBUG /Zi src\main.cpp src\arena.cpp src\hooks.cpp src\d3d.cpp src\state.cpp src\game.cpp src\lab.cpp src\census.cpp /Fobuild\ /Fdbuild\ /Fe:build\savestate.dll /link /DEBUG /MAP:build\savestate.map /OPT:REF /OPT:ICF user32.lib kernel32.lib gdi32.lib || exit /b 1
cl /nologo /O2 /MT /EHsc /std:c++17 /W3 /DNDEBUG /DUNICODE /D_UNICODE src\launcher.cpp /Fobuild\ /Fe:build\GTASA-Savestates.exe /link /SUBSYSTEM:WINDOWS user32.lib kernel32.lib comdlg32.lib shell32.lib || exit /b 1
echo built build\savestate.dll and build\GTASA-Savestates.exe
exit /b 0

:novs
echo error: no Visual Studio or Build Tools installation with the C++ x86 tools was found. 1>&2
echo Install the "Desktop development with C++" workload, or run this from an x86 Developer Command Prompt. 1>&2
exit /b 1
