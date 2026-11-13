# Implementation changelog

## T089 Inventory key B (2026-11-13)

User explicitly requests B for the bag. Added the `inventory` action with physical B to `project.godot` so the default is visible in the editor Input Map and runtime, in addition to the existing GameSettings fallback. Existing saved settings inspected: no inventory override and no B attack binding. No user settings file modified; remapping support remains intact.

Files: `project.godot` (declarative B binding), `specs/001-integrate-basement-stage/tasks.md` (scope/status), `specs/001-integrate-basement-stage/validation.md` (evidence), this changelog, `docs/validation/inventory-combat/b-key.log` and `b-key-errors.log` (final rendered regression evidence). Final Godot 4.7.2 Compatibility fixture passes 48/48, including B opening and closing/resuming the bag. Initial headless run passed hotkey checks but failed its physical-window resolution assertion; rendered rerun resolves that fixture limitation. Existing UID fallback and shutdown retained-object/resource diagnostics persist. No other bindings changed, no native manual acceptance or commit/push claimed.

## T088 Lightning 2, ESC, idle dot and inventory (2026-11-13)

User requests removal of lightning-2 teleport, horizontal shooting, ESC improvements, a tiny white dot while not aiming, and a simple equipment/consumable foundation. User explicitly confirms a usable system with sample items. Bao-owned Player/UI implementation with an optional GameManager save field; no map, enemy AI, crafting or drop changes. No teammate or balance acceptance claimed. Starting dirty UID cache and medieval wood texture import sidecar were preserved, never reset by hand.

Included files and purpose:
- `scenes/player/player.gd`: horizontal lightning-2 endpoints and removal of overhead strike/teleport helpers; connect inventory stat recomputation, equipment bonuses, non-healing equip changes, timed consumable effects with refresh/expiry and 1s use cooldown; quick-use input and idle-dot layer. Original skill damage/stun/reach/cooldown retained.
- `scenes/player/battle_vfx.gd`, `scenes/player/horizontal_lightning.gd` and generated UID: depth-tested, camera-facing horizontal beam with correct authored endpoints and short fade/cleanup.
- `tools/export_lightning_beam.mjs`; `assets/effects/pixelfx/lightning/horizontal-beam/{horizontal-beam.png,horizontal-beam.json,contact.png,README.md}` and PNG import sidecars: recolored bundled arcane-beam export, timing/pivot instructions, reproducibility and MIT/Sprite Fusion attribution. Upstream library and protected slash/shield assets unchanged.
- `scenes/player/skill_aim_reticle.gd`: tiny white idle-dot mode at existing raised aim point, hidden for pause/held aim/dialogue/death/cinematics; held reticle unchanged.
- `scripts/items/item_catalog.gd`, `item_inventory.gd` and generated UID sidecars: seven data-driven sample items, three unique equipment slots, bounded consumable stacks, one quick selection, validated ID/count/slot restore, grant/equip/unequip/use APIs and change signal.
- `scripts/autoload/game_manager.gd`: inventory init/reset/new/legacy samples, optional primitive save field, preserve unknown fields and version. Samples do not auto-equip; saved depleted stacks are never refilled.
- `scripts/autoload/game_settings.gd`: remappable B inventory/Q quick-use actions; preserve old custom keys when newly added defaults collide.
- `ui/inventory_panel.gd` and generated UID: three equipment cards, list/details, stat comparison and one equip/quick-assign action; explicit empty state.
- `ui/pause_menu.gd`: compact home, inventory page and shortcut, shared pause/mouse ownership, explicit aim cancellation, back/close handling, clipped content, tighter spacing and cached preview audio generation.
- `ui/player_hud.gd`: event-driven quick-item/count/key display below health, compensating for pixel HUD scale.
- `ui/skill_tree_layout.gd`: lightning-2 description matches horizontal shot without teleport.
- `tests/inventory_combat_test.gd`: actual-Player gear/buff/consumption checks, validated/unknown-field save roundtrip and fresh-process restore, key migration, damage/stun/position/beam checks, ESC/input/focus/settings/dot/UI layout and UI equip checks. Disk writes confined to fixture paths.
- `docs/inventory-equipment.md`: usage, explicit sample balance, grant API and future loot ownership, persistence boundaries.
- `docs/validation/inventory-combat/`: import/orb regression/rendered/small/restart logs; home/inventory/dot/beam screenshots at normal and small sizes; fixture JSON save and legacy key config. Final evidence supersedes early layout/import runs.
- `specs/001-integrate-basement-stage/tasks.md`, `validation.md`, `docs/implementation-changelog.md`: pre-implementation scope and actual validation record.

Verification: final Godot 4.7.2 Compatibility suite passes 48/48 at 1280x720 and 48/48 at verified 960x540, plus fresh-process save restore 4/4. Prior orb regression headless passes 87/87. Export contact sheet and final beam/dot/ESC/inventory screenshots inspected. Stock pixelfx `check.mjs arcane/arcane-beam` passes without warnings. New test confirms no lightning teleport, horizontal world endpoints, retained actual target damage/stun and beam cleanup; gear affects Player without double stacking/free armor healing; consumables reject no-effect/cooldown/dead/dialogue/paused/empty use, refresh buffs without stacking and expire; save keeps depleted stacks/equipment/quick selection and foreign fields. ESC settings cancel/back/resume and both bag hotkey directions pass; all home actions and inventory primary action fit without outer scrolling. `git diff --check` passes with existing line-ending notices.

Corrections/limits: first import found two inferred bool types in UI; made explicit. Visual QA caught pixel-HUD scale and inventory action clipping; reduced HUD label size, compacted equipment/details and added containment assertions. Small-window test initially reset itself to 1280 via settings; final fixture explicitly applies 960 and asserts actual size. Final rendered logs have no SCRIPT ERROR; pre-existing UID fallback and exit diagnostics remain (3 ObjectDB instances, 1 retained resource). Native full-map feel, full original settings suite, manual balance and reviewer acceptance remain pending. No loot/chest/crafting connection, physical equipment art swap or commit/push. Temporary item buffs/current HP are not saved; inventory/equipment persist with existing checkpoint save semantics.

## T087 Raised skill aim and orb depth (2026-11-13)

User reports skill art overlaying the Player and asks to move default aim up slightly. Static cause: orb art used the foreground PixelFX CanvasLayer, bypassing 3D depth. Bao-owned Player aiming/presentation scope is authorized; camera rig, map/enemy and gameplay balance are unchanged. Prior uncommitted parry/orb work and dirty tracked cache are preserved; no teammate approval claimed.

Included files:
- `scenes/player/skill_aim_reticle.gd`: shared normalized aim point (0.5, 0.42), raising aim 8% of viewport height; draw reticle at that point.
- `scenes/player/player.gd`: both hidden/default and held target ray use the same shared point, preserving 3D projectile convergence and existing camera shoulder behavior.
- `scenes/player/battle_vfx.gd`: replace orb-only foreground overlay helper with AnimatedSprite3D, depth test enabled, existing frame metadata/pivot/nearest filtering, same 3.6m sheet width and animation speed. Existing sheets and other VFX remain unchanged.
- `scenes/objects/elemental_orb.gd`: projectile owns its 3D visual child; update global position and camera-facing basis with projected travel angle after the camera update. Child frees with projectile; no timed foreground loop remains.
- `tests/elemental_orb_test.gd`: adapt orb assertions to 3D visual, add per-form depth checks, normalized raised aim at three resolutions, ray/reticle and quick/held agreement, Player-center clearance, actual rendered open/blocked core-pixel checks.
- `tests/camera_gameplay_check.gd`: place obstruction on the new shared aim ray for future full-basement fixture runs.
- `docs/validation/elemental-orbs/raised-aim.log`, `raised-aim-errors.log`, `depth-open.png`, `depth-occlusion.png`, updated `rendered-orbs.png`: final rendered evidence with raised reticle and native-depth orbs.
- `specs/001-integrate-basement-stage/tasks.md`, `validation.md`, `docs/implementation-changelog.md`: scope/acceptance and actual evidence.

Verification: Godot 4.7.2 Compatibility final fixture passes 89/89 including prior route/flight/wall/range/cooldown/element-callback/wind catch regressions. Raised ray/reticle aligns at normalized 0.42 height, quick/held targets agree, and actual rendered pixels confirm an unobstructed white core becomes hidden behind foreground 3D geometry. Inspected raised-reticle/four-orb and open/occluded screenshots. Initial fixture pixel checks used logical viewport coordinates against physical screenshot pixels; corrected conversion and hid reticle during pixel checks. Player-clearance fixture now explicitly checks target lies above Player center rather than assuming a fixed 30 logical pixels. Final logs contain no SCRIPT ERROR; existing UID fallback and exit diagnostics remain (3 ObjectDB instances, 1 resource retained). `git diff --check` passes with existing line-ending notices.

Limits: manual native full-stage feel, every camera angle and direct pixel testing against the Player silhouette remain pending; actual foreground-geometry occlusion and Player depth-writing scene configuration establish the corrected rendering path. Full-basement camera fixture was adapted but not rerun in its required isolated copy. No camera rig or collision behavior changed; Bao acceptance and commit/push are not claimed. Tracked UID cache was already dirty and remains untouched by hand.

## T086 Straight elemental orbs (2026-11-13)

User authorizes replacing returning daggers for neutral, fire, ice and lightning with straight elemental orbs while preserving wind. Bao-owned Player combat/VFX/UI scope; no teammate review/sign-off is claimed. Prior T085 parry work and dirty tracked UID cache were preserved.

Included files and purposes:
- `scenes/objects/elemental_orb.gd`, generated `.gd.uid`, `elemental_orb.tscn`: separate outbound-only projectile inheriting existing speed/range/wall query and HitArea scene. Hide dagger art; travel along initial 3D aim, expire at range/wall, track effect position and free effect with projectile. Never suppress/restore the equipped blade or start a return/hit-reset phase.
- `scenes/player/states/skillstate.gd`: retain original scene exclusively for wind; route other throws to the orb, snapshot element before spawning, keep wind-only launch slashes and return upgrades, retain cooldown/damage/status callback and aiming. Neutral launch uses a magic sound.
- `scenes/player/battle_vfx.gd`: orb visual helper using existing world anchor/metadata loader and projectile-owned loop lifetime; neutral magic sound mapping. Existing parry edits retained.
- `tools/export_elemental_orbs.mjs`: reproducible export of bundled pixelfx plasma-shot, size 8, four palettes, without changing upstream sources.
- `assets/effects/pixelfx/projectiles/orb-{white,fire,ice,lightning}/`: each contains named PNG/JSON sheet, `palette.json`, `contact.png`, plus Godot PNG import sidecars. White core/corona/trail with neutral-white, fire-orange, ice-cyan and lightning-yellow palettes; 24 frames, 144x60, pivot [108,30], 30fps loop. `projectiles/README.md` records regeneration and MIT/Sprite Fusion attribution.
- `ui/player_hud.gd`: orb names/tooltips and neutral/fallback orb atlas icon, keeping wind dagger fallback and stable internal cooldown/skill keys.
- `ui/skill_tree_layout.gd`: Hỏa Cầu/Băng Cầu/Lôi Cầu full/short names and straight-flight descriptions; ember/frostbite wording refers to orbs. Node IDs, prerequisites, costs and upgrades remain intact.
- `tests/elemental_orb_test.gd`: actual Player cast routing, 3D aim, damage upgrades, elemental hit-signal connection, cooldown, blade suppression, flight/range/wall/cleanup checks; wind return/catch/upgrade regressions; HUD/Skill Tree checks and rendered four-orb capture.
- `docs/validation/elemental-orbs/{import.log,test.log,rendered.log,rendered-errors.log,rendered-orbs.png,parry-regression.log}`: import, headless/rendered evidence and shared-VFX parry regression (all seven enemies and feedback lifecycle pass).
- `specs/001-integrate-basement-stage/tasks.md`, `validation.md`, `docs/implementation-changelog.md`: scope/acceptance, verification and cumulative record.

Integration: preserves original `scenes/objects/skill.gd` and `phidao.tscn` for wind, existing enemy damage/status handlers, skill costs/cooldowns/IDs, higher skills, map/save systems, slash and ice-shield implementations. Orbs use the old 14m/s speed and 7m outbound range and wall mask/margin. Existing outbound piercing remains, with no return damage pass. No commit/push.

Verification: inspected all four pixelfx contact sheets and in-engine `rendered-orbs.png`. Stock `check.mjs projectiles/plasma-shot` passes without warnings. Godot 4.7.2 headless fixture passes 73/73 checks; final Compatibility renderer fixture passes 77/77, adding HUD/Skill Tree checks. Final rendered run has no SCRIPT ERROR and confirms actual physics-world wall query; existing UID fallback and shutdown diagnostics (3 ObjectDB instances, 1 retained resource) persist. Early fixture failures were load ordering (typed Player before autoload) and typed-array setup, corrected in test only. Editor memory mapping prevented a whole-file UI write; content remained intact, and scoped patch succeeded. Native full-basement play/combat feel and actual per-enemy burn/slow/stun application with the new projectile were not manually verified; existing callbacks are connected and damage/status code is unchanged. Bao acceptance remains pending. Godot may update the already-dirty tracked UID cache; no cache hand edit/reset occurred.

## T085 Successful parry feedback (2026-11-13)

Implemented for Bao-owned Player combat, authorized by the user's request for Sekiro-style successful-parry feedback and metallic sound. No teammate sign-off or visual acceptance is claimed.

Files and purpose:
- `scenes/player/parry.gd`: trigger feedback only after entering SUCCESS; retain HP, window, recovery and enemy reaction behavior.
- `scenes/player/battle_vfx.gd`: gold spark/white flash/ring helper, attacker-facing contact with facing fallback, upright fan and corrected source pivot, 1.5x playback, existing Sword Parry 1 sound through the SFX bus at -2 dB.
- `assets/effects/pixelfx/impacts/parry/parry.png`, `parry.json`, `parry.png.import`: transparent 31-frame sheet, timing/pivot metadata and Godot import.
- `assets/effects/pixelfx/impacts/parry/contact.png`, `contact.png.import`, `README.md`: inspected preview, import and regeneration/license attribution. Bundled upstream source and license remain intact.
- `tests/parry_test.gd`: retain seven-enemy parry regressions; add entry/miss suppression, exactly one burst/clang per success, duplicate rejection, contact/orbit projection and completed-node cleanup.
- `specs/001-integrate-basement-stage/tasks.md`, `validation.md`: pre-implementation scope/acceptance and final evidence/open review state.
- `docs/validation/parry-feedback/import.log`, `test.log`: actual Godot import and final regression evidence.
- `docs/implementation-changelog.md`: this cumulative record.

Integration: uses existing PixelFX world anchor and settings-aware audio lifecycle. No enemy scripts, map, slash or ice-shield implementations changed. The tracked `.godot/uid_cache.bin` was already dirty before this work and remains untouched by hand; Godot import can update caches, and the final tracked file is still dirty. No cache reset or cleanup was performed.

Verification: pixelfx `check.mjs impacts/parry` passes with no warnings; exported contact sheet inspected. Godot 4.7.2 headless final test passes crab, barrel, mushroom, starfish, skeleton warrior, skeleton mage and pelican, plus entry/miss/duplicate/orbit and cleanup checks, with no SCRIPT ERROR. Existing UID fallback warnings and exit diagnostics (7 retained ObjectDB instances, 1 resource still in use) remain unresolved. Native rendered combat and listening to the clang in-game were not performed; visual/audio feel and reviewer agreement remain pending. No commit/push.

This cumulative teammate-facing record describes actual changes and evidence, not
whole-feature acceptance. Every future implementation group or commit/push must
update it before publishing; see root AGENTS.md. Keep historical entries and add
new groups with task status, every included file, integration effects, checks,
known errors, limitations and unfinished work.

## 2026-11-05 — Spec Kit setup and continuous-basement scene foundation — this commit

**Base commit:** `0c01c67b3fa087fa898a8d5f4e7d8afbe170cd3f`.
**Branch/destination:** `basement-split-floors` at
`origin` (`https://github.com/Deltaruneman/ProjectVNG.git`).
The remote branch matched the base at preflight. No existing commits are amended.
Setup and foundation are backfilled into this single associated commit; they are
not represented as earlier commits that never occurred.

### Groups and actual task status

- **Setup and planning:** existing Spec Kit 1.3.0 installation, constitution v1.0.0,
  feature specification/design/task documents are included. T001-T003 complete:
  preservation/scope recorded and writable pre-autoload test isolation established.
  Bundled commands/workflow availability does not mean those workflows were all run.
- **First scene foundation:** T004-T009 complete. Root Stage composition, integrated
  B3/GroundExit removal and null-obstacle cleanup implemented and structurally checked.
  T008 required no additional collider: existing containment was judged sufficient
  structurally; physical containment acceptance remains outstanding.
- **Validation/handoff:** T010 partial; T011 partial without Quan sign-off.
  Lam reports reviewing expected scene changes and testing basement_b1,
  basement_b2 and basement_full with no major issues observed. These are Lam's
  observations, not comprehensive acceptance or Quan/Bao approval.
- **Current hold, not implementation:** T012 attempted/BLOCKED. Named shared
  manager/input/save reviewer and actual reviewer/Quan agreement with Bao input-impact
  review are missing. T013-T017 and T025 are unimplemented/unrun behind that gate.
  No checkpoint behavior, startup/recovery/save changes or later task groups are
  included. Existing data-model/contract APIs and wave flags remain proposals.

### File-by-file commit manifest

Each checked row is a reviewed inclusion decision reconciled with the staged diff.
A = added relative to base; M = modified. The staging check matched these exact 43 paths;
no file deletions are included. New files already present at packaging entry are
backfilled setup/feature/foundation artifacts, not claimed to have been authored
during packaging. Only AGENTS.md, this changelog and removal of the temporary
constitution comment are new packaging changes.

| Reviewed | File | Git change | What changed and why |
| --- | --- | --- | --- |
| [x] | `.agents/skills/speckit-analyze/SKILL.md` | A | Cross-artifact consistency review workflow. |
| [x] | `.agents/skills/speckit-checklist/SKILL.md` | A | Reviewer-owned requirements checklist workflow. |
| [x] | `.agents/skills/speckit-clarify/SKILL.md` | A | Specification clarification workflow. |
| [x] | `.agents/skills/speckit-constitution/SKILL.md` | A | Constitution authoring and governance workflow. |
| [x] | `.agents/skills/speckit-converge/SKILL.md` | A | Append-only remaining-work assessment workflow. |
| [x] | `.agents/skills/speckit-implement/SKILL.md` | A | Task execution and honest validation workflow. |
| [x] | `.agents/skills/speckit-plan/SKILL.md` | A | Design-artifact planning workflow. |
| [x] | `.agents/skills/speckit-specify/SKILL.md` | A | Feature specification workflow. |
| [x] | `.agents/skills/speckit-tasks/SKILL.md` | A | Dependency-ordered task generation workflow. |
| [x] | `.specify/.gitignore` | A | Ignore checkout-local feature pointers, overrides and adapter packages. |
| [x] | `.specify/init-options.json` | A | Record portable Spec Kit 1.3.0/Codex/PowerShell initialization choices. |
| [x] | `.specify/integration.json` | A | Record installed/default Codex integration and invocation separator. |
| [x] | `.specify/integrations/codex.manifest.json` | A | Installer provenance and checksums for the nine bundled skills. |
| [x] | `.specify/integrations/speckit.manifest.json` | A | Installer provenance and checksums for bundled scripts/templates/ignore rules. |
| [x] | `.specify/memory/.constitution-template.json` | A | Track source template hash for future constitution refreshes. |
| [x] | `.specify/memory/constitution.md` | A | Adopt v1.0.0 ownership, evidence, scope, map safety and validation rules; remove temporary sync-impact comment before commit, preserving governance text. |
| [x] | `.specify/scripts/powershell/check-prerequisites.ps1` | A | Resolve/check feature artifacts for workflow prerequisites. |
| [x] | `.specify/scripts/powershell/common.ps1` | A | Shared portable repository/feature/integration/template resolution. |
| [x] | `.specify/scripts/powershell/create-new-feature.ps1` | A | Bundled feature-creation helper; not executed during packaging. |
| [x] | `.specify/scripts/powershell/resolve-template.ps1` | A | Resolve composed workflow templates. |
| [x] | `.specify/scripts/powershell/setup-plan.ps1` | A | Bundled planning setup helper; not executed during packaging. |
| [x] | `.specify/scripts/powershell/setup-tasks.ps1` | A | Bundled task setup helper; not executed during packaging. |
| [x] | `.specify/templates/checklist-template.md` | A | Requirements-review checklist template. |
| [x] | `.specify/templates/constitution-template.md` | A | Upstream governance template retained for workflow reuse. |
| [x] | `.specify/templates/plan-template.md` | A | Design/implementation planning template. |
| [x] | `.specify/templates/spec-template.md` | A | User-story/requirements specification template. |
| [x] | `.specify/templates/tasks-template.md` | A | Dependency/task execution template. |
| [x] | `.specify/workflows/speckit/workflow.yml` | A | Bundled SDD workflow with spec/plan review gates; installed, not run automatically. |
| [x] | `.specify/workflows/workflow-registry.json` | A | Portable bundled workflow version/provenance registry. |
| [x] | `specs/001-integrate-basement-stage/spec.md` | A | Approved Q1-Q4 requirements, boundaries and acceptance criteria; no runtime acceptance claim. |
| [x] | `specs/001-integrate-basement-stage/checklists/requirements.md` | A | Preserve 14/16 requirements-quality markers and two explained technical-constraint exceptions. |
| [x] | `specs/001-integrate-basement-stage/plan.md` | A | Record incremental architecture, ownership/review boundaries and phased implementation. |
| [x] | `specs/001-integrate-basement-stage/research.md` | A | Record targeted static evidence, canonical identities and unresolved integration dependencies. |
| [x] | `specs/001-integrate-basement-stage/data-model.md` | A | Document stage/checkpoint/state model; proposed fields/interfaces remain proposals. |
| [x] | `specs/001-integrate-basement-stage/contracts/stage-progress.md` | A | Document proposed checkpoint/wave/persistence contracts and shared review requirements. |
| [x] | `specs/001-integrate-basement-stage/quickstart.md` | A | Historical planned validation guide; latest isolation/results/status in validation.md supersede earlier examples. |
| [x] | `specs/001-integrate-basement-stage/tasks.md` | A | Record T001-T009 complete, T010/T011 partial, T012 hold and dependent work unimplemented. |
| [x] | `specs/001-integrate-basement-stage/validation.md` | A | Preserve baseline, isolated-run evidence, diagnostics and Lam observations; document T012 blocker without implementation. |
| [x] | `levels/level_1/basement_full.tscn` | M | Rename root Basement to Stage; remove integrated B3/GroundExit and two orphan resources; remove only null B1/B1_5 obstacle entries. Preserve all other retained blocks/Hidden and separate B3. Existing containment judged sufficient structurally; no speculative boundary added. |
| [x] | `tests/basement_integration_check.gd` | A | Read-only serialized-scene assertions for root, retained hashes, singleton declarations, references and separate-B3 preservation; isolated-copy guard; explicitly not a gameplay/physics test. |
| [x] | `tests/basement_integration_check.gd.uid` | A | Preserve the checker's existing Godot resource UID for stable script identity. |
| [x] | `AGENTS.md` | A | Add root guidance because none existed; require cumulative changelog updates for every future implementation group or commit/push, preserving ownership/review rules. |
| [x] | `docs/implementation-changelog.md` | A | Create this cumulative teammate record, backfill setup/foundation evidence and enumerate this commit's exact inclusion/exclusion decisions. |

