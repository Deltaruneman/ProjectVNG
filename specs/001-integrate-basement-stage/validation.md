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

## Player HUD readability and menu ordering (T061)

### Acceptance and review boundary recorded before implementation

- Owner: Bao, for Player HUD and Skill Tree presentation.
- Scope: reduce the active-status chip font/padding and rage-label font; move the existing Skill Tree into a dedicated menu CanvasLayer that ranks above HUD, boss HUD, low-health vignette and cinematic/VFX layers. Define one shared layer value for gameplay menus so later menu scenes can use the same topmost ordering.
- Acceptance: buff/rage text is smaller but readable and uncut; the Skill Tree menu renders above all current gameplay HUD/effect layers, opening hides the gameplay HUD and closing restores it; no Duy-owned boss layer or gameplay behavior is edited.
- Checks: inspect font/padding overrides, the parent CanvasLayer assignment, `set_skill_tree_open` visibility flow, all in-project gameplay CanvasLayer values and `git diff --check`.
- NOT RUN before implementation: Godot parse/import and runtime visual stacking checks. The repository currently contains the Skill Tree as the only player-facing gameplay menu scene; no reviewer agreement is implied.

### Implementation and static review (2026-11-09)

- `ui/player_hud.gd` reduces active-status labels to 7 px with 2 px chip margins and 3 px spacing. The HUD exports `MENU_CANVAS_LAYER = 100` as the shared ordering value and toggles the dedicated menu layer while hiding/restoring gameplay HUD children.
- `ui/hud.tscn` moves `SkillTree` beneath a hidden `SkillTreeLayer` CanvasLayer at layer 100 and reduces the RageLabel font from 10 to 8.
- `ui/skill_tree_layout.gd` assigns its parent menu CanvasLayer to the shared layer value and now walks ancestors to find the HUD visibility callback after reparenting. The existing menu is above HUD 1, vignette 2, Dark Fairy BossHUD 3, Pixelfx 21 and ultimate cinematic layers 20/22. No Duy-owned layer was edited.
- Static source search found Skill Tree is the only player-facing gameplay menu scene; all menu references use the new parent path or ancestor callback. `git diff --check` reports no whitespace errors, with a CRLF normalization warning for this validation file.
- NOT RUN: Godot parse/import or runtime menu/HUD stacking and font readability at supported viewport sizes. T061 remains open pending visual review; no reviewer agreement is claimed.

## Wind ultimate redesign (T062)

### Acceptance and review boundary recorded before implementation

- Owner: Bao, for Player combat, skills and Skill Tree.
- Scope: preserve the `ultimate_wind_2` ID and replace only its Wind-form behavior, presentation name and SP threshold. Add a dedicated PlayerState for collision-aware movement, reuse current Wind dash/VFX and enemy slow/damage systems, and clear only unlocked Wind active-skill cooldowns on completion. Other forms and `ultimate_wind_1` remain outside the change.
- Acceptance: the 10-SP “Trăng Tối” ultimate circles the nearest living enemy (or its cast point when none is nearby) for 3.6 seconds, repeatedly damages and slows enemies along its path, blocks both Player hurt-area and state damage routes while active, returns to normal movement, and resets unlocked Wind active-skill cooldowns without resetting the ultimate cooldown.
- Checks: inspect threshold and ID preservation, state registration/entry/exit, normal collision-aware movement, repeat pulse coverage, immunity cleanup, cooldown reset and title/HUD mappings; run `git diff --check`.
- NOT RUN before implementation: Godot parse/import or runtime unlock, movement/collision, immunity, damage/slow and cooldown tests. T062 must remain open until the Godot playtest; no reviewer agreement is implied.

### Implementation and static review (2026-11-09)

- `ultimate_wind_2` keeps its existing ID and 18-second ultimate cooldown. Its Skill Tree threshold is now 10 SP; other forms and Wind ultimate 1 retain their previous thresholds and behavior. Skill Tree, Player HUD, cinematic title and concept record use “Trăng Tối”.
- The dedicated `WindUltimateState` uses Player's existing collision-aware `_update_movement()` path for a 3.6-second, 2.5-rotation dash around the nearest living enemy within 8m, tracking that target while alive; without one, the cast position is the orbit center. Existing afterimage/trail, slash and Wind burst effects are reused.
- Pulses run every 0.32 seconds, hit enemies within 3.2m for current attack damage, and apply the existing 50% slow for 0.55 seconds. Repeated ultimate pulses do not refill the Rage meter they just spent. `is_invulnerable` and `invincible` are set before entering the state and both are cleared on exit; the blade suppression is also paired on entry/exit.
- On completion, only cooldown entries for unlocked `active_wind_1` through `active_wind_4` are cleared. The 18-second ultimate cooldown remains active. The existing FSM idle state restores normal input/movement.
- Static inspection confirmed the registered state name matches the lookup, movement velocities flow through Player's stair-aware collision method, `ultimate_wind_2` references retain the ID, and the title/SP mappings are consistent. `git diff --check` reports no whitespace errors; Git emits Markdown CRLF-to-LF normalization warnings for the implementation changelog and this validation file.
- NOT RUN: Godot parse/import or in-game unlock, trajectory/collision, pulse damage/slow, immunity, cleanup, cooldown and Rage checks. T062 remains open pending the required playtest; no reviewer agreement is claimed.

## Skill Tree alignment and ultimate presentation (T063)

### Acceptance and review boundary recorded before implementation

- Owner: Bao, for Skill Tree and Player combat presentation.
- Scope: adjust the existing graph viewport/layout and status-chip presentation; add a temporary element-colored full-screen glow and Player neon shimmer that begin after an ultimate cinematic and end with the corresponding ultimate effect. Preserve ultimate gameplay rules and restore the exact prior Player sprite material. Keep slash and ice-shield VFX untouched; no cross-owner system is in scope.
- Acceptance: the visible Skill Tree nodes/links are centered without clipping across supported aspect ratios; buff chips are compact but legible; each ultimate starts with its matching colored screen/player treatment only after its cut-in, then removes it at the effect end and restores all prior sprite state, including Wind 2 cleanup and scene/player exit.
- Checks: inspect graph transform/viewport bounds, chip font/padding, element palette mapping, presentation duration and cleanup paths for every ultimate; run `git diff --check`.
- NOT RUN before implementation: Godot parse/import, Skill Tree visual review at supported aspect ratios, and in-game ultimate timing/color/material restoration. T063 must remain open pending runtime visual review; no reviewer agreement is implied.

### Implementation and static review (2026-11-09)

- `SkillTreeGraph` now allows graph nodes to render outside its viewport clip, and `SkillTreeLayout` applies a responsive right offset so the node cluster moves toward the center of the open page. Page content still clips at the book-page bounds. Buff chips are reduced from 7 px to 6 px, with 1 px padding and 2 px spacing.
- Every ultimate starts a temporary presentation when `cast_ultimate()` runs, which occurs after the existing cinematic's finished signal. The fullscreen CanvasLayer at 23 uses a pulsing screen shader tinted wind teal, fire coral, ice cyan or lightning yellow; the player's existing Sprite3D receives a time-varying neon shader overlay. Each skill uses a presentation duration aligned to its visible effect (Wind 2 uses its 3.6-second state). Fade-out reaches zero, the previous sprite material overlay is restored, and death, Wind-state completion or Player tree exit cleans up the presentation.
- A Pixelfx catalog candidate (`holy/blessing`) was rendered and inspected; it uses a fixed gold beam and actor preview, so it did not fit the requested per-element screen tint and sprite-following shimmer. No Pixelfx export or shared slash/ice-shield code was changed; the requested color treatment is implemented with local shaders.
- Static source review confirmed the menu remains at CanvasLayer 100, the glow is at layer 23, all eight ultimate IDs reach the existing cast path, and the material restoration checks only replace the shader overlay installed by this effect. `git diff --check` reports no whitespace errors; Git emits Markdown CRLF-to-LF normalization warnings for the implementation changelog and this validation file.
- NOT RUN: Godot parse/import, graph clipping/clickability at supported aspect ratios, and in-game element colors, visual intensity, fade timing and cleanup. T063 remains open pending runtime visual review; no reviewer agreement is claimed.

### User clarification — outline-only player neon (2026-11-09)

- The user clarified that the player treatment must follow the sprite silhouette, not tint a full second copy of the sprite. The accepted appearance is a thin, pulsing elemental contour outside the alpha silhouette; the original sprite fill/colors stay unchanged. The fullscreen elemental glow remains unchanged.
- `ultimate_neon.gdshader` now compares neighboring alpha samples and emits only where a transparent pixel borders the current frame's opaque player silhouette. `player.gd` updates the sampled frame rectangle as the sprite animation changes and continues restoring the saved material overlay on completion/exit.
- Static review checked that the shader discards interior pixels, clamps samples to the active sprite-sheet frame, and applies the elemental color/intensity only to the contour. `git diff --check` remains the whitespace check. NOT RUN: Godot shader import/compile or in-game outline thickness/frame-edge/animation review; T063 remains open, with no reviewer agreement claimed.

## Ultimate cast-impact VFX (T064)

### Acceptance and review boundary recorded before implementation

- Owner: Bao, for Player combat and skill presentation.
- Scope: intensify only the actual cast/hit effects for Wind, Fire and Lightning ultimates using the existing PVFX Foundry exports. The user clarified that the cinematic is already good; this task targets the attack effects after it. Ice ultimate art, cinematic/camera, T063 screen glow and Player outline, slash implementation, and all gameplay behavior are outside this change.
- Candidate review: inspected the PVFX Foundry CC0 pack already present in the project. `wind/wind-blade`, `wind/wind-gust`, `wind/whirlwind`, `impacts/shockwave-ring`, `impacts/ground-slam`, `fire/fire-pillar`, `fire/meteor-strike`, `explosions/fire-nova`, `explosions/big-explosion`, `lightning/lightning-strike`, `lightning/chain-lightning`, `lightning/static-burst`, and `shadow/void-implosion` were previewed. The final selection uses the cast/impact effects listed in the implementation section; `wind/whirlwind` was not used because its looping animation would stay at a fixed projected screen point while the Player or camera moves. Pack license/docs confirm rendered sheets and manifests are CC0 1.0.
- Acceptance: each of the six Wind/Fire/Lightning ultimate IDs gets an unmistakably stronger, element-appropriate effect at its existing cast/impact point; no gameplay values change and no visual strike is shown on an unaffected target. Both Ice ultimate paths remain unchanged.
- Checks: review helper resource/camera guards, sheet/manifest parsing, scale/pivot/timing, target filtering and exact ultimate call sites; run `git diff --check`.
- NOT RUN before implementation: Godot parse/import and in-game visual/scale/timing/per-target review. T064 remains open until those visual checks; no reviewer agreement is implied.

### Implementation and static review (2026-11-09)

- `BattleVFX.ultimate_impact()` now reuses the existing PVFX Foundry atlas loader and metadata, projects a world point and world-scale into the shared pixel VFX CanvasLayer, applies the PVFX pivot/tint/direction, and removes one-shot animations on completion. Existing overlay/cache is reused. The new helper returns safely if Player, camera, scene or effect resources are unavailable.
- Wind ultimate 1 now layers an aimed gust and large shockwave ring over its existing radial slashes. Trăng Tối starts with a gust, adds a PVFX wind blade to each existing pulse, and ends with a void implosion and shockwave ring. The projected vortex candidate was not added because it would not track the moving target/camera.
- Fire ultimate 1 now combines a fire pillar and fire nova around its existing buff/cast. Fire ultimate 2 layers the meteor strike and large explosion over its existing charge.
- Lightning ultimate 1 adds a static burst, chain arcs and vertical bolts only for living enemies inside the same horizontal radius and 2.5-unit vertical tolerance used by its damage helper. Lightning ultimate 2 adds a cast burst and chain/strike effects for each living enemy inside the same 2.5-unit vertical tolerance used by its existing global-damage path.
- Both Ice ultimate branches and the cinematic/camera, T063 screen glow/outline, damage, statuses, hit timing, cooldowns and slash implementation remain unchanged. No external asset was downloaded or modified; the referenced PVFX exports were already in the project and the pack's local license says their sheets/manifests are CC0 1.0.
- Static checks confirmed all selected sheets and manifests exist and match expected dimensions, pivots, loop flags and durations (one-shot effects range from 780–1,680 ms); target filters match the existing lightning damage constraints; `git diff --check` passed. Git reports existing Markdown CRLF-to-LF normalization warnings for the changelog and validation file.
- NOT RUN: Godot parse/import or in-game scale, occlusion, timing, target alignment and player/camera movement review. The projected sprite effects keep their screen position for the life of each one-shot, so movement during a long animation may produce some drift. T064 stays open pending visual review; no reviewer agreement is claimed.

## Active Ice skill PVFX trial (T065)

### Acceptance and review boundary recorded before implementation

- Owner: Bao, for Player skill presentation.
- The user asked to try PVFX replacements on a few existing Ice skills and judge whether they fit. Existing sheet previews were inspected: `ice/frost-breath` is a directional horizontal frost stream, and `ice/ice-spike` grows from a compact flash into a broad spike burst. Their local grid manifests declare 14 frames/910 ms/loop for frost-breath and 26 frames/1,820 ms/one-shot for ice-spike, with authored pivots suitable for projecting from the Player.
- Scope: change only the VFX call for active Ice 2's forward cone and active Ice 4's circular storm, using the existing PVFX loader. Preserve damage, aim/range, freeze, cooldown/hit timing, shield/ring, slash sheets, status visuals, both Ice ultimates, and all non-Ice skills.
- Acceptance: `ice/frost-breath` visually follows the cast aim across the existing cone, while `ice/ice-spike` fills the existing storm footprint; one-shot/loop FX end cleanly and no gameplay behavior changes.
- Checks: inspect sheet manifests/pivots, helper scale/direction/lifetime handling, exact call sites and unchanged damage/status arguments; run `git diff --check`. The user asks for a trial assessment; in-game visual review should be run if a Godot runtime is available. If unavailable, report it NOT RUN and leave T065 open for hands-on visual review.

### Implementation and static review (2026-11-09)

- `BattleVFX.play_pvfx()` exposes the existing PVFX sheet renderer for ordinary active skills; the existing `ultimate_impact()` now delegates to it, so prior T064 call sites retain the same behavior.
- `active_ice_2` replaces only the old `ice/ice-shatter` claw effect with directional `ice/frost-breath`, anchored at the Player and sized to half the unchanged 5-unit cone reach. Its authored loop is capped at 0.72 seconds. The cone damage and freeze arguments are unchanged.
- `active_ice_4` replaces only the old Pixelfx `ice/frost-nova` with the one-shot PVFX `ice/ice-spike`, using the existing evolution-scaled storm radius. Its damage, radius and freeze arguments are unchanged.
- `active_ice_3` shield/ring, Ice attacks/slash sheets, status effects, both Ice ultimate branches and all non-Ice skills are unchanged.
- Static review confirmed both sheets and manifests exist; `frost-breath` is a 14-frame/910 ms loop with pivot `[4,21]`, and `ice-spike` is a 26-frame/1,820 ms one-shot with pivot `[46,68]`. `git diff --check` is the code/record check.
- NOT RUN: Godot parse/import or in-game effect scale, facing, occlusion and overall style fit. The Godot desktop window could not be accessed by Computer Use (the tool reported that access to the Godot app was not approved); the user will inspect the trial in game. T065 remains open pending that visual feedback; no reviewer agreement is claimed.

## Other-element active skill PVFX trial (T066)

### Acceptance and review boundary recorded before implementation

- Owner: Bao, for Player skill presentation.
- The user asked about the other elements after the Ice trial. Existing PVFX Foundry sheet previews/manifests were inspected for Wind (`wind-blade`, `whirlwind`), Fire (`fire-nova`, `lava-burst`, `meteor-strike`) and Lightning (`chain-lightning`, `lightning-strike`, `static-burst`).
- Scope: update only active skill effect call sites for Wind 3/4, Fire 2/3/4, and Lightning 2/3/4. Preserve damage, range, aim, cast/timer/sequence timing, target filters, status effects, slash implementation, all Ice skills and both Ice ultimates.
- Acceptance: the new visuals match each skill's shape/element, use the checked-in PVFX sheet timing/pivot, and do not show target-specific Lightning hits on enemies excluded by the corresponding damage path. No gameplay behavior changes.
- Checks: inspect manifests, helper call arguments and effect cleanup; compare Lightning visual filters to the hit helper; run `git diff --check`. The user will review the actual appearance in game. Runtime visual acceptance remains open until they report back.

### Implementation and static review (2026-11-09)

- Wind 3 now uses the PVFX wind blade beside the unchanged sword slash. Wind 4 uses a PVFX whirlwind loop for the existing two-second tornado period and keeps its existing radius/slow call.
- Fire 2 keeps its five-second delay and charge, then plays `explosions/fire-nova` at the existing blast center. Each Fire 3 rage pulse now uses `fire/lava-burst` at the existing circle. The `BattleVFX.meteor()` helper now keeps its charge and plays the PVFX `fire/meteor-strike`; repository search confirmed its only call is active Fire 4.
- Lightning 2 draws chain arcs and strikes only living enemies inside the existing 38-degree cone, reach and 2.5-unit height tolerance. Lightning 3 layers a vertical bolt/static burst at the existing strike center. Lightning 4 adds a static burst at the Player and vertical strikes only on living enemies with a hurt area inside the existing 5-unit circle and 2.5-unit height tolerance.
- Static review confirmed all eight PVFX sheets and manifests exist; their authored durations range from 780 to 1,610 ms, with only the whirlwind looping. Existing charge, sword slash, damage, range, cooldown, delayed timing, status application, Ice trial and ultimate calls are unchanged. `git diff --check` passed; Git emits Markdown CRLF-to-LF warnings for the changelog and validation record.
- NOT RUN: Godot parse/import or in-game scale, occlusion, facing and full visual-fit review. The 2-second whirlwind is projected to the screen at cast time and may drift if the Player/camera moves during the loop. The user will inspect the visual trial; T066 remains open until they report fit/adjustments. No reviewer agreement is claimed.

## Dark Fairy intro and defeat cut-ins (T067)

### Scope and review boundary recorded before implementation (2026-11-10)

- Static inspection: darkfairy.gd sets engaged on detection-range entry and exposes the existing BossHUD/Bar and BossHUD/Name; health UI visibility currently follows engaged. Phase-2 death currently plays the 2.1-second phase2_death animation, then emits defeated and frees the boss. ultimate_cinematic.gd already provides the project’s pause, FOV-only zoom, black/white impact-frame and title pattern.
- Owner/reviewer: Duy, for Dark Fairy boss behavior and scene integration. The user reports Duy approved this exact T067 scope on 2026-11-10; this is relayed approval, not direct reviewer sign-off. The earlier T053 approval covered only boss-bar texture/style.
- Proposed intro: once per spawned boss instance, pause gameplay on first detection-range entry, zoom only camera FOV (no shake, orbit, or translation), show the Dark Fairy title, reveal the existing BossHUD, then restore and resume.
- Proposed defeat: on the existing phase-2 lethal hit, use a short black-screen beat and one slash, show the Dark Fairy sprite separated into two halves, then emit defeated and free the boss through its existing completion path. Preserve combat and health/phase rules. Skip the cut-in and use the existing death path if the active camera is unavailable.
- Out of scope: level scenes, Player/skill scripts, enemy base/shared systems, boss AI/attacks/damage values, phase transitions, BossHUD styling/layout, and all unrelated working-tree changes.
- Acceptance: intro triggers once on first engagement and does not replay on range re-entry; existing boss name/health UI is visible after the intro; camera and pause state restore exactly. Defeat displays one slash and two clearly separated boss halves before cleanup, and cannot emit/free twice.
- Pre-implementation checks: source review of detection/attack gating, lethal-hit and animation-finished flow, HUD state, frame atlas layout, process-while-paused and restoration paths. After implementation, run git diff --check and a Godot visual check for first approach/re-entry, phase-2 defeat, split readability and missing-camera fallback.

