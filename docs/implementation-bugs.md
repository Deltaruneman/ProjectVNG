# Implementation bugs

> Latest T087: new marked B3 recovery and door contract are runtime-verified; old unmarked
> B3 data remains held. BUG-010 in-memory identity preservation now passes.
> Current audit index (2026-11-13, HEAD `42471e4c`): see
> [current state](project-current-state.md) and [execution evidence](project-audit-validation.md).
> T086 checkpoint repair update follows at the end: BUG-005 is runtime-verified fixed
> for the exercised approach/startup/death cases; native/independent review remains pending.
> Original BUG-001–004 entries below are historical evidence, retained verbatim.
> Their current disposition and new BUG-005–010 are appended below; historical severity
> does not mean the old reproduction still occurs on this HEAD. No game fix was made.

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

## Audit dispositions — 2026-11-13

Evidence root: see the exact absolute path and commands in
`docs/project-audit-validation.md`. Log names below are relative to that root.
Severity is impact assessment, not author attribution or owner acceptance.

| ID | Severity | Current status |
| --- | --- | --- |
| BUG-001 | High, historical | Preservation fixture passes; no regression demonstrated in its covered payload cases |
| BUG-002 | High, historical | T071/T087 allow clear-gated entry and new marked B3 recovery; unmarked/future/invalid B3 remains held; original evidence retained |
| BUG-003 | High, historical | **NOT REPRODUCED at current HEAD** in rendered B1/B2 interaction and settled captures; health bar visible. Keep history/open retest, no fix/attribution claim |
| BUG-004 | High, historical | **NOT REPRODUCED at current HEAD** at all six old coordinates; genuine first/second Jump transitions and landing observed. Keep open for broader geometry/containment review |
| BUG-005 | High | T086 FIX VERIFIED in bounded runtime cases; historical reproduction below retained; see final update |
| BUG-006 | High | REPRODUCED: B1/B2 pathfinders build zero walkable points |
| BUG-007 | High | REPRODUCED: Pelican has no gameplay damage receiver, blocking B1 finite clear/chest |
| BUG-008 | Medium | REPRODUCED: duplicate Player and Stage HUD/Skill Tree instances |
| BUG-009 | Medium | REPRODUCED: four alternate/test scenes have missing ext_resources |
| BUG-010 | Low | T087 FIX VERIFIED for tested v1 missing-reference identity/preservation; historical reproduction below retained |

### BUG-003 current retest (historical severity High)

- Steps: isolated rendered `basement_checkpoint_check.gd --lane=interaction --capture`;
  independently load actual combined stage, move Player to each declared child Spawn,
  settle 90 frames and capture viewport (`runtime.log`, `audit-B1.png`, `audit-B2.png`).
- Expected/actual: visible health bar at both B1 and B2; actual images show it at both.
  Actual HUD `_bar.is_visible_in_tree()` is true at both; two HUDs also exist (BUG-008).
- Limits: former renderer/scene state was different; camera and HUD were replaced since
  original evidence. A different B2 floor-visibility defect is BUG-005, not proof of the
  original missing-health-bar cause. Manual full route remains NOT RUN. No closure/sign-off.

### BUG-004 current retest (historical severity High)

- `diagnostic-scene.log`: actual Space press/release; second Space after Fall; wait 220
  physics frames then physical D for 30 frames. Six first Jump + six Fall→Jump transitions
  are in log. Original enemy timers stopped only in fixture, Player source unchanged.
- At (-3,1.2,14), (25,1.2,5), (31,1.2,15), (35,1.2,10), (35,1.2,25),
  (49,7.2,5), all settled/landed and moved after D. Four prior trap points return Y≈1.011.
  The last legacy B2 coordinate now settles Y≈4.961, so it is no longer an equivalent
  B2-surface control. Do not reuse old headroom measurements as current geometry.
- Expected/actual: no permanent trap at tested positions; no trap reproduced. Limits:
  renderer repeat of this exact jump sequence, current route-wide headroom, crate clearance,
  wall escape and all B2 surfaces remain NOT RUN. No ceiling fix/acceptance claim.

## [HIGH] BUG-005 — B2 continuation selects missing floor level; spawn support differs from declaration

- Status: **REPRODUCED / OPEN**, no fix. Owner boundary: Lam/Quan map/visibility;
  Bao input/controller preserved.
