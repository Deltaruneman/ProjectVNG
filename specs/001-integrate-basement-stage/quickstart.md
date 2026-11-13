# Quickstart: Planned Validation Guide

## Audit supersession / safe execution — 2026-11-13

This is a historical planning guide. Its no-executable/no-tests statements, pinned feature
branch, unconditional B3 prohibition and original-scene hashes are superseded for current
validation by [project audit validation](../../docs/project-audit-validation.md).
Tests/APIs now exist; do not run old suites against current design without checking their
assumptions. The old command example pointing at the production workspace is withdrawn:
only the verified disposable project path may be launched. Set child-process APPDATA and
custom user directory, then verify exact OS user-data path using a no-autoload probe
**before** launching production autoloads. A harness guard after startup is insufficient.
Never read/reset/delete real progress, run generators, or edit source to satisfy old tests.


**Status**: Future validation instructions only. No Godot executable/tests, generators, gameplay
changes, tasks command, or implementation ran during planning. A compatible installed Godot
executable must be located; none was found by Get-Command godot* in this session.

Read [plan](plan.md), [data model](data-model.md), and [contract](contracts/stage-progress.md).
The foundation can be checked independently; subsequent map and real wave acceptance have
additional dependencies. No B3 round-trip or Hidden entrance acceptance is included.

## Prerequisites and isolation

1. Confirm branch basement-split-floors and inspect Git status/diffs. Preserve existing
   project.godot, KKD_library.tres and uid_cache.bin modifications and all docs.
2. Use the project's Godot 4.7-compatible installed executable, verify its reported version,
   and set a local shell variable godotExe to its absolute executable path. Do not download
   engines, generate basements/mesh libraries, or clean tracked caches as part of verification.
3. Implement the scoped checks later, after review. Proposed tests/basement_integration_check.gd
   does not exist yet; commands below are not runnable until that test slice exists.
4. The fixture harness must set SaveSystem.save_path to a unique disposable test file BEFORE
   any write, replace in-memory fixture state, and load only that fixture. A transient manager
   reset in this harness is not permission to reset production progress. Never use F9/new_game
   to clear the real save. Startup may read a real file before the harness takes control;
   ensure no writes/scene continuation occur against it. Manual F5 needs isolated test
   user data verified before launch, not an assumption that the user's save is empty.
5. Review the agreed Duy interface implementation and readiness order before real wave tests.
   Record unsupported old B3 fixtures as blocked; preserve their data and do not select a fallback.

## Structural checks — before gameplay claims

- Parse/load the adapted scene in the isolated harness; verify root Stage and inheritance,
  retained B1/B1_5/B2, direct singleton nodes, one registration, and no B3/GroundExit branches.
- Resolve every scene/resource/NodePath and both Pathfinder obstacle arrays; no null maps.
  Inspect actual B1 nested-map navigation coverage; do not apply raw-cell comparisons across
  different transforms or one mesh library's item IDs to another library.
- Compare Hidden room/wall/collision/behavior/connections and log permitted reference repairs.
  Compare separate basement_b3.tscn hash to baseline; it should remain unchanged.
- Check each checkpoint's Stage owner, unique ID, Spawn support candidate, detector variant,
  no stock auto-activation connection, rank definition, prompt/tint/feedback nodes.
- Check project main scene and manager FIRST_STAGE agree. Verify one interact physical-F mapping
  while preserving other input/plugin settings. No direct F collision was found statically;
  actual dispatch still needs playtests.
- Trace startup/respawn/transition routes to the B3 deny guard, using both path and UID forms.
  A closed gate alone is insufficient. No B3 target on active map gates.
- Fixture comparisons must preserve unknown top-level fields and unrelated flags, valid new
  checkpoints, and clear/unlock state. No enemy-health/partial-wave persistence fields.
- Ensure gate collision opens without removing SprintBoundary; no new fall damage/hazard hooks.

Planned runner invocation after the harness is implemented and isolated:

```powershell
& $godotExe --headless --path $isolatedCopy --script res://tests/basement_integration_check.gd
```

