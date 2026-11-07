# Implementation changelog

This cumulative teammate-facing record describes actual changes and evidence, not
whole-feature acceptance. Every future implementation group or commit/push must
update it before publishing; see root AGENTS.md. Keep historical entries and add
new groups with task status, every included file, integration effects, checks,
known errors, limitations and unfinished work.

## 2026-11-05 — Spec Kit setup and continuous-basement scene foundation — this commit

**Base commit:** `0c01c67b3fa087fa898a8d5f4e7d8afbe170cd3f`.
**Branch/destination:** `basement-split-floors` at
`origin` (`https://github.com/Deltaruneman/ProjectVNG.git`).
The remote branch matched the base at preflight. No existing commits are amended.
Setup and foundation are backfilled into this single associated commit; they are
not represented as earlier commits that never occurred.

### Groups and actual task status

- **Setup and planning:** existing Spec Kit 1.3.0 installation, constitution v1.0.0,
  feature specification/design/task documents are included. T001-T003 complete:
  preservation/scope recorded and writable pre-autoload test isolation established.
  Bundled commands/workflow availability does not mean those workflows were all run.
- **First scene foundation:** T004-T009 complete. Root Stage composition, integrated
  B3/GroundExit removal and null-obstacle cleanup implemented and structurally checked.
  T008 required no additional collider: existing containment was judged sufficient
  structurally; physical containment acceptance remains outstanding.
- **Validation/handoff:** T010 partial; T011 partial without Quan sign-off.
  Lam reports reviewing expected scene changes and testing basement_b1,
  basement_b2 and basement_full with no major issues observed. These are Lam's
  observations, not comprehensive acceptance or Quan/Bao approval.
- **Current hold, not implementation:** T012 attempted/BLOCKED. Named shared
  manager/input/save reviewer and actual reviewer/Quan agreement with Bao input-impact
  review are missing. T013-T017 and T025 are unimplemented/unrun behind that gate.
  No checkpoint behavior, startup/recovery/save changes or later task groups are
  included. Existing data-model/contract APIs and wave flags remain proposals.

### File-by-file commit manifest

Each checked row is a reviewed inclusion decision reconciled with the staged diff.
A = added relative to base; M = modified. The staging check matched these exact 43 paths;
no file deletions are included. New files already present at packaging entry are
backfilled setup/feature/foundation artifacts, not claimed to have been authored
during packaging. Only AGENTS.md, this changelog and removal of the temporary
constitution comment are new packaging changes.

