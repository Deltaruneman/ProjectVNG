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

## Focused player sword and status FX follow-up (T048)

### Acceptance and review boundary recorded before implementation

- Owner: Bao, who requested this player combat/skill visual slice.
- In scope: default visibility for the existing back-mounted `Direction/Blade`; hiding/restoring it for attack and skill lifecycles; status visuals at the existing player-owned burn/slow/freeze application sites; reading the user-added PVFX grid sheets through their manifests; reusing the project Pixelfx library for the slow indicator.
- Out of scope: enemy status/damage/movement logic in Duy-owned `scripts/enemy.gd`; changing skill durations/damage; replacing `effects/slash.tscn`, `effects/slash.gd`, slash sheets, `BattleVFX.shield`, or `BattleVFX.emberline_ring`; unrelated combat or map work.
- Acceptance: sword is visible by default at its current back mount, hidden during attacks/skills and restored when each action ends; burn/slow loops are attached to the affected enemy and end after the existing status duration; freeze plays a one-shot; reapplication refreshes rather than stacking duplicates; gameplay status mechanics remain unchanged.
- Checks: source/path/manifest review and `git diff --check`. Runtime Godot visual, input and skill checks are not requested in this turn and will remain NOT RUN.
- Unresolved questions/cross-owner approvals: none for the bounded player-owned call sites. No Duy-owned enemy implementation file or shared system is in scope.

### Implementation and static evidence (2026-11-09)

- `scenes/player/player.tscn` enables the existing `Direction/Blade`; the pre-existing transform places it behind the character. `scenes/player/states/skillstate.gd` now owns suppression for active casts and restores it in `_exit()`. Thrown skills rely on the existing projectile-owned suppression; the skill state no longer duplicates that suppression or clears it at the end of the throw animation.
- `scenes/player/player.gd` calls the VFX helper after the existing burn, slow and freeze application calls. The enemy damage, movement and status-duration methods remain unchanged.
- `scenes/player/battle_vfx.gd` reads the PVFX grid manifests, creates billboard `AnimatedSprite3D` loops attached to the target, refreshes loop timers by name, and plays the one-shot PVFX freeze encase. The slowed target also gets the exported Pixelfx clock indicator.
- Referenced user-added files, all preserved unchanged: `effects/status/burning-aura/lit/grid/sprite-sheet.png` and `manifest.json`; `effects/status/frozen-chill/lit/grid/sprite-sheet.png` and `manifest.json`; `effects/ice/freeze-encase/lit/grid/sprite-sheet.png` and `manifest.json` under `assets/effects/pvfx-foundry-thirteen-spritesheets/`.
- Kept Pixelfx exports: `assets/effects/pixelfx/status/slowed/slowed.png` and `slowed.json`. Candidate preview images and unused status exports generated during selection were removed.
- Static review confirms the paths and manifest schema match the loader. `git diff --check` passes; Git reports only the existing documentation line-ending normalization warning. No test was added or run.
- **NOT RUN:** Godot import/parse, in-game sword visibility and hide/restore, VFX scale/placement, status refresh/expiry, or enemy combat playtest. T048 remains open pending visual and lifecycle runtime evidence. No teammate/reviewer sign-off is claimed.

## Focused floating player sword follow-up (T049)

### Acceptance and review boundary recorded before implementation

- Owner: Bao, based on the user's clarification that the existing sword should look suspended and move gently rather than remain rigid.
- In scope: add subtle bobbing and angular sway to the existing player-only sword scene, relative to its current mount/rest transform.
- Out of scope: changing the sword asset, its mounting position, player facing, attack/skill visibility suppression, character animation, or shared `BaseCharacter` behavior.
- Acceptance: the visible sword floats and rocks smoothly around its current back-mounted pose; existing hide/restore behavior is unchanged.
- Checks: inspect the script's captured rest transform and animation offsets; `git diff --check`. Godot import/parse/runtime visual tuning will remain NOT RUN unless requested.
- Cross-owner approvals: none; the sword scene is player-owned and is only instanced by the player.

