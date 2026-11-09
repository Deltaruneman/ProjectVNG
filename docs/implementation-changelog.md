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
## 2026-11-07 — T043 F6 scene startup follow-up

**Status:** Implementation is present; runtime behavior is not verified. T043 remains
open until the isolated F6/F5 acceptance checks are performed. No reviewer agreement is
claimed for this follow-up.

**Cause:** The configured main scene and `GameManager.FIRST_STAGE` are both
`levels/level_1/basement_full.tscn`. The local save had a valid `stage_1.tscn` checkpoint
(`village`). `register_stage()` previously used only scene path equality, so an explicit
F6 run of `basement_full.tscn` was treated as ordinary main-scene startup and redirected
to that saved checkpoint.

**Included files and purpose:**

| File | Purpose / effect |
| --- | --- |
| `scripts/autoload/game_manager.gd` | In `register_stage()`, detect Godot's explicit `--scene` launch argument and skip saved-checkpoint conflict/continuation and checkpoint spawn restoration for that isolated scene run. F5, which has no explicit scene argument, retains the existing continue-from-save flow. Does not clear or rewrite the save. This is a shared startup/recovery system change within the existing GameManager boundary. |
| `specs/001-integrate-basement-stage/tasks.md` | Record T043 scope, ownership/review boundary, observable acceptance criteria, and pending runtime checks; update task totals/current state. |
| `specs/001-integrate-basement-stage/validation.md` | Record the observed configuration/save cause, implementation, and the distinction between static review and unrun runtime acceptance. |

**Shared-system/integration effects:** Only GameManager startup routing changes. Stage,
SaveSystem serializer, player, checkpoint scenes, scene resources and project settings are
untouched by this group. Prior local changes in other files were preserved.

**Verification:** Read-only inspection confirmed the saved checkpoint target and the
existing registration branch. Static review confirms the `--scene` bypass encloses both
the conflict fallback and checkpoint stage/spawn restoration. No tests or Godot runs were
performed. Required isolated F6 and F5 runs with a synthetic `stage_1.tscn`/`village` save
remain unfinished; runtime behavior must not be reported as verified.

**Known limitations / unfinished work:** T043 remains open pending F6 scene identity,
default spawn, unchanged save, and F5 continuation checks. Existing T025/T026 partial
status, BUG-003, other open feature tasks, and prior review boundaries remain unchanged.

## 2026-11-07 — T044 active-floor camera visibility

**Status:** The render-visibility change is implemented. Runtime camera, floor-transition,
collision and navigation behavior is unverified; T044 remains open. Quan review/sign-off is
not recorded.

**Included files and purpose:**

| File | Purpose / effect |
| --- | --- |
| `levels/level_1/basement_floor_visibility.gd` | Render only the active `floor_level`; retain B1_5's existing secret-area condition; hide the B1 room ceiling GridMap visually so it does not block the camera. No collision/navigation/movement data is edited. |
| `specs/001-integrate-basement-stage/tasks.md` | Define T044 scope, owner/review boundary, acceptance criteria, and required camera/floor/collision checks; update totals. |
| `specs/001-integrate-basement-stage/validation.md` | Record static baseline findings, implementation and outstanding runtime checks without claiming a fix. |
| `docs/implementation-changelog.md` | Preserve this cumulative implementation and verification record. |

**Shared-system/integration effects:** Changes are limited to the basement Stage's render
visibility script. The script still processes hidden floors and their collision/navigation
nodes remain in the scene. Scene geometry, shared mesh libraries, player/camera systems,
checkpoints, saves, and the open T034-T038 ceiling/route work are unchanged.

**Verification:** Static source inspection only; no Godot run or test was performed. Required
playtest: switch among B1, B1_5, B2, B3 and GroundExit, inspect camera sightlines and confirm
collision/navigation behavior remains intact. No known new runtime errors are established.

**Limitations / unfinished work:** T044 remains open pending the playtest. T034-T038 remain
open; this render-only change does not constitute measured ceiling/route construction or
acceptance. No reviewer agreement is claimed.

### T044 correction — keep the selected floor during jumps

**Cause:** T034's recorded B2 jump reaches root Y≈12.9342 from Y≈7.0006. The visibility
formula's B3 threshold is Y=11.5, so a jump could select B3 before landing on B2. The
measurements are prior runtime evidence; no new playtest was run for this correction.

**Included file and purpose:** `levels/level_1/basement_floor_visibility.gd` now retains the
selected floor while the player is airborne and recalculates after landing. This prevents
jump height alone from switching rendered floors. Collision, floor geometry, camera system,
and navigation remain unchanged.

**Verification and limitations:** Static source review only. Runtime B2 jump/landing and
floor-transition checks are pending under T044. Do not claim the floor-3-at-B2-jump issue
is runtime-verified as fixed until that playtest is recorded. No reviewer agreement is
claimed.

#### User-reported B2 ladder case and selector revision

The user supplied a screenshot showing the B2 ladder area with B2 hidden and B3 rendered.
This shows that retaining the prior floor only while airborne was insufficient: the player
can stand on elevated B2 stairs above the height threshold. The selector now identifies the
floor from a short downward physics ray against the grounded player's supporting collider,
and retains the prior selection while airborne. Height is only a startup fallback before a
supporting floor is found. No Godot playtest was run; collider mapping and camera behavior
remain unverified under T044.

#### Final T044 selection rule — midpoint during ascent

The user clarified that the upper floor should become visible while climbing, near halfway
between floors, before landing. This supersedes the support-collider/airborne-retention
approach described above. The script now uses the player height continuously with
`switch_margin=3.0`, selecting the upper floor at the midpoint: Y=4, 10, and 16 for the
current B1/B2/B3/GroundExit spacing. B1_5's secret-area filter remains in effect. Static
source review and `git diff --check` were performed; no Godot playtest was run. Stair ascent
and possible transition flicker remain unverified under T044.

#### Superseding T044 implementation — connector-local thresholds

The user approved a connector-specific solution because global height thresholds also
changed floors during ordinary jumps. `levels/level_1/basement_floor_visibility.gd` now
uses the existing B1↔B2, B2↔B3, and B3↔Ground ladder markers as horizontal transition zones
(3.5 m radius). Within each zone, crossing the pair's vertical midpoint while grounded or
touching a wall selects the destination floor; crossing back down selects the source floor,
with 0.25 m hysteresis. Outside connectors, a short downward physics ray identifies the
grounded support floor, and the selection stays fixed while airborne. Scene geometry,
player movement, and collision configuration are not edited.

