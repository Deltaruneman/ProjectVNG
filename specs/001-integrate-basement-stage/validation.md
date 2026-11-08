# First Scene-Foundation Validation

**Date**: 2026-11-05 | **Branch**: `basement-split-floors`
**Initial HEAD**: `0c01c67b3fa087fa898a8d5f4e7d8afbe170cd3f`
**Current activity**: authorized commit/push packaging of Implementation 2 and the
Implementation 3 replan; no ceiling/parkour construction or route selection.
Earlier no-commit handoffs below are historical; current packaging scope is recorded at the end.
**Latest verification**: See current checkpoint-phase authorization/results at the end:
T012 and T014-T021 complete; T013/T025/T026 partial; BUG-003 visual/HUD blocker open.
T010/T011 remain partial; Lam's observations recorded without teammate sign-off.
Current ceiling planning evidence reproduces HIGH BUG-004; see the final planning section.
Earlier isolation-blocked results are retained as history.
**Review**: User explicitly authorized this bounded work. Assistant scope/diff review only;
Quan has not reviewed or signed off. No approval from Quan is implied.

## Initial status and preservation baseline (T001)

Initial `git status --short`:

```text
 M .godot/uid_cache.bin
 M assets/meshes/KKD_library.tres
 M project.godot
?? .agents/
?? .specify/
?? docs/
?? specs/
```

SHA-256 baseline captured for 247 existing files: tracked levels/scripts/scenes/UI/tests,
project/settings/mesh resources/tracked caches, and existing visible untracked documentation.
Real user progress was not inspected. Selected preservation hashes follow; all 247 are compared
again at completion. Existing tracked changes were not cleaned up.

| File | Initial SHA-256 |
| --- | --- |
| `levels/level_1/basement_full.tscn` | `EEB5340ADE0BA3BD2DB2EEE23E644AADA07C304A03479BC827A8D189A90DA76C` |
| `levels/level_1/basement_b3.tscn` | `AC02484CFD729C7680AECEE5AEF30401D6100E578726A65E04D5757BA8491F86` |
| `.godot/uid_cache.bin` | `4806865148A74B682DAB28CF0C2951C89B521DAB5248FC92FDD5D98AEF44999D` |
| `assets/meshes/KKD_library.tres` | `39719D8CD1C635F74AA4BF7284A88276CA06AC7F0A60096E9EDB282A250C1733` |
| `project.godot` | `E451F4D90E57E854F60ABF0FD73742B2EC03E2B5B9248CE5238E0B635FFC7D93` |
| `assets/meshes/basement_library.meshlib` | `7F84EB6522FD0B3CBB7BD8B4B2D8814A9AFAE37E4AAD571A9FCA6CA1241CE34D` |
| `assets/meshes/MVP_library.tres` | `F3CE5829BF9DC565F617EDA07065DEB087840F59AA41823F1DFE5A6D417BFD22` |
| `scripts/autoload/game_manager.gd` | `D695B35803FB2198EA020920D16409E33AEAF568FCED5264A64B239BFCB8E17B` |
| `scripts/autoload/save_system.gd` | `E2B609BC561F0F657CD865947AA0EBB5BF2569B3658DC974471824BC4EDA07FA` |
| `scripts/grid_pathfinder.gd` | `0C4CC9F3639FF78BB3F52A932916A78536AB73BDD18DFB933EF3069F0EB45815` |
| `scenes/player/player.tscn` | `FBD1E7BEC3D19CEA8AE73192F4D2BFA75EAE5BCB3FC13927B92A9CCCF113B75D` |
| `levels/level_1/basement_floor_visibility.gd` | `D81446BB522DB060926D5A552F3B91AEFCD0C8C3427A6A397D3C693D9D6192A1` |

Retained-scene golden manifest: 57 serialized node blocks, excluding root, B3/GroundExit,
and only the two allowed obstacle-array lines. Aggregate normalized-text SHA-256:
`6b57013726fc713115e4760415cae5b9a8930cd41a2e935f74537ce776bec9f0`.
Root body SHA-256: `a1e9361c0f1cd3c088f56735707c262e7279f771b899c0e6e112d67ec9d4c6fe`.
These check geometry, resources, transforms, Hidden content, Player/Spawn and all retained
properties without asserting physical correctness.

## Scope and checklist gate (T002)

Read constitution, approved spec/plan/tasks, research, data model, contract, and quickstart.
Prerequisite resolver returned this absolute feature directory and existing required artifacts.
No extension hooks registered (extensions.yml absent). Existing .gitignore covers .godot/;
tracked caches remain tracked/preserved. Ignore-file edits are outside allowed writes.

| Checklist | Total | Checked | Unchecked | Marker status |
| --- | --- | --- | --- | --- |
| requirements.md | 16 | 14 | 2 | FAIL by generic marker gate |

The two unchecked items are documented no-implementation-detail exceptions for explicit
user constraints. Current user authorization expressly permits T001-T011. Proceed under that
bounded authorization; checklist content/markers remain unchanged. This is not Quan sign-off.

Only writes allowed: combined scene, focused test script, this report, task-status markers.
No startup/input/checkpoint/save/player/enemy/wave/ceiling/parkour/gate/library changes.
No generators, branches, commits, pushes or T012+ execution. Reviews remain pending where
external review is required; the assistant does not fabricate agreement.

## Engine and isolation disposition (T003)

Supplied executable exists: `C:/Users/Chung Kiết Lâm/Desktop/Godot_v4.7.2.exe`.
Read-only `--version` returned `4.7.2.stable.official.ed1daf0bf` (exit 0).
Only version/help commands were invoked; no project, editor, scene, import, or script launch.
Help documents --path, --script, --check-only and --log-file; no pre-autoload user-data override
was established. No other engine was downloaded.

**BLOCKED: runtime isolation within the current write allowlist.** Project autoloads include
SaveSystem/GameManager/Dialogic. GameManager._ready immediately calls load_game;
SaveSystem defaults to user://save.json. A test-script override or F6 would not establish
pre-autoload isolation. The allowlist provides no disposable project/user-data configuration
path. Do not read/write real progress or run the original project speculatively. No real
progress contents were read and no save/reset/continuation API was invoked.

The focused GDScript script documents and checks an isolated-copy precondition, but its
own guard runs too late to protect autoload startup; it is not a substitute for isolation.
Independent Node.js read-only structural checks are safe and do not load Godot/autoloads.
GDScript parsing/execution and all scene/physics tests remain blocked, not falsely passed.

## Test-first structural baseline (T004)

Authored tests/basement_integration_check.gd before editing the scene. Independently executed
Node.js serialized-scene checks against the same baseline constants, without a Godot launch.
Initial result: 162 PASSED, 4 FAILED (expected baseline defects): root not Stage, integrated
B3/GroundExit present, null obstacle entries in B1 and B1_5 Pathfinders. These are observed
static test failures, not new regressions or gameplay results.

## Terminal-containment inspection (T008)

Static serialization and read-only builder-source inspection show B2/LadderSpot_B2_B3 at
(51, 7, 5), above an existing B2 floor cell (25, 3, 2); all nine surrounding floor cells
x=24..26/z=1..3 exist. Existing back/right perimeter cells remain, and no B3 loading Door
exists in the combined scene. B3/GroundExit are separate upper branches; removing them does
not remove B2's floor or perimeter cells. No demonstrated newly exposed terminal opening
justifies a speculative wall in this interior area. Therefore no boundary is added.

This is not proof of sufficient physical containment. Existing front perimeter is lower
than back/right; actual collider behavior, jump escape and containment need an isolated
playtest. Record any real failure before selecting the smallest justified terminal boundary.
Do not infer collision from visibility or modify the room/parkour speculatively.

## Results, changes and manual verification

### Changes actually made

| File | Change and purpose |
| --- | --- |
| levels/level_1/basement_full.tscn | Rename root to Stage for existing factory ancestry; remove 17 serialized B3/GroundExit nodes; remove nulls from two obstacle arrays |
| tests/basement_integration_check.gd | New read-only serialized-scene suite and baseline hashes; explicit isolated-copy precondition; no scene instantiation or save APIs |
| specs/001-integrate-basement-stage/validation.md | Baseline, scope, structural evidence, blocked runtime checks and manual instructions |
| specs/001-integrate-basement-stage/tasks.md | Task status only: T001/T002/T004-T008 checked and status summaries updated; no later task text/status changed |

There were no newly orphaned external dependencies: all 14 external file references remain
used and exist. Retained subresource references are declared. Scene now has 58 serialized
nodes: root plus 57 retained nodes. No new boundary, gate, checkpoint, asset, spawn repositioning,
startup change or script-system change was made.

Both original non-null obstacle paths resolve and remain unchanged:

- B1/Pathfinder -> ../HiddenGate_B1_5/B1_5Side.
- B1_5/Pathfinder -> ../../B1/HiddenGate_B1_5/B1_5Side.

The null entries were the documented reference defects; no relative path was guessed broken.
The root body's properties and all retained node properties/resources/transforms are golden-
hash identical after excluding only the two authorized obstacle-array lines. In particular,
Hidden wall/room/collision configuration, B1/B2 geometry, current parkour, Player/Spawn,
CameraRig/Hud/Bullets, and existing enemy-zone configuration are unchanged.

