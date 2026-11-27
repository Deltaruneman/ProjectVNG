# Implementation Plan: Continuous B1/B2 Basement Stage Integration

## Current applicability — audit 2026-11-13

The plan above/below is the preserved Nov 4 sprint snapshot, not current implementation
status. An installed Godot 4.7.2 build was found and executed; many formerly proposed
APIs and tests now exist. T071/T075 record the later gated separate-B3 route. The current
map uses nested Floor/Wall/Ceiling GridMaps and replacement asset libraries; the current
Player has orbit/aim controls and shared settings. See [system map](../../docs/project-current-state.md)
and [executed audit](../../docs/project-audit-validation.md) for exact baseline and results.

No implementation plan is executed by this audit. Proposed first repair group is
BUG-005/006 in `levels/level_1/basement_full.tscn` and
`levels/level_1/basement_floor_visibility.gd`, with GridPathfinder contract review only
if scene wiring/library naming cannot resolve zero navigation points. Lam/Quan and Duy
integration reviews remain required; no authorization or teammate approval is inferred.


**Branch**: `basement-split-floors` | **Date**: 2026-11-04 | **Spec**: [spec.md](spec.md)

**Input**: Approved specification and constitution v1.0.0.
**Status**: Documentation complete; implementation/runtime checks not run. Old B3-save recovery is blocked.

## Summary

Adapt the existing integrated `basement_full.tscn`, retaining B1/B2/parkour/Hidden in one
active stage and removing integrated B3/GroundExit. Preserve separate B3 unchanged and
inaccessible. Then establish B1/B2 spawns and nearby-F checkpoints. Ceiling clearance,
parkour completion, and the B2-clear gate are subsequent map work, not a reason to expand
this foundation into a player, enemy, or save-system rewrite.

Nov 4-7 sequencing below is conditional on reviews/interfaces; final build deadline is
2026-12-15. Q1-Q4 remain approved. See research for static evidence and contracts for proposed interfaces.

## Technical Context

**Language/Version**: GDScript; project declares Godot 4.7/GL Compatibility. Installed build
not verified; `Get-Command godot*` found no executable. README version is not runtime evidence.
**Primary Dependencies**: Existing Stage, GameManager, SaveSystem, GridPathfinder,
InteractiveArea3D, player/CameraRig, optional Dialogic, current mesh libraries.
**Storage**: Existing version-1 `user://save.json` dictionary: stage/checkpoint/flags.
**Testing**: Focused structural/fixture checks plus mandatory Godot playtests. Existing full/split
scripts assume old layouts. No Godot tests ran here.
**Target Platform**: Existing Windows development project; no new shipping-platform decision.
**Project Type**: Integrated Godot Prototype 1, not a new project.
**Performance Goals**: Preserve current responsiveness and one active stage/player/camera/HUD;
no invented FPS target or new streaming/performance system.
**Constraints**: Documentation only now. Preserve modifications/caches; no generators,
asset-library edits, branch change, commits, tasks generation, or implementation.
**Scale/Scope**: Two playable floors; preserved Hidden wall/room; separate inaccessible B3.

## Constitution Check

*GATE: Evaluated before research and re-evaluated after design.*

| Principle | Before research | After design |
| --- | --- | --- |
| Ownership | Lam/Quan map; Bao player; Duy enemies | Boundaries retained; shared-file reviewers and Duy contract agreement required before edits |
| Evidence | Reuse audit and inspect relevant current files | Static findings/inferences/playtest gaps separated; no bug-fix claim |
| Scope | Small incremental integration | Three phases; local variants rather than shared-system rewrite |
| Map safety | Git changes reviewed | No generators/libraries/caches changed; B3/Hidden preservation explicit |
| Validation | Spec acceptance read | Structural checks separated from gameplay; blocked checks cannot pass |
| Planning | Q1-Q4 approved | Concrete old-B3-save conflict held; no invented reset, waves, or wall multiplier |

Documentation gates pass. Implementation gates are conditional on ownership review and
interfaces. Old B3-save recovery fails readiness for that exception until an explicit decision
exists; independent work remains designable. This is an ERROR/hold for dependent recovery work,
not an exception granting a guessed migration. Re-evaluation does not claim implementation approval.