| Reviewed | File | Git change | What changed and why |
| --- | --- | --- | --- |
| [x] | `.agents/skills/speckit-analyze/SKILL.md` | A | Cross-artifact consistency review workflow. |
| [x] | `.agents/skills/speckit-checklist/SKILL.md` | A | Reviewer-owned requirements checklist workflow. |
| [x] | `.agents/skills/speckit-clarify/SKILL.md` | A | Specification clarification workflow. |
| [x] | `.agents/skills/speckit-constitution/SKILL.md` | A | Constitution authoring and governance workflow. |
| [x] | `.agents/skills/speckit-converge/SKILL.md` | A | Append-only remaining-work assessment workflow. |
| [x] | `.agents/skills/speckit-implement/SKILL.md` | A | Task execution and honest validation workflow. |
| [x] | `.agents/skills/speckit-plan/SKILL.md` | A | Design-artifact planning workflow. |
| [x] | `.agents/skills/speckit-specify/SKILL.md` | A | Feature specification workflow. |
| [x] | `.agents/skills/speckit-tasks/SKILL.md` | A | Dependency-ordered task generation workflow. |
| [x] | `.specify/.gitignore` | A | Ignore checkout-local feature pointers, overrides and adapter packages. |
| [x] | `.specify/init-options.json` | A | Record portable Spec Kit 1.3.0/Codex/PowerShell initialization choices. |
| [x] | `.specify/integration.json` | A | Record installed/default Codex integration and invocation separator. |
| [x] | `.specify/integrations/codex.manifest.json` | A | Installer provenance and checksums for the nine bundled skills. |
| [x] | `.specify/integrations/speckit.manifest.json` | A | Installer provenance and checksums for bundled scripts/templates/ignore rules. |
| [x] | `.specify/memory/.constitution-template.json` | A | Track source template hash for future constitution refreshes. |
| [x] | `.specify/memory/constitution.md` | A | Adopt v1.0.0 ownership, evidence, scope, map safety and validation rules; remove temporary sync-impact comment before commit, preserving governance text. |
| [x] | `.specify/scripts/powershell/check-prerequisites.ps1` | A | Resolve/check feature artifacts for workflow prerequisites. |
| [x] | `.specify/scripts/powershell/common.ps1` | A | Shared portable repository/feature/integration/template resolution. |
| [x] | `.specify/scripts/powershell/create-new-feature.ps1` | A | Bundled feature-creation helper; not executed during packaging. |
| [x] | `.specify/scripts/powershell/resolve-template.ps1` | A | Resolve composed workflow templates. |
| [x] | `.specify/scripts/powershell/setup-plan.ps1` | A | Bundled planning setup helper; not executed during packaging. |
| [x] | `.specify/scripts/powershell/setup-tasks.ps1` | A | Bundled task setup helper; not executed during packaging. |
| [x] | `.specify/templates/checklist-template.md` | A | Requirements-review checklist template. |
| [x] | `.specify/templates/constitution-template.md` | A | Upstream governance template retained for workflow reuse. |
| [x] | `.specify/templates/plan-template.md` | A | Design/implementation planning template. |
| [x] | `.specify/templates/spec-template.md` | A | User-story/requirements specification template. |
| [x] | `.specify/templates/tasks-template.md` | A | Dependency/task execution template. |
| [x] | `.specify/workflows/speckit/workflow.yml` | A | Bundled SDD workflow with spec/plan review gates; installed, not run automatically. |
| [x] | `.specify/workflows/workflow-registry.json` | A | Portable bundled workflow version/provenance registry. |
| [x] | `specs/001-integrate-basement-stage/spec.md` | A | Approved Q1-Q4 requirements, boundaries and acceptance criteria; no runtime acceptance claim. |
| [x] | `specs/001-integrate-basement-stage/checklists/requirements.md` | A | Preserve 14/16 requirements-quality markers and two explained technical-constraint exceptions. |
| [x] | `specs/001-integrate-basement-stage/plan.md` | A | Record incremental architecture, ownership/review boundaries and phased implementation. |
| [x] | `specs/001-integrate-basement-stage/research.md` | A | Record targeted static evidence, canonical identities and unresolved integration dependencies. |
| [x] | `specs/001-integrate-basement-stage/data-model.md` | A | Document stage/checkpoint/state model; proposed fields/interfaces remain proposals. |
| [x] | `specs/001-integrate-basement-stage/contracts/stage-progress.md` | A | Document proposed checkpoint/wave/persistence contracts and shared review requirements. |
| [x] | `specs/001-integrate-basement-stage/quickstart.md` | A | Historical planned validation guide; latest isolation/results/status in validation.md supersede earlier examples. |
| [x] | `specs/001-integrate-basement-stage/tasks.md` | A | Record T001-T009 complete, T010/T011 partial, T012 hold and dependent work unimplemented. |
| [x] | `specs/001-integrate-basement-stage/validation.md` | A | Preserve baseline, isolated-run evidence, diagnostics and Lam observations; document T012 blocker without implementation. |
| [x] | `levels/level_1/basement_full.tscn` | M | Rename root Basement to Stage; remove integrated B3/GroundExit and two orphan resources; remove only null B1/B1_5 obstacle entries. Preserve all other retained blocks/Hidden and separate B3. Existing containment judged sufficient structurally; no speculative boundary added. |
| [x] | `tests/basement_integration_check.gd` | A | Read-only serialized-scene assertions for root, retained hashes, singleton declarations, references and separate-B3 preservation; isolated-copy guard; explicitly not a gameplay/physics test. |
| [x] | `tests/basement_integration_check.gd.uid` | A | Preserve the checker's existing Godot resource UID for stable script identity. |
| [x] | `AGENTS.md` | A | Add root guidance because none existed; require cumulative changelog updates for every future implementation group or commit/push, preserving ownership/review rules. |
| [x] | `docs/implementation-changelog.md` | A | Create this cumulative teammate record, backfill setup/foundation evidence and enumerate this commit's exact inclusion/exclusion decisions. |

### Exclusions and attribution

All five excluded paths were present at packaging entry, remain unstaged, and
must retain their entry SHA-256 hashes. No attribution is invented.

