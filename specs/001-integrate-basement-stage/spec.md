# Feature Specification: Continuous B1/B2 Basement Stage Integration

**Feature Branch**: `basement-split-floors`

**Created**: 2026-11-04

**Status**: Draft updated with final user decisions; Q1-Q4 resolved; runtime acceptance unverified

**Input**: Adapt existing integrated Prototype 1 using Option B: one active B1/parkour/B2
stage with preserved Hidden B1.5 content. B3 is inaccessible this sprint; preserve its separate
scene. Record the Nov 4-7 map scope and coordinated wave dependencies. Documentation only.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Keep one continuous playable basement (Priority: P1)

The player explores B1 and B2 in one active stage, without scene changes on the physical
parkour route. Hidden B1.5 remains preserved content; its entrance is deferred.

**Why this priority**: Stage integration is the foundation for subsequent map work.

**Independent Test**: Godot playtest the available main route with existing player abilities;
record stage identity, loading events, player/camera/HUD counts, registration, and errors.
Full gated-route acceptance also requires the subsequent map tasks and Duy's wave interface.
A fixture or simulated clear may isolate integration checks but cannot prove gameplay wave completion.

**Acceptance Scenarios**:

1. **Given** the continuous stage is active and parkour access is unlocked,
   **When** the player physically travels B1 through parkour to B2,
   **Then** no stage change, reload, or stage re-registration occurs.
2. **Given** the player crosses a playable floor boundary or respawns,
   **When** gameplay settles, **Then** exactly one active Player, CameraRig, HUD, and
   stage registration exist, with correct camera tracking and usable route visibility.
3. **Given** the current Hidden B1.5 room and HiddenGate_B1_5 wall,
   **When** integration is reviewed, **Then** their geometry, collisions, behavior, and
   existing connections remain intact. Necessary reference repairs are documented and
   preserve those properties; no entrance mechanic or wave-clear coupling is introduced.
4. **Given** the main route, **When** the player proceeds toward B2,
   **Then** entering or exiting Hidden B1.5 is not required or tested for sprint acceptance.

### User Story 2 - Activate checkpoints and recover progress (Priority: P1)

The player activates a nearby visible temporary checkpoint by pressing F. Activation shows
an interaction prompt beforehand, changes the marker color, and displays "Checkpoint activated."
Checkpoint progression is forward-only; reaching a floor alone does not activate its checkpoint.

**Why this priority**: Respawn and restart must preserve earned floor progress without
moving the active checkpoint backward.

**Independent Test**: With isolated save fixtures, test B1/B2 activation, prompt and feedback,
forward-only progression, the three death cases below, and application restart. Inspect
checkpoint ownership, stage identity, endpoint, clear/unlock state, and wave-reset outcomes.
Wave outcomes require Duy's coordinated dependency; no runtime result is asserted here.

**Acceptance Scenarios**:

1. **Given** a nearby eligible temporary checkpoint, **When** the player stands near it,
   **Then** an interaction prompt is visible; pressing F activates it, changes its marker
   color, and displays exactly "Checkpoint activated." Proximity or floor arrival alone
   does not activate it. Final art is not required.
2. **Given** B2's checkpoint is active, **When** the player approaches or presses F at B1's
   checkpoint, **Then** B1 cannot replace the active B2 checkpoint. No downgrade is persisted.
3. **Given** B1 is not cleared, **When** the player dies,
   **Then** respawn is at B1 and B1's waves restart.
4. **Given** B1 is cleared and B2's checkpoint has not been activated, **When** the player
   dies in B2, **Then** respawn is at B1, unfinished B2 waves restart, B1 stays cleared,
   and parkour stays unlocked. Reaching B2 has not activated its checkpoint.
5. **Given** B2's checkpoint is active, **When** the player dies,
   **Then** respawn is at B2 and unfinished B2 waves restart; B1 stays cleared and
   parkour stays unlocked. A cleared floor must not be treated as unfinished.