### Implementation and static evidence (2026-11-09)

- `scenes/player/weapon/blade.tscn` now attaches a player-weapon-specific floating script to the existing sword root.
- `scenes/player/weapon/floating_blade.gd` captures the root's instance/rest position and rotation in `_ready()`, then adds a low-amplitude vertical sine bob and two gentle angular sway components in `_process()`. This preserves the mount transform and doesn't edit the visibility state.
- The blade scene is only referenced from `scenes/player/player.tscn`; no enemy or other shared weapon instance is affected.
- Tracked cache `.godot/uid_cache.bin` changed during this workspace update (429,747 to 490,208 bytes). It was not manually edited or reverted, preserving the existing project cache; no Godot process was running during final inspection, so the cache writer/source is unknown.
- `git diff --check` is the static whitespace check. **NOT RUN:** Godot parse/import, playtest, visual tuning, or attack/skill hide/restore regression. T049 remains open until the sword motion is inspected in game; no reviewer agreement is claimed.

## Focused player dash trail follow-up (T050)

### Acceptance and review boundary recorded before implementation

- Owner: Bao, for the player dash presentation requested by the user.
- In scope: leave short-lived afterimages made from the player's actual current `Sprite3D` pose during the existing dash state, and reuse the user-added PVFX `smoke/dash-dust` effect to reinforce the ground trail.
- Out of scope: dash movement, duration, cooldown, invincibility, collision, enemy behavior, shared character movement, slash effects, and other player VFX.
- Acceptance: a short tinted trail follows dash motion in the selected direction, then fades cleanly when the dash ends; the actual player sprite and existing animation remain the source of the afterimages.
- Candidate review: PVFX `arcane/blink-dash` and `smoke/dash-dust` sheets/manifests were inspected. Pixelfx `status/haste` was rendered and inspected; its exported afterimages depict a generic humanoid that does not match the game's fox player, so the plan uses snapshots of the real player sprite with the existing PVFX dust instead.
- Checks: inspect the dash-state lifecycle, sprite snapshot properties, referenced PVFX frames/durations, and `git diff --check`. Godot runtime visual, direction and lifecycle review is NOT RUN unless requested.
- Existing working-tree changes to preserve: tracked `.godot/uid_cache.bin` and `levels/level_1/stage_1.tscn`; user-added `assets/effects/pvfx-foundry-thirteen-spritesheets/`, the existing Pixelfx slow exports, and `scenes/player/weapon/floating_blade.gd.uid`. T050 will not modify or clean them.

### Implementation and static evidence (2026-11-09)

- `scenes/player/states/dash.gd` starts one trail burst, emits player-pose snapshots at roughly 45 ms intervals while dash state is active, and emits a final snapshot when the state exits. Dash movement values and state transitions are unchanged.
- `scenes/player/battle_vfx.gd` duplicates the current `Sprite3D` frame into a world-fixed, cool-tinted afterimage and fades it over 0.22 seconds. It also plays the user-added `smoke/dash-dust` PVFX sheet once at dash start and rotates it to the projected dash direction when a camera is available.
- Static asset check: PVFX `smoke/dash-dust` sheet and manifest exist; manifest has 13 non-looping frames, 68×32 canvas, 780 ms total. The `arcane/blink-dash` candidate has 22 frames / 1320 ms and was not selected because the repeated body-vanish/reappear burst is less suitable than a short ground trail during this dash.
- Pixelfx `status/haste` was rendered and inspected; its embedded generic humanoid afterimages do not match the Foxy sprite, so they were not reused. The actual player sprite is the afterimage source.
- No enemy, shared character, slash, skill, or dash gameplay code was changed. **NOT RUN:** Godot parse/import, in-game direction/scale/opacity, movement trail, and afterimage cleanup checks. `git diff --check` remains the static whitespace check. T050 remains open pending runtime observation; no reviewer agreement is claimed.

## Dash trail visibility tuning (T051)

### Acceptance and review boundary recorded before implementation

