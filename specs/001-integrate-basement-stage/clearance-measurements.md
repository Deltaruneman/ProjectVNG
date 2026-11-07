# Ceiling/headroom measurements — planning evidence

**Date:** 2026-11-05. **Scene:** `levels/level_1/basement_full.tscn`.
**Disposition:** baseline reproduction and inspection only; no fix implemented.
T034 is partial: focused measurements exist, but route-specific sweeps and review
remain. T035-T040 are not executed. See [third-pass proposal](third-implementation-plan.md)
and [candidate map](clearance-candidates.svg).

## Reproduction and actual outcome

Godot `4.7.2.stable.official.ed1daf0bf`, fixed physics at 60 Hz. A fresh disposable
copy includes the current uncommitted checkpoint phase; original project never
launched. The existing Player/controller/colliders and scene geometry are unchanged
in the copy. A diagnostic script was added only to the disposable copy.

1. Load the combined scene with no real save; stop EnemyZone timers in the diagnostic
   instance only to remove combat interference. No production enemy code changed.
2. Place the existing Player at (25,1.2,5), let it settle naturally to Y≈1.010.
   Clear directional keys. No controller/velocity injection after the initial setup.
3. Send a fresh physical Space press/release, then a second press/release when the
   controller first reaches Fall after the initial apex (about frame 35 in the trace).
4. Release jump, allow 220 physics frames after the first pulse, then hold physical D
   for 30 frames. Do not teleport, reset FSM, reload or kill the player to recover.
5. Actual: root stays near (25.337,6.144,5.429), not grounded. Last vertical sample has
   velocity.y≈-62 despite fixed position. B2/World contacts have horizontal normals
   (e.g. .707,0,.707), is_on_wall=true and is_on_ceiling=false. D moves X by 0;
   state enters Wall_slide. Health stays 3. This is a reproduced softlock.
6. A separate rendered repeat starting exactly X=25 (no initial lateral drift)
   reproduced Y≈6.14416, no landing, no horizontal recovery. Screenshots show the
   player partly buried in the upper floor; B2 visibility switching is not evidence
   of landing on B2.

| Requested start | Baseline result after vertical double jump | D recovery over 30 frames |
| --- | --- | --- |
| (-3,1.2,14), B1 outside upper-floor footprint | Lands at Y≈1.0107; peak root≈6.9443; Idle | ΔX≈2.90, moves normally |
| (25,1.2,5), B1 under B2 | Trapped at Y≈6.1442; Fall, not on floor | ΔX=0, Wall_slide |
| (31,1.2,15), B1 under B2 | Trapped at Y≈6.1442; Fall, not on floor | ΔX≈-0.092, still trapped/Wall_slide |
| (35,1.2,10), B1 under B2 | Trapped at Y≈6.1443; Fall, not on floor | ΔX=0, Wall_slide |
| (35,1.2,25), B1 under B2 | Trapped at Y≈6.1442; Fall, not on floor | ΔX=0, Wall_slide |
| (49,7.2,5), B2 | Lands at Y≈7.0006; peak root≈12.9342; Idle | ΔX≈2.90, moves normally |

The six-case headless sequence has minor initial X drift (~0.1) from scenario-reset
input timing; the independent rendered single-case repeat removes that ambiguity.
This is automated real input/physics reproduction, not Lam/Quan manual acceptance.

## Collision and headroom

| Element | Inspected/observed geometry | Consequence |
| --- | --- | --- |
| Player body | Capsule radius .7998047, height 1.6977539, center Y=.84887695; world/enemy collision mask 9 | Approximately 1.60 m diameter and 1.698 m head above root; HurtArea is not the body |
| B1 walking floor | B1/World/Floor, MVP_library item 26 Floor_UnevenBrick; BoxShape3D 2×.5×2 with local Y offset -.24 | Walking surface measured Y=1.01; solid thickness below it, unlike B2 floor |
| B2 walking floor | B2/World, basement_library floor_ground/path items; ConcavePolygonShape3D, local Y≈1, thickness≈.00001, backface_collision=false | Surface measured Y=7; a thin triangle surface, no solid volume/usable ceiling underside |
| Upward rays from B1 | No hit at all four trap points, even though downward rays from B2 hit the floor at Y=7 | Existing floor does not provide a blocking underside; do not equate floor-plane height with a functioning ceiling |
| B1 geometric separation | Floor 1.01 to upper floor plane 7: ≈5.99 m; standing body top≈2.708 | ≈4.292 m between standing head and upper plane, but current collision permits entering it from below |
| B1 uncovered region | No upward hit from spawn up to Y=21.1 | No blocking roof observed over the sampled uncovered B1 area |
| B2 overhead | No upward hit above B2 sample to Y=27.1 | No roof observed in sampled B2 areas; do not invent an existing B2 ceiling |
| B1 walls | Runtime-transformed shape bounds: Y=1..5 | 4 m walls; measured double-jump root can exceed wall tops |
| B2 walls | Runtime-transformed shape bounds: Y=7..9 and 9..11 | Upper perimeter top≈11; measured B2 double-jump root≈12.934 can exceed it |
| Existing prototype crates | B1/World/B2-Parkour item 67, cells (7,1,0),(8,1,0),(8,2,0), rotated BoxShapes | World tops≈3.5418 and 5.5418; standing head on the upper crate≈7.2396, above B2 floor plane |

