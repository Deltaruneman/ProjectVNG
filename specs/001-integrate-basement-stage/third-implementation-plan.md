# Third implementation proposal — two reviewed passes

**Planning only — 2026-11-05. No scene/script edits or construction authorized here.**
Target: `levels/level_1/basement_full.tscn`, preserving the existing checkpoint phase,
Hidden, separate B3, libraries, player/enemy systems and working-tree changes.

Review [measurements/reproduction](clearance-measurements.md) and the
[candidate opening map](clearance-candidates.svg). Lam and Quan must choose the
route/opening before pass 2 is built. No choice or teammate approval is recorded.

## Decision and smallest supported fix

The reported vertical B1 double-jump softlock is reproduced under B2 at four points.
B2/World is a front-face-only, nearly zero-thickness concave triangle floor at Y=7.
It is not a solid ceiling. The capsule enters from below and stays caught in wall-like
tile-edge contacts around root Y=6.144; it cannot land or resume ordinary movement.
A separate rendered single-case repeat confirms this.

**Recommend keeping current floor spacing.** The smallest scene-local fix to test
first is a flat, solid BoxShape3D underside beneath the B2 floor over affected B1
walking space, using a local StaticBody3D on world layer 1. Do not change shared
MeshLibrary collision or the Player. A thin slab with top at Y=7 and provisional
underside Y=6.8 is a review candidate, not an implemented or proven dimension.
It prevents entry into the triangle plane while preserving the B2 walk surface.
Do not call it fixed until ceiling contact -> falling -> landing -> movement passes.

Do not use a uniform slab blindly: the existing upper prototype crate tops at
Y≈5.5418, leaving only 1.2582 m beneath a Y=6.8 slab, too little for the 1.698 m body.
That region needs reviewed temporary containment/isolation or a held local treatment.
Do not delete the crates, open the route, or infer they are usable stepping stones.

Turning backface collision on in the shared mesh library, replacing all floor
resources, raising every wall by a multiplier, or changing the player collider/
jump/gravity is broader and less isolated than this first scene-local proposal.

## Pass 1 — B1/B2 ceilings and containment, independent of route choice

**Purpose:** prevent underside penetration/softlock and jumping out of playable
floor bounds; retain a deliberately closed progression boundary while no route
has been chosen. This is safety work, not a wave gate or a finished route.

**Candidate changes after review, scene only:**

1. Add local, flat solid ceiling/slab collision over ordinary B1 walking regions
   under B2; cover dangerous seams with a few aligned rectangular volumes matched
   to measured footprint, not one collider per triangle. Keep B2 floor/top surface
   and all checkpoint IDs/positions intact. Avoid side seams reachable by the body.
2. Add a B1 roof/containment over uncovered walking regions if needed to prevent
   over-wall escape. Use the same reviewed ordinary-ground ceiling plane where
   valid. Existing upright B1 walls end at Y=5, so close the wall-to-ceiling gap
   with local boundary strips up to the cap; a floating roof alone is insufficient.
3. Add B2 roof/top containment plus perimeter continuation where tests justify it:
   B2 currently has no sampled roof, and perimeter tops at Y≈11 while measured
   double-jump root reaches ≈12.934. An underside near Y=13 is a provisional
   six-metre room-height reference, not a final ceiling dimension. Close any gap
   from existing wall top to that roof. Use measured boundary volumes, no global
   library/asset edit or wall-height multiplier.
4. Protect the existing narrow prototype hole/upper crate hazard. Proposed interim
   option: a reversible local guard isolating the stack footprint from B1 movement,
   retaining the cells and preventing access into insufficient headroom while the
   overhead cap is closed. Lam/Quan must agree the temporary guard footprint.
   Without that agreement, leave that local cap/containment treatment explicitly
   held; do not claim complete pass-1 containment or build a low ceiling over it.
5. Keep candidate-opening cap sections modular and closed. Do not cut either
   candidate's floor or make an accidental route choice by exposing one opening.
   Preserve Hidden wall/collision/behavior and do not add a Hidden entrance.