### Check results

| Check/lane | Status | Evidence and limits |
| --- | --- | --- |
| Supplied engine version | PASSED | 4.7.2.stable.official.ed1daf0bf; version command exit 0 |
| Pre-edit serialized baseline | FAILED, expected | 162 passes/4 baseline failures: root, integrated floors, two null arrays; demonstrates targeted structural defects |
| Final independent structural suite | PASSED | Node.js read-only parser, exit 0: 141 passes/0 failures using constants from the GDScript suite; no Godot/autoload launch |
| Root and retained content preservation | PASSED (static) | Root body and 57-block golden hash unchanged except allowed obstacle lines; correct root name |
| Retained NodePaths/resources | PASSED (static) | All serialized NodePaths resolve, 14 external files exist, ExtResource/SubResource IDs declared, no null obstacles |
| Serialized runtime-object composition | PASSED (static) | One direct Player, CameraRig, Hud; no nested Stage scene added; actual runtime counts unverified |
| Separate B3 preservation | PASSED | SHA-256 unchanged: ac02484cfd729c7680aecee5aef30401d6100e578726a65e04d5757ba8491f86 |
| Existing terminal cell/perimeter preservation | PASSED (static) | Terminal floor/adjacent cells and B2 World block unchanged; no newly exposed opening established; no speculative boundary added |
| Godot GDScript parse / structural runner execution | BLOCKED | Pre-autoload user-data isolation unavailable within allowed writes; independent Node checks do not prove GDScript parses |
| Isolated F6 load/registration/camera/physics | BLOCKED | Same isolation blocker; no assertion that static composition equals runtime behavior |
| Factory/navigation gameplay smoke | BLOCKED | Needs isolated scene; source ancestry defect addressed statically, actual behavior unverified |
| Physical containment/push/jump checks | BLOCKED | Needs isolated physics/playtest; no sufficient-containment claim |
| Quan review/sign-off | NOT RUN | No review/sign-off supplied; assistant's diff review is not Quan's approval |
| F5/startup/recovery/checkpoints/waves | NOT RUN, out of scope | T012+ excluded; old-B3 recovery policy not chosen or tested |
| Ceiling/complete parkour/fall-retry/completion gates | NOT RUN, out of scope | Subsequent groups; no gameplay completion claim |

Check counts differ before/after because removing 17 nodes removes their parent/resource
assertions. The intermediate preservation check also caught one surplus blank line at the
removed-branch boundary; it was corrected, then the final 57-block golden hash passed.
No gameplay defect is claimed fixed from these serialized checks.

### Pre-existing issues versus regressions

- **Observed static baseline defects addressed**: Basement root incompatible with
  Node3DFactory's named Stage ancestry, integrated B3/GroundExit outside approved composition,
  null obstacle entries dereferenced by GridPathfinder. Runtime effects remain unverified.
- **Existing and unchanged**: B1 Pathfinder uses World while additional B1 geometry lives
  in nested maps. Serialized reference resolution does not prove navigation coverage.
- **Existing and unchanged**: Player position differs from root Spawn. Current main scene,
  FIRST_STAGE, interact input, checkpoints, save behavior and old-B3 recovery conflict remain
  outside this slice. Do not run F5/death tests to imply those flows are now integrated.
- **Existing and unverified**: lower front B2 perimeter, possible ceiling/route obstructions,
  jump-state/camera/physical escape behavior. Removal preserves every retained B2 cell;
  their real behavior needs isolation. No player/enemy/library adjustment was made.
- **No new structural regression detected** by the final suite and retained-content hashes.
  New runtime regressions cannot be ruled out without the blocked scene checks.

### Task disposition at stop

| Task | Status | Reason |
| --- | --- | --- |
| T001 | Complete | Initial Git status and preservation hashes recorded |
| T002 | Complete | Authorized bounded scope and pending external review boundaries recorded; no invented sign-off |
| T003 | BLOCKED/partial | Exact engine verified, but safe runtime isolation cannot be established within the write allowlist |
| T004 | Complete | Focused serialized GDScript suite authored before edits; expected structural failures independently observed |
| T005 | Complete | Root name changed, root properties and singleton nodes preserved |
| T006 | Complete | Integrated B3/GroundExit removed, separate B3 bytes preserved |
| T007 | Complete | Nulls removed; retained paths verified; no geometry/behavior repair invented |
| T008 | Complete (inspection decision) | No demonstrated new terminal opening; no unnecessary boundary added; physics remains T010 |
| T009 | Partial, unchecked | Independent structural lane passed; the authored GDScript runner's parse/execution is still blocked |
| T010 | BLOCKED, unchecked | No safely isolated Godot scene playtest |
| T011 | Pending, unchecked | Assistant diff/evidence review recorded; runtime blockers and Quan review remain explicit |
| T012-T042 | NOT RUN | Not authorized; all remain unchecked |

### Final preservation review

Compared all 247 baseline files after the bounded work: 245 unchanged; only the authorized
combined scene and task-status document changed. Two new files are the allowed structural
test script and this validation record. No baseline file was removed.

Pre-existing project.godot, KKD_library.tres and uid_cache.bin hashes still match the initial
table. Separate B3, player/enemy/shared scripts, remaining scenes, UI, existing tests, retained
mesh libraries, and earlier feature artifacts remain unchanged. Branch remains
basement-split-floors; no commit/push/branch operation occurred.

No engine-generated project/cache/UID file change was observed: there was no project/editor
launch/import. Version/help commands created no additional repository files. No generated
changes were discarded, and no tracked cache was edited or reset. Scene diff whitespace
check passed. Separate structural passes are independent of all blocked recovery fixtures.

No test suite is marked FAILED merely because isolation is blocked. No blocked runtime
check is marked passed or hidden by structural success. First group and whole-feature
acceptance are incomplete. This run stops before T012.

## Exact manual verification for blocked checks (not executed)

The following requires a disposable copy/user-data setup outside the four allowed write
paths. It is a manual follow-up, not changes performed by this run. Do not launch F6,
F5, --script or --check-only against the original project assuming they isolate saves.

1. Close running copies of the game. Create a new uniquely named disposable folder such as
   `%TEMP%/ArcanaFoundation-<new-GUID>` and copy the current project there, including its
   existing imported .godot resources if needed, excluding .git. Leave the original untouched.
   Do not run basement/mesh generators. Engine-generated files must stay in the copy.
2. Before opening/running that copy in Godot, edit **the copied project.godot only**, in its
   existing `[application]` section, to set:

   ```ini
   config/use_custom_user_dir=true
   config/custom_user_dir_name="ArcanaFoundation-<same-new-GUID>"
   ```

   Use a genuinely new name, not an existing user-data directory. Verify this setup directs
   user:// to that unique test directory with no save.json, before any gameplay launch.
   Never copy real progress into it or inspect the original save. If isolation cannot be
   confirmed, stop and retain BLOCKED status. Changing a script's save_path after autoload
   startup is insufficient. Use a separate disposable Windows account as additional isolation
   if custom-user-data behavior cannot be independently confirmed.
3. Verify the supplied engine again with `--version`. In a PowerShell session set `$copy`
   to the disposable project directory, then run the structural runner **only in that copy**:

   ```powershell
   & 'C:/Users/Chung Kiết Lâm/Desktop/Godot_v4.7.2.exe' --headless --path $copy --script res://tests/basement_integration_check.gd -- --isolated-copy
   ```

   Expect zero serialized-structure failures and unchanged separate-B3/retained-content
   hashes. Record parser/runtime errors honestly; this command is not a physics test.
   Its guard is additional protection, not proof of pre-autoload isolation. Do not run
   the historical split checker, which intentionally loads B3.
4. Open the **copied** project with the verified executable, preferably editor recovery mode
   to avoid editor plugins/tool execution. Do not run EditorScripts/generators. Open
   `levels/level_1/basement_full.tscn`, confirm root Stage and required nodes, then F6 only.
   Do not press F5/F9 or trigger checkpoints/death/recovery in this first-group check.
5. In the Remote scene tree, verify one active Player, CameraRig, Hud, and registered Stage.
   Inspect GameManager.current_stage without changing save data. Confirm camera target,
   visible support surfaces, and absence of B3/GroundExit. Record load/spawn errors.
6. With existing controls, exercise safe B1 movement/camera and an existing projectile/factory
   interaction where available; inspect output for missing Stage/Bullets/pathfinder errors.
   Observe existing navigation without changing enemies/waves. Avoid death; stop if it occurs,
   because recovery/startup remains outside this slice. Record each exercised/unexercised case.
7. For B2-only inspection without requiring unfinished parkour, pause the copied run and use
   the **Remote** inspector to place the existing Player on a supported B2 floor, such as near
   (49, 7.2, 5); this is a diagnostic placement, not verified traversal or a saved scene edit.
   Resume and inspect camera/visibility/floor support near LadderSpot_B2_B3 (51, 7, 5).
   Attempt walking/pushing/jumping toward nearby terminal/perimeter edges using current
   abilities; record whether physical containment holds. Stop rather than adding speculative
   walls or changing player systems. Record any baseline escape/geometry issue separately.
