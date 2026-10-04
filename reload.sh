#!/usr/bin/env bash
# Dev helper: (re)install a script from this repo into KWin under a fresh ID.
# Usage: ./reload.sh <script-dir>   e.g. ./reload.sh screenfocusosd
set -euo pipefail

name="${1:?usage: $0 <script-dir>}"
name="${name%/}"
repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
src="$repo/$name"
dest="${XDG_DATA_HOME:-$HOME/.local/share}/kwin/scripts"

[ -f "$src/metadata.json" ] || { echo "$src/metadata.json not found" >&2; exit 1; }

# Remove earlier copies made by this script (<name>-<timestamp>), not a regular install of <name>.
for d in "$dest/$name"-*; do
    [ -d "$d" ] || continue
    id="$(basename "$d")"
    qdbus6 org.kde.KWin /Scripting org.kde.kwin.Scripting.unloadScript "$id" >/dev/null || true
    kwriteconfig6 --file kwinrc --group Plugins --key "${id}Enabled" --delete
    rm -rf "$d"
done

id="$name-$(date +%s)"
mkdir -p "$dest/$id"
cp -r "$src"/. "$dest/$id"/
sed -i "s/\"Id\": \"[^\"]*\"/\"Id\": \"$id\"/" "$dest/$id/metadata.json"

kwriteconfig6 --file kwinrc --group Plugins --key "${id}Enabled" true
qdbus6 org.kde.KWin /KWin reconfigure
echo "loaded $id"