### Exclusions and attribution

All five excluded paths were present at packaging entry, remain unstaged, and
must retain their entry SHA-256 hashes. No attribution is invented.

| Reviewed exclusion | Path | Entry state | Reason |
| --- | --- | --- | --- |
| [x] | `.godot/uid_cache.bin` | Modified | Generated tracked cache, already changed before this session; differs from first-session baseline. Preserve for review, do not stage or clean. |
| [x] | `assets/meshes/KKD_library.tres` | Modified | Pre-existing BoxShape3D_scaffold resource-block relocation; no foundation library edits authorized or attributable. Preserve. |
| [x] | `project.godot` | Modified | Pre-existing removal of mesh_to_scene editor-plugin enablement; unrelated to foundation. Preserve and exclude entire diff. |
| [x] | `docs/build_progress_1.md` | Untracked | Earlier broad Prototype 1 progress document, already present at original baseline; authorship/commit attribution unestablished and outside requested feature artifacts. |
| [x] | `docs/godotgameteam7_full_concept.md` | Untracked | Earlier broad project concept document, already present at original baseline; authorship/commit attribution unestablished and outside requested feature artifacts. |

Checkout-local ignored Spec Kit state (including feature.json), .git data,
import caches, disposable test projects/logs and actual user data are excluded.
No wholesale directory staging or mixed unrelated hunks are required: the only
included tracked modification is the reviewed basement_full.tscn foundation diff.
The index was empty at entry, so no pre-staged work is silently carried forward.

### Shared systems and integration considerations

- Gameplay composition changes only in the combined scene. Separate B3, standalone
  B1/B2, Hidden geometry/collision/behavior/connections and shared libraries remain
  unchanged. Root Stage supports existing factory ancestry; one direct Player,
  CameraRig, Hud, Bullets and Spawn remain.
- Production project settings, GameManager, SaveSystem, Player, navigation scripts,
  stock checkpoint logic and enemy/wave producers are not modified by this commit.
  Production startup remains standalone B1; this foundation is tested by explicit
  combined-scene loading/F6, not an asserted production startup switch.
- Teammates receive portable Spec Kit workflows/templates and explicit governance,
  review boundaries and cumulative reporting requirements. No new dependency
  installation, automatic workflow execution, ownership transfer or teammate approval.
- T012 requires a named shared reviewer plus actual review agreement for manager
  B1/B2 acceptance, physical-F binding and local checkpoint/spawn scope before
  dependent edits. Old-B3 recovery and Duy's real-wave handshake remain separate
  unresolved later dependencies, not reasons to implement a guessed fallback now.
- Detailed validation has historical machine/temp paths as evidence; they are not
  portable launch configuration. Use a new disposable copy/user-data identity and
  verify isolation before autoloads; never launch the original project for these checks.

### Verification, known diagnostics and unfinished work

Existing evidence reused from feature validation.md (no gameplay rerun during packaging):

- Godot `4.7.2.stable.official.ed1daf0bf`: isolated no-autoload probe verified
  unique writable temp-backed user data and no save before game autoload startup.
- Focused unchanged GDScript runner: **243 passed, 0 failed**, exit 0, in disposable
  project copy. Earlier independent 141 static checks are historical, not added
  to or substituted for that result.
- Limited headless combined-scene load/composition: one Player/CameraRig/Hud,
  one observed registration, GameManager.current_stage equals Stage,
  camera target equals Player, absent integrated B3/GroundExit; not a playtest.
- Diagnostics remain explicit: initial isolated Dialogic directory error corrected
  by verified temp APPDATA; root-certificate-store failure reproduced in minimal
  probe; graceful scene shutdown leaked 3 ObjectDB instances/1 resource
  (`fsm.gd`). Pre-existing detached-FSM lifetime is a hypothesis, not proven cause.
  Exit 0 does not establish error-free gameplay.
- Lam's general scene observations are recorded separately above. Detailed visual
  camera/visibility, movement/collision, factory/projectile/navigation and physical
  B2 containment checks remain unverified. No comprehensive acceptance/sign-off.
- Checkpoint prompt/F/feedback/rank, supported spawn/recovery, restart, real waves,
  ceiling/parkour/gates and old-B3 recovery are not verified by this foundation.

### Packaging verification and staged reconciliation

- **PASSED:** branch/HEAD/upstream verified; index initially empty. Live origin
  branch equalled base HEAD at preflight. Destination is the existing branch,
  normal push only; stop on divergence. No custom active Git hooks were found.
- **PASSED:** all 43 candidates individually reviewed and explicitly staged;
  exact index path-set comparison matched the manifest above (42 additions,
  1 scene modification, no file deletions). All five excluded candidates remain
  outside the index. Their entry hashes are retained for post-commit comparison.
- **PASSED:** all 21 bundled skill/script/template/ignore files match installer
  provenance SHA-256 hashes in the two integration manifests. Installer registries
  contain timestamps/checksums/relative paths, not checkout-specific configuration.
- **PASSED:** focused read-only PowerShell checks against the index: **198 passed,
  0 failed**. Checked root/retained hashes, 58 serialized nodes/57 retained blocks,
  singleton declarations, no integrated B3/GroundExit/null obstacles, NodePaths,
  external dependencies present in committed base, ExtResource/SubResource IDs,
  separate-B3 preservation and honest task completion markers. No Godot launch.
- **PASSED:** staged JSON parses; all six PowerShell scripts parse; staged content
  matches normalized working files; obvious private-key/token/AWS-key patterns
  absent. Absolute paths appear only in historical evidence/examples or a generic
  script comment, not portable JSON configuration. No credentials or temp artifacts
  included. This is a focused obvious-secret scan, not a security certification.
- **PASSED, whitespace:** initial staged check found one extra blank line at this
  new changelog's EOF; corrected as packaging-only work. The final
  `git diff --cached --check` returned exit 0. Existing text normalization
  produces CRLF-to-LF notices for five setup JSON files; no semantic setting changes.
- **Evidence reuse limitation:** the retained disposable copy's checker still
  matches this checker byte-for-byte, but its scene no longer matches current
  source even after EOL normalization (reason unverified). The historical 243/0
  Godot run stays historical; today's index is independently checked by the
  198 static checks and golden retained-content hashes above. No fresh runtime
  result is claimed. Manual checks and known diagnostics remain as listed above.

A successful commit/push does not change task completion or satisfy missing
gameplay acceptance. No T012+ implementation was performed during packaging.

## 2026-11-05 — Authorized checkpoint/startup/recovery phase — included in this commit

**Base:** pushed foundation `7c392eb213ecc6ef63db9ed844eecd54ae24be73`;
branch remains basement-split-floors. At the implementation handoff no commit,
staging, push, merge or branch change was performed; packaging is recorded below.
Lam explicitly authorizes and will review the narrow shared-file slice. This
supersedes the earlier T012 missing-reviewer hold for this phase; no Quan/Bao
agreement or finished teammate code review is claimed. Constitution I still
requires affected-owner approval before changing their systems; Player/enemy
systems remain untouched.

**Task status:** T012 complete as authorization/boundary record. T014-T021
implemented and independently checked. T013 remains partial for full planned
coverage because later actual-wave coverage is deferred. T025/T026 are partial:
isolated input/physics/startup/recovery checks pass, but B2 HUD rendering and
remaining manual checks block complete visual acceptance. T010/T011 remain partial.
No T022-T024 or T027+ implementation; old-B3 recovery remains separately BLOCKED
on policy, and actual waves are NOT RUN.

### Every file added or modified in this phase

| File | Change | Purpose and integration impact |
| --- | --- | --- |
| `scripts/autoload/game_manager.gd` | Modified | Combined FIRST_STAGE; explicit path/UID and trusted B1/B2 rank table; active Stage/owner/unique declaration acceptance; no downgrade, duplicate progression write or stock-setter bypass. Retain/merge loaded payload and flags; exact four legacy reference+ID pairs reset only checkpoint pair. Refuse B3 before load-state mutation and hold unresolved save/respawn references without fallback. Supported unrelated-stage stock fixture passes. Shared manager boundary only; no wave producer/reset implementation. |
| `project.godot` | Modified, mixed with preserved pre-existing edit | Set main scene to combined canonical path and add exactly one physical-F interact binding. Preserve pre-existing mesh_to_scene plugin disablement and every other input/setting. No isolated-user-data settings written to original. |
| `levels/level_1/basement_full.tscn` | Modified | Add Stage-owned B1/B2 local checkpoint instances and resource; align default Player/Spawn to supported (-3,1.2,14), B2 checkpoint Spawn (49,7.2,5). Other foundation blocks/Hidden unchanged; no geometry changes. |
| `levels/objects/checkpoint/basement_checkpoint.gd` | Added | Basement-only InteractiveArea3D script replacing inherited stock contact activation. Living active Player/actual overlap/no-dialogue/load guard, fresh-F input, acceptance-only tint/exact two-second local message and restored active tint. Shared helper/Player/HUD unchanged. |
| `levels/objects/checkpoint/basement_checkpoint.gd.uid` | Added | Stable script identity generated by Godot ResourceUID in isolated probe; no cache edits. |
| `levels/objects/checkpoint/basement_checkpoint.tscn` | Added | Inherit existing helm/detector/Spawn visuals, override behavior and add local Label3D feedback. No auto-activation script or second HUD. |
| `tests/basement_checkpoint_check.gd` | Added | Independent fixture/interaction/recovery runs, exact isolation guards, synthetic payload sentinels and test-only process/scene controls. Actual physical-F dispatch, overlap, rank/owner/duplicate/legacy/B3 refusal, support rays/body settling, injected damage through real Player/FSM and rendered captures. Test controls do not implement production waves or prove actual wave behavior. |
| `tests/basement_checkpoint_check.gd.uid` | Added | Stable new runner identity from isolated ResourceUID generator. |
| `specs/001-integrate-basement-stage/tasks.md` | Modified | Record actual Lam authorization, implementation completion, partial tests/visual acceptance and separate deferred work without fabricated review. |
| `specs/001-integrate-basement-stage/validation.md` | Modified | Current authorization, isolated copy/user-data/log provenance, results/corrections/diagnostics, captures, preservation and manual limitations; retain historical evidence. |
| `docs/implementation-bugs.md` | Added | Flag HIGH baseline payload-loss BUG-001 and B3-load BUG-002 fixed in scope; HIGH B2 health-bar capture issue BUG-003 remains open with reproduction and phase impact. No speculative HUD/player/renderer fix. |
| `docs/implementation-changelog.md` | Modified | Append this cumulative phase record, exact affected files, shared-system effects, evidence and unfinished work. |

No files removed. Root AGENTS.md, constitution, specification/plan/research/model/
contract/quickstart, historical foundation checker/UID, Stage, SaveSystem,
InteractiveArea3D, stock checkpoint, Player/enemy scripts/scenes and separate B3
remain unchanged. No new wave API or durable clear/unlock keys are implemented;
fixture flags are preservation sentinels only. Other pre-existing cache/library/
concept/progress changes remain untouched and unstaged.

### Verification and limitations

Full provenance and commands: current phase section in feature validation.md.
Disposable root: `ArcanaCheckpoint-da11bc20c86749c9a4c091c4df511339`
under the user's temp directory; Godot `4.7.2.stable.official.ed1daf0bf`.
Pre-autoload no-autoload probe confirmed the exact temp-backed user directory
and no save before copied-game startup. All save files are synthetic. No original
project or real player-save launch/access. New UIDs generated in the isolated probe.

| Check | Result |
| --- | --- |
| Current fixture suite | 55 passed / 0 failed, exit 0; owner/duplicate/rank/idempotence/stock behavior, nested data/flags, exact legacy/negative/B3 lanes |
| Headless interaction | 24 passed / 0 failed, exit 0; no arrival activation, actual F dispatch, exact feedback/tint, echo/repeat, synthetic dialogue/dead/overlap |
| Rendered interaction | 26 passed / 0 failed, exit 0; includes B1/B2 screenshot assertions, captures inspected |
| Final supported recovery | 55 passed / 0 failed, exit 0; six fixture cases, support rays/body settling, registration/camera/health and real damage/dead-state reload path |
| Rendered recovery diagnostic | 56 passed / 0 failed; B2 screenshot inspected; earlier direct-death-signal variant, not substituted for final damage/dead-state run |
| Actual normal main-scene startup | Five separate no-save/B1/B2/legacy-B1/legacy-B2 process launches; expected combined scene/endpoint/camera/one Hud, exit 0 |
| B3 refusal | Path/UID/direct/startup/death checks pass zero-load/state/file preservation; recovery outcome separately BLOCKED |
| Foundation/protected files | Static reversal of only declared scene edits reproduces pushed foundation; protected Stage/save/helper/player/enemy/stock checkpoint/B3 match HEAD |
| Whitespace/branch/index | git diff --check passes after removing an extra documentation EOF blank; original branch/HEAD retained; index empty |

Historical foundation checker remains a first-group golden snapshot, not the
checkpoint-phase runner: its retained-block/transform expectations predate these
authorized checkpoint/spawn additions. It was not rewritten or used to claim
current all-phase acceptance.

Harness-only early errors were corrected: SceneTree autoload/type resolution,
dynamic Dictionary typing, JSON numeric round-trip comparison, frame timing and
recording initial placement before gravity. Expected red first established the
missing request API before production edits. Final passes above supersede failed
harness drafts; they do not hide gameplay findings.

**Open HIGH BUG-003:** B2 captures lack the health bar despite one visible Hud node,
while B1 capture shows it. Cause/regression attribution is unproven. Blocks full
T025/T026 visual/HUD acceptance; needs manual reproduction and HUD/renderer review.
Captured checkpoint marker/message and restored B2 player/floor are visible.

Other diagnostics retained: headless certificate-store failure also reproduced
without game autoloads; shutdown ObjectDB/resource leaks (4/1 fixtures, 3/1
interaction, 14/1 repeated recovery); one rendered recovery run emitted a GLES3
shader initialization error. No proven attribution or out-of-scope fixes.

Still manual: human-controlled approach/leave and camera framing/visibility,
real dialogue and other-interactable overlap, ordinary combat-driven death,
normal B2 startup/death/restart HUD rendering, and complete route/factory/navigation/
containment acceptance from T010. Actual finite-wave/reset/clear behavior and
old-B3 recovery policy remain unimplemented/unverified separately. A passing
synthetic fixture or rendered capture is not whole-feature acceptance or sign-off.

## 2026-11-05 — Third implementation replan — planning/evidence only

Planning-only group, packaged in this commit with Implementation 2. No scene/script construction. Preserve pushed foundation
and uncommitted checkpoint work; branch/HEAD unchanged. The new baseline
basement_b1.tscn ext-resource-order edit was already present at entry and is preserved.

| File | Change in this activity | Why / integration impact |
| --- | --- | --- |
| `specs/001-integrate-basement-stage/clearance-measurements.md` | Added | Reproduction, actual collider/headroom measurements, controller dependency and isolated evidence; no fixed claim |
| `specs/001-integrate-basement-stage/third-implementation-plan.md` | Added | Two review-gated passes, smallest scene-local safety proposal, candidate openings, spawn/spacing impact and owner boundaries |
| `specs/001-integrate-basement-stage/clearance-candidates.svg` | Added | Actual floor-cell X/Z footprint map, two unchosen opening/landing/retry proposals, current spawns/checkpoints/Hidden and reproduced traps |
| `specs/001-integrate-basement-stage/plan.md` | Modified narrowly | Link current replan and reverse old route-before-ceiling-test dependency; preserve broader plan |
| `specs/001-integrate-basement-stage/tasks.md` | Modified narrowly | T034 partial measurements; T035 pass-1 ceilings/containment then T038 contact/recovery tests; T036 waits for pass-1 acceptance and recorded Lam/Quan route choice, then T039 retry tests. No geometry completion markers |
| `specs/001-integrate-basement-stage/validation.md` | Modified | Append planning authority, current baseline, reproduction/isolation/findings/limits and review stop |
| `docs/implementation-bugs.md` | Modified | Add open HIGH BUG-004: B1 vertical double jump traps in B2 triangle floor, expected ceiling/fall/landing/recovery vs actual stuck state; no implementation/fix |
| `docs/implementation-changelog.md` | Modified | This cumulative planning/evidence entry; distinguish proposal from built work |
| `specs/001-integrate-basement-stage/clearance-candidates.svg.import` | Unexpected generated sidecar, left unstaged | Godot import metadata appeared for the new SVG. Retained for review, not an authored gameplay/configuration change |
| `.godot/uid_cache.bin` | Existing tracked modification; current hash differs from prior session | No explicit assistant write/cleanup; timing/attribution unproven. Preserve current contents and report generated-metadata observation in validation.md |

**Evidence:** verified fresh ArcanaClearance disposable project/user-data probe;
four under-B2 headless reproductions, two non-trapping controls, independent rendered
repeat and before/stuck captures. Real physical input and existing Player physics,
without production edits. B1 floor1.01, B2 thin front-face plane7, no functioning
underside, trapped root≈6.144 with wall normals and accumulating negative velocity.
Upper prototype crate top≈5.542 means a uniform ceiling6.8 would leave inadequate
headroom. Logs/data retained in the disposable root recorded in measurements.

**Proposal, not a fix:** retain six-metre spacing; local solid underside/roofs and
measured perimeter closure. Treat prototype stack separately with an explicitly
reviewed guard/hold; don't silently cap it too low. Pass 1 proves ceiling contact,
falling, landing and normal movement recovery. Pass 2 is a separate deliberate
opening and safe parkour/landing/retry after Lam/Quan choose A, B or a revision.
No choice is inferred; no floor cut, route, cap or temporary guard is built now.

**Shared impact:** none implemented. No player/enemy/manager/save/input/checkpoint/
library edits or intentional cache edits in this planning activity. A future spacing change would move
B2 child spawns/checkpoints if its container moves, require explicit reconciliation
if only GridMap cells move, and require review of visibility thresholds: changing
floor_height alone does not move the first B1→B2 threshold. Existing IDs save
locations by reference, not coordinates. Bao owns any required controller change.

**Status/limits:** T034 partial; T035-T040 not built/tested. No post-fix pass, route
traversal, perimeter escape or full-floor sweep claim. SVG XML/geometry preview
checked; native SVG includes labels (Godot raster preview omits SVG text).
Certificate-store and shutdown leaks remain existing diagnostics; invalid item34
outside sampled candidates noted separately. BUG-003 visual/HUD issue remains open.
No real-save access, generators, scene/script edits, staging, commits or pushes.
Stop for Lam/Quan review of pass 1 and later route selection.

Final source preservation: 207 original scene/script/test/mesh files equal the
fresh entry copy; original settings match after removing copy-only isolation keys.
SVG import sidecar appeared and original UID cache differs from earlier hashes;
a running importer is suspected but not proven. Neither was discarded or staged.
See validation.md's final metadata observation; no cache-equality claim is made.