- Files: `levels/level_1/basement_full.tscn:235` (B2 root Y=5), `:350`
  (checkpoint local Y=7; child Spawn adds 0.2),
  `levels/level_1/basement_floor_visibility.gd:56`, `:73`, `:93`.
- Steps: before autoload, seed only isolated `save.json` with v1, stage
  `res://levels/level_1/basement_full.tscn`, checkpoint `b2_start`; normal main entry
  without `--scene`; let 100 physics frames pass. Repeat death from B3 with B2 checkpoint.
- Expected: B2 continuation/death recovery shows its supporting playable floor and uses
  a supported checkpoint endpoint, matching US1/US2 and T025/T026.
- Actual: declared marker is (49,12.2,5); Player lands at (49,11.0102,5), active_level=2,
  `B1.visible=false`, `B2.visible=false`; combined scene contains no level-2 B3.
  Legacy recovery support ray within 1 m beneath marker misses, and settle tolerance
  0.4 m fails. Six other recovery camera failures are obsolete test expectations and
  are **not** counted as this bug.
- Evidence: `entry-continue-b2.log`, `entry-explicit-b2.log`, `runtime.log`,
  `checkpoint-recovery.log`; rendered `audit-B2.png` shows invisible floor while HUD remains.
  Explicit scene launch correctly starts B1; normal B2 continuation does not.
- Static mechanism: initial height formula maps 12.2 to level 2; nearby B2→B3 connector
  logic returns the active level before correcting from support. Actual collider ownership
  and per-route geometry still require inspection before choosing a fix.
- Impact: continuation/respawn can present a blank/incomplete world; checkpoint location,
  connector metadata, geometry and visibility must be reconciled together. Not a save deletion.

## [HIGH] BUG-006 — Current B1/B2 navigation graphs have zero walkable points

- Status: **REPRODUCED / OPEN**. Files: `basement_full.tscn:108`–`:111`, `:270`–`:273`;
  `scripts/grid_pathfinder.gd:78`, `:108`; mesh libraries read-only evidence.
- Steps: instantiate current combined stage; call each actual Pathfinder's `point_count()`
  and inspect configured `floor_map.get_used_cells().size()` without changing maps/prefixes.
- Expected: a usable connected walkable graph for configured playable-floor navigation and
  valid spawn-point selection (T004/T009 navigation preservation).
- Actual: B1 World has 3 cells / **0 points**; B2 World/Floor has 405 cells / **0 points**;
  Hidden B1_5 control has 69 points. `find_path` necessarily returns empty on those graphs.
  B1 still points at parent World after floor split; B2's replacement MVP library uses
  asset names such as `Floor_*`, whereas default prefixes are case-sensitive `floor_`/`stair_`.
- Evidence: `runtime.log` `AUDIT_NAV`; `kill-rewards-final.log` spawning prints pathfinder=0;
  serialized scene and `MVP_library.tres` item names. Runtime build, not merely a suspected NodePath.
- Impact: PathAgent navigation fails and `closest_point()` falls back to arbitrary input
  instead of snapping to a walkable point; enemy-zone spawn safety is not established.
  Not every enemy uses PathAgent (skeleton/Starfish have other controllers), so this does
  not claim every enemy is immobile. Clone path integration remains a separate risk.

## [HIGH] BUG-007 — B1 Pelican cannot receive normal Player damage, preventing clear chest

- Status: **REPRODUCED / OPEN**. Duy enemy boundary; Bao reviews damage integration.
- Files: `scenes/enemies/pelican/pelican.tscn:19`, `pelican.gd`, `scripts/enemy.gd`
  (`_init_hurt_area`), `scenes/player/player.gd:796`, `basement_full.tscn:127`,
  `basement_floor_visibility.gd:61`.
- Steps: load real combined stage; let zone B spawn its configured Pelican (fixture calls
  the normal timer handler for deterministic timing); inspect descendants; invoke the
  actual Player circle damage helper at the Pelican's position with damage=999.
- Expected: the finite-clear enemy can be defeated through the game's damage contract;
  all three B1 zones can eventually clear and spawn the B1 chest.
