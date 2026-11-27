---
description: "Reviewable tasks for continuous B1/B2 integration in existing Prototype 1"
---

# Tasks: Continuous B1/B2 Basement Stage Integration

**Input**: Approved spec.md, plan.md, research.md, data-model.md,
contracts/stage-progress.md, quickstart.md, and constitution v1.0.0.
**Branch**: `basement-split-floors` | **Created**: 2026-11-05
**Status**: T001-T009 complete; T010 partial (prior headless checks passed; Lam reports
testing basement_b1, basement_b2 and basement_full with no major issues observed;
detailed acceptance checks remain unverified). T011 partial, Quan sign-off pending.
T012 complete under Lam's explicit slice authorization/review decision; no Quan/Bao agreement
claimed. T014-T021 implemented and independently checked; T013 partial (current-slice suites
pass, later wave coverage pending). T025/T026 partial: isolated runtime checks pass but
visual/HUD issue BUG-003 and manual checks remain; Lam reports successful manual activation.
T034 baseline measurements partial; BUG-004 reproduced/open. Later ceiling/parkour
construction and wave groups NOT RUN. See validation.md.
**Sprint**: Nov 4-7 map scope; final build deadline 2026-12-15.

## Format: `[ID] [P?] [Story] Description`

Each task gives candidate files, owner/reviewer, dependencies, acceptance criteria (AC),
and verification (V). Paths are repository-relative. Proposed filenames/APIs are not existing
implementations. [P] permits different-file work after listed prerequisites, not automatic agents.

## Path Conventions and Ownership

Use existing levels/, scripts/, scenes/, ui/, tests/, assets/ structures. Lam implements
map integration with Quan's collaborative review. Shared manager/input/save work requires an
identified maintainer/reviewer before editing. Bao's player systems and Duy's enemy/wave
systems are outside Lam's implementation tasks. Coordination requests are not assigned
teammate commitments. Reuse assets; preserve all existing changes, docs and tracked caches.
No generators, unrelated libraries/art, branch changes, commits, pushes or automatic implement.

## Independent Result Semantics

Record each check as PASSED, FAILED, BLOCKED, or NOT RUN with evidence/reason. PASSED requires
execution meeting criteria; FAILED requires an observed violation. BLOCKED means that check's
own dependency/policy prevents execution or interpretation; NOT RUN means no attempt.
Separate structural, isolated scene, interaction, valid/legacy recovery, old-B3 recovery,
actual-wave and subsequent-map results. An unrelated blocked B3 fixture cannot invalidate
structural passes or fail that suite's exit status. Real structural failures still fail it.
Whole-feature acceptance stays incomplete while required checks remain blocked/failed/unrun.
This separation refines earlier quickstart combined-run wording; no all-pass aggregate may
hide blocked checks. Static findings, hypotheses and runtime observations remain distinct.

## Phase 1: Setup — existing-project review only

No new-project initialization, branches, dependency installation or generic scaffolding.

- [X] T001 Record the working-tree baseline in `specs/001-integrate-basement-stage/validation.md`, including hashes of `levels/level_1/basement_b3.tscn` and existing modified files.
  - Owner/reviewer: Lam / Quan. Dependencies: none.
  - AC: preserve current project.godot, KKD_library.tres, uid_cache.bin and all docs; identify pre-existing changes without cleanup.
  - V: structural Git status/diff/hashes; no gameplay launch.

- [X] T002 Record first-group scope/review boundaries in `specs/001-integrate-basement-stage/validation.md` against `plan.md`, `spec.md` and `contracts/stage-progress.md`.
  - Owner/reviewer: Lam / Quan. Dependencies: T001.
  - AC: confirm allowed scene-foundation scope and protected systems. Do not require old-B3 policy or Duy interfaces for independent scene preparation.
  - V: document review against FR-001-006/010/011/013/014; no tests.

## Phase 2: Foundational — safe validation prerequisite only

This phase gates launches, not static scene preparation after T002.

- [X] T003 Establish isolated validation conditions in `specs/001-integrate-basement-stage/validation.md`, following `quickstart.md` and inspecting `scripts/autoload/save_system.gd` read-only.
  - Owner/reviewer: Lam / Quan. Dependencies: T001-T002.
  - AC: locate compatible installed Godot/build and verify test-only state/path isolation before writes or saved continuation. No production startup/save changes, real-save deletion, F9 or compatibility blanket reset.
  - V: inspect harness lifecycle/isolation; unavailable engine blocks launch-dependent checks only. Do not run gameplay during task generation.

## Phase 3: US1 — Scene Foundation (P1)

### FIRST IMPLEMENTATION GROUP — T004-T011 ONLY

**Goal/MVP slice**: correctly named Stage retaining B1/B2/Hidden, excluding integrated
B3/GroundExit, valid references and terminal containment only where necessary.
**Allowed implementation paths**: levels/level_1/basement_full.tscn,
proposed tests/basement_integration_check.gd, and evidence in this feature's validation.md.
**Excluded changes**: startup/main scene, input, checkpoints/spawn repositioning, saves,
enemy/wave systems, player systems, ceiling repairs, completion gates and final/completed
parkour. Scripts/resources/separate B3 are read-only references. No project.godot/cache edits.
**Independent test**: structural suite and isolated no-save F6 smoke. No F5, death/recovery,
checkpoint or real-wave acceptance here. Later route obstruction is reported, not fixed here.

- [X] T004 [P] [US1] Define scene-only checks in proposed `tests/basement_integration_check.gd` for `levels/level_1/basement_full.tscn` before scene edits.
  - Owner/reviewer: Lam / Quan. Dependencies: T002; T003 before runtime.
  - AC: assert Stage/inheritance, direct singleton nodes, retained floors/Hidden, absent B3/GroundExit, valid resources/NodePaths/non-null obstacles, unchanged separate B3. No checkpoint/startup/recovery fixtures.
  - V: review expected current failures; later isolated structural execution. Missing engine is BLOCKED, not a fabricated failure/pass. Preserve historical test scripts.

- [X] T005 [P] [US1] Rename root Basement to Stage in `levels/level_1/basement_full.tscn` only.
  - Owner/reviewer: Lam / Quan. Dependencies: T002.
  - AC: retain Stage subclass and direct Player/CameraRig/Hud/Bullets/Spawn/transforms/resources; satisfy Node3DFactory ancestry without nested Stage roots.
  - V: structural root/path diff; runtime factory/singletons in T010. No spawn repositioning.

- [X] T006 [US1] Remove integrated B3/GroundExit from `levels/level_1/basement_full.tscn`, preserving `levels/level_1/basement_b3.tscn` unchanged.
  - Owner/reviewer: Lam / Quan. Dependencies: T005.
  - AC: retain B1/B2/B1_5/HiddenGate_B1_5/parkour content; remove only orphaned dependencies. No standalone active Stage composition or future-B3 door edits.
  - V: scoped scene/resource diff and separate-B3 hash; T009 assertions.

- [X] T007 [US1] Repair null Pathfinder obstacles and verify retained references in `levels/level_1/basement_full.tscn`.
  - Owner/reviewer: Lam / Quan. Dependencies: T006.
  - AC: remove null B1/B1_5 obstacle entries; resolve relative paths before repairs. Preserve Hidden geometry/wall/collision/behavior/connections; document necessary reference repairs. Inspect nested B1 map coverage, without shared Pathfinder/enemy rewrite.
  - V: structural node/resource/cell comparison and path resolution; navigation smoke T010. Report coverage defects rather than broadening scope.

- [X] T008 [US1] Inspect exposed terminal edge and add B2/SprintBoundary only where necessary in `levels/level_1/basement_full.tscn`.
  - Owner/reviewer: Lam / Quan. Dependencies: T006-T007.
  - AC: smallest local StaticBody3D/CollisionShape3D/existing-resource containment; no Door/load target, damage, hazard, completion gate, ceiling or parkour tuning. If existing containment suffices, document evidence without unnecessary edits.
  - V: structural collider/resource diff; T010 Godot containment with current abilities. Hidden/shared libraries unchanged.

- [X] T009 [US1] Execute focused structural checks in `tests/basement_integration_check.gd`, recording `specs/001-integrate-basement-stage/validation.md`.
  - Owner/reviewer: Lam / Quan. Dependencies: T004-T008; T003 for engine checks.
  - AC: per-assertion reference/singleton/Hidden/B3 preservation results; no old-B3 fixture in this suite and no dependency on its policy.
  - V: static checks and isolated headless scene checks when available; separately report PASSED/FAILED/BLOCKED/NOT RUN. Headless results are not playtests.

- [ ] T010 [US1] Perform isolated no-save F6 Godot validation of `levels/level_1/basement_full.tscn`, recording `specs/001-integrate-basement-stage/validation.md`.
  - Resume evidence (2026-11-05): Lam reports reviewing expected scene changes and testing basement_b1, basement_b2 and basement_full with no major issues observed. These are Lam's observations, not per-case acceptance; detailed camera/movement/factory/navigation/containment checks remain unverified. Prior headless passes retained.
  - Owner/reviewer: Lam / Quan. Dependencies: T003, T009 applicable structural failures resolved.
  - AC: scene load, one Player/CameraRig/Hud/registration, camera/visibility, existing factory/navigation smoke, terminal containment; no new load/spawn/navigation errors in exercised scope. No F5, deaths, checkpoints or wave implementation.
  - V: Godot build/steps/results. Record pre-existing/regression/unknown route blockers separately; blocked traversal does not authorize player/ceiling/parkour edits here.

- [ ] T011 [US1] Review first-group diff and evidence in `specs/001-integrate-basement-stage/validation.md`, then stop at the group boundary.
  - Resume evidence (2026-11-05): partial handoff updated with Lam's observations and existing preservation evidence. No Quan review/sign-off supplied; user authorizes the next bounded slice subject to documented shared-file agreement.
  - Owner/reviewer: Lam / Quan. Dependencies: T005-T010 attempted with honest statuses.
  - AC: only allowed files changed; preserved separate B3/Hidden/libraries/caches/pre-existing work. Independent structural passes survive unrelated blocked checks. No full-feature/US1 completion claim from this partial foundation.
  - V: Git diff/hashes, result ledger and reviewer sign-off or explicit blockers; no automatic continuation to T012.

## Phase 4: US2 — B1/B2 Spawns and Checkpoints (P1)

**Goal**: nearby-F interaction, forward-only progress, narrow legacy compatibility and supported
startup/recovery. Independent interaction/valid fixtures do not depend on old-B3 policy;
actual rounds require coordinated interfaces. This phase is outside the first group.

### Shared review and focused test preparation

Current slice review decision supersedes older missing-reviewer/task-specific gates:
Lam explicitly authorizes and will review T012-T021 shared-file changes. No Quan/Bao
agreement or completed teammate code review is implied. Constitution I still protects
their owned systems, which are unchanged. See current authorization/evidence in validation.md.

- [X] T012 [US2] Identify shared manager/input/save reviewer and boundaries in `specs/001-integrate-basement-stage/validation.md` for `project.godot` and `scripts/autoload/game_manager.gd`.
  - Current evidence: Lam is named reviewer and explicitly authorizes this bounded phase; earlier BLOCKED disposition below is historical. No protected owner-system edits required.
  - Resume disposition (2026-11-05): attempted/BLOCKED. No named shared maintainer or actual shared-reviewer/Quan/Bao agreement recorded. Exact proposed boundary and outstanding decision recorded in validation.md; no dependent edits begun.
  - Owner/reviewer: Lam coordinates / Quan and named shared maintainer; Bao input-impact review. Dependencies: T011 handoff.
  - AC: actual reviewer agreement before shared edits; no inferred ownership or authorization to modify protected systems. Old-B3 policy not needed for independent review.
  - V: documented file-impact review; shared edits BLOCKED until reviewer identified.

- [ ] T013 [P] [US2] Prepare independent suites in proposed `tests/basement_checkpoint_check.gd` from `data-model.md` and `contracts/stage-progress.md`.
  - Current evidence: partial; fixture/interaction/recovery suites implemented and executed in disposable copy. 55 fixture checks, 24 headless interaction checks (26 with captures), 55 damage/dead-state recovery checks pass. Old-B3 recovery remains separately BLOCKED; real-wave coverage waits for T022-T024 and was not implemented.
  - Owner/reviewer: Lam / Quan/shared reviewer. Dependencies: T012; T003 before runtime.
  - AC: separate interaction/rank, supported recovery, legacy B1/B2, old-B3 refusal/recovery and real-wave results; sentinel unrelated fields. Verify "b1_start -> b1/1, b2_start -> b2/2; not trusted from arbitrary saved rank" and "B2 -> B1 is rejected without saving or success feedback."
  - V: review before implementation; no real-save writes or invented fallback; blocked old-B3 recovery cannot fail independent suites.

- [X] T014 [P] [US2] Add narrow basement checkpoint acceptance/rank boundary in `scripts/autoload/game_manager.gd`.
  - Current evidence: identity/rank, UID idempotence, lower/foreign/duplicate/wrong-owner rejection, no-save rejection and stock-setter bypass/unrelated-stage fixtures pass.
  - Owner/reviewer: Lam within agreed boundary / shared reviewer/Quan. Dependencies: T012.
  - AC: canonical stage/declared IDs; "b1_start -> b1/1, b2_start -> b2/2; not trusted from arbitrary saved rank"; "B2 -> B1 is rejected without saving or success feedback." Foreign requests rejected, same-current idempotent; unrelated stages unchanged.
  - V: T013 identity/rank fixtures. Proposed request API is not existing until implemented/verified; no player/enemy changes.

### Local checkpoint placement and interaction

- [X] T015 [US2] Create proposed `levels/objects/checkpoint/basement_checkpoint.tscn` and `levels/objects/checkpoint/basement_checkpoint.gd` using existing visuals and InteractiveArea3D.
  - Current evidence: local variant implemented; real input dispatch/physics overlap, acceptance-only exact feedback/tint and no-arrival behavior pass; rendered captures inspected. T025 whole visual/HUD acceptance remains partial.
  - Owner/reviewer: Lam / Quan; Bao input consultation. Dependencies: T014.
  - AC: local variant replaces stock auto-contact behavior; reuses helm/detector/Spawn. Nearby F prompt, eligible request, then local tint and exact "Checkpoint activated." Label3D only after acceptance. Guard dead/dialogue eligibility locally; no Player API/second HUD/final art.
  - V: structural no-auto-activation connection review, T013 fixtures, T025 playtests. Do not trust helper's absent can_interact assumption.

- [X] T016 [US2] Establish B1 default placement and B1/B2 checkpoint instances in `levels/level_1/basement_full.tscn`.
  - Current evidence: Stage ownership/group/unique IDs verified; B1 default/B1 Spawn (-3,1.2,14), B2 Spawn (49,7.2,5). Downward physics rays, capsule settling, startup/death placement and camera snap pass in copied scene.
  - Owner/reviewer: Lam / Quan. Dependencies: T015, T011.
  - AC: reconcile root Player/Spawn on supported B1 surface; b1_start/b2_start "unique in active Stage"; owner "Active Stage, not an inherited visual's foreign floor root." Supported child Spawn/group; validate transforms instead of blindly copying split coordinates. No B3 checkpoint.
  - V: structural ownership/IDs/transforms; Godot support/camera T025-T026. Player scripts/colliders unchanged.

- [X] T017 [US2] Add only missing interact-to-physical-F binding in `project.godot`.
  - Current evidence: one physical-F mapping added; existing plugin/input edits retained. Real F dispatch, echo/repeated F, synthetic dialogue/dead and overlapping-checkpoint cases pass; other live dialogue/interactable cases remain manual T025 checks.
  - Owner/reviewer: Lam within approved shared scope / shared reviewer/Bao input review. Dependencies: T012, T015.
  - AC: one interact/F mapping; preserve other input/plugin edits; main-scene change only in T021. No remapping of approved F or other player actions.
  - V: input-map diff and T025 repeated-F/dialogue/overlap playtests; static no-direct-conflict finding is not runtime proof.

### Save and recovery integration — separate result lanes

- [X] T018 [US2] Preserve unrelated loaded payload at `scripts/autoload/game_manager.gd` save boundary, reusing `scripts/autoload/save_system.gd` unchanged.
  - Current evidence: nested sentinel, unknown fields and unrelated/earned flags survive synthetic activation and compatibility round trips; serializer/version unchanged. BUG-001 recorded as fixed in scope.
  - Owner/reviewer: Lam within approved scope / shared reviewer/Quan. Dependencies: T014, T013.
  - AC: merge owned fields/flags, retain unknown top-level values/unrelated flags; keep version 1/serializer. "Do not serialize enemy health, partial-wave indices/counts, or individual enemies."
  - V: sentinel-field round-trip fixtures/diff; no save rewrite, version bump, deletion or blanket reset.

- [X] T019 [US2] Add explicit narrow legacy B1/B2 checkpoint reset in `scripts/autoload/game_manager.gd`.
  - Current evidence: four exact path/UID plus known-ID pairs reset only the checkpoint pair; valid continuous IDs retained, wrong-ID/lookalike/missing/B3 negatives not reset. Synthetic main-scene launches restore legacy B1/B2 at B1 default.
  - Owner/reviewer: Lam within approved scope / shared reviewer/Quan. Dependencies: T018.
  - AC: exact research R4 standalone paths/UIDs; only old test checkpoint pair -> continuous B1/default empty ID. "Do not apply substring/basename matching or reset valid continuous-stage B1/B2 IDs." Preserve unrelated data/clears/unlocks. B3/unknown references excluded.
  - V: path/UID positives and valid-new/sentinel negatives in T013. Old-B3 recovery policy is not a dependency for this classifier.

- [X] T020 [US2] Add B3 load refusal at existing boundary in `scripts/autoload/game_manager.gd`.
  - Current evidence: direct path/UID, startup and respawn callers refuse with zero B3 loads and preserved state/file; no success/fallback continuation registration. BUG-002 refusal fixed; T027 recovery policy remains BLOCKED, not a pass.
  - Owner/reviewer: Lam within approved scope / shared reviewer/Quan. Dependencies: T012, T013.
  - AC: reject known B3 path/UID before load-state mutation; cover startup/death/interaction callers. Preserve save/data; no fallback, remap, deletion or new user policy; unrelated supported flows intact.
  - V: refusal/unchanged-data fixtures independent of recovery; zero-load check PASSED/FAILED, recovery outcome separately BLOCKED in T027.

- [X] T021 [US2] Align supported startup/recovery in `project.godot` and `scripts/autoload/game_manager.gd` to continuous stage.
  - Current evidence: main scene/FIRST_STAGE agree; actual main-scene launches with synthetic no-save/B1/B2/legacy fixtures and six independent damage/dead-state recovery cases pass placement/camera/health checks. T026 visual/manual acceptance remains partial (BUG-003); no actual-wave reset claim.
  - Owner/reviewer: Lam within approved scope / shared reviewer/Quan. Dependencies: T016-T020; serialize shared edits.
  - AC: main scene/FIRST_STAGE agree; no-save/B1/B2/approved legacy restore correct spawn, preserve deferred loading/health/camera behavior. No implicit old-B3-to-default redirect.
  - V: structural path/UID and supported F5/respawn checks T026. B3-specific recovery remains T027; its blocked fixture does not invalidate supported results.

### Coordination dependencies and actual round-state integration

- [ ] T022 [US2] Record proposed completion/reset/persistence handshake and review status in `specs/001-integrate-basement-stage/contracts/stage-progress.md` and `validation.md`.
  - Owner/reviewer: Lam coordinates / Quan, Duy for interface agreement, shared reviewer. Dependencies: T012; independent of checkpoint implementation.
  - AC: distinguish existing flags/EnemyZone timer from proposed completion/restore/restart/readiness APIs. Agree pre-child-spawn initialization, durable keys and once-only reset. Missing agreement/provider is BLOCKED, not an existing API or teammate commitment.
  - V: joint contract record; no edits to Duy's producer files, wave counts/composition/defeat definitions or enemy behavior.

- [ ] T023 [US2] Add map-side proposed `levels/level_1/basement_progress_bridge.gd`, its Stage child in `levels/level_1/basement_full.tscn`, and narrow `scripts/autoload/game_manager.gd` flag adaptation.
  - Owner/reviewer: Lam consumer only / Quan, Duy interface review, shared reviewer. Dependencies: T018, T022 agreed interface; provider availability before production connection; scene edits after T016.
  - AC: genuine b1/b2 notifications; restore clears/unlocks before provider starts; approved unfinished-round reset once. "B1 clear and parkour unlocked advance together and remain true across death/restart." Key/API names stay proposed until agreed. No alive_count-clear inference, timer suppression, wave manager or producer edits.
  - V: explicitly synthetic adapter fixtures may pass independently; actual lifecycle T028 waits for provider. No dummy production wave implementation.

- [ ] T024 [US2] Extend `tests/basement_checkpoint_check.gd` with durable-state/reset-request checks, recording `specs/001-integrate-basement-stage/validation.md`.
  - Owner/reviewer: Lam / Quan, Duy contract review, shared reviewer. Dependencies: T013, T023 agreed consumer implementation; real provider unnecessary for isolated fixtures.
  - AC: approved death/restart matrix, persistent clears/unlocks, once-only requests, no saved enemy health/partial waves. Test doubles never prove genuine gameplay completion.
  - V: fixture PASSED/FAILED separate from provider-dependent BLOCKED checks; no enemy/wave logic in adapter tests.

- [ ] T025 [US2] Playtest nearby-F interaction in `levels/level_1/basement_full.tscn`, recording `specs/001-integrate-basement-stage/validation.md`.
  - Commit handoff observation: Lam reports successful manual checkpoint activation. Floor-specific steps/build/isolation details were not supplied; this does not establish recovery/HUD acceptance or close BUG-003. Task remains partial/unchecked.
  - Current evidence: partial; automated isolated headless and rendered input/physics playtests pass, captures inspected. BUG-003 flags missing rendered B2 health bar; human-controlled approach/camera/real dialogue/other-interactable overlap checks remain unverified.
  - Owner/reviewer: Lam / Quan; Bao consulted for input/player issues. Dependencies: T003, T014-T017 and applicable structural checks.
  - AC: supported ownership/spawn, prompt/F/tint/exact message; no arrival activation; B1 cannot replace B2. Repeated F/overlap/dialogue/dead cases cause no unintended action; one HUD.
  - V: isolated Godot interaction/camera evidence. No real-wave provider or B3 policy prerequisite for this lane; report limitations independently.

- [ ] T026 [US2] Validate supported no-save/B1/B2/legacy continuation/recovery using `tests/basement_checkpoint_check.gd` and Godot, recording `specs/001-integrate-basement-stage/validation.md`.
  - Current evidence: partial; supported fixtures, actual main-scene process launches and damage/dead-state reloads pass. Rendered B2 player/marker/support captured but health bar absent (BUG-003); manual visual recovery checks remain pending. Separate T027/T028 are not passed.
  - Owner/reviewer: Lam / Quan/shared reviewer. Dependencies: T003, T016-T021.
  - AC: F5/death/restart use correct continuous-stage location; valid checkpoints/unrelated data preserved; legacy reset narrow. Stage/location success does not claim wave resets or old-B3 recovery.
  - V: isolated supported fixture suites and Godot respawn/camera; separate PASSED/FAILED/BLOCKED results from T027/T028.

- [ ] T027 [US2] Validate old-B3-save recovery only after explicit user policy is recorded in `specs/001-integrate-basement-stage/validation.md`, using `tests/basement_checkpoint_check.gd` and `scripts/autoload/game_manager.gd` as scoped candidates.
  - Owner/reviewer: Lam records/validates / user decides policy, shared reviewer/Quan. Dependencies: policy NOT YET PROVIDED, T020, separately reviewed policy-sized change if needed.
  - AC: currently BLOCKED; preserve/report valid B3-save conflict. Choose no fallback/reset/migration now. Once approved, verify only that policy with zero B3 loads; unknown out-of-set cases need separate decisions.
  - V: isolated old-B3 lane; missing policy is BLOCKED, not a structural failure. No edge from this task to independent scene, valid-fixture or geometry completion.

- [ ] T028 [US2] Verify actual approved death/reset/persistence in `levels/level_1/basement_full.tscn`, recording `specs/001-integrate-basement-stage/validation.md`.
  - Owner/reviewer: Lam map validation / Quan and Duy interface review, not producer assignment. Dependencies: T022 agreed/available provider, T023-T026.
  - AC: pre-B1-clear death -> B1/restart B1; B2 before activation -> B1/restart unfinished B2, retain B1 clear/unlock; after activation -> B2/restart unfinished B2. Restart retains checkpoint/clears/unlocks, restarts unfinished floors, not saved health/partial waves; cleared floors remain clear.
  - V: actual Godot gameplay/restart evidence, BLOCKED without finite-wave/readiness support. Mocks cannot satisfy this task; T027 is not a prerequisite.

## Phase 5: US3 — Subsequent B2 Gate and Safe Terminal (P1)

**Goal/independent test**: containment and zero loads can be checked without real B2 waves;
actual completion gate opening needs provider support. Separate B3 stays preserved; no B3
checkpoint/round-trip acceptance. This phase is outside the first group.

- [ ] T029 [P] [US3] Define gate/containment checks in proposed `tests/basement_gate_check.gd` from `contracts/stage-progress.md`.
  - Owner/reviewer: Lam / Quan. Dependencies: T011; T022 agreement before interface-binding assertions.
  - AC: closed/open gate and always-effective independent boundary, no loading Door/target, idempotent restored state, separate-B3 preservation; mark synthetic callbacks explicitly.
  - V: pre-implementation test review; keep structural/zero-load fixtures separate from real-wave gating and old-B3 recovery.

- [ ] T030 [P] [US3] Create map-only gate consumer in proposed `levels/level_1/basement_progress_gate.gd`.
  - Owner/reviewer: Lam / Quan; Duy agreed interface review. Dependencies: T022 interface agreement, not producer commitment.
  - AC: only agreed clear/snapshot-driven local gate visibility/collision; never change_stage or wave logic. Reusable for B1 access/B2 placeholder without global bus.
  - V: T029 isolated state checks; production binding remains T032. Different-file work may overlap T029 after prerequisites.

- [ ] T031 [US3] Add B2/CompletionGate separately from B2/SprintBoundary in `levels/level_1/basement_full.tscn`.
  - Owner/reviewer: Lam / Quan. Dependencies: T011, T030; serialize all scene writes.
  - AC: reuse visuals/local resources; gate closed while unfinished, boundary independent in both states. No B3 Door/destination, Hidden or shared-library change.
  - V: structural collider/resource diff and T029 fixtures; actual containment in T033.

- [ ] T032 [US3] Connect B2 completion/restored state via `levels/level_1/basement_progress_bridge.gd` and `levels/level_1/basement_full.tscn`.
  - Owner/reviewer: Lam consumer / Quan, Duy interface review. Dependencies: T023 actual provider connection, T031.
  - AC: genuine B2 clear opens placeholder; persisted clear restores gate; boundary remains effective; zero B3 loads. Missing provider blocks connection, not independent placeholder preparation.
  - V: fixture contract checks and actual event trace; no wave producer modifications.

- [ ] T033 [US3] Playtest terminal gate/containment in `levels/level_1/basement_full.tscn`, recording `specs/001-integrate-basement-stage/validation.md`.
  - Owner/reviewer: Lam / Quan; Duy real-completion review. Dependencies: T003, T029-T032 for real gate cases; boundary-only checks after T031 can run without provider.
  - AC: before/after genuine clear/restart, boundary resists traversal/repeated F/push/jump; no B3 load and separate scene unchanged. Blocked real gate checks do not erase containment passes.
  - V: separate structural, boundary, synthetic-gate, real-gate and restart Godot results. No B3 travel/player changes/hazards.

## Phase 6: US4 — Subsequent Ceiling and Safe Parkour (P1)

**Current planning-only replan (2026-11-05):** see `third-implementation-plan.md`,
`clearance-measurements.md` and `clearance-candidates.svg`. Two passes: first safe
ceilings/containment and ceiling-contact recovery; then a separately chosen parkour
opening/route/landing/retry. Lam/Quan must choose the route before construction.
No scene/script edits authorized by this replan; no geometry task marked complete.

**Goal/independent test**: measured clearance, completed safe route and misses/retries can be
validated separately; genuine clear/death/restart gates need Duy interfaces. Geometry tasks
do not assign Bao or Duy implementation. This phase is outside the first group.

- [ ] T034 [P] [US4] Measure route clearance in `levels/level_1/basement_full.tscn`, recording `specs/001-integrate-basement-stage/clearance-measurements.md`; inspect `scenes/player/player.tscn` and jump/fall states read-only.
  - Replan evidence: partial; four under-B2 softlocks reproduced plus B1/B2 controls and rendered repeat; floor/backface/collider bounds, headroom and candidate references measured. Full ceiling/route sweep and Lam/Quan review remain pending.
  - Owner/reviewer: Lam / Quan; Bao state interpretation consultation. Dependencies: T011; T003 for runtime measurements.
  - AC: obstruction node/cell/item/transform, underside, takeoff/landing/body sweep/screenshots. Body ~1.698/.800, jump12/gravity24/ideal rise3 are static/inference, not wall multiplier or verified target. Measure actual second-jump timing.
  - V: distinguish dimensions/inference from Godot observations. Missing engine blocks runtime measurements only; no B3 policy dependency.

- [ ] T035 [US4] After review, implement pass-1 measured local B1/B2 ceiling/underside and perimeter containment in `levels/level_1/basement_full.tscn`, following `third-implementation-plan.md`.
  - Owner/reviewer: Lam / Quan. Dependencies: T034 measured evidence/review.
  - AC: smallest scene-local solid underside/roof/boundary volumes over verified walking footprints; no floor-spacing change, opening or route selection. Avoid insufficient headroom over upper prototype crate; any temporary guard needs explicit reviewed footprint. Preserve Hidden/dependencies/libraries/checkpoints; no height multiplier or player edits. Player-rooted blocker requires Bao coordination, not Lam edits.
  - V: before/after geometry/resource/navigation review; actual clearance T038 before any fixed claim.