## Commit handoff — Implementation 2 and Implementation 3 replan — this commit

**Base:** `7c392eb213ecc6ef63db9ed844eecd54ae24be73`.
**Message:** `Implement basement checkpoints and document ceiling replan`.
**Destination:** existing `origin/basement-split-floors`,
`https://github.com/Deltaruneman/ProjectVNG.git`. Local/remote matched the base at
preflight; normal push only. This entry supersedes earlier uncommitted/no-push
handoff statements for packaging only. It does not authorize more gameplay work.

Lam reports **successful manual checkpoint activation**. No floor-specific steps,
engine/isolation details or recovery/HUD results were supplied with that report.
Record it as Lam's observation, not comprehensive acceptance or Quan/Bao sign-off.
T025/T026 remain partial; untested manual recovery/HUD/interaction cases and
HIGH BUG-003 stay open. BUG-004 is reproduced/open. Ceiling/containment and parkour
remain planning only; neither candidate route is chosen or built.

### Exact included-file checklist against the foundation commit

A = new relative to base; M = modified. Each row is an explicit reviewed staging
decision; the final index must match exactly these 16 paths, with no file deletion.

| Include | Path | Change | Content in this commit |
| --- | --- | --- | --- |
| [x] | `docs/implementation-changelog.md` | M | Cumulative group evidence and this exact commit manifest. |
| [x] | `docs/implementation-bugs.md` | A | BUG-001/002 fixes, BUG-003 open, BUG-004 reproduced/open; no ceiling fix claim. |
| [x] | `levels/level_1/basement_full.tscn` | M (selected hunks) | Checkpoint resource/instances, supported default Player/Spawn; exclude prototype reparenting. |
| [x] | `levels/objects/checkpoint/basement_checkpoint.gd` | A | Local eligible nearby-F interaction, tint/feedback, restored active marker. |
| [x] | `levels/objects/checkpoint/basement_checkpoint.gd.uid` | A | Checkpoint script identity. |
| [x] | `levels/objects/checkpoint/basement_checkpoint.tscn` | A | Inherited visuals/Spawn with local behavior and feedback Label3D. |
| [x] | `project.godot` | M (selected hunks) | Combined main scene and physical-F interact action only; exclude editor-plugin change. |
| [x] | `scripts/autoload/game_manager.gd` | M | Canonical checkpoint/rank, payload merge, exact legacy pairs, supported startup/recovery and B3 refusal. |
| [x] | `specs/001-integrate-basement-stage/clearance-candidates.svg` | A | Unchosen candidate opening/landing/retry map; planning only. |
| [x] | `specs/001-integrate-basement-stage/clearance-measurements.md` | A | Baseline headroom/collision and reproduced softlock evidence; no construction. |
| [x] | `specs/001-integrate-basement-stage/third-implementation-plan.md` | A | Two review-gated ceiling/containment and later selected parkour passes. |
| [x] | `specs/001-integrate-basement-stage/plan.md` | M | Narrow third-phase planning reference/dependency update. |
| [x] | `specs/001-integrate-basement-stage/tasks.md` | M | Honest completed/partial tasks, Lam activation observation and two-pass planning. |
| [x] | `specs/001-integrate-basement-stage/validation.md` | M | Isolated prior evidence, Lam activation, open checks/bugs, final packaging reconciliation. |
| [x] | `tests/basement_checkpoint_check.gd` | A | Independent isolated checkpoint/legacy/refusal/interaction/recovery fixtures. |
| [x] | `tests/basement_checkpoint_check.gd.uid` | A | Runner script identity. |

Final checkpoint node ordering/unique IDs/default exported properties and expanded
InputEventKey serialization reflect the current editor-saved files. Checkpoint
IDs/transforms and F binding remain the recorded behavior. The unrelated
B2-Parkour move from B1/World to B1/Pathfinder is **excluded**, so the committed
scene retains the foundation prototype path referenced by planning evidence.

### Explicit exclusions / preserved local work

| Excluded path or hunk | Reason / disposition |
| --- | --- |
| `project.godot` editor_plugins hunk | Pre-existing mesh_to_scene plugin disablement; preserve only in working tree. Staged plugin settings equal the foundation |
| `levels/level_1/basement_full.tscn` Pathfinder/B2-Parkour reparent/reordering hunk | Outside checkpoint implementation and planning-only ceiling replan; attribution not established. Preserve local hunk without staging or reverting it |
| `levels/level_1/basement_b1.tscn` | Unrelated ext-resource ordering; leave unstaged |
| `assets/meshes/KKD_library.tres` | Pre-existing resource-block reordering; leave unstaged |
| `.godot/uid_cache.bin` | Existing generated tracked cache modification; retain, no cleanup/staging |
| `specs/001-integrate-basement-stage/clearance-candidates.svg.import` | Generated SVG import sidecar; preserve untracked |
| `docs/build_progress_1.md` | Earlier broad progress document, unestablished attribution; preserve untracked |
| `docs/godotgameteam7_full_concept.md` | Earlier broad concept document, unestablished attribution; preserve untracked |

No `git add .` or `git add -A`. Whole-file staging is limited to the fourteen
explicit non-mixed paths; the two mixed files use reviewed cached patches without
changing their working copies. Entry hashes for all exclusions and both mixed
working files are retained for final preservation checks.

### Verification and acceptance boundaries

Prior independent evidence remains recorded in the group entries and validation.md:
55 fixture, 24 headless interaction, 26 rendered interaction and 55 final
damage/dead-state recovery checks passed; five normal synthetic main-scene launches;
four baseline under-B2 softlocks plus a rendered repeat. These are historical runs,
not new claims that manual recovery/HUD or ceiling fixes passed. Existing certificate,
shutdown-resource and one shader diagnostic remain documented.

Packaging verification PASSED: 294 focused static checks against the exact index,
including the 16-file manifest, selected hunks, retained foundation blocks,
scene/resource/NodePath invariants, obvious-secret patterns, UID metadata and open
task/bug status. Staged SVG XML parses; `git diff --cached --check` returns exit 0.
There are no staged file deletions, ceiling/route changes, plugin edits or prototype
reparenting. The remaining mixed-file diffs contain exactly those excluded hunks.
No Godot launch or real-save access is needed for packaging. Current editor saves
are reconciled statically with tested checkpoint behavior; unrelated prototype
reparenting is omitted rather than attributed to this work. No broad audit,
implementation, scene repair or test rewrite is part of this commit/push.
## 2026-11-07 — T043 F6 scene startup follow-up

**Status:** Implementation is present; runtime behavior is not verified. T043 remains
open until the isolated F6/F5 acceptance checks are performed. No reviewer agreement is
claimed for this follow-up.

**Cause:** The configured main scene and `GameManager.FIRST_STAGE` are both
`levels/level_1/basement_full.tscn`. The local save had a valid `stage_1.tscn` checkpoint
(`village`). `register_stage()` previously used only scene path equality, so an explicit
F6 run of `basement_full.tscn` was treated as ordinary main-scene startup and redirected
to that saved checkpoint.

**Included files and purpose:**

| File | Purpose / effect |
| --- | --- |
| `scripts/autoload/game_manager.gd` | In `register_stage()`, detect Godot's explicit `--scene` launch argument and skip saved-checkpoint conflict/continuation and checkpoint spawn restoration for that isolated scene run. F5, which has no explicit scene argument, retains the existing continue-from-save flow. Does not clear or rewrite the save. This is a shared startup/recovery system change within the existing GameManager boundary. |
| `specs/001-integrate-basement-stage/tasks.md` | Record T043 scope, ownership/review boundary, observable acceptance criteria, and pending runtime checks; update task totals/current state. |
| `specs/001-integrate-basement-stage/validation.md` | Record the observed configuration/save cause, implementation, and the distinction between static review and unrun runtime acceptance. |

**Shared-system/integration effects:** Only GameManager startup routing changes. Stage,
SaveSystem serializer, player, checkpoint scenes, scene resources and project settings are
untouched by this group. Prior local changes in other files were preserved.

**Verification:** Read-only inspection confirmed the saved checkpoint target and the
existing registration branch. Static review confirms the `--scene` bypass encloses both
the conflict fallback and checkpoint stage/spawn restoration. No tests or Godot runs were
performed. Required isolated F6 and F5 runs with a synthetic `stage_1.tscn`/`village` save
remain unfinished; runtime behavior must not be reported as verified.

**Known limitations / unfinished work:** T043 remains open pending F6 scene identity,
default spawn, unchanged save, and F5 continuation checks. Existing T025/T026 partial
status, BUG-003, other open feature tasks, and prior review boundaries remain unchanged.

## 2026-11-07 — T044 active-floor camera visibility

**Status:** The render-visibility change is implemented. Runtime camera, floor-transition,
collision and navigation behavior is unverified; T044 remains open. Quan review/sign-off is
not recorded.

**Included files and purpose:**

| File | Purpose / effect |
| --- | --- |
| `levels/level_1/basement_floor_visibility.gd` | Render only the active `floor_level`; retain B1_5's existing secret-area condition; hide the B1 room ceiling GridMap visually so it does not block the camera. No collision/navigation/movement data is edited. |
| `specs/001-integrate-basement-stage/tasks.md` | Define T044 scope, owner/review boundary, acceptance criteria, and required camera/floor/collision checks; update totals. |
| `specs/001-integrate-basement-stage/validation.md` | Record static baseline findings, implementation and outstanding runtime checks without claiming a fix. |
| `docs/implementation-changelog.md` | Preserve this cumulative implementation and verification record. |

**Shared-system/integration effects:** Changes are limited to the basement Stage's render
visibility script. The script still processes hidden floors and their collision/navigation
nodes remain in the scene. Scene geometry, shared mesh libraries, player/camera systems,
checkpoints, saves, and the open T034-T038 ceiling/route work are unchanged.

**Verification:** Static source inspection only; no Godot run or test was performed. Required
playtest: switch among B1, B1_5, B2, B3 and GroundExit, inspect camera sightlines and confirm
collision/navigation behavior remains intact. No known new runtime errors are established.

**Limitations / unfinished work:** T044 remains open pending the playtest. T034-T038 remain
open; this render-only change does not constitute measured ceiling/route construction or
acceptance. No reviewer agreement is claimed.

### T044 correction — keep the selected floor during jumps

**Cause:** T034's recorded B2 jump reaches root Y≈12.9342 from Y≈7.0006. The visibility
formula's B3 threshold is Y=11.5, so a jump could select B3 before landing on B2. The
measurements are prior runtime evidence; no new playtest was run for this correction.

**Included file and purpose:** `levels/level_1/basement_floor_visibility.gd` now retains the
selected floor while the player is airborne and recalculates after landing. This prevents
jump height alone from switching rendered floors. Collision, floor geometry, camera system,
and navigation remain unchanged.

**Verification and limitations:** Static source review only. Runtime B2 jump/landing and
floor-transition checks are pending under T044. Do not claim the floor-3-at-B2-jump issue
is runtime-verified as fixed until that playtest is recorded. No reviewer agreement is
claimed.

#### User-reported B2 ladder case and selector revision

The user supplied a screenshot showing the B2 ladder area with B2 hidden and B3 rendered.
This shows that retaining the prior floor only while airborne was insufficient: the player
can stand on elevated B2 stairs above the height threshold. The selector now identifies the
floor from a short downward physics ray against the grounded player's supporting collider,
and retains the prior selection while airborne. Height is only a startup fallback before a
supporting floor is found. No Godot playtest was run; collider mapping and camera behavior
remain unverified under T044.

#### Final T044 selection rule — midpoint during ascent

The user clarified that the upper floor should become visible while climbing, near halfway
between floors, before landing. This supersedes the support-collider/airborne-retention
approach described above. The script now uses the player height continuously with
`switch_margin=3.0`, selecting the upper floor at the midpoint: Y=4, 10, and 16 for the
current B1/B2/B3/GroundExit spacing. B1_5's secret-area filter remains in effect. Static
source review and `git diff --check` were performed; no Godot playtest was run. Stair ascent
and possible transition flicker remain unverified under T044.

#### Superseding T044 implementation — connector-local thresholds

The user approved a connector-specific solution because global height thresholds also
changed floors during ordinary jumps. `levels/level_1/basement_floor_visibility.gd` now
uses the existing B1↔B2, B2↔B3, and B3↔Ground ladder markers as horizontal transition zones
(3.5 m radius). Within each zone, crossing the pair's vertical midpoint while grounded or
touching a wall selects the destination floor; crossing back down selects the source floor,
with 0.25 m hysteresis. Outside connectors, a short downward physics ray identifies the
grounded support floor, and the selection stays fixed while airborne. Scene geometry,
player movement, and collision configuration are not edited.

Static review and `git diff --check` only; no Godot playtest was run. Marker alignment,
connector radius, transitions at the pictured stair, reverse descent, and ordinary jumps
outside connectors remain unverified. T044 remains open and no reviewer agreement is claimed.

## 2026-11-07 — T045 HUD and Skill Tree spellbook presentation

**Task status:** T045 implemented; runtime interaction and visual verification remain
unrun, so the task stays open. BUG-003 remains open and is not attributed to or claimed
fixed by this UI work.

### Included files and purpose

| File | Purpose and effect |
| --- | --- |
| `ui/health_bar.gd` | Replace the persistent `T: Cây kỹ năng` prose with the existing SP count; append a clickable spellbook icon in a sixth toolbar slot marked T. Preserve the four active-skill slots and ultimate slot positions and their existing behavior. |
| `ui/skill_tree_layout.gd` | Remove the menu shortcut footer; give the menu a dark two-page/spine book presentation and horizontal open/close tween. Opening pauses immediately; closing resumes after the animation. Existing T, Escape, close button, and allocation UI remain connected. |
| `assets/ui/skill_tree_book.svg` | Add a small project-authored vector book icon with a magical star and page lines. No existing spellbook image asset was found; existing pixel spell/skill icons remain available. |
| `specs/001-integrate-basement-stage/tasks.md` | Add T045 owner, scope, acceptance criteria and verification boundary; update task count. |
| `specs/001-integrate-basement-stage/validation.md` | Record pre-implementation acceptance, implementation status, asset search result, verification limits and open BUG-003 status. |
| `docs/implementation-changelog.md` | Add this cumulative implementation-group record. |

### Integration effects, verification and limitations

- Shared-system effects: HUD presentation/Skill Tree only. No input mapping, combat,
  skill progression, health/rage logic, basement scene, or BUG-003 diagnosis changed.
- **PASSED:** focused source/diff review confirmed the five skill slots retain their prior
  indexes and the new book/T slot is appended; the existing `skill_tree` action is retained.
  `git diff --check` is clean. The new SVG path matches its script reference.
- **NOT RUN:** no Godot parse, runtime, input, mouse-click, animation, or rendered-layout
  check was performed. Those behaviors and the sixth-slot fit need visual playtesting;
  the created icon is custom vector artwork rather than an existing project book asset.
- Known errors: none observed in static review. Unfinished: record T045 runtime results and
  any needed layout correction; BUG-003 B2 health-bar symptom and T025/T026 acceptance remain
  independent and open. No reviewer sign-off is claimed.

#### T045 correction — consume book-slot click through the viewport

The user reported a Godot error at `ui/health_bar.gd` because `_on_skill_tree_slot_input()`
called `accept_event()` on `HealthHUD`, a `CanvasLayer`. Replaced it with
`get_viewport().set_input_as_handled()` after opening the Skill Tree. This keeps the click
from propagating while using the viewport input API. Static review and `git diff --check`
only; no Godot rerun was performed, so T045 runtime verification remains open.

#### T045 update — integrate user-added CrystalWitch UI atlas

The user added Elysian's free UI bundle under `assets/ui/User Interface Packs - Free/`.
The free bundle includes the CrystalWitch theme atlas but not the full-version book menu
layout. `ui/skill_tree_layout.gd` now uses an atlas crop for the crystal orb beside the
Skill Tree title and applies the pack's purple/lavender palette to the open-book pages and
frame. Keep the user-added PNG/import files intact; the existing custom book glyph remains
the toolbar icon. The bundled READ ME allows free/commercial project use and asks for the
creator to be mentioned in commercial releases; record Elysian Game Studio in game credits
if commercially distributed. Static path/source review and `git diff --check` only; Godot
visual/runtime verification remains open under T045.

#### T045 visual revision — use CrystalWitch frames on both pages

After the user reported the first integration was not visually recognizable, the menu
pages were changed from plain colored panels to paired nine-patch frames sampled from
the CrystalWitch atlas. The frame regions (25,18,47,79) and (84,17,57,80) are within the
351×304 source image. Purple page fills and matching normal/hover/pressed button styles
make the pack's theme more visible while preserving the existing skill graph and book
animation. The free pack still does not include the full book-menu layout. Static review
and `git diff --check` only; no Godot rendering check was run, so appearance and crop
quality remain unverified under T045.

#### T045 correction — unsupported NinePatchRect flip

The user reported that assigning `flip_h` to a `NinePatchRect` fails because that property
is unsupported on this control. Removed the assignment and renamed the helper argument to
describe left-page placement. Each page still uses its own CrystalWitch atlas region.
Static source review and `git diff --check` only; no Godot rerun, so T045 remains open for
runtime verification.

#### T045 visual replacement — CraftPix animated book and single-spread layout

The user reported that the previous UI was visually poor, replaced the asset at the existing UI location, and asked for all content on one visible spread with a page flip when switching Weapon/Character. The new user-added CraftPix pack is now used directly.

| Included file | Purpose |
| --- | --- |
| `ui/health_bar.gd` | Replace the T-slot's former custom SVG texture with an atlas crop from the CraftPix open-book sheet. |
| `ui/skill_tree_layout.gd` | Display the open-book crop as the resting spread, remove scrolling, use open/close sheets for book transitions, and use directional page-turn sheets when changing tabs. |
| `ui/skill_tree_graph.gd` | Scale skill nodes to fit the graph's actual available width and height while keeping their layout ratios and links. |
| `specs/001-integrate-basement-stage/tasks.md` | Update T045 requirements for the replacement pack, one-spread fit, and Weapon/Character page-turn animation. |
| `specs/001-integrate-basement-stage/validation.md` | Record the replacement asset, one-spread implementation, static observations, and outstanding runtime checks. |
| `docs/implementation-changelog.md` | Maintain this cumulative implementation-group record. |

**Referenced user-added assets:** `PNG/Open_book.png` supplies the resting spread, opening frames, and toolbar book icon; `PNG/Close_book.png` supplies closing frames; `PNG/Turning_pages_left.png` and `PNG/Turning_pages_right.png` supply tab-change flips. These asset files and import metadata were not edited. The previously added `assets/ui/skill_tree_book.svg` remains in the workspace but is no longer referenced by the toolbar.

**Integration effects:** Skill Tree/HUD presentation only. Node positions, purchases, progression rules, health/rage, input bindings, and basement/map systems were not changed.

**Static review:** the builder has no `ScrollContainer`; weapon and character graphs use available space rather than oversized fixed heights; node scale is bounded by the graph's width/height and the smallest horizontal/vertical gap or edge margin. Asset paths match the replacement folder. `git diff --check` passes. **Not run:** Godot parse/runtime, rendered layout at supported resolutions, T/click input, page flips, or pause/resume. T045 remains open pending those observations. BUG-003 remains open; no teammate/reviewer sign-off is claimed.

#### T045 correction — single-page face, icon size, and flip direction

The user reported that menu text crossed the book seam, the toolbar book appeared smaller than skill icons, and tab flips moved in the wrong direction. All layout text and tree content now occupy only the right-hand page safe area. The weapon tree was re-spaced into two columns for that narrower page, and the graph's node scaling checks pairwise two-dimensional spacing and page-edge clearance. The toolbar atlas now crops tightly around the open-book frame and slightly enlarges its icon control. Weapon-to-Character uses the left-turn sheet and Character-to-Weapon uses the right-turn sheet, reversing the previous mapping.

| Included file | Purpose |
| --- | --- |
| `ui/skill_tree_layout.gd` | Restrict content to the right page, reflow the weapon graph, and reverse page-turn sheet selection. |
| `ui/skill_tree_graph.gd` | Scale nodes against pairwise horizontal/vertical separation and graph-edge clearance. |
| `ui/health_bar.gd` | Crop the open-book icon to its non-transparent bounds and render it at the skill-slot scale. |
| `specs/001-integrate-basement-stage/tasks.md` | Refine T045 acceptance for single-page-face content, comparable icon size, and correct turn direction. |
| `specs/001-integrate-basement-stage/validation.md` | Record the correction and remaining runtime visual checks. |
| `docs/implementation-changelog.md` | Preserve this cumulative change and its evidence boundary. |

**Integration effects:** HUD and Skill Tree presentation only. No skill/progression logic or input mapping changed. `git diff --check` passes. No Godot runtime, visual or input checks were performed; one-face fit, icon size, and flip direction remain unverified in-game. T045 remains open, BUG-003 remains independent, and no reviewer sign-off is claimed.

#### T045 correction — move the single-page content to the left leaf

The user reported that the content was misaligned and had been pushed onto the wrong page. `ui/skill_tree_layout.gd` now places the same single-page content area on the left leaf's mirrored safe region (7%-47% of the book artwork width), leaving clearance at the center seam. No tree, progression, icon, animation, or input behavior was changed in this correction. Static source inspection and `git diff --check` only; no Godot visual check was run. The placement is not yet runtime-verified, T045 remains open, and no review sign-off is claimed.

