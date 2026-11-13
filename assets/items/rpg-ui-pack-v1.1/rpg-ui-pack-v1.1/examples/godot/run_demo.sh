#!/bin/sh
# Imports the pack, renders the demo and compares it with the Python reference.
# Godot's --headless mode uses a dummy renderer that cannot read pixels back, so
# the render runs unattended with a real renderer in a window placed off-screen.
set -e
cd "$(dirname "$0")"
GODOT=${GODOT:-/opt/homebrew/bin/godot}
"$GODOT" --headless --path . --import >/dev/null 2>&1 || true
"$GODOT" --path . --position -4000,-4000 --rendering-driver opengl3 2>&1 | grep -v '^$' | tail -3
python3 compare.py