- [ ] T036 [US4] Complete route and safe missed-jump landing/retry surfaces in `levels/level_1/basement_full.tscn` B1/World/B2-Parkour and necessary B1/B2 route cells.
  - Owner/reviewer: Lam / Quan. Dependencies: recorded Lam/Quan opening/route decision, focused T034 route measurements and T038 pass-1 recovery acceptance; serialize scene writes with T031-T032/T037.
  - AC: separate approach through chosen deliberate opening, full supported B2 landing outside rim, intact B1 catch floor and walkable safe retry. Current abilities suffice; misses introduce no fall damage/lethal falls/new hazards. No assumed teleport, Hidden entrance/final art/player edits. Candidates A/B are proposals, not approved construction.
  - V: structural route/collider diff and T039 Godot miss/retry evidence; player/timing changes need Bao approval outside these tasks.

- [ ] T037 [US4] Add B1 parkour-access gate in `levels/level_1/basement_full.tscn`, reusing `levels/level_1/basement_progress_gate.gd` and `basement_progress_bridge.gd`.
  - Owner/reviewer: Lam consumer / Quan, Duy interface review. Dependencies: T030, T036; real binding requires T023 provider.
  - AC: closed before B1 clear, open after genuine/restored clear; "B1 clear and parkour unlocked advance together and remain true across death/restart." No wave logic, Hidden wall changes or new ability.
  - V: synthetic consumer fixtures separate from production completion/persistence in T040; BLOCKED if provider missing.

- [ ] T038 [US4] Playtest ceiling/clearance in `levels/level_1/basement_full.tscn`, recording `specs/001-integrate-basement-stage/clearance-measurements.md` and `validation.md`.
  - Owner/reviewer: Lam / Quan; Bao player-behavior consultation. Dependencies: T003, T035 reviewed pass-1 changes; no dependency on T036 route construction.
  - AC: ordinary/eligible second-jump and genuine ceiling contact -> fall away -> supported landing -> normal walk/jump again without teleport/death/reload/FSM reset. Check seams/high ground, all movement directions, repeated jumps and perimeter containment with unchanged player; record health/camera/navigation/spawn results and distinguish baseline issues. No fixed claim until this passes.
  - V: actual Godot measurements/steps. Blocking player bugs are reported, not changed without Bao approval.

- [ ] T039 [US4] Validate intentional misses and safe retries in `levels/level_1/basement_full.tscn`, recording `specs/001-integrate-basement-stage/validation.md`.
  - Owner/reviewer: Lam / Quan. Dependencies: T003, T036, T038 for affected segments.
  - AC: miss each gap; observe landing/retry and unchanged health from falling; no trap/lethal fall/new hazard. Distinguish enemy damage without enemy/player edits; unknown damage source blocks that claim.
  - V: Godot health/screenshots/route evidence; synthetic access may isolate geometry but cannot prove genuine B1 completion.

- [ ] T040 [US4] Validate genuine B1 access/unlock persistence and completed continuous route in `levels/level_1/basement_full.tscn`, recording `specs/001-integrate-basement-stage/validation.md`.
  - Owner/reviewer: Lam map validation / Quan and Duy interface review. Dependencies: T023/T028 provider/lifecycle evidence, T037-T039.
  - AC: before clear locked, genuine clear unlocks, B2 death before/after activation and restart preserve clear/unlock; B1/parkour/B2 traversal has zero load/re-registration, one runtime player/camera/Hud/stage, no new navigation errors.
  - V: actual Godot clear/death/restart/traversal, not synthetic wave success; missing provider blocks these cases only.

## Phase 7: Polish & Cross-Cutting Concerns — Evidence Only

No unrelated art, optimization, cleanup, generic tests, commits or deployment.

- [ ] T041 Consolidate requirement coverage and check statuses in `specs/001-integrate-basement-stage/validation.md` against `spec.md` and `quickstart.md`.
  - Owner/reviewer: Lam / Quan/relevant shared/interface reviewers. Dependencies: T011 and available later evidence; reporting can proceed with blocked tasks open.
  - AC: map FR-001-020/SC-001-011 to evidence or explicit FAILED/BLOCKED/NOT RUN. B3 policy/wave/map blockers never erase independent passes or disappear into all-pass.
  - V: evidence/document review with separate suite summaries/exit semantics; no redundant broad gameplay rerun.

- [ ] T042 Review final scoped diff/preservation ledger in `specs/001-integrate-basement-stage/validation.md` and `tasks.md`, then report without commit/push.
  - Owner/reviewer: Lam / Quan/shared reviewer where affected. Dependencies: T041 and slices being handed off.
  - AC: preserve existing modifications/Hidden/separate B3/libraries/caches/protected systems; check off only verified tasks and leave blocked tasks open. Foundation handoff is not whole-sprint acceptance.
  - V: Git diff/hashes/evidence review; no generators, branches, automatic implement, commits or pushes.

## Dependencies & Execution Order

```text
T001 -> T002 -> T004/T005 -> T006 -> T007 -> T008 -> T009
         T003 isolation -----------------> T009(runtime)/T010 -> T011 STOP
T011 -> T012 -> T013/T014 -> T015-T017 local checkpoints/spawns/input
                       -> T018-T021 payload/legacy/routing -> T026 supported recovery
T022 agreement + provider -> T023 consumer -> T024 fixtures / T028 actual rounds
explicit old-B3 policy -> T027 ONLY; no edge to independent structural/valid/geometry lanes
T011 + T022 -> T029/T030 -> T031 -> T032(provider) -> T033 actual gate checks
T011 -> T034 -> review -> T035 -> T038 (pass 1, independent of route choice)
T038 + recorded Lam/Quan route/opening decision -> T036 -> T039 (pass 2)
T030 + T036 + T023 provider -> T037 -> T040(actual lifecycle T028)
available evidence -> T041 -> T042; required blocked tasks remain open
```

T001-T003 are review/isolation, not project initialization. T003 gates runtime only.
Shared review gates shared edits only. T022 coordinates, never promises teammate implementation.
US1 foundation is independently checkable; complete physical-route acceptance also needs US4.
US2 interaction/valid fixtures do not depend on old B3 recovery. US3 containment is independent
of real B2 completion; genuine gate opening is not. US4 measurements/geometry are independent
of waves, but genuine gate/reset proof is not. Later task IDs do not fabricate dependencies.

## Parallel Examples and File Conflicts

- US1: after T002, T004 test definition and T005 root edit use different files. Serialize
  T005-T008 scene edits; checks run against a stable scene.
- US2: after T012, T013 tests and T014 manager boundary use different files. T022 coordination
  can proceed alongside local work; serialize GameManager/project.godot edits and review jointly.
- US3: after contract prerequisites, T029 test definition and T030 controller use different
  files. T031/T032 share scene/bridge with other stories; do not race those edits.
- US4: T034 measurement documentation can accompany US3 test/controller preparation on a
  stable scene. Serialize T035/T036/T037; run T038/T039 only against stable geometry. No safe
  independent parallel scene-edit pair exists within US4.

[P] requires named prerequisites and owners; it is not permission to launch agents or bypass
review. Never have simultaneous writers to basement_full.tscn.

## Implementation Strategy

1. Review/isolate, then prepare only FIRST IMPLEMENTATION GROUP T004-T011 and stop/report.
   Preserve separate passed, failed, blocked and unrun results. No automatic next group.
2. Later reviewed increments add checkpoint/spawn interaction, then narrow input/save/startup
   changes. Hold only old-B3 recovery for policy; supported fixtures remain independently useful.
3. Subsequent Nov 4-7 map work covers measured ceiling/route completion/safe retries and
   wave-gated consumers. No unsupported wall scaling or player/enemy implementation.
4. Genuine wave/reset/persistence/gate acceptance waits for coordinated provider availability;
   no synthetic callback closes those tasks. Report incomplete sprint work honestly.

**Totals**: 73 tasks: setup/foundational 3; US1 8; US2 17; US3 5; final review 2; F6 startup follow-up 1; camera visibility follow-up 1; Skill Tree HUD follow-up 1; Dark Fairy HUD follow-up 1; player stair traversal follow-up 1; player sword/status FX follow-up 1; floating player sword follow-up 1; player dash trail follow-up 1; dash trail visibility tuning 1; dash afterimage alpha blending fix 1; Dark Fairy health-bar style follow-up 1; player ultimate cinematic follow-up 1; front-facing ultimate cut-in pose follow-up 1; ultimate camera zoom-only follow-up 1; Skill Tree size follow-up 1; lightning enemy status VFX follow-up 1; player HUD feedback follow-up 1; player HUD presentation polish follow-up 1; HUD readability/menu layer follow-up 1; Wind ultimate redesign follow-up 1; Skill Tree alignment/status chip/ultimate glow follow-up 1; ultimate cast impact VFX follow-up 1; ice skill PVFX trial 1; Wind/Fire/Lightning active skill PVFX trial 1; Dark Fairy intro/defeat cut-in follow-up 1; Dark Fairy full-screen focus VFX follow-up 1; Lightning SFX differentiation follow-up 1; Dark Fairy camera focus follow-up 1; Skill Tree confirmation/scale restoration follow-up 1; Player skill speed and gravity follow-up 1.
**First group**: T004-T011, 8 scene-foundation/check tasks only.
**Current state**: T012 and T014-T021 are implemented; T013/T025/T026 remain partial and
T022-T042 remain open as recorded above. T043 is the focused F6 startup follow-up below;
T044 is a focused basement camera visibility follow-up. T045 is implemented with runtime visual/input verification pending. T047 has a player-only step-up implementation; required stair and movement regression checks remain unverified, so T047 stays open. T048 is implemented; Godot visual/skill checks remain NOT RUN, so T048 stays open. T049 is implemented; the floating sword animation remains visually unverified in Godot, so T049 stays open. T050 is implemented; the dash trail remains visually and directionally unverified in Godot, so T050 stays open. T051 increases trail opacity/density; visual tuning remains unverified in Godot, so T051 stays open. T052 corrects afterimage alpha blending; runtime visibility remains unverified, so T052 stays open. T053 applies the regular enemy health-bar styling to the Dark Fairy; runtime visual verification remains open. T054 is implemented with static review complete; camera/title/cast behavior remains unverified in Godot, so T054 stays open. T055 adds a front-facing idle pose during the ultimate cut-in; animation framing and restoration remain unverified in Godot, so T055 stays open. T056 removes camera orbit/translation; zoom framing and camera stability remain unverified in Godot, so T056 stays open. T057 expands the Skill Tree, and T058 changes lightning control effects to electricity; static implementation is recorded below, but Godot visual/input/status checks remain NOT RUN. T059 adds combat readiness/status feedback to the Player HUD; Godot visual and input checks remain NOT RUN.

**HUD follow-ups**: T060 is implemented with runtime visual review pending. T061 reduces buff/rage typography and puts the Skill Tree on the shared topmost menu layer; runtime menu stacking and readability remain NOT RUN, so T061 stays open.
**Wind ultimate follow-up**: T062 implements `ultimate_wind_2` as the 10-SP “Trăng Tối”; Godot runtime verification remains NOT RUN, so acceptance is still open.
**Presentation follow-up**: T063 implements the Skill Tree graph offset, compact buff chips and temporary element-colored screen/player glow after ultimate cut-ins; runtime visual verification remains NOT RUN, so acceptance stays open.
**Ultimate impact follow-up**: T064 adds stronger cast/impact effects to Wind, Fire and Lightning ultimates using the existing PVFX sheets; cinematic and gameplay values remain unchanged. Godot runtime visual review remains NOT RUN, so acceptance stays open.
**Ice PVFX trial**: T065 replaces only the active Ice cone and storm visuals with the local PVFX frost breath and ice spikes. Preserve Ice shield and Ice ultimate FX; visual compatibility remains to be checked in game.
**Other-element PVFX trial**: T066 replaces selected active Wind, Fire and Lightning cast effects with element-specific PVFX; combat behavior remains unchanged. Visual fit remains to be checked in game.
**Boss presentation follow-up**: T067-T068 and T070 are implemented with user-reported Duy approval; static review and git diff --check pass. Godot parse/import and visual/camera checks were not run, so T067-T070 remain open for in-game review.
**Lightning audio follow-up**: T069 assigns distinct existing sound clips and pitch/volume profiles to Lightning skills. Static path/route review is complete; runtime listening remains pending.

## Focused startup follow-up

- [ ] T043 Restore standalone F6 behavior for `levels/level_1/basement_full.tscn` when it is also `FIRST_STAGE`.
  - Current evidence: startup branch now checks for Godot's explicit `--scene` launch argument before attempting saved checkpoint continuation or checkpoint spawn placement. Runtime acceptance has not been verified.
  - Owner/reviewer: GameManager shared boundary / Lam, under the recorded T012-T021 startup/recovery review scope. Preserve distinction between implemented behavior, runtime verification, and reviewer agreement.
  - Scope: `scripts/autoload/game_manager.gd` and this task's validation/changelog record only. A Godot editor launch with an explicit `--scene` must skip saved-checkpoint continuation and saved spawn placement for that run; normal F5 startup must continue to restore the saved checkpoint. Do not clear, rewrite, or otherwise mutate the save during F6.
  - Acceptance: F6 on `basement_full.tscn` stays in that scene at its default spawn even when `save.json` points to `stage_1.tscn`/`village`; F5 still continues at the saved stage/checkpoint; legacy basement compatibility and unrelated saved progress remain unchanged.
  - Validation: isolated Godot F6 and F5 runs with a synthetic save and exact scene identity assertions, plus static review that no save mutation occurs in the F6 bypass. These checks are pending unless explicitly recorded in `validation.md`.

## Focused basement camera visibility follow-up

- [ ] T044 Show only the active basement floor and make its room ceiling see-through in `levels/level_1/basement_floor_visibility.gd`.
  - Owner/reviewer: Lam map scope / Quan review, preserving existing scene ownership and the open measured geometry work in T034-T038.
  - Scope: scene-local render visibility only. Keep floor heights, collision, navigation, movement, spawns, checkpoint/save flow, and the existing T034-T038 construction tasks unchanged. B1_5 retains its current secret-area rule.
  - Acceptance: outside stair connectors, jumping cannot change the active floor; inside a configured connector, ascending past its midpoint changes to the destination floor and descending back past it restores the source floor. B1_5 remains conditional on its secret area; the room ceiling no longer blocks the camera. Hiding render geometry must not change collision or navigation.
  - Validation: static review of connector marker/radius configuration, midpoint transitions, floor-level comparisons, and the B1 ceiling node, then Godot playtest of jumps outside connectors and ascent/descent through B1/B2 and B2/B3 connector midpoints; check camera sightlines and unchanged collision/navigation. Runtime checks remain pending unless recorded in `validation.md`.

## Focused HUD and Skill Tree presentation follow-up

- [ ] T045 Remove HUD and menu shortcut prose and present the complete Skill Tree inside one responsive open spellbook spread, using the user-added CraftPix magic-book art and page-turn animations.
  - Owner: Bao / Bao (user-requested Skill Tree and HUD presentation slice).
    - Scope: remove the `T: Cây kỹ năng` HUD prose and menu shortcut footer while retaining the skill-point count; add a clickable book icon in the existing skill toolbar with T key indication; keep the existing `skill_tree` input action; use the new CraftPix book art, open/close sheets, and left/right turning-pages sheets. Balance the Skill Tree across the open spread; enlarge element choices and skill nodes; add graph zoom controls; keep the left description box's geometry fixed while text wraps at a smaller size; remove redundant instructions from the tree area and retain only concise guidance on the left. Slightly shift the selected weapon tree right to balance it in the page. Keep the skill toolbar centered despite the HUD CanvasLayer transform, and name its expanded controller `player_hud.gd`. Do not change combat, progression, skills, input mappings, HUD health/rage behavior, or BUG-003 diagnosis.
    - Acceptance: skill-point count remains visible without shortcut instructions; the toolbar book icon is comparable in size to skill icons; the skill bar remains centered and slightly reduced at the configured HUD CanvasLayer scale; opening/closing and tab switches animate in the correct direction; both tabs remain centered without overflow; the selected weapon tree sits slightly right of its prior position without clipping; element choices are prominent and choosing one opens its existing tree; node hover updates the left description panel without changing its box geometry; zoom-in, zoom-out and reset work, with wheel zoom and middle-button pan; skill allocation behavior remains usable.
  - Validation: inspect changed source, referenced asset paths/regions, and diff whitespace. Godot visual/input playtest is NOT RUN unless separately requested. BUG-003 remains open unless independently reproduced/fixed with evidence.

## Focused Dark Fairy boss HUD presentation follow-up

- [ ] T046 Place the Dark Fairy boss health bar and phase label at the top center of the screen.
  - Owner/reviewer: Duy (Dark Fairy boss scene); approval is pending before changing the boss-owned scene.
  - Static finding: `scenes/enemies/darkfairy/darkfairy.tscn` already anchors `Bar` and `Name` horizontally at 0.5, but anchors both vertically at 1.0 (the bottom edge).
  - Scope: presentation-only anchor/offset changes to the `BossHUD/Bar` and `BossHUD/Name` nodes in `scenes/enemies/darkfairy/darkfairy.tscn`; do not change Dark Fairy logic, phases, health, attacks, or shared enemy health-bar behavior.
  - Acceptance: while engaged, both bar and phase label remain horizontally centered at the top with a visible margin at the configured viewport size; boss health tracking and phase text remain unchanged.
  - Validation: static scene/source review, diff whitespace check, and (after owner approval) a Godot visual check while the Dark Fairy HUD is visible.

## Focused player stair traversal follow-up

- [ ] T047 Allow the player to step over low stair risers without changing map colliders.
  - Owner/reviewer: Bao (player movement; user explicitly requested the fix).
  - Scope: player-only movement override in `scenes/player/player.gd`. Try a bounded step-up only when grounded horizontal movement is blocked, the raised path is clear, and a walkable landing surface exists within 0.75 world units. Do not edit shared `BaseCharacter`, enemy movement, GridMap data, stair mesh resources, navigation, or T044 render-visibility behavior.
  - Acceptance: the player can walk both up and down the pictured B1/B2 stairs without sticking on their risers; cannot step through walls, ceilings, or unsupported gaps; ordinary flat movement, jumping, landing, and enemies remain unchanged.
  - Validation: Godot playtest on the actual B1/B2 staircase in both directions, collision-debug review of the stair contact, and regression checks for flat movement, a wall, an unsupported edge, and jumping/landing. Record actual results; do not claim acceptance without the runtime pass.

## Focused player sword and status FX follow-up

- [ ] T048 Show the existing sword behind the player, hide it during attacks/skills, and add PVFX status visuals for burn, ice slow, and freeze.
  - Owner/reviewer: Bao (player combat and skill visuals; user-requested slice).
  - Scope: `scenes/player/player.tscn`, `scenes/player/states/skillstate.gd`, `scenes/player/player.gd`, and `scenes/player/battle_vfx.gd`; use the user-added PVFX spritesheets under `assets/effects/pvfx-foundry-thirteen-spritesheets/` and project-local Pixelfx exports under `assets/effects/pixelfx/`. Keep the existing sword node/texture and back transform. Do not modify enemy status/damage/movement logic, shared `BaseCharacter` behavior, slash scenes/sheets, `BattleVFX.shield`, or `BattleVFX.emberline_ring`.
  - Acceptance: the player sword is visible by default at its existing back mount; it stays hidden for player attacks and active/thrown skills, then returns when the corresponding action completes; burn and ice slow attach looping status visuals to the affected enemy for the existing status duration, freeze shows its hit effect, and refreshes do not create duplicate loops; damage, timing and movement rules remain unchanged.
  - Validation: inspect source paths, PVFX manifests/frame timing, sword mount, and status call sites; `git diff --check`. Godot runtime visual/skill checks are not run unless separately requested, so visual fit and hide/restore behavior remain unverified until a playtest.

## Focused floating player sword follow-up

- [ ] T049 Add a gentle idle hover and sway to the player's existing back-mounted sword so it reads as floating.
  - Owner/reviewer: Bao (player presentation; user clarification).
  - Scope: the existing player-only `scenes/player/weapon/blade.tscn` and a small attached animation script. Preserve the current back mount, sword asset, facing behavior, visibility suppression, attack/skill handling, and unrelated character animation.
  - Acceptance: while visible, the sword gently rises/falls and rocks around its existing resting transform; motion remains subtle, smooth, and continuous, and hiding it during attacks/skills continues to work.
  - Validation: inspect the base-transform-relative animation and `git diff --check`. Godot runtime visual tuning is NOT RUN unless separately requested; the final amplitude and placement remain subject to in-game review.

## Focused player dash trail follow-up

- [ ] T050 Leave a short afterimage trail behind the player during dash and use the existing dash-dust effect.
  - Owner/reviewer: Bao (player movement presentation; user-requested slice).
  - Scope: `scenes/player/states/dash.gd` and the player-owned helper in `scenes/player/battle_vfx.gd`; reuse the player's current animated `Sprite3D` for fading snapshots and the user-added PVFX `smoke/dash-dust` sheet. Do not change dash movement, duration, cooldown, invincibility, collision, or shared character behavior.
  - Acceptance: during a dash, a few short-lived tinted copies of the player's actual pose remain along the recent path, with a small dust trail; trail ends cleanly after the dash and follows the chosen dash direction. Regular movement and other combat effects remain unchanged.
  - Validation: inspect sprite-frame copying, dash state lifecycle, PVFX manifest frames/durations, and `git diff --check`. Godot visual/direction/lifecycle checks remain NOT RUN unless separately requested.

## Focused dash trail visibility tuning

- [ ] T051 Make the dash afterimages and dust more visible based on user feedback.
  - Owner/reviewer: Bao (player movement presentation; user-requested adjustment).
  - Scope: tune the existing T050 afterimage opacity/fade, emission spacing, and dash-dust scale/opacity in `scenes/player/states/dash.gd` and `scenes/player/battle_vfx.gd`. Preserve trail placement, dash movement and other gameplay values.
  - Acceptance: the trail reads clearly during a dash and fades shortly after, without obscuring the player or lingering as a persistent effect.
  - Validation: inspect tuned constants and `git diff --check`. Godot visual tuning is NOT RUN unless requested, so final strength/occlusion remains unverified.

## Focused dash afterimage alpha blending fix

- [ ] T052 Allow the tinted dash afterimages to use partial transparency.
  - Owner/reviewer: Bao (player dash presentation; user-reported missing afterimages).
  - Static finding: the player's source `Sprite3D` uses alpha-cut discard; the duplicated afterimages inherit that mode while also receiving partial alpha.
  - Scope: set standard alpha blending only on the temporary afterimage copies in `scenes/player/battle_vfx.gd`. Preserve the original player sprite's pixel-edge rendering and all dash gameplay values.
  - Acceptance: trail copies render with their configured tint/opacity and fade, while the base player sprite remains unchanged.
  - Validation: inspect copied sprite alpha mode and `git diff --check`. Godot visual confirmation remains NOT RUN unless requested.

## Dark Fairy health-bar style follow-up

- [ ] T053 Match the Dark Fairy's health-bar artwork and frame styling to regular enemies.
  - Owner/reviewer: Duy; user reports Duy approved this style change on 2026-11-09 (not directly confirmed by Duy).
  - Scope: change `BossHUD/Bar` to `TextureProgressBar` in `scenes/enemies/darkfairy/darkfairy.tscn`, reuse the texture/tint/nine-patch settings from `scenes/ui/enemy_health_bar.tscn`, and update the `boss_bar` type annotation in `scenes/enemies/darkfairy/darkfairy.gd`. Preserve the boss-specific bar size and current placement, phase label, and all other existing scene edits.
  - Acceptance: boss health fill uses the same red texture, dark backing, and nine-patch frame as regular enemy bars while still tracking boss health and phase behavior.
  - Validation: static compare of style properties, resource path, script node type, and `git diff --check`. Godot visual check is NOT RUN unless requested; final appearance remains unverified.

## Focused player ultimate cinematic follow-up

- [ ] T054 Add a shared ultimate cut-in that pauses gameplay, zooms the camera toward the player, shows a high-contrast elemental impact frame with the selected ultimate's name, restores the camera, then casts the ultimate.
  - Owner/reviewer: Bao (player combat and skill presentation; user-requested slice).
  - Scope: `scenes/player/player.gd`, `scenes/player/battle_vfx.gd`, a new player-owned `scenes/player/ultimate_cinematic.gd`, and the exported Pixelfx `impacts/impact-frame` sheet/metadata for the paused impact beat. Temporarily animate and exactly restore the active `Camera3D` transform/FOV. Do not edit `CameraRig`, ultimate damage/timing/effects, input maps, enemy behavior, or slash/ice-shield implementations.
  - Acceptance: a ready ultimate starts once; the game pauses while a short camera zoom and a black/white impact frame with its elemental accent and existing Vietnamese ultimate name play; camera transform/FOV are restored; the tree unpauses; then the captured ultimate casts once and applies its existing behavior. If no active camera is available, cast immediately without leaving the game paused. Cleanup must also unpause and restore the camera if the cinematic exits early.
  - Validation: static review of the gating/captured skill ID, process mode, pause/restore/early-exit paths, impact art and name/element mapping, then `git diff --check`. Godot playtest of all eight titles/elements, camera framing, cast-once behavior and interruption cleanup is required for runtime acceptance but is NOT RUN unless requested; report runtime behavior as unverified until performed.

## Focused front-facing ultimate cut-in pose

- [ ] T055 Show the player's front-facing idle animation while the ultimate cut-in runs, then restore the interrupted pose and direction.
  - Owner/reviewer: Bao (player presentation; user-requested follow-up to T054).
  - Static finding: scripts/base_character.gd maps "down" to the front (+Z, toward the camera); scenes/player/player_anims.tres defines idle_down as the front-facing idle animation. The player is paused during the cut-in, so its state machine will not process a deferred change_animation() call.
  - Scope: scenes/player/player.gd and scenes/player/ultimate_cinematic.gd only. Capture/restore the player's current and pending facing direction, animation name/position/play state, and sprite frame/flip; temporarily play idle_down and face down toward the camera. Do not modify animation assets, normal movement/combat state behavior, or cut-in timing/camera motion.
  - Acceptance: front-facing idle is visible from the start of the cut-in through the impact/title beat; after successful completion or abort, prior direction and animation state are restored before unpausing, and normal facing resumes without a state-machine mismatch.
  - Validation: inspect idle_down resource key/frame mapping and capture/restore logic, then git diff --check. A Godot playtest must verify front visibility through the zoom/impact and restoration from varied prior directions/animations; runtime checks are NOT RUN in this task, so T055 remains open pending visual verification.

## Focused ultimate camera zoom-only follow-up

- [ ] T056 Remove camera orbit and position movement from the ultimate cut-in; keep a steady FOV zoom in and out.
  - Owner/reviewer: Bao (player cinematic presentation; user-requested refinement of T054).
  - Scope: scenes/player/ultimate_cinematic.gd and this task's validation/changelog records only. Keep the camera at its original position and orientation throughout the cut-in; animate only FOV toward a tighter view and back. Preserve pause, front-facing pose, impact/title display, cast timing, and final camera restoration.
  - Acceptance: the camera does not circle, translate, or shake; the player remains framed from the existing camera angle while FOV zooms in for the cut-in and returns to its exact starting value before casting.
  - Validation: inspect the zoom methods to confirm only FOV changes and the full saved camera transform is restored, then git diff --check. Godot playtest of framing, steadiness, and before/after FOV remains NOT RUN, so runtime visual acceptance stays open.

## Focused Skill Tree size follow-up

- [ ] T057 Make the Skill Tree spread visibly larger and wider while keeping controls and nodes usable.
  - Owner/reviewer: Bao (Skill Tree presentation; user-requested follow-up to T045).
  - Scope: `ui/skill_tree_layout.gd`, `ui/skill_tree_graph.gd`, and/or `ui/skill_tree_node.gd` as needed. Expand the open-book content and tree graph footprint and make nodes easier to see. Preserve both tabs, descriptions, zoom/pan, node allocation, graph links, and all progression/gameplay behavior.
  - Acceptance: the weapon and character trees occupy substantially more width and area than the current screenshot; nodes/icons are easier to read without clipping or covering the description and book controls at supported resolutions.
  - Validation: review responsive book/page sizing, graph/node layout and unchanged allocation actions, then `git diff --check`. Godot visual/input checks at small and large resolutions remain NOT RUN; T057 stays open pending runtime review.

## Focused lightning enemy status VFX follow-up

- [ ] T058 Show electric status art on enemies hit by lightning skills instead of the ice freeze visual.
  - Owner/reviewer: Bao (player combat/skill presentation; user-requested follow-up).
  - Scope: `scenes/player/player.gd`, `scenes/player/battle_vfx.gd`, and the local Pixelfx `lightning/electrified` export plus metadata as needed. Route lightning elemental hits, active lightning freeze/stun effects, and lightning ultimates to an electric status visual; retain existing crowd-control durations and mechanics. Ice skill visuals and shared slash/ice-shield implementations stay unchanged.
  - Acceptance: all lightning skill paths that currently display `frozen` show the electric status animation; lightning still applies the same `apply_skill_freeze` duration, ice still uses its freeze art, and repeated hits refresh rather than stack duplicate status sprites.
  - Validation: inspect every lightning status call site, status refresh/lifetime handling and asset path, then `git diff --check`. Godot import/playtest and in-game visual/lifecycle confirmation remain NOT RUN; T058 stays open pending runtime review.

## Focused Player HUD combat feedback follow-up

- [ ] T059 Add compact readiness, active-effect, and critical-health feedback to the Player HUD.
  - Owner/reviewer: Bao (player combat/HUD presentation; user-requested follow-up).
  - Scope: `ui/player_hud.gd`, `ui/hud.tscn`, and `scenes/player/player.gd`. Show actual ultimate readiness in the rage label; add compact dash/parry cooldown indicators with current keys; show durations for the existing attack/speed buffs and ice shield; pulse a low-health warning at critical HP. Preserve all input bindings, gameplay values, skill-tree behavior, and health/cooldown/buff mechanics.
  - Acceptance: HUD labels agree with actual readiness/cooldown values; existing temporary buffs and shield expose their remaining time and disappear at expiry/consumption; low-health warning appears only for living players at or below one-third HP; the new slots and status strip fit without covering gameplay at supported resolutions.
  - Validation: inspect the tracked timer/status data and existing HUD slot logic, then `git diff --check`. Godot parse/import and visual/input checks remain NOT RUN; T059 stays open pending runtime review.