## Project Structure

### Documentation (this feature)

```text
specs/001-integrate-basement-stage/
  spec.md, checklists/requirements.md   existing, unchanged
  plan.md
  research.md
  data-model.md
  contracts/stage-progress.md
  quickstart.md
```

No tasks.md is created. The resolved plan workflow does not require an agent-guidance update;
existing instructions stay unchanged.

### Source Code (repository root)

Candidate paths below are not changed by this plan:

- `levels/level_1/basement_full.tscn`: composition, root/floor nodes, map geometry, local resources.
- `levels/level_1/basement_floor_visibility.gd`: existing Stage subclass and visibility rules.
- `levels/objects/checkpoint/basement_checkpoint.tscn` and `basement_checkpoint.gd`: proposed
  local inherited visual variant and InteractiveArea3D-based activation behavior.
- `levels/level_1/basement_progress_bridge.gd`: proposed stage-child adapter to agreed Duy interfaces.
- `levels/level_1/basement_progress_gate.gd`: proposed local gate controller, never a stage loader.
- `scripts/autoload/game_manager.gd`: narrow starting-stage/routing/checkpoint/flags/payload changes.
- `project.godot`: main scene and missing interact-to-F binding only; preserve existing plugin change.
- `levels/stage.gd`, `scripts/autoload/save_system.gd`, `scripts/interactive_area_3d.gd`:
  reuse unchanged unless a separately reviewed necessity emerges.
- `ui/hud.tscn`, `ui/health_bar.gd`: reuse unchanged; use local feedback, not a second HUD.
- `scripts/grid_pathfinder.gd`: inspect/verify, prefer scene-reference fixes over shared rewrite.
- `levels/level_1/basement_b1.tscn`, `basement_b2.tscn`: legacy identity/placement references only.
- `levels/level_1/basement_b3.tscn`: preserved future scene, no edits/playable acceptance.
- `scenes/player/`, `scripts/base_character.gd`, `levels/objects/enemy_zone/`: evidence only,
  owned by Bao/Duy. `assets/meshes/`: reuse resources unchanged.
- `tests/basement_integration_check.gd`: proposed focused structural/fixture runner, not present yet.

**Structure Decision**: One Stage subtree, not nested standalone Stage roots. Retain direct
Player/CameraRig/Bullets/Hud/Spawn and floor containers. Keep floor-local Pathfinder ancestry.
Basement-local checkpoint/gate/bridge behavior bounds shared impact.

## Implementation Phases

### A. Foundation — Nov 4 candidate

**Candidates and smallest changes**: In `basement_full.tscn`, rename root Basement to Stage
for Node3DFactory ancestry; retain B1, B1_5, B2, Player, CameraRig, Hud, Bullets, Spawn,
WorldEnvironment. Remove only integrated B3/GroundExit and unused dependencies. Remove null
B1/B1_5 Pathfinder obstacle entries; resolve each retained NodePath, preserving valid Hidden
links. Audit B1 nested World/Floor/Wall/B2-Parkour coverage before broader navigation changes.
Keep `basement_floor_visibility.gd` inheritance and once-only `super._ready()` registration.
Add scene-local `B2/SprintBoundary` StaticBody3D/CollisionShape3D using existing geometry
if removing B3 exposes the edge. No loading Door and no ceiling/parkour tuning in this slice.

**Separate startup safety slice**: Update only project main-scene reference and manager
FIRST_STAGE to continuous scene (`uid://mjb8sv4t2f20` / canonical path). In GameManager,
a narrow sprint destination guard must reject B3 path/UID before stage-change state mutates,
covering startup, respawn, and interaction callers. Retain deferred loading/health/dialogue flow.
Do not alter separate B3 return doors. Guarding a load is not approval to reset/redirect B3 saves.