Static review and `git diff --check` only; no Godot playtest was run. Marker alignment,
connector radius, transitions at the pictured stair, reverse descent, and ordinary jumps
outside connectors remain unverified. T044 remains open and no reviewer agreement is claimed.

## 2026-11-07 — T045 HUD and Skill Tree spellbook presentation

**Task status:** T045 implemented; runtime interaction and visual verification remain
unrun, so the task stays open. BUG-003 remains open and is not attributed to or claimed
fixed by this UI work.

### Included files and purpose

| File | Purpose and effect |
| --- | --- |
| `ui/health_bar.gd` | Replace the persistent `T: Cây kỹ năng` prose with the existing SP count; append a clickable spellbook icon in a sixth toolbar slot marked T. Preserve the four active-skill slots and ultimate slot positions and their existing behavior. |
| `ui/skill_tree_layout.gd` | Remove the menu shortcut footer; give the menu a dark two-page/spine book presentation and horizontal open/close tween. Opening pauses immediately; closing resumes after the animation. Existing T, Escape, close button, and allocation UI remain connected. |
| `assets/ui/skill_tree_book.svg` | Add a small project-authored vector book icon with a magical star and page lines. No existing spellbook image asset was found; existing pixel spell/skill icons remain available. |
| `specs/001-integrate-basement-stage/tasks.md` | Add T045 owner, scope, acceptance criteria and verification boundary; update task count. |
| `specs/001-integrate-basement-stage/validation.md` | Record pre-implementation acceptance, implementation status, asset search result, verification limits and open BUG-003 status. |
| `docs/implementation-changelog.md` | Add this cumulative implementation-group record. |

### Integration effects, verification and limitations

- Shared-system effects: HUD presentation/Skill Tree only. No input mapping, combat,
  skill progression, health/rage logic, basement scene, or BUG-003 diagnosis changed.
- **PASSED:** focused source/diff review confirmed the five skill slots retain their prior
  indexes and the new book/T slot is appended; the existing `skill_tree` action is retained.
  `git diff --check` is clean. The new SVG path matches its script reference.
- **NOT RUN:** no Godot parse, runtime, input, mouse-click, animation, or rendered-layout
  check was performed. Those behaviors and the sixth-slot fit need visual playtesting;
  the created icon is custom vector artwork rather than an existing project book asset.
- Known errors: none observed in static review. Unfinished: record T045 runtime results and
  any needed layout correction; BUG-003 B2 health-bar symptom and T025/T026 acceptance remain
  independent and open. No reviewer sign-off is claimed.

#### T045 correction — consume book-slot click through the viewport

The user reported a Godot error at `ui/health_bar.gd` because `_on_skill_tree_slot_input()`
called `accept_event()` on `HealthHUD`, a `CanvasLayer`. Replaced it with
`get_viewport().set_input_as_handled()` after opening the Skill Tree. This keeps the click
from propagating while using the viewport input API. Static review and `git diff --check`
only; no Godot rerun was performed, so T045 runtime verification remains open.

#### T045 update — integrate user-added CrystalWitch UI atlas

The user added Elysian's free UI bundle under `assets/ui/User Interface Packs - Free/`.
The free bundle includes the CrystalWitch theme atlas but not the full-version book menu
layout. `ui/skill_tree_layout.gd` now uses an atlas crop for the crystal orb beside the
Skill Tree title and applies the pack's purple/lavender palette to the open-book pages and
frame. Keep the user-added PNG/import files intact; the existing custom book glyph remains
the toolbar icon. The bundled READ ME allows free/commercial project use and asks for the
creator to be mentioned in commercial releases; record Elysian Game Studio in game credits
if commercially distributed. Static path/source review and `git diff --check` only; Godot
visual/runtime verification remains open under T045.

#### T045 visual revision — use CrystalWitch frames on both pages

After the user reported the first integration was not visually recognizable, the menu
pages were changed from plain colored panels to paired nine-patch frames sampled from
the CrystalWitch atlas. The frame regions (25,18,47,79) and (84,17,57,80) are within the
351×304 source image. Purple page fills and matching normal/hover/pressed button styles
make the pack's theme more visible while preserving the existing skill graph and book
animation. The free pack still does not include the full book-menu layout. Static review
and `git diff --check` only; no Godot rendering check was run, so appearance and crop
quality remain unverified under T045.

#### T045 correction — unsupported NinePatchRect flip

The user reported that assigning `flip_h` to a `NinePatchRect` fails because that property
is unsupported on this control. Removed the assignment and renamed the helper argument to
describe left-page placement. Each page still uses its own CrystalWitch atlas region.
Static source review and `git diff --check` only; no Godot rerun, so T045 remains open for
runtime verification.

#### T045 visual replacement — CraftPix animated book and single-spread layout

The user reported that the previous UI was visually poor, replaced the asset at the existing UI location, and asked for all content on one visible spread with a page flip when switching Weapon/Character. The new user-added CraftPix pack is now used directly.

| Included file | Purpose |
| --- | --- |
| `ui/health_bar.gd` | Replace the T-slot's former custom SVG texture with an atlas crop from the CraftPix open-book sheet. |
| `ui/skill_tree_layout.gd` | Display the open-book crop as the resting spread, remove scrolling, use open/close sheets for book transitions, and use directional page-turn sheets when changing tabs. |
| `ui/skill_tree_graph.gd` | Scale skill nodes to fit the graph's actual available width and height while keeping their layout ratios and links. |
| `specs/001-integrate-basement-stage/tasks.md` | Update T045 requirements for the replacement pack, one-spread fit, and Weapon/Character page-turn animation. |
| `specs/001-integrate-basement-stage/validation.md` | Record the replacement asset, one-spread implementation, static observations, and outstanding runtime checks. |
| `docs/implementation-changelog.md` | Maintain this cumulative implementation-group record. |

**Referenced user-added assets:** `PNG/Open_book.png` supplies the resting spread, opening frames, and toolbar book icon; `PNG/Close_book.png` supplies closing frames; `PNG/Turning_pages_left.png` and `PNG/Turning_pages_right.png` supply tab-change flips. These asset files and import metadata were not edited. The previously added `assets/ui/skill_tree_book.svg` remains in the workspace but is no longer referenced by the toolbar.

**Integration effects:** Skill Tree/HUD presentation only. Node positions, purchases, progression rules, health/rage, input bindings, and basement/map systems were not changed.