## Focused Player HUD presentation polish

- [ ] T060 Remove rage percentages, compact and separate defensive actions from elemental skills, add action icons, and show a pulsing red edge filter at low health.
  - Owner/reviewer: Bao (Player HUD and combat presentation; user-requested follow-up).
  - Scope: `ui/player_hud.gd` and `ui/hud.tscn`. Keep the rage progress bar but remove numeric percentage from rage labels/tooltips; reduce the skill bar footprint and place Dash/Parry in a visibly separate defense group with distinct icons; add a soft red screen-edge vignette that pulses at the existing low-health threshold. Preserve input bindings, cooldowns, skill selection, health rules and Skill Tree behavior.
  - Acceptance: no rage percentage is shown in HUD text/tooltips; elemental skills plus the ultimate/tree remain in the main group while Dash/Parry occupy a separate adjacent panel; action icons remain visible under cooldown feedback; vignette pulses only for a living player at or below one-third health, fades when health recovers or the player dies, and stays limited to the screen edge.
  - Validation: inspect HUD grouping/icon/cooldown wiring, rage text, vignette shader bounds and low-health visibility, then `git diff --check`. Godot parse/import and visual checks at supported viewport sizes remain NOT RUN; T060 stays open pending runtime review.

## Focused Player HUD readability and menu ordering

- [ ] T061 Reduce buff/rage text size and put every gameplay menu above all HUD and effect layers.
  - Owner/reviewer: Bao (Player HUD and Skill Tree presentation; user-requested follow-up).
  - Scope: `ui/player_hud.gd`, `ui/hud.tscn`, and `ui/skill_tree_layout.gd`. Reduce active-status chip type/padding and rage-label font size. Move the existing Skill Tree menu onto the shared topmost menu CanvasLayer and make the menu-layer constant available to future gameplay menus. Preserve all gameplay/HUD values and behavior.
  - Acceptance: buff and rage text are visibly smaller without clipping; the Skill Tree layer is above player HUD, boss HUD, health/status overlays and cinematic/VFX CanvasLayers; opening hides the gameplay HUD and closing restores it; no Duy-owned boss layer or gameplay system is modified.
  - Validation: inspect menu-layer assignment and visibility flow plus font/padding values; run `git diff --check`. Godot parse/import and visual menu stacking at runtime remain NOT RUN; T061 stays open pending runtime review.

## Focused Wind ultimate redesign

- [ ] T062 Replace the weak second Wind ultimate with “Trăng Tối,” a 10-SP invulnerable orbiting dash that damages/slows nearby enemies and resets Wind active-skill cooldowns.
  - Owner/reviewer: Bao (Player combat, skills and Skill Tree; user-requested follow-up).
  - Scope: `scenes/player/player.gd`, `scenes/player/player.tscn`, a dedicated PlayerState for the ultimate, `ui/skill_tree_layout.gd`, `ui/player_hud.gd`, `scenes/player/ultimate_cinematic.gd`, and the existing concept record. Keep the skill ID `ultimate_wind_2` so unlocked saves remain valid. Set only this Wind ultimate's threshold to 10 SP; preserve Wind ultimate 1 and all other forms.
  - Acceptance: Trăng Tối moves in repeated, collision-aware dashes around the nearest living enemy (or around the cast position if none is nearby) for a fixed 3.6-second duration; each pulse damages and slows enemies in the swept area; both damage entry paths honor immunity for the full active interval; ending the state restores normal movement and clears cooldowns for unlocked Wind active skills while keeping the ultimate cooldown. The UI and cinematic use the new title.
  - Validation: inspect SP requirements/ID preservation, FSM entry/exit and normal collision pipeline, hit/slow pulses, immunity cleanup, active-skill cooldown reset and title mapping, then `git diff --check`. Godot playtest of unlock, movement/collision, immunity, pulse damage/slow and cooldown reset remains NOT RUN; T062 stays open pending playtest.

## Focused Skill Tree alignment and ultimate presentation follow-up

- [ ] T063 Center the visible Skill Tree graph, make buff chips smaller, and add temporary element-colored light/neon shimmer during every ultimate effect after its cinematic.
  - Owner/reviewer: Bao (Skill Tree and Player combat presentation; user-requested follow-up).
  - Scope: `ui/skill_tree_graph.gd`, `ui/skill_tree_layout.gd`, `ui/player_hud.gd`, `scenes/player/player.gd`, and local shader resources if needed. Shift the graph right within its available viewport so the graph sits centered without clipping; reduce status-chip font/padding while keeping labels legible. Start a screen glow tinted to the ultimate's element and a pulsing neon outline drawn only on the player's alpha silhouette after the existing cinematic completes; keep the sprite fill and animation colors unchanged, restore the prior sprite material and remove the screen overlay when that ultimate's presentation ends. Preserve all ultimate mechanics, the T062 duration/cleanup, HUD status data and other menus.
  - Acceptance: graph nodes and links are centered in the visible tree area at supported aspect ratios; buff chips are compact and readable; each ultimate form receives its matching screen tint and only a neon contour around the player silhouette after the cinematic, with no tinted duplicate body; effects disappear at the effect's end and all original player material/state is restored, including when Wind 2 ends or the player/scene exits. Existing slash and ice-shield implementations remain unchanged.
  - Validation: statically inspect graph bounds/offsets, compact label sizes, element-to-color mapping, timed effect lifecycle and cleanup paths, plus `git diff --check`. Godot visual review at supported aspect ratios and ultimate playback/cleanup checks remain NOT RUN; T063 stays open pending runtime review.

## Focused ultimate cast impact VFX follow-up

- [ ] T064 Make Wind, Fire and Lightning ultimate casts read like powerful finishing moves with stronger elemental impact effects.
  - Owner/reviewer: Bao (Player combat and skill presentation; user-requested follow-up).
  - Scope: add a project-local PVFX spawn helper in `scenes/player/battle_vfx.gd` and use existing PVFX Foundry sheets at the non-ice ultimate cast/hit points in `scenes/player/player.gd`. Add a stronger impact accent to the repeated Trăng Tối hits/end beat as appropriate. Do not change the ultimate cinematic, camera, shake, damage, hit timing, duration, cooldown, enemy status/control, screen glow/neon, slash implementation or ice ultimates/ice shield. Reuse the checked-in `assets/effects/pvfx-foundry-thirteen-spritesheets/` assets; do not add another library or modify the upstream pack.
  - Acceptance: all six Wind, Fire and Lightning ultimate IDs have clearly stronger, readable, element-appropriate VFX at their actual cast/impact moments, with no unintended FX on unaffected enemies; existing cinematic behavior and all gameplay values remain unchanged. Ice ultimate visuals remain untouched.
  - Validation: inspect selected PVFX sheet/manifest frame count, size, pivot and duration; inspect each ultimate's hit point and target filtering; verify the helper frees one-shots and handles missing camera/resources; then run `git diff --check`. Godot import/playback and in-game visual/readability checks remain NOT RUN; T064 stays open pending runtime review.

## Focused active Ice skill PVFX trial

- [ ] T065 Try more expressive PVFX on two older active Ice skills and assess fit.
  - Owner/reviewer: Bao (Player skill presentation; user-requested trial).
  - Scope: replace only the visual call for `active_ice_2`'s cone attack with the directional PVFX `ice/frost-breath`, and only the visual call for `active_ice_4`'s area attack with PVFX `ice/ice-spike`, through the generic `BattleVFX.play_pvfx()` helper. Do not change skill damage, aim, range, freeze duration, cooldown, hit timing, ice attack slash sheets, ice shield/ring, ice status effects, either Ice ultimate, or any other skill.
  - Acceptance: the frost-breath direction/length reads as the existing forward cone, and the ice-spike burst reads as the existing area storm; both use checked-in PVFX manifests/pivots, auto-clean their animations, and leave all gameplay unchanged. The two trial effects can be judged visually for fit before more Ice skills are converted.
  - Validation: inspect candidate sheet previews and manifests, verify the exact two skill call sites and unchanged gameplay parameters, and run `git diff --check`. Godot in-game visual scale/aim/occlusion review is requested as part of this trial if the runtime is available; otherwise report it NOT RUN and keep T065 open.

## Focused Wind, Fire and Lightning active-skill PVFX trial

- [ ] T066 Try element-specific PVFX replacements on selected Wind, Fire and Lightning active skills.
  - Owner/reviewer: Bao (Player skill presentation; user-requested follow-up).
  - Scope: update only the visuals for active Wind 3/4, Fire 2/3/4, and Lightning 2/3/4 using the existing `BattleVFX.play_pvfx()` loader and checked-in PVFX Foundry sheets. Keep required charge beats and existing sword slash sheets where relevant. Preserve all skill logic, damage, targets, aim, range, delayed cast timing, cooldowns, status effects, and all Ice skills/ultimates.
  - Acceptance: the Wind dash reads as a wind blade and its area skill as a whirlwind; Fire delayed/rage/meteor attacks read as a nova, erupting burst and meteor; Lightning cone/strike/storm effects use directed arcs and visible impacts on only targets the existing damage paths can hit. Animations clean up; all gameplay behavior stays unchanged.
  - Validation: inspect chosen sheets/manifests and loop duration, verify each visual target/position against its damage call site, and run `git diff --check`. The user will review the appearance in game; do not claim visual acceptance until they report it.

## Dark Fairy boss intro and defeat cut-ins

- [ ] T067 Add a first-encounter boss introduction cut-in and a one-slash split finisher for the Dark Fairy.
  - Owner/reviewer: Duy (boss system); the user reports Duy approved this exact T067 scope on 2026-11-10 (relayed approval, not direct reviewer sign-off).
  - Scope: add the two presentation triggers in scenes/enemies/darkfairy/darkfairy.gd and a boss-local presentation controller at scenes/enemies/darkfairy/darkfairy_cinematic.gd. Play the intro once per spawned Dark Fairy when the player first enters detection range: pause gameplay, zoom only the active camera FOV without shake/orbit, present the boss name, then reveal the existing BossHUD and resume. On phase-2 defeat, pause gameplay, darken the screen, show one high-contrast slash, visibly split the boss sprite into two halves, then complete the existing defeated/cleanup flow. Restore pause and camera state on completion or abort. No stage scenes, player/skill code, boss AI, attacks, damage/health values, phase rules, shared enemy systems, or existing HUD layout/style are in scope.
  - Acceptance: the intro triggers once on first engagement and does not replay on leaving/re-entering detection range; the existing boss name/health UI is visible after the intro; gameplay and camera state resume exactly. Defeating the boss shows a single slash and two clearly separated boss halves before existing defeat cleanup completes. Missing camera or early exit must not leave the game paused.
  - Validation: inspect trigger gating, process-while-paused behavior, camera/pause restoration, existing BossHUD values, sprite-frame slicing and exactly-once defeat cleanup; run git diff --check. Godot visual checks should cover first approach/re-entry and phase-2 defeat/split/fallback. Runtime checks are not performed unless requested; record any unverified visuals as open.

## Dark Fairy full-screen cut-in and camera focus

- [ ] T068 Expand the Dark Fairy intro/defeat cut-ins with full-screen impact VFX.
  - Owner/reviewer: Duy (boss presentation); the user reports Duy approved this extension on 2026-11-10.
  - Scope: update only `scenes/enemies/darkfairy/darkfairy_cinematic.gd` to add full-viewport elemental flash/impact framing for intro and defeat beats and make the single defeat slash cross the viewport. Preserve the split-boss presentation, title, pause flow, boss AI, damage, HUD style/layout, and all shared/player VFX.
  - Acceptance: the intro impact and defeat hit visibly affect the full screen, with readable boss title and one full-width slash; overlays fade/clear when each cut-in ends and do not intercept input.
  - Validation: inspect full-rect anchors, CanvasLayer order, per-phase opacity/lifetime, slash viewport bounds, and cleanup; run `git diff --check`. Godot visual review remains pending unless explicitly requested; retain unverified visual claims as open.
- [ ] T069 Give Lightning skills distinct SFX using local audio assets.
  - Owner/reviewer: Bao (Player skill/audio presentation).
  - Scope: update only `scenes/player/battle_vfx.gd` sound routing/helper to assign different checked-in clips and pitch/volume profiles to `active_lightning_1..4`, `ultimate_lightning_1..2`, and `lightning_hit`. Preserve non-Lightning routing and all gameplay/VFX behavior. No Lightning-labeled audio files are present in the current SFX pack, so use varied existing spell/impact samples and record this limitation.
  - Acceptance: each Lightning skill and hit reaction no longer routes through one identical clip/profile; effects still clean up after playback and missing files remain safe.
  - Validation: verify every Lightning ID has an explicit path/pitch/volume mapping, confirm every referenced asset exists, compare unchanged non-Lightning cases, and run `git diff --check`. In-game listening is pending; sound fit and loudness remain unverified until heard in context.
- [ ] T070 Center the Dark Fairy in the paused intro and defeat cut-ins.
  - Owner/reviewer: Duy (boss presentation and camera behavior); the user reports Duy approved this extension on 2026-11-10.
  - Scope: update only `scenes/enemies/darkfairy/darkfairy_cinematic.gd` to calculate a temporary camera translation in the view plane that places the boss at viewport center, interpolate into/out of that framing during existing intro/defeat beats, preserve camera orientation/FOV animation, and restore the exact saved global transform and pause state on finish/abort. Do not change `camera_rig.gd`, stage scenes, Player camera behavior, camera shake/orbit, gameplay or boss behavior.
  - Acceptance: both cut-ins frame the boss at screen center while zooming, camera orientation is unchanged, and the exact prior camera transform/pause state are restored on all completion/fallback paths.
  - Validation: inspect perspective projection/depth guards, camera framing interpolation, process-while-paused behavior, and exact transform/pause restoration; run `git diff --check`. Constitution requires Godot playtests for camera changes; those runtime checks remain pending and T070 stays open until recorded.
## B2 respawn, enemy clear, and B3 gate follow-up

- [ ] T093 Make F9 New Game reach the existing reset path while gameplay UI is focused or paused.
  - Owner/reviewer: Bao (pause/input UI); user reports F9 leaves the B2 save intact. Scope: `ui/pause_menu.gd` and cumulative records. Preserve GameManager/SaveSystem, stage, enemy and map ownership boundaries and current working changes.
  - Acceptance: a single F9 press in gameplay or pause calls `GameManager.new_game()` once and marks the event handled; key rebinding may still capture F9 without starting a new game. Existing `new_game()` clears the save and B2 flag and returns to the first stage. No unrelated controls change.
  - Checks: static event-route review, save/reset code inspection, diff check; Godot input/playtest for gameplay, pause, binding capture, and cleared B2 flag before runtime acceptance. No user save will be altered during source review.
  - Status: UI event route implemented; static review completed. Godot input/playtest and Bao acceptance remain pending.

- [ ] T071 Fix checkpoint recovery from the standalone B2 scene and unlock the B3 door only after B2 enemies are cleared.
  - Owner/reviewer: Lam / Quan for basement scenes and shared checkpoint routing; Duy review for consuming the existing EnemyZone clear signal; user clarified and reports the clear-to-open rule is already agreed. Treat this as relayed agreement, not direct reviewer sign-off.
  - Scope: `scripts/autoload/game_manager.gd`, `levels/objects/checkpoint/checkpoint.gd`, `levels/level_1/basement_b2.tscn`, `levels/level_1/basement_full.tscn`, and a small B2-local progress bridge. Canonicalize exact standalone B2 checkpoint touches to the integrated `b2_start` checkpoint without changing legacy-save migration. Configure the currently active B2 EnemyZone for a finite three-defeat clear (matching its existing max-enemy capacity); ignore the unconfigured zone with no enemy scene. Aggregate every configured B2 zone's existing `cleared` signal, persist one `b2_cleared` flag, and unlock a locked B2→B3 door in both the standalone and integrated B2 scenes. Allow B3 path/UID loading only when that flag is set. Preserve old-B3 saved-checkpoint refusal and all non-B3 routes.
  - Acceptance: touching the standalone B2 checkpoint stores the canonical integrated B2 checkpoint; after death, the player reloads at B2 with full health. B2 spawns a finite group of three enemies total in the active zone; killing all configured B2 groups stops their timers and persists `b2_cleared`. Before that flag, the B2→B3 door stays locked and direct B3 stage changes are refused. After clear, the door opens and its transition lands at `b3_down`; clearing persists across death/reload. Legacy invalid/B3 checkpoint recovery remains blocked.
  - Validation: inspect checkpoint canonicalization vs unchanged legacy-save migration, finite zone thresholds and empty-zone handling, aggregate clear/persist-once path, door guard and B3 spawn routing; run `git diff --check`. Godot playtests must cover standalone-B2 checkpoint/death, finite kills, locked-before-clear, open/transition-after-clear, integrated-B2 behavior and reload persistence. They remain NOT RUN until explicitly requested; no runtime acceptance is implied.
  - Implementation status: source changes are in place; static review and `git diff --check` are recorded in `validation.md`. Runtime checks remain pending, so T071 stays open.

## Focused Skill Tree scale and learn-confirmation follow-up

- [ ] T072 Restore the elongated Skill Tree presentation and require confirmation before learning or upgrading a selected node.
  - Owner/reviewer: Bao (Skill Tree UI; user-requested restoration). No shared progression or combat systems are changed.
  - Scope: `ui/skill_tree_layout.gd` and `ui/skill_tree_node.gd`. Restore the documented 110% initial graph zoom, spread the weapon-tree levels further along its vertical axis, and keep nodes/links within the graph area. Hover continues to show details. Clicking a node only selects it; show a contextual action button in the left description panel. Only that button may invoke existing form, skill, evolution, character-upgrade or ultimate-selection callbacks. Disable the button when existing purchase eligibility says the action cannot run. Preserve all costs, thresholds, IDs, progression rules, descriptions, graph links, pan/zoom and tab behavior.
  - Acceptance: tree levels use more of the available graph height and open at the documented 110% zoom without obscuring the left description or zoom controls; hovering shows details and does not spend SP; clicking any actionable node selects it and reveals its correctly labeled left-side action button without spending SP; confirming performs the same existing action once, and unavailable actions remain disabled. Node selection and hover descriptions remain understandable when moving between nodes.
  - Validation: inspect graph ratio bounds/zoom and node clipping, hover/selection state, all existing callback call sites, action eligibility, and confirm-only invocation; run `git diff --check`. Godot visual/input playtesting remains NOT RUN unless requested; keep T072 open until reviewed in game.
  - Implementation status: code is in place; static review and whitespace check are recorded in `validation.md`. Godot visual/input verification remains pending, so T072 stays open.

## Player skill speed and gravity follow-up

- [ ] T073 Make Player skill animations play about 20% faster and slightly increase Player gravity.
  - Owner/reviewer: Bao (Player skill presentation and movement; user-requested tuning).
  - Scope: `scenes/player/states/skillstate.gd`, `scenes/player/battle_vfx.gd`, and `scenes/player/player.tscn`. Apply a 1.2 playback scale to Player skill attack/throw animations and spawned PixelFX/PVFX sprites. Match cast-state duration to the accelerated animation, restoring the prior AnimationPlayer scale when the state exits/finishes. Raise only Player's inherited gravity from 24 to 26 via the Player scene override; do not alter BaseCharacter's shared default.
  - Acceptance: active skill attack/throw and spawned battle VFX animations play about 20% faster; cast state ends in step with its accelerated clip; existing skill cooldowns, damage, status timers and timer-based VFX loop lifetimes stay unchanged. Player gravity becomes 26 while enemies retain the shared 24 default. No other movement values change.
  - Validation: statically inspect speed-scale setup/restoration and cast duration math, VFX sprite assignments, and Player-only gravity override; run `git diff --check`. Constitution-required Godot skill playback and jump/fall/stair/dash checks remain NOT RUN; keep T073 open pending runtime verification.
  - Implementation status: source changes are in place; static review and whitespace check are recorded in `validation.md`. Skill playback and movement runtime checks remain pending, so T073 stays open.

## Locked-door dialogue crash follow-up

- [ ] T074 Fix the `door_locked` dialogue crash caused by Conversation calling talk APIs that Player does not implement.
  - Owner/reviewer: Bao (Player-facing dialogue integration). Keep the change in `scripts/conversation.gd` and `scenes/player/player.gd`; do not alter Door, Dialogic, BaseCharacter, or shared input systems.
  - Scope: implement the Player talk state expected by Conversation, including movement restoration and `can_interact()` behavior used by `InteractiveArea3D`; pass input through to Dialogic while a timeline is active; guard optional partner talk calls so generic BaseCharacter instances without those methods do not crash. Use the active Dialogic timeline as the global duplicate-dialogue guard.
  - Acceptance: interacting with a locked door no longer accesses a missing Player property/method; `door_locked` starts once; Player movement/input is unavailable during the timeline and previous movement-enabled state is restored afterward; an interact press during dialogue is available to Dialogic; absent optional partner talk methods do not cause invalid access.
  - Validation: inspect Conversation call sites, Player talk lifecycle, `can_interact()` input handoff, movement restoration, and safe optional partner calls; run `git diff --check`. Godot parse/runtime reproduction is not run unless requested; keep T074 open until the reported locked-door interaction is verified in game.
  - Implementation status: `Conversation` and Player talk support are implemented; static review and `git diff --check` are recorded in `validation.md`. The reported locked-door flow remains unverified in Godot, so T074 stays open.

## B2 clear-gate bug follow-up

- [ ] T075 Fix the inactive B2 enemy zone inheriting a default enemy scene and preventing the clear flag from being set.
  - Owner/reviewer: Lam / Quan for basement scene configuration; this corrects the existing T071 clear-to-open implementation without changing its agreed rule.
  - Scope: explicitly set `enemy_scene = null` on the unused `EnemyZone_B` instance in `levels/level_1/basement_b2.tscn` and `levels/level_1/basement_full.tscn`. Preserve `EnemyZone_A`'s three-defeat threshold, the `b2_cleared` gate, and all other B3 route checks.
  - Acceptance: the unused zone no longer spawns inherited crabs or invalidates the progress bridge; defeating the three configured B2 enemies sets `b2_cleared`, opens the B2→B3 door, and allows its transition to `b3_down`.
  - Validation: inspect the base EnemyZone default and both B2 instance overrides, progress bridge's configured-zone selection, and unchanged GameManager/door gate; run `git diff --check`. Godot parse and kill/door transition playtests remain NOT RUN; T075 stays open pending runtime verification.
  - Implementation status: both unused B2 zone instances now explicitly override `enemy_scene` to `null`; static review and whitespace check are recorded in `validation.md`. The in-game clear-to-tele flow remains unverified, so T075 stays open.

## Ultimate cut-in impact frame and Skill Tree readability follow-up

- [ ] T076 Make the Player ultimate impact frame fill the viewport and improve Skill Tree readability.
  - Owner/reviewer: Bao (Player ultimate presentation and Skill Tree UI). No shared/boss VFX helper or progression system changes.
  - Scope: in `scenes/player/ultimate_cinematic.gd`, play the existing PixelFX `impacts/impact-frame` animation as a viewport-sized CanvasLayer sprite, maintaining its aspect ratio while covering the viewport and removing it with the cinematic. In `ui/skill_tree_layout.gd` and `ui/skill_tree_node.gd`, raise the initial graph zoom from 110% to 115% and enlarge node icons, circles, and labels for readability. Preserve timing, camera, title, impact bands, cleanup, all skill-tree data and callbacks, and user pan/zoom controls.
  - Acceptance: all Player ultimate cut-ins display the existing impact-frame animation across the full viewport at supported aspect ratios; it remains visible above the cinematic bands/flash, does not cover the title, and is cleaned up on finish or abort. The Skill Tree opens at 115%; icons, nodes and labels are visibly larger without obscuring neighboring nodes, the description panel or zoom controls; existing selection, confirmation, pan, zoom and progression behavior remain unchanged.
  - Validation: inspect the impact atlas/manifest frame size and timing, viewport cover-scale and resize handling, draw order and lifecycle cleanup; inspect node draw bounds/readability and confirm callback/eligibility wiring is unchanged; run `git diff --check`. Godot visual checks for all ultimate cut-ins and supported Skill Tree viewport sizes are NOT RUN unless requested; keep T076 open pending runtime review.
  - Implementation status: source changes and static review are recorded in `validation.md`; viewport and Skill Tree runtime visuals remain unverified, so T076 stays open.

## Lightning active-skill 2/3 mechanic rework

- [ ] T077 Replace Lightning 2's cone with a line strike and Lightning 3's area strike with a timed chasing clone.
  - Owner/reviewer: Bao (Player skills and Skill Tree). Use existing Enemy freeze/hurt APIs and GridPathfinder; do not change Duy's Enemy AI or shared navigation.
  - Scope: update `scenes/player/player.gd`, add a Player-local `scenes/player/lightning_clone.gd`, and update the two Lightning skill descriptions in `ui/skill_tree_layout.gd`. Lightning 2 fires along a 1.6 m line to 7 m (+1 m per `evo_lightning_chain` rank), deals the existing 2× skill damage, retains its existing 0.45 s lock (+0.2 s/rank) and 7 s cooldown, selects the first living valid enemy on the line, then teleports the Player to a collision-safe point behind that enemy. If no safe landing point exists behind the target, deal the hit and skip teleport. Lightning 3 summons a copy at the cast point for 5 s; it chases the nearest living enemy with the existing GridPathfinder, performs a basic box attack every 1.2 s using current normal attack damage, then explodes at its last position in the existing 3 m radius for 3× skill damage (+1× per `evo_lightning_storm` rank), applying the existing 0.6 s movement lock. Keep its 9 s cooldown. Preserve IDs, unlock/cost/evolution rules, other Lightning skills, SFX, and unrelated mechanics.
  - Acceptance: Lightning 2 draws a directed bolt along the straight path, damages only the first living eligible enemy within range/line width, and moves the Player behind that target without placing the Player inside blocking collision; failed landing leaves the Player in place. Lightning 3 visibly summons a tinted Player copy, reselects targets as enemies die, chases reachable enemies using the existing pathfinder, attacks no faster than every 1.2 s with basic damage, and explodes once at 5 s with the recorded radius/damage/lock. Despawn/scene exit or Player death must not leave a clone or timer behind. The Skill Tree descriptions match both behaviors.
  - Validation: inspect line target ordering/height/width filters, single-hit/rage path, teleport overlap query and fallback; inspect clone target reselection, path agent usage, attack interval/damage source, five-second timer and exactly-once explosion/cleanup; verify both UI descriptions and unchanged costs/evolutions/SFX; run `git diff --check`. Godot parse and playtests for beam targeting, blocked teleport, clone chase/attacks, final blast, death and stage exit remain NOT RUN unless requested. Keep T077 open pending runtime validation; no reviewer sign-off is claimed.
  - Implementation status: Player-local beam/teleport helpers and a five-second chasing clone are implemented; both Skill Tree descriptions and review records are updated. Static review and `git diff --check` are recorded in `validation.md`; Godot parse and gameplay checks remain unverified, so T077 stays open.

## Book-integrated Skill Tree presentation (2026-11-12)

- [ ] T078 Blend the T-menu Skill Tree into a coherent antique spellbook.
  - Owner/reviewer: Bao (Skill Tree presentation). User-authorized UI scope only; no shared gameplay, save, map or progression changes.
  - Scope: `ui/skill_tree_layout.gd`, `ui/skill_tree_graph.gd`, `ui/skill_tree_node.gd`, optional local folio decoration, and cumulative task/validation/changelog records. Preserve pre-existing T072/T076/T077 changes.
  - Acceptance: static and animated book use identical frame geometry; text, graph, controls and confirmation stay on their respective paper pages; warm ink/bronze styling and active chapter indicators are consistent. Opening, turning and closing hide/reveal page ink coherently, prevent interaction during transitions, handle rapid T/Escape without stranded pause/HUD state, and retain selection-before-confirm, costs and callbacks. Default zoom remains 115% with clipped pan/zoom inside the right page.
  - Checks: focused Godot UI-only preview with isolated user data, render both chapters and selected descriptions, exercise transition interruption and confirm-only actions, check representative aspect ratios and `git diff --check`. Record stubbed UI checks separately from actual gameplay integration and reviewer acceptance.
  - Status: implemented. Godot 4.7.2 isolated UI scene passed 103 assertions with no script/runtime errors in the final run; rendered both chapters, four forms, selected descriptions and 4:3/16:9/ultrawide sizes. Real T/Escape/mouse input, confirmation gating, all 56 frame bounds, interrupted transitions and pause/HUD restoration passed against fixture stubs. Main-game integration and Bao visual acceptance remain NOT RUN/pending, so the task stays unchecked; see validation.md.

## Free orbit gameplay camera (2026-11-12)

- [ ] T079 Replace the fixed camera with a collision-aware free orbit camera.
  - Owner/reviewer: Bao (Player camera/input integration). User explicitly requests the rework and selects mouse-look with held Alt releasing the cursor. Shared CameraRig is consumed by Stage; preserve its target, Camera3D child and snap_to_target API. Map/AI/save code and the pre-existing Dark Fairy scene diff are excluded. No teammate sign-off claimed.
  - Scope: camera rig script/scene; Player-local movement, dash, carry, skill aim and sprite-facing integration; focused camera regression fixture and these cumulative records.
  - Acceptance: 360-degree yaw, clamped pitch, wheel zoom; mouse capture releases for Alt, pause/menu, dialogue, focus loss and removal. Camera contracts immediately before world collision, including thin walls/corners/floor/ceiling, and extends smoothly; target is excluded. Follow and teleport do not sweep from old stage positions. WASD/dash/carry/aim follow camera yaw without changing speeds/damage or enemy code. Paused cinematics retain camera control. No collision-free viewpoint is promised when the target itself is embedded in solid geometry.
  - Checks: isolated Godot physics/input regression fixtures, rendered obstacle scenarios, production scene playtest in a disposable copy with isolated save data, whitespace/diff review. Keep manual feel/full-map acceptance and any unexercised integrations explicit.
  - Status: scope recorded before implementation; checks pending.
  - Final status (2026-11-12): implemented and verified by 104 rendered camera physics/input assertions plus 20 actual-basement/Player/UI integration assertions. Reviewed spawn/side/obstructed-rear screenshots; fixed Compatibility alpha fading for Player, sword and foreground non-solid checkpoint markers. Stage, map/AI/save code and pre-existing Dark Fairy edits preserved. Manual feel, all-map traversal, real carry/combat/respawn/cutscene acceptance and reviewer agreement remain pending; keep unchecked. Full-copy runtime retains UID fallback and shutdown resource diagnostics, explicitly recorded in validation.md.