### Implementation and static review (2026-11-10)

- The user reports Duy approved the exact T067 scope; this is relayed approval, not direct reviewer sign-off.
- darkfairy.gd now gates the intro once per spawned Dark Fairy, holds boss actions in a presentation state, updates the existing HUD, and starts the boss-local cinematic. A missing camera skips the intro; a defeated boss with no camera or an unusable sprite frame falls back to the existing phase2_death animation.
- darkfairy_cinematic.gd runs while the tree is paused. The intro uses the existing Pixelfx impact-frame helper, a boss-name title, a temporary FOV-only zoom and the existing BossHUD; the death cut-in darkens the screen, overlays one diagonal slash, draws two screen-space AtlasTexture halves from the current Sprite3D frame, separates them, then hands off to the existing defeated signal and cleanup.
- Static review confirmed the intro flag is set before starting the cut-in, only the idle state can choose an attack, both cut-ins restore the saved camera transform/FOV and previous pause state on completion/abort, and the defeat callback is guarded against duplicate emission. git diff --check passes; Git reports CRLF-normalization warnings for the Markdown files.
- NOT RUN: Godot parse/import and runtime visuals. Boss framing, Sprite3D-to-screen-half alignment, slash readability, pause restoration and fallback behavior remain unverified in game. T067 stays open until the user checks the cut-ins; no direct reviewer sign-off or runtime acceptance is claimed.

## Dark Fairy full-screen cut-in and camera focus (T068, T070)

### Scope and review boundary recorded before implementation (2026-11-10)

- The user reports Duy approved expanding the existing T067 boss-local presentation on 2026-11-10. This is relayed owner approval, not direct reviewer sign-off.
- T068 scope: only `scenes/enemies/darkfairy/darkfairy_cinematic.gd`; add full-viewport hit accents and extend the defeat slash across the viewport. Keep title, split halves, pause/cleanup, BossHUD styling/layout, gameplay and shared/player VFX unchanged.
- T070 scope: only `scenes/enemies/darkfairy/darkfairy_cinematic.gd`; compute a temporary translation in the camera view plane to center the boss, interpolate during existing cut-in beats, retain orientation and restore the exact saved camera global transform and prior pause state on all paths. Do not edit `camera_rig.gd`, stage scenes, Player camera behavior, shake/orbit or gameplay.
- Acceptance: both cut-ins center on the boss and show full-screen impact treatment; the defeat uses one full-viewport slash; overlays cleanly fade; camera orientation and exact transform/pause state restore after completion/abort.
- Static checks: inspect Camera3D projection/depth guards, focus interpolation, layer ordering/anchors/opacity, slash viewport bounds, paused processing and restoration paths; run `git diff --check`.
- NOT RUN before implementation: Godot camera playtests, fullscreen visual review or overlay/input review. Because the constitution requires Godot playtests for camera changes, T070 remains open pending runtime verification; no visual acceptance or direct Duy sign-off is implied.

## Lightning skill SFX differentiation (T069)

### Acceptance and review boundary recorded before implementation (2026-11-10)

- Owner: Bao, for Player skill/audio presentation.
- Static asset inspection found three local generic `Spells/Spell Impact` variants and no local audio filenames labeled thunder, lightning, electric, spark, zap, shock or bolt.
- Scope: only `scenes/player/battle_vfx.gd`; assign explicit different local spell/impact clips and varied pitch/volume profiles to every Lightning skill and hit ID. Preserve all other element routes, calls, and gameplay/VFX behavior. The absence of purpose-made Lightning sounds is a recorded content limitation.
- Acceptance: `active_lightning_1..4`, `ultimate_lightning_1..2` and `lightning_hit` no longer share one identical sound path/profile; each path exists and playback nodes still self-clean after stream completion.
- Checks: inspect all Lightning ID mappings, referenced file existence, sound helper cleanup, and unchanged non-Lightning mappings; run `git diff --check`.
- NOT RUN before implementation: in-game listening. Sound identity, mix balance and contextual fit remain unverified until heard in game; no user acceptance is implied.

### Implementation and static review (2026-11-10)

- T068: `darkfairy_cinematic.gd` now adds a full-viewport tinted flash with matching top/bottom impact bands at the intro title and defeat slash beats. The defeat slash scales to more than the viewport diagonal so it travels across the entire frame. All added UI ignores mouse input; existing impact-frame, title and split halves remain in place.
- T070: the cinematic calculates boss sprite position relative to the active camera's right/up axes and temporarily translates the camera in that view plane. Intro zoom/reveal and defeat blackout/fade interpolate camera position while preserving the saved basis/orientation; existing finish/abort cleanup restores the exact saved global transform, FOV and pause state. No `camera_rig.gd` or stage scene change was made.
- T069: each of the six Lightning skills and `lightning_hit` now has an explicit sample, pitch and volume mapping. The helper still checks file/stream availability and frees audio nodes on stream completion. Non-Lightning routes are unchanged. Referenced `Spell Impact 1/2/3.ogg` files all exist; the project contains no dedicated electricity-labeled SFX.
- Static review checked all Lightning IDs, camera focus/phase/restore paths, CanvasLayer ordering, full-rect anchors, viewport-scaled slash, and exact `git diff --check`; the whitespace check passes. Git emits only existing Markdown CRLF-to-LF normalization warnings for the records.
- NOT RUN: Godot parse/import and visual/camera playtests. The constitution requires Godot playtesting for camera changes, so boss framing, zoom/reveal, abort restoration and full-screen visual composition remain unverified. In-game listening is also NOT RUN, so the sound profiles may need tuning. T068-T070 remain open pending runtime/user review; Duy approval is user-reported, not direct reviewer sign-off.
## B2 respawn and clear-gated B3 access (T071)

### Acceptance and review boundary recorded before implementation

- Owner boundary: Lam / Quan own basement map integration and shared checkpoint routing; Duy owns the EnemyZone producer/wave behavior. The user clarified on 2026-11-11 that B3 access follows clearing the B2 enemies and reports that rule is already agreed. This is user-relayed consensus; no direct reviewer sign-off is claimed.
- In scope: `scripts/autoload/game_manager.gd`, `levels/objects/checkpoint/checkpoint.gd`, both `levels/level_1/basement_b2.tscn` and `basement_full.tscn`, a new B2-local clear bridge, and this task's records. Consume existing `EnemyZone.cleared` / `is_cleared()` without changing Duy's producer. Configure the one B2 zone with an enemy scene to clear after three defeats (its current `max_enemies` capacity); the adjacent zone has no enemy scene and is not part of the wave. Canonicalize new split-B2 checkpoint touches to `FIRST_STAGE` + `b2_start`, persist `b2_cleared` only after all configured B2 zones clear, and permit B3 path/UID transitions only with that flag.
- Preserve legacy-save migration/refusal, unsupported saved B3 checkpoint refusal, the checkpoint serializer, enemy behavior and all unrelated stage routes. The new door rule supersedes the previous no-B3-access rule only for an explicit B2 clear; no fallback/recovery policy for old B3 saves is introduced.
- Acceptance: standalone B2 checkpoint touch no longer creates a conflicting legacy pair; a death reloads the integrated stage at B2. The active B2 group is finite, all active-zone clear signals are required, and the saved flag keeps the B2 door open after reload. B3 loads are refused before clear and accepted after clear through the B2 door, with the player at `b3_down`. Existing old-B3 checkpoint conflicts still block respawn/startup.
- Checks: static route review for `set_checkpoint`, legacy load normalization, `respawn`, B3 allowlist gate, zone clear aggregate and both B2 scene instances; `git diff --check`. Godot playtests for checkpoint/death, kill limit, both door states, destination placement and saved progression are required for runtime acceptance; do not claim them from static review.
- NOT RUN before implementation: Godot parse/import or runtime checks. The task remains open until required behavior is playtested; no direct Duy/Lam/Quan sign-off is implied by the user's relayed agreement.

## Skill Tree scale and learn-confirmation restoration (T072)

### Acceptance and review boundary recorded before implementation

- Owner: Bao, for the Skill Tree UI. This is confined to the existing UI scripts and has no shared progression-system change.
- Existing record: T057's changelog says the tree opens at 110% graph zoom; the current source instead initializes `_graph_zoom` to 0.95. Current skill-node clicks invoke purchase callbacks directly.
- Scope: restore the 110% starting view and stretch the weapon graph's level spacing along its vertical axis. Keep hover details. Change node click/Enter to selection only, and put the selected node's action button in the existing left description panel. Route existing callbacks exclusively through that button and leave their eligibility checks, point costs and progression calls unchanged.
- Acceptance: larger/longer tree remains within its area; hover never changes progression; node activation only selects and reveals the appropriate action; the separate confirmation button performs the existing action once and is disabled when unavailable. Existing form choice, learned/evolution/character nodes, ultimate selection, reset, pan/zoom and tab navigation retain their behavior.
- Checks: inspect geometry and responsive bounds, all callback wiring, node hover/selection/description state, and that only the confirmation handler calls purchase callbacks; run `git diff --check`. Godot parse/import and visual/input playtests are NOT RUN unless separately requested. Keep T072 open pending runtime review; no reviewer sign-off is claimed.

### Implementation and static review (2026-11-11)

- `ui/skill_tree_layout.gd` restores the documented 110% initial graph zoom and spreads the weapon tree's root, skill, evolution and ultimate levels further along the vertical axis. The element choice and character trees also use more of the graph height. The open book/page sizing and existing zoom/pan controls remain in place.
- Clicking or pressing Enter on a node now selects it and updates the left details panel; node activation does not invoke purchase callbacks. A focused outline marks the selected node. The left panel's contextual button invokes its existing callback only when pressed, with labels for choosing an element, learning a skill/ultimate, evolving, upgrading, or selecting an unlocked ultimate. Existing `available` state disables actions that cannot currently be taken.
- Hover still shows the full node description and requirement. Hovering another node temporarily hides the selected node's action button, and leaving the hover restores the selected node and its button. The existing point costs, thresholds, skill IDs, selection rules, reset, tab and graph controls are unchanged.
- Static review checked all node activation wiring, callback call sites, button eligibility, hover/selection transitions, and graph positions/zoom. `git diff --check` passes; Markdown files emit only the existing CRLF-to-LF normalization warnings.
- NOT RUN: Godot parse/import or visual/input playtests, including panel layout at supported viewport sizes, click-to-select/confirm behavior, and allocation interaction. T072 remains open pending runtime review; no reviewer sign-off is claimed.

## Player skill speed and gravity tuning (T073)

### Acceptance and review boundary recorded before implementation

- Owner: Bao, for Player skill presentation and movement.
- Scope: speed only the Player's skill attack/throw animations and skill battle VFX by 1.2x. Recompute skill-state end time from the accelerated animation and restore the previous AnimationPlayer speed on exit/finish. Override Player gravity from the inherited 24 to 26 in `player.tscn`; leave BaseCharacter defaults, enemies and all other movement values unchanged.
- Acceptance: casts and spawned battle-effect animations play about 20% faster, skill-state timing follows the clip, timer-based loop VFX lifetimes and gameplay values remain unchanged, and only Player gravity increases by 2.
- Checks: inspect skill-state speed lifecycle/duration math, both VFX spawn paths, Player-only gravity override and unchanged cooldown/damage/status timers; run `git diff --check`. Godot parse/playback and jump/fall/stair/dash verification are NOT RUN unless explicitly requested; because gravity affects movement, T073 remains open until runtime checked. No reviewer sign-off is implied.

### Implementation and static review (2026-11-11)

- `scenes/player/states/skillstate.gd` applies a 1.2x AnimationPlayer speed only while an active skill attack/throw animation is running. Cast-state duration uses the accelerated clip length, and both state exit and finish restore the previous speed scale.
- `scenes/player/battle_vfx.gd` applies 1.2x playback to PixelFX and PVFX `AnimatedSprite2D` sprites created by its spawn helpers. Timer-based loop lifetimes, skill cooldowns, damage and status durations are unchanged.
- `scenes/player/player.tscn` overrides only the Player instance gravity from inherited 24 to 26; `scripts/base_character.gd` and enemy scenes are unchanged.
- Static review confirmed the temporary AnimationPlayer scale restoration, cast duration calculation, both intended sprite spawn paths, and Player-only gravity override. `git diff --check` passes; Git reports only the existing Markdown CRLF-to-LF normalization warnings.
- NOT RUN: Godot parse/import or skill playback and jump/fall/stair/dash playtests. Gravity changes movement, so T073 remains open until runtime verification; no reviewer sign-off is claimed.

## Locked-door dialogue crash (T074)

### Acceptance and review boundary recorded before implementation

- Owner: Bao, for the Player-facing dialogue integration. Scope is limited to `scripts/conversation.gd` and `scenes/player/player.gd`; no Door, Dialogic, BaseCharacter, or shared input implementation change.
- Acceptance: the locked-door timeline starts without missing-property/method access; the Player is not movable/actionable or able to start another interaction while talking; F remains available for Dialogic advancement; movement-enabled state is restored when the timeline ends; optional partner methods are called only when present.
- Checks: inspect all `Conversation.play` call sites, talk start/end and movement restoration, Player input pass-through, the `InteractiveArea3D` `can_interact()` contract, and optional partner guards; run `git diff --check`.
- NOT RUN before implementation: Godot parse or runtime reproduction. Keep T074 open until the reported locked-door interaction is verified in game; no reviewer sign-off is implied.

### Implementation and static review (2026-11-11)

- `scenes/player/player.gd` now exposes `is_talking`, `start_talk()`, `finish_talk()`, and `can_interact()`. It saves/restores the prior `movement_enabled` value, stops horizontal movement while starting dialogue, blocks Player input and FSM physics updates during the timeline, and returns to the idle animation.
- `scripts/conversation.gd` guards invalid Players and the globally active Dialogic timeline, then calls the Player talk lifecycle. Optional partner talk methods are invoked only when that BaseCharacter implements them.
- Static review confirmed the only current `Conversation.play()` call is `door_locked`, the Player API now matches the call contract, and `InteractiveArea3D` will leave input unhandled while `can_interact()` is false so Dialogic can advance. `git diff --check` passes; Git reports only Markdown line-ending normalization warnings.
- NOT RUN: Godot parse/import or reproduction of the locked-door interaction. T074 remains open until in-game dialogue start, advancement, and restoration are verified; no reviewer sign-off is claimed.

## Integrated B2-to-B3 direct transition (T075)

### Request and review boundary recorded before implementation

- The user clarified that the clear-to-open rule still applies: after all B2 enemies are defeated, the door should stop showing the locked dialogue and transition to B3. The request to bypass clear gating is withdrawn.
- Static finding: `enemy_zone.tscn` assigns `zone_crab.tscn` by default. The unused `EnemyZone_B` instances in both B2 scenes had no explicit `enemy_scene = null`, so they inherited the crab scene. `basement_b2_progress.gd` treated the inherited scene as configured, then rejected its `clear_kills = 0` and cleared all signal listeners. This also left the unused zone spawning indefinitely.
- Owner/reviewer: Lam / Quan for the basement scene configuration; this is a correction to T071's existing clear-gated scope, not a route-rule change.
- Planned change: set `enemy_scene = null` on the unused B2 zone in both `basement_b2.tscn` and `basement_full.tscn`, preserving the active zone and all `b2_cleared` checks.
- Acceptance: only the configured finite B2 zone participates; defeating its three enemies sets `b2_cleared`, opens the door, and allows the B3 transition.
- Checks: inspect the packed-scene default and both overrides, bridge's configured-zone selection, and unchanged door/route checks; run `git diff --check` after implementation.
- NOT RUN before implementation: Godot parse or kill/door transition playtests. T075 remains open pending runtime verification; no reviewer agreement or runtime result is claimed.

### Implementation and static review (2026-11-11)

- Set `enemy_scene = null` explicitly on `EnemyZone_B` in both `basement_b2.tscn` and `basement_full.tscn`. The shared packed EnemyZone scene's default crab assignment remains unchanged for configured zones elsewhere.
- Static review confirmed the progress bridge now excludes the empty second zone and retains the active zone with `clear_kills = 3`; the `b2_cleared` flag, door lock, and GameManager B3 guard are unchanged. `git diff --check` passes; Git reports Markdown line-ending normalization warnings only.
- NOT RUN: Godot parse or runtime kill/clear/door/B3 transition checks. T075 remains open until the user-reported flow is verified in game; no reviewer sign-off is claimed.

## Ultimate cut-in impact frame and Skill Tree readability (T076)

### Acceptance and review boundary recorded before implementation

- Owner: Bao, for Player ultimate presentation and Skill Tree UI. Do not change the shared `BattleVFX` helper or Duy's boss cinematic.
- Static findings: `ultimate_cinematic.gd` currently spawns the PixelFX impact frame through `BattleVFX.ultimate_impact_frame()` at the Player's world position, while its existing fullscreen flash and bands are separate CanvasLayer elements. The checked-in `impacts/impact-frame` asset is a 10-frame, 320×180, 30 FPS animation. Skill Tree initial graph zoom is 110%; node circles/icons/text are drawn at the current small sizes in `skill_tree_node.gd`.
- Scope: replace only the Player ultimate's world-positioned frame with a viewport-space animation using the existing atlas/manifest, fitted to cover the viewport and cleaned up with its cinematic. Raise the Skill Tree initial zoom to 115% and enlarge its node graphics/text. Keep existing camera/cinematic timing, title and bands, skill-tree callbacks, progression rules, and manual pan/zoom unchanged.
- Acceptance: the impact animation covers the full viewport and stays visible above the impact flash/bands without obscuring the title, then cleans up on finish/abort. The Skill Tree opens larger with readable nodes at supported viewport sizes and no changed selection, confirmation, or purchase behavior.
- Checks: inspect manifest-driven frame construction/timing, cover scaling and resize behavior, CanvasLayer draw order and cleanup; inspect node draw bounds and existing graph/callback wiring; run `git diff --check`.
- NOT RUN before implementation: Godot parse/import or runtime visual review. Keep T076 open pending in-game visual review and do not claim runtime acceptance or reviewer sign-off.

### Implementation and static review (2026-11-12)

- `scenes/player/ultimate_cinematic.gd` now reads the existing impact-frame sheet and manifest into a 10-frame `SpriteFrames` animation. It plays in the Player cinematic's CanvasLayer, scales uniformly to cover the viewport, recenters on viewport resize, renders above the flash/bands and below the title layer, then frees on animation finish or cinematic finish/abort. The existing `BattleVFX` helper and boss cinematic are unchanged.
- `ui/skill_tree_layout.gd` now initializes the graph at 115% zoom. `ui/skill_tree_node.gd` increases regular/prominent circle radii from 32/40 to 38/45, textured icons from 48/60 to 58/68, and rank/title fonts from 11/11 or 11/12 to 12/12 or 12/13. Node callbacks and progression data are unchanged.
- Static review checked the manifest frame size (320×180), frame count (10), 30 FPS timing, uniform cover-scale, resize handling, layer order and cleanup paths; it also checked the graph default and node drawing bounds against existing node layout sizes and confirmed selection/confirmation callbacks were untouched. `git diff --check` passes; Git emitted only the existing CRLF-to-LF warnings for Markdown files.
- NOT RUN: Godot parse/import or in-game review of all eight Player ultimate cut-ins and Skill Tree crowding/readability at supported viewport sizes. T076 remains open pending that visual review; no runtime acceptance or reviewer sign-off is claimed.