**Static review:** the builder has no `ScrollContainer`; weapon and character graphs use available space rather than oversized fixed heights; node scale is bounded by the graph's width/height and the smallest horizontal/vertical gap or edge margin. Asset paths match the replacement folder. `git diff --check` passes. **Not run:** Godot parse/runtime, rendered layout at supported resolutions, T/click input, page flips, or pause/resume. T045 remains open pending those observations. BUG-003 remains open; no teammate/reviewer sign-off is claimed.

#### T045 correction — single-page face, icon size, and flip direction

The user reported that menu text crossed the book seam, the toolbar book appeared smaller than skill icons, and tab flips moved in the wrong direction. All layout text and tree content now occupy only the right-hand page safe area. The weapon tree was re-spaced into two columns for that narrower page, and the graph's node scaling checks pairwise two-dimensional spacing and page-edge clearance. The toolbar atlas now crops tightly around the open-book frame and slightly enlarges its icon control. Weapon-to-Character uses the left-turn sheet and Character-to-Weapon uses the right-turn sheet, reversing the previous mapping.

| Included file | Purpose |
| --- | --- |
| `ui/skill_tree_layout.gd` | Restrict content to the right page, reflow the weapon graph, and reverse page-turn sheet selection. |
| `ui/skill_tree_graph.gd` | Scale nodes against pairwise horizontal/vertical separation and graph-edge clearance. |
| `ui/health_bar.gd` | Crop the open-book icon to its non-transparent bounds and render it at the skill-slot scale. |
| `specs/001-integrate-basement-stage/tasks.md` | Refine T045 acceptance for single-page-face content, comparable icon size, and correct turn direction. |
| `specs/001-integrate-basement-stage/validation.md` | Record the correction and remaining runtime visual checks. |
| `docs/implementation-changelog.md` | Preserve this cumulative change and its evidence boundary. |

**Integration effects:** HUD and Skill Tree presentation only. No skill/progression logic or input mapping changed. `git diff --check` passes. No Godot runtime, visual or input checks were performed; one-face fit, icon size, and flip direction remain unverified in-game. T045 remains open, BUG-003 remains independent, and no reviewer sign-off is claimed.

#### T045 correction — move the single-page content to the left leaf

The user reported that the content was misaligned and had been pushed onto the wrong page. `ui/skill_tree_layout.gd` now places the same single-page content area on the left leaf's mirrored safe region (7%-47% of the book artwork width), leaving clearance at the center seam. No tree, progression, icon, animation, or input behavior was changed in this correction. Static source inspection and `git diff --check` only; no Godot visual check was run. The placement is not yet runtime-verified, T045 remains open, and no review sign-off is claimed.

| Included file | Purpose |
| --- | --- |
| `ui/skill_tree_layout.gd` | Move the page content container from the right leaf to the corresponding left leaf safe area. |
| `specs/001-integrate-basement-stage/validation.md` | Record the correction and note that visual alignment remains unverified. |
| `docs/implementation-changelog.md` | Preserve this cumulative update. |

#### T045 correction — center both tab layouts across the open-book spread

The user shared screenshots of the Weapon and Character tabs and reported that both appeared shifted. Re-centered the content box within the full open-book artwork with equal side margins, restored the weapon tree's wider node distribution across the spread, right-aligned the skill-point summary, and centered the footer buttons. Long section labels now wrap within the book content width. This supersedes the immediately prior left-leaf-only adjustment because the screenshots clarified that both tabs should balance across the spread.

| Included file | Purpose |
| --- | --- |
| `ui/skill_tree_layout.gd` | Center the content area on the full book, distribute the weapon tree across the spread, align header/footer controls, and wrap long labels. |
| `specs/001-integrate-basement-stage/tasks.md` | Update T045 acceptance from single-leaf placement to a balanced, overflow-free two-page spread. |
| `specs/001-integrate-basement-stage/validation.md` | Record the screenshot-driven correction and runtime-verification limit. |
| `docs/implementation-changelog.md` | Preserve this cumulative correction. |

**Integration effects:** Skill Tree presentation only; progression, tree allocation and input mapping are unchanged. `git diff --check` passes. No Godot rendering was run; both-tab alignment, wrap behavior and no-overflow acceptance remain unverified, so T045 stays open. No reviewer sign-off is claimed.

#### T045 refinement — prominent element choices and left-side hover descriptions

The user reported that skill nodes were too small to read and supplied a sketch for larger elemental choices, a tree shown after element selection, and a skill-description panel on the left while hovering. The existing GameManager form-purchase/selection path is retained; this change only updates the presentation and hover detail. Existing element-orb and spell-icon textures are used, so no additional asset download is needed.

| Included file | Purpose |
| --- | --- |
| `ui/skill_tree_layout.gd` | Add the left detail panel; send the graph description into it on hover; retain the existing element-choice callback that spends the current point and reveals the selected branch tree. |
| `ui/skill_tree_node.gd` | Enlarge node circles and icons; add a prominent display variant for element-choice nodes; emit hover detail signals. |
| `ui/skill_tree_graph.gd` | Fit normal and large node dimensions using per-node sizes and pairwise spacing. |
| `specs/001-integrate-basement-stage/tasks.md` | Add prominent element choices and left-side hover descriptions to T045 acceptance. |
| `specs/001-integrate-basement-stage/validation.md` | Record the UI change, reused assets, and unrun runtime checks. |
| `docs/implementation-changelog.md` | Maintain this cumulative implementation record. |

**Integration effects:** Skill Tree presentation/input feedback only. The existing one-point element selection and skill/progression rules are not changed. **Static review:** existing `32x32` elemental orbs and spell icons are referenced; no external UI pack or download is needed. `git diff --check` passes. **Not run:** Godot parse/render, hover, element selection, or visual readability checks. T045 remains open; BUG-003 and other reviewer boundaries are unchanged.

#### T045 refinement — fixed boxes, less prose, larger nodes, and graph zoom

The user reported that long description text overflowed its box and that tree nodes remained hard to read. The details card now has a fixed 176 px width with anchored inner layout, smaller wrapped text, and clipping within the box; box dimensions do not depend on the displayed description. Redundant instructional/threshold headings were removed from the tree area, with only concise point and unlock guidance retained in the left card. Node icons/circles are larger, especially the four element choices. Added fixed-size zoom out/in/percentage/reset controls, wheel zoom (65%-200%), and middle-button panning inside the clipped graph view. Text drawn inside a node does not determine the node's layout size.