| Reviewed exclusion | Path | Entry state | Reason |
| --- | --- | --- | --- |
| [x] | `.godot/uid_cache.bin` | Modified | Generated tracked cache, already changed before this session; differs from first-session baseline. Preserve for review, do not stage or clean. |
| [x] | `assets/meshes/KKD_library.tres` | Modified | Pre-existing BoxShape3D_scaffold resource-block relocation; no foundation library edits authorized or attributable. Preserve. |
| [x] | `project.godot` | Modified | Pre-existing removal of mesh_to_scene editor-plugin enablement; unrelated to foundation. Preserve and exclude entire diff. |
| [x] | `docs/build_progress_1.md` | Untracked | Earlier broad Prototype 1 progress document, already present at original baseline; authorship/commit attribution unestablished and outside requested feature artifacts. |
| [x] | `docs/godotgameteam7_full_concept.md` | Untracked | Earlier broad project concept document, already present at original baseline; authorship/commit attribution unestablished and outside requested feature artifacts. |

Checkout-local ignored Spec Kit state (including feature.json), .git data,
import caches, disposable test projects/logs and actual user data are excluded.
No wholesale directory staging or mixed unrelated hunks are required: the only
included tracked modification is the reviewed basement_full.tscn foundation diff.
The index was empty at entry, so no pre-staged work is silently carried forward.

### Shared systems and integration considerations

- Gameplay composition changes only in the combined scene. Separate B3, standalone
  B1/B2, Hidden geometry/collision/behavior/connections and shared libraries remain
  unchanged. Root Stage supports existing factory ancestry; one direct Player,
  CameraRig, Hud, Bullets and Spawn remain.
- Production project settings, GameManager, SaveSystem, Player, navigation scripts,
  stock checkpoint logic and enemy/wave producers are not modified by this commit.
  Production startup remains standalone B1; this foundation is tested by explicit
  combined-scene loading/F6, not an asserted production startup switch.
- Teammates receive portable Spec Kit workflows/templates and explicit governance,
  review boundaries and cumulative reporting requirements. No new dependency
  installation, automatic workflow execution, ownership transfer or teammate approval.
- T012 requires a named shared reviewer plus actual review agreement for manager
  B1/B2 acceptance, physical-F binding and local checkpoint/spawn scope before
  dependent edits. Old-B3 recovery and Duy's real-wave handshake remain separate
  unresolved later dependencies, not reasons to implement a guessed fallback now.
- Detailed validation has historical machine/temp paths as evidence; they are not
  portable launch configuration. Use a new disposable copy/user-data identity and
  verify isolation before autoloads; never launch the original project for these checks.

### Verification, known diagnostics and unfinished work

Existing evidence reused from feature validation.md (no gameplay rerun during packaging):

- Godot `4.7.2.stable.official.ed1daf0bf`: isolated no-autoload probe verified
  unique writable temp-backed user data and no save before game autoload startup.
- Focused unchanged GDScript runner: **243 passed, 0 failed**, exit 0, in disposable
  project copy. Earlier independent 141 static checks are historical, not added
  to or substituted for that result.
- Limited headless combined-scene load/composition: one Player/CameraRig/Hud,
  one observed registration, GameManager.current_stage equals Stage,
  camera target equals Player, absent integrated B3/GroundExit; not a playtest.
- Diagnostics remain explicit: initial isolated Dialogic directory error corrected
  by verified temp APPDATA; root-certificate-store failure reproduced in minimal
  probe; graceful scene shutdown leaked 3 ObjectDB instances/1 resource
  (`fsm.gd`). Pre-existing detached-FSM lifetime is a hypothesis, not proven cause.
  Exit 0 does not establish error-free gameplay.
- Lam's general scene observations are recorded separately above. Detailed visual
  camera/visibility, movement/collision, factory/projectile/navigation and physical
  B2 containment checks remain unverified. No comprehensive acceptance/sign-off.
- Checkpoint prompt/F/feedback/rank, supported spawn/recovery, restart, real waves,
  ceiling/parkour/gates and old-B3 recovery are not verified by this foundation.

### Packaging verification and staged reconciliation

- **PASSED:** branch/HEAD/upstream verified; index initially empty. Live origin
  branch equalled base HEAD at preflight. Destination is the existing branch,
  normal push only; stop on divergence. No custom active Git hooks were found.
