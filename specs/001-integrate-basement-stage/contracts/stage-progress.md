# Contract: Basement Progress, Checkpoints, and Sprint Destinations

**Status**: Proposed internal integration contract for Lam/Quan, Duy, Bao/input impact,
and the identified manager/save reviewer. This is documentation, not an implemented API.
No external network/API service is introduced.

## Existing surfaces verified in source

| Current surface | What it does | What it does not establish |
| --- | --- | --- |
| Stage._ready / GameManager.register_stage(stage) | Registers one current stage and connects death | No finite-wave initialization handshake |
| Stage.place_player_at(id) | Resolves descendant spawn point and snaps camera | No checkpoint rank or ownership repair |
| GameManager.change_stage(path, spawn, keep_health) | Deferred scene load after existence/health checks | No sprint B3 guard or compatibility policy |
| GameManager.set_checkpoint(stage,id) | Stores pair and saves immediately | No forward-only or nearby-F validation |
| GameManager.flags / unlock_door / is_door_unlocked | Persistent Boolean primitives | No B1/B2 clear semantics or round-reset lifecycle |
| SaveSystem.load_data/save_data/save_path | Version-1 dictionary JSON and configurable path | Caller must retain unrelated fields |
| InteractiveArea3D signals interacted/interaction_available/unavailable | Nearby input and generated F prompt | Missing project binding; Player.can_interact not implemented |
| EnemyZone.alive_count() and timer | Concurrent continuously replenished enemies | Not finite-wave completion, not a defeat rule |

## Proposed Duy-facing capability contract

The names below are review proposals, deliberately not references to existing methods.
Duy may supply equivalent names without altering approved player outcomes. Agree exact
script/owner before connecting; do not create a dummy production wave system in this feature.

| Proposed capability | Producer/caller -> consumer | Required semantics |
| --- | --- | --- |
| floor_completed(floor_id) notification | Duy -> map ProgressBridge | b1/b2 only; genuine finite-wave completion under Duy's rules; idempotent repeated notification |
| restore_floor_progress(cleared_floors) initialization | bridge -> Duy-owned implementation | Provide durable clear state before enemy starts; cleared floors do not respawn unfinished rounds |
| restart_unfinished(floor_ids, reason) command | bridge/manager lifecycle -> Duy | Reset only unfinished requested rounds for death or application restart; no enemy health/partial progress restored |
| readiness/completion acknowledgement or equivalent initialization barrier | Duy <-> bridge | Resolve child _ready auto-start ordering, reset once per recovery, initialize destination before gameplay acceptance |

Required floor identity is b1/b2, not Y position or nearest enemy zone. A local Stage child
ProgressBridge can coordinate restoration, notifications and gate state; it is not a new autoload.
Duy remains responsible for wave counts/composition, defeat conditions, actual spawning/reset,
and readiness mechanics. No signature shown here grants Lam permission to implement those systems.

### Completion and persistence ordering

1. Load/validate progress without deleting unrelated data; resolve destination eligibility.
2. Present restored cleared-floor/unlock state to Duy before waves are allowed to auto-start.
3. Duy initializes only unfinished floors and acknowledges readiness by the agreed mechanism.
4. Resolve spawn/camera and gate state; verify one registration and no duplicate wave reset.
5. On genuine b1 completion, persist b1-clear and parkour-unlocked together, then open map access.
6. On b2 completion, persist b2-clear and open the placeholder gate; SprintBoundary stays solid.
7. Save only durable checkpoint/clears/unlocks, never individual enemy health/partial wave progress.

Existing child EnemyZone._ready starts its timer. A parent bridge _ready alone is insufficient;
Duy's handshake is an explicit blocker, not assumed functionality or permission to edit his zones.
The lifecycle must also work across existing same-stage death reloads. Cleared B1 cannot
restart just because the scene reloads while unfinished B2 restarts.

### Approved reset matrix