| Included file | Purpose |
| --- | --- |
| `ui/skill_tree_layout.gd` | Fix the detail-card geometry, reduce description font, remove redundant graph-area text, retain concise guidance at left, and add fixed-size zoom controls. |
| `ui/skill_tree_graph.gd` | Add bounded zoom, wheel input, middle-button panning, and clipping while keeping graph bounds fixed. |
| `ui/skill_tree_node.gd` | Enlarge normal and element icons and keep node box dimensions independent of label text. |
| `specs/001-integrate-basement-stage/tasks.md` | Update T045 scope and acceptance for fixed box geometry and zoom. |
| `specs/001-integrate-basement-stage/validation.md` | Record implementation boundaries and unrun visual/runtime checks. |
| `docs/implementation-changelog.md` | Maintain this cumulative group record. |

**Shared-system effects:** Skill Tree presentation and navigation only; skill spending, unlock thresholds, character statistics, HUD behavior, and GameManager rules remain unchanged. Reuses the existing element-orb and skill-icon PNGs; no new external asset is required. `git diff --check` passes. Godot parse/render, wheel/middle input, text overflow, and supported-resolution layout checks were not run. T045 remains open, with no reviewer sign-off claimed.

#### T045 screenshot correction — keep zoom controls and skill bar within bounds

The user supplied a Skill Tree screenshot showing the top-right zoom controls outside the book art and the details card crossing the center seam, plus a HUD screenshot showing the skill bar shifted left and too large. `ui/skill_tree_layout.gd` now uses symmetric 8% book margins with clipping, relocates zoom controls into a right-aligned row above the graph, and narrows the fixed details card to 144 px so it stays on the left leaf. `ui/health_bar.gd` reduces slot size from 38×36 to 35×33 px, reduces gaps/padding, and centers the bar at the viewport midpoint.

| Included file | Purpose |
| --- | --- |
| `ui/skill_tree_layout.gd` | Bound menu content to a symmetric safe area, move zoom controls out of the crowded main header, and keep the detail card within the left page. |
| `ui/health_bar.gd` | Reduce skill-bar footprint and center it horizontally. |
| `specs/001-integrate-basement-stage/validation.md` | Record screenshot findings, implementation, and unrun runtime checks. |
| `docs/implementation-changelog.md` | Maintain this cumulative record. |

**Integration effects:** HUD presentation and Skill Tree layout only. Skill input/selection, cooldowns, progression and health behavior are unchanged. `git diff --check` passes. Godot screenshot/render verification was not run; final visual alignment and size remain unverified, and T045 remains open without reviewer sign-off.

#### T045 follow-up — confine details to left book leaf

The supplied screenshot still showed the fixed detail card crossing the book seam after the earlier width reduction. Narrowed the card from 144 px to 120 px, leaving the graph area on the right leaf.

| Included file | Purpose |
| --- | --- |
| `ui/skill_tree_layout.gd` | Keep the fixed detail panel inside the left book page. |
| `specs/001-integrate-basement-stage/validation.md` | Record the screenshot finding, source change, and remaining visual verification. |
| `docs/implementation-changelog.md` | Maintain this cumulative implementation record. |

**Integration effects:** Skill Tree layout only; skill unlocks, points, graph behavior, and the already reduced/centered skill bar are unchanged. `git diff --check` passes. Godot rendering was not run, so final alignment remains unverified and T045 remains open without reviewer sign-off.

#### T045 screenshot correction — compensate for HUD CanvasLayer scale

The latest HUD screenshot showed the skill bar positioned substantially right of center. Source inspection found `ui/hud.tscn` applies an X scale of 1.5 to the root `CanvasLayer`, so centering the bar at a local 0.5 anchor rendered it at 0.75 of the viewport width. The bar now maps the viewport center through the inverse canvas transform and uses exact half-width offsets. The bar remains at 35×33 px slots with tightened gaps and padding.

Renamed the expanded controller from `health_bar.gd` to `player_hud.gd`, updated its global class name and the scene resource path, and moved the UID sidecar without changing its UID.

| Included file | Purpose |
| --- | --- |
| `ui/health_bar.gd` → `ui/player_hud.gd` | Rename the combined player HUD controller and compensate for the CanvasLayer transform when centering the skill bar. |
| `ui/health_bar.gd.uid` → `ui/player_hud.gd.uid` | Preserve the Godot script UID under the new filename. |
| `ui/hud.tscn` | Point the HUD scene at the renamed script while keeping its UID. |
| `specs/001-integrate-basement-stage/tasks.md` | Record the centered-bar criterion and controller name in T045 scope. |
| `specs/001-integrate-basement-stage/validation.md` | Record the screenshot diagnosis, static evidence, and remaining runtime check. |
| `docs/implementation-changelog.md` | Maintain this cumulative implementation record. |

**Integration effects:** HUD presentation and script resource naming only. Health/rage logic, skill selection, cooldowns, input mappings, and progression are unchanged. `git diff --check` passes. Godot rendering/input behavior was not run; centering is supported by static transform math but remains runtime-unverified. T045 remains open with no reviewer sign-off claimed.

#### T045 parser correction — use the CanvasLayer viewport API

The user reported a parser error because `get_viewport_rect()` is unavailable on the `CanvasLayer` script base. `ui/player_hud.gd` now obtains the visible viewport width through `get_viewport().get_visible_rect().size.x` and uses that width for the center-anchor calculation.

| Included file | Purpose |
| --- | --- |
| `ui/player_hud.gd` | Replace the unsupported viewport call in the skill-bar centering code. |
| `specs/001-integrate-basement-stage/validation.md` | Record the parser report, correction, and unrun Godot check. |
| `docs/implementation-changelog.md` | Maintain this cumulative implementation record. |

**Integration effects:** HUD layout only; health/rage behavior and skill controls are unchanged. `git diff --check` passes. Godot parsing and rendering were not run, so the parser correction and visual placement remain unverified. T045 remains open without reviewer sign-off.

#### T045 screenshot refinement — nudge selected weapon tree right

The latest book-page screenshot showed the selected weapon tree sitting slightly left in its page. Added a 4% graph-width display offset for the selected weapon tree. Nodes and links share the offset; the element-selection graph and Character tree remain unchanged.