6. **Given** an activated B1 or B2 checkpoint and earned clear/unlock state,
   **When** the application restarts, **Then** the checkpoint, cleared floors, and unlocks
   persist. Unfinished floor waves restart; individual enemy health and partial wave
   progress are not restored or saved this sprint.
7. **Given** a retained B1/B2 checkpoint, **When** activation, death recovery, and saved-game
   continuation are checked, **Then** it belongs to the intended Stage and its unique ID
   and scene reference restore the correct location. With no checkpoint, start at B1's
   default spawn in the continuous stage.
8. **Given** an explicitly identified old test checkpoint referencing standalone B1 or B2,
   **When** the approved narrow compatibility reset is used, **Then** checkpoint progress
   resets to continuous B1's starting point. Preserving the old checkpoint location is
   unnecessary; unrelated save data and valid new-stage checkpoints remain intact.

### User Story 3 - End playable progression safely at B2 (Priority: P1)

The player cannot access B3 this sprint. After B2 clear, a placeholder gate toward B3 opens,
but a safe boundary still prevents leaving the playable area. Separate B3 work is preserved.

**Why this priority**: The sprint must communicate B2 completion without exposing unfinished areas.

**Independent Test**: Before and after a genuine B2-clear event, approach and interact with
the terminal area and attempt to pass the boundary. Verify gate state, safe containment,
and zero B3 loads. Gate opening is a subsequent map task dependent on Duy's completion event.

**Acceptance Scenarios**:

1. **Given** B2 is unfinished, **When** the player approaches the B3-facing gate,
   **Then** the gate remains closed and B3 cannot load.
2. **Given** B2 has been cleared, **When** its completion is received,
   **Then** the placeholder gate opens while the safe boundary prevents traversal beyond
   the playable area. Interacting or repeatedly approaching cannot load B3.
3. **Given** any supported sprint launch, checkpoint recovery, or application restart flow,
   **When** its destination is resolved, **Then** it does not load B3.
4. **Given** integration changes, **When** content is reviewed,
   **Then** integrated B3/GroundExit geometry is absent from the continuous stage,
   and the separate B3 scene and its existing work are preserved for the future.

### User Story 4 - Complete safe parkour with sufficient clearance (Priority: P1; subsequent map work)

The player gains parkour access after B1 clear, can traverse B1/B2 with suitable ceiling
clearance, and can miss a jump and retry without fall damage or newly introduced hazards.

**Why this priority**: These are actual Nov 4-7 map outcomes following the integration foundation.

**Independent Test**: Godot playtest the complete main route, ceiling clearance, intentional
missed jumps, landings, and retries with existing movement. Compare health and hazard behavior
before/after misses. Do not assume a teleport, lethal fall, or new recovery mechanic.

**Acceptance Scenarios**:

1. **Given** B1 is uncleared, **When** the player approaches parkour access,
   **Then** it is locked; once B1 clears, it unlocks and stays unlocked across death and restart.
2. **Given** the approved current abilities, **When** the player traverses the completed
   route, **Then** B1/B2 ceiling geometry provides clearance without requiring changes
   to player movement, combat, colliders, or abilities.
3. **Given** parkour is accessible, **When** the player misses a jump,
   **Then** falling causes no fall damage, lethal fall, or new hazard and the player can
   safely retry. Record the landing and retry route rather than inferring success.

### Edge Cases

- B2 arrival without F activation; B1 interaction after B2 activation; repeated F presses.
- No checkpoint, active B1 checkpoint, and active B2 checkpoint on death and application restart.
- B2 death before checkpoint activation must preserve B1 clear and parkour unlock.
- Restart during unfinished waves versus after floor clear; never restore enemy health or
  partial wave progress, and never restart a cleared floor as though it were unfinished.