## Embedded Game mouse-look regression (2026-11-12)

- [ ] T080 Restore continuous mouse-look in Godot's embedded Game view.
  - Owner/reviewer: Bao (camera input); user reports no mouse orbit and confirms embedded Game. No map, AI, save or editor-setting changes authorized or needed.
  - Scope: CameraRig input/focus lifecycle, camera regression fixtures, cumulative task/validation/changelog records. Preserve T079 and existing dirty files.
  - Acceptance: native mouse movement rotates the actual basement camera in embedded Input mode; cursor capture recovers on entering Game, Alt releases/reacquires, Escape releases until a gameplay click, menus/dialogue/death still block orbit. Standalone input and wall/corner regression checks remain passing.
  - Validation: reproduce in original embedded editor, diagnose input/focus, run isolated rendered suites, then repeat native embedded mouse input. Synthetic input alone is insufficient acceptance for this regression. Status: implemented; 106/106 rendered camera and 23/23 actual-basement synthetic-input checks pass. Native embedded mouse after final edits and reviewer feel remain pending; keep unchecked.

## Free-orbit VFX projection (2026-11-13)

- [ ] T081 Keep existing Bao-owned combat/skill VFX readable while the camera orbits.
  - Owner/reviewer: Bao (Player battle VFX). User requests retuning old VFX for the new view. Preserve slash and ice shield/cast ring implementations; no enemy, map, save, skill damage or timing changes.
  - Scope: world projection of existing PixelFX/PVFX combat and spell overlays, camera-aware orientation/size, targeted verification and cumulative records.
  - Acceptance: an active effect remains attached to its world hit/cast point as camera yaw/pitch/distance changes; screen direction follows projected world direction; effects hide behind the camera and reappear when visible. Existing sheets, colors and lifetimes remain intact. Screen-space cinematic impact remains unaffected.
  - Checks: Godot rendered multi-angle effect fixture and actual-basement smoke, source/asset preservation and git diff review. Status: implemented; 6/6 rendered projection and 23/23 actual-basement integration assertions pass. Manual multi-form visual and reviewer acceptance remain pending; keep unchecked.

## Aimed skills and ultimate silhouette (2026-11-13)

- [ ] T082 Add held-skill aiming and improve Player combat presentation.
  - Owner/reviewer: Bao (Player combat, skill input and VFX placement). User authorizes this scope. Preserve slash and ice-shield effect implementations, map, enemy and save systems; no teammate agreement is asserted.
  - Scope: quick skill tap casts normally on release; holding skill for 0.3 s shows a centered reticle, and release casts directional skills through the camera's center hit point. Keep movement and mouse orbit usable during aiming. Move the floating blade behind the Player during the ultimate cinematic pose and restore it afterward. Raise Player-spawned slash effects slightly. Add focused checks and cumulative records.
  - Acceptance: tap still throws/casts with existing facing rules; hold shows a noninteractive centered reticle and sends projectile/line/cone skills toward the viewed world point, including height for projectiles; releasing or cancelling clears the reticle without a stuck cast. Collision in the sightline determines the target. Ult blade no longer overlays the Player in the cut-in and returns to its former pose; slash visuals sit higher without changing hitboxes, damage, timing or effect assets.
  - Checks: Godot rendered gameplay fixture for tap/hold/release, aim point and obstruction; visual cut-in and slash smoke when feasible; diff/asset review. Native embedded input and Bao visual acceptance remain separate from scripted checks.
  - Status: implemented; 36/36 rendered actual-basement/Player integration assertions pass in isolated Godot 4.7.2, including quick cast, 0.3 s reticle, blocked sightline, 3D projectile direction, dialogue/pause cancellation and blade pose/restore. Reticle and blade screenshots were inspected. Native embedded input feel, all skill forms, full ult cut-in and slash visual acceptance remain pending; keep unchecked.

## Shoulder camera while aiming (2026-11-13)

- [ ] T083 Make the held-skill aim view smaller and unobstructed by the Player.
  - Owner/reviewer: Bao (Player camera/skill UI). User supplies an over-the-shoulder reference and requests a smaller crosshair plus camera/character reframing. CameraRig is shared with Stage; preserve target, Camera3D, snap_to_target and normal orbit/collision contracts. No map, enemy, save, input-map or unrelated VFX changes; no teammate sign-off claimed.
  - Scope: scale down the existing reticle; while hold aim is active, bring the camera to a collision-aware shoulder position so the Player appears to the left of the centered reticle. Return smoothly on release/cancel. Keep center-ray skill aim aligned with the moved camera and retain existing movement, mouse orbit, zoom setting, skill damage/range and 0.3 s threshold.
  - Acceptance: aimed Player sprite does not cover the center reticle at representative yaw/pitch/zoom; the center ray and projectile use the reframed Camera3D; lateral/boom wall obstruction keeps the lens outside solid collision; release, dialogue and pause restore normal framing without a stuck offset. Quick taps never enter shoulder view.
  - Checks: rendered isolated camera physics and actual-basement gameplay fixtures, screenshot inspection at normal/aimed framing, diff/resource review; native embedded feel and Bao visual acceptance remain distinct.
  - Status: implemented; Godot 4.7.2 rendered isolated rig fixture passes 115/115 checks, actual-basement/Player integration passes 40/40. Final aim screenshot inspected. Native embedded Game feel, representative map locations and Bao visual acceptance remain pending; keep unchecked.
## Straight elemental orbs (2026-11-13)

- [ ] T087 Clear the Player silhouette and raise the default skill aim point slightly.
  - Owner/reviewer: Bao; user authorizes Player aiming and projectile presentation. Preserve all existing uncommitted work, projectile gameplay and wind return behavior.
  - Scope: use shared normalized aim point at (0.5, 0.42) for hidden/visible aiming and camera ray; render existing orb sheets as depth-tested 3D sprites instead of foreground CanvasLayer overlays. No camera rig, map, enemy, slash/shield or source sheet changes.
  - Acceptance: visible reticle and actual ray coincide above screen center at multiple resolutions; quick and held casts use the same target; Player/world geometry occlude orbs behind them, orb remains correctly anchored/oriented as camera changes, and previous flight/range/wall/element/wind checks still pass.
  - Checks: rendered Godot aim/projection/occlusion fixture and screenshots plus orb regression. Native full-stage feel and reviewer acceptance remain pending.
  - Status: implemented; final Godot 4.7.2 Compatibility fixture passes 89/89 checks, including raised ray/reticle alignment at three viewport sizes, quick/held target agreement, 3D depth flags and rendered pixel occlusion. Screenshot inspected. Native full-stage feel and Bao acceptance remain pending; original full-basement fixture blocker updated to the raised ray but full fixture not rerun. Existing UID fallback/shutdown diagnostics remain.

- [ ] T086 Replace neutral/fire/ice/lightning returning dagger with a straight elemental orb; preserve wind.
  - Owner/reviewer: Bao; user authorizes Player projectile behavior and associated VFX/UI wording. Preserve prior parry work, enemy/map/save systems and slash/ice shield assets.
  - Scope: separate orb scene/script reusing existing projectile speed/range/wall query and HitArea damage; pixelfx plasma-shot exports with neutral-white and elemental palettes; first-skill routing and matching UI names/descriptions. Internal skill IDs, costs, cooldowns, damage/status upgrades and higher skills remain intact.
  - Acceptance: neutral casts show a white orb, fire/ice/lightning show their element; travel along the initial 3D aim without return/homing, expire at existing range or wall, and retain existing hit callbacks. Wind still spins/returns/catches, hides/restores blade and receives return upgrades. New orbs never suppress the equipped blade or reset hit monitoring for a return pass. Visual nodes clean up with projectile.
  - Checks: inspect rendered exports, pixelfx checks, Godot fixture covering routing/aim/range/wall/hit callbacks and wind regression, rendered snapshot. Native gameplay feel and Bao acceptance remain pending.
  - Status: implemented; inspected all four exported contact sheets and rendered in-engine screenshot. Godot 4.7.2 headless passes 73/73 checks; final Compatibility renderer fixture passes 77/77 including HUD/Skill Tree names/icon. Stock pixelfx check passes without warnings. Native full-stage input/combat feel and Bao acceptance remain pending; keep unchecked. Existing UID warnings and shutdown retained-object/resource diagnostics remain.

## Successful parry feedback (2026-11-13)

- [ ] T085 Add gold spark burst, white contact flash and metallic sword clang on successful Player parry.
  - Owner/reviewer: Bao (Player combat/VFX); authorized by the user's request. No enemy, map, slash, ice-shield or shared gameplay-rule changes.
  - Scope: export existing pixelfx impacts/parry with metadata/attribution, add a BattleVFX helper and existing Sword Parry sound mapping, invoke only in the successful state transition, extend the parry regression fixture.
  - Acceptance: one burst and one SFX per successful parry; none on entering, missing or retrying an already successful parry. Contact sits in front of Player toward attacker, with facing fallback, and stays anchored during camera orbit. Assets/nodes clean up; HP, enemy reaction, window and recovery remain unchanged; SFX respects settings bus.
  - Checks: inspect exported contact sheet; Godot parry fixture for success/miss/duplicate/cleanup and existing enemy behavior; diff review. Native visual/audio feel and Bao acceptance remain pending.
  - Status: implemented; pixelfx check passes, exported contact sheet inspected, Godot 4.7.2 headless regression passes all seven enemies plus miss/duplicate/orbit/cleanup checks. Native visual/audio feel and Bao acceptance remain pending; keep unchecked. Existing UID warnings and shutdown retained-object/resource diagnostics remain.

## Menu cursor and implicit camera aim (2026-11-13)

- [ ] T084 Show the cursor throughout Skill Tree and aim every directional skill through the camera center.
  - Owner/reviewer: Bao; user authorizes Player, camera and Skill Tree UI changes. Preserve existing dirty work, map/AI/save and skill balance.
  - Scope/acceptance: explicitly visible cursor during opening/open/closing menu, restore gameplay capture on close; quick and held casts use an invisible camera-center target rather than movement/facing, with the visible reticle/shoulder view still gated by 0.3 s hold. Projectile retains 3D aim, ground skills use horizontal bearing, directional ult uses the same camera aim. No reticle is added during ordinary gameplay.
  - Checks: rendered camera and actual-basement menu/input/skill fixtures, exact visible mouse mode including initially hidden cursor, opposing actor/camera directions, projectile trajectory, hold/pause regressions and diff review.
  - Status: implemented; Godot 4.7.2 rendered camera 115/115 and actual-basement integration 42/42 assertions pass. Menu is explicitly VISIBLE from hidden cursor; quick projectile follows center target despite opposite facing/lateral movement. Native embedded cursor feel, per-skill combat review and Bao acceptance remain pending; keep unchecked.


## Audit refresh — 2026-11-13 (documentation and verification only)

Baseline: `feature/playercontrolandmap` / `42471e4c`. See
[whole-project state](../../docs/project-current-state.md) and
[audit test matrix](../../docs/project-audit-validation.md). No existing checkbox is changed.

- T013 / T025 / T026: fresh checkpoint fixtures 54/55, interaction 25/26, recovery 45/55.
  BUG-003 is not reproduced in current rendered captures, but two HUDs (BUG-008) and
  B2 support/visibility (BUG-005) prevent full acceptance. Six recovery failures are
  obsolete camera=Player expectations after T079; four B2 support failures are real.
- T034 / T035–T040: BUG-004 not reproduced at six legacy coordinates; changed geometry
  makes old measurements insufficient. No ceiling/containment/route task is marked done.
- B1 enemy-drop/chest follow-up (commit `22ad2661`, no dedicated task ID in the old list):
  genuine end-to-end BLOCKED by Pelican missing damage receiver (BUG-007). API-only
  chest/unique-pickup dedup passes do not prove this flow. T070 remains boss framing,
  not rewards.
- T071 / T075: actual B2 three-defeat count, SP pickup/save/reload, persistent clear flag,
  stopped reload timer, door→B3 arrival and death→B2 routing now have bounded headless
  evidence. Recovered B2 is hidden (BUG-005); native full combat/route/reviewer acceptance
  remain open. No claim that B1 persistence or the whole wave contract is satisfied.
- T077: clone spawns at caster in diagnostic; direct active-skill invocation smoke passes.
  Nearest reachable target/chase/attack/explosion behavior across floors remains NOT RUN.
- T079–T084: current rendered rig 115/115, VFX 6/6, actual-basement U 42/42 and E 42/42.
  These do not catch duplicate HUD or prove native embedded feel/all-element hit behavior.
  B2 visible-floor regression takes precedence over older all-map assumptions.

### T085 existing settings implementation — backfilled status, not new implementation

- [ ] T085 Validate the existing Esc menu and persistent settings recorded in
  `docs/esc-menu-settings.md` and already present in HEAD.
  - Owner/reviewer: Bao; no teammate approval claimed by audit.
  - Existing scope: `scripts/autoload/game_settings.gd`, `ui/pause_menu.gd`, project
    autoload registration and camera/HUD/SFX settings integration; source unchanged here.
  - Acceptance: pause/cursor/input ownership, config save/restart, rebind conflicts,
    apply/cancel/defaults, display rollback/layout and existing Skill Tree coexistence.
  - Audit evidence: rendered settings 53/53, separate restart 2/2; GPU shader-init/UID/
    shutdown diagnostics retained. Native keyboard/mouse feel, audible mixer check,
    platform coverage and reviewer acceptance remain NOT RUN. Keep unchecked.

No repair implementation begins until the user chooses scope. BUG-005/006 map integration
is the first proposed group, followed by BUG-007 enemy damage and BUG-008 HUD ownership.


## T086 checkpoint visibility/recovery repair — current user scope, 2026-11-13

- [ ] T086 Diagnose and repair B1/B2 checkpoint approach visibility and related BUG-005 recovery.
  - Authorization: current user explicitly permits narrow code changes for checkpoint,
    floor visibility and proven shared-manager cause. This supersedes the audit-only stop
    and does not authorize navigation, Pelican, duplicate HUD or resource cleanup.
  - Baseline: same branch/HEAD `feature/playercontrolandmap` / `42471e4c`; prior audit docs
    dirty plus pre-existing scene changes: Door_b2_up moved to (38.1885,5.973031,5) local and
    Checkpoint_b2 local Y=6. Preserve both; save full hashes/diffs before edits.
  - Owner/review boundary: Lam/Quan map/floor selector/checkpoint integration. Bao camera
    collision/Player contract stays unchanged unless runtime evidence proves a necessary
    narrow change. Shared GameManager/input are not presumed causes. No Quan/Bao approval
    or acceptance is claimed; current user authorization permits this bounded repair.
  - Supersession: T044's connector midpoint criteria apply only to actual existing floor
    endpoints. A standalone B3 door/marker is not an integrated floor-2 visibility connector.
    Current scene has B1, B1_5 and B2; layout/textures/collision/gameplay rules are retained.
    Old camera rig=Player test equality is superseded by the orbit focus_offset contract;
    support and real visibility assertions must remain strict.
  - Acceptance: approach/leave B1/B2 by normal movement at representative camera yaw/zoom;
    selector never chooses absent floor; actual supporting floor visible before F; F tint/
    feedback/idempotence/forward-only preserved; Esc Settings does not break interaction;
    connector traversal/jumps and synthetic B1/B2 startup/restart/death (including B3 route)
    retain supported movable spawn, camera obstruction and unrelated payload.
  - Checks: before/after rendered isolated diagnostic with Player/support, floor visibility,
    connector and camera/collider traces; existing checkpoint recovery with justified test
    updates and added regression assertions; preserve baseline hashes and scene edits.
    Native/manual gaps and independent bugs stay explicit. No generator/commit/push.
  - Status before implementation: diagnosis pending; no game code changed by this repair yet.


### T086 implementation / executed results

Implemented only in `basement_floor_visibility.gd`: exclude absent connector endpoints
and bound startup height fallback to existing floor metadata. No GameManager, input,
CameraRig, checkpoint resource or scene edit. Incoming scene Y6 checkpoint/door placement
is preserved; supported Spawn Y11.2 is a baseline correction, not authored by this group.
`tests/basement_checkpoint_check.gd` now uses orbit focus_offset and keeps original spawn
support assertions, adding real floor visibility checks. New reusable
`tests/basement_checkpoint_visibility_check.gd/.tscn` exercises actual walking/camera traces.

Verified: paired before/after approach126 with18 failures→0; rendered approach126/126,
checkpoint/menu/jump/B2+B3 recovery32/32, physical connector wall-jump/descent2/2,
CameraRig115/115, recovery67/67 and five rendered entry processes7/7 each. Save bytes
unchanged in process tests; unrelated nested payload/flags preserved. Raw logs/limits:
[project audit validation T086 append](../../docs/project-audit-validation.md).

BUG-005 is verified for those cases; native editor/mouse feel, full viewpoint coverage and
independent Quan/Bao acceptance remain pending, so T086 remains unchecked. BUG-006–010
remain open; general save fixture still54/55 on BUG-010. No generator/commit/push.


## T087 — explicit B3 checkpoint and return doors (2026-11-13)

- [ ] T087 Implement current user's three B3 requirements on the current branch.
  - Authorization/owners: user explicitly authorizes related scenes and shared manager;
    Lam/Quan map/checkpoint integration boundary, existing Bao camera/Player and Duy boss
    implementations preserved. No independent reviewer agreement is claimed.
  - Baseline: HEAD42471e4c, prior T086/docs plus new incoming B3 nested GridMaps/MVP library/
    tracked UID-cache edits. Hash/diff snapshot before changes; no generator/setup/branch
    change, commit/push, reset or cleanup. Keep T086 selector and B2-clear entry guard.
  - Decisions superseded: blanket B3 checkpoint/recovery refusal (old US3/T027 contract)
    now permits only new explicit-F B3 checkpoint saves with a distinct contract marker.
    Unmarked old B3 pairs remain unsupported, byte-preserved and blocked; no guessed
    fallback/migration. Current no-silent-reset request supersedes legacy B1/B2 checkpoint
    reset: known pairs normalize to their equivalent B1/B2 ID without rewriting disk.
  - Scope: disabled targetless B3 exit interaction; B3-down to the main scene's separate
    existing B2 door Spawn (not checkpoint); explicit B3 checkpoint using local detector,
    trusted rank3, save contract and startup/death recovery; focused tests and docs.
  - Acceptance: physical F door round-trip without checkpoint mutation/auto loop; no exit
    prompt/empty load; B3 nearby F activation/tint/exact feedback, no contact activation;
    repeat current no write/feedback restart; lower B1/B2 refused; B2-clear guard retained;
    B3 death/restart and B3-active return-to-B2 death/restart restore supported B3 Spawn,
    camera/floor; Settings roundtrip and payload/SP/flags preserved. Old unsupported B3
    save cases held unchanged, no reset/delete; current valid B1/B2 and T086 regressions.
  - Plan: reuse Door_b2_up/Spawn as dedicated arrival, verify surface and trigger clearance;
    do not invent map coordinates or alter incoming layout/library. Inspect before editing.
    Runtime/engine/isolation evidence and exact included files recorded cumulatively.
  - Status at scope record: implementation and runtime acceptance pending.

### T087 implemented / executed evidence

Implemented four gameplay files: B3 scene wiring; opt-out targetless Door interaction;
checkpoint identity/idempotence; manager rank3/contract/recovery and preserved legacy IDs.
Existing measured Door_b2_up/Spawn is safe and separate from checkpoint; no placement edit.
Tests: rendered flow99/99 (bytes AND timestamp unchanged on repeated F), compatibility47/47,
fixtures59/59, recovery67/67, T086126/126; nine fresh rendered entry/restart cases pass.
B2 clear uses three actual damage/death/drop/pickup paths; SP7→10 and nested payload survive.
Old unmarked/future/invalid B3 recovery remains BLOCKED; refusal/preservation tests PASS.
Obsolete mandatory DarkFairy fixture assumption corrected; initial failure log retained.
See project-audit-validation.md T087 for raw evidence, commands and engine/isolation.
Implementation/runtime subset verified; checkbox stays open for native editor/mouse feel,
live boss interference and independent Quan/Bao/Duy review (NOT RUN, no agreement claimed).
No setup/generator, branch change, commit/push; T086 and incoming geometry/library preserved.

## User-authorized EXP progression — 2026-11-17

Scoped tasks, approved balance and ownership/review boundaries: `docs/exp-progression-2026-11-17.md`. This Player progression request does not complete unrelated basement tasks.

EXP outcome: scoped implementation complete; focused headless/rendered 48/48 each and actual stage persistence 20/20 pass. Existing B3 walking suite remains failed/incomplete at B2 door; review and manual campaign pacing pending. Exact files/evidence/limitations are cumulative in the project-changes record and EXP scope document.

## User-authorized inventory / offhand resonance / enchant — 2026-11-17

Bao-owned Player/combat/UI implementation and necessary shared save/input integration: docs/inventory-enchant-2026-11-17.md. User approved proposed archetypes/enchant pool with temporary test values; four named slots used. I01-I05 implemented; focused headless/rendered 120/120 each, actual scene/checkpoint/death persistence 19/19, elemental-orb regression 87/87 and temporary SP-API-adapted EXP regression 48/48. Manual full-campaign feel/balance and independent review remain pending. No unrelated basement checkbox closed; drops/crafting/AI/maps/slash/ice-shield unchanged. Cumulative file-level evidence in project-changes record.

Inventory correction C02 (2026-11-17): actual equipped offhand now appears during neutral, normal elemental and upgraded elemental slot-1 casts; hide/restore on exit/interruption/death/teardown. Isolated headless/rendered each 176/176 including original 120 checks + 56 pose/lifecycle checks. C01 one-fixed-element catalog and save aliases remain pending exact user pairing; no mapping invented. See feature scope and cumulative change record. Incoming dirty UID cache preserved; no map/AI/drop edits or reviewer sign-off.

Inventory correction C01/C03 complete (2026-11-17): confirmed sword/lightning, axe/ice, spear/fire, dagger/wind; bow/throwing knife neutral. Catalog contains one entry per type, legacy variants alias canonical IDs while retaining instance/equipment/SP state and inactive paid offhand elemental ranks. Headless/rendered each 213/213; canonical-ID B2/B3 checkpoint/death/save flow 19/19. C02 actual offhand cast art retained. Details/limits and per-file evidence in feature/cumulative records; no unrelated task closure or reviewer approval.

UI polish U01-U04 (2026-11-17): Hearthmark CC0 stone/wood/parchment skin and compact inventory grid/gear strip implemented; exact source/files/license in docs/ui-assets-2026-11-17.md. User-reported Dark Fairy stale _drop_skill_points call changed to existing EXP helper with identical five-unit/source ID contract. Final isolated headless/rendered 217/217 each without SCRIPT ERROR; actual boss load and exact-once 100 EXP included. Rendered UI inspected. Full boss fight/native UI feel/independent review pending; vendor/exit warnings retained, no original cache/real save writes or unrelated task closure.

E01-E04 (2026-11-17): user atlas rows corrected to outlined lightning sword/yellow, ice axe/blue, fire spear/red, wind dagger/green. Original neutral starter Blade restored; no-inventory/new game equips it, old prototype saves gain missing Blade without losing chosen gear/SP. Non-Blade max3 active enchant types; Blade no artificial type/rank purchase cap, normal eligibility/cost/effect formulas retained. Overflow ranks inactive/preserved; partial pending offers supported. Final headless/rendered 236/236 and stage/save/death 19/19. Visuals inspected, exact files and limits in feature/cumulative record; no unrelated task/reviewer acceptance.

### W01 — weapon-specific melee attack task (2026-11-17)
- Owner: Bao (Player/combat/UI boundary); user-authorized changes to Player, main-weapon animation state and Pixelfx presentation only.
- AC: three sword strikes; three axe strikes; four advancing spear strikes; one dagger strike. Equipped weapon flies to hand and uses its own attack pose/FX; stop using the generic attack clip/slash for main-hand attacks. A held J/mouse-left charge follows the W01-W04 contract recorded in `docs/inventory-enchant-2026-11-17.md`.
- Check: inspect static state/asset wiring; focused Godot combo/charge/playtest is necessary to verify windows, launches, collision safety, target selection and cleanup. No pre-implementation runtime verification has been performed.
- Review: no enemy AI/map/skill-tree/loot/camera/slash-sheet/ice-shield edit; no external teammate agreement inferred. Existing incoming dirty cache and inventory work are preserved.

W01-W04 implementation update (2026-11-17): new state and Pixelfx paths wired to `player.tscn`; each combo/charge path and restoration/obstruction code statically inspected. Four selected JSON files parsed with frame data and pixelfx metadata; source contact sheets viewed. Scoped text-file `git diff --check` passed (line-ending notices only). No Godot parser/runtime/playtest was run, so animation visibility, repeated hit signals, nearest enemy targeting, collision behavior, damage/launch and return remain unverified. W05 pending actual Godot playtest. This group does not close unrelated basement task checkboxes or imply Bao/other reviewer agreement.

W06 (2026-11-17) supersedes automatic combo: one click/strike, single queued input,0.3s link/reset, sword3/axe3/spear4/dagger1; grip/tip-directed sprite motion with distinct stage paths and continuous joins. Bao-owned attack state only, existing empty-hand pose/FX reused. Implemented and focused Compatibility-rendered98/98 verified; initial headless93/93 predates real hurt-area assertions/empty-hand presentation. Exact runtime conditions and limitations in feature record and docs/validation/weapon-combo. Full gameplay feel/charge-target cases and independent review remain pending; unrelated basement tasks not closed.

W06 final check update:103/103 Compatibility-rendered includes five FX load assertions. Repaired missing baseline spear-sweep art in disposable copy only; preimport98 history retained. Full manual feel/review remains open.

W07 (2026-11-17) implemented and focused rendered129/129: original directional attack body replaces carry, active main/offhand pixels depth-test behind Player, dagger physical elevated out/back arcs, axe jump/downward ground-impact with vertical streak/upright shock. Keeps click combos. Full input/direction regression plus actual crab damage, physics floor/wall/ceiling/interrupt and rendered silhouette occlusion verified in disposable project. Exact diagnostics/fixture failure history and manual limits in feature/validation record; no unrelated checkboxes/reviewer signoff.

## C01–C05 — F2 camera views (2026-11-19)
User-authorized Bao Player/camera slice. Criteria recorded before implementation in docs/camera-views-2026-11-19.md. C01–C04 implemented: Top-down default / TPS / FPS cycle, per-view controls/aim/presentation, menu/visibility restoration. C05 focused rendered checks pass139/139 camera and29/29 actual Player/HUD; final three-view screenshots inspected. Full-map manual traversal/feel and independent review remain pending. Existing unrelated task status and ownership boundaries unchanged.

C06 camera cleanup repair (2026-11-19): user-reported freed cached sprite reproduced; four visibility loops now validate untyped keys before use. Focused rendered147/147 passes versus pre-fix5 failures with matching errors. Full-stage/manual/review limits unchanged; see camera feature record.

C07/C08 (2026-11-20): implemented user-requested exact FPS weapon presentation including legacy Blade normal/charged original frames, and fixed Top-down angle/distance with foreground cutaway. Focused camera154/154 and actual Player67/67 rendered checks pass; complete regular combos and fixed movement anchor covered. Manual all-map/cutaway feel, all charge/contact variants and independent review pending. See docs/camera-views-2026-11-19.md; no unrelated task closure.

C09 (2026-11-20): reported Top-down down-facing weapon ground clipping reproduced and repaired in Player depth placement. Rendered177/177 checks pass across four weapon types/four directions/four first-strike samples, preserving back ordering/TPS offset. Before/after screenshots inspected; full-map/later-combo/charge/manual-review limits remain. See camera feature record.

## M01/M02 menu T bug report — 2026-11-21
Bao UI scope requested by user; criteria recorded before implementation in cumulative project-changes record. M02 implemented: Skill Tree refuses acquiring another system's pause while allowing its own opening/closing reversal. Isolated Godot4.7.2 Compatibility actual Player/HUD/cinematic fixture passes65/65 with --pause-only: all8 ultimates, rapid T/Escape, foreign pause, abort, menu reuse and teardown. No full-map native playtest or independent reviewer agreement. M01 remains PENDING USER DESIGN CHOICE: char_heal explicitly heals on opening in existing implementation and tooltip; retirement/refund versus replacement regeneration requested, no answer yet. Existing ranks/SP/saves/heal behavior preserved. Full fixture without --pause-only intentionally includes two still-failing M01 regression expectations. No unrelated tasks closed.

M01 clarification (2026-11-21): user chose timed regeneration, preserving purchased ranks/SP. Exact interval per rank remains pending (30/20/10s versus60/40/20s offered); scope/AC recorded in project-changes. No health implementation yet; M02 remains65/65 verified.

M01/M02 final (2026-11-21): user selected1HP per60/40/20s at ranks1/2/3. M01 implemented in Player gameplay timer; opening book no longer heals, tooltip updated, existing ranks/SP/save IDs preserved. Timer pauses with game/cinematic and resets at full health/death/rank change. Full isolated rendered fixture99/99 PASS (no --pause-only), including prior65 pause checks,2 no-menu-heal regressions,24 regen boundary/lifecycle/real-time checks and8 cinematic-timer checks. Earlier pending design/known-failing M01 notes are historical and superseded. Full-map native manual playtest/independent review remain unrun; no unrelated acceptance or commit/push.

## User request — dash priority / B3 camera (2026-11-21)
Bao-owned Player combat and B3 camera setup. Implemented: weapon_attack checks dash before processing/buffering any attack phase; existing state exit restores hitbox, weapon and animation when FSM changes to Dash. B3 instance CameraRig lowers top-down distance12→10.8 and focus offset1.3→1.1; only B3 scene affected. No runtime verification run in this turn; required Godot playtest of attack cancellation and B3 ceiling clearance remains pending. No map geometry, enemies, shared camera defaults or unrelated dirty files changed; no reviewer agreement.