## Lightning active-skill 2/3 mechanic rework (T077)

### Acceptance and review boundary recorded before implementation

- Owner: Bao, for Player skill behavior and Skill Tree descriptions. The user asked to replace Lightning 2/3 with a line strike/teleport and a timed chasing clone, and selected the baseline cooldown/damage/range/explosion values. The user clarified that the clone chases the nearest enemy.
- Existing values to preserve: Lightning 2 has a 7 s cooldown, 7 m reach (+1 m per `evo_lightning_chain`), 2× skill damage and 0.45 s movement lock (+0.2 s/rank). Lightning 3 has a 9 s cooldown, 3 m blast radius, 3× skill damage (+1× `evo_lightning_storm` rank) and 0.6 s movement lock. The Player already calls the existing `EnemyCharacter.apply_skill_freeze()` API; no new Enemy API is planned.
- Scope: `scenes/player/player.gd`, a new Player-local `scenes/player/lightning_clone.gd`, `ui/skill_tree_layout.gd`, and the task/validation/changelog records. Lightning 2 hits only the first living valid target intersecting a 1.6 m straight line, then attempts a safe landing behind it; if no collision-safe point behind it exists, retain the damage and skip teleport. Lightning 3 summons a Player visual copy at the cast point; it follows the nearest living enemy via existing `PathAgent`/`GridPathfinder`, attacks using normal Player basic damage every 1.2 s for 5 s, then explodes once at its last position using the preserved values above.
- Boundaries: do not alter shared `EnemyCharacter`, `PathAgent`, or `GridPathfinder`; do not change other skill IDs, costs, evolution rules, damage, SFX or FX. T077 supersedes T066's previous Lightning 2/3 attack-shape/effect placements; T066's other selected PVFX visual review remains separate.
- Acceptance: line target order, range/height/width and one-hit behavior are correct; teleport respects world collision and safely skips if all behind-target offsets are blocked. The clone retargets after an enemy dies, moves only along the existing pathfinding graph, attacks no faster than the basic-dagger cadence, survives only for its five-second window, and cleans up on detonation, Player death or scene exit. Its explosion affects only living enemies in the recorded radius and applies the existing 0.6 s movement lock. Skill Tree text matches the two mechanics.
- Checks: inspect the line query and direct-damage/rage path, teleport collision query/fallback, clone target/path/timing/damage/lifetime and single explosion cleanup, VFX call sites, updated descriptions, and unchanged SFX/progression values; run `git diff --check`.
- NOT RUN before implementation: Godot parse/import or gameplay review. The constitution requires runtime playtests for Player teleport/traversal and the new chase/attack timing; keep T077 open until these checks are recorded. No Duy system change or reviewer sign-off is implied.

### Implementation and static review (2026-11-12)

- `scenes/player/player.gd` replaces Lightning 2's cone with a directed 1.6 m beam, chooses the nearest-forward living target within its range, deals the preserved 2× damage and movement lock, and attempts a landing behind the target using a shape-overlap query plus floor ray. It retains damage and skips the teleport if all candidate points are blocked. Lightning 3 now creates the local clone at the cast point using the existing skill cooldown values and Player movement speed.
- `scenes/player/lightning_clone.gd` copies the Player sprite with a lightning tint, selects the nearest reachable living enemy through the stage's existing `GridPathfinder`, follows `PathAgent` waypoints, performs the existing Player basic-damage box query on the 1.2 s cadence, and triggers a single 3 m explosion after 5 s with the preserved storm evolution damage and 0.6 s enemy movement lock. It cleans up on detonation, Player death, and normal stage removal; it adds no timers or shared Enemy/navigation code.
- `ui/skill_tree_layout.gd` now describes the straight Lightning 2 strike/teleport and Lightning 3 chasing clone/final blast. Skill identifiers, unlock/cost/evolution data, cooldown table, other active skills, and existing Lightning FX/SFX calls remain unchanged.
- Static review checked line projection/order, range/height/width filters, damage/rage/impact calls, safe-landing checks, clone targeting/path agent use, basic-damage source/cadence, five-second lifetime, one-shot detonation, cleanup, and descriptions. `git diff --check` passes.
- NOT RUN: Godot parse/import or in-game checks of the beam, failed/successful teleport, clone chase/attack cadence, final blast, Player death, and stage exit. T077 remains open until the required runtime review; no reviewer sign-off is claimed.

### Implementation and static review (2026-11-11)

- `scripts/autoload/game_manager.gd` now canonicalizes a matching checkpoint touch in either standalone B2 scene to `FIRST_STAGE` + `b2_start`. It allows B3 scene path/UID transitions only after `b2_cleared`; the prior conflict handling for saved B3 and unsupported checkpoint references remains in place. Legacy-save migration was not changed.
- `levels/objects/checkpoint/checkpoint.gd` recognizes the canonical integrated checkpoint as current while a standalone basement checkpoint scene is active.
- `levels/level_1/basement_b2.tscn` and `basement_full.tscn` configure the active B2 EnemyZone to clear after three defeats, attach `basement_b2_progress.gd`, and provide a locked B2→B3 door with spawn id `b3_down`. The empty second zone is ignored because it has no enemy scene.
- `levels/level_1/basement_b2_progress.gd` consumes the existing `EnemyZone.cleared` and `is_cleared()` API, validates all configured zones have a finite threshold before connecting, then saves `b2_cleared` after all clear. If already unlocked on entry, it stops active B2 zone timers so waves do not restart.
- Integration effects: the existing `GameManager` save flag now gates the door and direct B3 load route. No EnemyZone producer, door implementation, checkpoint serializer, save migration, player/death logic, or old-B3 recovery policy was edited.
- Static review checked checkpoint route ordering, exact standalone B2 ids, unchanged legacy normalization, both door instances and destination id, finite threshold, empty-zone handling, aggregate clear and persistent flag flow. `git diff --check` passes; Markdown files produce only the existing CRLF-to-LF normalization warnings.
- NOT RUN: Godot parse/import or runtime playtests for standalone checkpoint/death, three defeats, locked/open door states, B3 arrival, integrated scene behavior, or reload persistence. T071 remains open pending those checks. The user-reported agreement to clear B2 before opening B3 is recorded as relayed consensus, not direct reviewer sign-off.

## Antique spellbook Skill Tree (T078) — scope before implementation, 2026-11-12

- Owner: Bao. User requests a unified, classic book presentation for the T menu, including opening/closing animation.
- Baseline: pre-existing dirty layout/node changes include 115% default zoom, enlarged icons and updated Lightning descriptions; preserve these and all unrelated working-tree changes. T072/T076/T077 remain independently open.
- Static diagnosis: the resting book uses a cropped 246×183 image stretched to 1.58, while animation uses a full square 272 frame and a separate scale/position calculation. The graph is shifted 19% and not clipped. Its dark luminous node treatment clashes with parchment. Page turns leave content beneath the moving sheet; HUD restoration occurs before closing finishes.
- Boundary: only Skill Tree UI scripts and these records; no shared progression, save, map, player mechanics, or input mappings. No new gameplay design questions.
- Planned acceptance/checks: T078 in tasks.md; isolated UI preview and transition/selection checks with explicit fixture limitations. No reviewer agreement or runtime acceptance claimed before execution.

### T078 implementation and verification — 2026-11-12

- Implemented a shared 1088×1088 design-space book rig. The resting image uses the complete last opening frame, identical to the animation TextureRect's geometry, pivot, tint and filtering. Each sprite frame's alpha bounds are cached to keep upright leaves in the viewport. The same layout logic handles resize and the settled page.
- Two paper pages: left chapter tabs, point balance, scrollable description and pinned confirmation/footer; right graph, zoom controls, instructions and folio number. Serif heading with system-font fallbacks, warm parchment, engraved corner rules, brown/bronze seals and curved ink connections replace the floating dark/neon treatment. Preserve the existing 58/68 icon sizes and default 115% zoom; adjust node hitbox/label sizing and tier positions to fit. The old 19% graph shift is superseded by page-local placement and clipping.
- Opening/turning/closing fade ink while the leaves settle. A full-viewport mouse shield blocks transition clicks. Rapid T/Escape changes the desired final state, completing the current leaf before reversing. HUD stays hidden and gameplay stays paused through the closed cover; restore the prior pause state on completion/removal. A selected description remains pinned while moving the mouse toward its confirmation.
- Existing form/skill/evolution/ultimate/character callbacks, cost/eligibility expressions, reset API, heal-on-open behavior and T077 Lightning descriptions are retained. Vietnamese short form labels are presentation only. No Player, GameManager, SaveSystem, input-map, map or boss source was modified in T078.

**Runtime fixture and environment.** Godot `4.7.2.stable.official.ed1daf0bf`, OpenGL Compatibility / AMD Radeon 760M. Disposable project: `C:/Users/BaoHo/AppData/Local/Temp/ArcanaBook-T078-20261112`. Copies of the production Skill Tree scripts/assets run in `preview.tscn` with stub GameManager, Player and PlayerHUD. Custom user directory plus process-local APPDATA were set before engine startup; runtime printed `.../ArcanaBook-T078-20261112/userdata-base/ArcanaBook-T078-UI-only`. The actual game's save path, game scenes, autoload execution and editor import were not used by this fixture.

**PASSED — final fixture execution.** `preview.log` contains 103 PASS assertions, `RESULT failures=0`, and no script/runtime error or warning lines. Observed checks:
- Identical static/animation rectangle geometry; opening settles with pause/HUD held; page ink hidden during turning; active chapter settles.
- Selection alone does not spend, confirmation invokes the callback once, and unavailable actions cannot spend (fixture callback spy, not proof of production save/progression).
- Node rectangles stay inside the right page at 115% for element choice, Wind/Fire/Ice/Lightning and character layouts. At 200% zoom the graph clips to the page. Character renders also cover 1024×768, 1920×1080 and 2560×1080; initial render is 1280×720.
- All 56 visible animation-frame bounds fit the viewport used for that assertion (2560×1080).
- Rapid close/open requests, closing during a page turn, pre-existing pause and removal while opening restore the expected pause/HUD fixture state.
- Actual dispatched T key, mouse click on a visible node, and Escape with that node focused operate correctly; transition mouse shield enables/disables with the sequence.
- Visually inspected rendered element selection, selected Wind ultimate, character page, 4:3 layout and an intermediate page-turn frame. The first render exposed undersized labels and a clipped moving leaf; node packing/font sizes and animation bounds were corrected before the final run.

**Static checks.** `git diff --check` passes; only line-ending normalization notices for existing Markdown/GDScript working copies. Reviewed that data IDs/callbacks and unrelated dirty files remain outside this group. No cache cleanup, generators, commit or push.

**Failed attempts and limitations.** Initial fixture runs found two missing explicit types in the new folio drawing; these were corrected and the final run is clean. A direct `--script res://ui/skill_tree.gd --check-only` attempt against the main project reported `Identifier not found: GameManager` in that CLI entry context (despite exit code 0); it is NOT a passing whole-project parse check. Running the UI as a scene with its autoload in the isolated project succeeds. Main-game HUD/player/save integration, actual production purchase persistence, animation feel during a manual gameplay session and cross-platform font rendering remain NOT RUN. No Bao/teammate sign-off or full-game acceptance is claimed. T078 is implemented and fixture-verified, but remains unchecked pending main-game/reviewer acceptance.

Final preview image is copied to `C:/Users/BaoHo/.codex/visualizations/2026/11/12/01a1cdb7-ca7e-7bf2-afc0-e533e65ed2dc/skill-tree-book-preview.png`. Fixture source, import/parse logs and screenshots remain under the disposable path above.

## T079 camera rework — pre-implementation boundary, 2026-11-12

- Request: free orbit third-person camera with wall handling; user selects mouse-look and held Alt for cursor release.
- Baseline: only scenes/enemies/darkfairy/darkfairy.tscn is modified (2 insertions, 1 deletion); preserve it. Existing T078 and prior gameplay checks remain independently pending.
- Diagnosis: rig is fixed at (0,30,30), FOV 30, with no obstruction queries. PlayerState, dash, carry and skill aim consume world-axis input. BaseCharacter direction combines world attack orientation and four-way sprite animation, requiring a Player-local adapter when orbiting.
- Review boundary: Bao-owned camera/Player integration; consume Stage snap API and paused cinematic lifecycle without modifying map, shared BaseCharacter, enemy AI, save, input map or UI code. Current user request authorizes this bounded implementation; no independent reviewer agreement is asserted.
- Acceptance/checks: T079 above. Test in isolated user data; do not run generators or alter tracked caches.

### T079 implemented and rendered gameplay verification — 2026-11-12

**Final behavior and integration.** Mouse-look defaults to continuous capture; held Alt releases it, Escape leaves it released until an unhandled left-click. Wheel zoom is 3–14 m, initial requested boom 9 m, FOV 60, pitch -30..70 degrees. World-layer sphere sweeps include near-plane corners, ignore target/Areas/enemy layers, reject initial overlap, contract immediately and recover exponentially. World XZ pivot follows exactly (cannot lag through a wall), vertical lag is bounded and checked against geometry. Stage's existing snap API and automatic >6 m displacement detection reset camera interpolation on teleport. Paused cinematics retain camera transform/FOV ownership. Input releases for pause, dialogue, death, focus loss and removal.

Player movement/air movement, dash, carry facing, skill aim and attack/weapon orientation now share camera-relative world direction. Four-way billboard animation is selected in view space while preserving world-facing gameplay and attack animation playback position. No shared BaseCharacter/enemy state, input mapping, damage/speed/cooldown rule or map source changed.

Rendered inspection found the back-mounted sword and the non-solid checkpoint helm sprite could fill the view at the obstructed spawn angle. Camera-local SpriteBase3D alpha now fades the Player/sword near the lens and existing spawn-point AnimatedSprite3D markers in the immediate foreground. Their original alpha/cut mode is restored when clear, paused or removed; marker tint and interaction remain owned by existing checkpoint scripts. This additional camera-only presentation scope consumes the existing spawn_points group and does not modify checkpoint/map source. Compatibility renderer ignores GeometryInstance3D.transparency, so the initial property-only fade check was insufficient proof of visible fade; replaced with modulate alpha plus temporary alpha-cut disable and verified in actual images. API reference: https://docs.godotengine.org/en/stable/classes/class_geometryinstance3d.html#class-geometryinstance3d-property-transparency .

**PASSED — final focused rendered fixture:** `tests/camera_rig_check.gd`, Godot `4.7.2.stable.official.ed1daf0bf`, OpenGL Compatibility / Radeon 760M, 104 assertions, zero failures, no script/runtime errors in final log. Includes 72 finite-corner orbit overlap checks; thin wall; collision below user zoom minimum; smooth recovery; floor/ceiling; enemy layer exclusion; initial overlap/valid basis; jump lag; teleport; paused camera ownership; target alpha restore; viewport mouse yaw/pitch; wheel min/max; checkpoint marker fade and exact alpha/cut restoration; Escape, pause, focus and removal cleanup. Minimal project `C:/Users/BaoHo/AppData/Local/Temp/ArcanaCamera-T079-20261112`, logs `rendered-physics.log` / `rendered-console.log`. Run with a renderer, not --headless: put camera_rig.gd and camera_rig_check.gd beside a minimal project.godot and invoke Godot with `--path <fixture> --script camera_rig_check.gd`.

**PASSED — actual gameplay scene fixture:** `tests/camera_gameplay_check.tscn` loads actual `levels/level_1/basement_full.tscn` with production autoloads, Player, camera, HUD and Skill Tree. 20 assertions, zero failures in `gameplay-camera-4.log` / `gameplay-console-4.log`. Covered actual target/current-camera binding; four orbit quadrants; real T/Escape menu lifecycle and mouse release; Player talk gate; teleport to a remote fixture floor; actual W movement at 90-degree yaw; attack forward, sprite-facing and skill/hitbox alignment; dash direction after the real FSM transition; animation phase retention; real Alt down/up; dead-player cursor release. Movement checks use an added remote floor and temporary invincibility; they do not prove full basement traversal or combat balance. No progression purchase/reset or checkpoint save was requested by the harness.

**Isolation and visual evidence.** Full disposable copy `C:/Users/BaoHo/AppData/Local/Temp/ArcanaCamera-T079-full-20261112`. Before engine startup, set custom user directory and process-local APPDATA; runtime printed `.../userdata-base/ArcanaCamera-T079-isolated`. Production save directory was not used. Long initial asset import was stopped only for the verified temporary process; copied existing imported cache/UID cache into the disposable copy, without editing or deleting original caches. Omitted unused nested PixelFX/Emberline source projects and .blend sources from the copy. Examined rendered PNGs of spawn, side and rear obstructed views, remote Player movement and Skill Tree. Final rear view visibly fades sword and foreground helm instead of filling the screen. Images are under the isolated user-data directory and selected previews copied to the current visualization workspace.

**Failed attempts and diagnostics.** Fixed fixture Transform3D type inference and Player preserve_phase bool inference. Corrected an assertion that treated finite walls as infinite; replaced it with real sphere-overlap clearance. Headless OS mouse-capture assertions failed; rendered final checks pass. Dash assertion initially ran before FSM's deferred transition; waiting two physics frames verifies the actual dash and passes. The initial direct import had temporary GameManager autoload resolution errors; production autoloads load successfully in the gameplay runs. Full-copy gameplay still emits imported-resource UID fallback warnings and shutdown diagnostics (5 ObjectDB instances and 1 resource retained); attribution is unresolved, not claimed fixed. Final gameplay has no SCRIPT ERROR lines and all 20 assertions pass despite the exit diagnostics.

**Static/preservation:** `git diff --check` passes (line-ending notices only). Existing Dark Fairy scene diff preserved. Godot's already-open editor generated stable `.gd.uid` files for the two new test scripts; include those alongside the tests. No generator, original project.godot/input-map edit, commit, push or reviewer acceptance.

**Remaining verification:** manual mouse/animation feel, all map routes and tight parkour, actual carry/throw encounter, checkpoint death/respawn and stage transitions, actual ultimate/boss cutscene playback, alternate resolutions/hardware, and enemy directional sprite presentation under arbitrary orbit. These are not established by the fixtures. A direct isolated basement run also launched, but interactive Computer Use inspection could not proceed because app approval timed out; no manual UI playtest is claimed. Uncollidable geometry beyond the handled marker sprites cannot stop a physics-based camera. No valid unobstructed view can be guaranteed for a target embedded in solid geometry. T079 implementation and bounded automated/rendered checks are complete; checklist remains open for manual/reviewer acceptance.

Final cleanup observation: all temporary Godot test processes have exited; the user's original editor was not stopped. The direct basement smoke run logged 6 retained ObjectDB instances / 1 resource at shutdown (the integration harness logged 5 / 1); neither shutdown diagnostic is claimed resolved. The final original-workspace status contains only the listed T079 files plus the pre-existing Dark Fairy scene modification.

### T080 embedded Game mouse-look follow-up — 2026-11-13

