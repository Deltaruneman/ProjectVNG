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
T012 attempted/BLOCKED: shared reviewer agreement missing. Authorized T013-T017/T025
are BLOCKED by T012 and remain unimplemented; later task groups NOT RUN. See validation.md.
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

- [ ] T012 [US2] Identify shared manager/input/save reviewer and boundaries in `specs/001-integrate-basement-stage/validation.md` for `project.godot` and `scripts/autoload/game_manager.gd`.
  - Resume disposition (2026-11-05): attempted/BLOCKED. No named shared maintainer or actual shared-reviewer/Quan/Bao agreement recorded. Exact proposed boundary and outstanding decision recorded in validation.md; no dependent edits begun.
  - Owner/reviewer: Lam coordinates / Quan and named shared maintainer; Bao input-impact review. Dependencies: T011 handoff.
  - AC: actual reviewer agreement before shared edits; no inferred ownership or authorization to modify protected systems. Old-B3 policy not needed for independent review.
  - V: documented file-impact review; shared edits BLOCKED until reviewer identified.

- [ ] T013 [P] [US2] Prepare independent suites in proposed `tests/basement_checkpoint_check.gd` from `data-model.md` and `contracts/stage-progress.md`.
  - Owner/reviewer: Lam / Quan/shared reviewer. Dependencies: T012; T003 before runtime.
  - AC: separate interaction/rank, supported recovery, legacy B1/B2, old-B3 refusal/recovery and real-wave results; sentinel unrelated fields. Verify "b1_start -> b1/1, b2_start -> b2/2; not trusted from arbitrary saved rank" and "B2 -> B1 is rejected without saving or success feedback."
  - V: review before implementation; no real-save writes or invented fallback; blocked old-B3 recovery cannot fail independent suites.

- [ ] T014 [P] [US2] Add narrow basement checkpoint acceptance/rank boundary in `scripts/autoload/game_manager.gd`.
  - Owner/reviewer: Lam within agreed boundary / shared reviewer/Quan. Dependencies: T012.
  - AC: canonical stage/declared IDs; "b1_start -> b1/1, b2_start -> b2/2; not trusted from arbitrary saved rank"; "B2 -> B1 is rejected without saving or success feedback." Foreign requests rejected, same-current idempotent; unrelated stages unchanged.
  - V: T013 identity/rank fixtures. Proposed request API is not existing until implemented/verified; no player/enemy changes.

### Local checkpoint placement and interaction

- [ ] T015 [US2] Create proposed `levels/objects/checkpoint/basement_checkpoint.tscn` and `levels/objects/checkpoint/basement_checkpoint.gd` using existing visuals and InteractiveArea3D.
  - Owner/reviewer: Lam / Quan; Bao input consultation. Dependencies: T014.
  - AC: local variant replaces stock auto-contact behavior; reuses helm/detector/Spawn. Nearby F prompt, eligible request, then local tint and exact "Checkpoint activated." Label3D only after acceptance. Guard dead/dialogue eligibility locally; no Player API/second HUD/final art.
  - V: structural no-auto-activation connection review, T013 fixtures, T025 playtests. Do not trust helper's absent can_interact assumption.

- [ ] T016 [US2] Establish B1 default placement and B1/B2 checkpoint instances in `levels/level_1/basement_full.tscn`.
  - Owner/reviewer: Lam / Quan. Dependencies: T015, T011.
  - AC: reconcile root Player/Spawn on supported B1 surface; b1_start/b2_start "unique in active Stage"; owner "Active Stage, not an inherited visual's foreign floor root." Supported child Spawn/group; validate transforms instead of blindly copying split coordinates. No B3 checkpoint.
  - V: structural ownership/IDs/transforms; Godot support/camera T025-T026. Player scripts/colliders unchanged.

- [ ] T017 [US2] Add only missing interact-to-physical-F binding in `project.godot`.
  - Owner/reviewer: Lam within approved shared scope / shared reviewer/Bao input review. Dependencies: T012, T015.
  - AC: one interact/F mapping; preserve other input/plugin edits; main-scene change only in T021. No remapping of approved F or other player actions.
  - V: input-map diff and T025 repeated-F/dialogue/overlap playtests; static no-direct-conflict finding is not runtime proof.

### Save and recovery integration — separate result lanes

- [ ] T018 [US2] Preserve unrelated loaded payload at `scripts/autoload/game_manager.gd` save boundary, reusing `scripts/autoload/save_system.gd` unchanged.
  - Owner/reviewer: Lam within approved scope / shared reviewer/Quan. Dependencies: T014, T013.
  - AC: merge owned fields/flags, retain unknown top-level values/unrelated flags; keep version 1/serializer. "Do not serialize enemy health, partial-wave indices/counts, or individual enemies."
  - V: sentinel-field round-trip fixtures/diff; no save rewrite, version bump, deletion or blanket reset.

- [ ] T019 [US2] Add explicit narrow legacy B1/B2 checkpoint reset in `scripts/autoload/game_manager.gd`.
  - Owner/reviewer: Lam within approved scope / shared reviewer/Quan. Dependencies: T018.
  - AC: exact research R4 standalone paths/UIDs; only old test checkpoint pair -> continuous B1/default empty ID. "Do not apply substring/basename matching or reset valid continuous-stage B1/B2 IDs." Preserve unrelated data/clears/unlocks. B3/unknown references excluded.
  - V: path/UID positives and valid-new/sentinel negatives in T013. Old-B3 recovery policy is not a dependency for this classifier.

