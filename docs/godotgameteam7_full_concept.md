# Project Full Concept Master Document: Tower of Arcana (Game UITXVNG)

**Team 7 (University of Information Technology - VNU-HCM)**  
**Collaboration:** UIT x VNG (SE116 Coursework)  
**Project Lead:** Chung Kiết Lâm (MSSV: 22520735)  

---

## 1. Project Overview & Core Vision

* **Title:** *Tower of Arcana: Day & Night*
* **Genre:** 2.5D Action Arena / Metroidvania Tower-Climber
* **Target Platforms:** PC (Final upload on itch.io) & Mobile
* **Core Premise:** Players ascend a 10-story tower featuring elevation variance (High/Low Ground). Starting as a base character equipped with a starter Dagger, players combine real-time mechanical skills (Dash, Parry, Plunging Attack) with tactical builds centered around two core pillars: a **Shared Skill Tree** and a **Potion Crafting System**.

```text
[Start Run (Starter Dagger)] ──> [Ascend 10 Floors + Secret Floor 1.5]
              │                                      │
              ▼                                      ▼
[Potion Crafting (Garden Safezone)] <──> [Shared Skill Tree (Weapon Forms & Traits)]
```

---

## 2. Core Mechanics

### Core Pillar 1: Shared Skill Tree & Free Resets
* **Shared Skill Points Pool:** Skill points are acquired from clearing floors, defeating Mini-Bosses, and discovering hidden chests. Points are distributed freely between **Character Traits** (Attack / Defense / Mobility) and **Weapon Skills**.
* **3-Branch Weapon Evolution:** Allocating skill points into weapons transforms the basic Dagger into three distinct elemental forms:
  1. **Wind Form (Trảm Phong):** Focuses on attack speed, wide area sweeps, high mobility, and knock-up control.
  2. **Fire Form (Hỏa Bộc):** High burst damage, Damage-over-Time (DoT) burn, sacrificing HP for raw offensive power.
  3. **Ice Form (Băng Sương):** Hard crowd control (Freeze/Slow) and damage-absorbing shields.
* **Unlimited Free Resets:** Players can reset allocated skills at any point with **zero resource cost**, encouraging active build adaptation against different floor bosses and environmental hazards.

### Core Pillar 2: Potion Crafting System
* **Ingredient Gathering:** Ingredients are collected across lower floors and harvested from defeated monster drops.
* **Crafting & Consumables:** Players cultivate ingredients in the Floor 4 Safezone (Garden) and combine them according to learned recipes to craft temporary buff items (Speed, Jump, Power, Health, Ice resistance) to tackle higher floors.

### World Cycle & Mechanical Layers
* **Day & Night Loop:** A dynamic cycle that alters enemy behavior, aggressiveness, and drop rates between daytime and nighttime phases.
* **Metroidvania Traversal:** High/Low ground movement mechanics utilizing elevators, ziczac ladders, breakable obstacles, and secret shortcuts.

---

## 3. Tower Progression & Map Layout

The game features a 10-story structure paired with hidden rooms and safezones:

* **Floors 1–3 (Basement Zone):** Initial scaling and minion encounters (Crab, Starfish, Mushroom, Witch, Knight).
* **Floor 1.5 (Hidden Room):** Optional exploration floor unlocked via map puzzles for extra skill points and secret loot.
* **Floor 3:** Fixed Mini-Boss encounter (e.g., King Crab).
* **Floor 4 (Garden Safezone):** Safe haven dedicated to potion cultivation, recipe crafting, and resting.
* **Floor 5:** Utility checkpoint unlocking the Elevator mechanism and shortcut access.
* **Floors 5–8 (High Zone):** Escalating difficulty featuring advanced minion variations and elite mobs.
* **Floor 8:** Big Boss encounter featuring multi-phase attacks and illusion mechanic logic.
* **Floors 9–10 (Spire & Roof):** The final ascent leading to the ultimate climax of the run.

---

## 4. UI Architecture & Presentation Concepts