**Ownership/review**: Lam/Quan map and containment; identify shared maintainer/reviewer for
GameManager and project settings before edits. No Duy/Bao work transfers to Lam.
**Structural checks**: one player/camera/Hud, Stage naming, no B3/GroundExit/loading Door,
valid resources/obstacle references, Hidden geometry/links preserved, separate B3 hash unchanged,
canonical path/UID destination guard coverage.
**Godot playtests**: isolated no-save F6 then F5, camera/visibility, projectile factory,
spawn support/navigation smoke, physical traversal without re-registration, terminal containment.
Death may reload the stage; B1-to-B2 physical traversal may not.
**Can proceed later**: reviewed scene preparation and isolated no-save testing.
**Held**: full startup/recovery acceptance for old B3 saves pending explicit handling decision.

### B. B1/B2 spawns, nearby-F checkpoints, and state integration — Nov 5 candidate

**Scene candidates**: `B1/Checkpoint_b1`, `B2/Checkpoint_b2`, IDs b1_start/b2_start,
child Spawn markers, spawn_points group, owner equal to active Stage. Reuse supported entry
surfaces; do not blindly copy split-scene coordinates. Root Player and Spawn transforms
currently differ; align default B1 placement in the scene rather than rewriting Stage.

**Local checkpoint variant**: Proposed basement_checkpoint.tscn inherits existing checkpoint
visuals/shape/Spawn but replaces root script only for basement. Its proposed .gd extends
InteractiveArea3D, validates Stage/Player eligibility, registers id, and requests manager
activation. Reuse generated Prompt (F); local AnimatedSprite3D tint plus ActivationFeedback
Label3D displays exactly "Checkpoint activated." only after accepted activation. Do not run
stock body_entered auto-activation alongside it. No stock checkpoint/HUD/player rewrite.

**Small shared changes**: Add `interact` physical F mapping in project.godot preserving all
other bindings/modifications. Add manager-side B1/B2 identity/rank validation and forward-only
activation; reject lower/foreign requests without success feedback. Explicitly classify legacy
B1/B2 paths/UIDs and reset only their checkpoint pair to continuous B1/default spawn, preserving
flags/clears/unlocks. Valid new checkpoints remain. Preserve unknown loaded top-level data by
merging manager-owned fields into the loaded dictionary; existing save_game drops such fields.
Reuse version-1 SaveSystem serialization/save_path; no schema-version or save-framework rewrite.

**Proposed ProgressBridge**: A child of Stage, scripted by basement_progress_bridge.gd,
adapts agreed Duy clear/query/restart capabilities to manager persistent flags. Restore
clears/unlocks before any wave start; never treat alive_count()==0 as floor completion.
Duy implements the wave behavior. Names and mappings in contracts are proposals, not current APIs.

**Ownership/review**: Lam/Quan local placement/interaction; identified shared manager/input/save
reviewer; Duy contract and wave initialization review; Bao input/interaction impact review.
InteractiveArea3D's comment assumes Player.can_interact, but that API is absent. Locally guard
alive/dialogue eligibility and test overlapping areas; any new Player API needs Bao approval.
Prefer spatially nonoverlapping interaction zones over a new interaction-priority system.

**Structural checks**: IDs/ownership/rank table, no auto-activation, one F mapping, narrow legacy
classifier, unknown data preservation, no enemy-health/partial-wave fields, one HUD.
**Godot playtests**: prompt/F/color/exact message, arrival without activation, B1 rejection
after B2, default/B1/B2 respawn, restart fixtures, camera snap, dialogue/overlap/F conflicts.
Use the contract's three death cases and persistent-clear state matrix.
**Can proceed later**: reviewed placement/local variant/rank guard/isolated save fixtures.
**Requires coordination**: real clear/unlock/reset/persistence and wave initialization order.
Mock callbacks prove adapters only. Old B3 recovery remains held, not covered by legacy B1/B2 reset.

### C. Subsequent map work — Nov 6-7 candidates