8. Record engine build, copy/user-data identity, steps, actual outcomes, screenshots and
   errors per check. Keep isolated scene, factory/navigation and containment results separate.
   Quan reviews the scoped diff and evidence; until actually supplied, do not claim sign-off.
   Do not write test-generated caches back to the original or delete pre-existing changes.

No startup/checkpoint/save/wave/ceiling/parkour/completion-gate success follows from these
steps. Any newly justified terminal boundary needs its own minimal reviewed scene change
and rerun, still within the first-group boundary. No T012+ continuation is authorized here.

## Follow-up isolated verification — 2026-11-05

This section supersedes the earlier isolation BLOCKED disposition for T003/T009.
The user explicitly authorized disposable project/user-data/log creation for verification,
with original-repository writes limited to this report and task statuses. No additional
scene/gameplay implementation, original runner repair, or T012+ work was authorized or performed.

### Current baseline and retained copy

At follow-up start Git still showed the existing scene/settings/cache/resource changes,
untracked documentation/test script, and an already-present
`tests/basement_integration_check.gd.uid`. The UID was pre-existing to this verification
run and was preserved. Captured a fresh 250-file preservation baseline before launching tools.

- Disposable root: `C:/Users/CHUNGK~1/AppData/Local/Temp/ArcanaFoundation-c534c41288a44f71bf7df8cd2c0eb8be`
- Copied project: `C:/Users/CHUNGK~1/AppData/Local/Temp/ArcanaFoundation-c534c41288a44f71bf7df8cd2c0eb8be/project`
- Logs: `C:/Users/CHUNGK~1/AppData/Local/Temp/ArcanaFoundation-c534c41288a44f71bf7df8cd2c0eb8be/logs`
- No-autoload isolation probe: `C:/Users/CHUNGK~1/AppData/Local/Temp/ArcanaFoundation-c534c41288a44f71bf7df8cd2c0eb8be/isolation-probe`
- Verified writable user data: `C:/Users/CHUNGK~1/AppData/Local/Temp/ArcanaFoundation-c534c41288a44f71bf7df8cd2c0eb8be/userdata-base/ArcanaFoundation-c534c41288a44f71bf7df8cd2c0eb8be`
- Manual launcher: `C:/Users/CHUNGK~1/AppData/Local/Temp/ArcanaFoundation-c534c41288a44f71bf7df8cd2c0eb8be/Open-Isolated-Editor.ps1`

Copy command (not a Git checkout; includes uncommitted files and existing imports):

```powershell
robocopy 'E:/Test/ProjectVNG' 'C:/Users/CHUNGK~1/AppData/Local/Temp/ArcanaFoundation-c534c41288a44f71bf7df8cd2c0eb8be/project' /E /XJ /XD .git /R:1 /W:1 /NFL /NDL /NP /LOG:'C:/Users/CHUNGK~1/AppData/Local/Temp/ArcanaFoundation-c534c41288a44f71bf7df8cd2c0eb8be/logs/copy.log'
```

Robocopy exit 1 denotes successful copying: 17,137 files, 442.53 MB, zero failed/mismatched
files. .git was excluded. Critical scene/test/manager/save/cache hashes matched the originals
before any copied-game launch. The focused GDScript runner was not modified in either location.
The combined and separate B3 scenes also remain byte-identical between original and copy.

### Isolation established before game autoload startup (T003)

Configured ONLY the copied project.godot with these application keys before launching it:

```ini
config/use_custom_user_dir=true
config/custom_user_dir_name="ArcanaFoundation-c534c41288a44f71bf7df8cd2c0eb8be"
```

Removing exactly those inserted keys reproduces the original settings hash. Startup scene,
input, plugins and all other original project settings were not changed.

A separate minimal probe project has those same custom-user-data settings, no autoload section,
and a builtin-only script. It reports OS.get_user_data_dir and globalized user://, rejects
unexpected paths, and checks save existence only after the unique expected path is verified.
Thus the probe cannot invoke GameManager or original progress APIs.

First probe resolved to the new unique Roaming/ArcanaFoundation-c534c41288a44f71bf7df8cd2c0eb8be directory, with no save.
The first copied-project structural run passed but Dialogic could not create its directory
there. This did not involve the original game's user-data directory. No old save was copied,
inspected, reset or loaded.

To provide a writable sandbox location, subsequent child processes received a process-local
APPDATA override to `C:/Users/CHUNGK~1/AppData/Local/Temp/ArcanaFoundation-c534c41288a44f71bf7df8cd2c0eb8be/userdata-base`. The no-autoload probe verified the resulting
user:// path exactly before the game autoloads were allowed to start. The isolated directory
was created under the disposable root and save.json was absent. The override was not persisted
to the user's environment or original project.

Probe/runner/scene commands were started with Start-Process -Wait -PassThru, hidden windows,
stdout/stderr files, and explicit --log-file paths. Representative actual arguments:

```powershell
& 'C:/Users/Chung Kiết Lâm/Desktop/Godot_v4.7.2.exe' --version
$env:APPDATA = 'C:/Users/CHUNGK~1/AppData/Local/Temp/ArcanaFoundation-c534c41288a44f71bf7df8cd2c0eb8be/userdata-base'
$env:ARCANA_EXPECTED_USERDATA = 'C:/Users/CHUNGK~1/AppData/Local/Temp/ArcanaFoundation-c534c41288a44f71bf7df8cd2c0eb8be/userdata-base/ArcanaFoundation-c534c41288a44f71bf7df8cd2c0eb8be'
& 'C:/Users/Chung Kiết Lâm/Desktop/Godot_v4.7.2.exe' --headless --path 'C:/Users/CHUNGK~1/AppData/Local/Temp/ArcanaFoundation-c534c41288a44f71bf7df8cd2c0eb8be/isolation-probe' --script res://probe.gd --log-file 'C:/Users/CHUNGK~1/AppData/Local/Temp/ArcanaFoundation-c534c41288a44f71bf7df8cd2c0eb8be/logs/isolation-temp.log'
& 'C:/Users/Chung Kiết Lâm/Desktop/Godot_v4.7.2.exe' --headless --path 'C:/Users/CHUNGK~1/AppData/Local/Temp/ArcanaFoundation-c534c41288a44f71bf7df8cd2c0eb8be/project' --script res://tests/basement_integration_check.gd --log-file 'C:/Users/CHUNGK~1/AppData/Local/Temp/ArcanaFoundation-c534c41288a44f71bf7df8cd2c0eb8be/logs/structural-temp.log' -- --isolated-copy
```

Engine version: `4.7.2.stable.official.ed1daf0bf`.
Confirmed probe exit 0: expected temp-backed path, GameManager autoload absent, save_exists=false.
Original progress was never copied or accessed. After verification, isolated save.json still
does not exist; Dialogic's isolated directory creation succeeds under the temp override.

### Focused GDScript structural runner (T009)

The unchanged focused runner parsed and executed successfully in the copied project.
Both the initial and temp-backed runs returned exit 0 with:

```text
STRUCTURAL RESULT: 243 passed, 0 failed
```

This is actual Godot GDScript execution, distinct from the earlier 141 independent Node.js
checks. Its 243 assertions include per-node absence/uniqueness/parent checks, retained golden
hashes, external resources and declared IDs, non-null obstacles, retained NodePaths, separate
B3 hash, and Stage inheritance source. No runner correction is needed or proposed.

There were no runner parser errors or resource-resolution failures. Assertion success does
not erase stderr diagnostics listed below or imply physics/gameplay correctness.

Evidence: logs/structural-temp.stdout.txt, structural-temp.stderr.txt and structural-temp.log.

### Isolated scene-load and runtime composition (T010 partial)

Created an additional diagnostic script ONLY inside the disposable copy:
`tests/verification_scene_probe.gd`. It explicitly loads basement_full.tscn rather than
starting the configured main scene, observes one process frame, records registration/counts,
then frees the scene and quits. It performs no inputs, movement, checkpoint activation,
death/recovery, saved continuation or wave acceptance. The copied focused runner remains unchanged.

Actual launch arguments for the diagnostic rerun:

```powershell
$env:APPDATA = 'C:/Users/CHUNGK~1/AppData/Local/Temp/ArcanaFoundation-c534c41288a44f71bf7df8cd2c0eb8be/userdata-base'
$env:ARCANA_EXPECTED_USERDATA = 'C:/Users/CHUNGK~1/AppData/Local/Temp/ArcanaFoundation-c534c41288a44f71bf7df8cd2c0eb8be/userdata-base/ArcanaFoundation-c534c41288a44f71bf7df8cd2c0eb8be'
& 'C:/Users/Chung Kiết Lâm/Desktop/Godot_v4.7.2.exe' --headless --path 'C:/Users/CHUNGK~1/AppData/Local/Temp/ArcanaFoundation-c534c41288a44f71bf7df8cd2c0eb8be/project' --script res://tests/verification_scene_probe.gd --fixed-fps 60 --quit-after 12 --log-file 'C:/Users/CHUNGK~1/AppData/Local/Temp/ArcanaFoundation-c534c41288a44f71bf7df8cd2c0eb8be/logs/scene-load-cleanup.log'
```

Original short run and graceful-cleanup rerun both returned exit 0 and observed:

```text
scene = res://levels/level_1/basement_full.tscn
root = Stage
Player = 1; CameraRig = 1; Hud = 1
GameManager.current_stage == loaded Stage: true
stage_changed registration events observed: 1
CameraRig.target == Player: true
integrated B3 present: false; GroundExit present: false
player position = (-7.833418, 1.0, 15.4608)
isolated save_exists = false
```

These are limited runtime facts at the observed frame. Camera target identity is not visual
tracking validation. This does not establish stable movement/collision, factory execution,
navigation coverage, safe physical containment or complete traversal.

Evidence: scene-load.stdout/stderr.txt and scene-load-cleanup.stdout/stderr.txt, with matching
.log files. A verbose diagnostic rerun used the same cleanup probe with --verbose and logs
scene-load-verbose.stdout/stderr.txt / scene-load-verbose.log.

### Errors and limitations — retained separately from passes

| Check/diagnostic | Status | Observed evidence |
| --- | --- | --- |
| Pre-autoload isolation | PASSED | No-autoload probe confirmed unique temp user path before copied game launch; no save existed |
| Focused GDScript parsing/assertions | PASSED | 243 passes/0 failures, exit 0; runner unchanged |
| Explicit combined-scene load | PASSED, limited | PackedScene load/instantiate entered tree; requested scene only |
| Runtime object counts and registration | PASSED, limited | One Player/CameraRig/Hud, correct manager Stage, one observed registration |
| Camera target identity / absent upper floors | PASSED, limited | Target points to Player; B3/GroundExit absent |
| First Dialogic directory creation | FAILED initially, isolation setup corrected | user://dialogic creation error under initial unique Roaming path; absent on temp-backed rerun |
| Root-certificate store access | FAILED environmental diagnostic | "Failed to read the root certificate store" at os_windows.cpp:2582; also reproduced in minimal no-autoload probe |
| Scene shutdown cleanliness | FAILED diagnostic, cause not proven | 3 ObjectDB instances leaked and 1 resource still in use after graceful cleanup; exit code still 0 |
| Visual camera / visibility behavior | NOT RUN | Headless target-reference observation is insufficient |
| Movement and collision | NOT RUN | No inputs or physical route test |
| Factory/projectile and navigation behavior | NOT RUN | No interaction/pathfinding gameplay smoke |
| Physical B2 containment | NOT RUN | No walking/pushing/jumping/escape attempts |
| Quan review/sign-off | NOT RUN | No supplied review; assistant observations are not Quan approval |

Verbose shutdown output identifies `res://scripts/fsm/fsm.gd` as the resource still in use,
one leaked Node, GDScript and GDScriptNativeClass. It also emits "Cannot get path of node as it
is not in a scene tree" while describing the leaked node. Existing unchanged player.gd:14
creates FSM.new(...), while FSM extends Node. A pre-existing detached-FSM lifetime issue is
a plausible explanation, not proven attribution from these runs. No player/FSM fix was made.
Do not characterize this as a new scene regression or an error-free run without further evidence.

The root-certificate failure is independent of gameplay because the no-autoload probe also
emits it. No network operation, engine download or certificate change was attempted.

### Updated task status and preservation

- T003: complete — compatible engine and safe, writable pre-autoload isolation demonstrated.
- T009: complete — unchanged focused GDScript suite executed; structural assertions passed;
  diagnostics remain explicit rather than being hidden.
- T010: partial, unchecked — headless scene load/count/registration passed; visual/movement/
  factory/navigation/containment checks remain NOT RUN pending manual results.
- T011: pending, unchecked — bounded verification evidence and assistant preservation review
  recorded; no Quan sign-off and manual results remain outstanding.
- T012-T042: NOT RUN and unchanged.

Original-repository writes in this follow-up are limited to validation.md and task statuses.
The fresh 250-file baseline is checked against final state; source scenes/settings/scripts,
the focused runner and its pre-existing UID, assets and tracked caches must remain identical.
Test-generated files stay inside the disposable root; none are copied back. The copy and
logs are intentionally retained for the user's manual checks.

Final comparison completed: of 250 original baseline files, 248 are byte-identical; only
validation.md and tasks.md changed. No original file was added or removed. Reversing only
the two new task markers and status-summary updates reproduces the starting tasks.md hash,
confirming T012+ task text/status is untouched. Branch remains basement-split-floors.

### Open the retained copy for manual visual checks

