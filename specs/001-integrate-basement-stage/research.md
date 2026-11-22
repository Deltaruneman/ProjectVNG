# Research: Continuous Basement Integration

**Date**: 2026-11-04 | **Evidence**: targeted static inspection only; no Godot run/generator.
Read constitution and current approved spec first; reused their audit context. Two focused
research reviews covered input/checkpoints and jump/collision. No new full-repository audit.
Approved Q1-Q4 stand; this research does not re-decide game rules.

## R1. Single Stage composition and navigation

**Decision**: Adapt existing full scene; keep its Stage subclass and direct singleton children.
Rename root Basement to Stage and remove only integrated B3/GroundExit. Repair invalid scene
references before considering generic script changes.
**Rationale/evidence**: basement_full.tscn:65 root is Basement. levels/stage.gd:8-13 expects
Player/CameraRig and registers once. scripts/node3d_factory.gd:18-24 explicitly finds parent
named Stage. The scene already has Player/CameraRig/Bullets/Hud/Spawn (:379-396).
B1 obstacle_maps (:116) and B1_5 (:195) contain nulls; grid_pathfinder.gd:112-115 dereferences
each map. Remove null entries. Relative Hidden NodePaths must be resolved, not declared broken
without proof. B1 floor_map points to World, but many cells are in nested Floor/Wall/Parkour;
actual coverage remains unverified. GridPathfinder.find (:41-45) uses finder-parent ancestry;
retain floor-local finders, not a new global graph.
**Alternatives considered**: nesting standalone Stage scenes duplicates active runtime objects;
rewriting loader/navigation exceeds scope. No such rewrite is justified.

## R2. Checkpoint behavior and visuals

**Decision**: Use a basement-only inherited checkpoint scene and local InteractiveArea3D
behavior, reusing existing helm sprite/collision/Spawn. Local tint and Label3D feedback avoid
HUD/player changes. Variant filenames in plan are proposed, not existing files.
**Rationale/evidence**: checkpoint.gd:9-21 auto-activates on body_entered; :24-26 uses owner
Stage path. checkpoint.tscn has AnimatedSprite3D, player-mask detector (1.8 x 2 x 1.8),
CollisionShape3D offset y=1, Spawn offset (0,.2,2). Spawn support must be playtested.
InteractiveArea3D already builds Prompt text F (:50-62) and consumes interact (:35-38).
ui/hud.tscn is one Hud CanvasLayer using health_bar.gd; no checkpoint-toast API exists.
**Alternatives considered**: changing stock checkpoints affects other floors/scenes; a screen
toast would touch shared health HUD. Local variant/feedback is the smaller review boundary.

## R3. Missing interaction binding and possible conflicts

**Decision**: Add only interact -> physical F during implementation, preserving other actions.
Check runtime focus/overlap/dialogue behavior; do not reopen the approved F decision.
**Rationale/evidence**: project.godot:92-163 contains no interact action or F mapping.
InteractiveArea3D defaults to interact (:13). No direct F collision was found in targeted
player/base/interaction/HUD/Dialogic input inspection. Dialogic mapping (:155-163) includes
Enter/mouse/Space/X/controller. conversation.gd comments mentioning F do not prove a mapping.
InteractiveArea3D:41-46 assumes can_interact only when the body implements it; current
Player/BaseCharacter lack that API. Thus alive/dialogue safety is not established.
**Alternatives considered**: remapping approved F or adding a Player method now is unjustified.
Use a local eligible-player/dialogue guard and separate checkpoint zones; consult Bao if a
shared Player/input change becomes necessary. Actual conflicts remain unverified playtest items.

## R4. Persistence, legacy references, and concrete old-B3 conflict

**Decision**: Reuse manager and SaveSystem, with narrow canonical stage/ID classification,
forward-only checkpoint ranks, destination guard, and payload preservation. Do not bump schema
or replace serializer. Hold recovery handling for old B3 saves.
**Existing evidence**:

- game_manager.gd:15 FIRST_STAGE is standalone B1; project.godot:14 main UID matches it.
- register_stage (:82-102) restores saved checkpoint; :93-95 may redirect to its saved stage.
- respawn (:116-120) loads checkpoint_stage; change_stage (:47-54) checks existence only.
- set_checkpoint (:124-127) accepts any pair; no rank guard.
- flags and unlock_door/is_door_unlocked (:130-136) persist booleans, not wave completion APIs.
- save_game (:139-140) constructs only stage/checkpoint/flags, dropping unknown top-level fields.
- SaveSystem version 1, dictionary serialization, and configurable save_path already exist.
  Unsupported versions return empty data; this does not authorize a new deletion/reset rule.

| Identity | Path | UID | Known checkpoint |
| --- | --- | --- | --- |
| Legacy B1 | res://levels/level_1/basement_b1.tscn | uid://ut8i8xxf74gj | b1_start |
| Legacy B2 | res://levels/level_1/basement_b2.tscn | uid://b7bnu12tjc0e8 | b2_start |
| Continuous | res://levels/level_1/basement_full.tscn | uid://mjb8sv4t2f20 | proposed retained b1_start/b2_start |
| Preserved B3 | res://levels/level_1/basement_b3.tscn | uid://d12u1s460ag67 | b3_start |