* **Skill Tree Interface:** Node-based branching interface displaying character attribute paths and elemental weapon evolutions alongside the zero-cost Reset action button.
* **Potion Crafting Journal:** Interactive recipe notebook interface where players manage collected herbs and mix potions.
* **Player HUD:** Displays HP, Rage Meter, potion quick-slots, mini-map, active status effects, and the dynamic Day/Night indicator.
* **Tower Navigation Map:** Visual floor-by-floor node progression map tracking cleared stages, safezones, boss stages, and hidden route shortcuts.

---

## 5. Active Skills & Ultimate Mechanics

Character Active Skills are unlocked at specific Skill Point (SP) thresholds and scale based on the active **Weapon Form Evolution**.

### Standard Active Skills (SP Milestones: 1 - 4 - 6)

#### 1. Wind Form (Trảm Phong)
* **Giải Phong Kiếm Khí:** Releases a swift sword wave forward, dealing damage and piercing through targets.
* **Phong Bộc:** Empowers the weapon, increasing attack speed, damage, and movement speed.
* **Quét Kiếm Phi Gió:** Dashes forward a short distance, dealing damage and knocking up enemies along the path.

#### 2. Fire Form (Hỏa Bộc)
* **Hỏa Ảnh Trảm:** Slashes forward in a box area, dealing instant damage and applying a Burn DoT effect.
* **Ma Hỏa:** Summons a floating flame that follows the player, building stacks as damage is dealt and exploding after 5 seconds for damage scaling with stacks.
* **Hỏa Nộ:** Sacrifices 25% current HP to create a ring of fire around the player for 3 seconds; killing an enemy within the ring resets the duration.

#### 3. Ice Form (Băng Sương)
* **Cấp Đông Tức Thì:** Deals frontal damage and inflicts a Slow effect on hit targets.
* **Hầm Mộ Băng Giá:** Freezes enemies in a cone area; basic attacks against frozen targets deal massive bonus damage.
* **Khiên Băng:** Generates an ice shield that absorbs incoming damage up to 25% of the player's Max HP.

### Ultimate Skills (SP Milestones: 5 - 8; Wind's Trăng Tối: 10)
*Requires full Rage Meter built up through combat actions.*

#### 1. Wind Form (Trảm Phong)
* **Cái Chết Tựa Cơn Gió:** Unleashes a multi-hit slash combo, leaving behind a wind vortex that grants a movement speed buff.
* **Trăng Tối:** For 3.6 seconds, repeatedly dashes around the nearest enemy (or around the cast point if none is nearby), dealing damage and slowing enemies along the path. The player is immune to damage while dashing; when it ends, unlocked Wind active skills are ready again.

#### 2. Fire Form (Hỏa Bộc)
* **Hỏa Kiếm:** Empowers basic attacks to shoot fire sword waves forward with every slash.
* **Hỏa Thần Giáng Lâm:** Sacrifices 50% of current HP to summon a massive meteor impact dealing extreme AoE damage.

#### 3. Ice Form (Băng Sương)
* **Chân Băng:** Summons an ancient ice pillar that constantly deals damage to surrounding enemies and freezes them for 0.5s every 2 seconds.
* **Kỷ Băng Hà:** Unleashes a global freeze wave that completely freezes all enemies on screen.

---

## 6. Enemy Behaviors & Day/Night Modifiers

| Mob Type | Day Map Behavior | Night Map Behavior |
| :--- | :--- | :--- |
| **Witch (Ranged)** | Normal casting frequency | Extended casting delay (Slower attacks) |
| **Knight (Melee)** | Standard attack speed | Extreme attack speed & aggressive tracking |
| **Tank (Heavy)** | Massive HP pool & armor | Reduced max HP, higher aggression |
| **Boss Entities** | Standard moveset patterns | Enhanced moveset & altered phase timers |

### Boss Mechanics Overview
* **Illusion Clones:** Bosses utilize illusion mechanics, spawning clones that attack simultaneously with only one real body dealing damage; players must locate the true body to progress.
* **Telegraphed Movesets:** Bosses feature distinct telegraph frames and vulnerability recovery windows, enabling skilled players to parry or dash to prevent incoming damage.
