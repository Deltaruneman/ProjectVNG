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