**Conflict**: A version-1 B3 save passes current existence checks and can load B3 at startup
or death. No B3 transition is permitted this sprint. Approved legacy reset covers only
standalone B1/B2 test checkpoints, not B3. Refuse B3 loads before mutating stage-change state;
preserve its save and report the blocked case. Recovery destination/user-visible handling
requires an explicit decision; no reset/remap/delete/default-to-B1 is approved for B3.
Missing/unknown references outside the identified set likewise need case review.
**Alternatives considered**: blanket new_game/reset/delete_save violates approval; basename
matching risks unrelated scenes; general migration or save rewrite is unnecessary.

## R5. Existing enemy zones versus proposed wave interface

**Decision**: Document a proposed Duy-owned completion/query/restart contract, not a new wave
implementation by Lam. Use one local ProgressBridge and existing manager flags for adaptation.
**Rationale/evidence**: levels/objects/enemy_zone/enemy_zone.gd starts a repeating timer;
_alive/max_enemies limits concurrent enemies, and tree exit decrements count. It has no
finite-wave/floor-clear lifecycle. alive_count()==0 is not a definition of floor clear.
Existing GameManager flags can store clears/unlocks but no floor-completion/reset APIs exist.
**Alternatives considered**: counting current mobs, inventing waves, or suppressing/rewriting
zones here changes Duy's systems. Agreement and implementation by Duy are dependencies.
Startup restoration must precede wave spawning; existing zones currently auto-start in _ready,
so adding only a parent _ready bridge cannot guarantee this. Duy must supply an initialization
handshake or equivalent agreed suspension before children start waves.

## R6. Jump/collision evidence before geometry proposals

**Decision**: Measure actual route cell transforms and collider sweeps, then move only evidenced
map obstructions using existing assets. Do not multiply wall height or alter Bao's player.
**Static evidence**:

- scripts/base_character.gd:25-26 movement 6/gravity 24; :44 jump_speed 12; :61 maxjump 2.
  Gravity precedes move_and_slide (:127-139); jump replaces vertical velocity (:170-172).
- scenes/player/player.tscn:35-37,90-92 body capsule radius .7998047, height 1.6977539,
  center y .84887695. Separate HurtArea capsule .6/1.6 is not the body clearance.
- player/states/jump.gd:9-14 does not call control_jump; fall.gd:24-35 handles second jump,
  coyote timer .1 (:7). Wall contact resets jump count; freely timed double jumps cannot be assumed.
- basement_full.tscn:84-116 B1 World/Floor/Wall/B2-Parkour use multiple libraries; current
  parkour has three serialized cells. B2 World (:224-228) uses basement_library.meshlib.
- basement_floor_visibility.gd changes visible only; collisions/enemies remain. Its base=1,
  floor spacing=6, switch margin=4.5 are visibility parameters, not verified physical clearance.

**Inference only**: isolated ideal rise 12^2/(2*24)=3 and apex 12/24=.5 seconds. Body top is
about 1.698 above origin. These do not prove practical headroom or second-jump clearance.
**Measurement plan**: record each obstruction's node/cell/item/transform, collider underside,
takeoff/landing level, body sweep, and screenshot. Compare ordinary/current second-jump timing,
ceiling contact, camera view, intentional misses, unchanged fall health, safe landing/retry.
**Alternatives considered**: global wall scaling, shared mesh-library collider edits, changing
jump/capsule/gravity, or assuming visibility removes collisions are unsupported and out of scope.

## R7. Validation and tooling limits

**Decision**: New focused checks plus Godot gameplay verification; no broad test rewrite.
**Rationale**: basement_full_check assumes B3 markers, compares raw cells across transforms,
and interprets multiple map libraries as one; walk_test assumes integrated B3 visibility;
split_check explicitly chains B1/B2/B3 doors and can touch stage/save state. Do not run them
unmodified as Option B acceptance. Preserve historical scripts; a new scoped runner is smaller.
No Godot tests or generators ran. No Godot executable found on PATH; choose the installed
project-compatible executable before later testing.
Setup-plan resolved the correct paths but reported feature basename as BRANCH because common.ps1
Get-CurrentBranch uses feature state, not Git. `git branch --show-current` independently confirms
basement-split-floors; no branch change occurred. Plan uses the actual branch.
**Alternatives considered**: claiming static checks prove gameplay or using F9 to delete real
saves is unacceptable. Use isolated fixture paths and record every unrun/blocked check.

## Research disposition

Technical choices are resolved to current reuse or clearly proposed owner-reviewed interfaces.
No technology-choice clarification remains. Concrete old-B3 recovery remains an implementation
ERROR/hold for that exception, not a newly invented game policy. Interface agreement, runtime
geometry, and executable availability remain verification/coordination dependencies.