- **PASSED:** all 43 candidates individually reviewed and explicitly staged;
  exact index path-set comparison matched the manifest above (42 additions,
  1 scene modification, no file deletions). All five excluded candidates remain
  outside the index. Their entry hashes are retained for post-commit comparison.
- **PASSED:** all 21 bundled skill/script/template/ignore files match installer
  provenance SHA-256 hashes in the two integration manifests. Installer registries
  contain timestamps/checksums/relative paths, not checkout-specific configuration.
- **PASSED:** focused read-only PowerShell checks against the index: **198 passed,
  0 failed**. Checked root/retained hashes, 58 serialized nodes/57 retained blocks,
  singleton declarations, no integrated B3/GroundExit/null obstacles, NodePaths,
  external dependencies present in committed base, ExtResource/SubResource IDs,
  separate-B3 preservation and honest task completion markers. No Godot launch.
- **PASSED:** staged JSON parses; all six PowerShell scripts parse; staged content
  matches normalized working files; obvious private-key/token/AWS-key patterns
  absent. Absolute paths appear only in historical evidence/examples or a generic
  script comment, not portable JSON configuration. No credentials or temp artifacts
  included. This is a focused obvious-secret scan, not a security certification.
- **PASSED, whitespace:** initial staged check found one extra blank line at this
  new changelog's EOF; corrected as packaging-only work. The final
  `git diff --cached --check` returned exit 0. Existing text normalization
  produces CRLF-to-LF notices for five setup JSON files; no semantic setting changes.
- **Evidence reuse limitation:** the retained disposable copy's checker still
  matches this checker byte-for-byte, but its scene no longer matches current
  source even after EOL normalization (reason unverified). The historical 243/0
  Godot run stays historical; today's index is independently checked by the
  198 static checks and golden retained-content hashes above. No fresh runtime
  result is claimed. Manual checks and known diagnostics remain as listed above.

A successful commit/push does not change task completion or satisfy missing
gameplay acceptance. No T012+ implementation was performed during packaging.

## 2026-11-05 — Authorized checkpoint/startup/recovery phase — included in this commit

**Base:** pushed foundation `7c392eb213ecc6ef63db9ed844eecd54ae24be73`;
branch remains basement-split-floors. At the implementation handoff no commit,
staging, push, merge or branch change was performed; packaging is recorded below.
Lam explicitly authorizes and will review the narrow shared-file slice. This
supersedes the earlier T012 missing-reviewer hold for this phase; no Quan/Bao
agreement or finished teammate code review is claimed. Constitution I still
requires affected-owner approval before changing their systems; Player/enemy
systems remain untouched.

**Task status:** T012 complete as authorization/boundary record. T014-T021
implemented and independently checked. T013 remains partial for full planned
coverage because later actual-wave coverage is deferred. T025/T026 are partial:
isolated input/physics/startup/recovery checks pass, but B2 HUD rendering and
remaining manual checks block complete visual acceptance. T010/T011 remain partial.
No T022-T024 or T027+ implementation; old-B3 recovery remains separately BLOCKED
on policy, and actual waves are NOT RUN.

### Every file added or modified in this phase