| Included file | Purpose |
| --- | --- |
| `ui/skill_tree_graph.gd` | Apply a normalized presentation offset to graph nodes and connecting lines. |
| `ui/skill_tree_layout.gd` | Nudge only the selected weapon tree 4% to the right. |
| `specs/001-integrate-basement-stage/tasks.md` | Record the selected-tree alignment requirement and the pending Dark Fairy task. |
| `specs/001-integrate-basement-stage/validation.md` | Record the screenshot adjustment and boss-HUD ownership boundary. |
| `docs/implementation-changelog.md` | Maintain this cumulative implementation record. |

**Integration effects:** Skill Tree presentation only. Unlocks, node positions relative to each other, selection, points, zoom, and player HUD health/rage behavior are unchanged. `git diff --check` passes. Godot visual/zoom verification was not run; T045 remains open without reviewer sign-off.

#### T046 request — Dark Fairy boss HUD top-center

Static inspection found the Dark Fairy health bar and phase label already centered horizontally but anchored to the bottom of the viewport. The latest user-provided screenshot shows the phase label over the lower skill bar, consistent with the bottom anchors; the boss progress bar is obscured by that lower HUD area in the crop. The requested vertical reposition belongs to `scenes/enemies/darkfairy/darkfairy.tscn`, a Duy-owned boss scene. Per `.specify/memory/constitution.md` ownership boundary, no edit was made pending Duy approval. T046 records the narrow scene-only scope and acceptance criteria; the screenshot is user-provided runtime evidence, not a local playtest, and no implementation or reviewer agreement is claimed.

#### T047 implementation — player-only bounded stair step-up

The user reported that the player still gets stuck on the B1/B2 stair connector. Added a bounded
step attempt in the player movement override: only when grounded horizontal movement is blocked,
the code checks vertical clearance, the raised horizontal path, and a walkable landing within
0.75 world units. No map or shared character collision logic was changed.

| Included file | Purpose |
| --- | --- |
| `scenes/player/player.gd` | Add the bounded player-only step-up and landing checks. |
| `specs/001-integrate-basement-stage/tasks.md` | Record T047 scope and keep it open until required runtime checks are complete. |
| `specs/001-integrate-basement-stage/validation.md` | Record Godot startup evidence and the unverified traversal/regression checks. |
| `docs/implementation-changelog.md` | Maintain this cumulative implementation record. |

**Integration effects:** Player horizontal traversal only. `BaseCharacter`, enemy movement, basement
map/GridMap colliders, stair meshes, navigation, and T044 floor visibility are unchanged. Godot
4.7.2 F6 launched `basement_full.tscn` with the player and HUD visible, confirming script parse and
scene startup. The interactive traversal attempt was stopped by physical Escape before stair
ascent/descent and regression checks could be observed; no functional pass or reviewer agreement
is claimed. `git diff --check` passes with documentation line-ending warnings. T047 remains open
pending the B1/B2 traversal, wall/gap, normal movement, and jump/landing runtime checks.

#### T048 implementation — player back sword and elemental status VFX

Enabled the existing sword at its current back mount and connected the user-added PVFX sheets to the existing player-owned burn, ice-slow, and freeze application points. Active casts now suppress the blade until their state exits. Thrown skills rely on projectile-owned suppression; removed the skill state's duplicate suppress call so the blade returns when the projectile returns. Burn and frozen-chill loops are attached to the affected enemy for the existing status duration; slow adds the Pixelfx clock marker; freeze plays a PVFX encase one-shot. Reapplying a loop refreshes its timer instead of adding another loop.

| Included file | Purpose |
| --- | --- |
| `scenes/player/player.tscn` | Enable the pre-existing `Direction/Blade` at the existing back transform. |
| `scenes/player/states/skillstate.gd` | Hide the blade during active casts, restore it on state exit, and preserve projectile-owned hiding during thrown skills. |
| `scenes/player/player.gd` | Trigger the visual helper at current burn, slow, and freeze status applications without changing their gameplay rules. |
| `scenes/player/battle_vfx.gd` | Load PVFX sheets from their manifests, play attached 3D status animations, refresh loop durations, and play the freeze one-shot. |
| `assets/effects/pixelfx/status/slowed/slowed.png` | Project-local Pixelfx sprite sheet for the slow clock marker. |
| `assets/effects/pixelfx/status/slowed/slowed.json` | Pixelfx frame rectangles, timing, loop, and pivot metadata for the slow marker. |
| `specs/001-integrate-basement-stage/tasks.md` | Define T048 ownership, scope, acceptance, and update its implementation state. |
| `specs/001-integrate-basement-stage/validation.md` | Record T048 boundaries, static evidence, and unrun runtime checks. |
| `docs/implementation-changelog.md` | Maintain this cumulative implementation record. |

**Referenced user-added inputs (already untracked at the start of this slice; not modified):** `assets/effects/pvfx-foundry-thirteen-spritesheets/effects/status/burning-aura/lit/grid/{sprite-sheet.png,manifest.json}`, `.../status/frozen-chill/lit/grid/{sprite-sheet.png,manifest.json}`, and `.../ice/freeze-encase/lit/grid/{sprite-sheet.png,manifest.json}`.

**Integration effects:** Player scene and player skill presentation only. Existing enemy status methods, durations, damage ticks and movement remain unchanged; no `scripts/enemy.gd` or Duy-owned boss file changed. Existing slash files/sheets, `BattleVFX.shield`, and `BattleVFX.emberline_ring` are unchanged. The user's PVFX directory remains untouched.

**Static review:** referenced sheets and manifests exist and provide fixed-grid frame coordinates and durations accepted by the loader. The Pixelfx slow sheet and metadata were exported and inspected. `git diff --check` passes, with only Git's CRLF/LF normalization warning for validation docs. **Not run:** tests, Godot import/parse, runtime visual, combat, status expiry/refresh, or sword hide/restore checks. T048 is implemented but remains open until those in-game checks are observed; no reviewer agreement is claimed.

#### T049 implementation — floating sword idle motion

Added a gentle hover and sway to the existing player sword so it reads as suspended instead of rigid. The animation records the sword's current instance transform as its resting pose and applies small vertical and angular offsets around that pose. The existing sword asset, mount, facing and visibility suppression remain intact.