6. Coordinate any necessary B2 terminal collision with T031's independent
   containment boundary; no completion gate, wave binding, transition or B3 load.

**Pass-1 acceptance test, before any route construction:**

- Start from isolated fresh-copy no-save, B1-active and B2-active fixtures.
- At (25,1.2,5), (31,1.2,15), (35,1.2,10), (35,1.2,25), spawn vicinity,
  ordinary floor, ceiling joints, edges and nearby supported high ground:
  press jump; press a second time in the actual eligible Fall state; release.
- Record position/velocity, actual ceiling collider/normal, is_on_ceiling,
  is_on_floor, FSM state and jump count. Require genuine downward-facing ceiling
  contact at the new cap rather than a false wall contact at the floor triangles.
- Without teleport/death/reload/F9/FSM reset, observe fall away, stable supported
  landing within 3 seconds after last contact, then walk in all four directions
  and jump again. Require normal grounded state/jump budget and no ongoing trap.
  Compare with uncapped baseline controls; standing/ordinary jumps retain usable
  headroom. Sample different second-press timings, not one idealized impulse.
- Exercise lateral movement during contact, seams/corners, repeated jumps, wall
  contact and current dash/wall-jump abilities at perimeter/terminal areas.
  Require no escape or B3 load; document unknown cases instead of adding blind walls.
- Test B1/B2 default/checkpoint respawn: same supported endpoints, no intersecting
  cap, correct camera/visibility/one HUD. BUG-003's existing B2 HUD finding remains
  separate and unresolved; do not hide it behind collision passes.
- Check health unchanged for contact/falling/retry, keep combat distinguishable,
  preserve Hidden/B3/library/source hashes and perform focused navigation smoke.
- A player-state failure with correct solid ceiling collision is a Bao review
  dependency. Hold that failure; do not compensate by modifying Player systems.

**What can be built before the route is chosen:** after this plan is approved,
the ordinary-ground anti-snag underside, verified roofs/perimeter strips, supported
spawn regressions, modular *closed* cap sections, and an explicitly agreed temporary
prototype guard. No opening, new stepping path, permanent route access/gate, or
landing cut-out can be built before Lam/Quan choose. Nothing is built during this
planning turn. Where cap height/headroom/guard geometry is unresolved, measure and
hold that portion rather than treating the whole safety pass as accepted.

## Pass 2 — separate B1-to-B2 parkour route after Lam/Quan decision

**Purpose:** deliberately traverse through one chosen opening, with supported B2
arrival and safe B1 retry. It must not rely on head penetration, a ceiling snag,
wall-jump exploits, a scene load, or walking through Hidden.

Top view coordinates below are world metres (X,Z), not screen pixels. B2 floor
cells are 2 m; its local GridMap Y=3 has surface world Y=7. Opening dimensions are
initial review footprints, not validated jump widths or automatically selected routes.

| Candidate | Deliberate opening / B2 cells | Landing and retry proposal | Trade-off |
| --- | --- | --- | --- |
| A — north prototype area | X16..20,Z0..4, 4×4 m; X=8,9 / Y=3 / Z=0,1. One cell (8,3,0) already absent; expand by removing three remaining floor cells only after choice | Supported B2 landing patch X20..24,Z2..6, aim near (22,7,4); B1 floor below stays intact plus retry bay X14..24,Z4..10. Ground/landing reference rays hit Y=1.01 at (16,4) and Y=7 at (20,4) | Reuses prototype vicinity and existing hole, fewer new floor removals. North wall/rotated upper crate and small headroom are significant constraints; do not assume current crates form the route |
| B — separate central route | X24..28,Z12..16, 4×4 m; X=12,13 / Y=3 / Z=6,7, four current floor cells | Supported B2 landing X28..32,Z12..16, aim near (30,7,14); B1 catch/retry X22..34,Z10..20. Rays hit B1 Y=1.01 at (26,14), B2 Y=7 at (31,14) | Clearer separation from old stack/north wall and current checkpoints; needs a newly laid-out approach/platform sequence. More room for a readable landing/retry flow; not yet proven reachable |