- Falling at different parkour segments: health unchanged by the fall and a safe retry route.
- B2-clear gate opens while the independent safe boundary still contains the player.
- Old B3-facing transitions or saved references must not load B3 in sprint gameplay.
- Legacy B1/B2 path/UID references versus valid continuous-stage checkpoints; preserve unrelated data.
- Missing/unknown save references outside the identified legacy set: no new blanket reset policy.
- Nested checkpoints with wrong Stage ownership; duplicate IDs or runtime singleton instances.
- Hidden-area reference repair accidentally changes wall collision, connections, or visibility behavior.
- Pre-existing movement/geometry defects block the route; report them separately from regressions.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Retain B1, parkour, B2, and Hidden B1.5 content in one active continuous stage.
  Physical B1-to-B2 traversal MUST NOT change/reload or re-register the stage. The hidden
  entrance is excluded from traversal acceptance.
- **FR-002**: Preserve Hidden B1.5 and HiddenGate_B1_5 geometry, wall, collisions, behavior,
  and existing connections. Necessary integration reference repairs MAY be made only
  when documented and verified to preserve those properties. No entrance design, opening
  mechanic, always-open wall, or B1-wave-clear linkage is included this week.
- **FR-003**: At stable gameplay and after load/respawn there MUST be exactly one active
  Player, CameraRig, HUD, and stage registration. Verify counts, camera tracking, and route visibility.
- **FR-004**: B3 MUST be inaccessible this sprint. No transition, supported checkpoint
  recovery, or startup flow may load B3. B3 round trips, checkpoint behavior, and entry/return
  endpoints are not acceptance requirements. Keep the separate B3 scene for future work.
- **FR-005**: Remove integrated B3/GroundExit geometry from the B1/B2 stage while preserving
  the separate B3 scene and its existing work. A safe B2 terminal boundary MUST remain.
- **FR-006**: Preserve existing integrated content and scene/resource dependencies except
  necessary, documented integration changes. Later map geometry work has the distinct
  scope below; hidden-area repairs remain limited by FR-002.
- **FR-007**: Establish B1/B2 spawn points and checkpoints with correct Stage ownership,
  unique stage-local IDs, and scene-path/UID compatibility. Activation, death recovery,
  and application restart MUST restore the intended checkpoint location in the continuous
  stage; absent checkpoint progress starts at B1's default spawn.
- **FR-008**: Checkpoint progression MUST be forward-only. An activated higher-floor
  checkpoint cannot be replaced by a lower-floor checkpoint. Reaching a floor alone
  MUST NOT activate its checkpoint. Apply the rule to B1/B2 without enabling future floors.
- **FR-009**: Explicitly identify legacy standalone B1/B2 checkpoint references, including
  supported path/UID representations. Old test saves matching that set MAY reset checkpoint
  progress to continuous B1's starting point; preserving old locations is not required.
  Do not delete/reset unrelated save data or valid new-stage checkpoints. Record and test
  the reset's narrow scope. Other invalid references are not covered by this approval.
- **FR-010**: Introduce no new loading, spawning, or navigation errors. Compare equivalent
  before/after routes; distinguish integration regressions from pre-existing movement or
  geometry defects. Report every acceptance blocker, even if pre-existing.
- **FR-011**: Required verification includes Godot playtests of traversal, collision,
  camera, falling/retrying, respawn, checkpoint interaction, restart, and terminal containment.
  Separate static findings, hypotheses, and runtime-verified behavior. Record checks not
  run, reasons, and limitations; static/headless checks alone do not prove gameplay acceptance.
- **FR-012**: B1 completion MUST unlock parkour and B1 clear/parkour unlock MUST persist
  across death, including B2 death before checkpoint activation, and application restart.
  Wave completion/reset/persistence interfaces require coordination with Duy; this feature
  MUST NOT implement his systems or invent wave counts, composition, or defeat definitions.