Exact upper-crate collision AABB: X≈17.0036..18.0632,
Y≈4.4582..5.5418, Z≈.4582..1.5418. Cell centers are not shape centers
after rotation. Do not use map_to_local alone as a proven landing location.
A proposed ceiling underside at Y=6.8 would leave only 1.2582 m over this
crate, less than the body height. It cannot be blanketed safely over accessible
prototype high ground. Quarantine/close prototype access by reviewed local
containment, or defer that local cap treatment; do not silently trap the player.

The B2 floor currently lacks cell (8,3,0): a 2×2 m opening at X16..18,Z0..2
near the upper crate. Its narrowness/overhanging crate does not make it an
approved route. Candidate A explicitly widens this footprint; see route proposal.

## Root-cause assessment and Bao boundary

**Observed:** collision contacts are B2/World triangle/edge wall normals; position
does not fall although movement is enabled and downward velocity accumulates.
The controller transitions Jump -> Fall, then Wall_slide on directional input.
**Strong geometry hypothesis:** front-face-only thin concave floor allows underside
penetration, then catches the capsule against tile edges. A solid, flat local
underside should prevent entering that surface; this fix is not yet tested.

Bao's dependency is controller interpretation and recovery verification, not an
assigned implementation. Current Jump only transitions on velocity.y<0; second jump
is handled in Fall. Fall can reset jump count on moving wall contact; Wall_slide
clamps downward speed and may reset/allow more jumps. If a correctly oriented solid
ceiling still fails to produce falling, landing, reset jump count and normal movement,
hold that case for Bao's owner review before changing Player/state/physics code.
Do not mask the failure by shrinking the body, changing gravity/jump/dash or forcing
an Idle transition after contact.

## Candidate-location checks

- A: proposed 4×4 opening X16..20,Z0..4; B2 cells X=8,9 / Y=3 / Z=0,1.
  (8,3,0) already absent, three other cells exist. Near existing crates/north wall.
  B1 ground at (16,4) measured Y=1.01; B2 landing reference (20,4) measured Y=7.
  Full landing patch X20..24,Z2..6 and safe retry area remain proposals, not tested routes.
- B: proposed independent central opening X24..28,Z12..16; B2 cells
  X=12,13 / Y=3 / Z=6,7, currently present. B1 ground at (26,14) measured Y=1.01;
  B2 landing reference (31,14) measured Y=7. Proposed landing X28..32,Z12..16.
- Both keep current B1/B2 checkpoint locations away from the opening and avoid
  Hidden wall X≈39,Z8..18. Sampling does not prove a full reachable parkour route.
- Existing B1/World also has three serialized cells using missing library item 34,
  at cell (0,-1,19..21) / world centers (1,-2,39..43). Outside sampled room/route
  candidates. Recorded resource finding, not attributed as this B2/World softlock's
  cause; no library or cell cleanup performed.

## Isolation, evidence and limitations

Disposable root: `C:/Users/CHUNGK~1/AppData/Local/Temp/ArcanaClearance-b288225c951141beb50e576774962fbd`.
Project: its project/ child. Verified user://:
`C:/Users/CHUNGK~1/AppData/Local/Temp/ArcanaClearance-b288225c951141beb50e576774962fbd/userdata-base/ArcanaClearance-b288225c951141beb50e576774962fbd`.
The no-autoload probe confirmed exact path and save_exists=false before gameplay.
Child-only APPDATA points to userdata-base; real progress was never read/copied.
No generators/editor imports ran, and no cache/source changes were copied back.

- Full six-case data: user://clearance-report.json.
- Additional geometry/rays/backface data: user://clearance-spatial.json.
- Transformed collider bounds: bounds.stdout.txt in disposable root.
- Rendered repeat: user://clearance-rendered.json, b1-before-jump.png, b1-stuck.png.
- Logs: isolation.*, clearance.*, spatial.*, bounds.*, rendered-clearance.*.
  The rendered helper's printed report filename is historical/fixed text; the actual
  single-case file is clearance-rendered.json.
- Early helper drafts stopped on a null missing mesh and a wrong MeshLibrary helper
  name; corrected the disposable measurement helper, not project assets/scripts.
  One stalled uniquely identified diagnostic was stopped; no other game stopped.
- Final runs produced reports/captures, with existing certificate-store diagnostics
  in headless runs and 3 ObjectDB/1 resource shutdown leaks. No error-free claim.
- No cap, roof, wall, opening, route, spawn, checkpoint or controller fix implemented.
  No post-fix result, complete floor sweep, lateral boundary escape trial, real enemy
  combat, genuine wave-gated access or route miss/retry acceptance is claimed.
