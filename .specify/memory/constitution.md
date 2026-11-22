# Tower of Arcana: Day & Night Constitution

## Core Principles

### I. Ownership and Coordination

Implementation ownership MUST follow these boundaries:

- **Lam**: map logic and design with Quan; Potion Crafting; Potion Loot Drops.
- **Quan**: collaborative map design and development.
- **Bao**: player movement, combat, skills, and Skill Tree.
- **Duy**: enemy AI, mobs, and bosses.

Being team leader MUST NOT transfer teammates' implementation work to Lam.
Before changing another owner's systems, contributors MUST coordinate with and obtain
approval from the affected owner. Tasks and reviews MUST record applicable approval.
These boundaries preserve accountability while allowing agreed collaboration.

### II. Evidence Before Claims

Findings and progress reports MUST distinguish:

- **Static findings**: observations from source, scenes, resources, or documentation;
  cite the inspected location and state what it establishes.
- **Hypotheses**: suspected causes or behavior requiring investigation;
  record the uncertainty and the check needed to resolve it.
- **Runtime-verified behavior**: behavior observed in a Godot run;
  record the tested scene, conditions, steps, and actual result.

A gameplay bug MUST NOT be claimed fixed without suitable verification of the reported
behavior and relevant acceptance criteria. Static inspection alone MUST NOT be presented
as proof of runtime behavior. Incomplete checks MUST remain explicit limitations.

### III. Small Scope and Integration Preservation

Work MUST use small, reviewable tasks with an explicit purpose and affected files or systems.
Contributors MUST preserve existing integrated Prototype 1 work and pre-existing working-tree
changes. Unrelated features and refactors MUST be excluded from the task.
Necessary scope changes MUST be recorded and reviewed with affected owners before proceeding.
This keeps changes assessable within the existing game.

### IV. Map and Resource Safety

Contributors MUST review Git status and relevant diffs before making changes, identify
pre-existing work, and preserve existing scene and resource dependencies.
Basement generators and mesh-library generators MUST NOT run without explicit permission
for the proposed run and its output scope. Permission for ordinary map editing does not
authorize generator execution.

Tracked `.godot` caches MUST NOT be discarded or hand-edited. Unexpected cache or resource
changes MUST be reported and reviewed rather than silently cleaned up.
Map changes MUST identify affected scenes and resources so integration impacts can be reviewed.

### V. Acceptance Criteria and Appropriate Validation

Every implementation task MUST define observable acceptance criteria and appropriate checks
before implementation. Check selection MUST follow the behavior and integration risks involved;
automated tests are required only when appropriate to the task.

Changes affecting collision, camera, traversal, or respawn behavior MUST receive Godot
playtests covering the affected behavior. Static checks or headless loading alone do not
satisfy these playtest requirements. Verification records MUST include checks performed,
actual results, checks not run with reasons, and remaining limitations.
An implementation awaiting required verification MUST be reported as unverified.

### VI. Explicit Questions and Shared Infrastructure Boundaries

Unknown design details MUST remain explicit questions in the feature specification or planning
artifacts until answered by the relevant owner. Contributors MUST NOT invent gameplay rules
to fill gaps. Work that depends on an unresolved answer MUST wait for that answer;
independent work may continue.

Before shared infrastructure changes begin, the plan MUST identify affected systems,
dependencies, owners, and the review boundary: the files or interfaces under review and who
must approve them. Sprint-specific architecture decisions MUST stay in the feature
specification rather than becoming permanent project-wide rules in this constitution.

## Project Context and Deadline

Tower of Arcana: Day & Night is an existing Godot game with an integrated Prototype 1.
Plans MUST start from the current integrated project and identify the incremental change.
They MUST NOT assume a new project or recreate existing systems without an explicitly
reviewed need within the task scope.

The **final build deadline is December 15, 2026 (2026-12-15)**.
Planning MUST account for implementation, integration, and required validation before that date.
The deadline does not waive ownership approval or evidence requirements.

## Development Workflow and Review

Before implementation, each task MUST record its owner, scope, acceptance criteria,
appropriate checks, unresolved questions, and any cross-owner approval or shared infrastructure
impact. Review MUST begin from existing Git changes and identify dependencies to preserve.

Feature specifications MUST retain sprint-specific architecture decisions and their rationale.
Plans and task lists MUST apply the constitution to the concrete feature rather than copying
generic project setup or unrelated infrastructure work into the integrated game.

At review, contributors MUST assess scope, ownership coordination, dependency preservation,
and validation evidence against these principles. Handoffs MUST distinguish implemented work
from runtime-verified behavior and list outstanding questions, checks, and limitations.

## Governance

This constitution governs project planning, implementation, and review. Feature specifications
and task plans MUST comply with it; temporary sprint decisions MUST NOT silently amend it.

Amendments MUST document the proposed rule, rationale, impact on current work, and version
change. Affected owners MUST review and approve changes to their ownership or obligations
before the amendment is adopted. Contributors MUST record adoption and amendment dates and
identify any required documentation synchronization. Every implementation review MUST check
compliance and record unresolved deviations for resolution before declaring the task complete.

Versions follow semantic versioning: MAJOR for incompatible removals or redefinitions of
governance or principles; MINOR for new principles or materially expanded guidance;
PATCH for clarifications that do not change obligations. This first completed constitution
establishes version 1.0.0; its ratification date records adoption of these supplied principles.

**Version**: 1.0.0 | **Ratified**: 2026-11-04 | **Last Amended**: 2026-11-04