- **FR-013**: Player movement, combat, colliders, and abilities MUST remain unchanged in
  this feature; any proposed movement change requires Bao's coordination and approval.
  Geometry/clearance and Double Jump concerns MUST NOT be solved by unauthorized player
  changes. Duy's enemy behavior remains protected.
- **FR-014**: Keep integration as the first feature's foundation. Ceiling repairs, parkour
  completion, and the B2-clear gate are subsequent map work recorded below, not permission
  to implement now. Final checkpoint art, hidden entrance, B2 visual completion, future
  boss work, Garden elevators, future floor travel, and unrelated refactors remain excluded.
  One checkpoint per floor is intended direction; no future-floor work is implied.
- **FR-015**: Before B1 clear, death MUST respawn at B1 and restart B1 waves. Death in B2
  before B2 checkpoint activation MUST respawn at B1 and restart unfinished B2 waves,
  while preserving B1 clear and parkour unlock.
- **FR-016**: Death after B2 checkpoint activation MUST respawn at B2 and restart
  unfinished B2 waves, preserving B1 clear and parkour unlock. Cleared-floor progress
  MUST NOT be discarded by these resets.
- **FR-017**: A checkpoint MUST have a visible temporary marker and an interaction prompt
  when the player stands nearby. Pressing F activates an eligible checkpoint, changes its
  marker color, and displays exactly "Checkpoint activated." Floor arrival or proximity
  without F does not activate it. Lower-floor interaction cannot downgrade progress.
  Final art is deferred; no specific final color or asset is required.
- **FR-018**: Application restart MUST preserve the activated checkpoint, cleared floors,
  and unlocks. Unfinished floor waves restart. Individual enemy health and partial wave
  progress MUST NOT be saved this sprint. This is a coordinated persistence dependency,
  not permission to implement enemy systems.
- **FR-019**: Missed parkour jumps MUST cause no fall damage. Do not introduce fall damage,
  lethal falls, or new hazards. Validate safe landings and retrying with current abilities.
- **FR-020**: As subsequent map work, B2 clear MUST open a placeholder gate toward B3
  while retaining a safe boundary preventing travel beyond the playable area. Gate opening
  depends on Duy's wave-completion interface and MUST NOT trigger any B3 scene load.

### Key Entities *(include if feature involves data)*

- **Active basement stage**: B1/parkour/B2, preserved Hidden content, one player/camera/HUD,
  one registration, and stage-owned B1/B2 checkpoint/spawn identities.
- **Checkpoint progression**: activated floor and unique checkpoint identity, advanced by
  nearby F interaction; lower-floor activation cannot replace higher-floor progress.
- **Persistent floor state**: cleared floors and unlocks, including B1 clear/parkour access;
  retained alongside the checkpoint across application restart.
- **Unfinished wave state**: restarts in the approved death/restart cases; enemy health and
  partial wave progress are not persisted. Wave definitions remain with Duy.
- **B2 terminal gate and safe boundary**: visible completion response plus independent
  containment, with no B3 transition. Separate B3 is a preserved future asset only.
- **Legacy checkpoint reference**: explicitly identified standalone B1/B2 reference eligible
  for the narrow approved checkpoint reset, preserving unrelated data.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The available B1-to-parkour-to-B2 route has zero stage reloads/changes and
  zero stage re-registrations; stable gameplay has one player, camera, HUD, and registered
  stage. Full route clearance/completion also depends on subsequent map work (FR-001/003).
- **SC-002**: Review finds Hidden geometry/behavior/collisions/connections preserved and
  zero added entrance mechanics or wave-clear links. Every necessary reference repair
  has a documented reason and preservation check; no hidden-entry test is required (FR-002).
- **SC-003**: B1/B2 checkpoint fixtures restore the correct location after death/restart.
  Any approved legacy reset returns only identified legacy checkpoint progress to B1;
  valid new checkpoints and unrelated data remain intact (FR-007/009).
