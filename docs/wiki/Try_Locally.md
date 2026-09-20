# Try locally (copy-paste)

Need **GNAT + gprbuild** (Ada 2022). Ubuntu/Debian: `sudo apt install gnat gprbuild`.

```bash
cd ~/Downloads
rm -rf rogue_engine rogue_engine-main
git clone https://github.com/RobertBoettcherSF/rogue_engine.git
cd rogue_engine
make test
make play
```

There is no `demo` command. Do **not** use an old `rogue_engine-main` zip — clone current main. Inventory: [Packages.md](Packages.md). Spec: [Wrist_Map.md](Wrist_Map.md).

## `make play` — Wrist_Map v0

Plain Ada `Text_IO` — **no** GUI, **no** ANSI/ncurses.

| Key | Action |
|-----|--------|
| `wasd` / `hjkl` | Pan cursor |
| `W` | Chart course preview → confirm |
| `.` / Enter | Step `@` along course (m) |
| `1`–`4` | Profile: Earth / Mars-thin / Mars / Titan |
| `m` | Toggle local ops-room |
| `x` | Clear course |
| `q` | Quit |

Cuff shows `LEVEL/X/Y`, cabin NOMINAL + P/O2, and profile `P / O2% / g0 / outdoor=…`. Course length is metres (1 tile = 1 m).
