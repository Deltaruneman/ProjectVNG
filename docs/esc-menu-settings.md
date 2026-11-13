# Esc menu and settings — T085

Date: 2026-11-13. Owner/reviewer: Bao (player UI, input and camera). The user
requests an Esc menu with controls, audio and display settings. This authorizes
the implementation below; it is not teammate review or visual acceptance.

## Scope recorded before implementation

- Add persistent settings and pause-menu autoloads; integrate through existing
  CameraRig properties, InputMap and BattleVFX audio bus. Preserve existing dirty
  camera, player, Skill Tree, input-map and editor work.
- Update Bao-owned HUD shortcut labels/tooltips from InputMap so rebindings remain
  discoverable; keep the existing HUD layout and skill behavior.
- Pause menu: resume, settings, control reference and confirmed exit. Do not add
  new save/checkpoint semantics or destructive new-game actions. Existing game
  progress continues to use its checkpoint autosaves.
- Controls: two keyboard/mouse bindings per gameplay action, conflict rejection,
  reserved Escape/Alt/UI navigation keys, sensitivity and invert Y.
- Audio: master/music/effects/interface buses, master mute and background mute;
  route existing BattleVFX into effects, leave future music on its dedicated bus.
- Display: windowed/borderless/fullscreen, window size, VSync, FPS cap, 3D render
  scale, MSAA and FPS counter. Confirm risky window changes within 15 seconds or
  revert; preserve the game's pixel-art texture filtering and HUD sizing.
- Apply/cancel/defaults with ConfigFile separate from save.json, validation of
  loaded settings and reporting write failure without claiming success.
- Shared boundary: project autoload registration, pause/cursor ownership, input
  routing and audio buses; Bao reviews these interfaces. No map/enemy/AI/save
  implementation changes or generator execution. No other-owner sign-off claimed.

## Acceptance and checks

Esc pauses gameplay, shows a visible pointer, resumes cleanly and leaves Skill
Tree/cinematics' pause ownership intact. Settings persist across restart; cancel
restores live preview; invalid files fall back safely; conflicts cannot silently
disable another action. No input leaks through the menu. Window timeout restores
the previous usable mode. Tabs and scrolling fit 1280x720 and smaller windows,
with keyboard focus and readable Vietnamese text.

Run isolated Godot import and rendered tests for pause/resume, input conflict and
persistence, audio routing, camera settings, display rollback and menu layouts.
Inspect screenshots. Preserve tracked caches and real user saves by testing in a
disposable project copy with isolated user data. Record actual results and limits
in active tasks/validation and the cumulative implementation changelog.