- Actual: Pelican has only DetectPlayerArea3D and HitArea3D, **no HurtArea3D**; body
  collision_layer=4 (player_hurt) rather than enemy layer. Player helper returns hits=0,
  health remains 3. Enemy common hurt initialization silently skips missing receiver;
  Pelican has no ordinary damage/death override. B1 zone B never earns a normal defeat,
  therefore `_spawn_b1_chest` cannot satisfy its all-zone clear condition.
- Evidence: `kill-rewards-final.log` `AUDIT_PELICAN_BLOCKER`, instantiated area paths,
  source collision setup. The first reward harness assumed every enemy had a HurtArea3D
  and failed; its exception is a **harness error**, not the bug proof. The corrected
  receiver inspection + actual damage result establishes this finding. Its later zone-C
  victim selection can pick an earlier living Pelican; do not use that line as proof of
  a second Pelican zone (zone C is Skeleton Warrior).
- Impact: B1 genuine kill→clear→chest loop blocked. Directly assigning health or deleting
  the bird would bypass gameplay; neither is accepted as a successful full-clear test.

## [MEDIUM] BUG-008 — Two gameplay HUD and Skill Tree instances in normal basement

- Status: **REPRODUCED / OPEN**. Files: `scenes/player/player.tscn:144`,
  `levels/stage.gd:12`, `ui/hud.tscn`, `ui/player_hud.gd`.
- Steps: instantiate current main stage; list descendant Hud nodes and their SkillTreeLayer
  children; run existing checkpoint interaction lane's one-HUD assertion.
- Expected: one gameplay HUD / Skill Tree owner (US1 acceptance).
- Actual: `/root/Stage/Player/Hud` exists in Player packed scene; Stage checks only direct
  `Hud` then creates `/root/Stage/Hud`. Both layers draw and bind Player/progression signals;
  each includes SkillTreeLayer. Existing fixture records `one HUD` FAILED.
- Evidence: `runtime.log` `AUDIT_HUD_NODE` lists both paths;
  `checkpoint-interaction.log`: 25 passed / 1 failed. Rendered health text and UI overlap.
- Impact: duplicate UI and processing; pause/menu ownership risk. Existing 42-check camera
  suite still passes; it never proves there is only one HUD. Do not claim two menus open
  on every T press: input consumption can gate one of them.

## [MEDIUM] BUG-009 — Alternate scenes reference removed resources

- Status: **REPRODUCED / OPEN**, active main scene not shown broken by this finding.
- Files: `levels/level_1/stage_1_basement.tscn`, `stage_1_garden.tscn`, `stage_3.tscn`,
  `tests/test.tscn`. Missing refs include `scenes/enemies/barrel/barrel.tscn`,
  `scenes/npcs/mushroom_npc.tscn`, `scenes/objects/trap.tscn`,
  `assets/meshes/garden_library.meshlib`.
- Steps: ResourceLoader.load each scene in isolated normal scene harness after caches are
  available; retain original engine output, not only return value.
- Expected: every declared ext_resource resolves for scenes intended to remain runnable.
- Actual: engine prints `Cannot open file`, `Failed loading resource`, and scene-line
  `Parse Error: [ext_resource] referenced non-existent resource` for these four scenes.
  It may still return a non-null PackedScene; diagnostic load counters alone falsely appear green.
- Evidence: `diagnostic-scene.log` (44 ERROR lines total including repeated missing refs
  and exit diagnostic); `dependency-inventory.json`. These paths are absent in original
  source too, not omissions introduced by the test-copy exclusions.
- Impact: alternate scene/test entry resources partially missing. Their intended supported
  status needs a decision; do not silently delete them or retarget to similar assets.

## [LOW] BUG-010 — Unsupported missing-stage save loses identity in memory

- Status: **REPRODUCED / OPEN**; serializer/save-policy owner review required before fix.
- File: `scripts/autoload/game_manager.gd:362`–`:363`.
- Steps: seed isolated v1 fixture `{stage:"res://unknown/basement_b2.tscn",
  checkpoint:"b2_start", sentinel:{inventory:["keep",7]}}`; call manager load_game().
- Expected: retain unsupported pair for explicit review, as documented by compatibility
  contract and existing test; refuse guessed recovery/write without mutating its identity.
- Actual: stage becomes empty string while checkpoint remains b2_start.
  `checkpoint-fixtures.log`: 54 passed / **1 failed**, label
  `out-of-set pair not reset res://unknown/basement_b2.tscn`.
