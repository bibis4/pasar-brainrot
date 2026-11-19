# Pasar Brainrot: Rebut & Rebirth

**Pasar Brainrot** is a colorful multiplayer market tycoon built with Rojo and modular Luau. The plaza is framed by a raised conveyor, timber-and-fabric kiosks, a large market entrance, hanging pennants, lanterns, planters, and six distinct player/NPC bases. Original brainrot characters use assembled Parts, readable faces, and compact labels—no external models or textures are required.

## How to play

1. Find an affordable brainrot on the central conveyor and press **E** (or use the on-screen prompt) to buy it.
2. Carry it back to the **DROP ZONE** in your base. Carrying reduces your movement speed by 30%.
3. A delivered brainrot earns cash every second. Displayed characters can be stolen from unlocked rival bases by holding **E**; take the stolen character back to your own DROP ZONE.
4. Use **Lock Base** in the HUD to secure your base for 60 seconds. The gold stand in your base upgrades its defense.
5. Rebirth from the HUD after meeting the cash requirement and owning at least one delivered brainrot. Rebirth resets cash and stock, grants a permanent +25% income multiplier, and boosts higher-rarity odds at later tiers.

The game has four player bases and two NPC rivals, ten original characters across Common, Rare, Epic, Legendary, and Mythic rarities, plus Gold, Diamond, and Rainbow mutations that increase income. The conveyor purchase prompts, base DROP ZONE, lock timer, rival theft, and rebirth loop are server-controlled.

## Project files

- `src/server/WorldBuilder.luau` builds the 3D plaza, kiosks, conveyor, entry arch, decorations, and bases.
- `src/server/BrainrotCatalog.luau` defines the characters, rarity/mutation data, and Part-based models.
- `src/server/GameService.luau` owns runtime state and the validated game loop.
- `src/server/Bootstrap.server.luau` starts the server game service.
- `src/client/Game.client.luau` creates the HUD and connects to server remotes.
- `default.project.json` maps the Rojo project into Roblox services.

## Build and run

With Rojo 7.7 installed, run from the repository root:

```sh
rojo build default.project.json --output game.rbxl
```

Open `game.rbxl` in Roblox Studio and press **Play** to test. For a submission, replace the starter captures in `screenshots/` with screenshots from the running game; use one as the first experience thumbnail. `PLAY.json` identifies the published experience.
