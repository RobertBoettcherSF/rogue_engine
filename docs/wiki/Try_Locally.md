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

There is no `demo` command. Do **not** use an old `rogue_engine-main` zip — clone current main. Inventory: [Packages.md](Packages.md).