## Runes and flat skill bonuses — 2026-11-21 (before implementation)
Owner: Bao inventory/catalog, Player combat/skills, Skill Tree UI, and GameManager respawn integration. User authorizes six rune charms; no new armor. Lam-owned potion crafting/loot, Duy enemy implementations, maps, and unrelated save architecture remain out of scope. Existing charm save ID/equipment slot and all old item instances remain compatible.
Approved effects: rename existing charm to Bùa ma pháp and convert its +15% skill bonus to +1 flat elemental skill damage; six charm items use Amber/Binding/Blood/Brimstone/Sky/Time rune art. Values: Amber +1 burn damage per tick (one-second tick); Binding +1 second slow/freeze/stun; Blood 10% chance to heal 1 HP per attack/skill hit; Brimstone consumes itself on death and respawns the Player at 2 HP; Sky +0.5 movement speed; Time subtracts 1 second from active/ultimate cooldowns. Matching equipped main-hand element adds +2 flat skill damage; resonance enchant becomes +1 flat skill damage/rank. Affliction enchant becomes +1 status second/rank; Haste becomes -1 cooldown second/rank.
User-approved percentage conversions in current skill tree: Wind return +1 m distance and +1 m/s return speed; Gale +2 damage/rank; Ice Shatter +2 damage/rank against frozen targets; Searing Knife +1 projectile damage/rank; Parry +0.05 s/rank; Dash -0.1 s/rank; Speed +0.5 m/s/rank; Fire Rage cost 5 HP and Fire Deity cost 10 HP, retaining the existing minimum-1-HP safety floor. Ice Shield absorbs one whole incoming hit, regardless of damage size.
Acceptance: each rune is grantable/equippable from the existing P/inventory prototype and retains its static 32x32 icon; only the named rune grants its effect; old charm ID/restore works; Brimstone is consumed exactly on a successful death respawn and grants 2 HP; one shield hit leaves HP unchanged and a second hit works; matched/wrong-form skill damage is +2/0; all named former-percent bonuses use the approved flat values; retained save/slot state and other gear behavior do not regress. Runtime playtest is required for respawn per constitution. Focused inventory, Player skill/status, death/respawn and source compatibility checks are specified; no test assets/automation added here.
Unresolved: wind return currently has no implementation call sites in source, only its tree description/progression ID; record as an existing limitation, do not invent a projectile subsystem. Existing unrelated percentage probabilities such as critical chance and explicit Blood 10% chance remain probabilities.

Implementation status (2026-11-21): six rune charms added to the existing charm slot/P grant catalog; baseline charm is named Bùa ma pháp and retains its save ID. Effects implemented at the user-approved values: flat +2 skill damage for matching main-hand element, baseline charm +1 elemental skill damage, Amber +1 burn damage/tick, Binding +1s slow/freeze duration, Blood 10% chance to heal 1 HP on hit, Brimstone one-use 2-HP death respawn, Sky +0.5 movement speed, Time -1s active/ultimate cooldown. Ice Shield now absorbs one entire incoming hit. Skill Tree percentage conversions from the approved list are implemented in descriptions and formulas, plus flat haste/resonance/affliction enchant conversions.
Known unresolved: `evo_wind_return` still has no source behavior call site (only progression and description); its description now carries the approved +1m/+1m/s values but that effect isn't runtime-implemented. Existing Wind ultimate movement still uses its prior 1.5x formula. A proposed conversion of it to +3m/s was rejected by automatic approval review because that formula wasn't in the approved percentage conversion list; it was not retried or bypassed. The user can decide that separate design change. Existing critical and lifesteal probabilities remain probabilities.
Included files/purpose: `scripts/item_catalog.gd` adds rune definitions/icons, charm names and flat enchant descriptions; `scripts/inventory_state.gd` consumes equipped Brimstone; `scenes/player/player.gd` implements rune hit/status/speed/cooldown/skill-damage effects, flat approved skill formulas and one-hit shield; `scripts/autoload/game_manager.gd` carries one-use Brimstone through the existing respawn registration and saves consumption; `ui/skill_tree_layout.gd` shows approved fixed numbers; `specs/001-integrate-basement-stage/tasks.md` and `validation.md` record acceptance/status and limits; `docs/project-changes-2026-11-14.txt` is this cumulative file-level record. The source PNGs were already present under the user-provided vendor folder and were not modified.
Integration: P's existing grant-all test action now grants all six rune charms via the catalog, and existing equip/save machinery retains charm IDs/slots. No new armor, crafting/drop, enemy AI, map, slash/ice-shield presentation, or SaveSystem schema work. Runtime verification NOT RUN: no Godot playtest or test-suite run; respawn/shield/status behavior remains unverified under the constitution. Static source review, all seven icon path existence checks, and `git diff --check` passed. Vendor cache/import changes and incoming C09 `.import` files remain untouched. No independent owner/reviewer agreement, commit, or push claimed.

## Dash key, cooldown and action cancel — 2026-11-21 (before implementation)
Owner: Bao Player/input/skill states and input settings/HUD labels. Preserve current combat and stamina rules. Existing project defaults already say Q=quick item and Shift=dash; a saved settings file can override them, so migrate only the exact former swapped default pair while preserving custom bindings/secondary slots. New user request: Q stays quick item, Shift dashes; base Dash cooldown becomes 2 seconds (existing per-rank fixed Dash skill reduction remains); Shift must exit any weapon attack phase and an active skill cast animation into Dash. Cooldown/stamina are still charged through the existing DashState on entry; skill cooldown already started at cast must not be refunded. No change to projectile/effect after it has been launched.
Acceptance: fresh defaults and legacy saved swapped pair both resolve Q→quick item, Shift→dash without duplicate bindings; custom keybinds remain; Dash cooldown base is 2.0 seconds before existing rank reductions; Dash interrupts weapon combo/charge and skill cast, runs existing state cleanup, and leaves skill cooldown spent. Checks: inspect InputMap/save migration/key display; source flow for both states and cleanup; `git diff --check`. Runtime playtest of real inputs, cooldown/stamina, interruption cleanup and skill cooldown is required by feature acceptance; no added test fixture.

## Dash key and cancel — implementation status (2026-11-21)
Implemented: existing project defaults remain Q=quick item and Shift=dash; GameSettings now migrates only a saved primary pair exactly matching the former reversed defaults (dash Q / quick Shift), preserving secondary/custom bindings. Player base dash cooldown is 2.0s before existing per-rank fixed reductions. PlayerState cancels active skill aim when dash starts; SkillState now checks dash before advancing cast animation. The existing weapon attack state already checked dash before its attack phases/buffer. Dash still uses its existing stamina cost and DashState sets cooldown on entry; skill cast cooldown starts on enter and is not reset when dash exits the cast.
Files: scripts/autoload/game_settings.gd (legacy swapped-default migration); scenes/player/player.gd (2s Player base); scenes/player/states/player_state.gd (clear pending aim on dash); scenes/player/states/skillstate.gd (dash interruption/retained cooldown); ui/player_hud.gd (empty quick-slot tooltip reads the actual quick-item key); specs/001-integrate-basement-stage/tasks.md, validation.md and docs/project-changes-2026-11-14.txt (acceptance, evidence and cumulative record). No project.godot edit was needed: static inspection already showed Q for quick_item and Shift for dash in InputMap.
Static review confirms migration condition, Player cooldown initialization, dash transition and SkillState ordering; `git diff --check` passed. No Godot run, tests or physical input playtest were performed. Therefore key migration, interruption cleanup, 2s runtime timing, stamina payment and retained skill cooldown remain runtime-unverified. No settings file outside the project was modified; no SaveSystem, map or enemy change and no teammate/reviewer acceptance claimed. Existing dirty cache, vendor import and C09 .import files were left untouched. No commit/push.
## EnemyPlacement — split basement encounters and forward portals

- Scope: Lam / Quan map configuration in `basement_b1.tscn`, `basement_b2.tscn`, and `basement_b3.tscn`. The user superseded the respawn marker in the reference with fixed authored encounters. Use only Arcane, Skeleton, and Dark Fairy placements, with Undead Executioner as B2 mini-boss and Dark Fairy as B3 boss.
- Implemented: B1 has four pairs (8 total) in the northern, eastern, western, and southern areas. B2 has two pairs plus the eastern Undead Executioner (5 total). B3 has one Dark Fairy at the central boss spot. Each forward portal stays hidden and inactive until the last authored enemy's death completes. The Castle sketch serves as the arrival scene; no onward route was requested for it.
- Integration: split clear flags preserve opened portals and skip the defeated roster on return. The existing `b2_cleared` prerequisite is set after split B2 clear. B3's existing return door leads to split B2 when that split clear flag exists. The main entry scene and existing checkpoint recovery policy remain outside this scope.
- Status: implemented. See the EnemyPlacement section in `validation.md` for the Godot results and playtest limits. No independent owner approval is recorded.

- Follow-up exit decision (2026-11-22): the user asked to remove the newly added Castle link. Restored the original disabled B3 exit with its empty destination. B3 still tracks Dark Fairy defeat without a forward portal. This supersedes the Castle destination in the previous entry.

## G01–G04 — Garden integration (2026-11-23)
User-authorized scope/owners/AC are recorded before implementation in docs/project-changes-2026-11-14.txt.
- [X] G01 Connect boss-gated B3 exit and garden return, retaining checkpoint and reverse routes.
- [X] G02 Persist confirmed partial encounter defeats and completed boss across revisit/save reload; no living/phase-change false clears. Map progression adapters only; Duy AI unchanged.
- [X] G03 Reuse existing four-crop farm in garden, preserve sketch save identities, add greeting/chat/purchase-only/leave NPC. User confirms existing 1 SP/seed.
- [ ] G04 Fit dialogue/shop to viewport; rendered route, persistence, farm and layout checks; record exact limits and review status.
Independent Quan/Bao/Duy review not supplied; no prior unrelated task closed.

G01–G03 implemented (2026-11-23); G04 focused rendered verification passed 127/127,
exit 0, including actual F routes, partial/whole defeat persistence, garden farming and
four viewport sizes. Shop/dialogue screenshots inspected. Full on-foot/manual combat,
legacy sketch runtime, physical controller/mouse UX and independent review remain unrun.
See validation.md Garden / basement verification and the cumulative change record.

## G05/G06 — Garden revision (2026-11-24)
- [X] G05 Expand eight beds into32 marked independent cells, preserving old crops in first cell; Lam/Quan map scope, user authorized. Verify actual scene support, independent planting and save reload.
- [X] G06 Use Dialogic greeting/chat/trade/leave and handoff to existing seed shop; UI/farm adapter scope, user authorized. Verify actual choices, control/mouse cleanup, shop return and four viewport sizes. Independent review unrun.

G05/G06/G07 focused completion (2026-11-24):32 supported numbered cells with legacy/new
crop identity persistence, actual Dialogic choices/shop/back/leave/Escape and four viewport
sizes pass. G07 repairs both missing portrait paths with AtlasTextures from existing sheets,
adds Foxy reply, verifies actual NPC/Player speaker images and inspects both screenshots.
Final isolated Godot4.7.2 rendered157/157, exit0. Full manual traversal/controller UX and
independent review remain unrun; see validation.md and cumulative record.

- [X] G08 (2026-11-24): user requests removing cell numbers. Removed32 numeric Label3D children; preserved32 cells and their stable save keys/positions. Existing regression expectation updated. Static count/whitespace checks passed; runtime not rerun for label-only change. See cumulative record.


## N01–N05 / L01–L03 — Possession story, secret room and chest loot (2026-11-25, before implementation)
User authorizes this narrative/chest/map integration slice: Lam/Quan map/secret-wall and loot adapters; Bao inventory/EXP/camera presentation; Duy Dark Fairy dialogue hooks only, preserving combat/AI. No independent teammate agreement inferred. Incoming git status clean. No generators, source-cache edits, real saves, commit or push.
AC: N01 prison/dead fox/decayed chains intro, Có/Không choice; only Có continues, then adaptation. N02 actual B1 clear monologue, ladder camera focus, restore camera/control, persist seen flags. N03 locked B2 progression door/player exchange, no travel. N04 first Dark Fairy intro and final defeat requested text, freeze combat, preserve cinematic/phase distinction. N05 repeated player weapon hits break authored B1 secret wall and remove collision, persist opening; existing room gets chest and F-readable prisoner67 notebook with failed nine-tailed specimen record. L01 F exactly-once chest opening with all existing opening frames. L02 random1–2 current catalog items, first B1 clear chest guarantees weapon. L03 user clarified10 existing EXP points =200EXP per chest; SP via level-up only. Item/EXP drops fly into living Player. Persist rolled contents and per-drop collection so save/reload/transition cannot duplicate or lose rewards; preserve legacy opened B1 reward ID, existing save schema.
Checks: source/reference/whitespace; isolated rendered Godot actual choice/clear/boss/loot/save/reload checks and camera/wall traversal playtest. Distinguish implemented and verified behavior. Full manual combat balance and independent review remain unverified until performed.


## N01–N05 / L01–L03 — focused corrected result (2026-11-25)
Implemented user-requested slice. Godot4.7.2 official, Compatibility/ANGLE on isolated C:/Users/BaoHo/AppData/Local/Temp/ArcanaGarden-20261123, custom user directory ArcanaStory-20261125. Command: Godot_v4.7.2-stable_win64_console.exe --path <copy> --rendering-method gl_compatibility --script res://tests/basement_story_loot_check.gd -- --isolated-copy. Corrected final:61/61 functional assertions PASSED, explicit ENGINE_EXIT_CODE=0. No script/parse/Dialogue-expression error. Vendor UID text-path fallbacks and10 ObjectDB/one retained resource at shutdown remain; baseline157/157 run also retains19 ObjectDB/one resource, exit0. Native access violation in earlier new-suite runs was real and is superseded by the corrected exit0 result, not ignored.
- N01 PASSED: real Có/Không labels; Không stays at offer and cannot enable play; Có completes adaptation and releases Player/world. Actual fresh-start scene used, not real save.
- N02 PASSED: authored B1 zone-clear signals trigger story; actual camera focus/zoom and restored view/control in Top-down/TPS/FPS; clear seen flag saves. Signal fixture sets required zone defeat counts before emitting real cleared signals; full nine-kill manual combat is not claimed.
- N03 PASSED: main B2 door handler and actual F at split B2 locked exit show dialogue without travel.
- N04 PASSED: actual Dark Fairy intro hook, existing cinematic return, terminal-death dialogue before disappearance/clear, defeated clear flag and control restoration. Final-death fixture drives existing hurt handler in phase2; phase-change persistence regression checked separately by old suite.
- N05 PASSED: non-player damage rejected; five calls through actual Player HitArea.hit/HurtArea remove authored GridMap cells and physics wall; Player.move_and_collide physically crosses passage. Real nearby F reads/re-reads notebook; save/scene reload preserves opened wall and skips seen stories. This is a rendered automated actor playtest, not manual J/mouse combat/feel acceptance.
- L01–L03 PASSED: actual F/repeated F rolls1–2 items with guaranteed elemental weapon in first B1 clear chest; animation ends open and emits item count+10EXP orbs before granting. Actual flight/collection, interrupted opening/scene travel to Garden, save/load deduplication and independent secret chest all pass. Each chest gives200EXP; fresh test totals400EXP, level3/150EXP/6SP from level-ups only. All16 current catalog icons load. Legacy opened B1 reward remains empty.
- Parser regression PASSED: all five notebook text events have null speaker, labels display literal colons, B2 door resolves registered prison_door character. Source parser inspected to confirm anonymous runtime speaker creation from unescaped single-word colon. Minimal notebook case failed native before escape and exits0 afterward.
- Scene transition during active story releases Dialogic, Player, stage process mode and camera process mode. Existing map/resource references and shared player/enemy AI remain unchanged except documented adapter hooks.
Evidence: docs/validation/story-loot-2026-11-25/runtime.log; native-failure-before-fix.log, notebook-before-fix.log and notebook-after-fix.log preserve reproduction/correction; baseline-regression.log proves pre-change157/157 exit0. Five rendered PNGs possession-choice, ladder-focus, secret-notebook, chest-opening, dark-fairy-intro were visually inspected: readable dialogue/choice, authored ladder shot, notebook title, visible open chest/airborne rewards, boss portrait. Latest route/farm regression is running; final result recorded separately.
Limitations: full manual all-map traversal/physical-key combat balance, every weapon/skill against wall, controller navigation and independent Quan/Bao/Duy acceptance NOT RUN. Existing shutdown retained-resource and vendor UID warnings not repaired. No source cache or real save changes, generators, commit or push. Old basement task checkboxes and unrelated acceptance remain unchanged.


### N01–N05 / L01–L03 FINAL — 2026-11-25
Implemented and focused rendered verification PASSED after both corrections. Final source-compatible Compatibility/ANGLE runs in the documented isolated copy/custom save directory:
- tests/basement_story_loot_check.gd:61/61, ENGINE_EXIT_CODE=0; docs/validation/story-loot-2026-11-25/runtime.log.
- tests/basement_clear_portal_check.gd:158/158, ENGINE_EXIT_CODE=0; docs/validation/story-loot-2026-11-25/route-regression.log. Includes real F forward/reverse B1/B2/B3/Garden, actual enemy terminal defeat/phase distinction, partial/whole persistence through save/reloads, garden32 cells/purchases/plant/harvest, real merchant Dialogic/portraits and four viewport sizes, plus new cleared-B2 no-orphan assertion.
- Disposable12-transition B2/B3 stress: exit0; docs/validation/story-loot-2026-11-25/revisit-stress.log. Previous route-failure-before-lifecycle-fix.log retains native heap failure as reproduction, not a pass.
N01–N05 and L01–L03 requested behavior is implemented and covered by these focused checks; no unrelated feature/task closure or independent teammate agreement implied. Native failures in earlier experiments are superseded by final clean engine exits. Scene teardown no longer produces get_viewport/is_inside_tree errors in final routes. Existing vendor UID path warnings and shutdown retained-resource diagnostics remain(10 ObjectDB/1 resource story;19/1 route, matching baseline class of warning). No final SCRIPT ERROR, parse failure, Dialogue expression error or native crash. Full manual all-map/physical combat/controller UX and independent owner review remain unrun, as listed above.
Final included additions beyond first manifest: dialog/characters/prison_door.dch supplies persistent Cửa speaker; project.godot registers it; notebook escaped field colons remain visible literals; clear_portal.gd creates locked interaction only while needed and after scene readiness; tests add parser/no-orphan assertions. Evidence manifest: runtime.log and route-regression.log are final full assertion/diagnostic logs; baseline-regression.log is before-change157/157 exit0; native-failure-before-fix.log and notebook-before/after-fix.log preserve colon/speaker reproduction and corrected result; route-failure-before-lifecycle-fix.log preserves orphan regression; revisit-stress.log records12 transitions; possession-choice.png, ladder-focus.png, secret-notebook.png, chest-opening.png, dark-fairy-intro.png show inspected actual rendered UI/animation/focus/portrait. All evidence is under docs/validation/story-loot-2026-11-25. Both feature records and this cumulative file contain final status/limits. Source .godot caches, real saves, original mesh libraries, input/main-scene, Player combat/skills, enemy tuning, crafting and source artwork remain unchanged. No generators, commit or push.


## C-TPS-ZOOM — TPS default and Top-down wheel (2026-11-25, before implementation)
User authorizes Bao camera/settings presentation slice: TPS default, other views selectable, wheel near/far in Top-down. Preserve incoming N01–N05/L01–L03 dirty story/chest/scene/docs/evidence work. Scope/review boundary: scenes/camera/camera_rig.gd, scripts/autoload/game_settings.gd, related existing camera fixtures and camera/task/validation/cumulative docs. No teammate agreement inferred.
AC: new rig and missing/invalid/missing-key settings default to TPS(1); explicitly saved valid0/1/2 preferences remain selectable/persistent, existing F2 TPS→FPS→Top-down cycle remains. Top-down wheel up/down changes its distance by existing0.75m step within existing min_zoom/max_zoom(3–14m), keeps fixed yaw/pitch/follow and foreground cutaway; TPS zoom stays independent, FPS ignores wheel. Pause/dialogue/death/Alt cannot zoom. Top-down retains selected distance across view switches within same rig; existing per-scene authored initial distances remain, no new zoom save schema. Run isolated rendered actual Player/HUD input, preference/load/default, zoom bounds/control-gating/collision checks and inspect near/far screenshots. Full manual all-map feel/review remain unrun. No generators/source cache/real settings or save edits/commit/push.


### C-TPS-ZOOM FINAL — 2026-11-25
Implemented and isolated rendered verification PASSED. TPS is the export/default preference, missing/invalid/missing-key configs fall back to1; explicitly saved valid Top-down/TPS/FPS choices remain compatible. F2 cycling unchanged. Top-down wheel adjusts its own distance by0.75m in existing3–14m bounds while yaw/pitch stay fixed; existing cutaway/follow preserved. TPS has independent orbit zoom; FPS ignores wheel. Selected Top-down zoom survives switching views within the rig; each scene keeps its authored initial zoom, no new persistence schema.
Included files/purpose: scenes/camera/camera_rig.gd changes fallback/export view toTPS and handles Top-down wheel through existing gameplay/unhandled-input gating; scripts/autoload/game_settings.gd defines DEFAULT_CAMERA_VIEW_MODE=1 and uses it consistently for initialization/load/missing-key fallback, preserving valid saved modes. tests/tps_preference_check.gd checks fresh default/missing/invalid settings and all saved modes, real viewport wheel directions/clamps, angle/TPS independence, pause/dialogue/dead gates, FPS ignore and return-to-view zoom; tests/camera_views_check.gd starts actual Stage atTPS, explicitly selects optional Top-down before existing F2/FPS/Player/HUD checks, marks narrative as already seen to preserve camera-fixture scope. tests/camera_rig_check.gd updates historical default/wheel expectations and waits for physics after zoom; this standalone minimal fixture was NOT RUN in this turn. docs/camera-views-2026-11-19.md, specs/001-integrate-basement-stage/tasks.md, validation.md and docs/project-changes-2026-11-14.txt record scope, AC, file purposes, results and limitations.
Verification: Godot4.7.2 Compatibility/ANGLE, disposable C:/Users/BaoHo/AppData/Local/Temp/ArcanaGarden-20261123 with fresh custom user directory ArcanaCameraDefaults-20261125. Commands use --path <copy> --rendering-method gl_compatibility --scene res://tests/<suite>.tscn. tps_preference_check54/54, ENGINE_EXIT_CODE=0; camera_views_check68/68, ENGINE_EXIT_CODE=0. These are rendered actor/input checks, not headless-only loading. Actual Player/HUD defaultTPS, F2 other views, rear facing, TPS wall retraction, pointer aim, pause/dialogue/death switching, FPS presentation/weapon animation and stable Top-down follow pass. All new wheel assertions pass. Source whitespace check passes.
Evidence/file purposes: docs/validation/tps-default-topdown-zoom-2026-11-25/preference-runtime.log and player-hud-runtime.log contain final assertions/full diagnostics; topdown-near.png and topdown-far.png show actual controlled test-platform zoom limits; tps-default.png shows defaultTPS in actual basement. All three images visually inspected: scale changes as expected, Player visible, TPS rear framing and HUD intact. Retained existing3 ObjectDB/one resource shutdown warnings and same-state animation notices; no script/parse/native failure. Source cache and real save/settings not edited; incoming story/chest work preserved. No new AI/combat/map/collision geometry/input binding/save schema changes, generators, commit or push. Full manual all-map ceiling/zoom feel, native physical-device UX, Alt-wheel runtime case and independent owner review NOT RUN; Alt guard remains statically present in existing input flow. No broad feature acceptance or teammate agreement implied.
## G09–G12 — Garden potion brewing, Milestone 1 (2026-11-25)

- [X] G09 Add the Garden NPC Brew choice, reuse the merchant panel and verify focus, Esc, mouse and seed shop continuity.
- [X] G10 Exchange one harvested cucumber and pineapple for `healing_potion`, with one save for produce and inventory. Verify insufficient ingredients, rapid attempts, harvest after brewing and the 32×32 potion icon.
- [X] G11 Verify B inventory and the existing quick slot, Q, exact consumption, no-op at full HP, one-second HUD feedback, Continue and version-1 potion/assignment compatibility.
- [ ] G12 Former proposal to bind 2 to the quick item. **SUPERSEDED** by G16. It was blocked in Mốc 1 by the existing `active_skill_2` binding.

Lam approved this milestone. Review scope covers the merchant, farming/Inventory adapter and potion-use feedback. See the milestone spec and validation for acceptance and evidence.


## G13–G17 — Garden protection and strength potions, Milestone 2 (2026-11-25)

- [X] G13 Add two harvested-produce recipes and potion frames to Garden Brew and the v1 save flow (Lam).
- [X] G14 Integrate one-item Q/Inventory use, shield and ordinary melee damage (Lam and Bao-authorized combat points).
- [X] G15 Display timers and the shield gauge, reject duplicate use, freeze on pause and clear on death. Verify respawn, scene change and Continue.
- [X] G16 Verify Q and retain 2 for active skill slot 2 per the user's final decision.
- [X] G17 Run isolated Garden/combat checks and healing regression. Record validation and the cumulative implementation history.


## G18–G23 — Venom potion, Milestone 3 (2026-11-25)

- [X] G18 Add the fourth Garden recipe and 32×32 frame, retaining Q and the user-confirmed skill 2 binding (Lam).
- [X] G19 Implement accepted-only spending and camera-directed, terrain-checked independent throws (Lam).
- [X] G20 Implement impact merging, isolated zone clocks, manifest-based visual and enemy damage via HurtArea3D (Lam). Verify defeat, EXP and Castle EnemyZone progression through existing APIs.
- [X] G21 Implement Foxy's single pause-aware infection and HUD. Verify exact-expiry tick, overlap, death and the existing scene-reset behavior (Lam).
- [X] G22 Run isolated Garden and Castle checks including real scene death/respawn and wave isolation.
- [X] G23 Rerun the three existing potion regressions and record handoff/evidence.

## N06 — B1 ladder dialogue zoom after TPS default (2026-11-25, before implementation)
User reports the ladder focus/zoom during the B1 clear dialogue does not work. Hypothesis from current TPS default: the old fixed ladder shot used a farther camera position and a mild FOV reduction that can read as a pullback beside the closer TPS frame. Acceptance: during the actual `b1_clear` Dialogic event in fresh TPS plus optional Top-down and FPS modes, camera visibly narrows FOV toward the ladder, centers the ladder focus, and restores the exact prior pose/FOV after the dialogue. Owner boundary: Bao camera/story presentation only (`basement_story.gd` and focused story runtime fixture); no camera-rig, map, enemy, loot, or save behavior changes. Run rendered Godot checks in the disposable isolated copy, capture/inspect the ladder shot, preserve incoming dirty work; manual in-game feel remains distinct from fixture evidence.

### N06 FINAL — B1 ladder dialogue camera follow-up (2026-11-25)
Implemented `levels/level_1/basement_story.gd` ladder shot adjustment and expanded `tests/basement_story_loot_check.gd` to assert centered focus in TPS/Top-down/FPS plus exact restore. `dialog/timelines/b1_clear.dtl`, Stage/camera rig, map, enemies, save/settings and loot are unchanged. Rendered Godot 4.7.2 Compatibility run in disposable `ArcanaGarden-20261123` copy with fresh `ArcanaStory-Zoom-20261125`: 61/61 PASS, ENGINE_EXIT_CODE=0. Evidence: `docs/validation/story-loot-2026-11-25/ladder-zoom-runtime.log` and visually inspected `ladder-focus.png`. One first-run fixture-order assertion was corrected before final pass. Existing vendor UID fallback plus ObjectDB/retained-resource shutdown warnings remain; no script/parse/native failure. Manual interactive playthrough and independent owner review NOT RUN. No save/map/enemy changes, commit or push; the tracked `.godot/uid_cache.bin` already had a 07:56 UTC modification timestamp before this task and was preserved without intentional edits; no reviewer sign-off implied.

## N07 — B1 clear story gate (2026-11-25, before implementation)
User asks to gate the B1 dialogue on defeating all B1 enemies. Source review finds the adapter currently polls every direct child of `B1/EnemyZones` and waits for each `EnemyZone.is_cleared()` (its authored `clear_kills` quota), with the persistent B1 clear door flag as a completed-progress fallback. Make the all-zones condition explicit and test that one uncleared zone prevents the dialogue, then that its completion starts it. Keep the user-edited Player transform and all enemy/zone ownership files intact. Runtime check in the latest full basement scene with an isolated save. No enemy balancing, map edits, save changes or reviewer sign-off.

### N07 FINAL — B1 clear story gate (2026-11-25)
Implemented explicit all-EnemyZone completion in `levels/level_1/basement_story.gd`; no EnemyZone, enemy balance, map, door, save schema or Player spawn file edits. `tests/basement_story_loot_check.gd` proves two cleared zones do not trigger the dialogue and the last cleared zone does; it also checks camera FOV/view and Player controls after dialogue. Latest user-edited `basement_full.tscn` was copied into the isolated test project without altering its source transform. Godot 4.7.2 Compatibility result: 63/63 PASS, ENGINE_EXIT_CODE=0. Evidence: `docs/validation/story-loot-2026-11-25/story-all-b1-runtime.log`. The fixture advances real zone counters/emits their signals, not nine manual enemy kills. Existing vendor UID fallback and ObjectDB/resource shutdown warnings remain. A prior fixture over-asserted exact camera position after the follow rig resumed; final run checks restored FOV/view/controls. Main save currently resumes Garden (F5) and has possession story seen; use F6 on `basement_full.tscn` for that edited scene. Actual full combat playtest and independent review remain NOT RUN; no teammate sign-off implied. Existing tracked `.godot/uid_cache.bin` modification predates this task and was preserved. No commit/push.
## N08 — Ignore empty B1 enemy zones (2026-11-25, before implementation)
Confirmed blocker: B1 EnemyZone_B has enemy_scene = null while clear_kills = 3; it can never reach is_cleared(), so the all-zone story gate never opens. Change the story predicate to count/check only EnemyZones with an enemy scene. Test the latest full scene: empty B1 zone remains incomplete, an active zone short of quota blocks the dialogue, and it starts after the final active B1 zone is cleared. Do not alter the map's enemy assignment/EnemyZone owner system. Rendered isolated Godot validation. Preserve user Player transform and unrelated changes.

