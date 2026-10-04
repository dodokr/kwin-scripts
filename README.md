# kwin-scripts
Kwin-scripts for KDE Plasma 6 made by dodokr.

## Scripts

- `move-windows-to-desktops`: moves the active window to the previous/next virtual desktop, wrapping around at the edges, and follows it there.
- `screenfocusosd`: shows a short pop/squish card with the screen number on the screen that just got focus.

## Installation

From the root of this repo:

```sh
kpackagetool6 --type KWin/Script -i <dir-name>
```
e.g.:
```sh
kpackagetool6 --type KWin/Script -i screenfocusosd
```

Then enable the script in System Settings → Window Management → KWin Scripts.

To update an installed script after changing it, use `-u` instead of `-i`. To remove one, use `-r <id>`.

## `reload.sh` (for tweaking/testing only)

```sh
./reload.sh screenfocusosd
```

Installs the given script from this repo into `~/.local/share/kwin/scripts/` under a fresh ID (`<name>-<timestamp>`), removes the copy it installed last time, enables it and reconfigures KWin.

This is only a development helper. KWin appears to keep a stale copy of a script's QML for as long as the same ID stays in use, so edits don't show up after a plain unload/reload. A new ID each time avoids that without restarting KWin.

Notes:

- Edit the files in this repo, not the installed copy. The installed copy is deleted on every run.
- Don't tick the script in System Settings → KWin Scripts while testing, and don't keep a regular install of the same script enabled alongside it. Both would be loaded and you get duplicates (e.g. two popups).
- Needs `qdbus6` and `kwriteconfig6` (Plasma 6).