- Owner: Bao, based on the user's feedback that the T050 trail was too faint.
- In scope: strengthen the existing afterimage trail by raising opacity, sampling poses more frequently, extending its short fade, and slightly enlarging/brightening the existing dash dust.
- Out of scope: trail route/placement, dash movement speed/duration/cooldown, invincibility, collisions, and other effects.
- Acceptance: the trail is clearly readable during dash while still fading shortly after and not hiding the player.
- Checks: inspect the adjusted values and `git diff --check`. Godot visual/occlusion review remains NOT RUN unless requested.
- Existing workspace changes from T050 and earlier remain preserved; this tuning only touches the player dash/VFX source and task records.

### Implementation and static evidence (2026-11-09)

- Reduced afterimage spacing from 45 ms to 32 ms; raised its starting alpha from 0.34 to 0.62 and fade time from 0.22 s to 0.28 s.
- Increased the existing dash-dust scale from 0.22 to 0.30 and alpha from 0.70 to 0.90.
- Dash motion and timing are unchanged. `git diff --check` is the static whitespace check. **NOT RUN:** Godot visual/occlusion tuning; the final strength and overlap with the Foxy sprite remain unverified. T051 remains open pending that observation; no reviewer agreement is claimed.

## Dash afterimage alpha blending fix (T052)

### Acceptance and review boundary recorded before implementation