- **SC-004**: B3 is loaded zero times across supported sprint traversal, interactions,
  checkpoint recovery, and restart checks. Boundary attempts cannot leave the playable area;
  the separate B3 scene remains preserved (FR-004/005).
- **SC-005**: Acceptance runs show zero new loading, spawning, or navigation errors.
  Every unrun check and blocking baseline defect is listed; blocked scenarios are never
  reported as passing (FR-010/011).
- **SC-006**: Review accounts for all necessary integration changes and finds zero
  integrated B3/GroundExit geometry or unauthorized player/enemy changes (FR-005/006/013).
- **SC-007**: All three death cases pass: pre-clear B1 returns to B1/restarts B1; B2 without
  activation returns to B1/restarts unfinished B2; activated B2 returns to B2/restarts
  unfinished B2. B1 clear and parkour unlock persist once earned (FR-012/015/016).
- **SC-008**: Every B1/B2 checkpoint presents a nearby prompt, accepts eligible F activation,
  changes marker color, and displays "Checkpoint activated." B2 arrival alone never
  activates it; B1 cannot replace an active B2 checkpoint (FR-008/017).
- **SC-009**: Restart checks preserve every tested activated checkpoint, cleared floor,
  and unlock while restarting unfinished waves without saved enemy health or partial
  wave progress (FR-018). Missing interfaces block these checks, not their documentation.
- **SC-010**: Subsequent map acceptance demonstrates B1/B2 clearance and the completed
  parkour route with current abilities, plus intentional missed jumps and safe retries
  with zero fall damage, lethal falls, or newly introduced hazards (FR-013/019).
- **SC-011**: Subsequent map acceptance shows the B2-facing gate closed before B2 clear
  and open after clear, with the safe boundary effective in both states and zero B3 loads
  (FR-020). Wave-dependent gate opening remains blocked until the interface exists.

## Assumptions

- This is integrated Prototype 1, governed by constitution v1.0.0; final build deadline is
  2026-12-15. The Nov 4-7 map scope is 2026-11-04 through 2026-11-07.
- Option B remains approved for continuous B1/B2 stage integration. Final sprint decisions
  supersede previous B3 access/round-trip and B3 checkpoint acceptance.
- Current player abilities are the traversal baseline. No additional ability or new hazard
  is assumed. Detailed wave counts/composition/defeat definitions are not specified here.
- These are approved requirements, not observed runtime behavior. No gameplay checks ran
  during this documentation update.

## Approved Architecture and Scope Boundaries

Adapt `levels/level_1/basement_full.tscn` as the active B1/parkour/B2 stage, preserving
Hidden B1.5 and HiddenGate_B1_5. Keep `levels/level_1/basement_b3.tscn` separate and preserved,
but inaccessible this sprint. Do not compose fully active standalone stages or enable B3
loads. These are feature decisions, not permanent constitution rules.

### Nov 4-7 map scope and sequencing boundary

| Scope item | Boundary | Dependency and acceptance |
| --- | --- | --- |
| Stage integration | First feature foundation | One active stage; preserve dependencies/Hidden content; exclude integrated B3/GroundExit and B3 loads |
| B1/B2 spawn points and checkpoints | Foundation integration outcome | Correct ownership, IDs, nearby-F feedback, forward-only progress; coordinated save/round interfaces |
| B1/B2 ceiling geometry and clearance | Subsequent map task after foundation | Map geometry repair; current player abilities; Godot clearance playtest; Bao approval for any proposed movement change |
| Parkour completion accessible after B1 clear | Subsequent map task after foundation | Duy's completion/unlock interface; persistent unlock; missed-jump landing and retry validation without fall damage/new hazards |
| B2-clear placeholder gate | Subsequent map task after foundation | Duy's B2-completion interface; open gate while retaining safe boundary; zero B3 loads |