Run this exact command in PowerShell; the launcher sets the same verified temp APPDATA and
opens only the disposable project. The launcher was created but NOT executed by the assistant:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File 'C:/Users/CHUNGK~1/AppData/Local/Temp/ArcanaFoundation-c534c41288a44f71bf7df8cd2c0eb8be/Open-Isolated-Editor.ps1'
```

Alternatively configure the same APPDATA in that terminal and open:
`C:/Users/CHUNGK~1/AppData/Local/Temp/ArcanaFoundation-c534c41288a44f71bf7df8cd2c0eb8be/project/project.godot`
with the supplied executable, --editor --recovery-mode and --log-file in the disposable logs.
Do not import/open the original project accidentally. No F5, F9, death, checkpoint or wave tests.

Manual checklist, currently all NOT RUN:

1. Open levels/level_1/basement_full.tscn in the copied editor and press F6. Record visible
   scene loading and any debugger errors; do not infer clean output from process exit code.
2. Check camera follows existing safe movement, intended floor visibility and support surfaces.
   Do not modify player abilities/physics or scene geometry.
3. Exercise existing factory/projectile interactions only where safe and observe navigation;
   record missing Stage/Bullets/pathfinder or other errors. Avoid death; stop if it occurs.
4. For B2 terminal checks, pause and use the Remote inspector to place the existing Player on
   a supported B2 surface near (49, 7.2, 5), then resume. This is diagnostic remote placement,
   not traversal acceptance or a saved scene edit. Inspect near marker (51, 7, 5).
5. Attempt walking/pushing/jumping toward the terminal/perimeter with current abilities.
   Record physical containment, escape, collision/camera issues and screenshots. Do not add
   a boundary or change original/copy gameplay as part of reporting these checks.
6. Return separate results for scene loading, visual camera/visibility, movement,
   factory/navigation errors and B2 containment. Until results are supplied, those entries
   remain NOT RUN. Quan review is a separate unperformed review.

No first-group completion, whole-sprint completion, or T012+ continuation is implied.

## Bounded checkpoint-slice resume — 2026-11-05

This section supersedes prior scope/status statements only where explicitly stated.
The user authorizes T012-T017, the T013 tests needed for that slice, and applicable
T025 interaction checks, then stop. No later groups, generators, branch changes,
commits or pushes are authorized. Existing work remains preserved.

### Lam's observations and first-group handoff (T010/T011)

Lam reports: reviewed the expected scene changes and tested `basement_b1`,
`basement_b2` and `basement_full`, with no major issues observed.
This is user-reported runtime observation, not assistant-executed verification,
comprehensive acceptance, or Quan's review/sign-off. The supplied report does not
specify engine/copy identity, detailed steps, screenshots, debugger output, or
per-case outcomes. Do not infer that those details or isolation were verified.

- T010 remains partial/unchecked. Retain the prior 243/0 structural result and
  limited headless load/composition observations. Lam's general scene observations
  are now recorded; detailed visual camera/visibility, movement/collision,
  factory/projectile/navigation and physical B2 containment acceptance remain
  unverified. Historical NOT RUN entries describe the assistant's prior runs;
  they do not negate Lam's subsequent general testing.
- T011 is partial/unchecked: Lam's review of expected changes and bounded handoff
  are recorded. Quan sign-off is still NOT RUN/not supplied. No first-group or
  whole-feature acceptance is claimed. Authorization to attempt the next slice
  does not invent the required shared reviewer agreement.

### T012 exact outstanding decision and proposed review boundary

**Attempted/BLOCKED**: the latest tasks and validation records contain no named
shared maintainer/reviewer or actual agreement for this slice. No dependent code,
scene, settings or test edits have begun.

Decision needed: identify the shared manager/input/save maintainer/reviewer and
record actual agreement by that reviewer and Quan, with Bao's input-impact review,
to the following concrete boundary (or supply the agreed narrower boundary):

| File/interface | Proposed slice boundary |
| --- | --- |
| `scripts/autoload/game_manager.gd` | T014 only: continuous-stage identity/declared B1/B2 ID validation, trusted rank table, foreign/lower rejection, same-current idempotence, accepted/unchanged/rejected result for local feedback; retain unrelated-stage behavior |
| `project.godot` | T017 only: add missing interact-to-physical-F binding; preserve existing plugin/input changes and main scene |
| Local checkpoint and active scene | T015/T016: basement-only InteractiveArea3D variant using existing visuals, local alive/dialogue guard, prompt and acceptance-only tint/exact feedback; Stage-owned unique B1/B2 checkpoints, supported child Spawn and aligned B1 default Player/Spawn placement |
| Validation | Only slice-required T013 interaction/rank/ownership/spawn fixtures and applicable T025 isolated interaction playtests |

Excluded: T018+ payload retention/legacy/reset/routing/startup changes, save serializer,
shared interaction helper, stock checkpoints, Player APIs/physics, enemies/waves,
new clear/unlock interfaces, ceiling/parkour/completion-gate work and old-B3 recovery.
No messages were sent to teammates. A request for names/actual agreement was presented
to the user; agreement must not be inferred from silence or implementation authorization.

### Resume check results and remaining work

| Check/task | Status | Evidence or reason |
| --- | --- | --- |
| Feature resolution | PASSED | Prerequisite script resolved this feature and existing artifacts; initial PowerShell execution-policy refusal handled with process-local `-ExecutionPolicy Bypass` |
| Requirements marker scan | 14 checked / 2 unchecked | Intentional documented constraints; user's explicit bounded authorization permits proceeding; reviewer-owned markers unchanged |
| T010/T011 evidence update | Recorded, tasks partial | Lam's general observations recorded above without acceptance/sign-off claims |
| T012 agreement | BLOCKED | Named shared reviewer and actual reviewer/Quan/Bao agreement absent |
| T013 slice tests, T014-T017 implementation | BLOCKED / NOT RUN | Each depends directly or transitively on T012; no new checkpoint test or gameplay implementation |
| T025 interaction playtests | BLOCKED / NOT RUN | T014-T017 not implemented; Lam's earlier scene testing is not checkpoint acceptance |
| Later T013 coverage and later task groups | NOT RUN | Outside authorized slice; no later coverage added |
| Godot execution this resume | NOT RUN | No dependent implementation to verify; no project launch, import, or real-save access |
| Before/after extension hooks | Not applicable | `.specify/extensions.yml` absent; no registered hooks to dispatch |

Remaining manual checks once the slice is agreed and implemented: supported B1/B2
spawn/camera, nearby prompt, no arrival activation, F acceptance/tint/exact message,
B2-to-B1 rejection without save/success feedback, repeated F, overlap, dialogue/dead
eligibility and one HUD. Use the documented fresh disposable project and pre-autoload
user-data probe/override procedure above; never launch against real saves.

Only this report and tasks.md were edited during this resume. The branch remains
`basement-split-floors`; pre-existing scene/settings/resource/cache changes remain
present. No tests were rerun and no new behavior is claimed implemented or verified.

Read-only preservation checks match historical hashes for project.godot,
KKD_library.tres, separate B3, GameManager and SaveSystem. The currently present
tracked uid_cache.bin hash is
`DFB5017D46C6FD8FDA25A3A58BDE1F7EED5DC987C5C81B350028E4C649ED2E80`,
which differs from the initial-session cache hash above. Its current modification
was already present at resume entry; no engine was launched and no cache edit,
cleanup or restoration was performed. The reason for the between-session cache
change is unverified and remains for review.

## Checkpoint phase authorization — 2026-11-05 (current)

Lam explicitly authorizes and will review the narrow shared-file edits for T012-T021
and applicable T025-T026 checks. This supersedes the prior missing-reviewer hold
for this slice, including older task-specific reviewer gates; it is not Quan or
Bao agreement. Lam is the named shared-file reviewer for this slice. Constitution I
requires: "Before changing another owner's systems, contributors MUST coordinate with
and obtain approval from the affected owner." Player movement/combat/skills and enemy
systems remain untouched, so that clause does not block the authorized local
checkpoint and manager/settings work. Any need to edit those systems still requires
the affected owner's approval. Quan/Bao review remains unsupplied, not fabricated.

Boundary: GameManager checkpoint identity/rank/request, payload retention, exact legacy
B1/B2 classification, pre-mutation B3 refusal and combined-stage startup/recovery;
project main scene/missing interact-F binding; local checkpoint visual/interaction
variant and supported B1/B2 placement; independent synthetic tests and isolated runs.
SaveSystem serializer, Stage, shared InteractiveArea3D, Player, enemies, wave interfaces,
geometry/parkour/gates and old-B3 recovery policy remain outside changes. No real saves.
T012 authorization recorded; implementation/results follow below. No commit or push.

## Checkpoint phase results — 2026-11-05 (current)

**Base:** pushed foundation `7c392eb213ecc6ef63db9ed844eecd54ae24be73`;
branch unchanged. T012 Lam authorization above replaces the earlier missing-reviewer
hold for this slice. It does not supply Quan/Bao agreement or completed teammate
code review. No stage/player/enemy/serializer ownership changes were needed.

### Implementation and scope

- T014: trusted b1_start -> b1/1, b2_start -> b2/2 table; canonical continuous path/UID;
  active Stage/declaration/owner/unique-ID checks; accepted/unchanged/rejected outcomes.
  Lower/foreign/undeclared/duplicate/wrong-owner requests do not save. Same-current
  is idempotent. Stock setter routes continuous-stage requests through that boundary,
  while supported unrelated-stage stock behavior remains.
- T015: inherited visual-only basement variant replaces the stock contact script.
  InteractiveArea3D still supplies the F prompt/input dispatch. Local checks require
  the active Stage's living Player, actual physics overlap, no active dialogue or
  load; key echo ignored. Arrival does not activate. Accepted requests alone display
  local tint and exact "Checkpoint activated." for two seconds; current tint restores
  from identity. No Player/helper/HUD changes or second HUD.
- T016: active Stage owns B1/Checkpoint_b1 and B2/Checkpoint_b2, each in spawn_points,
  each with inherited Spawn child. Default Player/Spawn and B1 checkpoint endpoint:
  (-3,1.2,14). B2 endpoint: (49,7.2,5). Positions are verified against actual combined
  scene support rays and body settling, not merely copied from split scenes.
- T017/T021: project main path and FIRST_STAGE both continuous; one interact physical-F
  binding added. Existing plugin removal and all other inputs preserved.
- T018: retain deep-copied loaded envelope and merge only manager fields/flags.
  Serializer/version unchanged; nested sentinels/unrelated fields/flags survive.
- T019: exact four research R4 standalone path/UID + corresponding known-ID pairs
  reset only checkpoint pair to continuous default; this is persisted through the
  retained payload. Valid new path/UID B1/B2 IDs remain valid. Wrong-ID/lookalike/
  missing/unknown/B3 references are not classified as eligible legacy data.
- T020: known B3 path/UID refused at change_stage before loading/dialogue/health/pending
  mutation. Unsupported saved references remain intact; saves/respawns are held for
  case review rather than blanket reset or default fallback. A B3 startup conflict
  can still instantiate the configured main scene, but is not registered as successful
  continuation and does not place/reset/overwrite the saved checkpoint. That is not
  an approved recovery result or chosen user-facing policy.
- No wave interface, producer, clear/unlock behavior, later map task, generator,
  branch/staging/commit/push or real-save access. Existing flag values used by
  fixtures are synthetic preservation sentinels, not implemented wave APIs.

### Isolated environment and commands

- Engine rechecked: `4.7.2.stable.official.ed1daf0bf`.
- Disposable root: `C:/Users/CHUNGK~1/AppData/Local/Temp/ArcanaCheckpoint-da11bc20c86749c9a4c091c4df511339`.
- Copied project: `C:/Users/CHUNGK~1/AppData/Local/Temp/ArcanaCheckpoint-da11bc20c86749c9a4c091c4df511339/project`.
- Probe: `C:/Users/CHUNGK~1/AppData/Local/Temp/ArcanaCheckpoint-da11bc20c86749c9a4c091c4df511339/isolation-probe` (no autoloads).
- Child-process APPDATA: `C:/Users/CHUNGK~1/AppData/Local/Temp/ArcanaCheckpoint-da11bc20c86749c9a4c091c4df511339/userdata-base`.
- Verified user://: `C:/Users/CHUNGK~1/AppData/Local/Temp/ArcanaCheckpoint-da11bc20c86749c9a4c091c4df511339/userdata-base/ArcanaCheckpoint-da11bc20c86749c9a4c091c4df511339`.
- Copy excluded .git, included existing imports/uncommitted work; only copied
  project.godot has the unique ArcanaCheckpoint custom-user-dir keys. No caches
  copied back. The probe initially lacked config/name and resolved to an isolated
  unnamed-project subdirectory; launch was stopped before game autoloads. Adding
  the same config/name as the real copied project corrected the probe. Verified
  expected path and save_exists=false before the first copied-game launch.
- Harness startup guard checks exact ARCANA_EXPECTED_USERDATA, custom directory
  prefix and --isolated-copy; fixture writes go to unique user://fixtures files.
  Synthetic save.json files for actual main-scene startup were written only under
  the already verified disposable directory. Later probe save_exists=true refers
  to these synthetic files, never production progress.
- All runs use process-local environment overrides, hidden child windows, separate
  stdout/stderr/log files. Main-scene diagnostics use a copied-project-only observer
  autoload in tests/main_scene_probe.gd; it is not a production change.
- Example test arguments in that verified environment:

```powershell
& 'C:/Users/Chung Kiết Lâm/Desktop/Godot_v4.7.2.exe' --headless --path $copy --script res://tests/basement_checkpoint_check.gd --fixed-fps 60 --log-file $log -- --isolated-copy --lane=fixtures
```

Use --lane=interaction or --lane=recovery separately. For rendered captures omit
--headless and append --capture. Do not use these commands against the original
project. Production startup checks used --path $copy --fixed-fps 60 --quit-after 8
without --script, exercising the actual configured main scene and pre-autoload
synthetic fixture load. This is the F5-equivalent startup path, not an editor-key test.

### Verification ledger

| Lane/check | Status | Actual evidence |
| --- | --- | --- |
| T013 pre-implementation red | PASSED as expected red | Once harness compilation was corrected, missing request API gave 0 passes/1 failure, exit 1; red.log |
| Final manager/rank/payload/legacy/refusal fixtures | PASSED | 55 passed/0 failed, exit 0; fixtures-final.stdout/stderr.txt and .log |
| Headless interaction/physics/input | PASSED | 24 passed/0 failed, exit 0; interaction.stdout/stderr.txt and .log |
| Rendered interaction + captures | PASSED for exercised checkpoint behavior | 26 passed/0 failed, exit 0; rendered-interaction.stdout/stderr.txt and .log |
| Final supported recovery | PASSED for exercised physics/location/death behavior | 55 passed/0 failed, exit 0; recovery-final.stdout/stderr.txt and .log; six no-checkpoint/B1/B2/UID/legacy cases |
| Rendered recovery capture | PASSED for location/capture; HUD issue below | 56 passed/0 failed with screenshot assertion; rendered-recovery.stdout/stderr.txt and .log; this earlier diagnostic used direct death-signal emission, superseded for death behavior by recovery-final |
| Normal main-scene process startup | PASSED, limited observation | Five independent no-save/B1/B2/legacy-B1/legacy-B2 launches: exit 0, expected Stage/ID/player/camera and one Hud; main-*.stdout/stderr.txt and .log |
| Known B3 path/UID direct/startup/death refusal | PASSED | Zero B3 loads; pending/health/file/pair preserved; no successful continuation event for B3 fixture |
| Old-B3 recovery | BLOCKED | No policy selected; no recovery acceptance, redirect, migration or reset |
| Real waves/round reset/clear/unlock | NOT RUN | Outside authorized slice; no Duy interface/provider implementation |
| Pushed foundation preservation | PASSED, static | Reversing only checkpoint ext-resource/instances and Player/Spawn transforms reproduces HEAD scene; all other retained content/Hidden unchanged |
| Protected systems | PASSED, static | Stage, SaveSystem, InteractiveArea3D, Player, stock checkpoint, enemy zone and separate B3 match HEAD |
| Working-tree whitespace / branch / index | PASSED | git diff --check clean; branch/HEAD unchanged; nothing staged |
| T025/T026 whole visual/manual acceptance | PARTIAL | BUG-003 and remaining manual checks below; fixture passes do not hide this issue |

Screenshots inspected by the assistant:
`user://fixtures/b1-accepted.png`, `b2-accepted.png`, `b2-recovery.png`.
B1/B2 exact feedback and tinted helm render. B2 restored player/helm/support render.
B1 health bar renders; B2 health bar is absent despite one visible Hud node.
This is an image observation with unproven cause, not Quan/Lam manual acceptance.
BUG-003 is flagged HIGH in docs/implementation-bugs.md and blocks full visual/HUD
acceptance; no speculative shared HUD/renderer fix was made.

