# HOLUF — World Scale Lock (M62)

## 0. Purpose
This document finalizes the exact pixel dimensions and spatial relationships for HOLUF's 2D top-down environment production. It builds upon the art-direction guidelines established in M61 (World Production Visual Bible) and serves as the strict mechanical scale reference for M63–M75.

## 1. Locked Dimensions

| Element | Locked Scale / Dimension | Notes |
| :--- | :--- | :--- |
| **Base Tile** | **32x32 px** | Standard grid unit for terrain, paths, and modular buildings. |
| **Standard Humanoid Body Frame** | **32x48 px** | Core visual footprint for playable characters and NPCs. |
| **Allowed Visual Canvas / Overflow** | **Up to ~48x64 px** | Allowed for hair, cloaks, mantles, and weapon extensions without clipping. |
| **Player/NPC Collision** | **±24x16 px** | Placed at the feet to allow proper depth perception (Y-sorting). |
| **Normal Door** | **32 px** | Fits within exactly one base tile. |
| **Large Door** | **64 px** | Fits within two base tiles (for grand entrances or temples). |
| **Tree Collision** | **±32x32 px** | Trunk collision footprint. |
| **Tree Visual Canopy** | **~64x96 to 96x96 px** | Varies by region and tree type. |
| **Buildings** | **Modular multiples of 32 px** | Built using the base grid. |

## 2. Production Implications
- At a 1280x720 internal viewport, a 32x32 grid yields exactly **40 x 22.5 tiles** on screen natively.
- This provides ample space to appreciate the environment, while `Camera2D` zoom (e.g., 1.5x) can be utilized later (M70) for closer framing without changing these base assets.
- Production now safely unblocks M63 (Playable Character Sprite Pipeline) and M64 (NPC Sprite Pipeline).