| Event | Checkpoint outcome | Duy outcome | Preserve |
| --- | --- | --- | --- |
| Death before b1 clear | B1 activated point or default | Restart b1 | Unrelated durable data |
| Death in b2 without b2 activation | B1 activated point or default | Restart unfinished b2 | b1 clear, parkour unlock |
| Death after b2 activation | b2_start | Restart unfinished b2 | Cleared floors, b1 clear/parkour unlock |
| Application restart | Persisted eligible checkpoint, else B1 default | Restart unfinished floor waves | Checkpoint, clears, unlocks; no enemy health/partial wave restoration |

No other wave definition/restart policy is inferred. Test adapters with fixtures separately
from actual waves; a synthetic completion cannot pass real wave-gated gameplay acceptance.

## Proposed checkpoint request boundary

Basement-local detector accepts a nearby living Player and a fresh F interact event; arrival
alone never saves. Local dialogue eligibility must be checked, because the generic helper's
can_interact fallback is permissive. Avoid overlapping zones; test conflicting interactions.
Do not add a Player method or rebind his actions without Bao coordination/approval.

Proposed manager request: activate_basement_checkpoint(stage_reference, checkpoint_id).
Not an existing API. Validate current Stage, canonical scene identity and declared ID mapping;
compute rank from the trusted b1_start/b2_start table, not caller-supplied rank. Return an
accepted/unchanged/rejected outcome so feedback reflects actual acceptance.
A lower rank cannot replace the active higher checkpoint. Repeating the current request is
idempotent and must not issue another progression write. Preserve unrelated stages' stock
checkpoint behavior; do not impose basement ranks on the whole game.

On acceptance only: persist the pair, tint local AnimatedSprite3D, and show the exact local
Label3D text `Checkpoint activated.`. Restore active-marker state from saved progress after
load. Keep existing one Hud CanvasLayer and health logic unchanged. Temporary helm visuals
and instance-local tint satisfy the sprint; no new art/shared material-library edit.

## Destination and compatibility boundary

Canonical identities are listed in research R4. Proposed sprint guard sits at the existing
manager loading boundary before _changing/pending_spawn/player_health or deferred scene load.
Reject preserved B3 path and UID consistently for startup, respawn and interaction calls.
Do not rely only on removing one Door: valid B3 saves currently bypass that protection.

- Known standalone B1/B2 test checkpoint references: approved reset of checkpoint pair only
  to continuous B1/default spawn; do not migrate old locations or discard other data.
- Valid continuous-stage b1_start/b2_start: preserve and honor forward-only progression.
- Known B3 reference: refuse B3 load and report the concrete conflict, preserving file/data.
  Recovery destination and user-facing handling are NOT DECIDED. Do not redirect/reset/delete
  or claim this fixture passes recovery acceptance until the user supplies a policy.
- Other unknown/missing references: explicit case review; not covered by legacy approval.

Save update is a merge at manager boundary: retain loaded unknown top-level fields, preserve
unrelated flags, update only owned stage/checkpoint/clear/unlock fields. Current save_game()
reconstructs three fields, so reuse without this narrow adjustment would lose unrelated data.
Do not call new_game(), delete_save(), or a blanket reset() as compatibility handling.
Keep SaveSystem serializer/version and real save paths untouched during tests.

## Review boundary and failure evidence

Lam/Quan review scene owners, checkpoint placement, bridge/gate consumers and safe map area.
Identify shared manager/input/save reviewer before editing those files. Duy reviews producer
interfaces, readiness and lifecycle; Bao reviews input/player impact and approves any player
change. No ownership transfer is implied.

Record stage path/UID, checkpoint, reason, durable state, requested unfinished floors and actual
outcome for validation. Do not add a telemetry service. Any missing interface, wrong owner,
unsupported save, duplicate reset/load, new error, or blocked route is recorded as a failure
or blocked check, not hidden by a fallback or fake clear event.