Harness corrections before final passes: SceneTree --script must resolve autoload
nodes after startup rather than compile Stage/autoload types prematurely; explicit
Dictionary typing for dynamic ray result; JSON numeric sentinel comparison uses
serializer round-trip types; capture placement at registration before gravity;
wait through node processing before prompt assertions. These initial harness
errors/failures were not declared gameplay fixes. No application failure is hidden.

### Diagnostics and remaining checks

- Headless certificate-store error reproduced in no-autoload probe; environmental
  diagnostic, not a new gameplay attribution. Rendered runs did not emit it.
- Shutdown leaks/resources remain (3 ObjectDB instances/1 resource in interaction,
  4/1 in fixtures, 14/1 after repeated recovery scenes). Earlier fsm.gd lifetime
  hypothesis remains unproven; no Player/FSM changes.
- One rendered recovery run reports GLES3 shader initialization `err != OK` at
  shader_gles3.cpp:802 while producing the screenshot and passing assertions.
  Cause/relationship to BUG-003 is unproven. Exit 0 is not an error-free run.
- Human-controlled approach/leave, real active dialogue, overlap with other actual
  interactables, repeated-F play, B1/B2 camera framing/visibility, and HUD at normal
  B2 startup/death/restart still need manual verification. Fixture teleports and
  synthetic dialogue-state assignment are not physical traversal or complete
  dialogue acceptance. Normal combat-driven enemy damage is not proven by injected
  damage through the real Player/FSM path.
- T010/T011 remain partial. T012 complete as authorization/boundary record.
  T014-T021 implementation complete with the above independent evidence.
  T013 partial for full planned coverage (real-wave tests deferred).
  T025/T026 remain unchecked/partial. T022-T024/T027+ not implemented; old-B3
  recovery and actual waves retain separate dispositions.
- New script UIDs were generated by ResourceUID.create_id in the isolated no-autoload
  probe and written only as the two new .gd.uid metadata files. No original cache edit.
- Existing cache/library/concept/progress files remain untouched. project.godot
  retains the pre-existing plugin edit plus only this phase's declared changes.
  No files deleted, no planning documents regenerated, no commit/push.

## Third implementation replanning — 2026-11-05 (current activity)

User requests planning only: reproduce vertical double-jump softlock inside B1,
inspect underside/headroom/collision, propose two passes and candidate openings;
stop for review before scene or script edits. No new gameplay implementation
authorized. Existing checkpoint-phase results/statuses remain historical and valid
within their exercised scope, not ceiling/route acceptance.

- Read AGENTS, current task/validation/changelog, relevant plan/research/constitution
  and Player/controller/collision sources. Fresh branch/HEAD remains
  basement-split-floors / 7c392eb213ecc6ef63db9ed844eecd54ae24be73.
- New pre-existing change at entry: basement_b1.tscn reorders door/checkpoint
  ext-resource declarations only. Preserve it along with all prior checkpoint
  work, mesh/cache/plugin and concept/progress files.
- Fresh isolated copy/probe: `C:/Users/CHUNGK~1/AppData/Local/Temp/ArcanaClearance-b288225c951141beb50e576774962fbd`;
  custom user-data identity ArcanaClearance-b288225c951141beb50e576774962fbd,
  process-local APPDATA override, exact-path/no-autoload/save_exists=false probe
  before copied-game startup. No real saves, generators or original engine launch.
- Temporary diagnostic scripts exist only inside the disposable copy/probe.
  They inspect collision and inject physical jump/movement input into the existing
  Player. Enemy timers are stopped only in the diagnostic instance to isolate combat.
  No geometry, Player/enemy controller or checkpoint behavior is changed even there.
- **Reproduced:** four B1-under-B2 starts trap at root Y≈6.144 after vertical double
  jump, no ground contact, downward velocity≈-62 and failed movement recovery.
  An independent rendered repeat at (25,1.2,5) confirms the trap and screenshots.
  B1 uncovered and B2 controls fall/land/move normally.
- **Measured:** B1 floor Y=1.01; B2 surface Y=7, thin concave front-face floor,
  backface_collision=false; upward rays have no underside hit. B1 wall top5,
  B2 wall top11, sampled B2 has no roof up to27.1. Upper prototype crate top5.5418
  makes a blind underside6.8 cap unsafe for the 1.6978-high body.
- **Proposal only:** scene-local solid underside/roofs/perimeter, explicit local
  prototype quarantine/hold before route; no spacing change. Pass 1 must demonstrate
  real ceiling contact -> fall -> supported landing -> normal walk/jump, without
  forced unsticking. Pass 2 waits for Lam/Quan route/opening decision and pass-1
  recovery acceptance. Candidate A X16..20/Z0..4 near old stack; B X24..28/Z12..16
  separate central opening. Neither selected or cut.
- **Bao dependency:** existing Fall/Wall_slide response/jump resets require owner
  consultation if correctly oriented solid ceiling still cannot recover; no
  controller edits. B3/waves/Hidden entrance remain outside this plan.
- T034 is partial measurement/reproduction, unchecked; T035-T040 unbuilt/unrun.
  BUG-004 HIGH is recorded open, not fixed. BUG-003 remains separate.
- Detailed data/steps/limitations: clearance-measurements.md; reviewed proposal
  awaiting approval: third-implementation-plan.md; native SVG candidate map:
  clearance-candidates.svg. SVG XML parses; geometry preview rendered in isolated
  probe (Godot SVG rasterizer omits SVG text; native SVG retains text for viewers).
- Existing headless certificate error and 3 ObjectDB/1 resource shutdown leak remain
  diagnostics. Early helper drafts corrected a missing-item null and wrong helper
  method, not production code. Missing B1/World mesh item34 is separately recorded.
  No candidate fix or post-fix acceptance run was performed.

Only planning/evidence documents and candidate SVG changed in this activity.
No deliberate original scene/script/game-resource/settings/cache edit; no file deletion,
staging/commit/push, branch change or invented Lam/Quan route approval.

### Final preservation / generated-metadata observation

207 original scene/script/test/mesh files match the fresh entry copy byte-for-byte,
including current checkpoint files and the pre-existing basement_b1 resource-order
edit. Removing only the copied custom-user-dir keys reproduces original settings.
Branch/HEAD/index unchanged; whitespace check clean; isolated save.json still absent.