- Preservation: subsequent save is held by conflict detection; fixture confirms original
  disk bytes and no respawn fallback. **No disk progress loss reproduced.**
- Impact: misleading/partial in-memory conflict identity complicates diagnostics/recovery.
  Severity is Low for observed behavior, not assumed corruption.

## Non-bug buckets retained by this audit

- **Static risks / requirement gaps, not runtime-confirmed bugs:** durable B1 clear/parkour
  flags absent, clone floor/pathfinder ownership, Wind 3 direct position movement, geometric
  damage without line-of-sight; see current-state questions. Do not turn intentions into requirements.
- **Design decisions pending:** farmable ordinary-enemy SP, Hidden entrance, B2 chest,
  combined boss placement and B3 exit/old-B3 recovery.
- **Environment/harness:** full import timed out; first smoke ran before import completion;
  initial `--script` diagnostic singleton compile failure; harness type error and premature
  pre-FSM death call; GPU shader-cache initialize errors, UID fallback and shutdown retained
  objects/resources. These logs remain visible in validation and are not assigned gameplay IDs.


## BUG-005 / T086 checkpoint repair — 2026-11-13, working-tree baseline

**Current status: FIX VERIFIED for the runtime cases listed below; native feel and
independent Quan/Bao review remain pending.** The earlier audit OPEN entry is historical.
No new bug ID is assigned for approach blackout: it shares the absent-floor selection cause.

### Reproduction before F and proven cause

- Current baseline retains branch/HEAD `feature/playercontrolandmap` / `42471e4c`, prior
  audit docs, and pre-existing scene edits: checkpoint B2 local Y=6, Door_b2_up moved.
  These scene bytes are not changed by T086. Do not reuse audit's old checkpoint Y=7.
- In an isolated actual-basement run, walk from (49,11.2,9) toward (49,11.1,3.9), then
  walk back. Repeat from west, camera yaw 0/90/180 and zoom 3/9/14. No F/death/save needed.
- Before: Player=(49,11.01055,9), grounded on `/root/Stage/B2/World/Floor`, level=1,
  only B2 visible. Near: Player=(49,11.01055,4), same support/grounded, connector
  `B2/LadderSpot_B2_B3` (from=1,to=2), level=2, B1/B1_5/B2 all false. Departure restores B2.
- Yaw0/zoom9 at failure: focus=(49,12.31055,4), camera=(49,15.36821,12.40085), distance=8.94;
  focus/lens overlap lists empty, desired-boom obstruction none, actual camera→Player
  sightline collider none. Both ceiling visuals already false. Checkpoint Sprite is a
  non-solid Area child and becomes invisible with B2, rather than covering the camera.
  Other yaw/zoom traces identify real walls and keep the lens outside world collision.
- Cause: `_ready()` registered a connector to level 2 although no integrated floor 2 exists.
  Grounded Y≈11 exceeds its nominal midpoint 10, so entering its radius selects 2.
  Startup independently guessed level 2 from nominal floor spacing before grounded physics.
  Both paths hide all floor branches. GameManager/input F and camera collision are not causes.

### Small fix and spawn attribution

- `basement_floor_visibility.gd`: keep a connector only if both metadata levels exist;
  choose startup/respawn fallback only among actual floor levels. Keep supported-floor
  detection, real B1↔B2 midpoint/hysteresis, secret-area rule, ceiling render behavior,
  collision, camera sweep and separate-scene B3 door unchanged.
- No scene, checkpoint detector/resource, GameManager, Player, CameraRig, input or asset
  library change. No always-visible B2 or collision/occlusion disable workaround.
- Spawn mismatch from the audit is **already corrected in the incoming working tree**:
  B2 parent Y=5 + checkpoint local Y=6 + child Spawn Y=0.2 = world (49,11.2,5).
  Actual support Y≈11.01, capsule settles Y≈11.0102 (≈0.19 below declaration). B1 has the
  same supported clearance. All original support assertions pass before the selector fix;
  T086 does not claim authorship of this earlier position correction.

### Evidence and limits

Evidence root is `cp-fix` under the same visualization workspace documented in audit
validation. Before screenshots retained in `before-captures`, after in `after-captures`.

- Rendered before: 18 B2 approach visibility failures across 18 combinations; B1 controls
  remain visible. Final paired headless trace: 126 checks / 18 failures before, 126/0 after.