### N08 FINAL — Ignore empty B1 enemy zones (2026-11-25)
Root cause: B1 EnemyZone_B in `basement_full.tscn` has no `enemy_scene` but requires 3 kills, so it could never be cleared. `basement_story.gd` now ignores EnemyZones without enemy scenes and waits for all active zones. Test keeps this empty zone at zero kills, verifies the last active zone gate, and checks the timeline starts on its clear signal. Latest scene rendered in isolated Godot 4.7.2 Compatibility: focused 33/33 PASS, ENGINE_EXIT_CODE=0. Evidence: `docs/validation/story-loot-2026-11-25/story-b1-gate-runtime.log`. Player transform preserved; no enemy/map/EnemyZone/save implementation changes. Manual six-enemy combat playtest NOT RUN. Wider suite hit its unrelated absent `B1/ChestSpot` child in `basement_full.tscn`; focused suite passed. Existing UID/exit diagnostics remain; no teammate review or sign-off implied. No commit/push.

## N09 — Separate cheat menu, one-time camps, checkpoint rollback (2026-11-25, before implementation)
User requests the P cheat controls to leave Inventory and appear in a dedicated P menu; every `EnemyZone` camp should spawn one finite initial set with no replacement for defeated enemies; on death, restore XP and inventory to their last checkpoint snapshot while preserving unlock flags. User confirms Bao and Duy approved their respective UI/player and EnemyZone ownership changes. The active tasks record only Lam's older, bounded GameManager approval, so shared save/checkpoint changes require Lam's approval before implementation.

Acceptance: B opens the normal Inventory without any cheat tab/actions; P opens a separate cheat view and menus hand off/close cleanly. Each zone's defeated spawn slots remain defeated after death/scene reload and across Continue; still-living slots may return at their initial state under the existing stage reload model, with no enemy health serialized and no new replacements during a zone's single configured wave. On accepted checkpoint activation, capture current XP and inventory; death restores those values, keeps unlock flags and the checkpoint itself, and saves the rollback. New/legacy saves without a snapshot keep their loaded state as the initial baseline.

Planned checks: inspect scoped diffs and input/UI paths; Godot playtest B/P/Esc transitions; actual EnemyZone initial population, no replacement after kills, death/Continue persistence and completed-clear gating; checkpoint XP/inventory rollback, later checkpoint recapture and unlock preservation. Keep user changes and tracked caches intact. Lam shared-save approval remains a prerequisite only for GameManager/save state and durable camp-kill state; independent P-menu work may proceed.

N09 status update (2026-11-25): separate P-menu slice implemented in `ui/cheat_menu.gd` and `ui/inventory_menu.gd`; no runtime check yet. Durable zone-kill and checkpoint snapshot work remains pending Lam's shared-GameManager approval.
Static check update (2026-11-25): `git diff --check` reports no whitespace errors in the new menu implementation or the appended task/validation/change-log records. Source review confirms Inventory routes only B, CheatMenu routes P/Esc, and the existing `cheat_menu` action remains configured to physical P. Godot runtime behavior remains unverified.

N09 user clarification (2026-11-25): supersedes the planned XP rollback. After death, XP/level/collected-EXP state must remain as earned; only the inventory snapshot may roll back to the last checkpoint. Persistent unlock flags remain unchanged. This is an explicit correction to the original “lose everything after checkpoint” rule.

## N10 — Attack/impact SFX and responsive combo recovery (2026-11-25, before implementation)
User requests SFX for Player attack and incoming hits; after a combo ends, only attack input should be delayed while movement and other controls remain available; dash must interrupt an active attack. Bao owns these Player/combat files and the user explicitly requests this change.

Acceptance: each normal combo strike and charged attack plays a suitable attack SFX; accepted damage plays a hit SFX while invulnerable/parried hits remain silent (shield absorption may have its own/received-hit feedback once, never duplicate). Use existing licensed SFX assets and SFX bus. After combo completion, a short attack-only cooldown rejects attack presses, but movement, jump, carry, parry, skill and dash can act; movement can leave the recovery phase, and dash immediately cancels the current attack with hitbox/weapon cleanup. Dash cooldown/stamina/invulnerability rules remain unchanged. No unrelated combo damage/timing, movement speed, camera, map, enemy AI or input bindings change.

Planned checks: inspect all call sites and resource paths; Godot input/playtest for per-strike and charged swing SFX, accepted hurt/parry/invulnerability/shield paths, movement and dash during combo recovery, dash cancellation during active strike, restored hitbox/weapon, and attack-only cooldown boundaries. Preserve all incoming dirty work. No implementation or runtime result claimed yet.

N10 implementation update (2026-11-25): `player_state.gd` gates only attack starts on `attack_input_cooldown`; `player.gd` ticks the timer and plays accepted-hit feedback for Ice Shield absorption; `weapon_attack.gd` plays swing feedback on each normal/charged attack and exits completed combos to Idle with a 0.5-second attack-only cooldown. Dash priority remains first in AttackState._update, so active strikes still permit dash cancellation and its existing cleanup path. `battle_vfx.gd` maps both sounds to existing SFX assets. Static diff check passes. Required Godot runtime combat/input/audio playtest remains NOT RUN; no test added or run. N10 is implemented but not runtime-verified.

N09 latest user correction (2026-11-25): supersedes the preceding XP-retention note. Death must roll XP/level back to the most recent checkpoint; retaining XP is the bug the user wants fixed. The earlier intent to discard post-checkpoint gains is reinstated. Unlock flags remain preserved. No XP rollback code has been implemented yet; it stays within the shared GameManager approval boundary.

N09 approval/status update (2026-11-25): user confirms Lam approved the new shared save/checkpoint boundary. Proceed with a v1-compatible `checkpoint_progress` snapshot and durable defeated-slot flags inside existing `GameManager.flags`. Latest XP rule is rollback-to-checkpoint, superseding both earlier retention notes. Preserve story/unlock flags; do not serialize enemy health.

## N11 — Enemy attack and hurt SFX (2026-11-25, before implementation)
User adds that enemies also need attack and received-hit SFX. Duy's approval for enemy ownership changes was previously confirmed by the user. Acceptance: common enemy attack animations (melee, ranged, spell and dive) play an attack cue when they begin; enemy HP loss plays one hurt cue, including lethal hits, but ignored damage does not. Reuse existing SFX assets and SFX bus; no AI/attack timing/damage/map changes.

Planned checks: inspect attack animation naming across existing enemy families; statically verify the common EnemyCharacter hook recognizes those names and successful damage; Godot combat playtest for enemy attack/hurt audio, enemy death, mute/volume behavior. No implementation/runtime result claimed at planning time.

N09–N11 implementation status (2026-11-25): implemented in source, runtime verification still required. Latest user clarification: death reloads both player progress and enemy camps from the newest checkpoint. Player XP/level/collected-EXP and inventory are restored from the checkpoint snapshot; enemy defeated-slot flags are restored to their checkpoint baseline. Consequently enemies defeated after that checkpoint return on death, while camps already cleared by the checkpoint remain cleared. Other world/unlock flags are preserved. User reports Bao, Duy and Lam approved their applicable boundaries; this records the user's report, not independent reviewer sign-off.

Included implementation files and purpose:
- `ui/inventory_menu.gd` removes the Cheat tab and routes Inventory only through B; `ui/cheat_menu.gd` adds the separate P overlay and existing test/enchant actions; its generated `.uid` sidecar is retained.
- `levels/objects/enemy_zone/enemy_zone.gd` creates a finite set of spawn slots and stores defeated slots instead of replenishing kills. On stage reload, defeated slots follow the latest checkpoint snapshot.
- `scripts/autoload/game_manager.gd` captures XP/level/collected EXP, serialized inventory and defeated EnemyZone slots with each accepted checkpoint; death restores those values and preserves unrelated world flags in the existing version-1 payload/flags structure. Existing saves without a snapshot use their loaded state as the initial baseline.
- `scenes/player/battle_vfx.gd`, `scenes/player/player.gd`, `scenes/player/states/player_state.gd`, and `scenes/player/states/weapon_attack.gd` add Player swing/hurt sounds, an attack-only 0.5-second cooldown after a completed combo, and restoration to normal animation/state while movement resumes. Dash remains available during an attack through the existing first-priority dash path.
- `scripts/enemy.gd` adds attack cues on common enemy attack-animation starts and a hurt cue after accepted HP loss, including lethal hits. `battle_vfx.gd` maps those cues to existing OGG assets.
- This task entry, `specs/001-integrate-basement-stage/validation.md`, and `docs/project-changes-2026-11-14.txt` maintain the cumulative implementation and verification record.

Acceptance checklist: P menu is separate from Inventory; each camp has one finite spawn set; death restores player XP/inventory and camp defeat state from the latest checkpoint; world unlock flags remain; Player/enemy attack and hit sounds are mapped; post-combo lockout applies only to attack and dash can interrupt attacks. Implementation is present; runtime acceptance is not yet established.

N10 parser fix follow-up (2026-11-25): renamed the new `PlayerState` sound helper constant to `PLAYER_HIT_FX` so derived combat states can keep their existing `BattleFX` constant without an inherited member collision. `git diff --check` passes for the changed script. Godot parsing/runtime was not run; parser acceptance remains to be confirmed in the editor.

## N12 — B1 clear chest restore and B3 boss chest (before implementation, 2026-11-25)
User requests the B1 clear chest to appear after all active floor zones are cleared, and an equivalent loot chest after defeating the B3 Dark Fairy boss. Static source findings: `basement_floor_visibility.gd` only connects EnemyZone.cleared and never checks already-cleared zones on scene load; the active `basement_full.tscn` has a B1 ChestSpot marker. `basement_b3.tscn` uses `clear_portal.gd` for the boss terminal signal but has no `clear_reward` marker/path. `clear_portal.gd` already instantiates the existing `floor_clear_chest.tscn`, but the chest ID needs to be unique for B3. Acceptance: B1 spawns exactly one existing chest when every configured, spawnable quota zone is clear, including on reload with persisted clear state; Dark Fairy terminal defeat creates one chest at the boss reward marker, using a separate persisted chest ID. No boss AI/health/animation changes. Static diff/reference inspection and `git diff --check`; Godot runtime remains NOT RUN unless requested. Incoming changes in `basement_full.tscn` (B1/B2 enemy placements and Player transform) must be preserved.

N12 implementation update (2026-11-25): `levels/level_1/basement_floor_visibility.gd` now checks B1's configured EnemyZones after load as well as on each `cleared` signal, skips zones with no enemy scene/no finite clear quota, and avoids adding a duplicate FloorClearChest. This covers clear state restored from save where no new signal fires. `levels/objects/door/clear_portal.gd` now accepts an optional unique chest ID while preserving the prefab default for existing portals. `levels/level_1/basement_b3.tscn` configures a ClearReward marker at the Dark Fairy arena and unique `basement_b3_dark_fairy` loot state, using the existing terminal clear signal and chest prefab. No boss code or incoming `basement_full.tscn` edits were changed. `git diff --check` passes. Godot parser, first-clear/reload chest display, boss defeat, loot interaction and reward persistence have not been run; N12 remains runtime-unverified.

## N13 — Single action camera, movement facing and held equipment (2026-11-26)
Before implementation: user requests replacement of all camera modes/settings with one elevated diagonal LoL/Hades/Diablo-inspired view. Clarification: character faces movement rather than mouse, and holds the equipped weapon in hand. Bao Player/camera/presentation boundary; shared settings and pause UI change only to retire camera controls. Preserve Stage target/Camera3D/snap interface, combat damage/timing, maps/enemies/progression/save format. Acceptance: yaw45/pitch50/FOV35/distance22 stay fixed under F2/mouse/wheel/legacy settings; no camera options/FPS presentation; screen-relative movement controls facing and idle keeps last direction; skill pointer aim stays separate; visible hand grip without idle float, attacks restore held pose. Required checks: isolated rendered Godot input/follow/teleport/obstruction/weapon/menu/story tests, captures and diff/dependency checks; full-map/manual feel and owner review remain pending unless actually performed. Baseline working tree clean. Existing test files will be retained and migrated, not deleted. No independent reviewer agreement claimed.

N13 staged implementation update: Player body facing now follows movement; pointer/held skill aim no longer turns it. `scenes/player/player.gd` changes those facing paths and ultimate equipment placement; `scenes/player/player.tscn` replaces the old rear weapon transform; `scenes/player/weapon/floating_blade.gd` keeps its existing resource identity but replaces float/sway with a hand grip and retains attack/temporary-pose APIs. `scenes/camera/camera_rig.gd` locks the runtime view to yaw45/pitch50/distance22/FOV35, disables F2/orbit/wheel changes and no longer creates FPS overlays; legacy signatures are temporarily retained for dependent fixtures. `scenes/camera/camera_rig.tscn` matches FOV35. `levels/level_1/basement_b3.tscn` removes only its two old camera overrides, with no geometry/encounter edits. `scripts/autoload/game_settings.gd` ignores/removes camera preference keys; `ui/pause_menu.gd` removes camera sliders and updates control help. `tests/fixed_action_camera_check.gd` and `.tscn` add isolated rendered Player/input/follow/weapon/menu/legacy-preference coverage. `tests/settings_menu_check.gd` retains its UI/audio/bindings/restart checks with fixed-camera expectations; `tests/weapon_presentation_check.gd` retains equipment/throw checks with held-grip expectations. This task/validation/change record tracks the work.
Verification in progress: isolated copy import is running; no runtime pass claimed yet. A broad rewrite/deletion of obsolete fixtures was rejected by automatic review, then an API-breaking replacement was rejected, then fixture stubs were rejected; none executed. Safer staged edits preserve the existing test files/signatures while adding substantive new coverage. No source cache/real user data intentionally changed, no generators, commit/push or reviewer sign-off. Remaining work: rendered suite, screenshots, dependency cleanup and final evidence; old multi-view acceptance is historical and no longer current product acceptance.

N13 verified follow-up and integration correction: the simplified single-camera candidate was first tested only in the disposable project (45/45 rendered checks, no script/parse errors), then copied into production. TPS/FPS runtime branches, shoulder orbit, mouse capture and FPS body/weapon layers are removed. `scenes/camera/camera_view_overlay.gd` and `first_person_weapon.gd` retain only hidden inert resources to preserve their UID/path; Player's FPS-only adapter and AttackState's FPS-only pose serializer are removed in `scenes/player/player.gd` and `scenes/player/states/weapon_attack.gd`. Legacy enum names/data/no-op signatures in CameraRig remain only for historical fixture/resource compatibility; they are not exported settings and cannot activate another view.
The initial rendered run found a teardown viewport error in held-weapon cleanup; `floating_blade.gd` now guards scene exit. Visual review also corrected the hand anchor to Foxy's real billboard hand pixels and each texture's actual axis rather than a world-height approximation. All five weapon types were inspected in rendered captures. The new story regression reproduced a camera-near clipping failure; `levels/level_1/basement_story.gd` now snapshots/restores the near plane and resets it for the existing ladder shot. A first all-map fixture accidentally loaded the unused `stage_1_garden.tscn`, which has missing resources; it was corrected to the actual `garden.tscn` without editing either map. A 55/55 actual-map pass then revealed partial hat occlusion in the B3 screenshot; CameraRig now also probes the billboard top when choosing the cutaway near plane. Focused B1/B2/B3/Garden visibility regression passes 12/12 and the updated B3/Garden images were inspected. The unchanged camera angle/distance and full Player silhouette are visible. The final complete suite and UI/depth checks are in progress; no final all-pass aggregate claimed at this point.
`tests/topdown_weapon_depth_check.gd` retains every existing depth sample and aligns facing to the new camera; its legacy TPS request now checks that the fixed view and safe front layering remain. Earlier rendered depth run: 177/177, no script/parse errors; it predates the additional hat probe. `tests/fixed_action_camera_check.gd.uid` is copied from Godot's generated test resource identity, not a manually invented UID. `docs/validation/fixed-camera-2026-11-26/` is the evidence directory; per-file final inventory follows when verification completes. Historical three-mode suites are retained as historical evidence, not claimed passing/current acceptance. No source cache, map generator, save format, enemy implementation, commit/push or independent reviewer agreement.

N13 orientation clarification (2026-11-26): user explicitly wants the camera looking from left to right like LoL. This supersedes the earlier +45-degree yaw choice. Acceptance before this small follow-up: camera sits on the negative-X/positive-Z side at yaw -45 degrees, keeps pitch50/FOV35/distance22, and screen-relative movement/facing, hand grip and cutaway remain correct. `scenes/camera/camera_rig.gd` mirrors the fixed yaw and matching movement basis; `tests/fixed_action_camera_check.gd` checks the corrected signed yaw. All earlier +45-degree rendered results remain historical; rerun camera/depth and inspect all-map screenshots before claiming the corrected orientation verified. No gameplay rule, settings, map geometry or ownership boundary changes.

### N13 final implementation and verification (2026-11-26)
Status: implemented and focused runtime-verified; independent reviewer acceptance and native full-map traversal remain pending. Final user-approved direction is LEFT TO RIGHT, yaw -45 degrees; earlier +45-degree results are superseded for camera orientation. Final rendered runs use Godot4.7.2 Compatibility/ANGLE, AMD Radeon780M and disposable custom user directories. Camera59/59, weapon depth177/177 and equipment40/40 all PASS at final yaw, ENGINE_EXIT_CODE=0, no script/parse/compile errors. UI/settings53/53 and fresh-process restart2/2 PASS, exit0; these ran immediately before the final yaw-sign-only change and their production code is unchanged. Stable camera anchor error is recorded in camera-runtime.log. Updated B1/B2/B3/Garden, held-weapon, settings and ladder images inspected. git diff --check PASS (line-ending notices only).
Included source/resource files and purpose: scenes/camera/camera_rig.gd is the sole active fixed view, cutaway/head visibility and screen-relative movement basis; camera_rig.tscn sets matching FOV35; camera_view_overlay.gd and first_person_weapon.gd retain only hidden inert UID/path resources. scenes/player/player.gd removes pointer-driven body facing and FPS-only presentation and keeps ultimate equipment in hand; player.tscn replaces the rear weapon transform; states/weapon_attack.gd removes only its FPS-only serializer, preserving combat; weapon/floating_blade.gd retains its UID while implementing a stable billboard hand grip, correct texture axes, attack-pose compatibility and safe teardown. scripts/autoload/game_settings.gd removes camera preferences/application; ui/pause_menu.gd removes camera controls and updates help. levels/level_1/basement_b3.tscn removes only old camera overrides; basement_story.gd saves/restores/reset the near plane for the existing ladder shot. No map geometry or encounter edits.
Included fixtures/docs: tests/fixed_action_camera_check.gd, .gd.uid and .tscn supply the isolated rendered suite and Godot-generated script identity; tests/topdown_weapon_depth_check.gd keeps all pose/depth samples with view-relative directions and inert-mode expectation; tests/weapon_presentation_check.gd keeps equipment/throw/scale checks with held-rest expectations; tests/settings_menu_check.gd keeps53 UI/binding/audio/display checks, removes camera-preview expectations, uses verified unused H instead of occupied B/K, checks visible cursor and restart persistence. docs/camera-views-2026-11-19.md records the superseding view/controls/evidence; specs/001-integrate-basement-stage/tasks.md and validation.md record scope, results and pending review; docs/project-changes-2026-11-14.txt is the cumulative file-level record.
Evidence inventory under docs/validation/fixed-camera-2026-11-26/: camera-runtime.log and camera-errors.log are the final59-check run; depth-runtime.log and depth-errors.log the final177 samples; equipment-runtime.log and equipment-errors.log the final40 equipment checks; settings-runtime.log/settings-errors.log and settings-restart-runtime.log/settings-restart-errors.log the53+2 UI/restart checks. initial-runtime.log/initial-errors.log preserve the first43/45 and teardown error; story-before-runtime.log/story-before-errors.log preserve the46/47 near-plane reproduction. orientation-before-runtime.log/orientation-before-errors.log and orientation-before.png preserve the superseded +45-degree result. fixed-basement.png is the integrated startup view; fixed-basement_b1.png, fixed-basement_b2.png, fixed-basement_b3.png and fixed-garden.png show authored stages at final orientation; fixed-ladder-story.png shows the cinematic integration; fixed-settings.png shows removed camera controls; fixed-grip-starter_blade.png, fixed-grip-sword.png, fixed-grip-axe.png, fixed-grip-spear.png and fixed-grip-dagger.png show held grips for all five weapon types.
Shared effects/limits: Stage target/Camera3D/snap contract, input actions, combat timing/damage, save version1 and owner systems remain. Camera's foreground technique clips a whole near plane rather than fading individual world objects; native full-route/long-session feel and all charged/contact variants remain untested. Historical three-mode fixture bodies remain unchanged as historical evidence and are not claimed current/passing acceptance. Known non-blocking diagnostics: existing vendor/stage UID text-path fallbacks, CheatMenu anchor warning, B2 incomplete clear-zone warning and ObjectDB/retained-resource shutdown diagnostics. An unused stage_1_garden fixture path briefly produced pre-existing missing-resource errors; final verification uses the actual garden.tscn and has no missing-resource/script/parse errors. Earlier candidate annotation/type errors were confined to validation and corrected; no final such error. Auto-review-blocked broad rewrites/deletions were not executed; safe API-preserving candidate validation resolved the implementation path. No real save/settings or source .godot cache touched by test runs, no generators, no commit/push and no invented teammate agreement.

## N14 — Cleanup around Basementfull, Garden and Castle (2026-11-26, before implementation)
User explicitly requests removing everything unrelated to the three primary gameplay scenes: levels/level_1/basement_full.tscn, garden.tscn and castle.tscn. Audit scope: resolve runtime paths/UIDs, global GDScript classes, relative glTF resources and dynamic asset-directory loads; distinguish live dependencies, related regression/authoring infrastructure, obsolete scenes/tests, unused vendor variants and editor temporary duplicates. Keep governance, cumulative evidence, existing dirty camera work and tracked cache; `.godot/uid_cache.bin` is already dirty at the start of this cleanup and must not be discarded/hand-edited. No generators, commit/push or teammate approval invented.
Acceptance/check plan: retain all three roots and every direct/transitive/dynamic resource required by their Player/enemy/UI/inventory/skills/farming/dialogue/save systems; no missing dependency in the post-cleanup audit; import and rendered isolated smoke/playtest of all three roots, plus relevant transition/save checks if routing is changed. Produce a concrete per-file manifest with reasons/hashes and a recoverable snapshot before deletion; validate absolute paths within D:/VNG/ProjectVNG and never delete protected metadata/caches or incoming dirty files. Current design question: Garden still returns to the standalone B3 scene and GameManager supports B3 checkpoints; user clarification is pending whether to keep this dependency or change the route to exactly Basementfull ↔ Garden ↔ Castle. No routing/B3/save changes until that answer. Independent unreferenced-file audit can continue. Ownership/review boundary: cleanup of disconnected resources is user-requested; active Lam/Quan maps/shared save and Duy enemy behavior remain unchanged unless concretely authorized by the resolved cleanup design. No independent review claimed.

## N15 — Mouse-directed skills with movement-directed body facing (2026-11-26, before implementation)
User clarification during N14 cleanup: skills must aim/cast toward the mouse, not the character's movement facing. Bao Player/skill boundary explicitly requested. Preserve movement-facing, camera, damage, cooldowns and non-directional/self-centered effect rules. Scope: tap and held skill input snapshots, direct directional/projectile aim fallback, ultimate aim through the existing cinematic, matching directional cast VFX and focused rendered regression. Acceptance: pointer opposite to facing produces the pointer-directed cast for both tap and hold; changing pointer after release does not redirect a committed cast; body facing remains movement-driven; directional ultimate survives the paused cinematic with the original pointer target; no skill/cooldown/dash cleanup regression. Existing circle/global buffs and Wind ultimate's authored target/orbit behavior are not re-designed by this generic aim correction. No teammate agreement claimed. N14 cleanup remains active and must preserve this skill work plus B3 as confirmed by the user.

## N16 — Correct Blade hand and straight default weapon throw (2026-11-26, before implementation)
User reports reversed Blade grip and requests the default skill throw straight for a limited range, stopping on wall/enemy, dealing damage on enemy contact, then falling and planting in the ground. Preserve the immediately preceding mouse-aim clarification: "forward" means along the cursor aim ray, while the body keeps movement-facing. Reuse the existing7m fallback reach and14m/s throw speed, F pickup, inventory UID, cooldown and version2 drop record; no new save schema or enemy AI changes. Scope: held grip side/texture axis, SkillState's default throw launch, thrown_weapon flight/first-contact fall/visual and focused rendered collision/pickup regressions. AC: constant flight height until first contact/range end; first enemy receives weapon damage once and stops the throw; walls block enemies behind; landed weapon is grounded/planted and recoverable; pointer can differ from body facing; original item/texture/scale ownership retained. Validation is pending; no fixed/accepted claim yet. N14 staged cleanup has not deleted source files and must incorporate this new gameplay work before its final smoke test.


### N14–N16 implementation group ready to apply (2026-11-26)
User confirms B3 must remain. The four retained maps are basement_full, basement_b3, garden and castle; gameplay helpers, related regression fixtures, authoring generators for active libraries, pixelfx authoring library, attribution and import boundaries are preserved. The staged pruned project was imported without relying on source cache; Godot binary dependency inspection retained the OBJ referenced indirectly by basement_library.meshlib. Staged rendered results: complete gameplay93/93, focused mouse28/28 and straight throw10/10, engine exit0, no missing-resource/script/parse/compile errors in final runs. Earlier preliminary audit/import failures were corrected before source deletion. The archive C:/Users/BaoHo/AppData/Local/Temp/ProjectVNG-cleanup-20261126-0648a9dd.zip contains all 11799 planned removed files and each entry was verified against its recorded SHA256; source deletion is not executed yet.

Included edited files/purpose: levels/objects/door/clear_portal.gd removes only the obsolete return override into standalone B2; authored B3↔Basementfull and Garden/Castle links remain. scenes/player/player.gd makes tap/held/direct skill aim use cursor targets, snapshots ultimate aim through cinematic, and chooses Wind ultimate eligible target by cursor proximity within the existing8m range. scenes/player/states/skillstate.gd uses the committed cursor direction for cast VFX and the default straight7m weapon launch, saving a safe launch-floor fallback for an in-flight drop. scenes/player/thrown_weapon.gd removes the arc/spin, caps reach, stops at first enemy/world contact, deals damage once and falls/plants with existing UID/F pickup/save record. scenes/player/weapon/floating_blade.gd corrects front/back hand side and outward tilt. ui/player_hud.gd names/describes Ném vũ khí; ui/skill_tree_layout.gd describes cursor-selected Wind target; ui/pause_menu.gd explains both quick/held mouse casting. tests/fixed_action_camera_check.gd adds mouse/cinematic/default-throw/route tests and actual retained-map matrix; tests/low_throw_check.gd verifies straight height,7m bound, first enemy stop, walls, floor and pickup. tools/audit_gameplay_cleanup.mjs is the non-destructive repeatable dependency audit. README.md documents current maps, controls and cleanup recovery. specs/001-integrate-basement-stage/tasks.md and validation.md retain plan/results; docs/project-changes-2026-11-14.txt records this cumulative group.

Per-file removal inventory follows. Every entry is backed up and absent from the validated runtime/related-tool closure. Status for this list at creation: PREPARED, not yet deleted; the subsequent final result determines whether this entire guarded group applied.

Full per-file removal inventory: docs/project-changes-2026-11-14.txt and docs/validation/gameplay-cleanup-2026-11-26/cleanup-manifest.json. No original save/cache/generator execution or teammate sign-off.


