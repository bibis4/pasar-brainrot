# Pasar Brainrot: Rebut & Rebirth

A bright, multiplayer market game built with Rojo and modular Luau scripts. Players buy original brainrot characters
from a shared conveyor, carry them home, earn cash from their displays, swipe stock from rivals, lock and defend their
base, then rebirth to reset their collection for a permanent income bonus.

## Play loop

- Walk to the central conveyor and press **E** (or the on-screen prompt) to buy an affordable brainrot.
- Carry it to the **DROP ZONE** in your base. Carrying slows your character by 30%; delivered characters earn cash each second.
- Visit another player's or an NPC rival's base and hold **E** on a displayed character to swipe it, then bring it home.
- Use the **Lock Base** button to protect your stock for 60 seconds. Use the gold stand at your base to upgrade defense.
- Rebirth from the HUD when you have the required cash and at least one delivered character. Rebirth clears cash and stock,
  grants a permanent +25% income multiplier, and improves higher-rarity conveyor odds at later tiers.

The game includes 10 original 3D characters across Common, Rare, Epic, Legendary, and Mythic rarities. Gold, Diamond, and
Rainbow mutations increase income. Four player bases and two NPC rivals surround the market plaza; rival raids can move
one of your displayed characters into an NPC base.

## Project layout

- `src/server/BrainrotCatalog.luau` defines the character catalog, rarities, mutation multipliers, and 3D models.
- `src/server/WorldBuilder.luau` constructs the plaza, conveyor, bases, rival keepers, and display stations.
- `src/server/GameService.luau` owns the single authoritative runtime state and server-validated game loop.
- `src/server/init.server.luau` starts the game service.
- `src/client/Game.client.luau` builds the responsive HUD and connects it to server remotes.
- `default.project.json` maps those modules into Roblox services and enables automatic character spawning.

## Build

With Rojo 7.7 installed, rebuild the Roblox place from the project root:

```sh
rojo build default.project.json --output game.rbxl
```

`PLAY.json` points to the published public experience. Replace the starter captures in `screenshots/` with screenshots of
the running game before submitting, and use one of those same captures as the first experience thumbnail in Creator Dashboard.