- Report/conditions: user could not rotate with mouse in Godot's embedded Game Input view. Native click in the running original basement produced `CAM_DIAG focus=false window=true can=true owns=false mode=0 released=false`; this is runtime evidence that application-focus notifications left the rig's focus flag stale while the Game window itself had focus. Drag before the fix left the view unchanged.
- Implementation: `scenes/camera/camera_rig.gd` now samples its actual Window focus each process frame, recovers when an external owner changes captured mouse mode, and handles captured motion in `_input` so HUD Controls cannot consume it before the camera. Escape/release-click remain `_unhandled_input` for GUI priority. Temporary diagnostic print instrumentation was removed.
- Verification: rendered standalone camera fixture passes 106/106 including two new stale-focus/capture-recovery assertions; actual-basement fixture passes 23/23, including captured mouse motion through the production HUD, with real Player, scene, menu and Alt. Native physical mouse motion in the user's embedded Game after the final source change is NOT confirmed; an editor Game window was observed running and left untouched. T080 stays open for that direct interaction and Bao's feel/reviewer acceptance. Prior native experiments with automation after partial fixes were inconclusive; no false claim of end-to-end native success.

### T081 orbit-aware existing VFX — 2026-11-13

- Static finding: `BattleVFX._spawn_pixelfx` and `_spawn_pvfx` projected a world point to a CanvasLayer pixel only once. After a free orbit/zoom, active effects remained at that old pixel and their directional art kept the old screen angle and size. Status effects and dash dust already use billboarded Sprite3D; slash and ice shield/cast ring are excluded by the PixelFX skill.
- Implementation: `scenes/player/world_vfx_anchor.gd` projects the same fixed world cast/impact point each frame after CameraRig, updates screen position, projected extent and art angle, hides behind the camera and reveals on return. `scenes/player/battle_vfx.gd` instantiates it for existing PixelFX and PVFX overlays. Paused cinematic impact frame, emberline slash/ring, existing slash scene/sheets, shield/cast ring, sheet assets, effect timing/tint and skill damage remain unchanged. This is projection integration, not regenerated art; the existing PixelFX exports continue to supply frames.
- Verification: rendered projection fixture passes 6/6 (initial, yaw/pitch, size, behind/reappear). Actual-basement fixture passes 23/23, including real fire PixelFX charge and PVFX meteor sheets whose pixels shift with orbit and remain within 8 screen pixels of the current world projection during continuous camera/player updates. First VFX fixture failed because the point was at the camera's look-at center, so moving the camera could not change its screen pixel; fixture changed to an off-center point. First integration assertion assumed a >50 px orbit shift; actual constrained spawn geometry produced ~32.6 px with ~2.6 px transient projection residual, so threshold was corrected to >15 px. Final full-copy run has no parse/SCRIPT ERROR; previous UID fallback/shutdown 5 ObjectDB / 1 resource diagnostics remain unresolved. Manual multi-form combat and all-map visual acceptance remain open.
- Preservation: original editor-generated `.godot/uid_cache.bin` is modified and retained without hand editing. Pre-existing Dark Fairy scene diff retained. No original cache/save edits by test commands, generator, commit, push or teammate sign-off. `git diff --check` passes (line-ending notices only).

Late workspace observation (2026-11-13): while the Godot editor remained open, `project.godot` gained input-map changes (attack C replaced by left click; skill E added; ultimate R added), and an editor temporary `levels/level_1/basement_full.tscn~RF481dac7.TMP` appeared. Neither was edited, removed, tested as part of T080/T081, or included in the isolated copy; both are preserved as concurrent user/editor work. A Game view with 6 HP and Fire form was observed running, so no further native UI input was sent to avoid interfering with that session. The `.godot/uid_cache.bin` modified by the editor remains untouched.
## T082 pre-implementation boundary — aimed skills and Player VFX (2026-11-13)

User requests the ultimate sword behind the Player, a center reticle after holding skill for about 0.3 s, precise camera-center direction for relevant skills, and a slightly higher slash. Bao owns the Player combat/skill files. Quick taps will cast on key release so the hold can be distinguished; held release will use the camera sightline hit point. Keep slash and ice-shield implementations, map/enemy/save code, concurrent input-map/editor changes and tracked caches untouched. Acceptance and checks are recorded in T082; no reviewer agreement is asserted. Runtime verification pending.

### T082 implementation and verification

Player skill input now waits for release; a hold of 0.3 s displays a noninteractive viewport-center reticle. While held, a physics ray from the current Camera3D records the nearest solid hit (or a 45 m fallback). On release, the deferred FSM skill entry consumes that point. Directed ground skills use its horizontal bearing; thrown daggers use the full three-dimensional direction from their actual spawn point. Tap retains camera-relative movement/facing aim. Slot change, dialogue, pause, death, unusable skill and ultimate input cancel the reticle; the reticle layer processes during pause so menu opening clears it. The floating blade receives a temporary camera-relative position behind the Player during the cut-in pose and active ultimate glow, then restores its base position. Player-spawned slash visuals move up 0.2 m; slash/ice-shield resources and combat hitboxes are untouched.

Godot 4.7.2 Compatibility, isolated full basement copy with separate user-data path: clean changed-script import (no SCRIPT ERROR) and final rendered `tests/camera_gameplay_check.tscn` run, 36/36 assertions passed. Checks cover existing camera/HUD integration, quick press/release and cooldown, hold threshold/reticle, ray stop at a blocking body, projectile direction including vertical component, reticle cleanup, dialogue/pause cancellation without later cast, and blade camera-behind position plus restoration. Inspected rendered `camera-skill-aim-reticle.png` and `camera-ultimate-blade-behind.png` in the disposable user-data directory; reticle is centered and the visible sword does not cover the Player's face in the tested angle. A first run failed the aimed projectile assertion because FSM enters the state one frame later; the cast snapshot now persists until `PlayerSkillState._enter()` consumes it. A later pause check found the reticle visible after tree pause; the always-processing reticle layer now requests cancellation. The final run passes. `git diff --check` passes with only existing line-ending notices.

Native mouse and E-key feel inside the original embedded Game view, full cinematic motion, all element-specific directed skills, and slash height across camera angles remain NOT RUN. The fixture uses the existing U skill binding in its earlier copied input map, while the current working `project.godot` also binds E; that concurrent input-map edit was preserved and not included in T082. Existing disposable-copy UID fallback warnings and exit diagnostics (5 ObjectDB instances, 1 resource) remain unresolved. No reviewer acceptance or teammate sign-off is claimed; T082 remains open.

## T083 pre-implementation boundary — shoulder aim camera (2026-11-13)

User's image shows the Player on the left and an unobstructed centered crosshair. User requests a smaller reticle and changed camera/character framing during aim. Bao-owned camera/Player/reticle integration only; CameraRig's Stage API and normal orbit/collision behavior remain in scope for regression checks. Intended checks and acceptance are in T083. Preserve concurrent editor/input-map, Dark Fairy, cache and unrelated VFX changes. No reviewer agreement asserted before implementation.

### T083 implementation and rendered validation

The held-skill reticle is reduced from a 22-unit outer tick radius to 8.5 units, retaining its viewport-center position and mouse-ignore behavior. `Player` requests shoulder framing only after the 0.3 s threshold and clears it on release/cancellation. While aiming, it faces the horizontal sightline without changing movement input; the release refreshes the ray from the reframed Camera3D before the deferred skill cast. `CameraRig` interpolates toward a 5.8 m boom and a 2.0 m right-shoulder offset, scaled down at close zoom or obstruction; its existing sphere cast checks the complete offset lens motion. The saved orbit zoom remains unchanged, and framing interpolates back when aim ends. Stage target/Camera3D/snap APIs, input mappings, combat ranges and damage are unchanged.

**Rendered checks.** Godot 4.7.2 Compatibility, isolated minimal rig fixture: 115/115 assertions passed, including normal orbit/collision regressions, shoulder offset, Player-left projection at multiple yaw angles, visibility at minimum zoom, lateral-wall lens clearance and framing restoration. Isolated full-basement/Player fixture: 40/40 assertions passed, including quick tap retaining normal view, held camera shift, Player left of reticle, collision-limited center ray, aimed projectile direction and normal framing after release; earlier dialogue/pause and ult checks also pass. Inspected final `camera-skill-aim-reticle.png`: smaller reticle at screen center, Player visibly left with a clear view through the crosshair. No SCRIPT ERROR in final runs; `git diff --check` passes with existing line-ending notices.

**Corrections and limits.** The first rig run found an untyped fixture projection variable; fixed. The first gameplay run used an overly strict blend threshold immediately after the 0.3 s trigger; the measured shoulder displacement already passed, and the assertion now checks the in-progress transition. Native embedded Game input feel, full-map obstruction situations, the visual composition at all aspect ratios and Bao reviewer acceptance remain NOT RUN. Existing disposable-copy UID fallback and shutdown retained-object/resource diagnostics remain unresolved. T083 stays open; no reviewer sign-off is claimed.
## T084 — visible Skill Tree cursor and implicit camera-center skill targeting (2026-11-13)

User authorizes showing the hidden cursor in the skill menu and using a hidden mouse-look target for every directional skill. T084 scope/acceptance were recorded before implementation; Bao-owned Player/camera/Skill Tree integration only. Existing dirty map, Dark Fairy, input-map, effect assets and tracked caches were preserved; no teammate approval is claimed.

Static diagnosis: Skill Tree paused gameplay without explicitly setting visible mouse mode; CameraRig restored its pre-capture mode, which could be HIDDEN. Quick skill release set the camera-point snapshot only for held aim; `get_skill_aim_direction()` otherwise preferred movement/facing. Skill Tree now explicitly shows the cursor throughout opening/open/closing, restores the prior mode when it finishes/cleans up, and CameraRig forces VISIBLE while paused. A recaptured cursor cannot become its own restore mode. Quick and held release both snapshot the camera-center ray. Without a snapshot the common skill direction helper also uses that implicit center ray, covering directed active skills and ult presentation. Ground directions flatten the target bearing (with camera-forward fallback for a ground hit behind the Player); thrown projectiles aim in 3D from their actual spawn. The visible reticle/shoulder threshold stays 0.3 s, and ordinary gameplay adds no visible reticle. Existing area/self-centered skill mechanics remain intact.

Godot 4.7.2 Compatibility rendered fixtures: isolated camera 115/115 checks pass; actual-basement/Player/HUD/Skill Tree integration 42/42 pass. Tests explicitly start menu opening from HIDDEN mouse mode and require VISIBLE during opening and after animation, verify movement-independent camera bearing and quick projectile direction with the actor facing opposite the view while lateral input is held; held aiming, camera obstruction, menu close, pause/dialogue cleanup and blade pose regressions pass. Final logs contain no SCRIPT ERROR; existing full-copy UID fallback and shutdown retained-object/resource diagnostics remain unresolved. `git diff --check` passes with existing line-ending notices.

Native cursor display inside the original embedded Game window, every individual elemental combat/ult scenario and Bao visual acceptance remain NOT RUN. Fixtures use U from the earlier copied input map; current E binding was preserved. No commit/push or reviewer agreement is claimed. Source files had Windows memory mappings preventing truncation/replacement; scoped edits were written in place and exact content verified, and the temporary replacement file was removed.


## Whole-project audit refresh — 2026-11-13 / HEAD 42471e4c

This cumulative append supersedes earlier present-tense statements only within the tested
scope; prior evidence/history remains. No game source, scenes, input, vendor assets or
tracked caches were changed. No task checkboxes or teammate agreement were added.

The definitive current run matrix, engine/build, pre-autoload isolation probe, raw-log
locations, failures/harness corrections and NOT RUN manual checklist are in
[project-audit-validation.md](../../docs/project-audit-validation.md).
System/dependency and design-divergence map: [project-current-state.md](../../docs/project-current-state.md).

- Godot 4.7.2 official, current renderer Radeon 780M Compatibility. Disposable copy plus
  child APPDATA/custom directory verified with no-autoload probe before startup.
- 100 authored/integration scripts load/instantiate as scripts; full clean import timeout
  is BLOCKED, not passed. Current cached main startup succeeds. Four alternate/test scenes
  emit missing-ext-resource errors even though ResourceLoader may return non-null.
- Rig 115/115, VFX 6/6, actual-basement U 42/42 and E 42/42, settings 53/53 + restart 2/2,
  parry 7 cases. None is full manual gameplay/reviewer acceptance.
- Checkpoint fixtures 54/55 (BUG-010), interaction 25/26 (BUG-008), recovery 45/55
  (six obsolete camera equality expectations; four real B2 support failures).
- BUG-003 health bar visible in new B1/B2 captures; BUG-004 not reproduced at six old
  coordinates. Both retain history and broader retest status; no fix/closure attributed.
- New High findings: B2 continuation/respawn active_level=2 hides all floors (BUG-005),
  B1/B2 zero-point navigation (BUG-006), undamageable Pelican blocks B1 clear/chest (BUG-007).
  Medium: two HUDs (BUG-008), missing legacy scene resources (BUG-009).
- Actual B2 three-defeat→pickup/save/reload→clear gate→B3 arrival→B2 death recovery ran;
  recovered B2 visibility fails. B1 genuine all-zone chest flow blocked by Pelican.
  Unique reward API dedup passes; ordinary SP farm intent remains a design question.
- Direct API smoke for 12 active skill IDs and 8 ultimates runs without SCRIPT ERROR;
  actual per-skill target hits, visuals, native feel, boss fight and full route remain unverified.
  Renderer shader-init, UID fallback and retained objects/resources remain unresolved.

All original requirements and ownership boundaries remain. T071/T075 are recorded later
B3-gating decisions, not permission to rewrite unrelated sprint requirements. T085 source/
request existed before audit but task verification was missing; audit backfills an unchecked
status with actual test results. No game-fix implementation has started.


## T086 checkpoint approach / BUG-005 repair — 2026-11-13

Current user authorizes narrow implementation; prior audit-only stop and T044's integrated
B2→B3 connector assumption are superseded for the three-branch combined scene. Branch/HEAD
unchanged. Prior audit docs and pre-existing checkpoint local Y6 / relocated door scene
bytes preserved. No setup, generator, branch switch, commit/push or broad plan regeneration.

Rendered walking before F proves level1→2 selection in B2/LadderSpot_B2_B3, all floors
hidden while Player remains grounded on B2/World/Floor. At yaw0/zoom9, camera boom remains
8.94 and has no focus/lens/sightline obstruction; blackout is floor selection, not marker,
GameManager or F. Leaving connector restores B2. Startup guess independently selects absent
level2. Fix admits only connectors with existing endpoints and bounds startup fallback to
existing floor metadata. Camera collision, ceilings/colliders, gameplay and scene unchanged.

Spawn support was already corrected at entry: B2 parent5 + checkpoint6 + child0.2 =11.2,
support≈11.01. Historical audit12.2 is not current. Before/after identical updated recovery
fixture63/67→67/67 proves four visibility failures repaired, original support assertions pass
both. Camera assertion now matches rig focus_offset, not pre-orbit rig=Player equality.

Runtime evidence: rendered approach126/126, F/tint/feedback/idempotence/rank/Settings/jump/
B2 death/B3 death/payload32/32, actual connector wall-jump ascent/descent2/2, unchanged camera
suite115/115; five rendered startup/restart/explicit-scene processes each7/7 with synthetic
save bytes unchanged. Final headless trace126/18→126/0 includes marker paths, ceilings,
real supporting collider, connector, camera focus/boom obstruction and actual sightline.

See [audit validation](../../docs/project-audit-validation.md) T086 section for exact paths,
commands, snapshots and limitations. Initial temporary JSON numeric comparison failure is
retained as harness error, corrected via initial loaded sentinel; game save source unchanged.
Known UID fallback/exit retained-resource diagnostics remain. Independent BUG-010 fixture
still54/55; other audit bugs remain out of scope. Native F5/F6/mouse feel and Quan/Bao review
NOT RUN/pending. No full-task checkbox or independent reviewer sign-off is fabricated.

## T087 — B3 explicit checkpoint / door implementation (2026-11-13)

Current requirements supersede blanket B3 recovery prohibition; only marked new explicit-F
saves are supported. Exact old B1/B2 pairs retain their IDs without disk reset. See spec.md
supersession table and contracts/stage-progress.md for authoritative current policy.

| Executed case | Result |
| --- | --- |
| Rendered B2 clear→B3→B2; inert exit; F/Settings/tint/feedback; rank3; death; payload | PASSED 99/99 |
| Legacy/invalid/future B3 hold, supported path/UID cases, spoofed rank | PASSED 47/47 |
| Existing checkpoint save fixtures / B1/B2 recovery | PASSED 59/59 / 67/67 |
| T086 approach visibility regression | PASSED 126/126 |
| Nine fresh rendered main-entry processes, three B3 restart + four held + two legacy | PASSED all; saved bytes unchanged |
| Old unmarked/invalid B3 recovery itself | BLOCKED intentionally; no migration policy |
| Native F5/F6/mouse/focus feel, live boss interference, independent reviews | NOT RUN |

Repeated current F checks save bytes plus filesystem modified timestamp and no replay.
Existing support/visibility assertions retained; optional boss fixture guard matches incoming
combined scene without DarkFairy. First obsolete-fixture failure is retained, not game bug.
Detailed commands, isolated paths, raw logs, support coordinates, warnings and checklist:
[project audit validation T087](../../docs/project-audit-validation.md).
Godot4.7.2 official Compatibility/OpenGL; no clean import or full-project re-audit claimed.
T087 unchecked until remaining manual/review work; no teammate sign-off inferred.
## T085 Successful parry feedback (2026-11-13)

Implemented Bao-owned Player feedback at the successful parry transition, using exported pixelfx impacts/parry and the existing TomMusic Sword Parry 1 sound. White contact flash, expanding gold ring and sparks play at 1.5x speed, with contact in front toward the attacker and camera-projected world anchoring. Source pivot correction keeps the flash at the intended point. SFX uses the existing SFX/Master bus selection. No slash/ice-shield, map, enemy implementation or combat timing changes.

Verified: exported contact sheet inspected; pixelfx check passes without warnings. Godot 4.7.2 headless tests pass all seven existing enemy cases with preserved Player/enemy HP and enemy reactions. Added assertions pass for no feedback on entry or miss, exactly one burst and one audio node per success, duplicate rejection, expected contact point, projection after camera movement, and automatic visual/audio cleanup. Final test has no SCRIPT ERROR. Evidence: docs/validation/parry-feedback/test.log and import.log. Existing resource UID fallbacks and shutdown diagnostics (7 ObjectDB instances, 1 resource in use) remain unresolved.

Not verified: native rendered combat feel, listening to clang in-game, manual all-angle review or Bao acceptance. Facing fallback is implemented and statically inspected but not separately runtime-tested. Existing dirty tracked UID cache preserved; no reviewer sign-off or commit/push claimed.

## T086 Straight elemental orbs (2026-11-13)

Authorized Bao-owned Player change: neutral/fire/ice/lightning first throws now use a separate elemental orb scene, while wind uses the original returning dagger scene/script and return upgrades. Orbs retain initial 3D camera-center aim, 14m/s speed, 7m outbound range, wall query, existing outbound piercing, cooldowns, damage upgrades and per-element hit callback. They never return or hide the equipped blade. Neutral is white; fire orange, ice cyan, lightning yellow; each has animated corona and trail. Existing wind launch slashes remain wind-only. HUD and Skill Tree names/descriptions match the new projectiles; internal IDs remain compatible. Existing parry work preserved.

Verified: inspected all four exported contact sheets and in-engine rendered-orbs.png. Bundled pixelfx plasma-shot check passes without warnings. Godot 4.7.2 headless passes 73/73 checks; final Compatibility renderer fixture passes 77/77 including neutral and all elements, exact initial 3D aim, one-way flight independent of moving thrower, range expiry, wall expiry without return, blade and visual lifecycle, unchanged damage/status signal connections and cooldowns, wind return/catch/upgrade regression, and HUD/Skill Tree naming/icon load. Logs and screenshot are under docs/validation/elemental-orbs/. Final rendered run has no SCRIPT ERROR. git diff --check passes with line-ending notices.

