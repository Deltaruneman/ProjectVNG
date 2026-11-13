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