This table records scope and dependency boundaries only; it is not a generated task plan.
Subsequent map outcomes remain required for the Nov 4-7 scope, even when they are outside
this first foundation feature. Foundation completion MUST NOT be claimed as completion of
those map tasks or their wave-dependent acceptance. Final visual polish remains deferred;
that does not defer the parkour completion and safety work listed above.

Lam and Quan coordinate map integration/geometry. Duy owns wave/enemy systems; completion,
reset, and persistence require coordinated interfaces and an identified review boundary.
Bao owns movement/combat/abilities; player movement changes need his coordination and approval.
Team leadership transfers neither owner's work. Shared Stage/checkpoint/save/starting-stage
changes require affected-system impact and reviewer identification before implementation.

One checkpoint per floor is intended direction, limited here to B1/B2. Garden elevators,
future floor travel, boss work, Hidden entrance, and final checkpoint art remain out of scope.
Preserve current modifications, docs, resources, and tracked caches. This update changes
only the spec and requirements checklist on `basement-split-floors`; no gameplay edits,
generators, branch changes, planning, implementation, commits, or pushes are authorized here.

## Evidence and Current Compatibility Findings


Evidence below is static inspection on 2026-11-04, not a runtime audit rerun.
The supplied audit conclusions and constraints are retained; no separate completed audit
report was found in the inspected documentation. No unseen audit result is asserted.

| Source | Static finding | Implication requiring verification |
| --- | --- | --- |
| `basement_full.tscn` | Contains B1/B1_5/B2 and integrated B3/GroundExit; root is named Basement and uses floor visibility script | Remove only excluded integrated content; assess root-name compatibility with Stage-dependent callers |
| `basement_floor_visibility.gd` | Extends Stage; changes visibility, not collision or enemy execution | Hidden floors may still obstruct movement; actual traversal/camera effects remain unverified |
| `levels/stage.gd` | Registers stage; expects Player and CameraRig; resolves spawn IDs among descendants; comments require root name Stage for factory lookup | Verify registration, root-name dependencies, and spawn uniqueness |
| `checkpoint.gd` | Activation requires owner to be a Stage; records owner scene path and ID | Verify B1/B2 ownership; baseline activation does not establish the approved nearby-F interaction |
| `game_manager.gd` | FIRST_STAGE is standalone basement_b1; respawn uses saved stage/ID; startup continuation depends on FIRST_STAGE | Starting-stage, continuation, and checkpoint compatibility require coordinated review |
| `save_system.gd` | Version 1 stores stage/ID/flags; unsupported/invalid files return empty data | Static baseline only; approved legacy checkpoint reset must preserve unrelated data and valid new checkpoints |
| `game_manager.gd` load/register logic | Missing stage clears in-memory checkpoint; existing scene paths are not remapped; missing IDs reach Stage's warning path | Legacy standalone paths can remain loadable but incompatible with Option B; no runtime save behavior verified |
| `basement_b2.tscn`, `basement_b3.tscn` | b2_up targets B3/b3_down; b3_down targets standalone B2/b2_up via UIDs | Historical routing only; B3 loading must be inaccessible this sprint; separate B3 remains preserved |
| `basement_b1.tscn`, `basement_b2.tscn`, `basement_b3.tscn` | Checkpoint IDs b1_start, b2_start, b3_start | B1/B2 identities inform narrow legacy detection; B3 checkpoint acceptance is outside this sprint; actual user save contents not inspected |
| `project.godot` | Main scene UID matches standalone B1 | Verify launch destination alongside manager starting-stage reference |
| B3 Door_b3_exit | No destination configured; marked as unfinished ground exit | Ground-exit completion is outside this feature; report baseline limitation without inventing its destination |
| `tests/basement_full_check.gd`, `basement_walk_test.gd`, `basement_split_check.gd` | Existing checks assume old full/split layouts, including integrated B3 markers | Existing checks are not Option B acceptance evidence; future validation must account for outdated expectations |