| File | Change | Purpose and integration impact |
| --- | --- | --- |
| `scripts/autoload/game_manager.gd` | Modified | Combined FIRST_STAGE; explicit path/UID and trusted B1/B2 rank table; active Stage/owner/unique declaration acceptance; no downgrade, duplicate progression write or stock-setter bypass. Retain/merge loaded payload and flags; exact four legacy reference+ID pairs reset only checkpoint pair. Refuse B3 before load-state mutation and hold unresolved save/respawn references without fallback. Supported unrelated-stage stock fixture passes. Shared manager boundary only; no wave producer/reset implementation. |
| `project.godot` | Modified, mixed with preserved pre-existing edit | Set main scene to combined canonical path and add exactly one physical-F interact binding. Preserve pre-existing mesh_to_scene plugin disablement and every other input/setting. No isolated-user-data settings written to original. |
| `levels/level_1/basement_full.tscn` | Modified | Add Stage-owned B1/B2 local checkpoint instances and resource; align default Player/Spawn to supported (-3,1.2,14), B2 checkpoint Spawn (49,7.2,5). Other foundation blocks/Hidden unchanged; no geometry changes. |
| `levels/objects/checkpoint/basement_checkpoint.gd` | Added | Basement-only InteractiveArea3D script replacing inherited stock contact activation. Living active Player/actual overlap/no-dialogue/load guard, fresh-F input, acceptance-only tint/exact two-second local message and restored active tint. Shared helper/Player/HUD unchanged. |
| `levels/objects/checkpoint/basement_checkpoint.gd.uid` | Added | Stable script identity generated by Godot ResourceUID in isolated probe; no cache edits. |
| `levels/objects/checkpoint/basement_checkpoint.tscn` | Added | Inherit existing helm/detector/Spawn visuals, override behavior and add local Label3D feedback. No auto-activation script or second HUD. |
| `tests/basement_checkpoint_check.gd` | Added | Independent fixture/interaction/recovery runs, exact isolation guards, synthetic payload sentinels and test-only process/scene controls. Actual physical-F dispatch, overlap, rank/owner/duplicate/legacy/B3 refusal, support rays/body settling, injected damage through real Player/FSM and rendered captures. Test controls do not implement production waves or prove actual wave behavior. |
| `tests/basement_checkpoint_check.gd.uid` | Added | Stable new runner identity from isolated ResourceUID generator. |
| `specs/001-integrate-basement-stage/tasks.md` | Modified | Record actual Lam authorization, implementation completion, partial tests/visual acceptance and separate deferred work without fabricated review. |
| `specs/001-integrate-basement-stage/validation.md` | Modified | Current authorization, isolated copy/user-data/log provenance, results/corrections/diagnostics, captures, preservation and manual limitations; retain historical evidence. |
| `docs/implementation-bugs.md` | Added | Flag HIGH baseline payload-loss BUG-001 and B3-load BUG-002 fixed in scope; HIGH B2 health-bar capture issue BUG-003 remains open with reproduction and phase impact. No speculative HUD/player/renderer fix. |
| `docs/implementation-changelog.md` | Modified | Append this cumulative phase record, exact affected files, shared-system effects, evidence and unfinished work. |

No files removed. Root AGENTS.md, constitution, specification/plan/research/model/
contract/quickstart, historical foundation checker/UID, Stage, SaveSystem,
InteractiveArea3D, stock checkpoint, Player/enemy scripts/scenes and separate B3
remain unchanged. No new wave API or durable clear/unlock keys are implemented;
fixture flags are preservation sentinels only. Other pre-existing cache/library/
concept/progress changes remain untouched and unstaged.

### Verification and limitations

Full provenance and commands: current phase section in feature validation.md.
Disposable root: `ArcanaCheckpoint-da11bc20c86749c9a4c091c4df511339`
under the user's temp directory; Godot `4.7.2.stable.official.ed1daf0bf`.
Pre-autoload no-autoload probe confirmed the exact temp-backed user directory
and no save before copied-game startup. All save files are synthetic. No original
project or real player-save launch/access. New UIDs generated in the isolated probe.

| Check | Result |
| --- | --- |
| Current fixture suite | 55 passed / 0 failed, exit 0; owner/duplicate/rank/idempotence/stock behavior, nested data/flags, exact legacy/negative/B3 lanes |
| Headless interaction | 24 passed / 0 failed, exit 0; no arrival activation, actual F dispatch, exact feedback/tint, echo/repeat, synthetic dialogue/dead/overlap |
| Rendered interaction | 26 passed / 0 failed, exit 0; includes B1/B2 screenshot assertions, captures inspected |
| Final supported recovery | 55 passed / 0 failed, exit 0; six fixture cases, support rays/body settling, registration/camera/health and real damage/dead-state reload path |
| Rendered recovery diagnostic | 56 passed / 0 failed; B2 screenshot inspected; earlier direct-death-signal variant, not substituted for final damage/dead-state run |
| Actual normal main-scene startup | Five separate no-save/B1/B2/legacy-B1/legacy-B2 process launches; expected combined scene/endpoint/camera/one Hud, exit 0 |
| B3 refusal | Path/UID/direct/startup/death checks pass zero-load/state/file preservation; recovery outcome separately BLOCKED |
| Foundation/protected files | Static reversal of only declared scene edits reproduces pushed foundation; protected Stage/save/helper/player/enemy/stock checkpoint/B3 match HEAD |
| Whitespace/branch/index | git diff --check passes after removing an extra documentation EOF blank; original branch/HEAD retained; index empty |

