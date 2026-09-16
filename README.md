# homebrew-emulock

Homebrew tap for [emulock](https://github.com/BoukhariAyoub/emulock) — enforced
Android emulator reservations for parallel AI coding agents.

```bash
brew tap BoukhariAyoub/emulock
brew install emulock
emulock doctor
```

`brew install` gives you `emulock` and `emulock-lab`, plus the guard hook and the
agent skill under `$(brew --prefix)/share/emulock`. Wiring the hook into your
agent's settings stays a manual step — see the caveats printed after install, or
the [main README](https://github.com/BoukhariAyoub/emulock#install).
