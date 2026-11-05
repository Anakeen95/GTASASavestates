# GTA San Andreas Savestates

Original author: **crabik**

Savestates for GTA San Andreas (PC) that work like virtual machine snapshots. You can save anywhere, including
in the middle of a mission or a cutscene, and jump back to that exact moment later. That can be in the same
session or after restarting the game or the PC.

A load restores everything: the mission script and its timers, every ped and car with its AI, physics, traffic,
wanted level, weather, the camera, and the radio track and its position. The game's own save files only keep a
summary of your progress and can't be used during missions. Savestates can.

The mod doesn't change or add any file in the game folder. Start the game with `GTASA-Savestates.exe` to get
savestates, or run `gta_sa.exe` directly to play the unmodified game.

## Controls

| Key | Action |
|---|---|
| **F5** | Save to the current slot |
| **F9** | Load the current slot |
| **F6 / F7** | Previous / next slot (10 slots) |

A short message in the top-left corner confirms each action, for example `Savestate 1 saved (55 MB, 35 ms)`.

| Operation | Typical time |
|---|---|
| Save | ~35 ms |
| Load (savestate from the current session) | ~10 ms |
| Load (savestate from an earlier session) | ~40 ms |

You can change the keys in `savestate.ini`.

## Requirements

- `gta_sa.exe` **1.0 US** (HOODLUM or Compact) or **1.01 EU**. The mod detects other versions (1.01 US, Steam,
  Definitive Edition), leaves them alone and writes a note in the log.
- Windows 10 or 11.

## Installation and use

1. Put `GTASA-Savestates.exe`, `savestate.dll` and `savestate.ini` in a folder you can write to, for example
   `D:\GTA SA Savestates`. Avoid `Program Files`. The folder doesn't need to be inside the game folder.
2. Run `GTASA-Savestates.exe`. The first time, it asks where `gta_sa.exe` is and saves the path in
   `savestate.ini` (`[Launcher] Game=`). You can also pass the path on the command line:
   ```
   GTASA-Savestates.exe "D:\Games\GTA San Andreas\gta_sa.exe"
   ```
   Any other arguments are passed on to the game.
3. Play. `savestate.log`, next to the launcher, lists every save and load.

Your own `d3d9.dll`, `DINPUT8.dll` and other files in the game folder keep working. The launcher starts the game
suspended, loads `savestate.dll` into its memory before any game code runs, and then resumes it. Some antivirus
programs flag programs that start other programs this way. If yours does, add an exception for the launcher's
folder.

### As an ASI mod

`savestate.dll` also works as a classic ASI mod. Rename it to `savestate.asi` and put it in the `scripts` folder
of an ASI loader. In that case its ini, log and savestates live in `scripts`.

## Configuration

All settings are in `savestate.ini`.

| Section | Key | Default | Meaning |
|---|---|---|---|
| `[Savestate]` | `SaveKey`, `LoadKey`, `PrevSlotKey`, `NextSlotKey` | `116`, `120`, `117`, `118` | Windows virtual-key codes (F5, F9, F6, F7) |
| | `ShowMessages` | `1` | Show save/load messages in the top-left corner |
| | `RestartStreamedAudio` | `1` | After a load, resume the radio, cutscene soundtrack and ambience at their saved position |
| | `Folder` | empty | Where savestate files go. Empty means a `savestates` folder next to the launcher |
| | `ArenaMB` | `384` | Address space reserved for the game's heap. The stock game uses 30-60 MB. Raise it only if the log says `arena full` |
| | `ArenaBase` | `0x10100000` | Address of that heap. Savestates only load at the address they were made at, so don't change it |
| `[Launcher]` | `Game` | empty | Path to `gta_sa.exe`. Empty means the launcher asks on first run |

## Things to know

- **Savestates are files.** They are stored as `slot01.sast` to `slot10.sast` (about 55 MB each) and stay after
  the game is closed, so you can load them in a later session or after a reboot. Delete a file to empty its slot.
- A savestate only loads with the same `gta_sa.exe` and at the same screen resolution it was made with. The
  on-screen message tells you if they don't match.