Unexpected generated metadata is retained for review, not cleaned or staged:
`clearance-candidates.svg.import` appeared in the original feature directory with
Godot texture-import metadata for the new planning SVG. The original tracked
uid_cache.bin currently hashes to
`37903A7E867DAE2B4F9AEA642693570FFFD4A35BAB4783B498A90F7A9C33061F`,
different from the prior checkpoint-session hash and final disposable cache.
A Godot process remains present; attribution/timing of the original cache change
is unproven, and an active importer is a hypothesis. The assistant launched engines
only against verified disposable paths and did not explicitly write/restore/clean
the original cache or launch/stop an original editor. Do not claim cache hash equality
or silently discard this sidecar/cache work. They are not authored gameplay changes.

## Commit handoff — checkpoint implementation and ceiling replan

Lam now reports successful manual checkpoint activation. This is user-reported
manual observation; no specific floor/steps/build/isolation or recovery/HUD results
were supplied. It does not close T025/T026, BUG-003 or other untested checks, and
does not establish Quan/Bao sign-off. BUG-004 stays reproduced/open; ceiling and
parkour work remain proposals only, awaiting separate instruction and route review.

User authorizes one commit/push from foundation 7c392eb213ecc6ef63db9ed844eecd54ae24be73
with message "Implement basement checkpoints and document ceiling replan" to the
existing origin/basement-split-floors branch. Local HEAD/remote matched at preflight;
no force/amend/rebase/merge/branch change. This supersedes earlier no-commit handoffs
only for packaging the completed work and planning documents.

Exact 16-file manifest and exclusions: docs/implementation-changelog.md, final
commit-handoff section. Index uses only startup/F-binding project.godot hunks,
excluding its pre-existing plugin edit. A newly observed unrelated scene hunk moves
B2-Parkour from B1/World to B1/Pathfinder; that reparent/reordering hunk is excluded,
leaving the committed prototype path as in foundation/planning evidence. Checkpoint
node IDs/default-property serialization are retained as current editor-save form.
No original working file is reverted for partial staging. Asset/cache/basement_b1,
SVG sidecar and earlier concept/progress documents stay local. No new gameplay work.

Exact staged packaging verification passed 294 focused static assertions: 16-path
manifest, retained foundation node blocks, resource/NodePath declarations, supported
checkpoint/default transforms, one F binding and aligned startup, unchanged staged
plugin section and prototype path, UID metadata, obvious-secret patterns, and honest
open T025/T026/T035/T036/BUG-003/BUG-004 state. SVG XML parses; staged whitespace
check returns exit 0. No Godot launch, real-save access or gameplay rerun in packaging.
Prior runtime results remain historical; Lam's manual activation does not expand them.
### T043 — F6 startup continuation regression

- **Reproduced statically and with local save metadata:** `project.godot` selects
  `levels/level_1/basement_full.tscn`, and `GameManager.FIRST_STAGE` is the same scene.
  The existing local `user://save.json` contains `stage=res://levels/level_1/stage_1.tscn`
  and `checkpoint=village`.
- `register_stage()` uses only `stage.scene_file_path == FIRST_STAGE` to decide whether
  to continue a saved checkpoint. Thus F6 on `basement_full.tscn` enters the same branch
  as F5 and calls `change_stage()` to `stage_1.tscn`. Existing comment claiming an F6
  standalone scene is left alone is not satisfied by that branch.
- **Acceptance defined before implementation:** an explicit Godot `--scene` launch skips
  checkpoint continuation and checkpoint spawn placement, without changing/deleting the
  save. F5 still restores the saved stage/checkpoint. Legacy compatibility and unrelated
  save data remain unchanged. See T043 in `tasks.md`.
- **Implementation status:** implemented in `scripts/autoload/game_manager.gd`; saved-game
  conflict handling and checkpoint continuation/spawn placement now run only when the
  process did not receive Godot's explicit `--scene` argument. The save file is not cleared
  or rewritten by the F6 bypass.
- **Verification:** static source review only. No Godot launch or automated test was run for
  this follow-up. Required isolated F6/F5 runs with a synthetic save and scene identity
  assertions remain required before claiming runtime behavior fixed.
- **Review boundary:** GameManager startup/recovery only, within the recorded Lam shared
  review scope for T012-T021. No Quan/Bao reviewer agreement is implied by the prior record.

### T044 — Active-floor camera visibility

- **Baseline:** `basement_floor_visibility.gd` already chose a level from player height and
  hid only floors with a greater `floor_level`, leaving lower floors rendered. It also
  conditionally rendered B1_5 inside its secret-area bounds. `basement_full.tscn` contains
  the B1 room roof as `B1/World/Ceiling`; floor-level nodes are B1, B1_5, B2, B3, and
  GroundExit. These are static source observations.
- **Acceptance defined before implementation:** only the active `floor_level` is rendered;
  B1_5 keeps its secret-area condition; the room roof stops obscuring the view; collision,
  navigation, and movement geometry remain unchanged. See T044 in `tasks.md`.
- **Implementation:** the visibility comparison now selects only the active floor. The
  existing B1 ceiling GridMap is hidden for rendering by the same Stage script. No scene,
  mesh library, collision, or player files were changed.
- **Verification:** static review only. No Godot playtest was performed. Floor transitions,
  camera sightlines on every floor, and unchanged collision/navigation still need runtime
  verification. Static source review cannot establish that the camera obstruction is fixed.
- **Review boundary:** one scene-local visibility script and its task/evidence records;
  Quan review/sign-off has not been supplied. T034-T038 ceiling/route measurements,
  construction and playtests remain open and are not claimed complete by this render-only
  visibility change.

#### T044 implementation update — connector-local floor changes

- **User clarification:** the next floor should appear around halfway through the stair
  climb, while an ordinary jump elsewhere on a floor should not change visibility.
- **Implementation:** the global height thresholds were replaced with per-connector rules
  anchored to the existing `LadderSpot_B1_B2`, `LadderSpot_B2_B3`, and
  `LadderSpot_B3_Ground` markers. Within a 3.5 m horizontal radius, an upward/downward
  crossing of that connector's midpoint changes the active floor, when the player is on a
  floor or wall. Outside the connector areas, the active floor follows the grounded support
  collider and remains stable while airborne. Hysteresis is 0.25 m.
- **Verification:** static source review only. No Godot run was performed; marker alignment,
  radius fit, ascent/descent behavior, and jumps outside connectors require the T044 playtest.
  T044 remains open.
## T045 — HUD and Skill Tree spellbook presentation (2026-11-07)

- Task source: user-requested Bao-owned HUD/Skill Tree presentation slice, added as T045 in `tasks.md`.
- Acceptance criteria recorded before implementation: retain skill-point count without HUD/menu shortcut prose; add T/clickable toolbar book control; animate the Skill Tree as a horizontal open/close spellbook; preserve pause/input/allocation behavior; leave BUG-003 independent.
- Implementation status: implemented in `ui/health_bar.gd`, `ui/skill_tree_layout.gd`, and new vector icon `assets/ui/skill_tree_book.svg`. The HUD SP display no longer includes shortcut prose; the menu's shortcut footer is removed; the six-slot bar keeps the four active skills and ultimate at their prior positions and appends a clickable book icon marked T. T and the existing close controls call the same menu transition. The menu now has a dark leather-like frame, two-page center seam, and horizontal open/close tween; pause begins on opening and ends after closing.
- Asset finding: no spellbook asset was found in the existing project files. Existing pixel spell/skill icons are available; the toolbar book is a small project-authored SVG.
- Verification: changed-file/asset-reference review and whitespace check only; `git diff --check` passes after removing a trailing blank line. No Godot run or playtest was performed. T045 remains open pending runtime interaction/visual verification. BUG-003 remains open; this change is not evidence about its B2 health-bar symptom.
- Review boundary: Bao-owned HUD/Skill Tree presentation. No combat, progression, skill, input-map, health/rage behavior, or BUG-003 diagnosis changes.

#### T045 update — user-added Elysian CrystalWitch UI

- The user added Elysian's free UI pack under `assets/ui/User Interface Packs - Free/`.
  Its free edition contains CrystalWitch UI elements and theme art, but not the book-menu
  layout listed for the full edition. The existing project-authored book glyph remains in use.
- `ui/skill_tree_layout.gd` now references the CrystalWitch atlas for its crystal-orb
  header accent and uses the pack's purple/lavender palette for the open-book pages/frame.
  The user's downloaded atlas and its import metadata are not modified.
- The bundled READ ME allows free and commercial use and requests creator mention for
  commercial projects. Include Elysian Game Studio in game credits if the project is
  distributed commercially.
- Verification: static path/region/source review and `git diff --check`; no Godot run or
  visual inspection was performed. T045 runtime appearance and atlas crop remain open.

#### T045 visual revision — frame both pages with CrystalWitch sprites

- The user reported that the earlier small orb/palette use was visually too subtle.
- The two book pages now use paired nine-patch frames cropped from the CrystalWitch
  atlas, with the supplied violet button styling and darker purple page fills. The atlas
  remains unmodified; no book-menu layout is included in this free edition.
- Verification: static review of source regions (sheet is 351×304; both frame regions are
  within bounds) and `git diff --check`. No Godot run or rendered inspection was performed;
  final appearance and crop quality remain unverified under T045.

#### T045 correction — remove unsupported NinePatchRect property

- User reported runtime error for assigning `flip_h` on `NinePatchRect`.
- Removed that unsupported assignment. Each page keeps its own atlas region and placement;
  no horizontal flip is attempted.