| Included file | Purpose |
| --- | --- |
| `scenes/player/weapon/floating_blade.gd` | Animate subtle hover and sway relative to the sword instance's captured rest transform. |
| `scenes/player/weapon/blade.tscn` | Attach the floating animation to the existing sword root. |
| `.godot/uid_cache.bin` | Existing tracked Godot UID cache changed during this workspace update and was retained without manual edits. |
| `specs/001-integrate-basement-stage/tasks.md` | Record T049 ownership, scope, acceptance and open runtime status. |
| `specs/001-integrate-basement-stage/validation.md` | Record the review boundary, implementation evidence and unrun visual checks. |
| `docs/implementation-changelog.md` | Maintain this cumulative implementation record. |

**Integration effects:** player sword presentation only; the blade scene is only instanced by the player. No shared character, enemy, combat, skill, sword asset, or mount transform changes. Existing attack/skill suppression remains responsible for hiding the animated node.

**Static review:** implementation offsets are relative to the instance transform captured on `_ready()`. `.godot/uid_cache.bin` grew from 429,747 to 490,208 bytes during the workspace update; no Godot process was running during final inspection, so its writer/source is unknown. The tracked cache was preserved without manual edits. `git diff --check` is the whitespace validation. **Not run:** Godot import/parse or in-game visual/attack/skill checks, so the motion amplitude and final appearance remain unverified and may need visual tuning. T049 stays open pending that runtime review; no reviewer agreement is claimed.

#### T050 implementation — player dash afterimage trail

Added a short trail during the existing dash. Each echo duplicates the player's currently animated `Sprite3D`, fixes it at the sampled world pose, tints it cool blue, and fades it quickly. The existing PVFX dash-dust sheet plays once at the dash origin and aligns to the projected travel direction when the camera is available. Dash speed, duration, cooldown, invincibility and collision are unchanged.

| Included file | Purpose |
| --- | --- |
| `scenes/player/states/dash.gd` | Start the trail, emit afterimages through the dash, and finish with a last pose. |
| `scenes/player/battle_vfx.gd` | Create/fade world-fixed snapshots of the player's actual sprite and play the existing PVFX dash-dust animation. |
| `specs/001-integrate-basement-stage/tasks.md` | Record T050 scope, acceptance and open runtime status. |
| `specs/001-integrate-basement-stage/validation.md` | Record the asset review, integration evidence and remaining checks. |
| `docs/implementation-changelog.md` | Maintain this cumulative implementation record. |

**Referenced user-added inputs (not modified):** `assets/effects/pvfx-foundry-thirteen-spritesheets/effects/smoke/dash-dust/lit/grid/{sprite-sheet.png,manifest.json}`. Static manifest check found 13 non-looping frames on a 68×32 canvas with 780 ms total duration. Pixelfx `status/haste` was inspected but not selected because its generic humanoid afterimages do not match the Foxy player; the trail reuses Foxy's live sprite instead.

**Integration effects:** player dash presentation only. No gameplay movement, enemy, shared character, slash, or skill code changed. **Static review:** PVFX asset paths/manifest and dash-state call sites inspected; `git diff --check` is the whitespace validation. **Not run:** Godot parse/import, in-game direction, scale, visual quality, fade cleanup, or dash regression checks. The dust rotation also depends on a camera being available; otherwise it retains its default horizontal orientation. T050 remains open pending visual/runtime review; no reviewer agreement is claimed.

#### T051 implementation — stronger dash trail visibility

Retuned the T050 trail after user feedback that it was too faint. Afterimages now emit every 32 ms instead of 45 ms, start at 0.62 alpha instead of 0.34, and fade over 0.28 s instead of 0.22 s. The existing PVFX dash dust is scaled from 0.22 to 0.30 and opacity from 0.70 to 0.90. Dash gameplay values remain unchanged.

| Included file | Purpose |
| --- | --- |
| `scenes/player/states/dash.gd` | Emit the existing afterimage snapshots more densely during dash. |
| `scenes/player/battle_vfx.gd` | Increase afterimage visibility/fade duration and dash-dust size/opacity. |
| `specs/001-integrate-basement-stage/tasks.md` | Record T051 scope, acceptance and open visual status. |
| `specs/001-integrate-basement-stage/validation.md` | Record before/after tuning values and unrun visual check. |
| `docs/implementation-changelog.md` | Maintain this cumulative implementation record. |

**Integration effects:** player dash presentation only; no change to movement, cooldown, invincibility, collision or other VFX. **Static review:** tuned values inspected and `git diff --check` is the whitespace check. **Not run:** Godot playtest or visual overlap/strength review, so the final prominence remains unverified. T051 stays open pending a Godot view; no reviewer agreement is claimed.

#### T052 implementation — dash afterimage alpha blending

Fixed the likely reason the afterimages were invisible: the source player sprite uses alpha-cut discard and each duplicate was assigned partial opacity. Temporary copies now use standard alpha blending before the tint/fade is applied; the source Foxy sprite retains its original pixel-edge mode.

| Included file | Purpose |
| --- | --- |
| `scenes/player/battle_vfx.gd` | Disable alpha-cut only on duplicated dash afterimages so partial opacity can blend. |
| `specs/001-integrate-basement-stage/tasks.md` | Record T052 scope, acceptance and runtime status. |
| `specs/001-integrate-basement-stage/validation.md` | Record the likely cause, alpha mode evidence and unrun runtime check. |
| `docs/implementation-changelog.md` | Maintain this cumulative implementation record. |

