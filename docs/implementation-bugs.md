# Implementation bugs

## [HIGH] BUG-001 — Existing manager drops unrelated saved payload (fixed in current slice)

- Affected file: `scripts/autoload/game_manager.gd`, former `save_game()`;
  `scripts/autoload/save_system.gd` is unchanged.
- Reproduction: in an isolated project, seed version-1 data with a nested `sentinel`
  or inventory field, load it, then activate a checkpoint/save through GameManager.
- Expected: checkpoint fields update while unrelated top-level/nested data and flags survive.
- Actual before this slice (source-confirmed): `save_game()` constructed only
  stage/checkpoint/flags, discarding other loaded fields. The existing implementation
  was already identified in research R4; no real save was inspected.
- Phase impact: blocked the authorized preservation/legacy acceptance until fixed.
  The current manager retains a deep-copied payload and merges owned fields/flags.
  Synthetic round-trip and exact legacy fixtures now pass. No serializer/version change.

## [HIGH] BUG-002 — Existing manager permits B3 loads (refusal fixed; recovery still blocked)

- Affected file: `scripts/autoload/game_manager.gd`, former `change_stage()` and its
  startup/death callers; separate B3 scene remains unchanged.
- Reproduction: a synthetic B3 path/UID checkpoint passed the old existence-only
  guard and was eligible for deferred loading at startup/death. This is source-confirmed
  baseline evidence; no baseline B3 scene was launched for this phase.
- Expected: zero B3 loads, unchanged progress and no guessed recovery fallback.
- Actual before this slice: no B3 deny boundary. The current path/UID guard refuses
  before dialogue/health/pending/loading mutation; synthetic startup/death/direct
  callers now pass zero-load/preservation checks.
- Phase impact: refusal is fixed within scope. Old-B3 recovery remains BLOCKED on
  an explicit policy; it is not counted as supported recovery or redirected to B1.
  Startup may instantiate the configured main scene, but emits no successful
  continuation registration and does not place/reset/overwrite the unsupported checkpoint.

## [HIGH] BUG-003 — Health bar absent in rendered B2 captures (open, attribution unproven)

- Affected integration: combined `levels/level_1/basement_full.tscn` Hud instance,
  existing `ui/hud.tscn` / `ui/health_bar.gd`, renderer/viewport cause unproven.
  No HUD or renderer fix was made.
- Reproduction: run the isolated `basement_checkpoint_check.gd` with graphics,
  `--lane=interaction --capture`; teleport via the fixture to B2 and activate.
  Also reproduced by `--lane=recovery --capture` at restored B2 before death.
  Captures are retained under the disposable user-data `fixtures` directory.
- Expected: one visible health bar at B2, as in the B1 capture, along with the
  checkpoint marker/feedback. Actual: B2 marker/player/floor render, but the health
  bar is absent from the captured image despite one Hud node and `Hud.visible=true`.
  The B1 capture shows the health bar. This is an assistant-observed image result,
  not a confirmed attribution to the new checkpoint code or a comprehensive manual test.
- Phase impact: blocks claiming complete T025/T026 visual/HUD acceptance. Manager,
  interaction, support and recovery fixture passes remain independent. Needs manual
  reproduction/renderer/HUD-owner review before a fix boundary can be established;
  no speculative shared HUD/player/renderer edits are authorized here.

## [HIGH] BUG-004 — Vertical B1 double jump gets stuck in B2 floor (reproduced, open)

- Affected scene: `levels/level_1/basement_full.tscn`, B2/World floor collision;
  read-only resource `assets/meshes/basement_library.meshlib`; Player Fall/Wall_slide
  controller interaction requires Bao interpretation if a geometry fix is insufficient.
- Reproduction: in verified isolated combined scene, settle at (25,1.2,5); press
  physical Space, press again in eligible Fall state, release; wait 220 frames,
  then hold D for 30 frames. No recovery teleport/FSM reset/death/reload.
- Expected: legitimate ceiling contact followed by falling, supported landing and
  normal movement. Actual: root remains Y≈6.144, not grounded; downward velocity
  accumulates to about -62, B2/World contacts report horizontal wall normals and
  no ceiling contact; D produces zero displacement and enters Wall_slide. Health 3.
- Reproduced at four under-B2 points and an independent rendered single-case repeat;
  B1 uncovered/B2 controls land and move. Thin ConcavePolygon floor has
  backface_collision=false; upward rays see no blocking underside. Strong geometry
  hypothesis: underside penetration and triangle-edge trapping, not a proven
  controller-only defect. See feature clearance-measurements.md for data/captures.
- Phase impact: blocks ceiling/recovery acceptance. Planning proposes a scene-local
  solid underside and reviewed containment before a separately chosen route.
  No fix is implemented or claimed. Uniform low caps must not trap the existing
  upper crate (top≈5.542); local guard/treatment needs review. Player changes held
  for Bao if correct solid ceiling still cannot recover.

Existing certificate-store diagnostics and detached-FSM shutdown leaks remain documented
in feature validation; this phase has not established a new major/high-severity gameplay
defect from them. Player/FSM/enemy changes are outside the authorized slice.