Historical foundation checker remains a first-group golden snapshot, not the
checkpoint-phase runner: its retained-block/transform expectations predate these
authorized checkpoint/spawn additions. It was not rewritten or used to claim
current all-phase acceptance.

Harness-only early errors were corrected: SceneTree autoload/type resolution,
dynamic Dictionary typing, JSON numeric round-trip comparison, frame timing and
recording initial placement before gravity. Expected red first established the
missing request API before production edits. Final passes above supersede failed
harness drafts; they do not hide gameplay findings.

**Open HIGH BUG-003:** B2 captures lack the health bar despite one visible Hud node,
while B1 capture shows it. Cause/regression attribution is unproven. Blocks full
T025/T026 visual/HUD acceptance; needs manual reproduction and HUD/renderer review.
Captured checkpoint marker/message and restored B2 player/floor are visible.

Other diagnostics retained: headless certificate-store failure also reproduced
without game autoloads; shutdown ObjectDB/resource leaks (4/1 fixtures, 3/1
interaction, 14/1 repeated recovery); one rendered recovery run emitted a GLES3
shader initialization error. No proven attribution or out-of-scope fixes.

Still manual: human-controlled approach/leave and camera framing/visibility,
real dialogue and other-interactable overlap, ordinary combat-driven death,
normal B2 startup/death/restart HUD rendering, and complete route/factory/navigation/
containment acceptance from T010. Actual finite-wave/reset/clear behavior and
old-B3 recovery policy remain unimplemented/unverified separately. A passing
synthetic fixture or rendered capture is not whole-feature acceptance or sign-off.

## 2026-11-05 — Third implementation replan — planning/evidence only

Planning-only group, packaged in this commit with Implementation 2. No scene/script construction. Preserve pushed foundation
and uncommitted checkpoint work; branch/HEAD unchanged. The new baseline
basement_b1.tscn ext-resource-order edit was already present at entry and is preserved.

| File | Change in this activity | Why / integration impact |
| --- | --- | --- |
| `specs/001-integrate-basement-stage/clearance-measurements.md` | Added | Reproduction, actual collider/headroom measurements, controller dependency and isolated evidence; no fixed claim |
| `specs/001-integrate-basement-stage/third-implementation-plan.md` | Added | Two review-gated passes, smallest scene-local safety proposal, candidate openings, spawn/spacing impact and owner boundaries |
| `specs/001-integrate-basement-stage/clearance-candidates.svg` | Added | Actual floor-cell X/Z footprint map, two unchosen opening/landing/retry proposals, current spawns/checkpoints/Hidden and reproduced traps |
| `specs/001-integrate-basement-stage/plan.md` | Modified narrowly | Link current replan and reverse old route-before-ceiling-test dependency; preserve broader plan |
| `specs/001-integrate-basement-stage/tasks.md` | Modified narrowly | T034 partial measurements; T035 pass-1 ceilings/containment then T038 contact/recovery tests; T036 waits for pass-1 acceptance and recorded Lam/Quan route choice, then T039 retry tests. No geometry completion markers |
| `specs/001-integrate-basement-stage/validation.md` | Modified | Append planning authority, current baseline, reproduction/isolation/findings/limits and review stop |
| `docs/implementation-bugs.md` | Modified | Add open HIGH BUG-004: B1 vertical double jump traps in B2 triangle floor, expected ceiling/fall/landing/recovery vs actual stuck state; no implementation/fix |
| `docs/implementation-changelog.md` | Modified | This cumulative planning/evidence entry; distinguish proposal from built work |
| `specs/001-integrate-basement-stage/clearance-candidates.svg.import` | Unexpected generated sidecar, left unstaged | Godot import metadata appeared for the new SVG. Retained for review, not an authored gameplay/configuration change |
| `.godot/uid_cache.bin` | Existing tracked modification; current hash differs from prior session | No explicit assistant write/cleanup; timing/attribution unproven. Preserve current contents and report generated-metadata observation in validation.md |