- Rendered after: 126/126 approach/camera checks; F/tint/exact feedback/repeated F/forward-only,
  Esc Settings, jump/land, B2 death and B3→B2 death recovery 32/32; physical connector
  wall-jump ascent and descent 2/2; unchanged CameraRig collision suite 115/115.
- Updated recovery fixture uses actual orbit focus_offset (not old rig=Player expectation),
  retains original support tolerances and adds visibility checks: 63/67 before, 67/67 after.
- Five fresh rendered processes: B1 start/restart, B2 start/restart and explicit-scene B2
  bypass, each 7/7. Synthetic save bytes unchanged; unrelated nested payload and flags survive.
- Full-copy UID fallback and shutdown retained-resource warnings remain; no SCRIPT ERROR
  in final game runs. An initial temporary regression fixture compared int vs JSON numeric
  types and failed two payload comparisons; corrected by retaining the initial loaded
  sentinel, then rendered 32/32. Game serialization was not modified.
- BUG-006/007/008/009/010 remain independent and open. Save fixture still fails its original
  BUG-010 missing-path identity assertion (54/55); it is not weakened for this repair.
- NOT RUN: native editor F5/F6 button interaction and subjective camera feel, every possible
  viewpoint/pitch/aspect ratio, independent Quan/Bao review. No whole-project acceptance.


## T087 B3 scope / compatibility update — 2026-11-13

Current user decision replaces blanket B3 checkpoint refusal with explicit nearby-F
activation, rank3 and a discriminator. This is new authorized behavior, not a retroactive
claim that historical B3 refusal was a gameplay defect under the old spec.

- **Door_b3_exit:** targets stay empty; transition_enabled=false keeps visual/solid gate,
  removes only InteractiveArea3D/prompt. Handler refuses disabled/empty targets before
  animation/load. Actual F and direct handler tests emit no empty-stage/load/script error.
- **Door_b3_down:** targets combined main scene / `b2_up`, using existing dedicated
  Door_b2_up/Spawn at (38.1885,11.17303,8.2), supportY11.01, outside trigger. Runtime return
  is B2 (not standalone B2 or checkpoint), no loop even on F, no checkpoint/save mutation.
- **Checkpoint_b3:** uses explicit basement detector; no contact activation. Prompt/tint/
  exact message pass; repeated F preserves both file bytes **and modification timestamp**
  across a >1s filesystem-clock boundary, and does not replay feedback. New rank3 prevents
  B1/B2 activation and legacy B2 setter downgrade. Settings roundtrip and death/restart pass.
- New supported v1 save must have B3 path/UID, b3_start,
  `basement_checkpoint_contract="explicit_b3_v1"` and b2_cleared. New activation creates
  discriminator; load never stamps it onto old B3 data. Unmarked old pairs, future marker,
  unknown ID and missing clear remain held byte-for-byte, no fallback/reset/delete.
- Current no-silent-reset requirement also supersedes old exact legacy B1/B2 reset.
  Known pairs normalize in memory to equivalent ID, with disk unchanged. Unknown/missing
  pair identity is retained instead of clearing stage: **BUG-010 verified fixed** in
  original missing-reference assertion and dedicated compatibility checks. This is a
  required save-preservation change in T087, not a separate unrelated bug cleanup.

Evidence in `b3-fix` workspace (full path/commands in audit validation): rendered flow99/99,
compatibility47/47; nine fresh rendered processes all pass and keep save bytes identical
(three new B3 restarts, four held old/future/missing-clear cases, legacy B1/B2). Existing
save fixtures now59/59, B1/B2 recovery67/67, T086 approach126/126. Final flow also verifies
actual B2 three-defeat clear and three SP drops via damage/pickup APIs, not a fake clear.

Historical BUG-001–010 evidence is retained. T086 gameplay source is unchanged; optional
boss fixture guard only reflects the incoming removal of DarkFairy from combined scene.
No AI, layout/library, camera, input or HUD cleanup. Other open audit bugs remain open.
Known UID fallback/retained-object/resource exit diagnostics persist; no SCRIPT ERROR in
final flow/compatibility/entry runs. Native editor/control feel and live boss interference
remain NOT RUN; no Quan/Bao/Duy review is claimed. Old unmarked B3 migration is intentionally
still unsupported until an explicit policy, not declared fixed/recovered by the new contract.
