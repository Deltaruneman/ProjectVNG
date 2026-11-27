# Data Model: Basement Stage and Progress

> T087 current persistence model is appended below. Older proposed tables and reset/B3
> ineligibility statements remain historical. The save serializer still uses JSON version1.

**Status**: Proposed integration model; existing primitives are distinguished below.
No fields/code were implemented. Names of new flag keys and Duy interfaces require joint review.

## Stage identity

- Canonical playable stage: `res://levels/level_1/basement_full.tscn` (UID in research R4).
- Playable floor identity: b1 or b2, explicit rank 1 or 2; not inferred from height or node order.
- Separate B3 remains a resource, not an eligible active stage or checkpoint destination.
- Runtime references (current_stage, pending_spawn, player_health) already exist in GameManager;
  do not persist node pointers or create a second stage registry.
- Stage owns one Player, CameraRig, Hud, and registration; root naming remains Stage.

## Checkpoint definition and progress

| Field | Status | Validation |
| --- | --- | --- |
| stage reference | Existing persisted stage string | Canonical continuous stage for new basement progress; path/UID normalization uses explicit identities |
| checkpoint id | Existing persisted string | b1_start/b2_start, unique in active Stage; default empty means B1 starting point |
| floor/rank | Proposed validated definition table | b1_start -> b1/1, b2_start -> b2/2; not trusted from arbitrary saved rank |
| Spawn | Existing Marker3D pattern | Child of checkpoint; floor support/camera placement playtested |
| owner | Existing scene ownership | Active Stage, not an inherited visual's foreign floor root |
| activation availability/tint/message | Proposed transient local UI | Nearby eligible Player, F press; accepted activation only; no checkpoint on arrival |

Transition: no checkpoint -> B1 or B2 only through eligible explicit activation; B1 -> B2;
B2 -> B1 is rejected without saving or success feedback. Same-current checkpoint is idempotent;
repeated F must not duplicate progression or spawn. The B1-clear dependency governs progression
through the map, not a new checkpoint-wave rule.

Temporary marker tint derives from restored checkpoint identity. Feedback text is exactly
`Checkpoint activated.`; no new UI singleton or final asset is required.

## Durable clear/unlock state

Use existing flags dictionary as the minimal storage candidate. Proposed owned Boolean keys:
`basement_b1_cleared`, `basement_b2_cleared`, `basement_parkour_unlocked`.
These are proposed names, not existing keys; Duy/shared reviewer must agree before implementation.
Do not overwrite unrelated flags. Cleared floors are durable, not reconstructed from enemy count.
B1 clear and parkour unlocked advance together and remain true across death/restart.
B2 clear drives the terminal gate; a cleared floor is never restarted as unfinished.

The bridge restores state before Duy starts rounds. Existing zones auto-start in child _ready;
that ordering is not solved by a parent callback alone. Contract supplies a coordinated handshake.

## Ephemeral unfinished-round state

Duy owns active wave/round/enemy state. It is not added to the save schema this sprint.
Do not serialize enemy health, partial-wave indices/counts, or individual enemies. Reset requests
identify unfinished playable floors and reason; Duy defines mechanics, not Lam's map adapter.
No wave counts/composition/defeat thresholds are invented here.

| Trigger | Respawn/location | Round request | Durable state |
| --- | --- | --- | --- |
| Death before B1 clear | B1 checkpoint/default | Restart B1 waves | Retain unrelated durable state |
| B2 death before B2 activation | B1 checkpoint/default | Restart unfinished B2 waves | B1 clear and parkour unlock remain |
| Death after B2 activation | B2 checkpoint | Restart unfinished B2 waves | B1 clear/parkour unlock and cleared floors remain |
| Application restart | Activated B1/B2 checkpoint, else B1 default | Restart unfinished floors through agreed initialization | Checkpoint, clears, unlocks persist; no saved enemy health/partial wave progress |

A same-stage death reload is existing manager behavior; physical B1/B2 travel never reloads.
Avoid duplicate round resets from both death and scene-start callbacks through agreed lifecycle
ordering. A reload alone is not proof that cleared/unfinished floor behavior is correct.

## Save envelope and narrow compatibility

Existing version 1 carries stage/checkpoint/flags. Proposed manager implementation retains
loaded unknown top-level values, overwrites only its owned fields, and merges flag changes.
SaveSystem continues whole-dictionary serialization; no version bump or new save service.
Existing save_game currently discards unknown top-level values; minimum payload retention is
necessary to honor unrelated-data preservation, including during approved legacy resets.

Classify known standalone B1/B2 path/UID references explicitly. Their old test checkpoint pair
may reset to continuous stage + empty checkpoint (B1 default), preserving other data and flags.
Do not apply substring/basename matching or reset valid continuous-stage B1/B2 IDs.

B3 references are a distinct blocked class. They must not load B3; preserve their save file,
checkpoint and unrelated data. No destination/remap/reset is selected in this model.
Unknown stage/checkpoint/version cases are not silently absorbed into the approved legacy class.

## Gate state

- ParkourAccessGate: closed while B1 uncleared; open after restored/received B1 clear.
- CompletionGate: closed while B2 unfinished; open after restored/received B2 clear.
- SprintBoundary: independent collision stays effective in both CompletionGate states.
- HiddenGate_B1_5: preserved wall/collision/behavior; not part of floor-clear gate state.

Gate visual/collision nodes are map-owned. No gate stores target_stage or invokes change_stage.
Safe missed-jump landings/retry surfaces are map geometry, not lethal-fall or damage entities.


## T087 implemented model — explicit B3 identity, no silent reset

| Entity/field | Current meaning |
| --- | --- |
| combined stage + b1_start / b2_start | Trusted rank1 / rank2; forward-only explicit activation |
| separate basement_b3 + b3_start | Trusted rank3; explicit F, owned declaration + child Spawn |
| basement_checkpoint_contract | Top-level discriminator `explicit_b3_v1`, written only by accepted new B3 activation |
| flags.b2_cleared | Existing persistent entry condition; required for supported B3 checkpoint too |
| pending_spawn=b2_up | Ephemeral main-scene door arrival; never checkpoint progress or saved coordinates |
| disabled exit | Door_b3_exit targets empty, transition_enabled=false, no interaction Area/prompt; visual/collision stay |

Example synthetic new save (other owned/unknown payload fields are retained by merge):

```json
{"version":1,"stage":"res://levels/level_1/basement_b3.tscn","checkpoint":"b3_start","basement_checkpoint_contract":"explicit_b3_v1","flags":{"b2_cleared":true},"skill_points":10}
```

New contract path/UID aliases normalize in memory; do not rewrite disk on load. Unmarked
old B3, wrong ID, future contract, missing clear and other unknown pairs remain held;
keep stage/ID/payload/SP/flags and file bytes, no guessed migration. Exact legacy B1/B2
pairs retain equivalent checkpoint ID, replacing the old reset-to-default policy.

Death/restart reads the checkpoint pair, not the last door destination. Thus active B3
+ runtime main/B2 still recovers B3; travel to B2 uses only pending_spawn. Scene geometry
is not serialized. Measured B2 door arrival=(38.1885,11.17303,8.2), B3 checkpoint Spawn=
(47,1.2,11), surfaces≈11.01/1.01 respectively. Positions are existing markers, not new
save fields or assumed permanent map design. No player/boss/partial-wave state added.