Limitations: native full-basement input/combat feel, collision in all map locations and manually observing actual per-enemy burn/slow/stun remain NOT RUN; inherited hit shape and callbacks are retained. Existing invalid UID fallback warnings and shutdown retained-object/resource diagnostics persist (final rendered run: 3 instances, 1 resource). Early fixture load-order/typed-array setup errors were corrected. Existing tracked UID cache remains dirty and was never manually reset. No reviewer approval, full feature acceptance or commit/push is claimed.

## T087 Raised aim and depth-tested orb presentation (2026-11-13)

The user reports skill art over the Player and requests a slightly higher default aim point. Orb visual helper now creates a depth-tested AnimatedSprite3D using the same pixelfx sheets, frame timing, pivot and nearest filtering. The projectile updates its visual at camera-facing world position/orientation after camera processing, and owns its cleanup. This replaces the orb-only always-foreground CanvasLayer path. Other skills/VFX and wind returning dagger remain unchanged.

One shared normalized point (0.5, 0.42) controls both reticle drawing and Player camera ray, moving hidden/default and held aiming up by 8% of viewport height. Quick/held casts and 3D projectile target convergence retain the same target; camera rig/framing and gameplay/collision values remain intact.

Verified in Godot 4.7.2 Compatibility renderer: 89/89 fixture checks pass. Checks include three viewport sizes, ray/reticle agreement, quick/held target agreement, target above Player center, all four orb depth flags, rendered unobstructed core and foreground-geometry core occlusion, plus previous route/flight/range/wall/callback/cooldown/cleanup and wind catch/upgrade checks. Inspected rendered-orbs.png (raised reticle), depth-open.png and depth-occlusion.png. Final evidence: docs/validation/elemental-orbs/raised-aim.log and raised-aim-errors.log. No SCRIPT ERROR; existing UID warnings and shutdown retained objects/resource remain. git diff --check passes with line-ending notices.

Pending: manual full-stage input/aim feel, all-angle Player overlap review, direct Player-silhouette pixel test and Bao acceptance. The actual geometry occlusion test passes; Player scene already writes depth via alpha cut. Full-basement camera fixture blocker now uses the raised ray but its isolated full run was not repeated. No reviewer agreement or commit/push claimed; existing tracked cache and earlier dirty work preserved.

## T093 F9 New Game input route (2026-11-13)

User reports pressing F9 still leaves B2 progress saved. Read-only inspection of the default `user://save.json` found `flags.b2_cleared = true`, checkpoint `b2_start`, and a save timestamp of 2026-11-13 20:42 local. `project.godot` binds `new_game` to physical F9. `GameManager._unhandled_input()` was the only F9 route; focused GUI can consume input before that callback, and the GameManager autoload uses inherited pause processing. `GameManager.new_game()` itself deletes the save, clears in-memory flags and reloads the first stage. The retained flag establishes that the reported F9 attempt did not complete that reset; the precise input interception was not reproduced in Godot.

Bao-owned `PauseMenu` is an always-processing autoload. Its `_input()` now handles one non-echo F9 press before GUI handling, marks it handled to avoid the GameManager fallback processing the same event, and calls the existing `GameManager.new_game()`. While key rebinding is active, F9 remains available for capture. No GameManager, SaveSystem, enemy, map or scene changes were made. Static event-route/source review and `git diff --check` completed. Godot gameplay/pause/rebinding input tests and native confirmation that a fresh B2 run spawns enemies remain NOT RUN; no reviewer agreement is claimed. The real user save was read only and not modified.

## EXP progression — 2026-11-17

User-authorized Player progression implemented. Detailed scope/results: `docs/exp-progression-2026-11-17.md`. Isolated Godot 4.7.2 headless/rendered each 48/48; actual B2/B3 checkpoint/scene/death/save persistence 20/20. Existing B3 walking fixture passes new three-kill 60 EXP contract but fails to reach B2 door, then times out; causality unknown without baseline, full suite remains incomplete. Vendor UID/shutdown diagnostics retained. No real saves/cache/generator changes, commit/push or independent sign-off.

## Inventory / offhand resonance / enchant — 2026-11-17

User authorized inventory with four named slots, ranged offhand and skill-1 elemental upgrade, matching elemental skill buffs, SP enchanting and P test menu; then confirmed prototype archetypes/enchant pool and temporary tuning. See docs/inventory-enchant-2026-11-17.md for exact rules, review boundary, tests, failed-history diagnosis and remaining manual/review limitations.

Godot 4.7.2 isolated custom user directory: final headless/rendered inventory fixture 120/120 each, actual B2/B3 transition/checkpoint/death/save fixture 19/19, existing orb fixture 87/87, temporary current-SP-name-adapted EXP fixture 48/48. Inventory data/art/stats/SP survive recovery; no real saves/source cache writes. Screenshots inspected. Vendor UID fallbacks and exit resource warnings retained. These passes do not close broader map/traversal/boss/full-campaign acceptance or imply teammate agreement. No commit/push.

Inventory correction C02 (2026-11-17): isolated Godot headless/rendered each 176/176; inspected actual bow/knife cast screenshots. Offhand visible for neutral and every elemental skill-1 route, balanced on interruption/exit; ordinary projectile/upgrade logic retained. C01 fixed pairing/catalog compatibility NOT implemented pending user's type-to-element mapping. Vendor UID and exit warnings remain; incoming .godot/uid_cache.bin remains dirty and untouched. Native full-map review and independent approval not claimed.

Inventory correction C01/C03 (2026-11-17): exact user element map applied, no intrinsic offhand affinity, one catalog entry per type, narrow legacy ID migration and retained inactive offhand elemental ranks/SP ledger. Final isolated headless/rendered 213/213 each and actual stage/death/save flow 19/19; rendered fixed catalog and cast weapon inspected. Source cache and real saves untouched. Initial missing inactive-rank restore initialization corrected; historical failure retained. Vendor/exit warnings, native full-map feel and independent review remain unresolved; no teammate acceptance.

UI polish / reported boss compile error U01-U04 (2026-11-17): final isolated headless and Compatibility-rendered 217/217, final logs no SCRIPT ERROR. Actual Dark Fairy load, one five-unit pickup on repeated defeat, exactly 100 EXP and no duplicate collection verified; only stale reward API call changed. Inventory skin/grid actions/pause and prior 213 checks pass; normal/square/equipment/enchant/cheat images inspected. Initial skin-loop inference error corrected; initial 211 output excluded from acceptance. Existing vendor UID/exit 16 objects/1 resource warnings retained; full fight/native feel and teammate review not claimed. See feature/UI asset guide and cumulative record.

E01-E04 atlas/starter/enchant correction (2026-11-17): final isolated headless and Compatibility-rendered 236/236 (no SCRIPT ERROR); actual B2/B3 checkpoint/death/save fixture 19/19. Correct outlined atlas regions, exact legacy Blade world texture/size, transaction/restore three-type limit, 50 unbounded Blade purchases/high-rank save retention and old overflow/missing-starter compatibility verified. Final equipment/original Blade/enchant screenshots inspected. Source atlases/cache/real saves unchanged by tools; original dirty cache preserved. Vendor UID/exit warnings and native balance/full-map review remain pending; no teammate sign-off or commit/push.

## W01 — weapon-specific attacks (2026-11-17)

Before implementation: read constitution plus inventory feature tasks/evidence and verified baseline. Existing `scenes/player/states/attack.gd` runs the shared `attack_<direction>` animation, hides the actual equipped weapon and opens one hitbox for the state duration. `floating_blade.gd` keeps the weapon in its separate idle float. Existing Player callback applies weapon damage/crit/enchant/rage; sword/axe/etc. catalog identity and element art already exist. Current attack is J or mouse-left; charge is interpreted as hold 0.4s then release, max 1.0s. User-requested combo/charge rules are in feature doc W01-W04.

Implementation started: pending. Static source review only; no new attack result or acceptance claimed. Required runtime work before behavior is verified: combo hit-count/rearm, weapon travel/restoration including interruption, charged input threshold, nearest target and wall/collision-limited spear/dagger dash, launch/return, existing HP/status/projectile regression, rendered weapon visibility. Do not expand into enemy AI, maps, drops, skill tree, slash sheets, ice shield or unrelated suite checkboxes. No teammate sign-off.

W01 implementation update: source and assets have been added. Static inspection confirms scene binding to the new state, expected combo-count/charge code paths, cleanup, no edits to the old slash/ice-shield files, and correct nested asset paths. JSON parse succeeded for four sheets (24/24/30/97 frames; 30fps metadata). Contact sheets were viewed. Scoped `git diff --check` passed on modified scene and docs with line-ending notices. No engine load, runtime fixture, or collision/playtest was run. W05 remains unverified: the actual hand flight/body silhouette, hitbox re-entry/count, charged thresholds, nearest target choice, physical wall stop, knockback/launch, dagger return, status/projectile regression and rendered palette/depth still need Godot review. No acceptance or reviewer sign-off claimed.

W01 parser correction: the reported undefined `_ease_out` helper is now present in `weapon_attack.gd`. Disposable Godot 4.7.2 headless load of `res://scenes/player/player.tscn` for two frames exited0 with no `SCRIPT ERROR`/`Parse Error`; this confirms compilation/resource load after the helper fix, not attack behavior or movement. Pre-existing vendor UID fallbacks and 3 ObjectDB /1 resource shutdown notices remained. No original source cache/real save touched.

W06 verification (2026-11-17): final Godot4.7.2 Compatibility rendered actual Player FSM on floor passes98/98, no script/parse errors. Checks cover all click-stage sequences, no automatic continuation, single early input buffer, finisher wrap/timeout reset, held charge selection, interrupt cleanup, actual HurtArea event counts1→2 with no automatic3, and36 facing/camera/source-tip orientation comparisons. Selected final weapon contact/prepare frames inspected; original baked attack dagger is excluded by empty-hand body pose. Existing UID fallbacks remain. Input fixture/snapshots/logs: tests/weapon_combo_check.gd/.tscn and docs/validation/weapon-combo. Source cache and real saves untouched. Full-map feel/all charge collision-target-return cases and independent owner review not run; no full-task acceptance.

W06 authoritative final result: Compatibility-rendered103/103 after adding explicit loads for all five weapon FX. Earlier98/98 lacked a pre-existing spear-sweep PNG in the disposable copy; import repaired only that copy, preimport logs retained. Final log has no missing-resource/script/parse error; UID fallbacks and16 ObjectDB /1 resource exit diagnostics persist. Evidence docs/validation/weapon-combo; details in inventory feature record.

W07 (2026-11-17): user supersedes carry pose with original Player attack animation, Player-over-active-weapon depth, airborne dagger out/back and axe jump/downward slam. Bao Player combat/presentation; no enemy AI/map changes. Godot4.7.2 Compatibility rendered tests/weapon_combo_check.tscn final129/129 (no script/parse/missing-resource error). Actual Player physics on floor, wall/ceiling blocks, dagger peak/outward/return, axe ground-only damage, stationary actual crab hurt callbacks, attack body frame, downward streak/upright shock, interruption/fall restoration, main/offhand depth both camera projections and pixel silhouette occlusion covered. W06 click/input/hit/direction cases retained. docs/validation/weapon-aerial has logs/screenshots; inspected air/impact/Player-over-weapon frames. Initial126/127 was fixture spawn relocation carrying Player before charge, corrected by placing target before tree entry; short headless runs incomplete; rendered128 predates final assertions. Existing UID fallbacks,24 ObjectDB/1 resource exit diagnostics persist. Native full-map feel/balance/independent review remain unrun, no teammate acceptance or unrelated task closure.

## C01–C05 — F2 camera views (2026-11-19)
Godot4.7.2 Compatibility in disposable ArcanaViews copies: camera139/139 and actual basement/Player/HUD29/29 pass. Startup/cycle, collision regression, mouse ownership, FPS eye/strafe/reticle/body restoration, Top-down pointer/skill snapshot, and pause/dialogue/death gates exercised. Final screenshots reviewed after UI scaling and correct late-frame marker fading. Full-map manual traversal/feel and independent acceptance pending. Vendor UID/case warnings and Player shutdown3 ObjectDB/1 resource diagnostics remain; no source cache/real save modified. Exact scope, checks, initial failed-history and evidence: docs/camera-views-2026-11-19.md and docs/validation/camera-views/. No teammate sign-off or unrelated task closure.

C06 camera freed-instance regression (2026-11-19): isolated Godot4.7.2 Compatibility fixture reproduced reported typed-loop assignment errors before fix (147 checks,5 failures). Fixed147/147 with no script errors/empty stderr; expired FPS visuals tested through pause, view switch and rig removal, plus expired third-person blade and checkpoint marker cleanup. Logs: docs/validation/camera-views/freed-*.log. No new full-basement/manual acceptance or reviewer agreement; source cache and real saves preserved.

C07/C08 (2026-11-20): isolated Godot4.7.2 Compatibility camera154/154 and actual Player/HUD67/67 PASS, no script/parse errors. Fixed angle/distance under obstruction, cursor projection, complete regular weapon combos, live combat grip/tip correspondence, original4 Blade frames including charged attack, and menu/equipment/view cleanup covered. Test-platform Top-down screen-anchor drift0.0px over45 samples. Representative final screenshots inspected. Known vendor/exit diagnostics and manual all-map/charge-contact/reviewer limitations remain explicit in docs/camera-views-2026-11-19.md. Evidence docs/validation/camera-views/c07-c08/. No source engine run/real saves, teammate sign-off or unrelated acceptance.

C09 (2026-11-20): isolated rendered Godot4.7.2 floor + actual Player/weapon pose methods reproduce48/177 failures before fix; after fix177/177 pass. Down axe y0.900→-0.036 before, y0.900 retained after; down dagger0.996→-0.056 before, native height retained after. Source depth correction retains nearest front depth only in Top-down; projected grip, up/back occlusion, terrain depth flags and TPS offset checks pass. Four after images inspected against before. Initial unentered-FSM fixture excluded from acceptance. Evidence docs/validation/camera-views/c09-depth/. Known vendor/exit diagnostics, full-map/later-combo/charged-pose/manual review limits retained; no teammate acceptance.

## M02 menu T / ultimate pause — 2026-11-21
Isolated Godot4.7.2 Compatibility actual Player + its existing HUD SkillTree + camera/floor and real cinematic/ultimate callbacks:65/65 PASS using tests/skill_tree_menu_check.tscn -- --pause-only. Injected skill_tree/ui_cancel actions cover8 ultimates,15 T presses within each cinematic, gameplay completion/rage consumption/cooldown, ordinary reversal, external pause preservation, abort, book/cinematic mutual exclusion, reopening and teardown. Before-incomplete logs reproduce low-HP healing and stranded pause for wind/fire/ice; this old disposable copy lacked some resources and hit frame limit, so NOT a complete baseline pass. Initial-timing run63/65 sampled WindUltimate before3.6s elapsed and queued input after teardown; fixture corrected to wait full duration/drain input. Final65/65, no parse/script/missing-resource/autoload error. Existing vendor/Dialogic UID warnings and shutdown3 ObjectDB/1 resource diagnostics remain. Fresh disposable import stopped during unrelated FBX imports after necessary fixture resources were available; final runtime ran after stopping importer. Source caches and real save untouched. Evidence docs/validation/skill-tree-menu. M01 HP assertions deliberately excluded pending user's char_heal replacement/refund choice; no health fix claimed. Native full-map/manual review not run; no owner acceptance or commit/push.

## M01/M02 final timed regeneration — 2026-11-21
User-approved1HP every60/40/20 gameplay seconds at ranks1/2/3 implemented. Godot4.7.2 Compatibility on actual Player/HUD/cinematic isolated scene:99/99 PASS, full default fixture (no exclusions). Controlled elapsed-delta checks prove all three approved intervals, no early recovery, HP cap, no full-health credit, no-rank/death exclusion, rank-change/removal reset, instant full-heal boundary, external pause/resume and unchanged SP/purchase history. Real physics runs19.5 active seconds at rank3 with no heal, opens T for2s crossing wall-clock20s without heal, then closes and recovers1HP after the remaining active time. Opening/spamming T no longer heals. All8 ultimate cinematics freeze regen and complete without stranded pause, then menu reuse/abort/teardown pass. Evidence: docs/validation/skill-tree-menu/regen-final.log and regen-final-errors.log. No script/parse/resource-load/autoload failure; inherited vendor/Dialogic UID warnings and shutdown3 ObjectDB/1 resource diagnostics persist. Source cache/real saves untouched; existing isolated imports reused. Native full-map/manual feel and independent acceptance not run; no commit/push. Earlier M01 pending/failing descriptions are superseded by this full99/99 result.

## Dash priority / B3 camera — 2026-11-21
Static implementation complete; runtime behavior unverified. `weapon_attack.gd` routes eligible dash before attack phase updates and buffered-click capture, so state exit clears attack through established cleanup. B3 CameraRig overrides only its scene instance to distance10.8/focus1.1, versus shared defaults12/1.3. Required Godot playtest: initiate dash during regular attack, charge, combo/link and hit phase, check immediate dash and hit/weapon cleanup; enter B3, traverse beneath lowest ceiling, inspect framing/occlusion and transitions. Not run. Scope/file-level record in docs/project-changes. No approval or gameplay acceptance inferred.

## Rune charms and flat skill bonuses — 2026-11-21 (before implementation)
User approved six rune charms (no new armor), renamed baseline charm, flat weapon-match skill damage and Ice Shield one-hit behavior. The exact numeric conversion table and owners/acceptance/integration boundary are recorded in tasks.md. Scope covers ItemCatalog/InventoryState, Player skill/status/damage/death hooks, Skill Tree descriptions, and GameManager's existing respawn registration only. No enemy, map, potion crafting/loot, slash, ice-shield FX, or SaveSystem schema work. Planned checks: icon/catalog/equip and old charm restore; all six effect boundaries; single-hit shield; flat matching-weapon damage; approved rank/value conversions; death flow with and without Brimstone; `git diff --check`. No runtime verification or test run at implementation start.

## Rune charms and flat skill bonuses — 2026-11-21 (implementation status)
Implemented: six rune charm definitions in ItemCatalog (existing P grant-all reaches them); Bùa ma pháp retains ID `charm`, uses arcane rune, and gives +1 elemental skill damage. Amber adds +1 damage to each fire burn tick; Binding adds 1 second to slow/freeze durations; Blood attempts a 10% +1 HP heal on weapon/skill hit; Brimstone is consumed on respawn and restores 2 HP; Sky adds 0.5 movement speed; Time and Haste reduce active/ultimate cooldown by fixed seconds. Matching main-hand resonance adds 2 skill damage; resonance enchant adds +1/rank and affliction adds +1 status second/rank. Ice Shield absorbs the entire first incoming hit. Approved percentage conversions for Gale, Shatter, Searing Knife, Parry, Dash, Speed and Fire self-costs are in place and displayed as fixed amounts.
Static checks: seven rune image paths exist; scoped `git diff --check` passed; old listed percentage formulas/descriptions no longer matched the search. No Godot parser, runtime, manual playtest or tests were run. Therefore code integration is implemented but behavior is not runtime-verified; especially Brimstone needs the required death/respawn playtest. User approval was explicit for the recorded numeric mappings; no independent teammate/reviewer acceptance is inferred.
Open: Hồi Phong still lacks behavior call sites; only its text is converted to +1m/+1m/s. Wind ultimate still multiplies movement speed by 1.5. The attempted change to +3m/s was rejected by automatic review as outside the approved conversions and was not retried. Other critical probabilities intentionally remain percentages. No armor, drop, crafting, maps, enemies, save schema, real saves, cache cleanup, generators, commit or push changed.

