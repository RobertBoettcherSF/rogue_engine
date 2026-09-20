# Try locally (copy-paste)

Need **GNAT + gprbuild**. Ubuntu/Debian: `sudo apt install gnat gprbuild`.

Prefer a **git clone**, not a zip named `rogue_engine-main`:

```bash
cd ~/Downloads
# if an empty/old clone blocks you:
# rm -rf rogue_engine
git clone https://github.com/RobertBoettcherSF/rogue_engine.git
cd rogue_engine
git pull
make test
make play
```

Already cloned:

```bash
cd ~/Downloads/rogue_engine
git pull
make play
```

## What you should see

| Command | What it is |
|---------|------------|
| `make test` | Lots of `PASS` — physics watchdog |
| `make play` / `./play` | **Now:** short scripted smoke log (walk/eat/strider/sleep). **Next:** interactive `@` + WASD wrist-map |

There is no `demo` command. If `./play` only prints a short “Demo sequence OK”, that’s expected until the interactive map lands — pull again then.
