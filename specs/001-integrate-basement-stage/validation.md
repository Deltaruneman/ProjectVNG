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
