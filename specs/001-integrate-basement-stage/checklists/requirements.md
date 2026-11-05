# Specification Quality Checklist: Continuous B1/B2 Basement Stage Integration

**Purpose**: Validate specification completeness and quality before planning
**Created**: 2026-11-04
**Feature**: [spec.md](../spec.md)
**Review Ownership**: Requirements-quality review maintained with the specification.
**Marker Semantics**: Checked means requirements quality reviewed, not implemented,
playtested, or approved as runtime-complete.

## Content Quality

- [ ] No implementation details (languages, frameworks, APIs).
- [x] Focused on user value and business needs.
- [x] Written for non-technical stakeholders, with technical evidence isolated.
- [x] All mandatory sections completed.

## Requirement Completeness

- [x] No active NEEDS CLARIFICATION markers remain; Q1-Q4 are resolved.
- [x] Approved sprint requirements are testable and unambiguous within the recorded scope.
- [x] Success criteria are measurable.
- [x] Success criteria describe observable outcomes without prescribing algorithms.
- [x] Acceptance scenarios reflect final decisions without obsolete B3 access or Hidden-entry tests.
- [x] Edge cases are identified.
- [x] Scope and subsequent map tasks are clearly bounded.
- [x] Dependencies and assumptions are identified without inventing wave definitions.

## Feature Readiness

- [x] All functional requirements have acceptance coverage in stories, measurable outcomes,
  or explicit scope/review boundaries.
- [x] User scenarios cover primary sprint flows.
- [x] Requirements define measurable outcomes and distinguish foundation from subsequent map acceptance.
- [ ] No implementation details leak into specification.

## Notes

- Review result: final user decisions are recorded consistently; Q1-Q4 are resolved.
  No obsolete gameplay question remains. Planning and implementation have not begun.
  Requirements quality does not establish interface availability or runtime success.
- The two generic no-implementation-details items remain unchecked intentionally:
  Option B's named scene boundaries, Godot validation, and approved F interaction are
  explicit user constraints. Technical baseline evidence stays isolated; it is not a plan.
- Q1 retained: FR-009, User Story 2 scenario 8, and SC-003 permit only explicitly identified
  old standalone B1/B2 test-checkpoint resets to continuous B1. No old-location migration
  is required. Preserve unrelated data and valid new-stage checkpoints.
- Q2 retained/updated: FR-002, User Story 1 scenarios 3-4, and SC-002 preserve Hidden B1.5
  and HiddenGate_B1_5 geometry/collision/behavior/connections. Necessary reference repairs
  need documented reasons and preservation checks. Entrance design, opening, always-open
  access, wave-clear linkage, and Hidden entry/exit acceptance remain excluded this sprint.
- Q3 resolved: FR-012/015/016/018, User Story 2 scenarios 3-6, and SC-007/009 specify:
  before B1 clear, death returns to B1/restarts B1; B2 death before activation returns
  to B1/restarts unfinished B2; after B2 activation, death returns to B2/restarts unfinished
  B2. Earned B1 clear/parkour unlock persist, including B2 death before activation.
  Restart preserves activated checkpoint, cleared floors, and unlocks; unfinished waves
  restart. Enemy health and partial wave progress are not saved this sprint.
- Q4 resolved: FR-008/017, User Story 2 scenarios 1-2, and SC-008 require nearby standing,
  an interaction prompt, F activation, marker color change, and "Checkpoint activated."
  Checkpoint progression is forward-only; reaching a floor alone does not activate it.
  Temporary markers suffice. No final art or particular final marker color is invented.
- Fall safety: FR-019, User Story 4 scenario 3, and SC-010 require falling/retrying checks
  with no fall damage, lethal falls, or new hazards. Recovery is not assumed to teleport.
- B3 scope superseded: FR-004/005/020, User Story 3, and SC-004/011 require no B3 access
  or loads this sprint. B3 round trips, B3 checkpoint tests, and entry/return endpoints
  are removed from acceptance. Preserve the separate B3 scene and existing work.
- B2 clear opens a placeholder gate toward B3 while a safe boundary still prevents leaving
  the playable area. Opening this gate is a subsequent map task dependent on Duy's wave
  completion interface, never authorization to load B3.
- Nov 4-7 scope is explicit: stage integration and B1/B2 spawns/checkpoints form the foundation;
  ceiling geometry/clearance, parkour completion after B1 clear, and the B2 terminal gate
  are subsequent map tasks. SC-010/011 are not satisfied by foundation completion.
  Final visual polish does not defer the approved parkour completion/safety scope.
- D1/D4: wave completion/reset/persistence require coordinated interfaces with Duy and
  affected save/checkpoint reviewers. No enemy-system implementation, wave counts,
  composition, or defeat definitions are authorized or invented.
- D2: map geometry work uses current player abilities; movement changes require Bao's
  coordination and approval. Confirmed pre-existing defects remain acceptance blockers.
- D3/D5: all runtime acceptance remains unverified. No Godot checks/playtests, generators,
  gameplay edits, branch changes, planning, implementation, commits, or pushes ran here.
- Residual exception boundary: missing/unknown save references outside the identified
  legacy B1/B2 set require an explicit case decision if encountered. Q1 is not blanket
  reset approval, and no exception may enable B3 loading. This is not a reopened Q1-Q4 rule.
- Future direction remains one checkpoint per floor; Garden elevators, future floor travel,
  boss work, Hidden entrance, B2 visual completion, and final checkpoint art stay out of scope.
