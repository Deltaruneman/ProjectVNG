# EXP progression — 2026-11-17

Owner: Bao (Player/skills/HUD). User requests progression plus required shared manager/pickup changes. Review boundary: GameManager progression/save fields, existing pickup adapter, Skill Tree/HUD. Preserve Duy enemy AI/drop API, Lam/Quan maps/chests, SaveSystem serializer and tracked caches. No teammate sign-off claimed.
Baseline: modified .godot/uid_cache.bin and untracked export_presets.cfg preserved. Active basement tasks/validation read; unrelated pending work stays open.

Approved design: 20 EXP per old pickup point, 100 EXP at level 1, +50 required EXP each later level, exactly 3 SP per level. Start level 1/EXP 0; carry overflow through multiple levels. Unique IDs remain deduplicated. Old saves retain allocations/unlocks/SP and previous 1 SP purchase prices for exact refunds. Persist level, EXP and actual spending ledger. Existing reward entry points award EXP.
Costs: form 1; active slots 1/2/3/4; ultimates 4/5; evolutions 2/3/4 (lightning 2/3); character ranks cost base + current rank, max 5 (basic base 1, specialist base 2, double jump base 3). Retain current earned-SP gates/prerequisites. Backend and UI use the same quote.

Tasks and acceptance/checks recorded before implementation:
- [x] EXP/save: thresholds, overflow, +3 SP, source deduplication, stage persistence, reset, old/new save round trips; synthetic saves only.
- [x] Pickup: cyan EXP automatically homes to live Player, accelerates from distance, awards once on arrival; dead/absent Player awards nothing; preserve scene/export/class/drop contracts.
- [x] Skill Tree: visible accurate costs, higher costs for advanced skills/ranks, reject invalid/poor/maxed purchases, exact refund including legacy purchases.
- [x] HUD: viewport-width bottom EXP strip, level/EXP text, level-up +3 SP notice, red book badge iff SP > 0; narrow/wide resize and menu lifecycle.
- [x] Runtime: isolated Godot fixture and rendered screenshots. Record executed results; manual balance/feel and independent review remain distinct.

Implementation and focused runtime validation completed below; broader integration limits and review remain explicit. No commit/push requested.

Integration follow-up: update only the existing B3 fixture reward expectation from +3 direct SP to +60 EXP, preserving 7 legacy SP; verify EXP survives checkpoint/door/death recovery. Existing traversal and owner-system code unchanged.

## Implemented and verified — 2026-11-17

All scoped implementation tasks are implemented. Godot 4.7.2 Compatibility, disposable copy at C:/Users/BaoHo/AppData/Local/Temp/ArcanaEXP-20261117; custom user data C:/Users/BaoHo/AppData/Roaming/ArcanaEXP-20261117 configured before autoload startup. Synthetic exp-fixture.json, exp-stage-fixture.json and t087-flow.json only; original saves/caches untouched.

- PASSED: headless-final and rendered each 48/48 assertions. Exact/overflow levels, +3 SP per level, unique-source rejection, legacy/new/mixed purchase save/refund, real crab drop adapter, automatic homing/arrival/exact-once, dead-player rejection, variable-price backend and displayed advanced skill price, red badge on/off, bottom EXP width at 480x270/800x270/360x360, T/Escape lifecycle and memory reset.
- PASSED: actual-stage flow 20/20. Actual B2 and B3 scenes load; explicit GameManager scene transitions, B3 checkpoint activation, actual Player.die() -> B3 respawn, B3 return to B2 and save reload retain level 3 / 45 EXP / 6 SP, collected IDs and nested sentinel. Enemies/timers disabled only in fixture to isolate persistence. These checks do not prove walking routes or boss fights.
- Visual review: inspected exp-level-up.png, exp-wide-hud.png, exp-character-costs.png and exp-weapon-costs.png. Full-width cyan strip/level/EXP, +3 SP notice and red number on book are visible; book shows variable skill/character upgrade costs. Square and spent-SP screenshots retained.
- FAILED / separate integration limit: updated existing basement_b3_check reward expectation; actual three B2 defeats, 60 EXP, unchanged 7 legacy SP, collected IDs, flags and nested payload pass. Broader walk fixture cannot reach the B2 door, then B3 transition times out and downstream missing-B3-node errors occur. No before-change run establishes whether this is pre-existing or a regression. Walking/map changes were not attempted. Preserve b3-integration logs; do not claim full B3 suite acceptance.
- Initial fixture/setup issues: first copy omitted runtime vendor dependencies; copied required vendor assets and reimported. First fixture used a bare enemy without sprite, a below-milestone skill purchase, insufficient animation time, and an Escape event lacking logical keycode. Fixed fixture conditions using real crab, valid purchases, physics-frame waits and both keycode fields. One added fixture variable needed an explicit Array type. Final focused logs have no SCRIPT ERROR. Initial import/headless logs are retained as unsuccessful history, not passing evidence.
- Known retained diagnostics: BattleFX vendor UID fallbacks and shutdown retained ObjectDB/resource warnings (4 objects / 1 resource in focused fixture; 6 / 1 in stage fixture). Initial import also reports missing old KayKit resource references and editor/plugin diagnostics; not repaired or claimed clean-project import. Final fixture checks pass despite exit resource diagnostics.
- NOT RUN: native gameplay feel, full campaign EXP pacing/balance, all skills/boss combat and independent Bao/Quan/Duy review. No teammate agreement or acceptance invented. No generator, branch change, commit or push.

Commands (from isolated copy): Godot --headless --scene res://tests/exp_progression_check.tscn; same with Compatibility renderer and --resolution 1280x720 --max-fps 60; headless same scene -- --stage-flow. Fixture refuses non-ArcanaEXP user directories. For existing B3 suite also set ARCANA_EXPECTED_USERDATA and -- --isolated-copy.