| Included file | Purpose |
| --- | --- |
| `ui/skill_tree_layout.gd` | Move the page content container from the right leaf to the corresponding left leaf safe area. |
| `specs/001-integrate-basement-stage/validation.md` | Record the correction and note that visual alignment remains unverified. |
| `docs/implementation-changelog.md` | Preserve this cumulative update. |

#### T045 correction — center both tab layouts across the open-book spread

The user shared screenshots of the Weapon and Character tabs and reported that both appeared shifted. Re-centered the content box within the full open-book artwork with equal side margins, restored the weapon tree's wider node distribution across the spread, right-aligned the skill-point summary, and centered the footer buttons. Long section labels now wrap within the book content width. This supersedes the immediately prior left-leaf-only adjustment because the screenshots clarified that both tabs should balance across the spread.

| Included file | Purpose |
| --- | --- |
| `ui/skill_tree_layout.gd` | Center the content area on the full book, distribute the weapon tree across the spread, align header/footer controls, and wrap long labels. |
| `specs/001-integrate-basement-stage/tasks.md` | Update T045 acceptance from single-leaf placement to a balanced, overflow-free two-page spread. |
| `specs/001-integrate-basement-stage/validation.md` | Record the screenshot-driven correction and runtime-verification limit. |
| `docs/implementation-changelog.md` | Preserve this cumulative correction. |

**Integration effects:** Skill Tree presentation only; progression, tree allocation and input mapping are unchanged. `git diff --check` passes. No Godot rendering was run; both-tab alignment, wrap behavior and no-overflow acceptance remain unverified, so T045 stays open. No reviewer sign-off is claimed.

#### T045 refinement — prominent element choices and left-side hover descriptions

The user reported that skill nodes were too small to read and supplied a sketch for larger elemental choices, a tree shown after element selection, and a skill-description panel on the left while hovering. The existing GameManager form-purchase/selection path is retained; this change only updates the presentation and hover detail. Existing element-orb and spell-icon textures are used, so no additional asset download is needed.

| Included file | Purpose |
| --- | --- |
| `ui/skill_tree_layout.gd` | Add the left detail panel; send the graph description into it on hover; retain the existing element-choice callback that spends the current point and reveals the selected branch tree. |
| `ui/skill_tree_node.gd` | Enlarge node circles and icons; add a prominent display variant for element-choice nodes; emit hover detail signals. |
| `ui/skill_tree_graph.gd` | Fit normal and large node dimensions using per-node sizes and pairwise spacing. |
| `specs/001-integrate-basement-stage/tasks.md` | Add prominent element choices and left-side hover descriptions to T045 acceptance. |
| `specs/001-integrate-basement-stage/validation.md` | Record the UI change, reused assets, and unrun runtime checks. |
| `docs/implementation-changelog.md` | Maintain this cumulative implementation record. |

**Integration effects:** Skill Tree presentation/input feedback only. The existing one-point element selection and skill/progression rules are not changed. **Static review:** existing `32x32` elemental orbs and spell icons are referenced; no external UI pack or download is needed. `git diff --check` passes. **Not run:** Godot parse/render, hover, element selection, or visual readability checks. T045 remains open; BUG-003 and other reviewer boundaries are unchanged.

#### T045 refinement — fixed boxes, less prose, larger nodes, and graph zoom

The user reported that long description text overflowed its box and that tree nodes remained hard to read. The details card now has a fixed 176 px width with anchored inner layout, smaller wrapped text, and clipping within the box; box dimensions do not depend on the displayed description. Redundant instructional/threshold headings were removed from the tree area, with only concise point and unlock guidance retained in the left card. Node icons/circles are larger, especially the four element choices. Added fixed-size zoom out/in/percentage/reset controls, wheel zoom (65%-200%), and middle-button panning inside the clipped graph view. Text drawn inside a node does not determine the node's layout size.

| Included file | Purpose |
| --- | --- |
| `ui/skill_tree_layout.gd` | Fix the detail-card geometry, reduce description font, remove redundant graph-area text, retain concise guidance at left, and add fixed-size zoom controls. |
| `ui/skill_tree_graph.gd` | Add bounded zoom, wheel input, middle-button panning, and clipping while keeping graph bounds fixed. |
| `ui/skill_tree_node.gd` | Enlarge normal and element icons and keep node box dimensions independent of label text. |
| `specs/001-integrate-basement-stage/tasks.md` | Update T045 scope and acceptance for fixed box geometry and zoom. |
| `specs/001-integrate-basement-stage/validation.md` | Record implementation boundaries and unrun visual/runtime checks. |
| `docs/implementation-changelog.md` | Maintain this cumulative group record. |

**Shared-system effects:** Skill Tree presentation and navigation only; skill spending, unlock thresholds, character statistics, HUD behavior, and GameManager rules remain unchanged. Reuses the existing element-orb and skill-icon PNGs; no new external asset is required. `git diff --check` passes. Godot parse/render, wheel/middle input, text overflow, and supported-resolution layout checks were not run. T045 remains open, with no reviewer sign-off claimed.

#### T045 screenshot correction — keep zoom controls and skill bar within bounds

The user supplied a Skill Tree screenshot showing the top-right zoom controls outside the book art and the details card crossing the center seam, plus a HUD screenshot showing the skill bar shifted left and too large. `ui/skill_tree_layout.gd` now uses symmetric 8% book margins with clipping, relocates zoom controls into a right-aligned row above the graph, and narrows the fixed details card to 144 px so it stays on the left leaf. `ui/health_bar.gd` reduces slot size from 38×36 to 35×33 px, reduces gaps/padding, and centers the bar at the viewport midpoint.

| Included file | Purpose |
| --- | --- |
| `ui/skill_tree_layout.gd` | Bound menu content to a symmetric safe area, move zoom controls out of the crowded main header, and keep the detail card within the left page. |
| `ui/health_bar.gd` | Reduce skill-bar footprint and center it horizontally. |
| `specs/001-integrate-basement-stage/validation.md` | Record screenshot findings, implementation, and unrun runtime checks. |
| `docs/implementation-changelog.md` | Maintain this cumulative record. |

**Integration effects:** HUD presentation and Skill Tree layout only. Skill input/selection, cooldowns, progression and health behavior are unchanged. `git diff --check` passes. Godot screenshot/render verification was not run; final visual alignment and size remain unverified, and T045 remains open without reviewer sign-off.

#### T045 follow-up — confine details to left book leaf

The supplied screenshot still showed the fixed detail card crossing the book seam after the earlier width reduction. Narrowed the card from 144 px to 120 px, leaving the graph area on the right leaf.

| Included file | Purpose |
| --- | --- |
| `ui/skill_tree_layout.gd` | Keep the fixed detail panel inside the left book page. |
| `specs/001-integrate-basement-stage/validation.md` | Record the screenshot finding, source change, and remaining visual verification. |
| `docs/implementation-changelog.md` | Maintain this cumulative implementation record. |

**Integration effects:** Skill Tree layout only; skill unlocks, points, graph behavior, and the already reduced/centered skill bar are unchanged. `git diff --check` passes. Godot rendering was not run, so final alignment remains unverified and T045 remains open without reviewer sign-off.

#### T045 screenshot correction — compensate for HUD CanvasLayer scale

The latest HUD screenshot showed the skill bar positioned substantially right of center. Source inspection found `ui/hud.tscn` applies an X scale of 1.5 to the root `CanvasLayer`, so centering the bar at a local 0.5 anchor rendered it at 0.75 of the viewport width. The bar now maps the viewport center through the inverse canvas transform and uses exact half-width offsets. The bar remains at 35×33 px slots with tightened gaps and padding.

Renamed the expanded controller from `health_bar.gd` to `player_hud.gd`, updated its global class name and the scene resource path, and moved the UID sidecar without changing its UID.

| Included file | Purpose |
| --- | --- |
| `ui/health_bar.gd` → `ui/player_hud.gd` | Rename the combined player HUD controller and compensate for the CanvasLayer transform when centering the skill bar. |
| `ui/health_bar.gd.uid` → `ui/player_hud.gd.uid` | Preserve the Godot script UID under the new filename. |
| `ui/hud.tscn` | Point the HUD scene at the renamed script while keeping its UID. |
| `specs/001-integrate-basement-stage/tasks.md` | Record the centered-bar criterion and controller name in T045 scope. |
| `specs/001-integrate-basement-stage/validation.md` | Record the screenshot diagnosis, static evidence, and remaining runtime check. |
| `docs/implementation-changelog.md` | Maintain this cumulative implementation record. |

**Integration effects:** HUD presentation and script resource naming only. Health/rage logic, skill selection, cooldowns, input mappings, and progression are unchanged. `git diff --check` passes. Godot rendering/input behavior was not run; centering is supported by static transform math but remains runtime-unverified. T045 remains open with no reviewer sign-off claimed.

#### T045 parser correction — use the CanvasLayer viewport API

The user reported a parser error because `get_viewport_rect()` is unavailable on the `CanvasLayer` script base. `ui/player_hud.gd` now obtains the visible viewport width through `get_viewport().get_visible_rect().size.x` and uses that width for the center-anchor calculation.

| Included file | Purpose |
| --- | --- |
| `ui/player_hud.gd` | Replace the unsupported viewport call in the skill-bar centering code. |
| `specs/001-integrate-basement-stage/validation.md` | Record the parser report, correction, and unrun Godot check. |
| `docs/implementation-changelog.md` | Maintain this cumulative implementation record. |

**Integration effects:** HUD layout only; health/rage behavior and skill controls are unchanged. `git diff --check` passes. Godot parsing and rendering were not run, so the parser correction and visual placement remain unverified. T045 remains open without reviewer sign-off.

#### T045 screenshot refinement — nudge selected weapon tree right

The latest book-page screenshot showed the selected weapon tree sitting slightly left in its page. Added a 4% graph-width display offset for the selected weapon tree. Nodes and links share the offset; the element-selection graph and Character tree remain unchanged.

| Included file | Purpose |
| --- | --- |
| `ui/skill_tree_graph.gd` | Apply a normalized presentation offset to graph nodes and connecting lines. |
| `ui/skill_tree_layout.gd` | Nudge only the selected weapon tree 4% to the right. |
| `specs/001-integrate-basement-stage/tasks.md` | Record the selected-tree alignment requirement and the pending Dark Fairy task. |
| `specs/001-integrate-basement-stage/validation.md` | Record the screenshot adjustment and boss-HUD ownership boundary. |
| `docs/implementation-changelog.md` | Maintain this cumulative implementation record. |

**Integration effects:** Skill Tree presentation only. Unlocks, node positions relative to each other, selection, points, zoom, and player HUD health/rage behavior are unchanged. `git diff --check` passes. Godot visual/zoom verification was not run; T045 remains open without reviewer sign-off.

#### T046 request — Dark Fairy boss HUD top-center

Static inspection found the Dark Fairy health bar and phase label already centered horizontally but anchored to the bottom of the viewport. The latest user-provided screenshot shows the phase label over the lower skill bar, consistent with the bottom anchors; the boss progress bar is obscured by that lower HUD area in the crop. The requested vertical reposition belongs to `scenes/enemies/darkfairy/darkfairy.tscn`, a Duy-owned boss scene. Per `.specify/memory/constitution.md` ownership boundary, no edit was made pending Duy approval. T046 records the narrow scene-only scope and acceptance criteria; the screenshot is user-provided runtime evidence, not a local playtest, and no implementation or reviewer agreement is claimed.

#### T047 implementation — player-only bounded stair step-up

The user reported that the player still gets stuck on the B1/B2 stair connector. Added a bounded
step attempt in the player movement override: only when grounded horizontal movement is blocked,
the code checks vertical clearance, the raised horizontal path, and a walkable landing within
0.75 world units. No map or shared character collision logic was changed.

| Included file | Purpose |
| --- | --- |
| `scenes/player/player.gd` | Add the bounded player-only step-up and landing checks. |
| `specs/001-integrate-basement-stage/tasks.md` | Record T047 scope and keep it open until required runtime checks are complete. |
| `specs/001-integrate-basement-stage/validation.md` | Record Godot startup evidence and the unverified traversal/regression checks. |
| `docs/implementation-changelog.md` | Maintain this cumulative implementation record. |

**Integration effects:** Player horizontal traversal only. `BaseCharacter`, enemy movement, basement
map/GridMap colliders, stair meshes, navigation, and T044 floor visibility are unchanged. Godot
4.7.2 F6 launched `basement_full.tscn` with the player and HUD visible, confirming script parse and
scene startup. The interactive traversal attempt was stopped by physical Escape before stair
ascent/descent and regression checks could be observed; no functional pass or reviewer agreement
is claimed. `git diff --check` passes with documentation line-ending warnings. T047 remains open
pending the B1/B2 traversal, wall/gap, normal movement, and jump/landing runtime checks.

#### T048 implementation — player back sword and elemental status VFX

Enabled the existing sword at its current back mount and connected the user-added PVFX sheets to the existing player-owned burn, ice-slow, and freeze application points. Active casts now suppress the blade until their state exits. Thrown skills rely on projectile-owned suppression; removed the skill state's duplicate suppress call so the blade returns when the projectile returns. Burn and frozen-chill loops are attached to the affected enemy for the existing status duration; slow adds the Pixelfx clock marker; freeze plays a PVFX encase one-shot. Reapplying a loop refreshes its timer instead of adding another loop.

| Included file | Purpose |
| --- | --- |
| `scenes/player/player.tscn` | Enable the pre-existing `Direction/Blade` at the existing back transform. |
| `scenes/player/states/skillstate.gd` | Hide the blade during active casts, restore it on state exit, and preserve projectile-owned hiding during thrown skills. |
| `scenes/player/player.gd` | Trigger the visual helper at current burn, slow, and freeze status applications without changing their gameplay rules. |
| `scenes/player/battle_vfx.gd` | Load PVFX sheets from their manifests, play attached 3D status animations, refresh loop durations, and play the freeze one-shot. |
| `assets/effects/pixelfx/status/slowed/slowed.png` | Project-local Pixelfx sprite sheet for the slow clock marker. |
| `assets/effects/pixelfx/status/slowed/slowed.json` | Pixelfx frame rectangles, timing, loop, and pivot metadata for the slow marker. |
| `specs/001-integrate-basement-stage/tasks.md` | Define T048 ownership, scope, acceptance, and update its implementation state. |
| `specs/001-integrate-basement-stage/validation.md` | Record T048 boundaries, static evidence, and unrun runtime checks. |
| `docs/implementation-changelog.md` | Maintain this cumulative implementation record. |

**Referenced user-added inputs (already untracked at the start of this slice; not modified):** `assets/effects/pvfx-foundry-thirteen-spritesheets/effects/status/burning-aura/lit/grid/{sprite-sheet.png,manifest.json}`, `.../status/frozen-chill/lit/grid/{sprite-sheet.png,manifest.json}`, and `.../ice/freeze-encase/lit/grid/{sprite-sheet.png,manifest.json}`.

**Integration effects:** Player scene and player skill presentation only. Existing enemy status methods, durations, damage ticks and movement remain unchanged; no `scripts/enemy.gd` or Duy-owned boss file changed. Existing slash files/sheets, `BattleVFX.shield`, and `BattleVFX.emberline_ring` are unchanged. The user's PVFX directory remains untouched.

**Static review:** referenced sheets and manifests exist and provide fixed-grid frame coordinates and durations accepted by the loader. The Pixelfx slow sheet and metadata were exported and inspected. `git diff --check` passes, with only Git's CRLF/LF normalization warning for validation docs. **Not run:** tests, Godot import/parse, runtime visual, combat, status expiry/refresh, or sword hide/restore checks. T048 is implemented but remains open until those in-game checks are observed; no reviewer agreement is claimed.

#### T049 implementation — floating sword idle motion

Added a gentle hover and sway to the existing player sword so it reads as suspended instead of rigid. The animation records the sword's current instance transform as its resting pose and applies small vertical and angular offsets around that pose. The existing sword asset, mount, facing and visibility suppression remain intact.

| Included file | Purpose |
| --- | --- |
| `scenes/player/weapon/floating_blade.gd` | Animate subtle hover and sway relative to the sword instance's captured rest transform. |
| `scenes/player/weapon/blade.tscn` | Attach the floating animation to the existing sword root. |
| `.godot/uid_cache.bin` | Existing tracked Godot UID cache changed during this workspace update and was retained without manual edits. |
| `specs/001-integrate-basement-stage/tasks.md` | Record T049 ownership, scope, acceptance and open runtime status. |
| `specs/001-integrate-basement-stage/validation.md` | Record the review boundary, implementation evidence and unrun visual checks. |
| `docs/implementation-changelog.md` | Maintain this cumulative implementation record. |

**Integration effects:** player sword presentation only; the blade scene is only instanced by the player. No shared character, enemy, combat, skill, sword asset, or mount transform changes. Existing attack/skill suppression remains responsible for hiding the animated node.

**Static review:** implementation offsets are relative to the instance transform captured on `_ready()`. `.godot/uid_cache.bin` grew from 429,747 to 490,208 bytes during the workspace update; no Godot process was running during final inspection, so its writer/source is unknown. The tracked cache was preserved without manual edits. `git diff --check` is the whitespace validation. **Not run:** Godot import/parse or in-game visual/attack/skill checks, so the motion amplitude and final appearance remain unverified and may need visual tuning. T049 stays open pending that runtime review; no reviewer agreement is claimed.

#### T050 implementation — player dash afterimage trail

Added a short trail during the existing dash. Each echo duplicates the player's currently animated `Sprite3D`, fixes it at the sampled world pose, tints it cool blue, and fades it quickly. The existing PVFX dash-dust sheet plays once at the dash origin and aligns to the projected travel direction when the camera is available. Dash speed, duration, cooldown, invincibility and collision are unchanged.

| Included file | Purpose |
| --- | --- |
| `scenes/player/states/dash.gd` | Start the trail, emit afterimages through the dash, and finish with a last pose. |
| `scenes/player/battle_vfx.gd` | Create/fade world-fixed snapshots of the player's actual sprite and play the existing PVFX dash-dust animation. |
| `specs/001-integrate-basement-stage/tasks.md` | Record T050 scope, acceptance and open runtime status. |
| `specs/001-integrate-basement-stage/validation.md` | Record the asset review, integration evidence and remaining checks. |
| `docs/implementation-changelog.md` | Maintain this cumulative implementation record. |

**Referenced user-added inputs (not modified):** `assets/effects/pvfx-foundry-thirteen-spritesheets/effects/smoke/dash-dust/lit/grid/{sprite-sheet.png,manifest.json}`. Static manifest check found 13 non-looping frames on a 68×32 canvas with 780 ms total duration. Pixelfx `status/haste` was inspected but not selected because its generic humanoid afterimages do not match the Foxy player; the trail reuses Foxy's live sprite instead.

**Integration effects:** player dash presentation only. No gameplay movement, enemy, shared character, slash, or skill code changed. **Static review:** PVFX asset paths/manifest and dash-state call sites inspected; `git diff --check` is the whitespace validation. **Not run:** Godot parse/import, in-game direction, scale, visual quality, fade cleanup, or dash regression checks. The dust rotation also depends on a camera being available; otherwise it retains its default horizontal orientation. T050 remains open pending visual/runtime review; no reviewer agreement is claimed.

#### T051 implementation — stronger dash trail visibility

Retuned the T050 trail after user feedback that it was too faint. Afterimages now emit every 32 ms instead of 45 ms, start at 0.62 alpha instead of 0.34, and fade over 0.28 s instead of 0.22 s. The existing PVFX dash dust is scaled from 0.22 to 0.30 and opacity from 0.70 to 0.90. Dash gameplay values remain unchanged.

| Included file | Purpose |
| --- | --- |
| `scenes/player/states/dash.gd` | Emit the existing afterimage snapshots more densely during dash. |
| `scenes/player/battle_vfx.gd` | Increase afterimage visibility/fade duration and dash-dust size/opacity. |
| `specs/001-integrate-basement-stage/tasks.md` | Record T051 scope, acceptance and open visual status. |
| `specs/001-integrate-basement-stage/validation.md` | Record before/after tuning values and unrun visual check. |
| `docs/implementation-changelog.md` | Maintain this cumulative implementation record. |

**Integration effects:** player dash presentation only; no change to movement, cooldown, invincibility, collision or other VFX. **Static review:** tuned values inspected and `git diff --check` is the whitespace check. **Not run:** Godot playtest or visual overlap/strength review, so the final prominence remains unverified. T051 stays open pending a Godot view; no reviewer agreement is claimed.

#### T052 implementation — dash afterimage alpha blending

Fixed the likely reason the afterimages were invisible: the source player sprite uses alpha-cut discard and each duplicate was assigned partial opacity. Temporary copies now use standard alpha blending before the tint/fade is applied; the source Foxy sprite retains its original pixel-edge mode.