## Dash key and action cancel — 2026-11-21 (before implementation)
Owner Bao Player/input states, input settings and HUD key help. Project InputMap already has Q for quick item and Shift for dash, but saved user bindings may preserve the formerly reversed default, so migrate only that exact pair. Set Player base dash cooldown to2 seconds, keeping prior rank-based fixed reduction. Use existing DashState to cancel weapon attack and skill cast; keep stamina cost and spent skill cooldown. Inspect project/settings input, PlayerState and state cleanup, HUD hint, then `git diff --check`. No tests/playtest run at implementation start.

## Dash key and cancel — implementation status (2026-11-21)
Implemented the old swapped-default migration in GameSettings while preserving all other slots, set Player base dash cooldown to2.0s, call dash from the active skill cast state, and clear skill aim when a dash begins. Attack-state dash priority was already present and remains. Skill cooldown is initialized at cast entry and is intentionally not refunded on interruption; DashState still handles stamina, invulnerability, movement and cooldown.
Static checks: source review confirms InputMap already defaults Q to quick item and Shift to dash; changed scripts implement exact old-pair migration,2s base and SkillState dash-before-timer. Scoped `git diff --check` passed. No Godot/runtime/input test performed; cleanup and timer acceptance remain unverified. Existing user input settings outside workspace were not edited. No other system or reviewer acceptance claimed.
## EnemyPlacement — fixed encounters and clear portals (2026-11-22)

Godot 4.7.2 Compatibility, rendered on a disposable project copy with a unique custom user directory. Final sweep passed **76/76** checks and exited 0. The scene-tree fixture opened split B1 and exercised the existing enemies' damage handlers and death animations. Injected F input through the viewport used the production InteractiveArea3D and GameManager transition callbacks.

| Check | Result |
| --- | --- |
| Authored roster and placement support | B1 8, B2 5 including Undead Executioner, B3 one Dark Fairy. Physics rays hit world floor at each authored enemy, forward portal, and arrival tested. |
| Clear gate | Hidden and inactive on entry and through partial clear. B3 remained closed during Dark Fairy's phase change. Final death completed before each portal opened. |
| Navigation through exits | F before clear was inert. F after clear reached split B2, B3, and Castle in order. Return door F interactions reached split B2 and B1. |
| Persistence | Cleared in-memory flags, reloaded the isolated save, and verified three split clear flags and the existing B2 prerequisite. Revisited all three floors with the portals open and no authored enemies restored. |

The first probe was excluded because its directory filter omitted the real KayKit vendor dependency, its save directory was unwritable, and it counted dropped pickups as enemies. A corrected rendered forward/re-entry sweep passed 68/68, then the final sweep also covered save reads and return doors. The engine emitted vendor UID fallbacks and retained-resource diagnostics at shutdown (one resource still in use); no final gameplay script/parse error appeared. Manual combat balance and full on-foot traversal were not exercised. Existing checkpoint recovery and independent owner review were outside the tested acceptance boundary.

### B3 exit rollback follow-up (2026-11-22)

Restored the original Door_b3_exit node block verbatim from the branch baseline. No forward portal instance or Castle target remains in B3. Rendered Godot 4.7.2 Compatibility in the disposable copy passed 77/77 checks and exited 0. F at the restored exit stayed in B3 before and after Dark Fairy's defeat. Defeat still saved B3 clear, and the B1/B2 forward portals, saved clear state, and both reverse doors passed. The retained-resource shutdown diagnostic persisted. This result supersedes the previous B3-to-Castle check.

## Garden / basement verification — 2026-11-23

G01–G03 implemented and focused runtime checks pass. G04 focused verification complete;
full manual traversal/combat and independent owner review remain NOT RUN. This does not
close unrelated basement tasks or claim teammate agreement.

Environment: Godot 4.7.2 official, Compatibility renderer (ANGLE / AMD Radeon 780M),
disposable C:/Users/BaoHo/AppData/Local/Temp/ArcanaGarden-20261123,
custom user directory ArcanaPlacement-Garden-20261123. Command:
`Godot_v4.7.2-stable_win64_console.exe --path <copy> --rendering-method gl_compatibility --script res://tests/basement_clear_portal_check.gd -- --isolated-copy`.
Final check5: **127/127 PASS, exit 0**, no gameplay SCRIPT ERROR, parse failure or
Dialogic expression error. Source cache and real save/settings were not used for writes.

### G01 — Garden / basement route
PASSED: real viewport F through split B1 → B2 → B3 → garden, garden → B3 → B2 → B1.
B3 exit refuses travel before boss clear and opens after terminal defeat. Physics rays
confirm authored enemy positions, entrances/exits, garden arrival, merchant and all eight
plot centers have floor support. Existing reverse route and saved clear flags pass.
Player positioning is controlled by the fixture; complete on-foot traversal is NOT RUN.

### G02 — Revisit persistence
PASSED: Executioner terminal signal is saved before death animation cleanup, then actual
scene transition to B1, save reload, and B2 revisit leave exactly four living encounters.
Ordinary-enemy death persists through a second revisit, leaving three living encounters;
partial clear keeps the forward portal closed. Full B1/B2 clears persist. Dark Fairy phase
change does not clear B3; final defeat persists after garden return and save reload.
Only confirmed authored defeat keys persist; ongoing health/AI state is not saved. Runtime
spawned summons and unrelated infinite-spawn zones are outside this adapter's scope.

### G03 — Garden farming and merchant
PASSED: eight existing plots bind to the controller; F opens greeting and locks Player,
Bắt chuyện / Mua bán / Rời đi are present, F activates focused chat, shop buttons buy the
four existing crops for exactly four SP, zero SP rejects further purchases. F at soil
opens planting, consumes one seed and uses a garden-prefixed plot key. Early harvest is
rejected; timestamp advanced by the fixture past 90 seconds survives actual save and
scene reload; F harvest grants one produce and repeated harvest grants nothing. Leaving
releases Player/menu. The legacy sketch scene retains default node path/unprefixed keys
by source inspection; full sketch runtime regression was not run.

### G04 — Dialogue and viewport
PASSED: greeting, chat and shop panel bounds in 480×270, 1280×720, 800×800 and 540×960;
actual Dialogic compact style selected and textbox bounds pass at those four sizes.
1280×720 screenshots of shop and ordinary dialogue were inspected: readable content,
inside viewport. Shop has bounded scrolling and back navigation. Existing Dialogic
choice offset was moved above the textbox; individual choice geometry was not separately
asserted. Full physical-mouse/controller UX and all other timelines remain unverified.

Evidence: docs/validation/garden-basement-2026-11-23/runtime.log,
runtime-diagnostics.log, garden-shop.png, garden-dialogue.png.
Initial test-copy failure: older reusable copy lacked KayKit OBJ dependencies; source
vendor files copied into disposable project and reimported, without source generators.
An interim test launched before import completion still had missing UID/dependency
errors and is not counted. A fixture directly referencing Conversation before autoload
initialization caused a compile failure; changed to runtime load. An interim mushroom
sample timeline exposed its pre-existing escaped-condition parse error; final dialogue
check uses the production door_locked timeline, leaving that unrelated sample unchanged.
Vendor reimport also reports unused Medieval OBJ author-machine texture paths; final
exercised scenes load successfully. Final runtime diagnostics retain vendor UID text-path
fallbacks, 19 ObjectDB instances and one retained resource on shutdown; no claim these
project-wide cleanup issues are repaired. No independent reviewer acceptance/commit/push.

## G05/G06/G07 — Garden cells, Dialogic and speaker portraits (2026-11-24)
Implemented and focused rendered verification passed157/157, exit0. Godot4.7.2 Compatibility
in the previously recorded isolated ArcanaGarden copy/custom save directory. Same invocation
as G01–G04; final output portraits3.log, diagnostics portraits3-errors.log.

### G05 — Expanded marked cells
PASSED:32 actual cells, each with label and physics floor support; closest-cell F planting;
new cell independent of legacy garden/Plot_01 crop; both timestamps survive actual save and
stage reload; early harvest rejected, mature harvest exactly once without clearing neighbor.
Overhead screenshot inspected: four groups around central path, expanded soil cells with
numbered markers. No floor/collision generator used. Full on-foot traversal remains unrun.

### G06 — Real Dialogic conversation
PASSED: F opens actual timeline with no custom greeting panel; actual Bắt chuyện/Mua bán/
Rời đi choice labels; chat returns to greeting; purchase handoff/insufficient SP/shop back/
leave/Escape cleanup; prior split-stage forward/reverse and boss-persistence regressions.
Textbox and all three choice bounds pass480x270,1280x720,800x800,540x960. Dialogic canvas105
renders above HUD. Previous interrupted revision4 had passed153/153; subsequent portrait
work extends that same suite. Full physical mouse/controller UX remains unrun.

### G07 — NPC and Player images
Root cause (static): both .dch portrait image overrides pointed at nonexistent
assets/dialog/characters PNGs. Implemented AtlasTextures from actual existing NPC/Player
sprite sheets. Added Foxy reply to the chat branch. PASSED: actual speaker-mode container
contains each character's expected visible AtlasTexture;1280x720 captures inspected after
portrait fade-in/frame draw: mushroom and Foxy appear inside portrait panel beside their
own dialogue text. NPC and Player swap with the active speaker. No new generated bitmap.
First test incorrectly queried joined-character API for speaker-only containers; fixture
corrected to inspect speaker containers. Initial capture preceded fade completion; final
fixture waits90 physics frames and frame_post_draw. No gameplay fix needed for these
fixture issues. Final run has no SCRIPT ERROR/parse/Dialogue expression failure; inherited
vendor UID text-path warnings,19 ObjectDB instances and1 retained resource remain at exit.
Evidence: docs/validation/garden-portraits-2026-11-24/runtime.log, runtime-diagnostics.log,
npc-portrait.png, player-portrait.png, garden-cells.png. Source caches/real saves unchanged
by the isolated test; incoming editor/cache changes retained. Independent owner acceptance
not supplied; no commit or push. Unrelated basement checkboxes remain unchanged.

### G08 — Remove cell numbers (2026-11-24)
Implemented user-requested label-only correction in garden.tscn:32 numeric Label3D blocks removed;32 soil cells with existing stable names, positions/resources preserved. Existing regression assertion updated to require no Label child. Static count checks and git diff --check pass; runtime NOT RUN for this reversible presentation change. Prior157/157 remains historical, not a new run. No independent review, commit/push; incoming work preserved.


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
## G09–G12 — Milestone 1 Garden potion brewing (2026-11-25)

Tested working tree based on `features/BasementandGarden @ 1e410e4f`, including the
incoming Garden scene. Godot 4.7.2 (ed1daf0bf), Compatibility renderer via ANGLE.
The three final rendered runs exited 0. Runs used a copied project and dedicated
`user://` directories. The source Garden and tracked UID cache match their incoming
SHA-256 hashes.

| Route and case | Status | Observation |
| --- | --- | --- |
| Direct Garden, seed shop | PASSED | F opens the actual merchant. Mua bán buys three cucumber and two pineapple seeds for five SP. Esc returns to dialogue. |
| Direct Garden, plant and harvest | PASSED | F selects and plants individual cells. The fixture ages the timestamps; ripe F harvest gives two of each crop. B → Vật phẩm shows the same quantities. |
| Direct Garden, dialogue to Brew | PASSED | Actual Điều chế Thuốc choice beside Mua bán. Player remains locked across handoff. Up/Down moves focus, F confirms, Esc and Đóng both return to gameplay. |
| Direct Garden, missing ingredients | PASSED | Seeds alone, no produce after exchange and one missing crop each keep the control disabled. Invoking a disabled confirmation leaves inventory unchanged. |
| Direct Garden, recipe/art | PASSED | Panel shows owned / required for both crops and one Bình hồi phục, with the first 32×32 frame of the specified great health potion sheet. Rendered screenshot inspected. |
| Direct Garden, repeat and save | PASSED | Two available pairs produce exactly two potions. A third confirmation made in the same function call spends nothing. Counts and disabled state update immediately. Disk contains both final produce counts and the potion stack. Source inspection shows one existing save call per successful Brew. |
| Direct Garden, next harvest | PASSED | A third cucumber harvested after brewing restores cucumber to one and leaves pineapple at zero, both in the controller and on disk. |
| Direct Garden, B → Tiêu hao and Q | PASSED | The potion is visible and assignable to the existing quick slot. Physical Q heals to full and consumes one. Full HP consumes none and displays no new indicator. The upper-right icon appears and hides after roughly one second. Rendered screenshot inspected. |
| Direct Garden, physical 2 binding | PASSED | Physical 2 selects `active_skill_2` without consuming a potion. |
| Physical 2 as potion shortcut | BLOCKED | Conflicts with the active skill binding. G12 awaits a decision about that binding. |
| Continue from the configured main scene | PASSED | A new process loads the earlier isolated save via GameManager startup. Starting the configured main scene continues at `garden_start`, with one assigned potion and harvested counts 1 cucumber / 0 pineapple. |
| Legacy version-1 saves | PASSED | Synthetic payloads containing a potion without a quick key and with an existing `consumable` UID both load. The assigned potion works via Q. |
| Split B1 → B2 → B3 → Garden regression | PASSED | Existing F route fixture loads Garden through the boss-gated exit, verifies all four choices at 480×270, 1280×720, 800×800 and 540×960, and retests seed trade, chat, back, leave and farming. Both reverse routes also pass. |
| Full on-foot run from a fresh configured main scene | NOT RUN | Split route uses controlled positioning and encounter completion. Continue starts the configured main scene with a saved Garden checkpoint. |
| Manual physical input and legacy sketch playtest | NOT RUN | Test runner injects Godot keys and invokes UI actions. Sketch keeps three options by the Garden-only choice condition. |
| Disk-write failure / recovery | NOT RUN | SaveSystem v1 reports open failures to the log and provides no write result or rollback. Successful Brew uses the standard combined save, with no change to that contract. |

### Reproduction

Use a disposable copy with imported assets, enable `application/config/use_custom_user_dir`
and set `application/config/custom_user_dir_name` to a new name beginning with
`ArcanaPlacement-`. In PowerShell, use a dedicated writable APPDATA directory for the
test processes. Keep the same APPDATA directory for the first two commands. Use a
different one for the split route so it has its own save. Set `$godot` to the Godot 4.7.2
executable and `$copy` to the copied project.

```powershell
& $godot --path $copy --rendering-method gl_compatibility --resolution 1280x720 --script res://tests/basement_clear_portal_check.gd -- --isolated-copy --brew-only
& $godot --path $copy --rendering-method gl_compatibility --resolution 1280x720 --script res://tests/basement_clear_portal_check.gd -- --isolated-copy --brew-continue
& $godot --path $copy --rendering-method gl_compatibility --resolution 1280x720 --script res://tests/basement_clear_portal_check.gd -- --isolated-copy
```

Direct Garden passed **33/33** (`brew-rendered-v4`), Continue and legacy passed **6/6**
(`continue-rendered-v4`), and split route passed **162/162** (`split-rendered-final`).
Local stdout, stderr and engine logs are in the ignored
`.godot/ArcanaBrew-20261125-73d194/` directory. Screenshots `brew-panel.png` and
`brew-used.png` are under `userdata/ArcanaPlacement-Brew-73d194/`. The final runs
have existing vendor UID fallbacks, ObjectDB leakage (3, 4 and 19 instances,
respectively) and one retained resource each on shutdown. No final gameplay script
or Dialogic expression errors were observed.

An early compile probe failed because the SceneTree fixture referenced the Player class
before autoload registration. The fixture now accesses the Player node at runtime.
The first rendered run exposed PauseMenu consuming Esc before the shared farm panel.
The panel now handles cancellation at the input phase. A subsequent rendered run
exposed a fixture timing error after closing Inventory; closing waits for two process
frames. The fixture now waits before sending the next gameplay input. All three
final runs above completed. Independent teammate review remains unrecorded.


## G13–G17 — Milestone 2 combat potions (2026-11-25)

Baseline was `features/BasementandGarden @ 1e410e4f` plus the existing Milestone 1
working tree. Lam reports verifying Milestone 1. The user confirms Bao's permission
for both combat points and chose to keep physical 2 on skill slot 2 for this milestone.

Godot 4.7.2 (ed1daf0bf), Compatibility via ANGLE, isolated save directories.
Final rendered totals are **43/43** direct Garden/combat, **2/2** Milestone 2 Continue,
**33/33** healing regression and **6/6** healing Continue/legacy. All exited 0.

| Case | Status | Evidence |
| --- | --- | --- |
| Garden Hộ mệnh and Cường lực recipes | PASSED | Actual NPC and Brew panel accept broccoli + spinach or broccoli + pineapple, each at one of each crop for one potion. Each row shows live ownership and its requested 32×32 frame. |
| Brew confirm, count refresh and exhaustion | PASSED | Rapid confirmation against shared broccoli stock caps both stacks at four. Shared recipe counts update immediately and disk contains the new produce and both stacks. Keyboard focus skips disabled recipes, follows the enabled recipes and reaches Đóng. |
| B and Q for each new potion | PASSED | Actual B → Tiêu hao buttons assign each item. Q takes exactly one bottle on success, including for Hộ mệnh at full HP. |
| Key 2, HUD and Inventory labels | PASSED | Q labels the consumable slot. Physical 2 selects skill slot 2 per the final user decision, with the weapon and potion counts retained. The earlier weapon-switch request is superseded. |
| Hộ mệnh allocation and ordinary mitigation | PASSED | 5 current HP yields a 3-point shield. Reuse after break at 3 current HP yields two points. A covered hit consumes only shield points. |
| Hộ mệnh with parry, immunity and Ice Shield | PASSED | The actual parry state and both immunity checks preserve potion shield. The existing Ice Shield gate consumes its one hit first. The fixture sets up Ice Shield directly. |
| Hộ mệnh overflow, break and timeout | PASSED | A 5-damage valid hit through a 3-point shield removes 2 HP. Break hides the shield gauge and badge while the strength badge remains. A fresh shield is present late in its eight-second window and expires on gameplay time. |
| Cường lực ordinary melee | PASSED | The same ordinary combo and actual hitbox overlap yield exactly one hit at 1 → 2 → 1 damage before, during and after the effect. A separate unmodified hitbox owned by Foxy still emits 7 damage. |
| Other damage routes | NOT RUN | Full charged attack, skill, projectile and DoT gameplay regressions were not run. Source inspection shows only the ordinary combo enables the modifier, and the separate HitArea default-path probe passed. |
| Two HUD effects and pause | PASSED | Both icons, separate countdown values and shield gauge are visible together. Inventory B and Escape pause both freeze the timers. Captured and visually inspected the combined HUD and three-recipe panel at 1280×720. |
| Duplicate use | PASSED | Both Q rejections display a reason and retain count. Strength keeps its remaining time. B → Sử dụng also reports the active strength effect and preserves the stack. |
| Lethal combat hit and respawn | PASSED | Incoming 5+shield damage uses the real hurt and death flow. Shield and strength vanish before the death delay. Actual Garden checkpoint respawn has full health, no effects, and the post-use counts. |
| District/scene change and Continue observation for Mốc 4 | PASSED | Garden → configured main scene clears transient potion effects. A new process continues at the Garden checkpoint with the paid counts and Q assignment, with neither runtime buff restored. |
| Healing regression | PASSED | Mốc 1 Garden suite covers purchase, planting, harvest, focus, repeated Brew, later harvest, full-heal/exact-one, full-HP no-op and healing HUD. Existing v1 save and Continue cases pass. |
| Wave reset, hardware controls and disk-error recovery | NOT RUN | Wave/encounter code was outside this change. Death used the actual Garden checkpoint. Inputs are injected through Godot. Standard SaveSystem v1 has no write result/rollback. |

