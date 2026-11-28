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


## Audit verification — 2026-11-13

At HEAD `42471e4c`, rendered isolated settings fixture passes 53/53; separate-process
restart passes 2/2. Source/default InputMap and all five autoloads were copied from the
current project; no production settings/save was accessed. See
[full environment, commands, logs and limitations](project-audit-validation.md).
Native feel, audible mixer behavior and reviewer acceptance remain NOT RUN. Duplicate
Player/Stage HUD (BUG-008) remains open despite bounded menu tests passing. This is an
audit status update, not new implementation or sign-off.


## N40 update — 2026-11-28
The in-game pause action is now **Về menu chính**, with the existing styled confirmation and checkpoint reminder. Confirming keeps the save file intact and returns to the actual title; only the title's desktop Thoát action still closes the application. Continue explicitly restores saved stage and checkpoint on every activation, including repeated returns in one process.
GameManager owns a persistent loading cover for New Game, Continue, doors, respawn and returning to title. It reuses the title/inventory stone skin, gold/violet palette and animated Foxy art. The opaque cover renders before threaded resource loading, shows destination/progress, survives the scene-ready frame and fades before releasing gameplay. It closes existing persistent menus, blocks overlapping/F9 requests, and exposes a keyboard-accessible Back action on load failure. No additional checkpoint/save policy.
Rendered focused44/44 and actual door regression73/73 PASS, both exit0; details, screenshots and known diagnostics/limits in [validation evidence](validation/menu-scene-loading-2026-11-28/results.json). No independent teammate acceptance or full export/campaign verification.


## N41/N42 update — 2026-11-28
Loading now waits for a normal game-processing callback before changing pause or swapping scenes, so editor suspension is respected. Its pause ownership begins before persistent menus close; their asynchronous resume requests cannot briefly release gameplay beneath the cover. Error Back safely restores the prior underlying pause after the editor resumes.
In the opening possession timeline, Không now ends the dialogue and returns through the shared loading screen to main menu without recording acceptance. Có retains the user's revised narration and normal story save. Native suspension17/17, opening19/19, menu/loading44/44 and actual doors73/73 PASS; [evidence and limits](validation/suspension-opening-return-2026-11-28/results.json).