| Included file | Purpose |
| --- | --- |
| `scenes/player/battle_vfx.gd` | Disable alpha-cut only on duplicated dash afterimages so partial opacity can blend. |
| `specs/001-integrate-basement-stage/tasks.md` | Record T052 scope, acceptance and runtime status. |
| `specs/001-integrate-basement-stage/validation.md` | Record the likely cause, alpha mode evidence and unrun runtime check. |
| `docs/implementation-changelog.md` | Maintain this cumulative implementation record. |

**Integration effects:** temporary dash copies only; the base sprite's alpha-cut, dash mechanics and other VFX are unchanged. **Static review:** copied node now sets `SpriteBase3D.ALPHA_CUT_DISABLED` before setting partial `modulate.a`; Godot's [SpriteBase3D docs](https://docs.godotengine.org/en/stable/classes/class_spritebase3d.html#enum-spritebase3d-alphacutmode) define mode 0 as blending and mode 1 as discard. **Not run:** Godot parse or visual confirmation, so visibility/fade is not runtime-verified. T052 remains open until seen in game; no reviewer agreement is claimed.

#### T053 implementation — Dark Fairy health-bar style synchronization

Changed the Dark Fairy boss health bar from Godot's plain `ProgressBar` to the same textured presentation used by regular enemies. It reuses the Kenney red flat button texture for the progress and under layers, the dark under tint, texture filter, z-index and four-pixel nine-patch frame. Boss-specific size/placement and health update behavior remain unchanged; the script's bar type annotation now matches the new node type.

| Included file | Purpose |
| --- | --- |
| `scenes/enemies/darkfairy/darkfairy.tscn` | Apply the regular enemy texture/tint/nine-patch health-bar style to the existing boss bar. |
| `scenes/enemies/darkfairy/darkfairy.gd` | Keep the boss bar's typed node reference compatible with `TextureProgressBar`. |
| `specs/001-integrate-basement-stage/tasks.md` | Record T053 scope, relayed owner approval and open runtime status. |
| `specs/001-integrate-basement-stage/validation.md` | Record the style comparison, review boundary and unrun checks. |
| `docs/implementation-changelog.md` | Maintain this cumulative implementation record. |

**Integration effects:** Dark Fairy HUD presentation and its static bar node type only. `scenes/ui/enemy_health_bar.tscn`, regular enemy behavior, boss health/phase logic, boss label and the user's existing Dark Fairy scene edits are preserved. The user reports Duy approval for the style change; no direct reviewer agreement is claimed. **Static review:** boss texture/style properties match the regular enemy bar source. `git diff --check` is the whitespace validation. **Not run:** Godot import/parse or in-game visual comparison, so T053 remains open until runtime review.

#### T054 implementation — player ultimate cut-in

Added a player-owned cinematic before the existing ultimate execution. A ready ultimate now captures its selected ID, pauses gameplay, circles and zooms the active camera toward the player, then displays the rendered Pixelfx black/white impact-frame with an elemental accent and that ultimate's Vietnamese name. The camera's original transform/FOV and previous pause state are restored before the captured ultimate casts. A missing camera/current scene keeps the old immediate-cast path. Early exit also restores camera/pause state.

| Included file | Purpose |
| --- | --- |
| `scenes/player/player.gd` | Gate the cut-in on ultimate readiness, capture the selected skill, prevent duplicate starts, and cast after cinematic completion. |
| `scenes/player/ultimate_cinematic.gd` | Pause-aware camera orbit/zoom, impact frame/title, and camera/pause cleanup. |
| `scenes/player/ultimate_cinematic.gd.uid` | Preserve the Godot resource UID sidecar for the new cut-in script. |
| `scenes/player/battle_vfx.gd` | Add an opt-in always-processing Pixelfx impact-frame overlay for the paused impact beat; normal impact calls retain their existing path. |
| `assets/effects/pixelfx/impacts/impact-frame/impact-frame.png` | Add the 10-frame transparent Pixelfx anime impact-frame sheet rendered for this cut-in. |
| `assets/effects/pixelfx/impacts/impact-frame/impact-frame.json` | Preserve frame timing, atlas layout, and Pixelfx pivot metadata for the impact-frame sheet. |
| `specs/001-integrate-basement-stage/tasks.md` | Record T054 scope, acceptance, total task count, and open runtime status. |
| `specs/001-integrate-basement-stage/validation.md` | Record the review boundary, implementation evidence, static check, and unrun runtime checks. |
| `docs/implementation-changelog.md` | Maintain the cumulative implementation record. |

**Integration effects:** player ultimate presentation and temporary use of the active shared `Camera3D`; no camera-rig, damage, cooldown, enemy, slash, or ice-shield changes. Existing sword/dash/status and boss/map working-tree changes were preserved. The existing Pixelfx source license and notice remain in the local library checkout. **Static review:** the local Pixelfx catalog and rendered 10-frame sheet (0.3 s, 320×180) were inspected alongside all eight ultimate names, four element colors, readiness/capture flow, pause-mode overrides, camera/FOV restoration, early-exit cleanup, and asset path. `git diff --check` found no whitespace errors; Git emitted line-ending normalization warnings for already modified Markdown records. **Not run:** Godot parse/import or in-game visual/camera/cast/cleanup checks. Orbit duration, framing, impact readability and timing remain subject to runtime review; T054 stays open and no reviewer agreement is claimed.


#### T055 implementation — front-facing ultimate cut-in pose

Updated the cut-in to show Foxy's front-facing idle while the camera zooms and the impact/title card appears. Before pausing, the player stores current and pending direction, animation name/playback position/active state, and sprite frame/flip, then sets direction to down and starts idle_down at its first front-facing frame. The existing cinematic cleanup restores the player's directions and animation state before restoring the camera/pause state. The cut-in can now be interrupted without leaving the player facing or animating in the temporary pose.

| Included file | Purpose |
| --- | --- |
| scenes/player/player.gd | Capture, apply and restore the temporary front-facing player pose and prior animation state. |
| scenes/player/ultimate_cinematic.gd | Apply the pose at cut-in start and restore it on completion/abort before unpausing. |
| specs/001-integrate-basement-stage/tasks.md | Record T055 ownership, scope, acceptance, task count and open runtime status. |
| specs/001-integrate-basement-stage/validation.md | Record static animation mapping/state evidence and unrun runtime checks. |
| docs/implementation-changelog.md | Maintain the cumulative implementation record. |

Integration effects: player-only presentation during the existing ultimate cut-in. Normal animation assets, state-machine behavior, gameplay and camera/cut-in timings are unchanged. Static review confirmed down is the camera-facing orientation and idle_down exists with front frames 16/20; git diff --check passes. Godot parse/playtest and animation restoration from varied starting poses remain NOT RUN, so the face-forward visual and exact in-game restore are unverified; T055 remains open and no reviewer agreement is claimed.


#### T056 implementation — zoom-only ultimate camera

Removed the cut-in camera orbit and its positional movement. The camera now remains at its saved position and orientation while its FOV eases to 68% of the starting value during zoom-in, then returns during zoom-out. The exact original camera transform/FOV is restored before the game resumes and casts the selected ultimate. This supersedes the T054 orbit behavior; impact frame, front-facing player pose, pause duration, and skill effects are otherwise unchanged.

| Included file | Purpose |
| --- | --- |
| scenes/player/ultimate_cinematic.gd | Replace orbit/translation with FOV-only zoom-in and zoom-out. |
| specs/001-integrate-basement-stage/tasks.md | Update the current cut-in acceptance, task total, and record T056 scope/status. |
| specs/001-integrate-basement-stage/validation.md | Record the review boundary, source evidence, and unrun runtime checks. |
| docs/implementation-changelog.md | Maintain the cumulative implementation record. |

Integration effects: active Camera3D FOV only; position/orientation remain fixed by the cut-in methods. Player pose, pause, impact/title, skill cast, camera rig, and gameplay values are unchanged. Static review confirmed zoom update methods only write FOV; git diff --check passes. Godot parse/playtest and actual visual stability/framing remain NOT RUN, so T056 stays open and no reviewer agreement is claimed.


#### T057 implementation — expand Skill Tree spread and graph

Expanded the book spread horizontally, used more of the spread for page content, made the description panel responsive to viewport width, reduced spacing between the description and graph, and set the initial graph zoom to 110%. The existing tabs, graph coordinates, node purchase callbacks, pan/zoom behavior, and progression rules remain as before.

| Included file | Purpose |
| --- | --- |
| ui/skill_tree_layout.gd | Increase the open-book/page footprint and give the graph a wider responsive area with a modestly larger default view. |
| specs/001-integrate-basement-stage/tasks.md | Record T057 scope, owner, acceptance, updated task total and open runtime state. |
| specs/001-integrate-basement-stage/validation.md | Record the pre-implementation boundary, implementation details and unrun runtime checks. |
| docs/implementation-changelog.md | Maintain this cumulative implementation record. |

Integration effects: Skill Tree presentation only. Weapon/character tab content, selection/allocation, tooltips, pan/zoom controls and gameplay progression callbacks are preserved. Static review confirms responsive size formulas and unchanged graph/node construction; `git diff --check` is the whitespace check. Godot parse/import, responsive visual/layout checks and input/allocation interaction are NOT RUN. T057 remains open until runtime visual/input verification; no reviewer agreement is claimed.


#### T058 implementation — lightning enemy status visual

Added the local Pixelfx `lightning/electrified` loop as the enemy status visual for lightning attacks that already apply the short freeze/stun mechanic. This includes elemental weapon hits, the active chain/strike/storm skills and both lightning ultimates. The current `apply_skill_freeze` logic and durations remain unchanged, while ice skills continue to use the existing frozen presentation.

| Included file | Purpose |
| --- | --- |
| scenes/player/player.gd | Route every lightning freeze/status call site to an explicit electric status visual without changing gameplay duration. |
| scenes/player/battle_vfx.gd | Attach the electrified loop to the enemy and use the existing duration timer so repeated hits refresh one sprite. |
| assets/effects/pixelfx/lightning/electrified/electrified.png | Add the rendered 60-frame electrified sprite sheet. |
| assets/effects/pixelfx/lightning/electrified/electrified.json | Preserve frame rectangles, timing, loop, pivot and Pixelfx metadata. |
| specs/001-integrate-basement-stage/tasks.md | Record T058 scope, owner, acceptance, updated task total and open runtime state. |
| specs/001-integrate-basement-stage/validation.md | Record the pre-implementation boundary, asset/source inspection and unrun runtime checks. |
| docs/implementation-changelog.md | Maintain this cumulative implementation record. |

Integration effects: shared enemy status presentation and player lightning-skill call sites only. Fire, ice and wind visuals, enemy freeze mechanics/durations, slash, and ice-shield systems are unchanged. The local Pixelfx catalog candidate and contact sheet were inspected before export; the source library and its license/notice remain unchanged. Static review covered all lightning call sites and status refresh logic. Godot import/parse, in-game scale/contrast and effect expiry/refresh are NOT RUN. T058 remains open pending runtime visual/lifecycle verification; no reviewer agreement is claimed.


#### T059 implementation — Player HUD combat feedback

Added compact in-combat state feedback to the Player HUD. The rage label is visible beside its bar and reports readiness only when the selected ultimate has full rage and no remaining cooldown. Two narrow defense slots show Shift/Dash and L/Parry readiness/cooldown. A status strip displays remaining seconds for current attack/speed buffs and the ice shield. A pulsing low-health label appears for a living player at one-third HP or less.

| Included file | Purpose |
| --- | --- |
| scenes/player/player.gd | Expose current timed attack/speed/shield status to the HUD without changing their values, rules, or durations. |
| ui/player_hud.gd | Add defense cooldown slots, status chips, low-health pulse, and truthful ultimate-ready text. |
| ui/hud.tscn | Reveal and position the rage label alongside the existing rage bar. |
| specs/001-integrate-basement-stage/tasks.md | Record T059 scope, owner, acceptance, task total and pending runtime status. |
| specs/001-integrate-basement-stage/validation.md | Record the review boundary, implementation evidence and unrun runtime checks. |
| docs/implementation-changelog.md | Maintain this cumulative implementation record. |

Integration effects: Player HUD presentation plus display-only timer tracking in the player. Existing input mappings (1-4 slot select, U skill, Shift dash, L parry, I ultimate), cooldowns, buff/shield mechanics, health and Skill Tree behavior are unchanged. Static review matched the displayed keys to `project.godot`, checked one-third HP logic, readiness requirements, status expiry/consumption and bar sizing; `git diff --check` is the whitespace validation. Godot parse/import, viewport fit, key behavior and visual status/cooldown timing are NOT RUN. T059 remains open until runtime visual/input verification; no reviewer agreement is claimed.


#### T060 implementation — Player HUD presentation polish

Removed numeric rage from the visible label and ultimate tooltip while keeping the progress bar and ready state. Reduced skill slots from 35×33 to 29×29 logical pixels, kept the elemental skills/ultimate/tree together, and moved Dash/Parry into a distinct adjacent panel with compact generated pixel icons, key badges and readable cooldown text. Added a soft red screen-edge vignette that pulses only while the player is alive at or below one-third health; it uses a dedicated identity-transform CanvasLayer so the HUD's horizontal scaling does not stretch the effect. The vignette and warning hide while the Skill Tree is open.

| Included file | Purpose |
| --- | --- |
| ui/player_hud.gd | Compact and regroup skill slots, generate Dash/Parry icons, remove rage percentages, and add the low-health edge vignette. |
| ui/hud.tscn | Remove the initial percentage text from the rage label. |
| specs/001-integrate-basement-stage/tasks.md | Record T060 owner, scope, acceptance, task total and pending runtime status. |
| specs/001-integrate-basement-stage/validation.md | Record the review boundary, static implementation evidence and unrun runtime checks. |
| docs/implementation-changelog.md | Maintain this cumulative implementation record. |

Integration effects: Player HUD presentation only. Input mappings, cooldown sources, health rules, Skill Tree behavior and combat logic are unchanged; the icon textures are generated in memory and add no imported assets. Static review checked zero percentage rage strings, slot-to-array indices, icon cache IDs, health gating and shader edge falloff. `git diff --check` reports no whitespace errors; Git emits Markdown CRLF normalization warnings for the already modified changelog and validation record. NOT RUN: Godot parse/import and in-game layout, icon, cooldown, vignette and pulse checks. T060 remains open pending runtime review; no reviewer agreement is claimed.


#### T061 implementation — smaller status text and topmost menu layer

Reduced the active-status chip typography from 8 px to 7 px, chip padding from 3 px to 2 px, and inter-chip spacing from 4 px to 3 px. Reduced the rage label font from 10 px to 8 px. Moved the Skill Tree under a dedicated CanvasLayer at layer 100, above the HUD, low-health vignette, BossHUD, Pixelfx and ultimate-cinematic layers; added `PlayerHUD.MENU_CANVAS_LAYER` for future gameplay menus. Opening the Skill Tree hides the normal HUD and closing it restores the HUD. The menu callback now resolves the HUD through its new CanvasLayer parent.

| Included file | Purpose |
| --- | --- |
| ui/player_hud.gd | Define the shared topmost menu layer and toggle the nested menu layer with HUD visibility. Reduce buff chip spacing/padding. |
| ui/hud.tscn | Place SkillTree under its own layer-100 CanvasLayer and reduce the RageLabel font. |
| ui/skill_tree_layout.gd | Assign the shared menu layer and find the PlayerHUD ancestor after reparenting. |
| specs/001-integrate-basement-stage/tasks.md | Record T061 scope, owner, acceptance, task total and pending runtime status. |
| specs/001-integrate-basement-stage/validation.md | Record layer evidence, implementation details and unrun runtime checks. |
| docs/implementation-changelog.md | Maintain this cumulative implementation record. |

Integration effects: UI ordering and typography only. HUD stays at layer 1, vignette at 2, existing Dark Fairy BossHUD at 3, Pixelfx at 21 and ultimate cinematic at 20/22; only the Bao-owned Skill Tree menu moves to layer 100. No boss scene, input, gameplay or health/cooldown behavior changed. Static review verified menu ancestor lookup, visible-state flow and layer ordering. `git diff --check` reports no whitespace errors; Git emits CRLF normalization warnings for modified Markdown records. NOT RUN: Godot parse/import or runtime menu stacking and text readability checks at supported viewport sizes. T061 remains open pending visual review; no reviewer agreement is claimed.


#### T062 implementation — Wind ultimate “Trăng Tối”

Replaced the second Wind ultimate's one-shot burst with a 3.6-second, 2.5-rotation collision-aware dash around the nearest living enemy within 8m, falling back to the cast position when no target is near. Existing afterimages, dash trail, slash and Wind burst VFX are reused. Pulses every 0.32 seconds damage nearby enemies and apply the current Wind slow; damage pulses do not regenerate the Rage spent to cast. Both Player invulnerability flags are active for the full FSM state, and the hidden blade is restored on exit. The 10-SP Skill Tree requirement, HUD name, cinematic title and concept notes now say “Trăng Tối”; `ultimate_wind_2` and its cooldown remain intact. On completion, cooldowns are cleared only for unlocked Wind active skills.

| Included file | Purpose |
| --- | --- |
| scenes/player/player.gd | Route `ultimate_wind_2` into the new timed state; add orbit movement setup/update/cleanup, immunity, pulse damage/slow and unlocked Wind cooldown reset. Preserve the ultimate ID/cooldown and avoid regenerating Rage from its repeated hits. |
| scenes/player/player.tscn | Register the dedicated WindUltimate FSM node. |
| scenes/player/states/wind_ultimate.gd | Drive the ultimate lifecycle through the existing PlayerState/FSM interface. |
| ui/skill_tree_layout.gd | Rename the Wind ultimate, describe its behavior and set only its second threshold to 10 SP. |
| ui/player_hud.gd | Display “Trăng Tối” for the existing ultimate ID. |
| scenes/player/ultimate_cinematic.gd | Display “Trăng Tối” in the ultimate cut-in. |
| docs/godotgameteam7_full_concept.md | Replace the stale Wind ultimate design and record its 10-SP threshold. |
| specs/001-integrate-basement-stage/tasks.md | Record T062 scope/acceptance and leave it open pending runtime verification. |
| specs/001-integrate-basement-stage/validation.md | Record review boundary, implementation details, static checks and unrun playtest. |
| docs/implementation-changelog.md | Maintain this cumulative implementation record. |

Integration effects: Player combat/FSM movement uses the existing collision-aware step-up and slide path. Enemy damage and slow continue through existing Player helpers; no enemy AI, shared VFX code, other ultimate, or other form is modified. The ultimate alone suppresses Rage gain from its repeated pulses to preserve the meter-spend behavior. Static review checked state lookup/registration, target fallback, immunity flag pairing, threshold/ID/title mappings and cooldown keys. `git diff --check` reports no whitespace errors; Git emits Markdown CRLF-to-LF normalization warnings for the implementation changelog and validation file. NOT RUN: Godot parse/import or in-game unlock, movement/collision, damage/slow, immunity, cleanup, cooldown and Rage checks. T062 remains open pending playtest; no reviewer agreement is claimed.


#### T063 implementation — centered Skill Tree, compact buffs and ultimate glow

Moved the Skill Tree graph to the right within the open page and allowed its nodes to render beyond the graph control while the page retains its outer clip. Reduced active buff chips from 7 px to 6 px, with tighter padding and spacing. Added a temporary fullscreen elemental glow and a pulsing neon treatment on the Player sprite after the cinematic ends; each ultimate has a duration aligned to its active effect, with Wind 2 tied to its 3.6-second state. The original sprite material overlay is restored and the CanvasLayer is removed on expiry, death signal, Wind-state completion or Player tree exit.

| Included file | Purpose |
| --- | --- |
| ui/skill_tree_layout.gd | Apply the rightward responsive graph offset across Skill Tree tabs. |
| ui/skill_tree_graph.gd | Allow graph nodes to extend beyond the graph viewport; the book page remains the outer visual clip. |
| ui/player_hud.gd | Reduce buff-chip font size, margins and separation. |
| scenes/player/player.gd | Start after-cinematic presentation for all ultimate IDs; map element colors/durations, animate intensity, restore the prior sprite overlay and clean up on interruption/exit. |
| scenes/player/ultimate_screen_glow.gdshader | Add pulsing elemental light over the screen image. |
| scenes/player/ultimate_neon.gdshader | Tint and shimmer the Player sprite in the matching elemental neon color. |
| specs/001-integrate-basement-stage/tasks.md | Record T063 scope/acceptance, task total and open runtime status. |
| specs/001-integrate-basement-stage/validation.md | Record the review boundary, implementation, Pixelfx candidate inspection and unrun runtime checks. |
| docs/implementation-changelog.md | Maintain this cumulative implementation record. |

Integration effects: the screen glow uses CanvasLayer 23, above the HUD, BossHUD, Pixelfx and cinematic layers but below the existing topmost menu at layer 100. The sprite shader replaces only `Sprite3D.material_overlay` during presentation and restores its saved value if still owned by this effect. Pixelfx `holy/blessing` was rendered/inspected but not used because its gold spotlight is fixed to its projected screen position and does not track the moving player; no Pixelfx export was added. Existing slash and ice-shield effects are unchanged. Static review checked all ultimate IDs/duration routes, color mapping, prior-material restoration and layer order; `git diff --check` reports no whitespace errors, with Markdown CRLF-to-LF normalization warnings for the changelog and validation record. NOT RUN: Godot parse/import, graph input/visual review at supported aspect ratios, and ultimate color/intensity/timing/restoration playtests. T063 remains open pending runtime visual review; no reviewer agreement is claimed.


#### T063 user refinement — outline-only Player neon

The user clarified that the Player effect should be a neon contour around the sprite, not a tinted duplicate of its full body. Reworked the sprite shader to sample neighboring alpha values and emit only in the transparent pixels directly outside the current sprite silhouette. The source sprite fill and animation colors remain visible underneath unchanged. The shader's frame rectangle now follows the Player's active sprite-sheet frame during the ultimate; the existing screen glow, duration and cleanup remain unchanged.

| Included file | Purpose |
| --- | --- |
| scenes/player/ultimate_neon.gdshader | Draw a pulsing elemental outline from the current sprite-frame alpha edge; discard interior pixels. |
| scenes/player/player.gd | Update shader frame bounds with the active animation frame and preserve existing overlay restoration/cleanup. |
| specs/001-integrate-basement-stage/tasks.md | Clarify T063 acceptance to require a contour-only effect and unchanged sprite fill. |
| specs/001-integrate-basement-stage/validation.md | Record the user clarification, static review and unrun shader/visual checks. |
| docs/implementation-changelog.md | Maintain the cumulative T063 refinement record. |

Integration effects: only the temporary `Sprite3D.material_overlay` shader changes; the source sprite material, base animation and fullscreen elemental glow are unchanged. Static source review confirms the shader subtracts current-pixel alpha from neighboring alpha, bounds sampling to `frame_uv_rect`, and discards zero-edge pixels. `git diff --check` remains the whitespace check. NOT RUN: Godot shader import/compile or visual confirmation of outline width, sheet-frame edges and shimmer during animation. T063 remains open pending runtime review; no reviewer agreement is claimed.


#### T064 user clarification and implementation — stronger ultimate cast/impact VFX

The user clarified that the ultimate cinematic is already satisfactory and asked for more powerful effects when the actual skills are cast. Reused the PVFX Foundry sprites already present in the project: Wind now adds a directional gust and shockwave, with individual blade impacts and a void implosion finish for Trăng Tối; Fire layers a fire pillar/nova or a meteor strike/large explosion; Lightning creates a strong static burst and connects valid enemies with animated lightning chains and vertical strikes. Ice ultimate effects are unchanged.

| Included file | Purpose |
| --- | --- |
| scenes/player/battle_vfx.gd | Add `ultimate_impact()` and a projected PVFX one-shot/loop spawner that uses the existing sprite-frame cache and manifest source size/pivot metadata. |
| scenes/player/player.gd | Add stronger elemental PVFX at the existing Wind, Fire and Lightning cast/pulse/end moments; keep Lightning target effects aligned with the existing horizontal/range and vertical-level damage filters. |
| specs/001-integrate-basement-stage/tasks.md | Record T064 scope, acceptance criteria, task total and pending runtime review. |
| specs/001-integrate-basement-stage/validation.md | Record the clarified scope, PVFX candidate previews, selected assets, static checks, limitation and unrun runtime review. |
| docs/implementation-changelog.md | Maintain this cumulative implementation record. |

Referenced, pre-existing assets (not changed in this slice): `assets/effects/pvfx-foundry-thirteen-spritesheets/effects/{wind/wind-gust,wind/wind-blade,impacts/shockwave-ring,shadow/void-implosion,fire/fire-pillar,explosions/fire-nova,fire/meteor-strike,explosions/big-explosion,lightning/static-burst,lightning/chain-lightning,lightning/lightning-strike}/lit/grid/{sprite-sheet.png,manifest.json}`. The included local license grants CC0 1.0 for effect sheets and manifests.

Integration effects: VFX only. Existing skill IDs, damage, enemy hit filters/statuses, duration, hit timing, cooldown, T063 glow/outline, cinematic/camera, and slash/ice-shield implementations are unchanged. Lightning 1 uses the existing horizontal radius and 2.5-unit height gate; Lightning 2 uses the existing global target's 2.5-unit height gate. `wind/whirlwind` was previewed but not selected because its looping projected sprite would remain at a fixed screen coordinate while the target/camera moves. Static manifest/path review confirmed the selected sheets, pivots and one-shot durations; `git diff --check` passed with Git's Markdown CRLF normalization warnings for changelog/validation. NOT RUN: Godot parse/import or in-game effect scale, occlusion, target alignment, timing and camera-motion review. Since projected one-shot effects stay at their spawn screen coordinate, movement during an animation may cause some drift. T064 remains open pending runtime visual review; no reviewer agreement is claimed.


#### T065 user-requested trial — PVFX on active Ice cone and storm

Replaced two older active Ice skill visuals with the PVFX Foundry `ice/frost-breath` and `ice/ice-spike` sheets to test their style against the game. Ice 2's cone now uses a short directional frost stream sized to its existing reach. Ice 4's storm now uses a one-shot ring of rising ice spikes sized from its existing evolution-scaled radius. The PVFX frame loader uses each sheet's existing timing and pivot metadata.

| Included file | Purpose |
| --- | --- |
| scenes/player/battle_vfx.gd | Expose the shared PVFX sheet renderer as `play_pvfx()`; preserve `ultimate_impact()` as a wrapper so the previous T064 effects are unchanged. |
| scenes/player/player.gd | Swap only the `active_ice_2` and `active_ice_4` effect calls; preserve their damage, range, aim and freeze parameters. |
| specs/001-integrate-basement-stage/tasks.md | Record T065 scope, acceptance criteria, task total and pending user visual review. |
| specs/001-integrate-basement-stage/validation.md | Record candidate preview/manifests, implementation, static checks and unrun runtime review. |
| docs/implementation-changelog.md | Maintain this cumulative implementation record. |

Referenced pre-existing PVFX sheets (not modified): `assets/effects/pvfx-foundry-thirteen-spritesheets/effects/ice/{frost-breath,ice-spike}/lit/grid/{sprite-sheet.png,manifest.json}`. Integration effects: only two active Ice skill visuals change. Active Ice 3's shield and cast ring, both Ice ultimates, slash sheets, Ice status logic and all gameplay behavior remain unchanged. `git diff --check` is the static whitespace check. NOT RUN: Godot parse/import or in-game fit, aim, scale, depth/occlusion and camera-motion review; the user said they can inspect these effects in-game. `frost-breath` is screen-projected at cast position for up to 0.72 seconds, so movement during the animation may cause some drift. T065 remains open pending user visual feedback; no reviewer agreement is claimed.


#### T066 user-requested trial — active Wind, Fire and Lightning PVFX

Following the Ice PVFX trial, replaced selected active-skill visuals for the other three elements. Wind 3 now adds a PVFX wind blade while retaining its sword slash, and Wind 4 uses a timed PVFX whirlwind. Fire 2's delayed detonation now uses a fire nova; Fire 3 uses lava bursts for each existing rage pulse; Fire 4's meteor helper now uses the meteor-strike sheet while retaining its charge. Lightning 2 now chains and strikes only enemies in its current cone; Lightning 3 uses a bolt/static burst at its existing strike center; Lightning 4 adds per-enemy bolts only for living enemies inside its current damage area.

| Included file | Purpose |
| --- | --- |
| scenes/player/player.gd | Swap active Wind 3/4, Fire 2/3 and Lightning 2/3/4 visual calls; mirror existing Lightning shape/range/height filters for target strikes. |
| scenes/player/battle_vfx.gd | Route the existing `meteor()` helper to the checked-in PVFX meteor-strike, retaining its charge effect; existing generic PVFX renderer is reused. |
| specs/001-integrate-basement-stage/tasks.md | Record T066 scope, acceptance criteria, task total and pending user visual review. |
| specs/001-integrate-basement-stage/validation.md | Record reviewed candidates/manifests, implementation, target-filter review, limitation and unrun runtime check. |
| docs/implementation-changelog.md | Maintain this cumulative implementation record. |

Referenced pre-existing sheets (not modified): `assets/effects/pvfx-foundry-thirteen-spritesheets/effects/{wind/wind-blade,wind/whirlwind,explosions/fire-nova,fire/lava-burst,fire/meteor-strike,lightning/chain-lightning,lightning/lightning-strike,lightning/static-burst}/lit/grid/{sprite-sheet.png,manifest.json}`. Integration effects: only the listed active-skill VFX change. Skill behavior, charge and delayed timing, damage/ranges/statuses/cooldowns, Ice skills, ultimates and slash sheets remain unchanged. `BattleVFX.meteor()` has no other project call site beyond active Fire 4. `git diff --check` passed with Markdown CRLF normalization warnings for changelog/validation. NOT RUN: Godot parse/import or in-game scale, facing, overlap and overall fit. The projected two-second Wind whirlwind may drift if Player/camera moves. T066 stays open for user visual feedback; no reviewer agreement is claimed.

#### T067 request — Dark Fairy intro and defeat cut-ins

Static source review found that Dark Fairy engagement currently drives BossHUD visibility and that the existing phase-2 death animation emits defeated before freeing the boss. The user requested a one-time first-encounter introduction and a black-screen, single-slash split finisher. Recorded the Duy-owned review boundary and acceptance criteria in the active task/validation files.

| Included file | Purpose |
| --- | --- |
| specs/001-integrate-basement-stage/tasks.md | Add T067 scope, Duy ownership gate, acceptance, and validation checks. |
| specs/001-integrate-basement-stage/validation.md | Record static findings, proposed design, review boundary, and unverified checks. |
| docs/implementation-changelog.md | Record the initial request and ownership boundary before implementation. |

**Integration effects:** The planning entry itself changed no game source or shared system; implementation is recorded below. The user reports Duy approved the exact T067 scope on 2026-11-10; this is relayed approval, not direct reviewer sign-off. The earlier approval applied only to T053 bar styling. **Verification:** static source/task inspection; git diff --check passed with Git CRLF-normalization warnings for the Markdown records. **Limitations:** no runtime acceptance or direct reviewer sign-off is claimed.

#### T067 implementation — Dark Fairy intro and split finisher

Added a once-per-spawn introduction when the player first enters the Dark Fairy's detection range. The intro pauses gameplay, zooms only camera FOV, uses the existing Pixelfx impact-frame helper, shows the boss name, then reveals the existing BossHUD. On phase-2 defeat, gameplay pauses, the screen fades to black, one high-contrast diagonal slash appears, and two screen-space AtlasTexture halves are cut from the boss's current Sprite3D frame and move apart before the existing defeated cleanup runs. Both cut-ins restore the saved camera transform/FOV and prior pause state. Missing camera or an unusable split frame skips the cut-in and preserves the existing death-animation path.

| Included file | Purpose |
| --- | --- |
| scenes/enemies/darkfairy/darkfairy.gd | Gate first engagement, start/finish/abort boss presentations, and preserve exactly-once defeated cleanup. |
| scenes/enemies/darkfairy/darkfairy_cinematic.gd | Add paused intro/death presentation, FOV zoom, HUD reveal, Pixelfx impact frame, black screen, slash and split sprite halves. |
| specs/001-integrate-basement-stage/tasks.md | Record T067 ownership, user-relayed approval, scope, acceptance and checks. |
| specs/001-integrate-basement-stage/validation.md | Record implementation, static review, unrun runtime checks and limitations. |
| docs/implementation-changelog.md | Maintain this cumulative implementation and review record. |

**Integration effects:** No stage scenes, Player/skill code, boss attacks, AI choices, health/damage, phase thresholds, shared enemy systems or BossHUD style/layout changed. Boss action selection remains gated by the existing idle state. **Static verification:** source review and git diff --check passed; Git reports Markdown CRLF-normalization warnings. **NOT RUN:** Godot parse/import or runtime visuals, so framing, split alignment and fallback behavior are not verified. T067 remains open pending the user's visual check; Duy approval is user-reported, not direct reviewer sign-off.

#### T068–T070 request and review boundary — full-screen boss impact, camera framing, Lightning SFX

Recorded the user's request to make both Dark Fairy cut-ins affect the full screen, zoom/frame the boss as the subject, and give Lightning skills distinct SFX. The user reports Duy approved the boss-presentation scope extension (full-screen effects and temporary camera centering) on 2026-11-10. T068 and T070 remain Duy-owned; this is relayed approval, not direct reviewer sign-off. T069 is Bao-owned. The active tasks and validation files contain the per-task scope, acceptance criteria, checks and pending runtime limitations before implementation.

| Included file | Purpose |
| --- | --- |
| specs/001-integrate-basement-stage/tasks.md | Add T068 full-screen boss impact, T069 Lightning SFX differentiation and T070 camera focus task records and update task total. |
| specs/001-integrate-basement-stage/validation.md | Record approval provenance, ownership boundary, planned checks and unrun runtime/audio review. |
| docs/implementation-changelog.md | Keep the cumulative implementation/review record current. |

**Integration effects:** Planning only; no game source/assets changed in this entry. The subsequent implementation group and its verification are recorded below. **Verification:** checked existing T067 implementation, Audio routing and local clip names. **Limitations:** no direct reviewer sign-off; runtime camera/visual/audio checks are pending.

#### T068–T070 implementation — full-screen boss impacts, boss focus, distinct Lightning SFX

Expanded both Dark Fairy cut-ins with a viewport-wide tinted flash and matching dark/accent impact bands. The defeat slash now spans beyond the viewport diagonal. During each cut-in the active camera translates temporarily along its view-plane right/up axes to center the boss sprite while preserving its basis; intro zoom/reveal and defeat blackout/fade animate that position, then existing cleanup restores the exact saved global transform, FOV and pause state. Each Lightning skill and the Lightning hit reaction now selects a specific local impact sample and pitch/volume profile.

| Included file | Purpose |
| --- | --- |
| scenes/enemies/darkfairy/darkfairy_cinematic.gd | Add fullscreen impact flash/bands, viewport-spanning finisher slash, and temporary boss-centered camera translation with restoration. |
| scenes/player/battle_vfx.gd | Route every Lightning skill/hit to its own sound profile while leaving other elements unchanged. |
| specs/001-integrate-basement-stage/tasks.md | Record T068-T070 scope, ownership, reported approval, acceptance and task status. |
| specs/001-integrate-basement-stage/validation.md | Record implementation, static checks, camera ownership, pending camera/audio runtime review and limitations. |
| docs/implementation-changelog.md | Maintain the cumulative implementation/review record. |

Referenced, pre-existing audio (not modified): `assets/sfx/Free Fantasy SFX Pack By TomMusic/OGG Files/SFX/Spells/Spell Impact 1.ogg`, `Spell Impact 2.ogg` and `Spell Impact 3.ogg`. Asset search found no dedicated thunder/lightning/electric/spark/zap/shock/bolt audio filenames; generic impact variants are differentiated with pitch and level. **Integration effects:** only Dark Fairy cut-in presentation/camera and Player skill sound routing changed. CameraRig, stage scene, Player camera behavior, gameplay, boss AI/health/damage, BossHUD, non-Lightning audio, other VFX and existing slash/ice-shield implementations are unchanged. Pre-existing edits in `levels/level_1/stage_1.tscn` and `.godot/uid_cache.bin` were preserved. **Static verification:** reviewed all Lightning IDs and local path existence, pause/camera cleanup, screen anchors/layers and slash bounds; `git diff --check` passes with Markdown CRLF-normalization warnings. **NOT RUN:** Godot parse/import, required camera playtest, fullscreen visual review and in-game SFX listening. T068-T070 remain open pending user/runtime review; Duy approval is reported by the user, not direct reviewer sign-off.
#### 2026-11-11 — Enemy Skill Point drops and B1 clear chest

Normal enemies drop a 1 SP pickup on defeat. Dark Fairy drops a 5 SP pickup after the final defeat sequence. B1 has three zones with three required defeats per zone. The chest spawns after all nine enemies are defeated. Pressing F within range awards 1 SP once per save through the existing floor-clear reward. Pickups and the chest use the existing saved balance and HUD signal.

| Included file | Purpose |
| --- | --- |
| `scripts/enemy.gd` | Spawn one collectible per defeated enemy. |
| `scenes/enemies/darkfairy/darkfairy.gd`, `darkfairy.tscn` | Award the boss pickup from the final defeat sequence and disable the regular drop for the boss. |
| `levels/objects/skill_point/skill_point.gd` | Match the saved pickup ID format and require a living player to collect. |
| `levels/objects/enemy_zone/enemy_zone.gd` | Support a finite clear condition and set enemy spawn positions before initialization. |
| `levels/level_1/basement_full.tscn`, `basement_b1.tscn`, `basement_floor_visibility.gd` | Configure the B1 encounters, place the chest marker, and spawn the chest on clear. |
| `levels/objects/skill_point/floor_clear_chest.gd`, `floor_clear_chest.tscn` | Present the chest and collect the saved floor-clear reward using the existing F interaction. |
| `levels/objects/skill_point/floor_clear_chest.gd.uid` | Track the chest script's Godot resource ID. |
| `docs/implementation-changelog.md` | Record the change and validation status. |

**Validation.** Static checks confirmed the three configured zones, the floor cell under the chest in both B1 scenes, the chest resource paths and the existing HUD and save hooks. An initial .NET headless launch reached the basement and reported missing imported UI textures. The full kill, pickup, chest interaction, and save/reload playtest remains pending. Godot was not run again at the user's request. Dark Fairy can be checked in `stage_1.tscn` or `stage_2.tscn`. The integrated basement scene has only a B3 boss marker on this branch.
#### T071 request and review boundary — B2 respawn and clear-gated B3 access

The user reported that the standalone B2 scene does not respawn reliably, its enemies replenish indefinitely, and B2→B3 cannot be entered. The user clarified that clearing the B2 enemies is the agreed condition for opening B3. T071 records the cross-boundary owners (Lam/Quan map and checkpoint routing; Duy EnemyZone clear interface), uses the existing clear API, and keeps the previous B3-save recovery refusal. The reported agreement is not represented as direct reviewer sign-off. No source has changed in this planning entry; implementation and verification evidence follow below.

#### T071 implementation — B2 respawn and clear-gated B3 access

T071 source implementation is present. The task remains open while its runtime behavior awaits Godot playtesting.

| Included file | Purpose |
| --- | --- |
| `scripts/autoload/game_manager.gd` | Canonicalize new standalone B2 checkpoint touches and gate B3 stage loads on the persisted clear flag, while retaining old-B3 conflict refusal. |
| `levels/objects/checkpoint/checkpoint.gd` | Show the matching canonical integrated B2 checkpoint as current in standalone B2. |
| `levels/level_1/basement_b2.tscn` | Set the active wave to three defeats, attach B2 progress tracking, and gate the B2→B3 door. |
| `levels/level_1/basement_full.tscn` | Apply the same finite wave and clear-gated B2→B3 door in the integrated scene. |
| `levels/level_1/basement_b2_progress.gd` | Aggregate existing EnemyZone clear signals, persist `b2_cleared`, and stop B2 timers on later entry. |
| `levels/level_1/basement_b2_progress.gd.uid` | Preserve the Godot resource UID sidecar for the new bridge script. |
| `specs/001-integrate-basement-stage/tasks.md` | Track T071 implementation with runtime acceptance still open. |
| `specs/001-integrate-basement-stage/validation.md` | Record scope, ownership boundary, static review, and pending runtime checks. |
| `docs/implementation-changelog.md` | Preserve the cumulative implementation record. |

**Integration effects.** `GameManager` uses the existing saved flags for B2 clear state and B3 route gating. The current active B2 zone has a three-defeat limit matching its three-enemy capacity; the second zone has no enemy scene and is excluded. Checkpoint save serialization, legacy-save normalization, EnemyZone production logic, the door implementation, and old B3 checkpoint recovery were not changed. The B3 route is available only after B2 is cleared.

**Static verification.** Source review covered checkpoint canonicalization and respawn route, preservation of legacy-load behavior, both B2 scene door/zone definitions, finite kill threshold, empty-zone exclusion, all-configured-zone clear aggregation, and persistent flag handling. `git diff --check` passes; Git reports only CRLF-to-LF normalization warnings for Markdown records.

**NOT RUN.** Godot parse/import and runtime playtests for checkpoint/death, three defeats, locked/open states, B3 arrival, integrated-scene behavior, and reload persistence. T071 stays open until these checks are performed. The user-reported clear-to-open agreement is not direct reviewer sign-off.

#### T072 request and review boundary — Skill Tree scale and confirmation restoration

The user reported that the previously enlarged Skill Tree and its learn confirmation button had disappeared and asked to restore them. T072 restores the existing T057 110% default graph view, extends vertical spacing between weapon-tree levels, and requires selecting a node before a separate left-panel action can run its existing callback. Owner is Bao; scope is limited to `ui/skill_tree_layout.gd` and `ui/skill_tree_node.gd`. No progression rule or shared system change is authorized or planned. Acceptance and checks are recorded in `specs/001-integrate-basement-stage/tasks.md` and `validation.md` before implementation.

#### T073 request and review boundary — Player skill speed and gravity

The user asked for skill animations to be faster and gravity to increase slightly. T073 records a modest 1.2x playback factor for Player skill attack/throw clips and BattleVFX sprite animations, with the cast timer calculated from the accelerated clip and the prior AnimationPlayer speed restored afterward. Player's scene gravity will move from the inherited 24 to 26; shared BaseCharacter/enemy defaults and other movement values remain unchanged. Owner is Bao. Runtime movement verification is required and will remain pending unless requested.

#### T073 implementation — Player skill speed and gravity

Player skill attack/throw animations and BattleVFX sprite animations now run at 1.2x. The skill state duration follows the faster Player clip and restores the previous AnimationPlayer speed on exit/finish. Player gravity is 26, up from inherited 24.

| Included file | Purpose |
| --- | --- |
| `scenes/player/states/skillstate.gd` | Speed up skill attack/throw clips, match state duration, and restore the original AnimationPlayer speed. |
| `scenes/player/battle_vfx.gd` | Speed up the PixelFX/PVFX sprite animations spawned for skill and battle effects. |
| `scenes/player/player.tscn` | Set the Player-only gravity override to 26. |
| `specs/001-integrate-basement-stage/tasks.md` | Track T073 implementation and pending movement/playback review. |
| `specs/001-integrate-basement-stage/validation.md` | Record scope, static checks, and unrun Godot playtests. |
| `docs/implementation-changelog.md` | Maintain the cumulative implementation record. |

**Integration effects.** Player skill presentation and Player falling/jumping only. Skill point costs, cooldowns, damage, status timers, timer-based loop VFX lifetimes, enemy gravity and shared `BaseCharacter.gravity` are unchanged. The VFX multiplier applies to PixelFX/PVFX created by the BattleVFX spawn helpers, including loops; status overlays and dash dust use separate paths.

**Static verification.** Reviewed the state-speed lifecycle and cast-duration formula, both BattleVFX spawn paths, and the Player scene override. `git diff --check` passes; only existing Markdown CRLF-to-LF normalization warnings were emitted.

**NOT RUN.** Godot parse/import, skill animation playback, VFX timing, and jump/fall/stair/dash playtests. Since gravity affects movement, T073 remains open pending runtime verification; no reviewer sign-off is claimed.

#### T072 implementation — restore Skill Tree scale and confirmation

The tree now opens at the recorded 110% graph scale with more vertical spacing between levels. Selecting a node updates the description panel and reveals a labeled confirmation button; selecting alone never spends a point or changes the chosen form/ultimate. The existing node action runs only from the confirmation button.

| Included file | Purpose |
| --- | --- |
| `ui/skill_tree_layout.gd` | Restore tree scale/spacing, add selected-node details and the left-side action confirmation, and route existing actions through it. |
| `ui/skill_tree_node.gd` | Make node activation selection-only, retain hover details and draw the selected-node outline. |
| `specs/001-integrate-basement-stage/tasks.md` | Track T072 implementation and pending runtime review. |
| `specs/001-integrate-basement-stage/validation.md` | Record acceptance, static review and unrun visual/input checks. |
| `docs/implementation-changelog.md` | Maintain the cumulative change record. |

**Integration effects.** Skill Tree UI only. Form choice, learned skills, evolutions, character upgrades, ultimate selection, point costs and eligibility remain on their existing callbacks. The new button is the only caller of a selected node's callback. No game manager, combat, save or input mapping changes were made.

**Static verification.** Reviewed node signal connections, confirm-only callback invocation, unavailable-action disabling, hover/selection handoff, graph level coordinates and initial zoom. `git diff --check` passes; Git reports only existing Markdown CRLF-to-LF normalization warnings.

**NOT RUN.** Godot parse/import or visual/input playtests at supported resolutions. T072 remains open pending runtime layout and interaction review; no reviewer sign-off is claimed.

#### T074 request and review boundary — locked-door dialogue crash

The user reported a runtime error in `Conversation.play()` when a locked door starts `door_locked`: `Player` has no `is_talking` property, and the current Player/BaseCharacter scripts also do not implement the called talk methods. T074 is scoped to `scripts/conversation.gd` and `scenes/player/player.gd`, implementing the expected Player talk lifecycle and guarding optional partner calls. `InteractiveArea3D` already checks `Player.can_interact()` to let Dialogic input pass through, so T074 supplies that Player-facing contract without changing shared input or BaseCharacter. Runtime reproduction is pending; no reviewer sign-off is claimed.

#### T074 implementation — locked-door dialogue crash

The invalid `Player.is_talking`, `start_talk()`, and `finish_talk()` accesses are now backed by the Player's dialogue lifecycle. Active dialogue prevents duplicate starts, temporarily disables Player movement and action input, lets Dialogic receive the interact key, and restores the prior movement-enabled state when the timeline ends. Optional partner calls are guarded by `has_method()`.

| Included file | Purpose |
| --- | --- |
| `scenes/player/player.gd` | Implement the Player talk state, `can_interact()` contract, input/physics gating, and movement-state restoration. |
| `scripts/conversation.gd` | Guard invalid/duplicate timeline starts and safely call optional partner talk methods. |
| `specs/001-integrate-basement-stage/tasks.md` | Track T074 implementation with runtime acceptance still open. |
| `specs/001-integrate-basement-stage/validation.md` | Record static review, diff check, and unrun Godot reproduction. |
| `docs/implementation-changelog.md` | Maintain the cumulative implementation record. |

**Integration effects.** Player and Conversation only. `InteractiveArea3D` consumes the existing `Player.can_interact()` contract, so its code and shared input handling were not changed. Door, Dialogic, BaseCharacter, and scene resources were not changed. The user-reported error has not been runtime-reproduced after the fix; T074 remains open pending Godot verification.

**Static verification.** Reviewed current Conversation call sites, Player talk API, input pass-through, movement restoration, and optional partner guards. `git diff --check` passes; Git reports only Markdown line-ending normalization warnings.

**NOT RUN.** Godot parse/import and the locked-door dialogue start/advance/restore playtest. No reviewer sign-off is claimed.

#### T075 request and review boundary — integrated B2-to-B3 direct transition

The user requested that the B2 door in `basement_full` transition directly to B3 without the locked-door dialogue. Existing T071 makes the door and B3 loads require `b2_cleared`. Proposed scope assumes bypassing that clear flag only for the integrated `basement_full` B2 door, while preserving the standalone `basement_b2` gate and other direct B3 refusals. The change affects `levels/level_1/basement_full.tscn` and shared `scripts/autoload/game_manager.gd` route logic, owned by Lam / Quan in the task record. Their approval is pending; no source change has been made. Acceptance and planned checks are recorded in `specs/001-integrate-basement-stage/tasks.md` and `validation.md`. No reviewer agreement or runtime result is claimed.

#### T075 clarification and diagnosis — B2 clear gate remains required

The user clarified that the clear-to-open rule remains in force; the desired behavior is for the B2 door to unlock after all enemies are defeated. The earlier direct-transition interpretation is superseded and no route bypass is planned. Static source inspection found that `levels/objects/enemy_zone/enemy_zone.tscn` assigns `zone_crab.tscn` by default. The unconfigured `EnemyZone_B` instances in both B2 scenes inherited that enemy scene despite having no explicit override. The progress bridge therefore treated the zone as configured, rejected its `clear_kills = 0`, cleared its tracked-zone list, and left the zone spawning indefinitely. T075 now corrects those two scene overrides while preserving T071's gate.

#### T075 implementation — correct inherited B2 enemy zone

Both B2 scenes now explicitly leave the unused `EnemyZone_B` without an enemy scene. The active zone still requires three defeats, and the existing `b2_cleared` door and GameManager gates remain unchanged.

| Included file | Purpose |
| --- | --- |
| `levels/level_1/basement_b2.tscn` | Clear the inherited crab scene from the unused B2 zone in the standalone scene. |
| `levels/level_1/basement_full.tscn` | Clear the inherited crab scene from the unused B2 zone in the integrated scene. |
| `specs/001-integrate-basement-stage/tasks.md` | Track T075 implementation with runtime acceptance still open. |
| `specs/001-integrate-basement-stage/validation.md` | Record root-cause evidence, static review, and unrun gameplay checks. |
| `docs/implementation-changelog.md` | Maintain the cumulative implementation record. |

**Integration effects.** The shared EnemyZone packed scene still defaults to its crab scene for intentionally configured instances. Only `EnemyZone_B` in the two B2 scenes is disabled. The progress bridge now selects the active finite zone rather than aborting on the inherited zero-clear zone. The B2 clear requirement and every GameManager/Door route gate are preserved.

**Static verification.** Reviewed `enemy_zone.tscn`'s default, both B2 overrides, the bridge's zone filter, and unchanged door/route conditions. `git diff --check` passes; Git reports only Markdown line-ending normalization warnings.

**NOT RUN.** Godot parse/import and kill-to-clear, door unlock, and B3 arrival playtests. T075 remains open pending runtime verification; no reviewer sign-off is claimed.

#### T076 request and review boundary — fullscreen ultimate impact and Skill Tree readability

The user reported that Player ultimate cut-ins' impact frame did not cover the screen and that the Skill Tree remained too small. T076 is scoped to Bao-owned Player cinematic/UI presentation: use the existing PixelFX impact-frame atlas in viewport space, raise default graph zoom from 110% to 115%, and enlarge node circles/icons/labels. The shared `BattleVFX` helper, Duy's boss cinematic, progression callbacks and gameplay are outside scope. Runtime visual acceptance remains pending.

#### T076 implementation — fullscreen ultimate impact and Skill Tree readability

Player ultimate cinematics now play the existing 10-frame, 320×180 PixelFX impact animation in screen space. It scales uniformly to cover the viewport, updates on viewport resize, draws above the flash/bands while the title remains on its higher layer, and is removed when its animation or cinematic ends. The Skill Tree opens at 115% and draws larger node circles, icons and labels. Existing camera/cinematic timing, selection callbacks, progression and pan/zoom behavior are unchanged.

| Included file | Purpose |
| --- | --- |
| `scenes/player/ultimate_cinematic.gd` | Load existing PixelFX frame metadata, play a viewport-covering animation, handle resize, and clean up on finish/abort. |
| `ui/skill_tree_layout.gd` | Set initial graph zoom to 115%. |
| `ui/skill_tree_node.gd` | Enlarge node circles, icons and labels. |
| `specs/001-integrate-basement-stage/tasks.md` | Record T076 scope, acceptance, validation and open runtime status. |
| `specs/001-integrate-basement-stage/validation.md` | Record acceptance boundary, static review, diff check, and pending visual review. |
| `docs/implementation-changelog.md` | Maintain this cumulative implementation record. |

**Integration effects.** Player ultimate presentation and Skill Tree rendering only. The shared `BattleVFX` helper, boss presentation, camera behavior, combat values, skill purchase callbacks and progression rules are unchanged. Non-16:9 viewports are covered by cropping the excess edges to preserve the frame's aspect ratio.

**Verification.** Static review confirmed the existing atlas/manifest's 320×180 frames, 10-frame count and 30 FPS timing; the viewport cover-scale, resize connection, layer ordering and cleanup paths; and the changed Skill Tree dimensions against existing controls and node layout sizes. `git diff --check` passes; Git emitted existing Markdown CRLF-to-LF warnings.

**NOT RUN.** Godot parse/import or in-game visual review of all eight Player ultimate cut-ins and Skill Tree layout/readability at supported viewport sizes. Runtime presentation, aspect-ratio cropping, and node crowding remain unverified; T076 stays open, and no reviewer sign-off is claimed.

#### T077 request and review boundary — Lightning 2 beam/teleport and Lightning 3 chasing clone

The user proposed replacing Lightning 2 with a straight lightning shot that teleports behind a hit target, and Lightning 3 with a five-second lightning clone that attacks and explodes. The user selected the recorded baseline values and clarified that the clone chases the nearest enemy. T077 is scoped to Bao-owned Player skills and Skill Tree descriptions; it reuses existing Enemy freeze/hurt APIs and stage pathfinding without changing Duy-owned Enemy AI or shared navigation. Godot runtime validation remains pending.

#### T077 implementation — Lightning beam and timed chasing clone

Lightning 2 now strikes along a 1.6 m line, damages the first living target within its existing range/evolution values, and attempts a collision-safe landing behind that target. Lightning 3 spawns a tinted Player copy at the cast position, chases the nearest reachable enemy through the stage's existing path agent, attacks with current basic damage every 1.2 seconds for five seconds, and explodes once with the existing blast radius, damage scaling, and movement lock. Skill Tree descriptions now explain the new behavior. Existing IDs, cooldown table, unlock/cost/evolution data, other skills, and FX/SFX call sites remain unchanged.

| Included file | Purpose |
| --- | --- |
| `scenes/player/player.gd` | Replace Lightning 2's cone and Lightning 3's immediate strike with the beam/teleport and clone spawn; add line target selection and collision-safe teleport helpers. |
| `scenes/player/lightning_clone.gd` | Add the local clone sprite, nearest reachable target selection, PathAgent movement, basic attacks, five-second detonation, and lifecycle cleanup. |
| `ui/skill_tree_layout.gd` | Update the Lightning 2/3 descriptions while preserving skill IDs, tree data, and the existing T076 zoom change. |
| `specs/001-integrate-basement-stage/tasks.md` | Record T077 scope, acceptance, and open runtime status. |
| `specs/001-integrate-basement-stage/validation.md` | Record the pre-implementation boundary, static review, diff check, and pending Godot verification. |
| `docs/implementation-changelog.md` | Maintain this cumulative implementation record. |

**Integration effects.** Player skill logic and its Skill Tree text only. The implementation calls the existing `EnemyCharacter.apply_skill_freeze()` and Player damage helper and reads the current stage `GridPathfinder`; it does not alter shared Enemy, pathfinding, stage, or progression code. Lightning 2's teleport is skipped if none of its candidate positions is collision-safe. The clone is removed when it detonates, the Player dies, or its owning scene is removed.

**Static verification.** Reviewed Lightning 2 line projection/order and range/height/width filters, damage/rage/impact calls, and the overlap/floor checks for teleport. Reviewed Lightning 3 target reselection, existing path agent use, current Player attack damage, 1.2-second cadence, five-second lifetime, one-shot blast, and cleanup. Confirmed the two Skill Tree descriptions and unchanged cooldown/evolution/SFX call sites. `git diff --check` passes; Godot has not been run.

**NOT RUN.** Godot parse/import or in-game checks of the beam, blocked and successful teleport, clone chase/attack cadence, final blast, Player death, and stage exit. T077 remains open pending runtime verification; no reviewer sign-off is claimed.

#### T078 request and review boundary — antique spellbook Skill Tree

User authorizes blending the T-menu Skill Tree into its book with coherent classic styling and opening/closing animation. Scope is Bao-owned UI: common sprite-frame geometry, two page layout, ink/bronze node and link styling, chapter state, transition input gating and pause/HUD restoration. Preserve T072 confirmation, T076 115% default zoom/enlarged icons, T077 Lightning descriptions and unrelated dirty files. Acceptance and focused verification are recorded before implementation in tasks.md and validation.md. No reviewer sign-off is claimed.

#### T078 implementation — coherent antique spellbook UI

The T-menu now presents the Skill Tree as ink and bronze seals on two parchment pages. The left page holds chapters, points, description and confirmation; the right page holds the graph. The resting book and all animations share the full sprite frame, pivot, tint and scale calculation. Ink fades with the leaves, all moving frames fit the tested viewport, and rapid close/open requests finish the current motion before reversing. HUD/pause restoration waits until the cover closes.

| Included file | Purpose |
| --- | --- |
| `ui/skill_tree_layout.gd` | Common book rig, cached frame bounds, two-page layout, classic heading/buttons, chapter indicators, pinned selection/confirmation, responsive frame fitting, input shield, animation sequencing and prior pause/HUD restoration. Preserve existing callbacks, default 115% zoom and Lightning descriptions. |
| `ui/skill_tree_graph.gd` | Clip zoom/pan inside the right page, fit default-zoom node bounds and draw subdued curved ink connections. |
| `ui/skill_tree_node.gd` | Parchment/bronze seals, muted element inks, visible selection/focus, retained enlarged icons, larger readable labels and page-appropriate hitboxes. |
| `ui/skill_tree_folio.gd` | Draw noninteractive engraved paper corners and folio rules in the same book coordinates. |
| `ui/skill_tree_folio.gd.uid` | Stable Godot script resource identifier for the new folio decoration. |
| `specs/001-integrate-basement-stage/tasks.md` | T078 scope, acceptance, implemented/fixture-verified status and pending main-game/reviewer acceptance. |
| `specs/001-integrate-basement-stage/validation.md` | Baseline, integration boundary, rendered UI evidence, 103 assertion results, failed attempts and remaining limitations. |
| `docs/implementation-changelog.md` | This cumulative implementation record. |

**Integration effects.** Bao-owned Skill Tree UI only. Existing GameManager callbacks, point costs/eligibility, reset, heal-on-open and PlayerHUD visibility API are reused; their implementations and shared input mappings are unchanged. The menu now keeps the HUD hidden until the closing animation finishes and restores the pause state that existed before opening. Default zoom remains 115%; manual zoom clips to the paper. The previous 19% graph offset is superseded by the right-page coordinate system. Existing T072/T076/T077 work and unrelated dirty files/caches were preserved without cleanup.

**Verified.** Godot 4.7.2 UI-only scene with separate user data and stub gameplay/HUD: 103 assertions passed, final log free of script/runtime errors. Covered element choice, all four weapon forms, character page, select-before-confirm, unavailable actions, real T/Escape/mouse events, interrupted transitions, prior pause/removal cleanup, graph bounds and all 56 sprite-frame bounds. Rendered 1280×720, 1024×768, 1920×1080 and 2560×1080; visually inspected both chapters, long selected description and page-turn output. `git diff --check` passes with line-ending notices only.

**Known errors, limitations and unfinished work.** Initial folio type-inference errors and preview sizing/clipping issues were fixed and rechecked. Main-project direct `--script --check-only` could not resolve the GameManager singleton in that entry context; it is not recorded as a whole-project parse pass. Main-game scene/HUD/save integration and manual animation-feel acceptance remain NOT RUN; fixture callback assertions do not establish actual purchase persistence. System serif fonts use fallbacks and are not visually checked on other operating systems. T078 remains unchecked pending those reviews. No reviewer agreement, commit or push is claimed.

## 2026-11-12 — T079 free orbit camera and Player-relative controls

**Authorization/status.** User requests a Zelda/Genshin-style orbit camera and obstruction handling, explicitly selecting mouse-look with held Alt to release the cursor. Bao-owned camera/Player work is implemented; focused rendered physics checks pass. Main-scene integration and reviewer/feel acceptance are pending. No teammate sign-off, commit or push is claimed.

| Included file | Purpose |
| --- | --- |
| `scenes/camera/camera_rig.gd` | Orbit yaw/pitch, zoom, capture/Alt/Escape/focus/pause lifecycle, sphere obstruction sweep including initial-overlap rejection, immediate contraction/smooth recovery, safe vertical follow, teleport snap, close-range sprite fade. Preserve Stage and cinematic interfaces. |
| `scenes/camera/camera_rig.tscn` | Replace distant fixed pose with 60-degree lens and 0.05 near plane driven by the rig. |
| `scenes/player/player.gd` | Camera-relative movement/aim API, continuous world attack facing, view-relative billboard frames with animation phase retention, dialogue/death camera input gate. |
| `scenes/player/states/player_state.gd` | Route common walking/air movement through camera-relative input. |
| `scenes/player/states/dash.gd` | Resolve dash direction from the same camera-relative vector. |
| `scenes/player/states/carry.gd` | Keep carried throw direction aligned with world movement/facing. |
| `tests/camera_rig_check.gd` | Standalone rendered physics/input regression fixture, run in a minimal disposable project. |
| `tests/camera_gameplay_check.gd` | Guarded disposable-copy integration playtest using actual basement, Player and Skill Tree. |
| `tests/camera_gameplay_check.tscn` | Explicit scene entry point for the integration playtest. |
| `specs/001-integrate-basement-stage/tasks.md` | Record T079 owner, scope, acceptance and verification state. |
| `specs/001-integrate-basement-stage/validation.md` | Cumulative request, baseline, boundaries and runtime evidence. |
| `docs/implementation-changelog.md` | This cumulative implementation record. |

**Integration effects.** All scenes instancing CameraRig receive the new camera. Stage target/snap_to_target and direct Camera3D child stay compatible. Existing cutscenes own the camera while paused; cursor cleanup still runs. World collision layer 1 blocks the camera, Player/enemy/hurt/trigger layers do not. Player movement speed, damage, cooldowns, skill rules, input mappings, map geometry, BaseCharacter and enemy systems are unchanged. Original dirty Dark Fairy scene is preserved.

**Verified so far.** Godot 4.7.2 / OpenGL Compatibility on AMD Radeon 760M: 100 rendered fixture assertions pass, including 72 orbit samples around real finite wall colliders, thin-wall contraction, recovery, floor/ceiling clearance, overlap fail-closed, target exclusion, teleport, vertical lag, sprite fade/restore, paused camera ownership, mouse pitch clamps and cursor cleanup. Tests use disposable project `ArcanaCamera-T079-20261112` under the OS temp directory; no production autoload/save runs there.

**Known errors/limitations/open work.** First fixture had two type-inference errors, corrected. A finite-wall test incorrectly assumed an infinite wall, corrected to physical overlap checks. Headless run cannot provide OS mouse capture and fails three mouse-motion assertions; renderer run passes those. Full-copy first import reported GameManager autoload type resolution errors before resource scan completed; integration execution remains pending. Geometry missing world-layer collision cannot block the camera. If the target focus itself overlaps solid geometry, the boom collapses; no valid exterior view is invented. Manual gameplay feel, all-map coverage, real combat/carry/cutscene/respawn acceptance remain pending.

### T079 final verification and presentation follow-up

- Added camera-local alpha handling for the existing checkpoint AnimatedSprite3D in the spawn_points group: non-solid markers fade only near the lens, preserving interaction and RGB tint, then restore alpha/cut mode. Player and back-mounted sword use the same Compatibility-supported sprite alpha technique. No checkpoint/map source changed. Initial GeometryInstance transparency did not visibly work on Compatibility; actual images exposed this and the final implementation replaces it.
- Additional included files: `tests/camera_rig_check.gd.uid` and `tests/camera_gameplay_check.gd.uid`, generated by Godot for stable identities of the new test scripts.
- Final evidence supersedes the pending checks above: 104/104 rendered isolated camera assertions pass; 20/20 production basement/Player/HUD/Skill Tree integration assertions pass. Inspected start/side/rear views and fixed foreground sword/helm occlusion; real W/dash/aim/Alt/T/Escape behavior is exercised through Godot input/FSM. Preserve attack animation phase when camera crosses sprite quadrants. `git diff --check` passes.
- Test-only corrections: explicit Player bool type; fixture Transform3D types, finite-wall clearance assertions and waiting for dash state entry. Test isolation, logs, screenshots and reproduction notes are in validation.md. Only the disposable copy receives import/cache and separate APPDATA/user-data configuration; original caches/save/config are untouched by the test commands.
- Remaining diagnostics: asset UID fallback warnings and full-copy shutdown warnings/error about 5 ObjectDB objects / 1 retained resource. No SCRIPT ERROR in final integration run; attribution of shutdown diagnostics is unresolved. Interactive Computer Use approval timed out, so manual input feel is not claimed. All-map/carry/combat/respawn/actual cutscene acceptance and independent reviewer agreement remain open. Existing Dark Fairy scene work is preserved; no commit or push.
- Final direct basement smoke also exited; its shutdown diagnostic is 6 retained ObjectDB instances / 1 resource (versus 5 / 1 in the fixture). No test process remains running. These unresolved exit diagnostics do not change the separately recorded 104 camera and 20 gameplay assertion results.

### T080/T081 camera input and existing VFX follow-up — 2026-11-13

- Tasks: T080 and T081 implemented with bounded rendered checks; both remain unchecked pending native embedded mouse/manual VFX feel and Bao reviewer agreement. Do not interpret automated fixture pass as sign-off.
- Included files and purposes: `scenes/camera/camera_rig.gd` synchronizes actual Game-window focus, recaptures externally released cursor and reads captured motion before HUD; `scenes/player/battle_vfx.gd` routes existing PixelFX/PVFX overlays through live world projection; `scenes/player/world_vfx_anchor.gd` is the new camera-aware screen anchor; `tests/camera_rig_check.gd` adds focus/capture regression; `tests/camera_gameplay_check.gd` exercises actual basement HUD motion plus both old VFX asset pipelines; `tests/world_vfx_anchor_check.gd` verifies orbit/zoom/behind-camera projection; `specs/001-integrate-basement-stage/tasks.md` records T080/T081 scope/criteria/status; `specs/001-integrate-basement-stage/validation.md` records diagnosis, verification and limitations; `docs/implementation-changelog.md` is this cumulative record.
- Shared integration: CameraRig still preserves Stage target/Camera3D/snap contract and paused cinematic ownership. New anchor affects Player BattleVFX PixelFX/PVFX overlays while active; world hit/cast points, timing, art exports and damage remain. Existing slash assets and shield/cast ring are untouched, as are map/AI/save systems. Original Dark Fairy diff and editor-modified tracked `.godot/uid_cache.bin` are preserved.
- Verification: Godot 4.7.2 Compatibility rendered isolated fixture 106/106 camera assertions and 6/6 VFX projection assertions; actual basement/Player/HUD/Skill Tree integration 23/23 in disposable copy and isolated user data. No parse/SCRIPT ERROR in final logs; `git diff --check` passes. Early diagnostic established `focus=false` while embedded Window focus=true; early VFX assertions were corrected for center-point geometry and observed projection lag. Final native mouse drag after all edits has not been conclusively observed, so that reported behavior and Bao visual feel are pending. Existing full-copy UID fallback and shutdown retained-object/resource diagnostics remain known, unresolved.
- Late preservation note: user/editor concurrently changed `project.godot` input bindings and left `levels/level_1/basement_full.tscn~RF481dac7.TMP` while a Game view was running. These are not T080/T081 implementation files and were preserved without cleanup or sign-off. Isolated integration checks used the earlier project copy, so they do not cover the new input-map changes.

## 2026-11-13 — T082 aimed skill release, reticle, ult blade and slash height

**Task/review status.** User requests quick cast plus a held 0.3 s camera-center aim, the sword behind the Player during ult, and slightly higher slash visuals. Bao-owned Player combat scope is implemented and verified in a rendered isolated basement fixture; native embedded control feel, full cut-in/element visual acceptance and Bao review remain pending. No teammate sign-off, commit or push is claimed.

| Included file | Purpose |
| --- | --- |
| `scenes/player/player.gd` | Hold/release skill input, camera-center physics aim and cancellation, directed skill/projectile aim APIs, temporary camera-relative ult sword position and Player-local slash spawn-height adjustments. Preserve prior T079/T081 work. |
| `scenes/player/skill_aim_reticle.gd` | Draw the noninteractive centered crosshair while holding the skill button and request aim cancellation during pause. |
| `scenes/player/skill_aim_reticle.gd.uid` | Stable Godot script UID for the new reticle. |
| `scenes/player/states/skillstate.gd` | Consume aimed point at deferred FSM entry, aim the thrown projectile in 3D from its spawn point, raise associated slash visuals. |
| `scenes/player/states/attack.gd` | Raise the existing basic attack slash spawn by 0.2 m. |
| `scenes/player/weapon/floating_blade.gd` | Apply and clear a temporary blade position without losing its original bob/sway rest pose. |
| `tests/camera_gameplay_check.gd` | Add actual-basement quick cast, held aim, collision ray, projectile direction, dialogue/pause cancellation and blade pose/restore assertions plus reticle/blade captures. |
| `specs/001-integrate-basement-stage/tasks.md` | Record T082 ownership, scope, acceptance and open review status. |
| `specs/001-integrate-basement-stage/validation.md` | Record pre-implementation boundary, checks, observed results and remaining limits. |
| `docs/implementation-changelog.md` | Maintain this cumulative file-level and integration record. |

**Shared/integration effects.** A quick skill now casts on key release so a hold can be distinguished; the HUD/input map, skill IDs, cooldowns, damage, hitboxes and save data are unchanged. Held aim follows the active Camera3D and stops at a solid collider; directional ground skills use a flat bearing and the thrown dagger uses full 3D bearing. The reticle ignores mouse input and disappears on release, dialogue, menu pause or other cancellation. The blade is moved only for ult presentation, then returns to its floating rest position. Existing slash scenes/sheets and ice shield/cast ring implementations remain untouched. Concurrent `project.godot`, Dark Fairy, tracked cache and editor temp changes were preserved.

**Verification.** Godot 4.7.2 Compatibility in disposable full-basement copy with isolated APPDATA/user data: changed scripts import without SCRIPT ERROR; rendered integration fixture passes 36/36 assertions. Rendered reticle and visible ult sword screenshots were inspected; the reticle sits at viewport center and the tested sword pose leaves the Player face unobscured. An initial 31-check run exposed an aim snapshot lost before deferred FSM entry; a later pause check exposed a reticle left visible by the paused Player. Both were corrected and the final 36/36 run passes. `git diff --check` passes with existing line-ending notices.

**Known errors, limitations and unfinished work.** Original embedded Game mouse/E-key feel, full ult cut-in motion, all elemental directional skills, slash height across camera angles and reviewer acceptance remain NOT RUN. The fixture uses U from its earlier copied input map; the user's concurrent `project.godot` also binds E but was not overwritten in the fixture. Disposable-copy UID fallback warnings and shutdown diagnostics (5 retained ObjectDB instances, 1 resource) remain unresolved. T082 stays unchecked pending these reviews; no acceptance is invented.

## 2026-11-13 — T083 shoulder framing and smaller aim reticle

**Task/review status.** User requests a smaller crosshair and over-the-shoulder framing while aiming, using the supplied image as a visual reference. Bao-owned camera/Player presentation is implemented and verified in rendered isolated fixtures. Original embedded Game feel, broader map composition and Bao visual acceptance remain pending; no teammate sign-off, commit or push is claimed.

| Included file | Purpose |
| --- | --- |
| `scenes/camera/camera_rig.gd` | Interpolate closer, right-shoulder framing only during held aim; scale lateral offset at close zoom; sphere-sweep the full camera motion; return to normal orbit without changing saved zoom or Stage APIs. |
| `scenes/player/player.gd` | Activate/reset shoulder camera with aim lifecycle, face the viewed point while aiming and refresh the center ray before release cast. Preserve prior camera, ult, slash and skill changes. |
| `scenes/player/skill_aim_reticle.gd` | Reduce centered reticle dimensions while preserving mouse-ignore and pause cancellation. |
| `tests/camera_rig_check.gd` | Cover aimed lateral shift, multiple yaw views, minimum zoom, wall clearance and framing restoration in the rendered minimal fixture. |
| `tests/camera_gameplay_check.gd` | Cover quick tap remaining in normal view, actual Player-left framing, aimed center ray/projectile and return after release in the isolated basement. |
| `specs/001-integrate-basement-stage/tasks.md` | Record T083 boundary, acceptance, checks and open review status. |
| `specs/001-integrate-basement-stage/validation.md` | Record pre-implementation scope, rendered evidence, corrections and limitations. |
| `docs/implementation-changelog.md` | Maintain this cumulative implementation record. |

**Shared/integration effects.** CameraRig's target, Camera3D child and `snap_to_target()` interface remain intact. Existing normal orbit, collision, wheel zoom and mouse-look behavior are reused; shoulder mode is requested by the Player only after the 0.3 s aim threshold and cleared by the existing release/cancel paths. The center-ray and projectile direction use the actual shifted camera, and Player world movement is unchanged. No map, enemy, save, input-map, slash/ice-shield asset or skill damage/range changes are included. Concurrent editor/input-map, Dark Fairy, tracked cache and temporary scene changes were preserved.

**Verification.** Godot 4.7.2 Compatibility rendered minimal camera fixture passes 115/115 assertions; isolated full-basement/Player fixture passes 40/40. The tests cover near/side wall behavior, several yaw angles, close zoom, Player-left screen projection, quick taps, aim/release and projectile sightline. Inspected final aim screenshot: reduced reticle centered with the Player left of its sightline. Final logs have no SCRIPT ERROR and `git diff --check` passes with pre-existing line-ending notices. Initial fixture type inference error and overstrict mid-transition threshold were corrected before final runs.

**Known errors, limitations and unfinished work.** Native embedded Game mouse/E-key feel, wider stage viewpoints, every aspect ratio and Bao reviewer acceptance remain NOT RUN. Isolated full-copy UID fallback warnings and shutdown retained-object/resource diagnostics persist. T083 remains unchecked; fixture success is not reviewer agreement.
## 2026-11-13 — T084 menu cursor and hidden camera aim

**Request/status.** User requests a visible Skill Tree cursor and all directional skills to follow an implicit mouse-look target rather than actor facing. Bao-owned implementation is complete; rendered fixtures pass, while native embedded feel, per-skill combat and Bao acceptance remain open. T084 stays unchecked; no reviewer sign-off, commit or push.

| Included file | Purpose |
| --- | --- |
| `ui/skill_tree_layout.gd` | Explicitly show cursor throughout opening/open/closing; preserve and restore prior mouse mode with menu pause ownership and cleanup. |
| `scenes/camera/camera_rig.gd` | Force visible cursor during pause and avoid storing CAPTURED as the pre-capture restore mode. Preserve normal orbit/collision interfaces. |
| `scenes/player/player.gd` | Snapshot center aim for quick and held releases; use camera-center bearing for all common directional skill/ult calls and full 3D projectile targeting instead of movement/facing. |
| `tests/camera_gameplay_check.gd` | Require exact VISIBLE menu cursor from hidden state; verify implicit direction and quick shot against opposite facing/lateral input, retaining held/camera/menu regressions. |
| `specs/001-integrate-basement-stage/tasks.md` | T084 pre-implementation scope/acceptance and final verification/open review state. |
| `specs/001-integrate-basement-stage/validation.md` | Diagnosis, implementation, rendered evidence and outstanding checks. |
| `docs/implementation-changelog.md` | This cumulative implementation record. |

**Integration.** Menu and CameraRig share cursor/pause lifecycle; gameplay capture resumes after menu close. All directed active skills and directional ult effects use the Player's shared center-ray aim API. Ground skills retain horizontal mechanics, projectiles retain their 3D path, and holding still shows the reticle/shoulder view after 0.3 s. Skill balance, self-centered area effects, input mappings, map/AI/save and existing slash/shield assets remain outside this change. Concurrent editor/input-map, Dark Fairy, cache and temporary scene work is preserved.

**Verified/limits.** Godot 4.7.2 Compatibility rendered camera fixture passes 115/115 and isolated full-basement integration passes 42/42. Exact visible cursor, opposing actor/camera directions with lateral input, quick projectile center target and existing held/pause/menu/collision checks pass. Final runs have no SCRIPT ERROR; `git diff --check` passes. Native original embedded Game cursor/feel, each elemental combat and ult case and reviewer acceptance remain NOT RUN. Existing disposable-copy UID fallback and shutdown retained-object/resource diagnostics persist. Windows-mapped source files required in-place writes instead of truncation; final content verified and temporary file removed.
## 2026-11-13 — T090 Hearthmark inventory and item set

**Request/status.** User installed Hearthmark RPG UI + Icon Pack v1.1 under `assets/items` and asks to replace the old sample items and make the inventory resemble Stardew Valley. Implemented the item/catalog and UI slice; rendered checks pass. Native visual acceptance remains pending, and no reviewer sign-off or commit/push is claimed.

| Included file | Purpose |
| --- | --- |
| `scripts/items/item_catalog.gd` | Replaced seven initial samples with twelve new items and Hearthmark icon metadata. |
| `scripts/items/item_inventory.gd` | Writes inventory schema v2 and migrates version-1 item IDs while retaining counts, equipped slots and selected quick item. |
| `ui/inventory_panel.gd` | Added parchment/wood tabs, equipment cards, quick slot, eight-column icon/count grid, filters, details and actions. |
| `ui/pause_menu.gd` | Gives the inventory page a wood-tone shell and paper backing; preserves B/ESC pause ownership and focus. |
| `assets/items/rpg-ui-pack-v1.1/rpg-ui-pack-v1.1/` | Preserves the installed CC0 pack, original LICENSE/README, icon/UI PNGs and Godot import sidecars. |
| `docs/inventory-equipment.md` | Documents the new sample IDs/effects, asset license, UI and legacy save migration. |
| `tests/inventory_combat_test.gd` | Covers new catalog/effects, old-ID migration, icon/grid UI, B/Q and save behavior. |
| `docs/validation/inventory-combat/hearthmark-*.log` and inventory screenshots | Records rendered, small-window and fresh-process checks using disposable fixture save/settings files. |
| `specs/001-integrate-basement-stage/tasks.md` | Records T090 scope, acceptance and current implementation status. |
| `specs/001-integrate-basement-stage/validation.md` | Records pre-implementation boundary, implementation, checks, diagnostics and open acceptance. |
| `docs/implementation-changelog.md` | This cumulative implementation record. |

**Integration.** Active inventory IDs now reference the new icon catalog; old v1 IDs are only accepted by the migration map and are not offered as current items. Existing grant/equip/use APIs, Player effect calculations, B/Q inputs and GameManager save ownership remain in place. Existing saves retain known items and depletion state after migration. The installed upstream pack and its CC0 license are preserved. No map, loot, crafting, enemy, shop or world-pickup systems changed.

**Verification.** Godot 4.7.2 Compatibility rendered fixture passes 53/53 at 1280x720 and 53/53 at 960x540; fresh-process save restore passes 4/4. The fixture checks actual Player stats/consumption, migration from old equipment/consumables including a zero-count quick item, v2 round-trip, icon loading, eight-column grid, category filters, UI equip and B open/close. Inspected large/small screenshots. Final fixture logs contain no SCRIPT ERROR. `git diff --check` reports existing CRLF notices with no whitespace errors. Godot still reports one retained resource on fixture shutdown.

**Limitations.** Native game feel, per-item balance and Bao's visual acceptance remain NOT RUN. Map pickup/loot and crafting integration remain future work. No player `user://` save/settings were edited; only disposable fixture files under `docs/validation/inventory-combat/` were written. Existing dirty tracked caches and unrelated concurrent T088/T089 changes are preserved.
## 2026-11-13 — T091 G camera lock-on

**Request/status.** User asks for G to lock the camera onto the nearest enemy, prioritize a boss, and press G again to unlock. Implemented Bao-owned Player/camera/input behavior. Rendered fixture passes; native embedded camera feel remains open. No Duy AI edits, reviewer sign-off, commit or push.

| Included file | Purpose |
| --- | --- |
| `project.godot` | Declares physical G as the default `lock_on` input action. |
| `scripts/autoload/game_settings.gd` | Adds lock-on to remappable controls and legacy binding conflict migration. |
| `scenes/player/player.gd` | Routes one G press to the active CameraRig while gameplay camera control is allowed. |
| `scenes/camera/camera_rig.gd` | Selects live targets with nearest-boss priority, smooths orbit toward them, points the camera at target and clears invalid locks. |
| `tests/inventory_combat_test.gd` | Adds rendered tests for G routing, priority, centering, toggle and target cleanup. |
| `specs/001-integrate-basement-stage/tasks.md` | Records T091 scope, acceptance and status. |
| `specs/001-integrate-basement-stage/validation.md` | Records pre-implementation ownership/boundary and rendered results/limits. |
| `docs/validation/inventory-combat/lock-on-rendered.log` and `lock-on-errors.log` | Stores final rendered fixture evidence and runtime diagnostics. |
| `docs/implementation-changelog.md` | This cumulative implementation record. |

**Integration.** Ordinary enemies already join `enemies` in `scripts/enemy.gd`; current Dark Fairy boss inherits that behavior and has a `BossHUD`. The selector supports both the existing HUD marker and an explicit `boss` group, avoiding edits to Duy-owned AI. New lock-on action appears in settings/help and can be rebound. Free mouse orbit resumes after unlock. Aim reticle and skill targeting use the active camera basis as before. Saves and combat stats are unchanged.

**Verification.** Godot 4.7.2 Compatibility rendered fixture passes 63/63. Checks cover G default, Player input dispatch, a closer regular enemy against two bosses, nearest-boss selection, actual camera center direction after smooth turning, second-press unlock, dead and removed target behavior, and the existing suite. Final log has no SCRIPT ERROR; existing shutdown diagnostics report three ObjectDB instances and one retained resource. `git diff --check` reports only existing CRLF notices.

**Limitations.** Native embedded cursor/mouse feel, every full-stage enemy type and Bao acceptance remain NOT RUN. The existing boss convention is `BossHUD`; new boss scenes should join `boss` or expose that marker. No enemy AI, map, save or teammate-owned implementation changed.

## 2026-11-13 — T092 basic attack combo trial

**Request/status.** User asked to try a normal attack combo with existing assets, then rejected the result and asked to remove it. T092 is cancelled and its Player combat source changes have been reverted. No commit, push, reviewer acceptance or teammate sign-off is claimed.

| Included file | Purpose |
| --- | --- |
| `scenes/player/states/attack.gd` | Queues up to three presses, replays existing directional attack animation and elemental slash, gives each hit a separate active window, and adds one damage to the last hit. |
| `specs/001-integrate-basement-stage/tasks.md` | Records T092 owner, scope, acceptance, checks and pending status. |
| `specs/001-integrate-basement-stage/validation.md` | Records static findings, preservation boundary and verification limitations. |
| `docs/implementation-changelog.md` | Adds this cumulative implementation record. |

**Integration.** Uses the existing Player FSM, hit area, animation and slash scene. Enemy AI, shared hit-area code, skill rules, slash/ice-shield implementation, map and concurrent dirty files were not modified. Each attack stage disables its hit shape outside the active interval; interruption clears the queue.

**Verification and limits.** Inspected source and existing 0.4-second attack animations; confirmed Godot is not on PATH. No Godot parse, in-engine collision/input test or native playtest was run. Hit registration against overlapping enemies, timing under low frame rate and visual feel require runtime verification. No errors observed from a game run because no game run occurred.

**Reversal.** `scenes/player/states/attack.gd` was restored to the original single attack, original full-state hitbox and original slash size/position. `specs/001-integrate-basement-stage/tasks.md` marks T092 cancelled; `specs/001-integrate-basement-stage/validation.md` records the user rejection and missing runtime evidence; this changelog retains the trial history and reversal. No shared systems or other owners' files changed during reversal. Source/diff inspection is the only check; Godot was not run, and no T092 work remains unfinished.
