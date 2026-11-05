# Build Progress Log: Tower of Arcana (Game UITXVNG)

**File Identifier:** `_Build_Progress.md`  
**Purpose:** Incremental release and progress tracking log for new features, structural map updates, asset additions, and gameplay mechanics across development builds.  
*(Note: Bug reports, fix logs, and issue tracking are documented separately).*

---

## [Build 0.1.0] - Prototype 1: Basement Layer & Core Combat Foundation

**Release Date:** October 2026  
**Milestone Focus:** Initial Playable Prototype / Vertical Slice Foundation  

---

### 1. Map & Level Layout Structure (Basement Zone)

The foundational 2.5D layout for the Basement Zone (Floors 1 through 3) and the secret floor structure has been successfully constructed:

*   **Base-1 (Floor 1 - Initial Basement):**
    *   Leftmost spawn point (Broken Hole entry point).
    *   Rectangular basement layout designed for 2.5D side-scrolling traversal.
    *   Basic enemy wave triggers and tutorial area setup.
*   **HiddenBase-1.5 (Floor 1.5 - Secret Area):**
    *   Layout structure designed for hidden room mechanics.
    *   Passage route connected to secret triggers accessible from elevator hints.
*   **Base-2 (Floor 2 - Intermediate Zone):**
    *   Layout tailored for elite minion encounters and Guard Chest interactions.
    *   Platforming elevation test zones.
*   **Base-3 (Floor 3 - Mini-Boss Arena):**
    *   Enclosed chamber for the first Mini-Boss encounter (King Crab).
    *   Exit ladder path connecting the basement out onto the Floor 4 Garden Safezone.

---

### 2. Environment Visuals & Lighting Pass

*   **Base-1 Texture Integration:**
    *   Applied custom basement tileset textures across all floor surfaces and back walls in `Base-1`.
    *   Established visual depth separating walkable foreground paths and background walls.
*   **Dynamic Torch Lighting:**
    *   Added animated wall torches (`torch.tscn`) across `Base-1`.
    *   Integrated local point lights (`OmniLight3D`) attached to torches to establish the dark basement atmosphere.

---

### 3. Minion & Enemy Additions

Implemented AI State Machine (FSM) structures and visual assets for two new minion types:

1.  **Skeleton:**
    *   **Role:** Basic Melee Ground Entity.
    *   **Behavior:** Patrols platforms, detects player proximity, and performs close-range physical slash attacks.
2.  **Pelican:**
    *   **Role:** Ranged Avian Mob.
    *   **Behavior:** Hovering/aerial movement pattern, fires ranged projectiles directed at the main character.

---

### 4. Main Character (Foxy) & Combat System

*   **Starter Weapon:** Integrated basic Dagger weapon model and sprite rendering.
*   **Primary Attack Mechanics:**
    *   Melee slash combo animations mapped to basic attack inputs.
    *   Added directional melee attack slash VFX (hit effect overlay).
    *   Basic hurtbox/hitbox collision detection between Dagger slash and enemy hitboxes.

---

### 5. Level Traversal & Stage Mechanics

*   **Parkour Transition Section:**
    *   Designed and implemented a platforming parkour challenge connecting `Base-1` to `Base-2`.
    *   Tests jump height, momentum sliding, and platform collision accuracy for multi-level High/Low ground movement.

---

## Progress Summary Table

| Category | Item / Feature | Status | Notes |
| :--- | :--- | :--- | :--- |
| **Map Layout** | Base-1, HiddenBase-1.5, Base-2, Base-3 | ✅ Complete | Structural layout finished |
| **Textures** | Base-1 Floors & Walls | ✅ Integrated | Basement tileset applied |
| **Lighting** | Wall Torches (`OmniLight3D`) | ✅ Integrated | Placed & animated in Base-1 |
| **Enemies** | Skeleton & Pelican | ✅ Implemented | Melee & Ranged behaviors active |
| **Combat** | Basic Dagger & Slash VFX | ✅ Implemented | Attack animation & hitboxes linked |
| **Traversal** | Parkour Section (Base-1 ➔ Base-2) | ✅ Functional | Platforming integration tested |