Expected: focused structural/fixture checks report zero new errors and a failing exit for
unhandled blocked recovery cases, not a false all-pass. Do not run existing split_check as
sprint acceptance: it deliberately loads B3. Existing full/walk scripts also need scoped
adaptation or replacement; do not rewrite unrelated tests merely to make them green.

## Godot playtests — required separately

Use the installed editor after fixture isolation; open the adapted scene, F6 for isolated
scene behavior and F5 for the actual startup/continuation path. Both are needed. Never treat
an F6 pass as proof of startup compatibility. Godot may update caches; review/report any
unexpected changes rather than discarding or hand-editing tracked caches.

| Check | Action | Expected outcome / dependency |
| --- | --- | --- |
| Default entry | Isolated no-checkpoint F6 and F5 | Correct B1 starting surface; one player/camera/Hud/stage; no new load/spawn errors |
| Continuous route | Traverse B1/parkour/B2 when access available | No scene load/re-registration; camera tracks; support surfaces and navigation work |
| Nearby F | Stand near checkpoint without F, then press F | Prompt; no arrival activation; eligible F tints marker and shows Checkpoint activated. |
| Forward-only | Activate B2, return near B1 and press F | Active/persisted checkpoint remains B2; no false success feedback |
| Input conflicts | Repeat F, overlap nearby interactables, use dialogue, test dead/ineligible state | No accidental double action/load; checkpoint activation eligibility correct; coordinate Bao for player API changes |
| B1 death | Die before B1 clear | B1 respawn and B1 waves restart; needs actual Duy lifecycle |
| B2 death before checkpoint | Clear B1, reach B2 without F activation, die | Return B1; restart unfinished B2; B1 clear/parkour unlock preserved |
| B2 death after checkpoint | Activate B2 then die | Return B2; restart unfinished B2; cleared floors and unlocks preserved |
| Restart | Exit/relaunch with B1/B2 active checkpoints, clears/unlocks, unfinished rounds | Restore checkpoint/clears/unlocks; restart unfinished floors, not enemy health/partial wave progress |
| Narrow legacy | Known old B1/B2 path and UID fixture copies | Only their checkpoint pair resets to continuous B1 default; unrelated data and valid new fixtures unchanged |
| Old B3 fixture | Copy containing valid B3 stage/ID | Zero B3 loads and unchanged file/data; recovery outcome BLOCKED pending explicit policy, not reset to B1 |
| Unknown reference | Missing/unknown out-of-set fixture | Report unresolved exception; no blanket reset or unrelated data deletion |
| Ceiling/clearance | Current ordinary/second-jump timing at measured obstructions | Subsequent map work; sufficient clearance without player changes; actual body collider, not HurtArea |
| Miss/retry | Miss every parkour gap, record landing and retry route/health | Subsequent map work; no fall damage/lethal fall/new hazard; safe retry, not assumed teleport |
| Parkour unlock | Before/after genuine B1 clear, death and restart | Subsequent map work + Duy; initially closed, persistent unlocked state after clear |
| B2 terminal | Before/after genuine B2 clear, repeat F/push/jump/boundary attempts | Subsequent map work + Duy; gate opens, boundary stays safe, no B3 load |

Where enemy damage could confound fall-health observation, use an isolated test situation
that distinguishes the source; do not change enemy/player behavior or declare a fall bug fixed
from an ambiguous result. A known baseline geometry defect remains a blocker if it prevents the route.

## Verification record and stop rules

For each run record revision/working-tree baseline, engine build, scene, fixture path, steps,
expected/actual outcome, counts/errors, and screenshots where useful. Label each finding
static, hypothesis, or runtime-verified. Record checks not run and why, blockers and owner,
remaining limitations, and unrelated changed files separately. Synthetic callbacks validate
adapters only; real wave completion/reset/persistence remains blocked until Duy's interface exists.

Do not claim foundation completion satisfies subsequent ceiling/parkour/gate acceptance.
Do not silently reset old B3 saves. Resolve that policy before recovery acceptance, then recheck
startup/death/restart paths. Do not run generators, discard caches, change branches, commit,
or push as part of this guide without separate authorization. Stop after reporting evidence.
