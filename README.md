# homebrew-emuriad

Homebrew tap for [emuriad](https://github.com/BoukhariAyoub/emuriad) — enforced
Android emulator reservations for parallel AI coding agents.

```bash
brew install boukhariayoub/emuriad/emuriad
emuriad init
emuriad doctor
```

`brew install` gives you `emuriad` and `emuriad-lab`, plus the guard hook and the
agent skill under `$(brew --prefix)/share/emuriad`. Wiring the hook into your
agent's settings stays a manual step — see the caveats printed after install, or
the [main README](https://github.com/BoukhariAyoub/emuriad#install).

## Renamed from emulock

This tap was `boukhariayoub/emulock` and the formula was `emulock` until 0.3.
`formula_renames.json` maps `emulock` to `emuriad`, so `brew upgrade` on an old
install moves it over. The `emulock` command is still installed, as a shim that
runs `emuriad`. For a clean switch to the new tap name:

```bash
brew uninstall emulock && brew untap boukhariayoub/emulock
brew install boukhariayoub/emuriad/emuriad
emuriad init    # moves an old emulock hook and skill over, after asking
```