### N14–N16 final results — 2026-11-26
N14: APPLIED and focused-verified. Every one of the 11799 PLANNED DELETE entries listed above was removed from the source project;0 listed files remain. Removed bytes: 331334918 (approximately331.3MB /316.0MiB). Only basement_full.tscn, basement_b3.tscn, garden.tscn and castle.tscn remain as the level_1 map scenes. B3 was explicitly retained by the user. All5 root metadata files, project instructions/history, active asset-authoring sources, related regressions and all live/dynamic dependencies remain. Post-cleanup audit:0 unresolved production resources;2,993 non-cache resource/code files match the pruned rendered-validation project byte-for-byte. The already-dirty tracked uid_cache.bin remains byte-identical to the pre-delete hash (ef47bf179ac156d67c11d30b3e33ab52242dd5beb039d3822a284aacfc3db3aa); it was not reset/hand-edited. No generators or real save/settings operations were run.
N15: implemented and rendered-verified. Tap and hold both commit the cursor target; moving the cursor afterward does not redirect an emitted projectile or turn the movement-facing body. Direct casts refresh cursor aim. Directional ultimate retains the original pointer target through its paused cinematic; Wind orbit chooses the cursor-nearest living enemy within its existing8m eligibility range. Existing self-centered/global/buff effects keep their shape rules. The first eight failed directional expectations were a fixture buffering issue: the fixture moved the pointer before buffered release input dispatched. Flushing input and setting the intended pointer immediately at release reproduced/verified the intended frozen target; final traces show exact target/direction agreement.
N16: implemented and rendered-verified. Blade now uses the correct front/back hand side and outward tilt; four-direction images were inspected. Default neutral skill throws the actual equipped weapon straight along mouse aim for7m at14m/s, with no arc/spin. First enemy contact deals existing weapon damage once and stops flight; solid walls stop flight and block enemies behind. Weapon then drops/plants on a floor, retaining its UID and existing F pickup/version2 flag structure. In-flight save fallback is the safe launch floor; actual landing updates the existing record. No save schema or enemy AI change. HUD now names Ném vũ khí, uses the equipped item icon and describes the7m/block/fall/pickup behavior. Pause help explains quick/held mouse aim; Wind tooltip reflects cursor selection; README records the four-map scope and restore location.
Final rendered Godot4.7.2 Compatibility/ANGLE results on disposable pruned project: full retained gameplay95/95 PASS, straight throw10/10 PASS, equipment40/40 PASS, final UI/stage smoke15/15 PASS; all engine exit0, no final missing-resource/script/parse/compile errors. Focused mouse28/28 is also retained, covered again by the complete95 run. These exercise actual Player/HUD/FSM, four elements tap/hold, cinematic aim, Wind cursor selection/range, hand/attack/dash restoration, neutral throw direction/range/ground/pickup, real enemy damage, wall blocking and all four retained maps/route metadata. Complete manual campaign traversal, defeating every camp/boss, every charged/contact combination, cross-platform export and independent reviewer sign-off remain NOT RUN/not supplied. Existing UID fallback, CheatMenu anchor, B2 quota and retained-resource/ObjectDB shutdown diagnostics remain; not declared fixed. A cold first import needed script-class registration and exposed a missing .gdignore/indirect binary OBJ dependency; both were corrected in the staged project before source deletion. No final such error remains. Some untouched historical fixture methods retain retired-mode/legacy-scene assumptions and are not claimed current/pass coverage.
Backup: C:/Users/BaoHo/AppData/Local/Temp/ProjectVNG-cleanup-20261126-0648a9dd.zip; archive SHA256 4895adb09bf2dc6a404addcfb3d3ec76163ee8fbc3c784ee9481cf43eb169eb6. All 11799 entries were individually verified against their manifest SHA256 before deleting any source file. This is outside the game project; use the full paths in cleanup-manifest.json to recover exact files if needed. No commit/push, no teammate acceptance invented.
Evidence inventory/purposes under docs/validation/gameplay-cleanup-2026-11-26/: baseline-status.txt preserves initial dirty state; audit-summary.json and pre-cleanup-dependency-audit.json preserve the reviewed closure; binary-dependencies.json records Godot-resolved indirect mesh dependencies; cleanup-manifest.json contains each deleted path, purpose/category, byte size, SHA256, backup path/hash and final status; cleanup-paths.txt is the exact removal list; dependency-audit.json, retained-paths.txt, candidate-paths.txt and post-cleanup-audit-summary.json reflect the remaining closure; post-cleanup-verification.json records no missing production files and exact staged/source content agreement. gameplay-runtime.log/gameplay-errors.log record final95 checks; straight-throw-runtime.log/straight-throw-errors.log the10 collision/range/ground/pickup checks; equipment-runtime.log/equipment-errors.log the40 equipped-texture/scale/throw checks; stages-ui-runtime.log/stages-ui-errors.log the15 final UI/map checks; mouse-runtime.log/mouse-errors.log focused28 mouse checks and traces; import-final.log the successful staged import; initial-gameplay-runtime.log/initial-gameplay-errors.log preserve the pre-fix fixture/binary-dependency failures. fixed-facing-down.png, fixed-facing-up.png, fixed-facing-left.png and fixed-facing-right.png show corrected hand side/grip; fixed-default-weapon-planted.png shows the landed weapon; fixed-basement_full.png, fixed-basement_b3.png, fixed-garden.png and fixed-castle.png show the retained authored stages with final UI/camera. No other evidence file is an acceptance claim.

## N17 — Secret-room support and opaque wall occlusion (2026-11-26, before implementation)
User reports falling when entering the secret room and walls looking penetrable near Player; requests preserving walls so they occlude hidden content. This supersedes the earlier camera foreground/hat cutaway acceptance. Scope: inspect B1_5 floor collision/support and existing gate traversal; smallest scene-local support repair if reproduced; remove camera near-plane cutaway while preserving fixed left-to-right view, movement-facing, mouse skill aim and solid authored walls. Do not change shared mesh libraries, enemy/save/combat behavior or execute any map/library generator. Current dirty camera/cleanup/skill work and dirty .godot caches are pre-existing and protected; no cleanup/revert.
AC/check plan: reproduce in an isolated rendered Godot actual-basement fixture; show that closed secret gate and ordinary wall block movement, open the existing secret wall using its existing hit rules, then walk into/through/back out of the room without falling; inspect downward rays and library shape/AABB evidence to locate missing support. Camera must keep near=0.05 and fixed yaw/pitch/distance near obstacles; opaque foreground wall must render in front of Player (pixel/capture verification), rather than being clipped/faded or making all actors visible through it. Existing breakable gate, chest/notebook, floor switching and authored wall/collision data are preserved. Focused runtime regression, representative retained-map render checks and diff checks required; native full campaign/independent review remain pending unless actually done. Owner/review boundary: user-requested Bao camera + local Lam/Quan map repair at the reported secret room, no separate teammate sign-off claimed.

### N17 implementation and focused evidence — 2026-11-26
The user clarified the fall happens immediately when walking through the entrance. Baseline rendered check reproduced the wall defect (near19.600027 and white rather than opaque-green center pixel), but did NOT reproduce an actual physical fall on the center route: minimum Player Y1.000836, reached notebook/chest/return, existing authored floor shapes present at Y1.0. The first attempt drove on the wrong fixture axis; correcting its 2D-to-3D yaw inverse verified the actual entry route. Do not claim an observed missing floor or proven original fall root cause. Scene-local prevention now adds two invisible solid floor volumes under the existing B1_5 room (x40..58,z4..24) and doorway (x38..40,z8..18), topY1.0, matching authored visible floor and not replacing any wall/cell/library. Room reveal uses the existing saved b1_secret_wall_broken flag as well as the legacy inside-room condition; once the gate opens, the floor/room renders before Player crosses the threshold. Normal same-floor visibility and hidden ceiling rules remain.
Camera foreground and hat near-plane cutaway was removed: fixed view now keeps near0.05 and lets opaque walls cover Player normally; angle/distance/FOV and movement-facing/mouse skill aim are preserved. Baseline8/10 becomes final focused18/18, rendered engine exit0. Physical movement traverses center and z9/11/15 doorway lanes both directions, reaches chest and returns, reloads the isolated save into a fresh Stage and walks in again; minimum Y remains at floor level.741 downward samples over entry/room strip have0 unsupported points. At z17 the authored non-gate wall correctly blocks entry: an initial17/18 result assumed this edge was open, then the fixture expectation was corrected without removing the wall. The separate ordinary wall and closed five-hit gate still block real movement. Opaque-green wall visibly covers screen-center Player (pixel test and inspected capture), camera fixed basis/offset unchanged. Full retained-map/gameplay regression is running; final status not yet recorded here. No real save, source cache edits, generators, commit/push, or independent sign-off.
Included implementation: scenes/camera/camera_rig.gd (normal depth occlusion); levels/level_1/basement_full.tscn (local collision backing and reveal metadata only); levels/level_1/basement_floor_visibility.gd (show opened room before crossing threshold); tests/secret_room_walls_check.gd and .tscn (isolated rendered entry/wall/save checks); tests/fixed_action_camera_check.gd (supersede old cutaway/clear-hat expectations with normal near-plane contract); tools/audit_gameplay_cleanup.mjs (retain new related regression in future dependency audits). Map GridMap cell data, meshes/materials, breakable-gate hit/save rules, notebook/chest, enemy/combat code and shared libraries are unchanged by N17. Existing tracked .godot/global_script_class_cache.cfg, scene_groups_cache.cfg and uid_cache.bin changes are preserved rather than reset; no claim that those were authored by this group.

## N18 — Conditional occluding-wall fade (2026-11-26, before implementation)
User refines N17: retain opaque walls normally, but fade walls between camera and Player when they hide Player. This supersedes only N17's always-opaque screen-center assertion; N17 floor support/reveal and physical wall/gate preservation remain. Owner/review boundary: user-authorized Bao camera presentation, no new map/library/save/enemy authoring changes or teammate acceptance. Plan: runtime-only per-cell visual proxies for intersecting GridMaps (source cells/collision remain intact), per-instance copied StandardMaterial3D alpha for occluding wall cells/solid mesh obstacles, smooth fade/restore; normal camera near0.05, fixed perspective unchanged. Do not change shared materials/MeshLibraries or run generators. Checks: rendered wall normally opaque, fade only along Player sightlines, Player visibly readable, other cells remain opaque, walls behind Player unchanged, collision remains during fade, restore after moving away/camera takeover, gate clearing invalidates proxies, no source cell/material mutation; retained four-map and gameplay checks. Baseline N17 focused18/18 and gameplay95/95 are verified for the earlier opaque contract, not N18 acceptance. Implementation/runtime verification pending.

## N17–N18 FINAL implementation/verification — 2026-11-26
Current user requirement is conditional wall fade (N18), superseding N17's temporary always-opaque Player-occlusion test. N17 local floor backing and opened-room reveal remain implemented. Status: implemented and rendered-runtime verified on the disposable Godot4.7.2 Compatibility project; no independent reviewer agreement/teammate acceptance or full-campaign acceptance claimed. No commit/push.
N18 behavior: normal near0.05 and fixed yaw-45/pitch50/distance22/FOV35. Wall tiles whose mesh bounds intersect foot/body/head sightlines between camera and Player smoothly fade to22% opacity, then restore. Other wall tiles, walls behind Player and physical collisions remain. GridMap wall presentation uses temporary per-cell mesh visuals while original cells and collision stay intact; standalone solid meshes use local duplicated BaseMaterial3D surface materials. Source MeshLibraries/materials are not edited. Original batched GridMap visuals/material overrides/shadows are restored when no longer occluding, on camera takeover and at teardown. Breakable gate cell removal clears temporary visuals; no stale ghost wall. Existing floor ancestor visibility applies to temporary visuals, and original authored cell scale/orientation/library mesh offset are preserved. Registry refresh is0.25s and fade/restore transitions are gradual.
Final rendered results: secret-room actual Stage19/19 PASS (engine exit0); focused conditional wall fade16/16 PASS (exit0); complete retained gameplay/camera95/95 PASS (exit0), including all4 retained maps and previous movement-facing, mouse skill aim, ultimates, held grip, neutral throw, menu/story and route contracts.741 support samples have0 holes across the doorway/room strip. Actual walk-through center and z9/11/15 lanes, chest and return, and saved-open reload all retain floor height; the authored z17 edge wall correctly blocks movement. A real B1 wall at Player(41,1.2,19) fades2 cells and remains solid; its inspected screenshot shows readable Player and adjacent opaque walls. The synthetic stacked-wall test confirms Player pixels visible, two blocking tiles fade, three off-axis tiles remain opaque, shared material alpha stays1 and physical ray still hits original GridMap. Matrix captures for Basementfull/B3/Garden/Castle were inspected/retained. Source/staged9 implementation/fixture files hash-match; all authored GridMap cell arrays equal HEAD;3 shared basement library hashes match the unmodified staged libraries. Node syntax and scoped git diff --check pass.
Initial issues are preserved as evidence, not hidden: first load discovered3 authored references to missing item34; the presentation scanner now skips missing library items without editing authored cells. An initial14/15 fade run exposed typed iteration over freed Node keys; untyped validity guards now handle deleted maps/meshes and restore safely. Its subsequent bool inference compile error was corrected before final runs. An initial18/19 authored-wall run used a red-channel-only pixel threshold that assumed a front-facing white Player; Player was visibly revealed but back-facing blue. The final comparison checks actual alpha compositing against the unobstructed Player pixel, independent of facing/color; final blend error is recorded in audit. No final parse/script/compile/missing-resource/missing-item error remains.
N17 fall limitation: baseline physical falling was NOT reproduced on the center walking route; existing thin authored floor shapes were present atY1.0. The two local solid volumes are prevention/backing against reported entry falling, and reveal-on-open eliminates the initially hidden room floor. Do not claim an observed original missing-floor cause. Final tested routes do not fall. Full manual campaign, all corner/dash/jump/save permutations, cross-platform exports, performance profiling and independent reviewer acceptance are NOT RUN. Fade works per mesh/tile bounding volume, not a pixel-perfect hole mask; custom ShaderMaterial surfaces are preserved rather than rewritten and are outside the supported BaseMaterial3D fade path. Authored wall transforms/material appearance were verified; runtime editing of a shared MeshLibrary or changing only an existing cell's item/orientation without changing its cell coordinates is outside this static-map cache contract. Existing UID fallbacks, CheatMenu anchors, B2 quota and ObjectDB/resource-in-use shutdown diagnostics remain and are not declared fixed. No source caches were hand-edited/reset, no generators or real user saves/settings used; prior cleanup deletions and unrelated dirty work remain.
Included source/document files and purposes:
- scenes/camera/camera_rig.gd: normal near plane, instantiate local wall-occlusion helper, retain fixed view/aim/follow contracts.
- scenes/camera/wall_occlusion.gd: new runtime-only selective tile/solid-mesh fade, material isolation, smooth restoration, gate/cache/teardown handling.
- levels/level_1/basement_full.tscn: two local B1_5 floor support volumes at authoredY1.0 and existing-gate reveal flag metadata; all wall/cell data preserved.
- levels/level_1/basement_floor_visibility.gd: reveal opened secret room from its saved flag before crossing threshold; retain floor/roof ownership.
- tests/secret_room_walls_check.gd and tests/secret_room_walls_check.tscn: rendered real movement/gate/wall/floor/save/opaque-depth/fade regression and capture fixture.
- tests/wall_occlusion_check.gd and tests/wall_occlusion_check.tscn: rendered stacked/off-axis/behind-Player tiles, source scale/material/collision preservation, restore/takeover/gate-deletion and standalone wall fixture.
- tests/fixed_action_camera_check.gd: supersede cutaway and clear-hat assertions with normal depth; keep existing95 gameplay/route checks.
- tools/audit_gameplay_cleanup.mjs: preserve both new related regressions during future non-destructive dependency inventory; no new deletion executed.
- docs/camera-views-2026-11-19.md: current conditional-fade supersession and results; historic camera records retained.
- specs/001-integrate-basement-stage/tasks.md and validation.md: cumulative N17/N18 scope, ownership, implementation, actual checks, failures and remaining limitations.
- docs/project-changes-2026-11-14.txt: cumulative per-file/status/effects/verification record required by AGENTS.md.
Evidence directory docs/validation/secret-room-walls-2026-11-26 contains baseline/temporary-opaque/final-fade and failed-attempt logs, support/pixel audits, screenshots and source/map hash verification. Initial/compile/authored-attempt files are explicitly unsuccessful historical attempts. Final acceptance for this bounded runtime slice is19/19 +16/16 +95/95 only; summaries do not assert designer/reviewer sign-off. Full per-file evidence purposes follow and results.json provides the same inventory.

### N18 integration follow-up — before finalizing (2026-11-26)
Inspecting the retained-map screenshots exposed a remaining readability issue: the standalone B3 roof tiles cover Player with the restored normal near plane. Garden/Castle/Basementfull captures were readable; B3's roof had previously depended on the old near-plane cutaway. The19/16/95 assertions did not check this screenshot content, so they are not sufficient to close that regression. Camera presentation scope now includes overhead flat tiles that actually cross Player sightlines, while preserving support floors below Player. No new authored map/library edits. Add rendered overhead-tile fade and grounded-floor-opacity checks, then rerun conditional fade, secret traversal and full retained gameplay and inspect the new B3 capture before final handoff.

### N17–N18 final integration follow-up PASSED — 2026-11-26
Latest final results supersede the earlier16-case fade summary: fade/restore18/18 PASS, secret room19/19 PASS, complete retained gameplay95/95 PASS; all rendered Godot exit0. The two additional cases verify an overhead flat tile fades when it hides Player and the actual support floor stays opaque. Thin tiles above Player may now fade on a Player sightline; supporting thin floors at/below Player feet remain opaque. No scene/library/collision change was needed for B3. The re-rendered B3 capture was visually inspected and now shows Player through the faded overhead tile; the previous fully covered capture is retained as before-roof-fade-basement_b3.png. Garden, Castle and Basementfull retain their authored view, and final map captures were refreshed. All9 final source/fixture hashes again match the tested project. Final secret audit still reports741 samples/0 holes,2 authored wall cells faded, alpha0.22 and pixel blend error below0.01.
Affected follow-up files: scenes/camera/wall_occlusion.gd adjusts only overhead-vs-support flat tile eligibility; tests/wall_occlusion_check.gd adds the two above/below tile checks. The final runtime/error logs, final4 map captures, final secret captures/audit, source-and-map-verification.json and results.json in the evidence directory were refreshed. New evidence files/purposes: before-roof-fade-basement_b3.png preserves the discovered covered-Player regression; wall-fade-overhead-player-visible.png verifies the synthetic overhead case. Prior failure and temporary-opaque evidence remains historical, not current acceptance. Full campaign/profiling/export/custom-shader/static-library limitations and existing shutdown diagnostics listed above remain; no teammate agreement/commit/push claimed.
Cache observation: current source .godot/uid_cache.bin SHA256 is e8b2d1ada25c2341fe2ba57e4ab76c393462ee19cbd9a00f1ea761d8671442b5, differing from the older N14 pre-delete checksum recorded earlier. No start-of-N17 checksum exists to attribute when it changed. All3 tracked cache files were already dirty when inspected in N17; no cache was hand-edited/reset here, and validation ran outside the source project. Preserve these observed cache changes for owner review; do not treat the earlier N14 byte-identity statement as a current checksum guarantee.

## N19 — Restore KayKit torch dependencies reported by user (2026-11-26)
User provided Godot error screenshot showing missing res://assets/vendor/KayKit_Dungeon/Assets/obj/dungeon_texture.png; cascading failed OBJ import torch_lit.obj and failed scenes/map/torches/torch.tscn parse. Investigation: torch scene references torch_lit.obj; OBJ declares mtllib torch_lit.mtl and its material references sibling Assets/obj/dungeon_texture.png. Cleanup manifest/verified backup identified the exact deleted three files. Restored only Assets/obj/torch_lit.mtl, Assets/obj/dungeon_texture.png and Assets/obj/dungeon_texture.png.import from the existing verified cleanup ZIP; SHA256s match the deletion manifest. Existing torch_lit.obj and .import were already present. Source/staged copies synchronized. Rendered Godot isolated scene instantiates torch.tscn and the actual Basementfull torch; TORCH_RESOURCE_RESULT PASS, exit0. The run's stderr had no missing texture/torch, failed-load, parse, or wall-occlusion invalid-call diagnostics. No cache reset, generators, or unrelated backup extraction.
User additionally reported Invalid call is_visible_in_tree on GridPathfinder in wall_occlusion.gd:92. Cause: Godot type-name search can match a project class named GridPathfinder when asked for "GridMap". Runtime scanner now casts generic matches to actual GridMap and skips other nodes; parent visibility calls are guarded by Node3D. Isolated torch+Basementfull runtime also exercised the scanner with no Invalid call. The immediately repeated full18 fade suite result is to be recorded in this N19 continuation after that process exits. Prior final secret19/gameplay95/map image findings remain; no independent signoff or commit/push. New regression tests/torch_resource_check.gd and .tscn verify torch scene/PackedScene, imported mesh and placed Basementfull torch.
Files: assets/vendor/KayKit_Dungeon/Assets/obj/torch_lit.mtl (OBJ dependency); assets/vendor/KayKit_Dungeon/Assets/obj/dungeon_texture.png and its .import (OBJ material texture/import); scenes/camera/wall_occlusion.gd (type-safe actual GridMap scan and parent visibility); tests/torch_resource_check.gd and .tscn (dependency load fixture); docs/validation/secret-room-walls-2026-11-26/torch-resource-runtime.log and -errors.log (Godot result/diagnostics). Staged project texture inputs match source and backup manifest; cleanup manifest remains historical and describes its original deletion plan/application, with these three subsequent restorations documented here.

### N19 final repeated wall scanner verification — 2026-11-26
After guarding the scanner against the GridPathfinder class-name match, the wall/overhead integration suite was repeated:18/18 PASS, Godot exit0, and no GridPathfinder invalid-call or missing torch texture/model errors in stderr. Torch load fixture separately passed with one imported mesh surface, the placed Basementfull torch and engine exit0. Restored3 files match their original cleanup manifest SHA256; all8 N19 affected source/test/asset files match the disposable tested copy. Node syntax and diff check pass. Evidence inventory/results.json now includes N19 logs and checksums. This corrects the previous sentence stating the repeated fade result was still pending. Full retained gameplay95/95, secret route19/19 and final4-map capture results from the same tested build remain as recorded.

## N20 — Audio investigation, B3 two wall courses, stair camera, mirrored weapon and bounded optimization (2026-11-26, before implementation)
User requests continue audio/B3, improve stair camera, flip weapon left/right and check/optimize game. Clarification: B3 two wall courses instead of one; implement room wall/ceiling height, keep floor/routes aligned. Measured B3 wall item182 AABB height4 times cell_scale1.8 =7.2m per course. Earlier floor-translation interpretation is superseded. Audio: referenced combat OGG assets exist, saved master/sfx1 and mute false; background_mute true is only a hypothesis for reported silence, not confirmed cause. Attempted external preference write was rejected by automatic-review infrastructure usage limit; it did not execute, and will not be bypassed. Deleted21 BGS loops have no current gameplay call sites; restoring unused files alone cannot fix silence. Scope: user-authorized camera/weapon presentation, local B3 wall/tran ceiling edit, local audio diagnostics and repeated work reduction in wall helper. Preserve caches/cleanup/other dirty work. No generator/shared-library edit, no independent signoff. AC: smoother height tracking with bounded lag and snap on teleport; actual left/right weapon mirror with grip preserved; second7.2m wall row and raised ceiling; runtime audio driver/bus/stream evidence; existing render/gameplay checks plus focused regression, no general FPS claim without measurement.

## N20 FINAL — presentation, B3, audio and bounded optimization (2026-11-26)
Implemented and focused rendered-verified: B3 room now has two7.2m wall courses: second GridMap copies the original footprint/cells at+7.2m; ceiling moves+7.2m. Floor, spawn, checkpoints and linked doors remain aligned at their authored positions. User's clarification was interpreted as room height/two wall courses, superseding earlier proposed floor translation; no floor translation was applied. Shared libraries and generators untouched.
Camera fixed yaw/pitch/distance/FOV remains; render follow now exponentially eases height at10/s, bounds lag to0.4m and snaps height for displacements beyond6m or explicit snap_to_target. Physics no longer resets render height each tick. Actual Player traversed six physical steps using normal input/step-up; final position(404.2381,1.000176,400), on_floor true, worst observed lag0.1514343m; settling and upward step checks passed. This is a controlled physical stair fixture, not full authored campaign traversal.
Held weapon sets Sprite3D.flip_h for screen-left and clears it for screen-right, mirrors horizontal grip offset and source tip axis so the handle stays at the hand. Vertical facing retains the last horizontal orientation. Rendered captures of both directions inspected; existing weapon attack/dash/skill/throw checks still pass.
Audio investigation: actual combat stream reaches SFX mixer at-14.6988dB on WASAPI. First isolated hidden-window run had focused=false/Master muted=true; explicit focus-in unmuted and mixed sound. Final run started focused=true/unmuted and also mixed sound. All referenced combat assets existed; deleted21 BGS ambience loops had no current callers, and source pause help explicitly states maps have no music. No missing-audio-asset cause was established. After the earlier approval infrastructure usage-limit failure, the user's continue request and a fresh normal approval review allowed changing ONLY C:/Users/BaoHo/AppData/Roaming/Godot/app_userdata/Tower of Arcana/settings.cfg background_mute from true to false; master1,sfx1,mute=false preserved. Preference readback confirmed, effective on next game settings load/restart. This addresses focus-triggered silence; real speakers/OS output and silence while already focused were not physically listened to or proven fixed. No source default/mute control removed or user save changed.
Optimization: cell inventory/hash refresh throttled to0.1s rather than every physics tick; world AABB reject avoids inverse transforms for off-sightline geometry; unchanged blend skips material/surface/shadow writes. At this B3 position120 helper calls averaged906.69us/tick in the final run. No controlled before/after timing or global FPS improvement claim. Dynamic gate deletion/restore tests still pass with bounded poll delay. Existing custom-shader/static-library cache limits remain. N19 causal correction: user's original GridPathfinder error was the call on map.get_parent(), which can be a plain Node; the class-name matching explanation in N19 was not proven. The guarded Node3D parent visibility and actual-GridMap cast remain defensive fixes.
Final rendered Godot4.7.2 Compatibility results: focused9/9, wall/overhead18/18, retained gameplay95/95; engine exit0. No final script/parse/invalid-call/missing-resource failure observed. Existing BattleFX UID fallbacks, CheatMenu anchor, B2 quota and shutdown ObjectDB/resource diagnostics remain; not declared fixed. Source/staged6 changed implementation/fixture files match hashes. Diff check and audit JS syntax pass. No full campaign/all stair layouts/all weapons on every direction/export/OS audio-device validation/independent reviewer acceptance. Prior work, large cleanup deletions and dirty tracked caches preserved; no commit/push.
Included files and purpose:
- scenes/camera/camera_rig.gd: bounded smooth vertical follow/teleport handling.
- scenes/player/weapon/floating_blade.gd: horizontal sprite mirror with adjusted source-axis/grip offset.
- scenes/camera/wall_occlusion.gd: less frequent cell scans, cheap broad bounds rejection, skip unchanged material writes.
- levels/level_1/basement_b3.tscn: second wall course and raised ceiling only; retain previous camera cleanup edits.
- tests/presentation_audio_check.gd and .tscn: isolated actual Player mirror/step/ground/B3 checks, SFX mixer evidence, helper timing and captures.
- tools/audit_gameplay_cleanup.mjs: retain new relevant fixture in future dependency inventory.
- C:/Users/BaoHo/AppData/Roaming/Godot/app_userdata/Tower of Arcana/settings.cfg: only background_mute=false, approved direct retry of earlier unexecuted action.
- specs/001-integrate-basement-stage/tasks.md and validation.md: N20 scope, final behavior/evidence and limitations; docs/project-changes-2026-11-14.txt cumulative per-file record.
Evidence under docs/validation/presentation-audio-b3-2026-11-26/: presentation-runtime.log and presentation-errors.log capture first focused/audio/CPU run; presentation-final.log and presentation-final-errors.log capture final9 checks including actual stair walking; n20-wall.log and n20-wall-errors.log capture18 wall regressions; n20-gameplay.log and n20-gameplay-errors.log capture95 full retained regressions; b3-two-courses.png shows updated room; weapon-left.png and weapon-right.png show mirrored held sprite; stairs.png shows actual Player on physical step fixture; results.json contains counts, audio/performance caveats and per-source SHA256 agreement. Runtime-log warnings are preserved. No output file claims independent acceptance.

## N21 — B3 open roof, automatic stairs, plot prompts, Castle checkpoints, Basement pacing (2026-11-26, planned)
User explicitly requests these changes. Boundaries: Lam/Quan map/farming/checkpoint, Bao player interaction, Duy enemy pacing. Authorized scope follows user's instruction; no teammate acceptance is asserted. Preserve all earlier dirty work, caches, two wall courses and Castle combat balance. No generators or shared mesh edits. Acceptance: B3 has no ceiling; F starts visible collision-aware automatic stair ascent with safe interruption; plot hint anchors over selected soil; both Castle checkpoints activate, persist and respawn on their own floor; Basement attacks have longer recovery and slower projectiles while Castle defaults remain. Check authored routes in rendered Godot and isolated save fixture. Record exact tuning and runtime findings. Investigating contact checkpoint behavior before assigning a cause. Implementation/testing pending.

## N22 — B1 ladder automatic climb (2026-11-27, planned)
User additionally requests automatic B1 ladder traversal; use F as established by prior request. Scope Bao player assist and Lam/Quan authored B1 connector integration. User authorization covers this local implementation; no teammate acceptance asserted. AC: enter B1 ladder zone, F climbs continuously to supported B2 landing, camera follows, collision and health interruption remain; no frame teleport or arbitrary wall bypass. Rendered actual map traversal required. Preserve N21 changes and cleanup/caches. N21 regression runs completed95/95 gameplay,18/18 walls,9/9 presentation; focused42/42 previously passed. Final documentation and clearer plot label placement pending. No generators/shared-library edits.

## N23 — Reverse held weapon sprite orientation (2026-11-27, planned)
User reports handed sprite orientation is reversed and explicitly requests inversion. Bao weapon presentation scope: reverse left/right Sprite3D.flip_h mapping and initial mapping, preserve mirrored grip/source-tip calculations and cursor aiming. Validate rendered left/right captures and focused presentation suite; no independent acceptance claimed.