- Loading a normal save from the menu doesn't delete savestates. You can load a savestate made in a different
  save file or mission.
- Saving and loading are disabled while the pause menu is open.
- Sound effects that were playing at the moment of the save restart from the beginning. Looping sounds (engines,
  ambience) come back on their own, and the radio or cutscene soundtrack resumes at the saved position.
- Each savestate made in the current session keeps the textures and models that were loaded at that moment. Many
  savestates in different parts of the map use more memory.
- The game must be started by the launcher. Savestates can't be added to a game that is already running.
- State kept by other mods (CLEO scripts, trainers) is not rolled back by a load.

## How it works

GTA SA keeps its state in two places: global variables inside `gta_sa.exe` and memory it allocates at runtime.
The DLL replaces the game's `HeapAlloc` family in the import table (in memory only) with its own allocator, so
every allocation lands in one region at a fixed address. A savestate is a copy of the game's global data plus the
used pages of that region, taken between two frames while the streaming and audio threads are paused. It also
includes the game's graphics objects: texture and buffer contents, shaders and device state. Loading writes all of
this back.

Objects that live outside the game's memory are handled separately:

- **Direct3D 9.** Every texture, buffer and shader the game creates is tracked. Within a session, they are kept
  alive while a savestate needs them, and a load restores reference counts and device state. A savestate from an
  earlier session re-creates them from the file and rewrites every pointer to them in the restored memory,
  including textures the game keeps locked, like the number-plate font. RenderWare's shared vertex buffers and
  SA's texture recycling are turned off so a kept object never changes its contents.
- **DirectSound.** Sound channels release their buffers before a load and start fresh after it. The streamed
  track (radio or cutscene) is re-opened at its saved position.
- **Windows and DirectInput** state, file and thread handles, the C runtime's per-thread and per-process data,
  and the timer's link to the system clock are left as they are. The savestate's references to the old ones are
  rewired to the current ones.

## Building from source

Requirements:

- Windows with the Microsoft C++ Build Tools (MSVC, x86 toolset, C++17).
- No third-party libraries. Only the Windows SDK (`user32`, `kernel32`, `gdi32`, `comdlg32`, `shell32`).

Run `build.bat`. It produces 32-bit `build\savestate.dll` and `build\GTASA-Savestates.exe`, plus `.pdb` and
`.map` files. To use them, put both next to `savestate.ini`.

`build.bat` finds the newest Visual Studio or Build Tools installation with the C++ x86 tools using `vswhere`, so
any version and install folder works. If you run it from an x86 Developer Command Prompt, it uses that
environment instead. See [BUILDING.md](BUILDING.md) for more details.

## Project layout

| File | Purpose |
|---|---|
| `src/launcher.cpp` | `GTASA-Savestates.exe`: starts `gta_sa.exe` suspended and loads `savestate.dll` before the game's code runs |
| `src/main.cpp` | DLL entry point, `savestate.ini`, key handling, on-screen messages |
| `src/arena.*` | Game heap replacement: a TLSF allocator in one region at a fixed address |
| `src/hooks.*` | Import-table hooks: heap redirection, main-loop safe point, audio thread parking |
| `src/state.*` | Savestate files: saving and loading game memory |
| `src/d3d.*` | Direct3D 9 objects: tracking, contents and device state |
| `src/game.*` | Game addresses for 1.0 US and 1.01 EU |
| `src/common.h` | Shared helpers |
| `src/lab.*`, `src/census.*` | Automated test harness and diagnostics, disabled unless `[Lab]` keys are set in the ini |
| `savestate.ini` | Default configuration |
| `build.bat` | Build script |

## Credits

- **crabik**, original author of the project.
- [gta-reversed](https://github.com/gta-reversed/gta-reversed) and
  [plugin-sdk](https://github.com/DK22Pac/plugin-sdk) from the GTA modding community, used as references for
  addresses and structures.
- Built with Claude Code (Anthropic) and Kiro IDE using Claude Opus 5.5 (Amazon Web Services) as an AI-assisted modding project.