Both avoid Hidden wall X≈39,Z8..18 and the B1/B2 checkpoint endpoints. A 4 m
opening minus the 1.60 m body diameter nominally leaves 1.20 m each side when centered;
this is a clearance calculation, not proof of a moving jump through the rim.

**Decision record required:** Lam and Quan select A, B or a revised footprint;
agree entry direction, platform sequence, floor cells to remove, upper landing
setback, safe miss/catch area, and disposition of the old prototype stack/guard.
Record names/actual decision before scene edits. No selection is inferred here.

**Build only after that decision and pass-1 recovery acceptance:**

- Form a separate, readable approach/riser/platform sequence with existing assets,
  measuring each actual collider pose and body sweep. Do not blindly use cell
  centers or copy old crate spacing. Keep existing Player abilities unchanged.
- Remove only chosen B2 floor cells and matching underside/cap section; maintain
  solid ceiling everywhere else. Preserve remaining walls/roof containment.
- Provide a full supported B2 landing outside the hole with capsule/edge clearance
  and a clear walking connection to B2. A rim/triangle edge is not a landing.
- Preserve B1 floor/catch area below each intentional miss; provide a walkable
  route back to takeoff with no new damage/hazard or assumed teleport.
- Run every jump and deliberate miss, including late second jump, head/rim contact,
  side collision, overshoot, fall/landing, health and regain-movement/retry tests.
  Verify physical traversal has no stage reload/re-registration and keeps one
  Player/CameraRig/Hud. Recheck B1/B2 checkpoint spawn and fall catch areas.
- Real B1-clear access/unlock/reset/persistence remains dependent on the existing
  Duy contract/provider tasks T022-T024/T028/T037/T040. Geometry can be isolated
  synthetically; no fake production wave completion or wave-interface implementation.

## Floor spacing, spawns and checkpoints

**Keep the current ~6 m floor separation for the smallest fix.** Local underside/
roof/boundary volumes do not require spawn/checkpoint movement or save migration.
Recheck default/B1 endpoint (-3,1.2,14) and B2 endpoint (49,7.2,5) against the caps.

If unimpeded full double-jump height throughout B1 is a separate design requirement,
the measured free-space root rise≈5.934 plus 1.698 m body needs >7.63 m floor-to-
ceiling clearance plus margin. Current geometric gap≈5.99 m cannot provide that.
A .2 m slab would require roughly another 1.85 m of separation before safety margin
for this tested timing alone. That is not a universal required height or approval
to raise B2; wall resets, timing and high-ground starts require separate measurement.

| Possible spacing edit | Impact requiring review |
| --- | --- |
| Move B2 container upward by Δ | B2 World, wall/torch/marker/pathfinder transforms and its checkpoint/Spawn child move together. Stage ownership and b2_start ID stay the same, but saved recovery resolves to a new world location. Must retest all B2 support/camera/restart cases |
| Change only B2 GridMap cell Y | Checkpoint/Spawn, lights, markers and other B2 nodes do **not** automatically follow; explicit reconciliation required |
| Current B1 default/root Spawn | Remain at current B1 height unless deliberately moved; do not translate them just because B2 changes |
| Existing prototype/route/Hidden adjacency | Vertical gaps, takeoffs, landing, retry, upper-crate aperture and Hidden wall adjacency must be remeasured; old route assumptions cannot survive an unreviewed spacing change |
| basement_floor_visibility.gd | Update/review floor_height **and** switch_margin/threshold behavior as needed. Current B1→B2 threshold is base_height+switch_margin=5.5; changing floor_height alone does not move that first threshold |
| Save compatibility | Saves store stage path/ID, not coordinates; keep IDs/path. No migration is inherently needed for a container move, but correct new endpoint resolution must be proven; do not reset valid progress |

## Review stop and ownership

Lam/Quan review this safety proposal and choose the later route. Bao reviews any
actual controller dependency; no ownership transfer or Player edit is authorized.
Duy's enemy/wave behavior and interfaces remain unchanged. No generator, shared
library rewrite, B3 access, Hidden redesign, commit/push or branch change.

**Review requested before any scene or script edit.** Planning evidence is not
acceptance, and neither pass is marked built or fixed.
