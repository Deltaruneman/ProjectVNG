# First Scene-Foundation Validation

**Date**: 2026-11-05 | **Branch**: `basement-split-floors`
**Initial HEAD**: `0c01c67b3fa087fa898a8d5f4e7d8afbe170cd3f`
**Authorized scope**: Latest user instruction authorizes T012-T017, only slice-required
T013 tests, and applicable T025 interaction checks, then stop. Historical scope below is retained.
**Latest verification**: See the resume section at the end: T003/T009 complete;
T010/T011 partial; Lam's observations recorded; T012 agreement missing blocks dependent work.
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