**Evidence:** verified fresh ArcanaClearance disposable project/user-data probe;
four under-B2 headless reproductions, two non-trapping controls, independent rendered
repeat and before/stuck captures. Real physical input and existing Player physics,
without production edits. B1 floor1.01, B2 thin front-face plane7, no functioning
underside, trapped root≈6.144 with wall normals and accumulating negative velocity.
Upper prototype crate top≈5.542 means a uniform ceiling6.8 would leave inadequate
headroom. Logs/data retained in the disposable root recorded in measurements.

**Proposal, not a fix:** retain six-metre spacing; local solid underside/roofs and
measured perimeter closure. Treat prototype stack separately with an explicitly
reviewed guard/hold; don't silently cap it too low. Pass 1 proves ceiling contact,
falling, landing and normal movement recovery. Pass 2 is a separate deliberate
opening and safe parkour/landing/retry after Lam/Quan choose A, B or a revision.
No choice is inferred; no floor cut, route, cap or temporary guard is built now.

**Shared impact:** none implemented. No player/enemy/manager/save/input/checkpoint/
library edits or intentional cache edits in this planning activity. A future spacing change would move
B2 child spawns/checkpoints if its container moves, require explicit reconciliation
if only GridMap cells move, and require review of visibility thresholds: changing
floor_height alone does not move the first B1→B2 threshold. Existing IDs save
locations by reference, not coordinates. Bao owns any required controller change.

**Status/limits:** T034 partial; T035-T040 not built/tested. No post-fix pass, route
traversal, perimeter escape or full-floor sweep claim. SVG XML/geometry preview
checked; native SVG includes labels (Godot raster preview omits SVG text).
Certificate-store and shutdown leaks remain existing diagnostics; invalid item34
outside sampled candidates noted separately. BUG-003 visual/HUD issue remains open.
No real-save access, generators, scene/script edits, staging, commits or pushes.
Stop for Lam/Quan review of pass 1 and later route selection.

Final source preservation: 207 original scene/script/test/mesh files equal the
fresh entry copy; original settings match after removing copy-only isolation keys.
SVG import sidecar appeared and original UID cache differs from earlier hashes;
a running importer is suspected but not proven. Neither was discarded or staged.
See validation.md's final metadata observation; no cache-equality claim is made.

## Commit handoff — Implementation 2 and Implementation 3 replan — this commit

**Base:** `7c392eb213ecc6ef63db9ed844eecd54ae24be73`.
**Message:** `Implement basement checkpoints and document ceiling replan`.
**Destination:** existing `origin/basement-split-floors`,
`https://github.com/Deltaruneman/ProjectVNG.git`. Local/remote matched the base at
preflight; normal push only. This entry supersedes earlier uncommitted/no-push
handoff statements for packaging only. It does not authorize more gameplay work.

Lam reports **successful manual checkpoint activation**. No floor-specific steps,
engine/isolation details or recovery/HUD results were supplied with that report.
Record it as Lam's observation, not comprehensive acceptance or Quan/Bao sign-off.
T025/T026 remain partial; untested manual recovery/HUD/interaction cases and
HIGH BUG-003 stay open. BUG-004 is reproduced/open. Ceiling/containment and parkour
remain planning only; neither candidate route is chosen or built.

### Exact included-file checklist against the foundation commit

A = new relative to base; M = modified. Each row is an explicit reviewed staging
decision; the final index must match exactly these 16 paths, with no file deletion.