- [ ] T020 [US2] Add B3 load refusal at existing boundary in `scripts/autoload/game_manager.gd`.
  - Owner/reviewer: Lam within approved scope / shared reviewer/Quan. Dependencies: T012, T013.
  - AC: reject known B3 path/UID before load-state mutation; cover startup/death/interaction callers. Preserve save/data; no fallback, remap, deletion or new user policy; unrelated supported flows intact.
  - V: refusal/unchanged-data fixtures independent of recovery; zero-load check PASSED/FAILED, recovery outcome separately BLOCKED in T027.

- [ ] T021 [US2] Align supported startup/recovery in `project.godot` and `scripts/autoload/game_manager.gd` to continuous stage.
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
  - Owner/reviewer: Lam / Quan; Bao consulted for input/player issues. Dependencies: T003, T014-T017 and applicable structural checks.
  - AC: supported ownership/spawn, prompt/F/tint/exact message; no arrival activation; B1 cannot replace B2. Repeated F/overlap/dialogue/dead cases cause no unintended action; one HUD.
  - V: isolated Godot interaction/camera evidence. No real-wave provider or B3 policy prerequisite for this lane; report limitations independently.

- [ ] T026 [US2] Validate supported no-save/B1/B2/legacy continuation/recovery using `tests/basement_checkpoint_check.gd` and Godot, recording `specs/001-integrate-basement-stage/validation.md`.
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

**Goal/independent test**: measured clearance, completed safe route and misses/retries can be
validated separately; genuine clear/death/restart gates need Duy interfaces. Geometry tasks
do not assign Bao or Duy implementation. This phase is outside the first group.

- [ ] T034 [P] [US4] Measure route clearance in `levels/level_1/basement_full.tscn`, recording `specs/001-integrate-basement-stage/clearance-measurements.md`; inspect `scenes/player/player.tscn` and jump/fall states read-only.
  - Owner/reviewer: Lam / Quan; Bao state interpretation consultation. Dependencies: T011; T003 for runtime measurements.
  - AC: obstruction node/cell/item/transform, underside, takeoff/landing/body sweep/screenshots. Body ~1.698/.800, jump12/gravity24/ideal rise3 are static/inference, not wall multiplier or verified target. Measure actual second-jump timing.
  - V: distinguish dimensions/inference from Godot observations. Missing engine blocks runtime measurements only; no B3 policy dependency.

- [ ] T035 [US4] Repair only measured ceiling/clearance cells in `levels/level_1/basement_full.tscn` B1/World/Floor, Wall, B2-Parkour and B2/World.
  - Owner/reviewer: Lam / Quan. Dependencies: T034 measured evidence/review.
  - AC: smallest per-cell existing-asset changes; preserve Hidden/dependencies; no shared library edits, height multiplier, player collider/gravity/jump changes. Player-rooted blocker requires Bao coordination, not Lam edits.
  - V: before/after geometry/resource/navigation review; actual clearance T038 before any fixed claim.

- [ ] T036 [US4] Complete route and safe missed-jump landing/retry surfaces in `levels/level_1/basement_full.tscn` B1/World/B2-Parkour and necessary B1/B2 route cells.
  - Owner/reviewer: Lam / Quan. Dependencies: T034-T035; serialize scene writes with T031-T032/T037.
  - AC: current abilities suffice; misses introduce no fall damage/lethal falls/new hazards. No assumed teleport, Hidden entrance/final art/player edits.
  - V: structural route/collider diff and T039 Godot miss/retry evidence; player/timing changes need Bao approval outside these tasks.

- [ ] T037 [US4] Add B1 parkour-access gate in `levels/level_1/basement_full.tscn`, reusing `levels/level_1/basement_progress_gate.gd` and `basement_progress_bridge.gd`.
  - Owner/reviewer: Lam consumer / Quan, Duy interface review. Dependencies: T030, T036; real binding requires T023 provider.
  - AC: closed before B1 clear, open after genuine/restored clear; "B1 clear and parkour unlocked advance together and remain true across death/restart." No wave logic, Hidden wall changes or new ability.
  - V: synthetic consumer fixtures separate from production completion/persistence in T040; BLOCKED if provider missing.

- [ ] T038 [US4] Playtest ceiling/clearance in `levels/level_1/basement_full.tscn`, recording `specs/001-integrate-basement-stage/clearance-measurements.md` and `validation.md`.
  - Owner/reviewer: Lam / Quan; Bao player-behavior consultation. Dependencies: T003, T035-T036.
  - AC: current ordinary/second-jump timing, head contact, transitions, camera/navigation show sufficient clearance with unchanged player; distinguish pre-existing issues from regressions.
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
T011 -> T034 -> T035 -> T036 -> T038/T039
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

**Totals**: 42 tasks: setup/foundational 3; US1 8; US2 17; US3 5; US4 7; final review 2.
**First group**: T004-T011, 8 scene-foundation/check tasks only.
**Current state**: isolated structural and headless scene verification recorded; manual playtests
and Quan review remain pending. T012-T042 stay unchecked and unexecuted; stop before T012.
