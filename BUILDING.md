# Building GTA SA savestates

The source code of the released `savestate.dll` and `GTASA-Savestates.exe` (GTA San Andreas 1.0 US / 1.01 EU).
`README.md` and `savestate.ini` are the ones shipped with that release.

## Requirements
- Windows with the Microsoft C++ Build Tools (MSVC, x86 toolset, C++17).
- No other libraries: only the Windows SDK (user32, kernel32, gdi32, comdlg32, shell32).

## Build
Run `build.bat`. It produces 32-bit `build\savestate.dll` and `build\GTASA-Savestates.exe` (plus `.pdb` / `.map`).
To use them, put both next to `savestate.ini`.

`build.bat` uses `vswhere.exe` (installed with every Visual Studio and Build Tools) to find the newest installation
that has the C++ x86 tools, and calls its `vcvars32.bat`. Any version and install folder works. If it is run from
an x86 Developer Command Prompt, it uses that environment as is. If no installation is found, it stops with an
error that says so.

## Files
| File | What it does |
|---|---|
| `src/launcher.cpp` | `GTASA-Savestates.exe`: starts `gta_sa.exe` suspended and loads `savestate.dll` before the game's code runs |
| `src/main.cpp` | DLL entry, `savestate.ini`, keys, on-screen messages |
| `src/arena.*` | the game heap replacement: a TLSF allocator in one region at a fixed address |
| `src/hooks.*` | import-table hooks: heap into the arena, main-loop safe point, audio thread parking |
| `src/state.*` | savestate files: saving and loading the game memory |
| `src/d3d.*` | Direct3D 9 objects: tracking, contents and device state for savestates |
| `src/game.*` | game addresses for 1.0 US and 1.01 EU |
| `src/common.h` | shared helpers |
| `src/lab.*`, `src/census.*` | automated test harness and diagnostics, off unless `[Lab]` keys are set in the ini |