- Owner: Bao, responding to the user's report that no afterimages were visible.
- Static finding/hypothesis: `scenes/base_character.tscn` sets the source `Sprite3D.alpha_cut = 1`. T050 duplicates this sprite, then sets `modulate.a` below 1. Godot documents mode 1 as `ALPHA_CUT_DISCARD`, which accepts only fully transparent or opaque pixels; this likely removes the partially transparent copies. Standard blending is mode 0 ([Godot `SpriteBase3D` docs](https://docs.godotengine.org/en/stable/classes/class_spritebase3d.html#enum-spritebase3d-alphacutmode)).
- In scope: disable alpha-cut only on temporary dash afterimage copies.
- Out of scope: the original Foxy sprite's alpha-cut mode, dash timing/movement, afterimage tint/density, dust, other VFX.
- Acceptance: temporary trail copies can render their configured partial opacity and fade; source player sprite rendering is unchanged.
- Checks: inspect the alpha mode assignment and `git diff --check`. Godot runtime confirmation is NOT RUN unless requested; this remains a likely static cause until observed in game.
- Existing unrelated workspace modifications remain preserved.

### Implementation and static evidence (2026-11-09)

- `scenes/player/battle_vfx.gd` now sets `SpriteBase3D.ALPHA_CUT_DISABLED` on each duplicated afterimage before applying its partial alpha. The source player's alpha-cut mode remains unchanged.
- This matches the documented mode values: 0 blends translucency; 1 discards partially transparent pixels. `git diff --check` is the static whitespace check.
- **NOT RUN:** Godot runtime confirmation that the copies now appear and fade as intended. T052 remains open until that visual check; no reviewer agreement is claimed.

## Dark Fairy health-bar style follow-up (T053)

### Acceptance and review boundary recorded before implementation

- Owner: Duy. The user reports Duy approved this style synchronization; this is recorded as a relayed approval, not direct reviewer sign-off.
- Static comparison: regular enemies use `TextureProgressBar` with `assets/ui/kenney_ui-pack/PNG/Red/Default/button_rectangle_flat.png` for both under/progress textures, dark `tint_under`, `texture_filter = 1`, and nine-patch stretch margins of 4 px. Dark Fairy currently uses a plain `ProgressBar`.
- In scope: apply those visual settings to the existing boss bar and update only its typed reference in `darkfairy.gd`.
- Out of scope: changing the existing boss bar's current size/placement, the phase label, health values/update logic, other boss visuals/behavior, the shared enemy health-bar scene, or any unrelated modifications already present in `darkfairy.tscn`.
- Acceptance: boss health bar has the same red textured fill, dark backing and nine-patch frame as regular enemies, while its existing boss health tracking remains intact.
- Checks: compare style properties/resource paths and `git diff --check`. Godot visual/runtime check remains NOT RUN unless requested.

### Implementation and static evidence (2026-11-09)

- `scenes/enemies/darkfairy/darkfairy.tscn` now uses `TextureProgressBar` and the same Kenney red texture, dark backing tint, texture filter, z-index, and 4 px nine-patch settings as `scenes/ui/enemy_health_bar.tscn`. The boss-specific width and current anchor/offset values are retained.
- `scenes/enemies/darkfairy/darkfairy.gd` now types `boss_bar` as `TextureProgressBar`; its existing visibility and health value updates are unchanged.
- User-reported Duy approval was received for this style synchronization. No direct teammate review or runtime acceptance is claimed.
- `git diff --check` is the static whitespace check. **NOT RUN:** Godot import/parse or visual comparison in game; T053 remains open until the top-center boss bar is observed with the same appearance as regular enemy bars.

## Player ultimate cinematic follow-up (T054)

### Acceptance and review boundary recorded before implementation

- Owner: Bao, for player combat and skill presentation requested by the user.
- In scope: pause the scene tree while a temporary always-processing controller zooms only by changing the current camera FOV, without rotating or translating it; show the Pixelfx black/white `impacts/impact-frame` with an elemental accent and the current ultimate title; restore camera transform/FOV and unpause before invoking the existing ultimate once.
- Out of scope: camera-rig edits, ultimate damage/timing/gameplay changes, input mappings, enemy behavior, slash/ice-shield implementations, and all pre-existing working-tree changes.
- Acceptance: the captured valid skill ID casts once after the cinematic; a missing camera falls back to immediate casting; early exit restores the camera and pause state.
- Checks: inspect cast gating/capture, always-process override, camera and pause cleanup, title/element mapping, Pixelfx pause-aware animation and `git diff --check`. Godot playtest of camera framing, all ultimate labels/elements, cast-once timing and cleanup remains NOT RUN unless requested; no runtime acceptance will be claimed from static review.

### Implementation and static evidence (2026-11-09)

- `scenes/player/player.gd` gates ultimate input on rage/cooldown/unlock state, captures the selected skill ID, prevents duplicate cut-ins, and starts the existing `cast_ultimate()` only after successful completion. A missing camera/current scene falls back to the existing cast without pausing; the captured ID prevents a paused selection change from redirecting the skill.
- `scenes/player/ultimate_cinematic.gd` pauses the tree, runs with `PROCESS_MODE_ALWAYS`, orbits a full turn while moving closer and narrowing FOV, then shows the exported black/white impact-frame with an elemental accent and the existing Vietnamese ultimate title. It zooms back, restores the exact saved camera transform/FOV and previous pause state, then emits one completion signal. Early abort/exit restores pause and camera state.
- `scenes/player/battle_vfx.gd` adds an opt-in paused Pixelfx `impacts/impact-frame` call using a dedicated always-processing CanvasLayer between the cut-in graphics and title. Normal impact calls and other VFX keep their existing overlay/lifecycle.
- Added `assets/effects/pixelfx/impacts/impact-frame/impact-frame.png` and `impact-frame.json` from the local Pixelfx renderer. The catalog lists this as a 0.3 s, 320×180, 10-frame black/white anime impact; its contact sheet was rendered and inspected. The Pixelfx source `LICENSE` and `NOTICE.md` remain in the existing library checkout.
- Static source review covered the eight skill names/four element colors, input gating/captured ID, camera orbit/zoom and exact restore, pause cleanup, and pause-aware impact lifecycle. `git diff --check` completed without whitespace errors; Git reported line-ending normalization warnings for the already modified Markdown files.
- **NOT RUN:** Godot parse/import, playtest, visual framing/readability, all eight title/element combinations, skill cast-once behavior, or forced interruption cleanup. Runtime behavior remains unverified and T054 stays open; no teammate review or agreement is claimed.

## Front-facing ultimate cut-in pose (T055)

### Acceptance and review boundary recorded before implementation

- Owner: Bao, for the player-facing presentation follow-up requested by the user.
- Static finding: BaseCharacter.DIRECTION_YAW maps down to yaw 0; the code comments define local +Z as the front and the camera as toward +Z. player_anims.tres contains idle_down (front-facing frames 16 and 20). While the tree is paused, BaseCharacter's physics-driven animation/direction synchronization does not run.
- In scope: temporarily change the player to direction = down plus idle_down at cut-in start, while saving pending direction and current animation playback/frame state; restore them before unpausing on both completion and abort.
- Out of scope: modifying the animation library/spritesheet, ordinary direction selection or state machine behavior, ultimate gameplay/timing, and camera motion.
- Acceptance: the player faces the camera during the cut-in; the prior direction and exact animation state resume when the cut-in finishes or aborts.
- Checks: inspect idle_down mapping, saved/restored state and git diff --check. Godot visual/playback restoration checks from varied directions and animations remain NOT RUN; no runtime acceptance will be claimed from static review.

### Implementation and static evidence (2026-11-09)

- scenes/player/player.gd now captures current/pending direction, AnimationPlayer animation name/position/active/playing state, and Sprite3D frame/flip. It temporarily sets both direction values to down, applies the down-facing Direction transform, and starts idle_down at its first frame. Restore re-applies the saved directions and resumes/seeks the prior animation (or restores the saved sprite frame/flip if no active animation existed).
- scenes/player/ultimate_cinematic.gd requests that temporary pose before pausing and restores it from the same camera/pause cleanup path on completion or abort, before the game unpauses.
- Static review: BaseCharacter maps down to yaw 0/front local +Z; player_anims.tres maps idle_down to front-facing frames 16 and 20; BaseCharacter's direction/animation synchronization is physics-driven and therefore does not update during tree pause. The animation state restore uses AnimationPlayer.current_animation_position and seek(..., true), supported by the [Godot AnimationPlayer docs](https://docs.godotengine.org/en/stable/classes/class_animationplayer.html).
- git diff --check passes. NOT RUN: Godot parse/import or visual checks with the player beginning from varied directions/actions, front visibility during the zoom-only cut-in, and resumed animation behavior. T055 remains open pending runtime verification; no reviewer agreement is claimed.
## Ultimate camera zoom-only refinement (T056)

### Acceptance and review boundary recorded before implementation

- Owner: Bao, for the player cinematic refinement requested by the user.
- In scope: remove the orbit and camera translation from the existing paused cut-in; animate only Camera3D FOV in and out, preserving the saved transform/FOV restoration and all impact/title/player-pose behavior.
- Out of scope: camera-rig changes, player facing/animation, impact/title art, pause timing, ultimate casting or gameplay behavior.
- Acceptance: camera position and orientation remain unchanged while FOV zooms toward the player, then returns to the original value before casting; no rotational or positional camera shake occurs.
- Checks: inspect the camera update methods for FOV-only changes and cleanup for exact camera restore, then git diff --check. Godot visual checks for framing and stability remain NOT RUN; no runtime acceptance will be claimed from static review.
- This user refinement supersedes the orbit requested in the original T054 implementation; the earlier T054 and T055 implementation notes describe the prior state, while T056 records the current zoom-only behavior.

### Implementation and static evidence (2026-11-09)

- scenes/player/ultimate_cinematic.gd removes the camera orbit, camera position changes, and look_at calls from the zoom methods. The cut-in now changes only FOV, narrowing it to 68% of the saved value and then easing it back; the originally saved full camera transform/FOV is still restored during completion/abort cleanup.
- T054 and T055's current task acceptance now describes zoom-only behavior. Their earlier implementation notes are historical; this T056 refinement supersedes their prior orbit behavior.
- Static review confirmed the zoom methods only write Camera3D.fov and do not change position, rotation, or basis. git diff --check passes.
- NOT RUN: Godot parse/import or visual playtest for zoom strength, camera framing/stability, exact return, and impact/title readability. T056 remains open pending runtime review; no reviewer agreement is claimed.

## Skill Tree size follow-up (T057)

### Acceptance and review boundary recorded before implementation

- Owner: Bao, for the Skill Tree presentation follow-up requested by the user.
- In scope: increase the open-book page and graph footprint, then tune the available graph/node sizing so weapon and character trees read larger and wider. Preserve the existing book controls, detail card, tab and allocation interactions, pan/zoom, and all progression/gameplay behavior.
- Acceptance: both trees occupy substantially more of the available spread and their nodes/icons are more readable without clipping, overlap, or obscuring controls/details across supported resolutions.
- Checks: inspect responsive sizing/layout and existing allocation callback preservation, then `git diff --check`. Godot visual/input checks at representative resolutions remain NOT RUN; no runtime acceptance or reviewer agreement will be claimed.

## Lightning enemy status VFX follow-up (T058)

### Acceptance and review boundary recorded before implementation

- Owner: Bao, for player combat/skill presentation requested by the user.
- In scope: give lightning elemental hits, active lightning skills and lightning ultimates an electric status visual through the local Pixelfx `lightning/electrified` effect and shared status presentation code. Keep `apply_skill_freeze` logic and current durations intact, keep ice freeze art, and let repeated status refreshes reuse the existing sprite/timer.
- Acceptance: lightning freeze/stun remains mechanically unchanged but presents as electricity; ice continues to present as ice; no duplicate electric status sprites are stacked.
- Checks: inspect all lightning freeze call sites, shared status refresh behavior, and exported asset/metadata paths, then `git diff --check`. Pixelfx preview review is planned before selection; Godot import/playtest, visual scale and status lifecycle remain NOT RUN. No runtime acceptance or reviewer agreement will be claimed.

### Implementation and static review (2026-11-09)

- `ui/skill_tree_layout.gd` now sizes the book spread to a wider 1.58 aspect ratio within 96% viewport bounds, expands the page content from 84% to 90% of book width and from 80% to 84% of height, adjusts the description-card width responsively, reduces the graph/card gap, and opens the graph at 110% zoom. The existing tabs, graph callbacks, node positions, zoom/pan controls and allocation APIs are unchanged.
- `scenes/player/battle_vfx.gd` adds a refreshable `BattleStatusElectrified` sprite using `lightning/electrified`; it uses the shared duration timer and loop-frame loader so repeat hits refresh the effect rather than add another sprite.
- `scenes/player/player.gd` routes elemental lightning hits, active lightning chain/strike/storm skills and lightning ultimates through the electric visual. The existing freeze durations and calls to `apply_skill_freeze` remain unchanged. Ice skills keep the default `frozen` visual.
- Added `assets/effects/pixelfx/lightning/electrified/electrified.png` and matching JSON metadata from the local Pixelfx catalog. The inspected candidate is a 60-frame, 108×92, 2-second electric silhouette/arcing loop; its contact sheet visibly shows blue-white lightning around a character. The existing Pixelfx source library and its license/notice are unchanged.
- Static source review covered responsive book/page bounds, all lightning freeze-status call sites, the existing refresh timer, and asset paths. `git diff --check` is the whitespace check. Godot import/parse, small/large viewport appearance, allocation interaction, and enemy VFX scale/expiry are NOT RUN. T057/T058 remain open pending runtime visual/lifecycle review; no reviewer agreement is claimed.

## Player HUD combat feedback follow-up (T059)

### Acceptance and review boundary recorded before implementation

- Owner: Bao, for Player HUD and combat presentation.
- In scope: expose truthful ultimate readiness, compact dash/parry cooldown feedback, current durations for already-existing attack/speed buffs and ice shield, and a pulsing warning at low health. Do not alter input mappings, gameplay values, cooldown rules, buff/shield rules, or Skill Tree behavior.
- Acceptance: displayed readiness and remaining times follow the existing player state; active-effect chips hide when their effect ends or shield is consumed; the low-health warning appears only for a living player at one-third maximum health or less; the HUD fits supported viewport sizes without obscuring combat.
- Checks: review state-to-HUD wiring, timer countdown/expiry, current key labels and slot placement, then `git diff --check`. Godot parse/import, visual layout, and runtime input/status behavior remain NOT RUN. No runtime acceptance or reviewer agreement will be claimed.

### Implementation and static review (2026-11-09)

- `ui/hud.tscn` now shows the rage text alongside its bar rather than keeping it hidden. The label reports ultimate-ready only when an ultimate is selected, rage is full, and its cooldown is zero.
- `ui/player_hud.gd` expands the bottom bar with compact Shift/Dash and L/Parry slots; each shows readiness or its fractional cooldown. It also adds a pulsing `MÁU THẤP` label at or below one-third health and a compact status strip for current attack/speed buffs and the ice shield.
- `scenes/player/player.gd` tracks display-only remaining times for the current temporary buffs and shield. The HUD reads the existing dash/parry timers, buff values, ultimate cooldown, rage and shield count. Input bindings and all gameplay values/timers remain unchanged.
- Static review matched the displayed actions to the existing `project.godot` bindings (Shift dash, L parry, U skill, I ultimate), verified low-health threshold and status expiry/consumption wiring, and checked that the eight-slot bar uses compact defense slots. `git diff --check` is the whitespace check.
- NOT RUN: Godot parse/import, viewport/layout inspection, input behavior, buff countdown, cooldown readiness, or low-health animation in game. T059 remains open pending runtime review; no teammate/reviewer agreement is claimed.

## Player HUD presentation polish (T060)

### Acceptance and review boundary recorded before implementation

- Owner: Bao, for Player HUD and combat presentation.
- Scope: `ui/player_hud.gd` and `ui/hud.tscn`. Keep the rage meter but remove numeric rage percentages from visible labels/tooltips; compact the skillbar and separate Dash/Parry into their own icon-bearing defense group; add a pulsing, soft red vignette confined to the screen edges while the living player is at one-third health or less.
- Acceptance: no rage percentage remains in HUD text/tooltips; elemental skills plus the ultimate/tree remain in the main group while Dash/Parry are boxed separately and their icons remain legible during cooldown; the vignette tracks the existing low-health threshold, disappears after recovery or death, and does not cover the playfield center.
- Preserve: input mappings, cooldowns, skill selection, health rules, and Skill Tree behavior. No cross-owner system is changed.
- Checks: inspect bar grouping/sizing, icon rendering and cooldown overlay order, percentage-free rage text, shader edge falloff and low-health visibility; run `git diff --check`.
- NOT RUN before implementation: Godot parse/import, visual review at supported viewport sizes, and runtime threshold/pulse behavior. No reviewer agreement is implied.

### Implementation and static review (2026-11-09)

- `ui/hud.tscn` now initializes the rage label without a percentage. `ui/player_hud.gd` uses only `NỘ KHÍ` or `TUYỆT KỸ SẴN SÀNG`; the ultimate tooltip reports a text state instead of numeric rage.
- The four active-skill slots, ultimate and Skill Tree remain in the smaller main group. Dash and Parry occupy a separately styled adjacent defense group; their Shift/L badges, generated pixel icons and cooldown timers have dedicated layout. Cooldowns remain sourced from the existing player timers.
- A full-viewport shader vignette uses a soft 12% edge falloff and low-alpha pulse. Its CanvasLayer uses identity transform so the HUD's horizontal scale does not stretch the screen filter. Both the warning and vignette follow the existing living-player one-third-HP threshold and hide while Skill Tree is open.
- Static review confirmed all rage text/tooltips are percentage-free, slot arrays retain index mapping, defense icon IDs match their calls, and the vignette visibility is gated by health and Skill Tree state. `git diff --check` reports no whitespace errors; Git emits only existing Markdown line-ending normalization warnings.
- NOT RUN: Godot parse/import and in-game viewport, icon, cooldown, edge-filter and pulse verification. T060 remains open pending runtime review; no reviewer agreement is claimed.