### Combat integration and run instructions

Incoming damage flows through `Player._on_hurt_area_3d_hurt()`, which retains the Ice
Shield gate, then `PlayerState.take_damage()`, where the potion absorbs damage after
invincibility and successful parry checks and before HP damage. The ordinary combo in
`weapon_attack.gd` opts its specific hitbox into one contact-time adjustment in
`HitArea3D.hit()` after the current damage calculation. State transitions, timing,
wave reset and scene loading continue to use their original implementations.

Use the disposable-copy setup from Mốc 1 above. Keep one dedicated APPDATA directory
for the first two commands and a separate one for the last two.

```powershell
& $godot --path $copy --rendering-method gl_compatibility --resolution 1280x720 --script res://tests/garden_combat_potions_check.gd -- --isolated-copy
& $godot --path $copy --rendering-method gl_compatibility --resolution 1280x720 --script res://tests/garden_combat_potions_check.gd -- --isolated-copy --continue
& $godot --path $copy --rendering-method gl_compatibility --resolution 1280x720 --script res://tests/basement_clear_portal_check.gd -- --isolated-copy --brew-only
& $godot --path $copy --rendering-method gl_compatibility --resolution 1280x720 --script res://tests/basement_clear_portal_check.gd -- --isolated-copy --brew-continue
```

Local evidence is under the ignored `.godot/ArcanaPotions2-20261125/` directory.
Final log stems are `m2-final`, `m2-continue`, `healing-final` and `healing-continue`.
`potions-brew.png` and `potions-both-active.png` are in the isolated Mốc 2 user
directory. The fixture supplies harvested produce directly for Mốc 2, drives the
actual Garden NPC and B menus, and uses a controlled target position to exercise
weapon contact and incoming damage. It also waits real gameplay seconds for expiry.

Earlier healing regression exposed focus stopping at disabled recipes. The Brew
panel now links its enabled buttons and close button. The first rendered Mốc 2
run compared two physics-frame samples as if a process tick was guaranteed between
them. The repeat-use test now establishes elapsed time before retrying and accepts
equal or decreasing time only, with the rejection message and unchanged count also
required. Final runs retain vendor UID fallbacks and ObjectDB/resource shutdown
diagnostics. No final gameplay script or Dialogic error was observed. Bao's
implementation authorization is recorded. Independent patch review is unrecorded.


## G18–G23 — Milestone 3 venom potion (2026-11-25)

Working-tree baseline is `features/BasementandGarden @ 1e410e4f` with Mốc 1–2 and
the team's existing changes. Lam approved Mốc 3. The final user decision keeps 2
on skill slot 2. Godot 4.7.2 (ed1daf0bf) Compatibility via ANGLE ran in an isolated
copy with independent save directories. The final Garden → Castle run passed
**56/56**. All four existing-potion regression runs also exited 0.

| Case | Status | Observed result |
| --- | --- | --- |
| Garden Brew, icon, combined save | PASSED | Real merchant lists the 32×32 venom frame. Fourteen exchanges each charge one cucumber and spinach. A fifteenth attempt cannot craft. Saved counts contain both produce and potion updates. |
| Assign B → Tiêu hao, real F Garden → Castle, Q and 2 | PASSED | The assigned potion goes through the existing Q slot. Physical 2 selects skill slot 2 and leaves the weapon and bottle count intact. Each accepted Q subtracts one bottle, including on disk. |
| Camera snapshot, horizontal limit and near-vertical fallback | PASSED | Real active Camera3D orientation drives the throw. On Castle F1 the unobstructed launch goes 4 m horizontally. Rotating the camera during flight leaves the first target fixed. A near-vertical camera uses Foxy's facing. |
| Castle wall, stair edge and invalid launch | PASSED | The authored wall shortens the throw to its near side. The stair edge lands on the Castle ramp around Y=7. Unsupported launch is rejected with the bottle retained and a gameplay reason. |
| Simultaneous flights and active zones | PASSED | A second bottle spends one while the first is airborne. Four independently timed regions coexist. Source imposes no active-zone cap. |
| Main throw A, same A at roughly 2 s, new B | PASSED | First impact creates A. Second impact restores A to 8 s with the same center, visual and damage phase. B lands outside A, starts its own clock and leaves A's deadline intact. |
| Atlas loop and visibility | PASSED | First four strict packed frames at 65 ms each loop on the ground and use the light-green palette. Flight alone leaves the infection icon hidden. The visual starts at impact and hides when the zone expires. Inspected Castle captures at 1280×720. |
| Enemy tick, exit, floor and occlusion | PASSED | A living Skeleton loses one HP after one second. Leaving the radius stops subsequent hits. The other floor and a solid test wall each block damage within the horizontal footprint. Existing hurt/invulnerability behavior still applies. |
| Foxy exact 2 s and shorter exposure | PASSED | On entry the icon appears. After leaving, exactly 2 s produces one final HP tick as the icon clears. A 1.5 s exposure displays the icon and expires without a tick. |
| Overlap and pause | PASSED | The two overlapping zones select the longer expiry with one two-second damage cadence. Escape pause holds flights, zone clocks, infection and the next scheduled damage. |
| Lethal infection and Castle checkpoint reset | PASSED | Foxy's health reaches zero and infection/icon clear before respawn. The old encounter continues advancing its zone clock during death. Castle F2 reload removes all old potion nodes and retains paid counts. Fresh enemies spawning in the same footprint receive no stale hit. |
| Defeat, EXP and Castle F2 wave-clear | PASSED | Poison defeats the nine test-positioned enemies spawned by the actual three Castle EnemyZones. All three zones clear, the exit unlocks, and a regular EXP pickup reaches Foxy. |
| Bình hồi phục regression | PASSED | Garden 33/33 and Continue/legacy 6/6. |
| Bình hộ mệnh and Bình cường lực regression | PASSED | Garden/combat 43/43 and Continue 2/2. |
| Manual on-foot combat, hardware input and other maps | NOT RUN | The fixture injects Godot input and controls positioning, local Camera3D orientation, initial harvested stock, drop-target HP, and some exact clock boundaries. Castle uses the authored navigation, walls, stairs, checkpoint and native EnemyZones. |
| Venom Continue in a new process and disk-write failure | NOT RUN | Castle reload and raw saved stock were checked. SaveSystem keeps its existing write-error behavior. |

### Integration boundary and reproduction

Lam's scene-local poison node calls `HurtArea3D.take_damage()` for a valid enemy tick.
Castle then uses the existing `Skeleton._on_hurt_area_3d_hurt()` /
`ArcaneEnemy._on_hurt_area_3d_hurt()`, EXP drop and `EnemyZone._on_enemy_tree_exited()`
paths. Foxy's periodic cost decrements HP directly, and lethal cost uses
`Player.die()` followed by the existing `GameManager.respawn()`. Bao or Duy can
review these call sites separately from patch sign-off. Their implementation files,
checkpoint handling, scene resources and wave reset rules have no Mốc 3 edits.
Range is measured horizontally. The search follows nearby floor and ramp support
in 0.25 m steps and checks world geometry along the actual launch arc.

Use the disposable copy setup above, with imported resources and a unique
`ArcanaPlacement-` custom user directory. Give each suite its own APPDATA path.
Reuse that suite's path for its Continue command.

```powershell
& $godot --path $copy --rendering-method gl_compatibility --resolution 1280x720 --script res://tests/garden_poison_potion_check.gd -- --isolated-copy
& $godot --path $copy --rendering-method gl_compatibility --resolution 1280x720 --script res://tests/basement_clear_portal_check.gd -- --isolated-copy --brew-only
& $godot --path $copy --rendering-method gl_compatibility --resolution 1280x720 --script res://tests/basement_clear_portal_check.gd -- --isolated-copy --brew-continue
& $godot --path $copy --rendering-method gl_compatibility --resolution 1280x720 --script res://tests/garden_combat_potions_check.gd -- --isolated-copy
& $godot --path $copy --rendering-method gl_compatibility --resolution 1280x720 --script res://tests/garden_combat_potions_check.gd -- --isolated-copy --continue
```

Local evidence is under `.godot/ArcanaVenom-20261125/`. Final log stems are
`venom-verified`, `healing-verified`, `healing-continue-verified`,
`m2-verified` and `m2-continue-verified`. Under
`userdata/ArcanaPlacement-Venom-20261125/`, `venom-castle-zones.png`
shows A/B without an infection badge and `venom-infection-hud.png` shows the
active badge when Foxy stands in the overlap.

The initial fixture parse error was fixed with an explicit Boolean type.
The early headless fixture could sample the HUD before its process frame and
looked for EXP after its auto-collection. It now waits for HUD layout and
observes actual EXP drops as well as collection. Rendered evidence prompted
a light-green remap of the selected atlas frames and immediate badge hiding
on lethal health change. Final runs have vendor UID fallbacks and existing
ObjectDB/retained-resource diagnostics at exit. No final gameplay script,
shader or Dialogic compile error was observed.

## N06 — B1 ladder dialogue zoom after TPS default (2026-11-25)
Before implementation: user reports the dialogue camera zoom toward the B1 ladder is not working after TPS became the default. Source review confirms `b1_clear.dtl` sends `story_ladder` before the ladder line and the story adapter applies a fixed pose/FOV. The old shot offset is `(0,7,5)` with FOV42; under the new TPS default that wider overhead pose can read as pulling back. This is a hypothesis; verify rendered actual-scene behavior in all three camera modes and exact restore.

N06 final result: Godot 4.7.2 Compatibility rendered actual basement story run in the disposable isolated copy with fresh `ArcanaStory-Zoom-20261125`. `basement_story_loot_check.gd` passed 61/61; engine exit 0. The B1 ladder focal point is centered with the tighter story shot in TPS, Top-down and FPS, and the prior camera pose/FOV restores when the dialogue ends. See `docs/validation/story-loot-2026-11-25/ladder-zoom-runtime.log` and inspected `ladder-focus.png`. The first rerun had a fixture-order mistake (mode switched after the story captured its saved pose); the fixture was corrected and the final complete rerun passed. Existing vendor UID fallback and ObjectDB/retained-resource exit diagnostics remain; no runtime errors or crash. Manual interaction and independent review remain NOT RUN.

## N07 — B1 clear story gate (2026-11-25, before implementation)
The user requests B1 clear dialogue after all B1 enemies are defeated. Existing implementation already polls all direct EnemyZone children, but the current fixture clears all zones at once and does not demonstrate the last-zone gate. Strengthen source clarity and the rendered regression: dialogue remains absent with one zone short and starts when the last zone reaches its clear quota. Preserve user's changed Player location. Run in an isolated rendered copy; don't infer reviewer agreement.

N07 final: The rendered latest-scene regression confirms that B1 story does not start while one `EnemyZone` remains incomplete, then starts after the final zone's clear signal. Camera FOV/view and Player interaction recover after dialogue. Godot 4.7.2 Compatibility: 63/63 PASS, engine exit 0; see `docs/validation/story-loot-2026-11-25/story-all-b1-runtime.log`. Test fixture drives each real zone counter and emits its existing clear signal; the full nine manual kills were not played. Existing vendor UID fallback and shutdown ObjectDB/resource diagnostics remain. A previous latest-scene run's exact-transform assertion was invalid after the rig resumed following; the final acceptance checks restored FOV/view/controls. Current F5 save resumes Garden and marks possession story seen, so run the current basement scene with F6 to inspect its edited Player transform and use the B1 clear path. Manual combat playtest and independent review NOT RUN.
## N08 — Empty B1 enemy zone blocker (2026-11-25, before implementation)
Static confirmation: basement_full.tscn configures B1 EnemyZone_B with no enemy_scene and clear_kills=3. EnemyZone.is_cleared() requires _defeated >= clear_kills, but the empty zone can never spawn/defeat enemies. Exclude zones without an enemy scene from the narrative clear requirement; test that this inactive zone does not block, while incomplete active zones still do.

N08 final root cause/fix: the latest full scene has B1 `EnemyZone_B` configured without an enemy scene but with `clear_kills=3`. The previous all-zone predicate waited forever for an impossible clear. Story gate now skips zones with `enemy_scene == null` and requires all active zones. Focused rendered run on the latest scene: 33/33 PASS, engine exit 0. The test deliberately leaves the empty zone at zero kills, keeps dialogue blocked until the final active zone completes, then observes the actual `cleared` signal start the timeline. Evidence: `docs/validation/story-loot-2026-11-25/story-b1-gate-runtime.log`. It does not manually defeat six spawned enemies. The full loot/story fixture remains blocked after this point by its unrelated `B1/ChestSpot` child assumption in the combined basement scene. No manual combat playtest or independent review.

## N09 — P menu, one-time enemy camps and checkpoint loss (before implementation)
Static findings: `ui/inventory_menu.gd` currently renders `Cheat · P` as an Inventory tab and routes the `cheat_menu` action into that same paused menu; `project.godot` already binds physical P. `EnemyZone` keeps only in-memory alive/defeated counts and its timer replenishes enemies while the zone has quota remaining; all Stage reloads recreate zone state. `GameManager.save_game()` persists inventory and XP immediately, while `respawn()` reloads the last checkpoint stage. Therefore camp no-respawn across death/Continue and XP/inventory checkpoint rollback need durable shared flag/snapshot state in `GameManager`/the v1 payload, without saving enemy health or resetting unlock flags.

Status before implementation: Bao and Duy approval for their ownership boundaries is reported by the user. The active feature's named shared reviewer is Lam, whose existing authorization covers an older bounded GameManager slice only. New durable snapshot/camp-state edits are BLOCKED pending Lam's approval; the independent separate-menu slice is authorized and may proceed. No implementation or runtime result claimed yet.

Planned checks: separate Inventory/P/Esc handoff; one initial population per camp and no defeated-slot re-spawn across death/process Continue; clear-gate completion; checkpoint XP and inventory restore after death; second checkpoint recaptures new values; world/unlock flags survive. Godot playtest is required for death/respawn behavior. No tests run at this planning point.

N09 P-menu slice implemented: `ui/inventory_menu.gd` no longer lists or builds cheat controls; new `ui/cheat_menu.gd` owns the separate P view and routes to the existing enchant page. Inventory B and cheat P hand off between their pause lifecycles; Esc/P close the cheat view. Existing physical-P action in `project.godot` is reused. Static path/diff inspection is pending; Godot UI interaction/playtest NOT RUN (not requested). Durable camp-kill and checkpoint XP/inventory rollback remain NOT IMPLEMENTED pending Lam's approval of new shared GameManager/save scope.
N09 static check: `git diff --check` passes for the menu and appended documentation; source references show the existing P action remains bound and is handled only by `CheatMenu`, while Inventory handles B/Esc and no longer contains the cheat tab or builder. This is source-level inspection, not parser/runtime proof.

N09 clarification: user supersedes XP rollback; future checkpoint snapshot restores inventory only and retains current XP/level/collected-EXP state and world unlock flags.

## N10 — Attack SFX and recovery input (before implementation)
Static findings: `BattleFX.play_skill_sound()` already loads the project's sword-attack and impact assets on SFX bus; the combo attack state currently has `PHASE_RECOVER` with horizontal movement stopped for the full recovery duration. `control_dash()` is checked before all attack phases, so dash interruption is already an intended path, but it needs acceptance/playtest under the requested recovery behavior. The Player routes ordinary hurt signals into the current state and `PlayerState.take_damage()` filters invulnerability/parry/potion-shield damage before HP handling.

Acceptance/check plan is recorded in `tasks.md` N10. New change is Bao-owned Player/combat scope and explicitly requested by the user. No code has changed for N10. Runtime playtest is required for damage, input and dash behavior; no test has been run at planning time.

N10 implementation result: swing sound is dispatched when each ordinary/charged attack begins; received-hit sound follows invulnerability/parry rejection in PlayerState and plays once for Ice Shield absorption. Combo completion sets a 0.5-second `Player.attack_input_cooldown` and transitions to Idle immediately; control movement/jump/carry/parry return to their regular states, while `control_dash()` remains first in the attack state's update and exits through its existing cleanup. Existing attack/hit audio assets and SFX bus are reused. `git diff --check` passes. Godot playtest for the sound, cooldown boundary, movement/jump/dash, active attack cancellation and hitbox/weapon restoration is NOT RUN, so behavior remains runtime-unverified. N09 inventory rollback and durable enemy camp state remain pending shared GameManager review; XP rollback is superseded by user clarification and is not planned.

N09 latest clarification supersedes the XP-retention note above: user explicitly wants death to lose XP/level back to the latest checkpoint. Keeping post-checkpoint XP is the current defect. No code changed for rollback; new shared save work remains pending Lam approval. Unlock flags must remain.
N09 resource note: Godot has generated `ui/cheat_menu.gd.uid` for the newly added standalone script. It is preserved as the script resource identity; it was not hand-edited.

N09 approval/status update: user confirms Lam approved the new shared GameManager/save scope. Proceed with v1-compatible XP/level/inventory checkpoint snapshots and persistent defeated spawn-slot state in existing world flags; preserve unlock flags and enemy health non-persistence. The latest XP rule is rollback on death.

## N11 — Enemy attack and hit SFX (before implementation)
Static inspection identifies `EnemyCharacter` as the shared class for current enemy families; their animation names cover `attack`, `attack2`, `skill`, `shoot`, `atk`, `phase*_castspell`, `phase*_closeattack` and `phase*_explosion`. `EnemyCharacter.take_damage()` runs after the state/hurt handler accepts damage, making it suitable for one received-hit cue. Planned implementation uses the existing BattleFX audio mapping, without changing enemy behavior. Runtime audio checks remain required and are not run at this point.

## N09–N11 implementation and verification status (2026-11-25)
Static review confirms a dedicated P overlay, finite EnemyZone slots, checkpoint snapshot/restore for player XP/level/collected EXP, inventory and defeated camp slots, and restoration of unrelated world flags. A death after a later checkpoint restores the enemy-slot baseline recorded at that checkpoint; kills after it return on death. Each defeated slot is not replenished during ordinary play. Common enemy animation-start and accepted damage hooks call the existing BattleFX sound helper. Player combo completion applies an attack-only cooldown and transitions to Idle after restoring the attack pose; dash remains the first AttackState control.

Existing OGG files for the four new SFX mappings were confirmed under the project's SFX assets. `git diff --check` completed without whitespace errors; Git emitted line-ending conversion notices for existing documentation files. No Godot parser, game run, audio audition, or required respawn/combat playtest was performed in this turn, so all gameplay behavior remains runtime-unverified. No test was added or run. Known limits: enemy attack sound matching relies on current animation names; audio levels and event timing need runtime review; save/write failure behavior remains the existing SaveSystem limitation. User reports Bao/Duy/Lam approval for their boundaries; no independent code review or reviewer sign-off is claimed. Pre-existing unrelated working-tree changes were preserved. No commit/push.

N10 parser-error follow-up (2026-11-25): fixed the reported inherited-member collision by renaming `PlayerState`'s helper constant from `BattleFX` to `PLAYER_HIT_FX`; child states' existing `BattleFX` declarations remain unchanged. Static diff check passes. No Godot parse/runtime run, so editor confirmation remains pending.