| Candidate files/nodes | Smallest change | Owner/dependency | Structural acceptance | Godot acceptance |
| --- | --- | --- | --- | --- |
| basement_full.tscn B1/World/Floor, Wall, B2-Parkour; B2/World | Measure obstructing cell/item/transform and collider underside; move/replace only evidenced cells using existing assets | Lam/Quan; Bao if player-state issue; no movement edits | Per-cell diff, shared libraries unchanged, Hidden preserved, navigation coverage | Current jump/second-jump timing, head contact, camera, landing/floor transitions |
| B1/World/B2-Parkour; proposed B1/ParkourAccessGate + basement_progress_gate.gd | Complete route and safe retry landings; gate closed until B1 clear and restored unlocked thereafter | Lam/Quan; Duy clear/snapshot contract | Gate collision/visibility coherent; route-only cells; no damage/hazard hooks | Real B1 clear, death/restart unlock, missed jumps at every gap, unchanged fall health, safe landing/retry |
| B2/LadderSpot_B2_B3 vicinity; proposed B2/CompletionGate and separate B2/SprintBoundary | Placeholder opens on B2 clear while boundary remains solid; no Door loading script | Lam/Quan; Duy B2 completion/snapshot | Separate visual gate/boundary colliders; no B3 destinations | Closed/open containment, repeated F/contacts, push/jump attempts, restart state, zero B3 loads |

Body capsule is about 1.698 high/radius .800. Jump speed 12/gravity 24 implies ideal first
root rise 3 and apex .5 seconds, not a verified clearance target. Second-jump state timing
matters. Measure actual takeoff/landing/collider sweep before moving geometry; no wall-height
multiplier or arbitrary platform-spacing rule is approved. See research R6.

Measured map geometry work can proceed after foundation review; real parkour unlock/B2 gate
and reset proof require Duy's interfaces. Safe terminal containment is required even without
completion events. No final art, unrelated asset-library edits, lethal falls, or new hazards.

### Smallest first implementation slice

One scene-focused change: Stage root name; remove integrated B3/GroundExit; remove null
obstacle entries while preserving valid Hidden links; retain all other content/runtime nodes;
secure the exposed B2 edge if necessary. Add only a focused scene-structure check in proposed
tests/basement_integration_check.gd. Validate structure and isolated no-save F6 load,
factory/navigation/camera/containment. No input/checkpoint/wave/save/ceiling changes in that slice.
It does not switch the production startup scene or constitute full feature acceptance.

## Complexity Tracking

### Current third-implementation replan — planning only, 2026-11-05

The ceiling/parkour sequencing in Phase C is refined by
[third-implementation-plan.md](third-implementation-plan.md), based on actual
[clearance/softlock measurements](clearance-measurements.md) and the
[candidate opening map](clearance-candidates.svg). Pass 1 is scene-local ceilings,
solid underside and containment with ceiling-contact/fall/landing/movement recovery;
pass 2 is a separate deliberate opening/parkour/landing/retry route chosen by Lam
and Quan before construction. Keep floor spacing/checkpoints for the smallest fix.
No scene/script edits or route choice are authorized by this planning record.
T038 no longer depends on route construction T036; T036 instead waits for pass-1
acceptance and a recorded route decision. No whole-plan regeneration or fixed claim.

No governance exception requested. Local variants/bridge/gates bound impact. No global event
bus, second loader, new save framework, player controller, wave manager, or asset pipeline.
Old B3 recovery is a blocker, not a complexity waiver.

## Planning Completion and Remaining Gates

Design supports independent work; old B3 saves still require an explicit recovery destination
and user-facing handling decision. Preserve their file/data, forbid loading B3, and do not
guess reset-to-B1 or any migration. Other unknown save exceptions need case decisions.
Record shared reviewer and Duy interface agreement before edits. All runtime acceptance is
unverified. No tasks/implement command, gameplay edit, or agent-guidance update occurred.


## T087 applicability update — 2026-11-13

Current user decision adds explicit B3 checkpoint/recovery, disabled targetless exit and
return to the combined B2 door Spawn. See T087 in spec/data-model/contract/tasks/validation;
this append does not regenerate the historical sprint plan. Old blanket B3 checkpoint
ban and legacy-reset policy are superseded by discriminated new B3 support + preservation
of exact legacy B1/B2 IDs. Old unmarked B3 remains held. T086, B2-clear gate and ownership
boundaries remain; no layout/library generation or independent reviewer agreement.