| Include | Path | Change | Content in this commit |
| --- | --- | --- | --- |
| [x] | `docs/implementation-changelog.md` | M | Cumulative group evidence and this exact commit manifest. |
| [x] | `docs/implementation-bugs.md` | A | BUG-001/002 fixes, BUG-003 open, BUG-004 reproduced/open; no ceiling fix claim. |
| [x] | `levels/level_1/basement_full.tscn` | M (selected hunks) | Checkpoint resource/instances, supported default Player/Spawn; exclude prototype reparenting. |
| [x] | `levels/objects/checkpoint/basement_checkpoint.gd` | A | Local eligible nearby-F interaction, tint/feedback, restored active marker. |
| [x] | `levels/objects/checkpoint/basement_checkpoint.gd.uid` | A | Checkpoint script identity. |
| [x] | `levels/objects/checkpoint/basement_checkpoint.tscn` | A | Inherited visuals/Spawn with local behavior and feedback Label3D. |
| [x] | `project.godot` | M (selected hunks) | Combined main scene and physical-F interact action only; exclude editor-plugin change. |
| [x] | `scripts/autoload/game_manager.gd` | M | Canonical checkpoint/rank, payload merge, exact legacy pairs, supported startup/recovery and B3 refusal. |
| [x] | `specs/001-integrate-basement-stage/clearance-candidates.svg` | A | Unchosen candidate opening/landing/retry map; planning only. |
| [x] | `specs/001-integrate-basement-stage/clearance-measurements.md` | A | Baseline headroom/collision and reproduced softlock evidence; no construction. |
| [x] | `specs/001-integrate-basement-stage/third-implementation-plan.md` | A | Two review-gated ceiling/containment and later selected parkour passes. |
| [x] | `specs/001-integrate-basement-stage/plan.md` | M | Narrow third-phase planning reference/dependency update. |
| [x] | `specs/001-integrate-basement-stage/tasks.md` | M | Honest completed/partial tasks, Lam activation observation and two-pass planning. |
| [x] | `specs/001-integrate-basement-stage/validation.md` | M | Isolated prior evidence, Lam activation, open checks/bugs, final packaging reconciliation. |
| [x] | `tests/basement_checkpoint_check.gd` | A | Independent isolated checkpoint/legacy/refusal/interaction/recovery fixtures. |
| [x] | `tests/basement_checkpoint_check.gd.uid` | A | Runner script identity. |

Final checkpoint node ordering/unique IDs/default exported properties and expanded
InputEventKey serialization reflect the current editor-saved files. Checkpoint
IDs/transforms and F binding remain the recorded behavior. The unrelated
B2-Parkour move from B1/World to B1/Pathfinder is **excluded**, so the committed
scene retains the foundation prototype path referenced by planning evidence.

### Explicit exclusions / preserved local work

| Excluded path or hunk | Reason / disposition |
| --- | --- |
| `project.godot` editor_plugins hunk | Pre-existing mesh_to_scene plugin disablement; preserve only in working tree. Staged plugin settings equal the foundation |
| `levels/level_1/basement_full.tscn` Pathfinder/B2-Parkour reparent/reordering hunk | Outside checkpoint implementation and planning-only ceiling replan; attribution not established. Preserve local hunk without staging or reverting it |
| `levels/level_1/basement_b1.tscn` | Unrelated ext-resource ordering; leave unstaged |
| `assets/meshes/KKD_library.tres` | Pre-existing resource-block reordering; leave unstaged |
| `.godot/uid_cache.bin` | Existing generated tracked cache modification; retain, no cleanup/staging |
| `specs/001-integrate-basement-stage/clearance-candidates.svg.import` | Generated SVG import sidecar; preserve untracked |
| `docs/build_progress_1.md` | Earlier broad progress document, unestablished attribution; preserve untracked |
| `docs/godotgameteam7_full_concept.md` | Earlier broad concept document, unestablished attribution; preserve untracked |

No `git add .` or `git add -A`. Whole-file staging is limited to the fourteen
explicit non-mixed paths; the two mixed files use reviewed cached patches without
changing their working copies. Entry hashes for all exclusions and both mixed
working files are retained for final preservation checks.

### Verification and acceptance boundaries

Prior independent evidence remains recorded in the group entries and validation.md:
55 fixture, 24 headless interaction, 26 rendered interaction and 55 final
damage/dead-state recovery checks passed; five normal synthetic main-scene launches;
four baseline under-B2 softlocks plus a rendered repeat. These are historical runs,
not new claims that manual recovery/HUD or ceiling fixes passed. Existing certificate,
shutdown-resource and one shader diagnostic remain documented.

Packaging verification PASSED: 294 focused static checks against the exact index,
including the 16-file manifest, selected hunks, retained foundation blocks,
scene/resource/NodePath invariants, obvious-secret patterns, UID metadata and open
task/bug status. Staged SVG XML parses; `git diff --cached --check` returns exit 0.
There are no staged file deletions, ceiling/route changes, plugin edits or prototype
reparenting. The remaining mixed-file diffs contain exactly those excluded hunks.
No Godot launch or real-save access is needed for packaging. Current editor saves
are reconciled statically with tested checkpoint behavior; unrelated prototype
reparenting is omitted rather than attributed to this work. No broad audit,
implementation, scene repair or test rewrite is part of this commit/push.