- Verification: static source review and `git diff --check`; Godot was not rerun. T045
  runtime verification remains open.

#### T045 correction — CanvasLayer input handling

- User reported a Godot parse error because `_on_skill_tree_slot_input()` called `accept_event()` from `HealthHUD`, which extends `CanvasLayer` rather than `Control`.
- Replaced that call with `get_viewport().set_input_as_handled()`, which consumes the click after opening the Skill Tree.
- Verification: static source review and `git diff --check` only. Godot parse/runtime was not rerun; T045 remains open pending runtime verification.

#### T045 update — replace UI art and fit the complete tree on one spread

- The user replaced the earlier asset at the same UI location with the CraftPix animated
  magic-book pack under `assets/ui/craftpix-net-809047-free-animated-magic-book-pixel-art-asset-pack/`.
- `ui/skill_tree_layout.gd` now uses the pack's open-book crop for the resting spread,
  its Open/Close sheets for opening and closing, and the left/right page-turn sheets when
  switching Weapon and Character. The old scrolling region was removed; the graph takes
  the remaining spread height, and `ui/skill_tree_graph.gd` scales node size and placement
  from the available height so the full tree can fit without a second page.
- `ui/health_bar.gd` uses the first book frame from `Open_book.png` for the T toolbar icon.
  The user's imported assets are referenced only and remain unmodified.
- Static source review confirms no `ScrollContainer` remains in the Skill Tree builder,
  both tree graphs no longer request oversized fixed heights, and all three animation
  sheets are referenced. Node sizing accounts for vertical and horizontal gaps. `git diff --check` passes. No Godot parse, rendered-layout, input, or animation run was
  performed, so visual fit across resolutions and runtime animation remain unverified.
  T045 remains open for that runtime evidence; BUG-003 remains independently open.

#### T045 correction — confine content to one page and correct the book controls

- Skill Tree content is now placed entirely within the right-hand page safe area. The
  weapon graph is arranged in two columns on the narrower page; node scaling checks
  pairwise two-dimensional spacing and page edges.
- The toolbar book atlas region is cropped to the open-book frame and its TextureRect
  is expanded slightly beyond the icon bounds so the visible book better matches skill
  icon size. Weapon/Character tab transitions now use the opposite left/right sheets,
  reversing the previous direction.
- `git diff --check` passes. Godot rendering/input/animation was not run. The page-face
  fit, icon appearance, and corrected flip direction remain runtime-unverified; T045 stays
  open.

#### T045 correction — align the content to the left page face

- The user reported that the previous single-face content appeared shifted onto the wrong
  page. Moved the content container from the right page to the mirrored safe area on the
  left page; its width and vertical margins remain confined to that page face.
- Static layout coordinates place the container at 7%-47% of the book artwork width,
  leaving space before the center seam. No Godot rendering check was run, so visual
  alignment remains unverified and T045 stays open.

#### T045 visual correction — balance both tabs across the open spread

- The user supplied screenshots of both Weapon and Character tabs and reported that each
  looked shifted. The menu content box is now centered within the open-book artwork and
  uses equal left/right margins; the weapon tree again distributes its nodes across the
  wider spread. Header stats align at the right edge, and footer buttons are centered.
- Long section labels now wrap within the book content area instead of drawing past the
  page edge. The menu remains a single viewport view without scrolling.
- `git diff --check` passes. No Godot display check was run, so the screenshot-level
  alignment and wrapping still need runtime visual confirmation. T045 stays open.

#### T045 visual refinement — larger element choices and hover details

- The four pre-selection element nodes now use larger circles and larger elemental sprites.
  Selecting one still spends the existing skill point and shows its corresponding weapon tree.
- The tree body now has a left-side detail card and a wider graph area on the right. Hovering a
  skill, evolution, character, or element node updates the detail title and description.
  Base node icons and text were enlarged, with per-node graph sizing to keep the larger element
  choices distinct from regular skills.
- The source references the existing pixel element and spell icon assets; no new download is
  needed for this refinement.
- Static source review and `git diff --check` only. Godot rendering, hover input, selection,
  and readability at supported resolutions were not run. T045 remains open pending visual
  confirmation.

#### T045 refinement — fixed detail box, compact copy, and zoom controls

- The left details card has a fixed 176 px width and anchored content container; wrapped label
  text cannot change the box geometry. Detail copy uses a smaller font and clips inside the
  card if it exceeds its available height.
- Removed redundant Weapon-tree instruction/threshold headings and Character-tree prose from
  the graph area. Kept concise unlock/point guidance in the left card.
- Added fixed-size `−`, `+`, percentage, and reset controls; wheel zoom ranges from 65% to
  200%, and holding the middle mouse button pans the clipped graph. Normal and element nodes
  use fixed layout dimensions independent of their text; graph scaling uses those dimensions.
- Static source review and `git diff --check` only. No Godot UI, zoom, pan, hover, or layout
  test was run. T045 remains open pending visual/runtime confirmation.

#### T045 screenshot correction — contain header controls and center/reduce skill bar

- Screenshot review showed the zoom buttons overflowing the book's right edge, the left detail
  card crossing the center seam, and the HUD skill bar centered left of the viewport.
- Narrowed the content safe area symmetrically to 84% of the book artwork, moved zoom controls
  into a right-aligned row above the graph, and reduced the fixed detail-card width to 144 px.
  The page content clips at its safe-area bounds.
- Reduced skill slots from 38×36 to 35×33 px, tightened gaps/padding, and centered the bar
  around the viewport anchor.
- Static source review and `git diff --check` only. No Godot screenshot/run was made, so final
  menu alignment and skill-bar size/position remain runtime-unverified; T045 remains open.

#### T045 follow-up — keep the details card on the left page

- Review of the supplied screenshot showed the 144 px detail card still crossed the book seam.
  Reduced its fixed width to 120 px so it stays within the left leaf with a small inner margin;
  the adjacent graph retains the right leaf.
- Static source review and `git diff --check` only. The final Godot render and viewport alignment
  remain unverified; T045 remains open.

#### T045 screenshot correction — center the skill bar after HUD canvas scaling

- The HUD `CanvasLayer` in `ui/hud.tscn` has an X scale of 1.5. A 0.5 local anchor therefore
  rendered at 0.75 of the viewport width, matching the right-shifted skill bar in the screenshot.
  The bar now inverse-maps the viewport center through the canvas transform and uses exact half-
  width offsets, so the reduced bar's frame and slots share the actual viewport center.
- Renamed the expanded HUD controller and UID sidecar from `health_bar.gd` to `player_hud.gd`,
  updated its global class name, and updated the scene's script path while retaining the UID.
- Static source/reference review and `git diff --check` only. No Godot render or input playtest was
  run; the visual result remains unverified and T045 remains open.

#### T045 parser correction — query viewport size from CanvasLayer

- The user reported a parser error because `get_viewport_rect()` is unavailable on `CanvasLayer`.
  Replaced it with `get_viewport().get_visible_rect().size.x` before inverse-mapping the viewport
  center.
- Static source review and `git diff --check` only. Godot parsing and visual alignment remain
  unverified; T045 remains open.

#### T045 screenshot refinement — nudge the selected weapon tree right

- Added a 4% graph-width horizontal content offset for the selected weapon tree only; node and
  link geometry move together, while the initial element selection and Character tree retain
  their existing positions.
- Static source review and `git diff --check` only. Godot rendering/zoom behavior was not run;
  visual placement remains unverified and T045 remains open.

#### T046 request — Dark Fairy boss HUD top-center placement

- Static inspection found the boss bar and phase label already use horizontal center anchors, but
  both use bottom-edge vertical anchors. The requested top-center adjustment would change only
  `BossHUD/Bar` and `BossHUD/Name` offsets in the Duy-owned `darkfairy.tscn` scene.
- The user-provided runtime screenshot shows `DARK FAIRY / PHASE 1` rendered over the bottom skill
  bar, consistent with the scene's bottom anchors. The boss-specific progress bar is obscured by
  the same lower HUD area in this crop.
- No Dark Fairy scene change has been made. Duy owner approval is pending under the project
  constitution. This is screenshot evidence from the user's game, not a local Godot playtest; the
  proposed top-center placement remains unimplemented and unverified.

## Focused player stair traversal follow-up (T047)

- Implemented a player-only bounded step-up in `scenes/player/player.gd`. It only runs when
  grounded horizontal movement is blocked, and accepts a clear raised path with a walkable
  landing no more than 0.75 world units above the starting floor. It leaves `BaseCharacter`,
  enemies, map/GridMap colliders, stair meshes, navigation, and T044 visibility logic unchanged.
- Godot 4.7.2 F6 launch of `levels/level_1/basement_full.tscn` succeeded and showed the player
  and HUD, which confirms the modified player script parses and the scene starts. The interactive
  traversal attempt was stopped by physical Escape before ascent/descent could be confirmed.
- **Not verified:** climbing/descending the B1/B2 stair, wall blocking, unsupported-edge behavior,
  ordinary movement, or jump/landing regression. No collision-debug traversal or reviewer
  agreement is claimed. T047 remains open until those runtime checks pass.
- `git diff --check` passes; Git reported only CRLF/LF normalization warnings for the
  documentation files.