`docs/build_progress_1.md` describes historical parkour and wave-trigger progress.
It does not establish finite-wave completion; the current user-supplied finding that finite
waves are absent governs this feature's dependency boundary.

User clarification establishes that HiddenGate_B1_5 is currently a textured wall without
an opening mechanic. This is supplied design/current-state evidence, not a new runtime test.

## User-Approved Clarification Record

- **Q1 resolved — legacy compatibility**: Retain the narrow explicitly identified old
  standalone B1/B2 test-checkpoint reset to continuous B1, without old-location migration,
  unrelated data deletion/reset, or resetting valid new-stage checkpoints (FR-009).
- **Q2 resolved — Hidden scope**: Preserve room/wall/collision/behavior/connections;
  allow necessary documented reference repairs only. Entrance remains deferred (FR-002).
- **Q3 resolved — death and restart state**: B1 clear and parkour unlock persist, including
  B2 death before activation. Apply the three approved death cases; application restart
  preserves activated checkpoint/clears/unlocks and restarts unfinished waves. Do not save
  individual enemy health or partial wave progress this sprint (FR-012/015/016/018).
- **Q4 resolved — activation**: Stand nearby, show prompt, press F, change marker color,
  display "Checkpoint activated." Progress is forward-only; floor arrival is insufficient
  (FR-008/017). Temporary markers suffice; final art remains deferred.
- **Fall safety**: Missing jumps causes no fall damage; no lethal falls or new hazards.
  Falling and retrying require playtests (FR-019).
- **B3 scope superseded**: No B3 access, round trips, or checkpoint acceptance this sprint.
  Preserve separate B3; B2 clear opens a placeholder gate behind a safe boundary with no
  B3 load (FR-004/005/020).
- **Actual map scope**: Foundation integration and B1/B2 spawns/checkpoints precede the
  ceiling/clearance, parkour completion, and wave-dependent B2 gate map tasks above.

## Dependencies, Questions, and Acceptance Blockers

- **D1 — wave completion interfaces**: Finite waves remain absent per the supplied audit.
  Coordinate B1/B2 completion with Duy for parkour unlock and B2 gate opening. Do not invent
  counts/composition/defeat rules or implement his systems. Real completion checks remain
  blocked until the dependency exists; a simulation is not gameplay verification.
- **D2 — clearance and movement coordination**: Ceiling/parkour repairs are subsequent map
  tasks. Potential Double Jump/ceiling effects remain unverified; playtest current abilities
  and coordinate with Bao. Any player movement change requires his prior approval.
- **D3 — runtime validation**: All gameplay acceptance remains unverified. No Godot loading,
  traversal, camera, fall/retry, checkpoint, death, save/restart, or containment checks ran
  in this documentation-only update. Existing defects remain blockers when they prevent acceptance.
- **D4 — reset and persistence interfaces**: Coordinate checkpoint identity, floor clear,
  unlock, unfinished-wave restart, and persistence responsibilities with Duy and the affected
  save/checkpoint reviewers. Approved outcomes are settled; interface support is not verified.
  Do not save enemy health/partial wave progress or choose additional wave rules.
- **D5 — subsequent map acceptance**: Ceiling clearance, completed parkour/retries, and
  B2-clear gate checks need the later map tasks. Track them separately from integration
  failures; completing the foundation does not satisfy SC-010/011.
- **Residual exception policy**: Missing/unknown save references outside explicitly identified
  legacy B1/B2 are not covered by Q1's reset approval. If encountered, record the case for
  an explicit handling decision, preserve unrelated data, and do not allow B3 to load.
  This is an exception boundary, not an unresolved Q1-Q4 gameplay rule.

Q1-Q4 are resolved; no active clarification markers remain. Exact wave definitions stay
with Duy's work, not invented here. Interface availability and runtime evidence remain
completion dependencies. Record each blocker with affected requirement, evidence, owner,
and required verification or decision. Stop before planning or implementation.