**Integration effects:** temporary dash copies only; the base sprite's alpha-cut, dash mechanics and other VFX are unchanged. **Static review:** copied node now sets `SpriteBase3D.ALPHA_CUT_DISABLED` before setting partial `modulate.a`; Godot's [SpriteBase3D docs](https://docs.godotengine.org/en/stable/classes/class_spritebase3d.html#enum-spritebase3d-alphacutmode) define mode 0 as blending and mode 1 as discard. **Not run:** Godot parse or visual confirmation, so visibility/fade is not runtime-verified. T052 remains open until seen in game; no reviewer agreement is claimed.

#### T053 implementation — Dark Fairy health-bar style synchronization

Changed the Dark Fairy boss health bar from Godot's plain `ProgressBar` to the same textured presentation used by regular enemies. It reuses the Kenney red flat button texture for the progress and under layers, the dark under tint, texture filter, z-index and four-pixel nine-patch frame. Boss-specific size/placement and health update behavior remain unchanged; the script's bar type annotation now matches the new node type.

| Included file | Purpose |
| --- | --- |
| `scenes/enemies/darkfairy/darkfairy.tscn` | Apply the regular enemy texture/tint/nine-patch health-bar style to the existing boss bar. |
| `scenes/enemies/darkfairy/darkfairy.gd` | Keep the boss bar's typed node reference compatible with `TextureProgressBar`. |
| `specs/001-integrate-basement-stage/tasks.md` | Record T053 scope, relayed owner approval and open runtime status. |
| `specs/001-integrate-basement-stage/validation.md` | Record the style comparison, review boundary and unrun checks. |
| `docs/implementation-changelog.md` | Maintain this cumulative implementation record. |

**Integration effects:** Dark Fairy HUD presentation and its static bar node type only. `scenes/ui/enemy_health_bar.tscn`, regular enemy behavior, boss health/phase logic, boss label and the user's existing Dark Fairy scene edits are preserved. The user reports Duy approval for the style change; no direct reviewer agreement is claimed. **Static review:** boss texture/style properties match the regular enemy bar source. `git diff --check` is the whitespace validation. **Not run:** Godot import/parse or in-game visual comparison, so T053 remains open until runtime review.

#### T054 implementation — player ultimate cut-in

Added a player-owned cinematic before the existing ultimate execution. A ready ultimate now captures its selected ID, pauses gameplay, circles and zooms the active camera toward the player, then displays the rendered Pixelfx black/white impact-frame with an elemental accent and that ultimate's Vietnamese name. The camera's original transform/FOV and previous pause state are restored before the captured ultimate casts. A missing camera/current scene keeps the old immediate-cast path. Early exit also restores camera/pause state.

| Included file | Purpose |
| --- | --- |
| `scenes/player/player.gd` | Gate the cut-in on ultimate readiness, capture the selected skill, prevent duplicate starts, and cast after cinematic completion. |
| `scenes/player/ultimate_cinematic.gd` | Pause-aware camera orbit/zoom, impact frame/title, and camera/pause cleanup. |
| `scenes/player/ultimate_cinematic.gd.uid` | Preserve the Godot resource UID sidecar for the new cut-in script. |
| `scenes/player/battle_vfx.gd` | Add an opt-in always-processing Pixelfx impact-frame overlay for the paused impact beat; normal impact calls retain their existing path. |
| `assets/effects/pixelfx/impacts/impact-frame/impact-frame.png` | Add the 10-frame transparent Pixelfx anime impact-frame sheet rendered for this cut-in. |
| `assets/effects/pixelfx/impacts/impact-frame/impact-frame.json` | Preserve frame timing, atlas layout, and Pixelfx pivot metadata for the impact-frame sheet. |
| `specs/001-integrate-basement-stage/tasks.md` | Record T054 scope, acceptance, total task count, and open runtime status. |
| `specs/001-integrate-basement-stage/validation.md` | Record the review boundary, implementation evidence, static check, and unrun runtime checks. |
| `docs/implementation-changelog.md` | Maintain the cumulative implementation record. |

**Integration effects:** player ultimate presentation and temporary use of the active shared `Camera3D`; no camera-rig, damage, cooldown, enemy, slash, or ice-shield changes. Existing sword/dash/status and boss/map working-tree changes were preserved. The existing Pixelfx source license and notice remain in the local library checkout. **Static review:** the local Pixelfx catalog and rendered 10-frame sheet (0.3 s, 320×180) were inspected alongside all eight ultimate names, four element colors, readiness/capture flow, pause-mode overrides, camera/FOV restoration, early-exit cleanup, and asset path. `git diff --check` found no whitespace errors; Git emitted line-ending normalization warnings for already modified Markdown records. **Not run:** Godot parse/import or in-game visual/camera/cast/cleanup checks. Orbit duration, framing, impact readability and timing remain subject to runtime review; T054 stays open and no reviewer agreement is claimed.


#### T055 implementation — front-facing ultimate cut-in pose

Updated the cut-in to show Foxy's front-facing idle while the camera zooms and the impact/title card appears. Before pausing, the player stores current and pending direction, animation name/playback position/active state, and sprite frame/flip, then sets direction to down and starts idle_down at its first front-facing frame. The existing cinematic cleanup restores the player's directions and animation state before restoring the camera/pause state. The cut-in can now be interrupted without leaving the player facing or animating in the temporary pose.

| Included file | Purpose |
| --- | --- |
| scenes/player/player.gd | Capture, apply and restore the temporary front-facing player pose and prior animation state. |
| scenes/player/ultimate_cinematic.gd | Apply the pose at cut-in start and restore it on completion/abort before unpausing. |
| specs/001-integrate-basement-stage/tasks.md | Record T055 ownership, scope, acceptance, task count and open runtime status. |
| specs/001-integrate-basement-stage/validation.md | Record static animation mapping/state evidence and unrun runtime checks. |
| docs/implementation-changelog.md | Maintain the cumulative implementation record. |

Integration effects: player-only presentation during the existing ultimate cut-in. Normal animation assets, state-machine behavior, gameplay and camera/cut-in timings are unchanged. Static review confirmed down is the camera-facing orientation and idle_down exists with front frames 16/20; git diff --check passes. Godot parse/playtest and animation restoration from varied starting poses remain NOT RUN, so the face-forward visual and exact in-game restore are unverified; T055 remains open and no reviewer agreement is claimed.


#### T056 implementation — zoom-only ultimate camera

Removed the cut-in camera orbit and its positional movement. The camera now remains at its saved position and orientation while its FOV eases to 68% of the starting value during zoom-in, then returns during zoom-out. The exact original camera transform/FOV is restored before the game resumes and casts the selected ultimate. This supersedes the T054 orbit behavior; impact frame, front-facing player pose, pause duration, and skill effects are otherwise unchanged.

| Included file | Purpose |
| --- | --- |
| scenes/player/ultimate_cinematic.gd | Replace orbit/translation with FOV-only zoom-in and zoom-out. |
| specs/001-integrate-basement-stage/tasks.md | Update the current cut-in acceptance, task total, and record T056 scope/status. |
| specs/001-integrate-basement-stage/validation.md | Record the review boundary, source evidence, and unrun runtime checks. |
| docs/implementation-changelog.md | Maintain the cumulative implementation record. |

Integration effects: active Camera3D FOV only; position/orientation remain fixed by the cut-in methods. Player pose, pause, impact/title, skill cast, camera rig, and gameplay values are unchanged. Static review confirmed zoom update methods only write FOV; git diff --check passes. Godot parse/playtest and actual visual stability/framing remain NOT RUN, so T056 stays open and no reviewer agreement is claimed.


#### T057 implementation — expand Skill Tree spread and graph

Expanded the book spread horizontally, used more of the spread for page content, made the description panel responsive to viewport width, reduced spacing between the description and graph, and set the initial graph zoom to 110%. The existing tabs, graph coordinates, node purchase callbacks, pan/zoom behavior, and progression rules remain as before.

| Included file | Purpose |
| --- | --- |
| ui/skill_tree_layout.gd | Increase the open-book/page footprint and give the graph a wider responsive area with a modestly larger default view. |
| specs/001-integrate-basement-stage/tasks.md | Record T057 scope, owner, acceptance, updated task total and open runtime state. |
| specs/001-integrate-basement-stage/validation.md | Record the pre-implementation boundary, implementation details and unrun runtime checks. |
| docs/implementation-changelog.md | Maintain this cumulative implementation record. |

Integration effects: Skill Tree presentation only. Weapon/character tab content, selection/allocation, tooltips, pan/zoom controls and gameplay progression callbacks are preserved. Static review confirms responsive size formulas and unchanged graph/node construction; `git diff --check` is the whitespace check. Godot parse/import, responsive visual/layout checks and input/allocation interaction are NOT RUN. T057 remains open until runtime visual/input verification; no reviewer agreement is claimed.


#### T058 implementation — lightning enemy status visual

Added the local Pixelfx `lightning/electrified` loop as the enemy status visual for lightning attacks that already apply the short freeze/stun mechanic. This includes elemental weapon hits, the active chain/strike/storm skills and both lightning ultimates. The current `apply_skill_freeze` logic and durations remain unchanged, while ice skills continue to use the existing frozen presentation.

| Included file | Purpose |
| --- | --- |
| scenes/player/player.gd | Route every lightning freeze/status call site to an explicit electric status visual without changing gameplay duration. |
| scenes/player/battle_vfx.gd | Attach the electrified loop to the enemy and use the existing duration timer so repeated hits refresh one sprite. |
| assets/effects/pixelfx/lightning/electrified/electrified.png | Add the rendered 60-frame electrified sprite sheet. |
| assets/effects/pixelfx/lightning/electrified/electrified.json | Preserve frame rectangles, timing, loop, pivot and Pixelfx metadata. |
| specs/001-integrate-basement-stage/tasks.md | Record T058 scope, owner, acceptance, updated task total and open runtime state. |
| specs/001-integrate-basement-stage/validation.md | Record the pre-implementation boundary, asset/source inspection and unrun runtime checks. |
| docs/implementation-changelog.md | Maintain this cumulative implementation record. |

Integration effects: shared enemy status presentation and player lightning-skill call sites only. Fire, ice and wind visuals, enemy freeze mechanics/durations, slash, and ice-shield systems are unchanged. The local Pixelfx catalog candidate and contact sheet were inspected before export; the source library and its license/notice remain unchanged. Static review covered all lightning call sites and status refresh logic. Godot import/parse, in-game scale/contrast and effect expiry/refresh are NOT RUN. T058 remains open pending runtime visual/lifecycle verification; no reviewer agreement is claimed.


#### T059 implementation — Player HUD combat feedback

Added compact in-combat state feedback to the Player HUD. The rage label is visible beside its bar and reports readiness only when the selected ultimate has full rage and no remaining cooldown. Two narrow defense slots show Shift/Dash and L/Parry readiness/cooldown. A status strip displays remaining seconds for current attack/speed buffs and the ice shield. A pulsing low-health label appears for a living player at one-third HP or less.

| Included file | Purpose |
| --- | --- |
| scenes/player/player.gd | Expose current timed attack/speed/shield status to the HUD without changing their values, rules, or durations. |
| ui/player_hud.gd | Add defense cooldown slots, status chips, low-health pulse, and truthful ultimate-ready text. |
| ui/hud.tscn | Reveal and position the rage label alongside the existing rage bar. |
| specs/001-integrate-basement-stage/tasks.md | Record T059 scope, owner, acceptance, task total and pending runtime status. |
| specs/001-integrate-basement-stage/validation.md | Record the review boundary, implementation evidence and unrun runtime checks. |
| docs/implementation-changelog.md | Maintain this cumulative implementation record. |

Integration effects: Player HUD presentation plus display-only timer tracking in the player. Existing input mappings (1-4 slot select, U skill, Shift dash, L parry, I ultimate), cooldowns, buff/shield mechanics, health and Skill Tree behavior are unchanged. Static review matched the displayed keys to `project.godot`, checked one-third HP logic, readiness requirements, status expiry/consumption and bar sizing; `git diff --check` is the whitespace validation. Godot parse/import, viewport fit, key behavior and visual status/cooldown timing are NOT RUN. T059 remains open until runtime visual/input verification; no reviewer agreement is claimed.


#### T060 implementation — Player HUD presentation polish

Removed numeric rage from the visible label and ultimate tooltip while keeping the progress bar and ready state. Reduced skill slots from 35×33 to 29×29 logical pixels, kept the elemental skills/ultimate/tree together, and moved Dash/Parry into a distinct adjacent panel with compact generated pixel icons, key badges and readable cooldown text. Added a soft red screen-edge vignette that pulses only while the player is alive at or below one-third health; it uses a dedicated identity-transform CanvasLayer so the HUD's horizontal scaling does not stretch the effect. The vignette and warning hide while the Skill Tree is open.

| Included file | Purpose |
| --- | --- |
| ui/player_hud.gd | Compact and regroup skill slots, generate Dash/Parry icons, remove rage percentages, and add the low-health edge vignette. |
| ui/hud.tscn | Remove the initial percentage text from the rage label. |
| specs/001-integrate-basement-stage/tasks.md | Record T060 owner, scope, acceptance, task total and pending runtime status. |
| specs/001-integrate-basement-stage/validation.md | Record the review boundary, static implementation evidence and unrun runtime checks. |
| docs/implementation-changelog.md | Maintain this cumulative implementation record. |

Integration effects: Player HUD presentation only. Input mappings, cooldown sources, health rules, Skill Tree behavior and combat logic are unchanged; the icon textures are generated in memory and add no imported assets. Static review checked zero percentage rage strings, slot-to-array indices, icon cache IDs, health gating and shader edge falloff. `git diff --check` reports no whitespace errors; Git emits Markdown CRLF normalization warnings for the already modified changelog and validation record. NOT RUN: Godot parse/import and in-game layout, icon, cooldown, vignette and pulse checks. T060 remains open pending runtime review; no reviewer agreement is claimed.