## N12 — B1 clear chest restore and B3 boss chest (before implementation)
Static findings: B1's `basement_floor_visibility.gd` reacts only to future EnemyZone `cleared` signals, so a zone already restored as clear on scene load has no event to trigger chest creation. The current combined scene contains `B1/ChestSpot`. B3 `EncounterProgress` consumes the Dark Fairy terminal defeat through `clear_portal.gd`, whose reusable `clear_reward` feature can create `floor_clear_chest.tscn`; the B3 scene has not configured a reward marker. Planned change: check completed active B1 zones on startup and guard against duplicate chests; add/configure a B3 reward marker and unique chest ID. Acceptance and scope are in tasks.md N12. No implementation yet. Tests/playtests remain NOT RUN unless requested. Preserve existing map working-tree edits.

N12 implementation result: B1 now runs its active-zone clear predicate once during scene startup and on subsequent clear signals; a missing/zero-quota zone does not block the chest; a scene-local guard prevents a duplicate. Thus a persisted clear with no prior chest can recover it on the next load. B3's Dark Fairy `EncounterProgress` now points to a reward marker and an independent chest ID; `clear_portal.gd` keeps the existing default ID for all other portal rewards. Static diff/reference inspection and `git diff --check` pass. Runtime creation, placement, chest interaction, loot save/reload and actual boss defeat were NOT RUN, so runtime acceptance is pending. No test was added or run. The pre-existing `basement_full.tscn` changes were preserved. No independent reviewer sign-off or commit/push.

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

### N30 FINAL — runtime-verified requested slice, 2026-11-27
Final rendered Godot4.7.2 Compatibility results: combat/burn/boss/parry/UI58/58 PASS and actual Garden/Castle fractional-HP/respawn8/8 PASS, both engine exit0. Existing quick-item HUD39/39 PASS, exit0; total105/105 in these three passing suites. Both bosses emitted3 attack animations during14s continuous0.5HP hits at0.2s intervals with burn refreshed every1.2s; each still accepts explicit parry and recovers. Dark Fairy completed transformation, phase2 attacks and defeat; Executioner successfully summoned and completed death. Burn overshoot, one-second expiry, reapplication/no stacking, pause/resume, damage through existing hurt, actual projectile/contact values, shield fractional overflow, fractional regeneration, clone liveness, both fire ultimate ignitions and learned gold pixels including selection/hover passed. Actual map transitions preserve0.5 and1.5HP; transient effects clear; death from0.5HP respawns at Garden checkpoint full-health with no potion effects. No final script/parse/compile/invalid-call failure in these two final new suites. Existing shutdown ObjectDB/resources-in-use warnings remain.
Screenshots inspected: gold/red HP frame is legible and fractionally filled; learned nodes have bright yellow fill/rings, selected+hover learned node stays gold; Dark Fairy boss bar and floating HP frame render with supplied art. These are controlled fixture captures, not a completed manual campaign. All35 selected source/staged implementation/test/asset hashes match. git diff --check and node --check tools/audit_gameplay_cleanup.mjs pass. Player scene and export diff exactly retain the starting user edits. Source uid_cache was already dirty; late observed SHA256A6380B34162FA25AD5A4DC346737A985D7D7A18E1EAE1FDF770462223F71AEAA is an observation only; no start checksum supports attributing external cache changes. No source editor import, hand-edit/reset, generator, commit or push.
Legacy suite limits are retained: potion38/41 failed checkpoint inventory/old UID expectations; EXP fixture incomplete at obsolete exp_points access, not part of105 passing assertions. Their source fixtures were not rewritten in N30; isolated copies only adapted custom-user-dir guards. Follow-up work would update these historical suites against current checkpoint rollback/skill_points contracts. Full manual campaign, all original bug input sequences, exports and independent reviewer/owner acceptance remain unperformed. Fixed burn overrides old burn-only bonuses; no substitute gear/evolution gameplay bonus designed. User-requested implementation is complete with this bounded runtime evidence; no claim of blanket project acceptance.
Evidence files under docs/validation/combat-balance-2026-11-27/:
- baseline.log: early pre-change intermittent-hit investigation and its uninitialized Player FSM / old summon-property errors; not final acceptance.
- combat-headless.log: initial46/47 focused run, preserved failure.
- combat-rendered.log: corrected48/48 rendered run before added pause/parry/pixel tests.
- combat-final.log: final58/58 focused rendered verification and shutdown diagnostics.
- transitions-final.log: actual8/8 Garden/Castle HP/potion/death/respawn verification.
- hud-regression.log: existing39/39 quick-item HUD regression.
- potions-regression.log: failed38/41 historical potion/old inventory UID run, not hidden or counted as pass.
- exp-regression.log: obsolete exp_points failure, terminated isolated fixture.
- import-after.log: isolated Godot import/parse check.
- combat-balance-hp-and-gold-nodes.png: HP art plus unlearned/learned/selected-hover comparison.
- combat-balance-boss-darkfairy.png and combat-balance-boss-arcane.png: supplied HP art on both actual bosses.
- source-hashes.json:35 source/staged SHA256 agreements including retained user scene edit; results.json: exact counts/tuning/limits.

### N31 FINAL — 2026-11-27
Implemented user-requested correction: Player scene base max_health5; existing health upgrades add to5 (rank2 verified7HP). All Skeleton Warrior/Mage damage0.5; Skeleton Mage was already0.5 at this turn start and was preserved, superseding N30's earlier Mage1 interpretation. All other15-scene inventory enemy types retain/default to1 except Executioner3->1; removed its special-attack+1 so both regular and skill hit1. Prior action timing, burn/boss/parry fixes, movement8/dash15/cooldown1.5/parry0.3, export index path and existing dirty work preserved.
Player HP retains supplied gold/red vendor art and adds dark vertical separators at each whole HP, redrawn when range/size/value changes. Full base5HP has4 internal dividers/5 segments;0.5HP hit empties half the last segment,1HP hit empties one segment. Upgraded7HP has6 internal dividers/7 segments. Capacity divisions are Player HUD only; enemy HP amounts/appearance unchanged. Fractional fill, HP signals, stage transfer, potion/shield/respawn policy preserved.
Files in this implementation group and purpose:
- scenes/player/player.tscn: add max_health5; preserve prior user movement/dash/parry overrides.
- ui/segmented_health_bar.gd: small TextureProgressBar drawing overlay, one divider per whole HP, redraw on Range/resizing changes.
- ui/player_hud.gd: instantiate segmented bar while retaining N30 texture/fill/tween behavior.
- scenes/enemies/arcane/undead_executioner.tscn: attack_damage3->1.
- scenes/enemies/arcane/arcane_enemy.gd: special attack uses ordinary attack_damage with no+1 bonus.
- tests/combat_balance_check.gd: correct ranged Skeleton expected damage0.5 and assert base Player starts5HP; prior combat/burn/boss tests retained.
- tests/hp_segments_damage_check.gd and .tscn: rendered HP-divider/pixel/fraction/upgrade checks, inspect all15 enemy scene resources, actual Executioner regular+skill and Dark Fairy melee/phase1+2 spell HP impacts.
- tools/audit_gameplay_cleanup.mjs: retain the new related fixture in future dependency inventory.
- specs/001-integrate-basement-stage/tasks.md and validation.md: N31 scope/status/acceptance and exact evidence; docs/project-changes-2026-11-14.txt: cumulative implementation/file/integration/error/limit record.
Source inputs deliberately preserved: scenes/enemies/skeleton/skeleton_mage.tscn already0.5; skeleton_warrior.tscn0.5; other enemy scenes already1/default1. Existing auto-generated N30 test .gd.uid files/source cache changes present at start were preserved; no source Godot editor/import or manual cache edit/reset by agent. No generators, saves/preferences, commit/push or independent acceptance.
Verification: rendered Godot4.7.2 Compatibility HP/damage29/29 PASS (15 real enemy PackedScene properties inspected; actual boss attack paths exercised), full updated combat/burn/boss/parry/gold59/59 PASS, actual Garden/Castle fractional HP/respawn8/8 PASS =96/96 in these three suites, all engine exit0. Both skeleton contact/projectile paths0.5 and mage1 paths verified by the59-case combat suite; boss melee/special and both Fairy spell phases1 verified in29-case suite. Player5HP and upgrade7HP,4/6 internal divider counts, partial last segment and1HP depletion checked against rendered image pixels. All3 HP captures visually inspected. Source/staged38/38 selected code/scene/resource hashes match; git diff --check and node --check tools/audit_gameplay_cleanup.mjs pass. No SCRIPT ERROR/Parse Error/Compile Error/invalid-call failure in final logs. Existing BattleFX UID fallback, CheatMenu anchor, B2 quota and shutdown ObjectDB/resources-in-use warnings remain; not claimed fixed. Historical N30 Potion/EXP suite drift not rerun/fixed/counting as passing. Full manual campaign/all enemy attack animations/export and independent reviewer-owner acceptance not performed.
Evidence directory docs/validation/hp-segments-damage-2026-11-27/:
- hp-segments.log:29/29 HP/art/enemy/boss assertions and engine diagnostics.
- n31-combat.log:59/59 prior combat/burn/boss/parry/UI regression at new HP/damage values.
- n31-transitions.log:8/8 actual map HP transfer/checkpoint death/respawn regression at5HP base.
- hp-segments-five-full.png: five full one-HP segments.
- hp-segments-four-and-half.png: half last segment empty after0.5HP hit.
- hp-segments-seven-upgraded.png: seven segments after+2HP upgrade.
- source-hashes.json:38 source/staged SHA256 agreements; results.json: exact counts/tuning/limits.

### N32 FINAL — expired summon typed-array failure reproduced and fixed (2026-11-27)
Actual user's Godot log reports filter callback Cannot convert argument1 from Object to Object and secondary Array->Array[Node3D] assignment at arcane_enemy.gd89/_begin_attack. Isolated pre-change reproduction with a real freed Node3D reference produced BOTH identical errors and1/1 failed assertion, engine exit1. Root cause established: typed filter lambda parameter conversion runs before predicate validity guard for an already-freed summon; filter fails and returns untyped empty Array. Prior N30/N31 short boss combat observation did not cover the actual18s summoned-unit expiry; earlier passing combat checks were bounded evidence and did not establish this lifecycle case.
Changed local Arcane _begin_attack pruning from allocating/filtering/reassigning summons to reverse-index checks/removal on the original Array[Node3D]. is_instance_valid(array[index]) runs before any method access; short circuit then checks queued-for-deletion nodes. Valid survivors and their order remain; no typed callback conversion and no new untyped array assignment. Enemy AI/balance/burn/HP, timers/summon limits, Dark Fairy and maps unchanged by this group. User authorizes Duy enemy lifecycle correction; no independent teammate acceptance asserted.
Included files and purpose:
- scenes/enemies/arcane/arcane_enemy.gd: safe reverse removal of expired/null/queued references before attack/summon selection.
- tests/summon_lifecycle_check.gd and .tscn: exact before/fix reproduction; typed-array identity/type/order, mixed invalid states/empty list, real summon18s expiry/death, replacement summon, damage-killed summon/repeated attacks and Necromancer shared-path recovery.
- tools/audit_gameplay_cleanup.mjs: preserve the relevant new lifecycle fixture during future dependency inventory.
- specs/001-integrate-basement-stage/tasks.md and validation.md: scope/cause/status/actual evidence/limits; docs/project-changes-2026-11-14.txt: cumulative per-file and integration record.
- docs/validation/summon-lifecycle-2026-11-27/summon-before.log: failing pre-change reproduction and exact stack/errors; summon-after.log: rendered final15/15 lifecycle assertions and diagnostics; source-hashes.json:3 tested source/scene SHA256 agreements; results.json: exact before/after counts, timing and limits.
Verification: Godot4.7.2 Compatibility rendered15/15 PASS, engine exit0. Actual summoned unit lifetime remains18s; waited20.5 real game seconds including death animation, then confirmed freed entry removal and successful replacement summon. Actual damage killed the replacement, completed death and three later attack requests continued. Mixed freed/queued/null removal preserves two valid Node3D entries/order and same typed array storage. Necromancer also safely recovers after freed summon reference. No final SCRIPT ERROR/filter callback/Array assignment/Parse Error/Compile Error. Existing BattleFX UID fallbacks, CheatMenu anchor and shutdown3 ObjectDB/one resource warnings remain, not declared fixed. git diff --check and node --check tools/audit_gameplay_cleanup.mjs pass;3/3 tested source/scene hashes match source. No additional broad combat rerun required for this local pruning after focused lifecycle coverage; N31 balance tests retain their prior status.
User's newly dirty levels/level_1/castle.tscn (placed Executioner and editor formatting) was inspected/preserved without edits; before/after SHA2565A4EB04D45941D4CA4E4755BC94C9C477D9AE283E441F844C1E82677E24E6982 identical. All prior user/N30/N31/cache/export work preserved. No generator, source editor/import/cache reset, real save/preference change, commit/push. Full manual campaign/export/independent reviewer-owner acceptance not performed; historical Potion/EXP fixture issues remain separately recorded.


### N33 FINAL — straight camera, movable book/HUD, Garden stations, doors/visibility/torches and larger bosses (2026-11-27)
User explicitly authorizes this bounded Bao player/UI/camera, Lam/Quan map/farm and Duy boss slice, including follow-up door obstruction/vanishing-map screenshot and basement torch repair. No independent owner/reviewer agreement or teammate acceptance asserted. Git baseline was clean; existing integrated work preserved.
Implemented: camera yaw -45->0 with matching movement (pitch50/FOV35/distance22 retained); book T and backpack B separately beside Q; drag book by upper handle, keep handle on screen; left/middle drag skill graph; farm tab Nông sản; functional Garden enchant/brewing tables at (27,1,17)/(37,1,17) beside seed merchant (32,1,18), using bundled KayKit table and Ravenmore/potion icons plus existing APIs/recipes; Dark Fairy40->80HP and Executioner90->180HP, sprite pixel size/height1.4x. Body collision, AI, attack damage and save format unchanged.
Door IDs/targets/locks/local Spawn offsets retained; seven doors moved toward north walls (B2, two B3, two Garden, two Castle). Runtime geometry inspection identified exactly three old B3 door surround wall_small cells at world (49,2,5)/(53,2,5)/(51,2,3); removed only these. B3/World/Floor remains intact. GroundExit's old raised platform visually covered the Garden exit; set visible=false, retaining its entire hierarchy/cell/collision data. Automatic approval review rejected an earlier proposed whole-GroundExit deletion; that command made no changes. The narrower geometry-inspected change and render-only alternative succeeded. No approval remains blocked.
Vanishing-map correction: Basementfull no longer hides B1/B2 based on supporting surface/connector height, so ladder/door-block contact cannot hide the whole map. Secret reveal and ceiling-only visual hiding retained. Camera wall-fade helper disabled in basement scenes, avoiding replacement/hiding of source GridMaps there. Other maps keep their existing wall fading. All basement torches now use textured KayKit torch_mounted model; orange cube Flames and per-instance skewed Flame overrides removed; warm light properties retained.
Files and purpose:
- scenes/camera/camera_rig.gd: straight yaw/movement and basement-only wall-fade opt-out.
- ui/player_hud.gd: separate book/backpack shortcuts, book artwork/key badge, compact backpack sizing.
- ui/skill_tree_layout.gd: upper drag handle/hint, event-relative scaled dragging, reachable-handle bounds and updated instructions.
- ui/skill_tree_graph.gd: add left drag to existing middle-drag/zoom graph.
- ui/inventory_menu.gd: Nông sản tab and BÀN ENCHANT title.
- levels/objects/garden_station.gd: model/icon/label/collider/nearby-F interaction; reuse InventoryMenu enchant and Farm brewing entry points.
- levels/level_1/garden.tscn: two station placements and two north-wall door placements.
- levels/level_1/basement_full.tscn: B2 door placement and all B1/B1.5/B2 mounted torches; retain floors, progression, stairs, checkpoints and secret room.
- levels/level_1/basement_b3.tscn: two door placements, exact three surround-cell removal, render-only old platform hiding and B3 mounted torches.
- levels/level_1/basement_floor_visibility.gd: render both normal floor branches through ladder/door contact; retain secret/ceiling policy and compatibility current_level API.
- levels/level_1/castle.tscn: only two door transform updates; placed Executioner and all other map content preserved.
- scenes/map/torches/torch.tscn: textured mounted glTF replaces previous OBJ visual and its separate MTL texture lookup.
- scenes/enemies/darkfairy/darkfairy.tscn and scenes/enemies/arcane/undead_executioner.tscn: each boss HP2x and sprite1.4x/raised visual center; no combat code changes.
- tests/layout_refresh_check.gd and .tscn: isolated rendered actual inputs/stages/menu/visibility/station/door/boss/torch regression and captures.
- tests/fixed_action_camera_check.gd: expected yaw0/straight description; prior full suite not independently rerun in this slice.
- tests/torch_resource_check.gd: find glTF child mesh as well as legacy direct Flame mesh; standalone suite not rerun separately.
- tools/audit_gameplay_cleanup.mjs: retain new related layout fixture in dependency inventory.
- specs/001-integrate-basement-stage/tasks.md and validation.md: scope/AC, clarification, implementation and actual evidence/limits.
- docs/project-changes-2026-11-14.txt: this cumulative per-file/integration/check/error/unfinished-work record.
Evidence files under docs/validation/layout-refresh-2026-11-27/: runtime.log = final rendered66/66 and diagnostics; import.log = isolated import; door-geometry-before.log = measured old wall blocks/platform and earlier helper-level42/42; results.json = counts/isolation/limits; source-hashes.json = 178/178 matching source/staged hashes (including all166 runtime script/scene/resource files plus fixture/current relevant assets). hud.png = B/T/Q layout; book-drag.png = moved window and panned graph; inventory.png = renamed tab; stations.png = two tables beside NPC; brew.png = existing recipe panel; b2-door.png/b3_down.png/b3_exit.png = moved doors and removed surround/cap; ladder-live.png = rendered ladder traversal with environment present. All these captures visually inspected.
Verification: final Godot4.7.2 Compatibility rendered66/66 PASS, exit0, with actual right/jump input, real F ladder start plus45-frame visibility monitoring, five ladder/door-height positions, all12 Basementfull torch instances non-cube, actual book/backpack GUI clicks, actual header/graph mouse drag/release, T close/pause restore, F opens both Garden services, seven door arrivals and floor support (six ray checks plus B2 grounded check), and both boss PackedScene HP/art values. Earlier development fixture failures came from raw window/viewport coordinate mismatch and missing synthetic motion delta; corrected using viewport-local events and explicit pointer delta. Subsequent visual review added reachable drag bounds. Final log has no SCRIPT ERROR/Parse Error/Compile Error; git diff --check and node --check tools/audit_gameplay_cleanup.mjs passed. This is bounded behavior verification, not full-feature acceptance.
Known remaining warnings: B2 EnemyZone_B finite clear_kills, BattleFX/automatic-stairs UID fallbacks, CheatMenu anchors, repeated state requests and shutdown6 ObjectDB/1 resource-in-use diagnostics; these are not claimed fixed. Full campaign/export, complete ladder route/end-point acceptance, full boss fights after HP/art tuning, and independent owner/reviewer acceptance NOT RUN. Nearby opaque walls still locally occlude Player with basement wall fading off; raised GroundExit collision remains though its image is hidden. No generators, source Godot imports/cache edits, real save/preferences changes, commit or push.