## N21/N22/N23 implementation and verification — 2026-11-27
Implemented under the user's requests; no independent reviewer/owner acceptance or commit/push is asserted. Earlier N21 planned status is superseded by this record. B3 Ceiling node removed completely; two wall courses/floors/doors remain. Castle authored stairs F assist traverses actual ramp from(7,1,45.5) to upper landing(7,9,26.5), normal gravity/collision; input or F cancels and a one-second stuck timeout stops assist. Measured final(7,9.010841,26.61771), grounded, camera lag0.2823m. B1 ladder F assist climbs actual shaft at(17,1,1) to y11.2 then dismounts toward(19,11.2,1), using move_and_collide without gravity during the climb; collision remains active. Final(18.89961,11.0105,1.000021), grounded, active B2, camera lag0.2757m. No generator or mesh-library edit. B2 authored landing is about10m above B1, as verified by raycast; do not confuse it with the visibility script's nominal6m floor spacing. Ladder mode participates in connector floor visibility while airborne. Movement/F can cancel; controls restore and gravity resumes. There is no dedicated ladder animation asset: existing run presentation is used.
Garden instructions now use camera-facing Label3D anchored2.6m above the selected soil/merchant; font40. Show planting, growth timer and harvest text above target; modal hides the hint. Three distributed plot targets and actual seed->plant->grow->harvest verified. One shared label follows the eligible selected plot rather than displaying32 overlapping hints.
Castle checkpoint original contact activation DID succeed in pre-change probe for both floors; reported failure was not reproduced, so no proven original save root cause is claimed. Added explicit F save/feedback, green active tint, camera-facing sprite, actual Stage ancestor resolution and eligibility refresh. Preserved contact activation and same stage/id/save contract. Both checkpoints passed disk save/load and GameManager.respawn to grounded correct-floor spawn. Shared checkpoint scene behavior also affects Garden; Basement uses its separate checkpoint script unchanged.
Basementfull/B3 Stage instance pacing: attack recovery and initial cooldown times1.5; skeleton/wizard projectile speed0.65 (7->4.55m/s). EnemyCharacter reads stage exports, including dynamically added summons; Dark Fairy attack recovery1.3->1.95s. Castle Stage defaults remain1; actual skeleton and wizard attacks verified7m/s and original cooldown. Damage/health/movement and Castle attack assets unchanged. This adjusts recovery cadence, not all animation windups/ground hazard timings.
User then corrected weapon handed orientation: held left now flip_h=false, right=true, initial vertical orientation true; vertical facing retains last horizontal. Mirrored source-tip and grip offset calculations retained. Changes limited to held presentation; skill cursor targets unchanged. Left/right rendered checks updated to corrected user request.
Files and purpose:
- levels/stage.gd: per-stage encounter pacing exports.
- levels/level_1/basement_full.tscn: local Basement pacing and F ladder entrance at existing marker; local BoxShape3D only.
- levels/level_1/basement_b3.tscn: no ceiling, local pacing; preserve prior two-course work.
- levels/level_1/castle.tscn: F area at authored ramp foot.
- levels/level_1/basement_floor_visibility.gd: connector visibility updates during ladder climb.
- levels/objects/automatic_stairs.gd: local F interaction and stair/ladder route dispatch.
- scenes/player/player.gd: collision-aware automatic route traversal, cancellation, interruption/control restoration, ladder vertical mode.
- levels/objects/checkpoint/checkpoint.gd: explicit save prompt/feedback and active marker/ancestor handling.
- levels/sketch/farm_controller.gd: plot/merchant world-space hint.
- scripts/enemy.gd: instance pacing from parent Stage.
- scenes/enemies/skeleton/skeleton.gd and scenes/enemies/arcane/arcane_enemy.gd: projectile velocity uses local stage scale.
- scenes/player/weapon/floating_blade.gd: reverse held sprite flip mapping with grip preserved.
- tests/world_interactions_check.gd/.tscn: isolated rendered route, cancellation/blocker, checkpoint save/load/respawn, stage-specific fired bullets and farm lifecycle checks.
- tests/presentation_audio_check.gd: replace superseded raised-ceiling assertion with absent-ceiling and update corrected mirror expectations.
- tools/audit_gameplay_cleanup.mjs: retain the new relevant fixture.
- specs/001-integrate-basement-stage/tasks.md and validation.md: cumulative task/evidence status; docs/project-changes-2026-11-14.txt: cumulative per-file/integration record.
Evidence in docs/validation/world-interactions-2026-11-26/: probe.log/probe-errors.log show original working contact checkpoints; runtime.log/runtime-errors.log record initial fixture-root mistake; runtime-2 logs record wrong-end stair entrance and exploratory missing mesh item; runtime-3 logs record corrected ramp and erroneous fixture MeshLibrary.has_item; runtime-4 logs record wrong fixture FarmController path. Those fixture mistakes were corrected, not product failures hidden. runtime-final logs:42/42 PASS. ladder-probe logs: actual shaft/support sampling; temporary probe source/scene removed after investigation. ladder-runtime logs:47/47 PASS including B1 landing and larger plot hint; exit0. gameplay/wall/presentation logs: earlier95/18/9 pass, exit0. ladder-gameplay and ladder-wall logs repeat95/18 after ladder addition. weapon-final logs record focused corrected orientation/presentation result. Six PNGs show B3 open room, B1 landing, Castle landing/both checkpoints, Garden hint; weapon images will be copied after final run. source-hashes.json records staged/source agreement. No real save writes by fixtures; custom user directories and fixture save path used.
Known diagnostic limits: BattleFX invalid-UID path fallbacks, CheatMenu anchor warning, B2 EnemyZone_B finite clear quota warning, ObjectDB/resource shutdown leaks remain. No final parse/invalid-call/missing-resource failure seen in completed suites. Early fixture errors retained in logs. Full campaign/export and independent user visual acceptance not performed. Existing cleanup deletions and dirty tracked caches preserved. Source uid_cache.bin changed externally during work: observed D6AE09CD3CC0788D849ED0E50B3137DA2676B20C6246DF6C998D0ADEBD28942E then134DFF63C7367FC767168C6ACE60C18CCF069CD692A1F65EF3ACFFDE2E9E6A00; no source editor launch/cache reset or hand edit by agent. Attribution cannot be established; retain for owner review. Source validation itself ran in disposable staged copy.

### N21/N22/N23 final check completion — 2026-11-27
Final counts: focused47/47, post-ladder gameplay95/95, post-ladder walls18/18, corrected-weapon presentation9/9 =169/169; all engine exit0. Corrected weapon-left.png and weapon-right.png copied and visually inspected; mirrored grip remains attached in both directions. All16 implementation/fixture files match the staged tested copy per refreshed source-hashes.json. results.json records counts/limits. Diff whitespace and audit JavaScript syntax checks pass. Eight final PNGs retained. No independent signoff/commit/push.

## N24 — Mirrored attack sprite axis (2026-11-27, planned)
User reports right-facing attack weapon lies sideways, left-facing normal. Bao combat/presentation scope authorized by this request. Static cause: weapon_attack._enter reads unmirrored source tip/handle offset regardless of retained Sprite3D.flip_h; current right-held sprite is flipped. Fix mirror-aware source axis and grip offset without changing attack hit window/damage/aim. AC: actual left/right attacks for all five retained weapons align visible texture tip with intended attack direction, grip stays at pose anchor, attack exit restores held orientation. Rendered isolated regression with both directions plus existing combat checks. Preserve pre-existing changes and no independent signoff. No map/generator/cache edits.

## N24 FINAL — mirror-aware weapon attacks (2026-11-27)
Implemented scenes/player/states/weapon_attack.gd: when attack starts with Sprite3D.flip_h, mirror source tip angle (PI-angle) and negate horizontal texture offset. Attack's existing view-plane rotation and spear world-tip/VFX calculations now use the correct mirrored texture axis. Preserve the user-requested held mirror, attack timing/hitbox/damage and skill targeting; no map/cache/generator edits. This fixes the right-facing atlas sword/axe sideways axis; unmirrored left attacks retain existing trajectory. Legacy vertical Blade axis is naturally invariant under horizontal flip.
Extended tests/weapon_presentation_check.gd with --attack-mirror-only mode: actual input attacks, eight sampled active-pose frames where available, visible texture tip vs intended projected swing, mirrored handle offset and exit restoration, for starter Blade/sword/axe/spear/dagger in both horizontal directions. Diagnostic output is retained only for failures. Before fix32/40: sword/axe right tip+handle failed, confirming reported issue; rapid spear/dagger tests additionally lacked active samples due variable physics catch-up. After initial fix36/40: sword/axe pass, remaining fast-attack sample failures. Final uses --fixed-fps60 to collect actual active frames reliably:40/40 PASS, engine exit0. Both directions of all5 weapons now pass tip/handle/exit checks. No code behavior was changed to satisfy the sampling issue.
Evidence docs/validation/attack-mirror-2026-11-27/: before.log/before-errors.log, after.log/after-errors.log preserve investigation; final.log/final-errors.log record40/40 and exit0. Ten combo-mirror-*.png captures show both directions of five weapons; sword left/right inspected. results.json records checks and SHA256 source/staged matches for both implementation/fixture files. Existing BattleFX UID fallbacks, CheatMenu anchor warning and ObjectDB/resource shutdown diagnostics remain; no script parse/invalid-call failure in final run. Focused normal-attack regression only: full charge/combo/campaign/export suite was not repeated since no timing/damage/route change. No independent acceptance/commit/push.
Files: scenes/player/states/weapon_attack.gd (mirror-aware tip/grip); tests/weapon_presentation_check.gd (rendered real-input regression); docs/validation/attack-mirror-2026-11-27/* (logs,10 screenshots,results/hashes); specs/001-integrate-basement-stage/tasks.md and validation.md (task/evidence state); docs/project-changes-2026-11-14.txt (this cumulative implementation/integration record). Diff whitespace check passes. Earlier169/169 record remains historical to N21-N23, not relabeled as rerun here. Preserved prior dirty work and ownership boundaries; user request authorizes local Bao attack presentation fix, no teammate signoff asserted.

## N25 — Exported combat audio resource lookup (2026-11-27, planned)
User reports exported build has UI audio but no combat sound. Static finding: BattleVFX.play_skill_sound tests FileAccess.file_exists(original OGG) and silently returns before ResourceLoader remapping; exported imported audio need not retain raw source file. All3 presets currently all_resources/no exclusions. Hypothesis matches Godot official import process docs; verify with actual Windows release export, not source-only mixer. Scope Bao combat sound loader/shared audio integration; user request authorizes local fix. AC: shipped resource resolves with remapping, all mapped sound IDs instantiate AudioStreamPlayer on SFX, representative combat streams produce real WASAPI mixer output; unknown sound remains ignored and finished nodes free. Preserve saved user volume and presets, no main game save access, isolated staged project/user dir. No independent acceptance asserted; tests/export pending.

## N25 FINAL — Exported combat audio lookup fixed and release-verified (2026-11-27)
Cause reproduced in an actual Windows Desktop RELEASE executable/PCK made by Godot4.7.2 with current all_resources preset. OGG original path FileAccess=false while ResourceLoader.exists=true: imported stream was packaged, but BattleVFX returned before loading it. UI settings preview in ui/pause_menu.gd synthesizes AudioStreamWAV samples, explaining why UI preview continued working. Source volume/focus settings and export filters were not the cause of this reproduced case and were not changed.
scenes/player/battle_vfx.gd now tests ResourceLoader.exists(sound_path,"AudioStream") before existing load/play, honoring imported resource remapping. Preserves volumes/pitches, SFX/Master routing, unknown-ID no-op and finished cleanup. Does not require exporting redundant raw OGG source. Existing all_resources presets unchanged. Godot official explanation: https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/import_process.html . Earlier source-only audio evidence from N20 did not cover this export-specific guard; this new test does.
New tests/export_combat_audio_check.gd/.tscn runs production BattleVFX for all34 mapped IDs in an isolated exported main scene. Before source fix:3/37 checks pass, all34 sound starts fail, engine exit1; resource remap exists. After source fix:46/46 pass, engine exit0; nine representative weapon/player/enemy/parry/wind/fire/ice/lightning streams measured at SFX mixer on WASAPI, peaks-22.42 to-7.94dB (weapon-14.6988dB). All34 IDs create playing AudioStreamPlayer on SFX; unknown ID no node and finished sound frees. Raw OGG remains absent while remapped resource resolves, establishing fix mechanism. Original export binaries B:/gameex/win untouched. Fixtures changed volume/focus only in isolated runtime and user dir ArcanaExportAudio-20261127; no real save/preferences edits.
Tests exported using existing Windows release template and a disposable warmed project, with main scene overridden only in staged project. before.exe/PCK and after.exe/PCK under C:/Users/BaoHo/AppData/Local/Temp/ArcanaExportAudio-20261127 are TEST FIXTURES, not a playable campaign distribution; hashes/bytes in results.json. Staged scene/preset overrides are not source project changes. Source needs a fresh regular export to update the user's existing game. Web/Linux use same corrected loader but were not runtime-tested. No physical speaker listening claim, full game/campaign rerun, independent acceptance, commit or push. Existing ObjectDB shutdown warnings remain; no final script/parse/missing-resource errors observed. Original uid_cache.bin observed C50E4BFE5FBAC80059AC5DE3133879832981E623025AD96CEA49D44F18B14D00 before export work, newer than N22; no hand edit/reset or source editor import by agent. Preserve externally observed dirty caches.
Included files/purpose: scenes/player/battle_vfx.gd (import-aware audio existence guard/comment); tests/export_combat_audio_check.gd and .tscn (real-export sound dispatch/mixer/cleanup fixture); tools/audit_gameplay_cleanup.mjs (retain relevant export fixture); docs/validation/export-combat-audio-2026-11-27/export-before.log and export-after.log (complete release export logs), before-runtime.log and after-runtime.log (actual executable reproduction/final mixer checks), results.json (counts/source and artifact hashes/limits); specs/001-integrate-basement-stage/tasks.md and validation.md (scope and final validation); docs/project-changes-2026-11-14.txt (cumulative integration record). All3 changed implementation/fixture sources match tested staged copy. Audit JS syntax and relevant diff whitespace checks pass. User requested investigation authorizes local audio fix; Bao combat/shared audio boundary recorded, no fabricated teammate approval.

## N26 — Slower stamina recovery and neutral weapon throw whoosh (2026-11-27, planned)
User requests slower stamina recovery and whoosh for default throw. Bao player/skill/audio scope explicitly authorized; no independent acceptance asserted. Proposed local tuning regen25->12.5/s, delay0.7->1.2s, nominal full empty recovery4.7->9.2s including delay; preserve costs/exhaustion. Add weapon_throw audio ID using existing Sword Attack3 swoosh with pitch1.15 and-6dB, dispatch only after successful neutral throw spawn. No new asset or visual skill. AC: delay/rate/cost/lock regressions pass, real default throw creates SFX node exactly once, new ID plays in actual Windows export using N25 remap-safe loader. Preserve all prior work/maps/caches/settings. Verification pending.

## N26 FINAL — Slower stamina recovery and neutral throw whoosh (2026-11-27)
Implemented user-authorized Bao player/skill/audio changes. Player stamina regen25->12.5/s and delay0.7->1.2s; nominal empty-to-full recovery now9.2s including initial delay versus4.7s previously (physics frame rounding applies). Costs, capacity, one-second exhaustion and HUD logic unchanged. Successful neutral/default weapon spawn in PlayerSkillState now calls BattleFX.play_skill_sound(obj,"weapon_throw") exactly once; empty-hand/cooldown refusals return before the sound. Sound reuses retained imported Sword Attack3.ogg as a quick whoosh with pitch1.15 and volume-6dB. No extra external sound asset, visual effect, aiming/trajectory/damage change. N25 ResourceLoader remap-safe audio guard preserved.
Verification: rendered Godot fixed60fps isolated stamina suite21/21 PASS (HUD/costs, insufficiency gates,1.19s delay sample,12.5/s regen, exhaustion timing/action lock); actual default skill integration7/7 PASS including exactly one SFX player at pitch1.15. First throw-sound test6/7 failed because it checked before the FSM's queued transition ran; fixed fixture awaits one physics update, no product workaround. Windows Desktop RELEASE export fixture48/48 PASS, engine exit0; all35 audio IDs instantiate,10 representative sounds reach WASAPI mixer including new weapon_throw peak-16.6659dB. All3 final runs exit0. No script/parse/invalid-call failure observed. Existing BattleFX UID/CheatMenu anchor and ObjectDB/resource shutdown diagnostics remain. Physical speakers, Web/Linux, full campaign and a full exported stamina playthrough were not tested. No independent signoff/commit/push.
Files/purpose: scenes/player/player.gd (regen delay/rate constants); scenes/player/states/skillstate.gd (successful default throw sound dispatch); scenes/player/battle_vfx.gd (weapon_throw mapping/pitch/volume); tests/weapon_combo_check.gd (new regen expectations, focused queued-FSM throw-sound regression); tests/export_combat_audio_check.gd (new ID plus mixer assertion); specs/001-integrate-basement-stage/tasks.md and validation.md (scope/final evidence); docs/project-changes-2026-11-14.txt (cumulative integration record). Evidence docs/validation/stamina-throw-2026-11-27/: stamina.log/stamina-errors.log (21 tests), throw-sound.log/throw-sound-errors.log (initial fixture timing failure), throw-sound-final.log/throw-sound-final-errors.log (7 actual-skill checks), export.log (release packaging), export-runtime.log (48 release audio checks), source-hashes.json (all5 changed implementation/fixture files match staged copy), results.json (76 total passing checks/tuning/limits). Diff whitespace check passes. Existing cleanup and dirty caches preserved; observed source uid_cache.bin now6B7DF2A88F1E88472FB502F5F8DBA209FC76B2E2C26683556C2EFB1510147687; no agent source editor import/cache reset/hand-edit. Attribution for externally changing cache not established.
Test export C:/Users/BaoHo/AppData/Local/Temp/ArcanaExportAudio-20261127/stamina-throw.exe and companion PCK are audio-only FIXTURES, not a campaign release. Original B:/gameex/win binaries and real settings/save untouched. Main-scene/custom-user-dir overrides exist only in disposable stage. A fresh regular game export is required to ship these changes.

## N27 — Web sound investigation and existing-asset main menu (2026-11-27, planned)
User requests all-Web-audio investigation and simple main menu using installed assets/addons. Scope Bao menu/audio and shared boot/settings/GameManager integration; user-authorized local implementation, no independent signoff. Preserve saves and earlier combat fix. Use existing Hearthmark panel/button/theme, Foxy sprite and existing PauseMenu settings/Dialogic integration. AC: responsive keyboard/mouse menu, continue existing checkpoint contract, confirm new game when save exists, settings return to title, Web user gesture begins audio without changing saved mute/volume. Diagnose actual browser export, distinguish original repro from hypotheses. Official Godot Web docs require user gesture for autoplay and describe sample vs stream limits. Do not force global streaming or overwrite user exports without evidence. Test isolated save, rendered menu, browser Web export, audio output instrumented where possible. No generators/shared mesh/cache reset.

## N27 FINAL — Main menu/settings decoration and browser-verified Web sound (2026-11-27)
Implemented user-authorized title/menu/audio boot changes; latest user steering explicitly includes settings and more decoration. New ui/main_menu.gd/.tscn is project startup: existing Hearthmark stone nine-slice panel, wooden buttons and InventoryMenu theme; existing Foxy hat atlas uses idle_down frame16/20 (row4/5) from player_anims; retained orb/potion icons. Code-drawn dusk glow, sparse drifting twinkles and tower silhouettes complement the existing pixel assets. Fixed960x540 content canvas scales/centers with viewport. First rough center-container layout clipped below screen in an early native capture; replaced with explicit scaled canvas and visually verified final1280x720 render. Early Foxy rotation used direction frames including blank art; replaced with actual idle_down frames and re-rendered. No AI-generated art/new asset download/plugin install or generators.
Buttons: Continue (disabled without save/incompatible reference), New Game (ConfirmationDialog before replacing existing save), Settings (existing PauseMenu controls/audio/display tabs), desktop Quit only. Settings returns to title on Cancel/Escape, preserves prior settings snapshot semantics. New/title buttons use existing UI preview sound on real click; this gives browser a user gesture. Source project.godot now launches title. GameManager keeps original save schema/Stage boot/checkpoint continuation; only F9 input is gated to an actual stage so it cannot bypass title new-game confirmation. PauseMenu similarly gates F9, adds title-settings entry/return. No change to new_game reset semantics, checkpoint contract, saved preferences or real user save. Existing Dialogic story still starts after New Game, verified in browser.
Web sound: current all-resources Web build with correct remap-safe N25 loader and default Sample mode still produced zero browser output, even after genuine click: AudioContext running, GameSettings focused=true, Master/SFX unmuted, actual audio player created. Test helper routed destination through an analyser only; it never resumes, unmutes, or starts audio itself. Switching project audio/general/default_playback_type.web to0 (Stream) reproduced nonzero output with otherwise same build. Separate production BattleVFX weapon_throw sample peak0.15015 and UI generated WAV peak0.09613 on Chromium; both real-click initiated, AudioContext running. A combined earlier click peaked0.133. Default Sample run peaked0.00000. This establishes a working compatibility fix in tested browser; exact engine/browser Sample failure not attributed further. Stream has potential extra latency with single-thread export, per official https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html . Retained single-thread preset and all audio user volume/mute controls; did not force mute off or alter real preferences. Earlier N25 imported-OGG guard fix remains necessary and preserved. No new background music implied.
Verification: tests/main_menu_check.gd/.tscn with isolated ArcanaMainMenu-20261127 user dir and fixture save: final13/13, engine exit0. Covers no-save keyboard focus/Continue disabled, settings3 tabs/open/cancel/unpause, existing save New Game confirmation without modifying file, Continue actual B2 grounded checkpoint spawn/save preservation, confirmed New Game actual retained first stage. First9 checks passed before extra tab/new-game coverage; native-final and native-idle-final repeat13 after decoration/idle correction. Actual Web release served localhost: clean production title, settings, Escape back, New Game -> Basement/first Dialogic story observed. Audio probe verifies output at browser WebAudio destination rather than unsupported Web sample mixer meter. Physical speaker listening, mobile/Safari/Firefox/embedded iframe hosting and full campaign were not tested. Existing BattleFX UID fallback, CheatMenu anchor, B2 EnemyZone_B quota and shutdown ObjectDB/resource diagnostics remain. No final script/parse/invalid-call/missing-resource failure observed. One intermediate QA helper export had extra parenthesis parse error, corrected and retained in web-qa-export.log. Sample silent runs and fixture limitations are not hidden.
Files/purpose:
- project.godot: menu startup and Web-only Stream playback override.
- ui/main_menu.gd and .tscn: responsive styled title, existing-asset decoration/idle Foxy, button input, continue/new-game confirmation/settings.
- ui/pause_menu.gd: title settings entry/return, title F9 guard.
- scripts/autoload/game_manager.gd: stage-only new-game shortcut guard; save/reset routines unchanged.
- tests/main_menu_check.gd and .tscn: rendered isolated menu/settings/checkpoint/new-game regression.
- tests/web_menu_qa.gd: optional staged-only diagnostic autoload with separate combat/UI buttons and focus/bus text; not configured in source or final clean export.
- tests/web_audio_probe.js: passive local browser output analyser overlay for verification HTML only, no production injection.
- tools/serve_web_preview.ps1: loopback-only local static test server with path containment and proper WebAssembly MIME; no public deployment.
- tools/audit_gameplay_cleanup.mjs: retain title regression; main title/assets reached via project.godot dependency scan.
- docs/validation/web-main-menu-2026-11-27/: native.log/errors initial9, native-final.log/errors13, native-idle-final.log/errors final13; web-export.log initial production Web, web-qa-export.log initial helper parse failure, web-qa-2-export.log fixed helper, web-stream-export.log compatibility A/B, web-separated-export.log separate signal verification, web-final-export.log and web-idle-final-export.log clean final packaging; server.log/errors local test hosting; main-menu.png final native render; source-hashes.json six implementation/fixture source/staged matches; results.json observed browser/output/check counts and limits.
- specs/001-integrate-basement-stage/tasks.md and validation.md: cumulative scope, acceptance/evidence and limits; docs/project-changes-2026-11-14.txt: this per-file integration record.
No source editor imports/cache reset/shared-mesh changes by agent; existing large cleanup and dirty caches preserved. uid_cache.bin observed6B7DF2A88F1E88472FB502F5F8DBA209FC76B2E2C26683556C2EFB1510147687, same as N26 observation. Source original export_presets.cfg and B:/gameex/web user export untouched. Disposable Web build at C:/Users/BaoHo/AppData/Local/Temp/ArcanaWebMenu-20261127/index.html has final main menu and test-specific user-directory override; no QA autoload/HTML instrumentation in clean index export. qa.html retains test overlay only. Fresh export from source required for user-distributed build, no deployment/upload performed. Native tests/browsing used isolated save; no independent owner/reviewer acceptance, commit or push. Relevant diff check, audit/probe JavaScript syntax pass. Initial Python server attempt failed because Windows Store alias had no Python installed; loopback PowerShell server used instead, no installation. Temporary top-level server logs to be moved into evidence after stopping local server.

## N28 — Faster base player movement and impact-directed knockback (2026-11-27, planned)
User requests increased basic movement speed and knockback from hit direction instead of facing. Bao player movement/hurt scope explicitly authorized. Static cause: Player discards HurtArea3D direction; Hurt._enter uses -obj.forward()*8. Scope: Player scene base speed6->7.5m/s, forward attack hit direction into hurt, source-position fallback only for zero vector with known attacker; zero/unknown impact gets vertical hop without arbitrary facing-based horizontal push. Preserve magnitude8/hop5/damage/hurt duration/invulnerability/parry/shields and all maps/enemy speeds. AC: actual directional movement25% faster, all facing/impact combinations push with incoming vector, source fallback, collision stops against wall, protected hits do not launch, recovery restores controls. Rendered actual Player fixture and relevant regression; no generator/cache reset/independent acceptance. Implementation/verification pending.

### N28 user steering before completion — 2026-11-27
User explicitly sets base speed15m/s, superseding proposed7.5; implement15 (2.5times original6). Shader/art question is advice scope only: recommend coherent palette/lighting, restrained actor outline and MSAA rather than heavy screen effects; do not silently implement rendering changes. Existing Player.base_movement_speed cache initialized100 in source was already present and is overwritten with actual scene speed in _ready, preserve unrelated source.

## N29 — Face the B1 ladder during automatic climb (2026-11-27, planned)
User adds request to turn Foxy toward ladder rather than front-facing while climbing. Scope Bao local automatic ladder presentation. AC: vertical shaft segment faces authored ladder wall(-Z), side dismount faces route motion, camera-relative sprite direction correct, arrival supported and controls restored. Preserve 15m/s user base speed, fixed ladder speed3m/s, collisions and other stair behavior. Render actual B1 route and check facing while vertical. No independent acceptance asserted.

## N28/N29 FINAL —15m/s player, impact-directed recoil, facing B1 ladder (2026-11-27)
User supersedes proposed7.5m/s with explicit15m/s,2.5times original6. Player scene now exports movement_speed15; cached base is captured by existing _ready/stat pipeline. Enemy scene speeds, movement buffs/skill-tree arithmetic, dash costs/cooldowns and fixed ladder vertical3m/s unchanged. Actual input walking covered7.5000019m in30 physics ticks at60fps. Source base-cache initialization100 was pre-existing and overwritten at runtime, left intact. Initial apply_patch partially wrote the scene then failed to write Player script; inspected and completed exact source edits normally with PowerShell, no permission bypass/cache reset.
Player hurt callback now preserves flattened incoming hit direction, normalizes it, and falls back away from HurtArea3D.attacker position only when incoming direction is near zero. Hurt entry consumes/resets that vector instead of -forward(). Existing8m/s horizontal impulse,5m/s hop,0.5s hurt lock, damage/immune/parry/shield behavior retained. Unknown zero-source impact gets no invented horizontal direction; vertical hop remains. Body facing is retained while displacement follows hit. All16 facing/impact combinations verified at8m/s, actual four-direction motion observed, source fallback/zero/invincible/shield/repeated-hit protection verified, actual wall blocks displacement and recovery restores controls.
B1 vertical ladder segment explicitly faces authored north shaft wall(-Z), independent of approach/current body facing. Side dismount resumes facing route movement. No camera/map/animation asset change; existing run presentation retained. Actual B1 climb reaches(18.89961,11.0105,1.000021), grounded on B2, visibility/camera checks and direction samples throughout y2..10 pass. Castle stair and blocker/cancel checks remain passing at15m/s.
Final rendered Compatibility results: speed/knockback46/46, secret route/walls19/19, world routes/checkpoint/farm/ladder48/48 =113/113, all engine exit0. Initial secret run18/19 failed a pixel blend assertion because clear/faded screenshots used different animated idle poses/camera settling times; material alpha already0.22 and route/collision checks passed. Fixture now freezes same Player pose/physics and settles camera before baseline capture; error0.1652->0.00257 with no wall rendering code change. Final19/19 confirmed with same deterministic scene. Existing BattleFX UID fallbacks/CheatMenu anchor/B2 finite quota and shutdown ObjectDB/resources-in-use diagnostics remain. No final parse/invalid-call/missing-resource error observed. No new Web/export/full-campaign/all-slope test or independent reviewer acceptance; no commit/push.
User visual question handled as recommendation only: coherent stylized dungeon palette (cool shadows/warm torches), reduce noisy floor texture/saturation and overlapping VFX, restrained1px sprite outline and MSAA2x/4x for3D edges. Official Godot renderer docs confirm Compatibility supports MSAA3D/tonemapping/adjustments but not SSAO/SDFGI/FXAA; recommend compatible light effects rather than promising unsupported Web effects. No shader/lighting/material changes implemented in this group. Advice basis: https://docs.godotengine.org/en/4.5/tutorials/rendering/renderers.html and https://docs.godotengine.org/en/latest/tutorials/3d/3d_antialiasing.html ; assessment of scene visual clutter is an inference from inspected game scenes/captures, not a measured defect.
Files/purpose:
- scenes/player/player.tscn: explicit base speed15.
- scenes/player/player.gd: record hit direction/source fallback; face ladder wall on vertical assist segment.
- scenes/player/hurt.gd: consume incoming knockback direction instead of body facing.
- tests/speed_knockback_check.gd/.tscn: isolated real Player movement,16 facing/hit combinations, physical hit paths/protections/wall/recovery.
- tests/secret_room_walls_check.gd: stable same-pose pixel comparison; all authored movement checks still at actual15m/s.
- tests/world_interactions_check.gd: verify facing samples along B1 vertical climb in addition to existing routes.
- tools/audit_gameplay_cleanup.mjs: retain related speed/knockback fixture.
- specs/001-integrate-basement-stage/tasks.md and validation.md: user steering/acceptance/actual verification and limitations; docs/project-changes-2026-11-14.txt: cumulative status/file/integration record.
Evidence docs/validation/speed-knockback-2026-11-27/: runtime.log/errors first46 checks; runtime-final.log/errors repeats46 after final ladder steering; secret.log/errors initial18/19 and secret-final.log/errors19/19 corrected same-pose fixture; routes.log/errors47 original route checks at15 and ladder-final.log/errors48 with explicit facing; secret-room-audit.json records support samples/pixel blend; b1-ladder-landing.png actual arrival capture; source-hashes.json7 source/staged agreements; results.json counts/tuning/limits. Native fixtures use custom isolated data/save; real save/preferences and original export binaries untouched. Existing dirty cleanup/caches preserved. uid_cache.bin observedDA0B7ED421D42E6EDDAAF0DE132E8186859C36D5FAAE351C51CFBF4C54BE1149 differs from N27; no agent source editor/cache hand edits or resets, attribution of external cache changes not established. User authorization covers local Bao movement/hurt/presentation scope; no fabricated teammate approval. Diff whitespace/audit JS syntax pass.
