# Messages (passenger inbox)

Lean Ada — **incoming only** this phase (no compose). Package: `Game_Messages`.

## Features

| Action | v0 |
|--------|----|
| List | Show inbox |
| Open / read | View body |
| Archive | Move out of active list |
| Delete | Remove |
| Compose | **Not yet** |

Sources: **INFO** / **ANNOUNCEMENT** / **CAUTION** / **FAIL** — scripted seed + watchdog pushes.

FUTURE color (plain text now): ANNOUNCEMENT → yellow; CAUTION → orange; FAIL → red.

## Seed messages

1. **INFO** welcome (`Planetname` from scenario / profile — Earth / Mars / Titan):

> Dear Passenger. Thank you for flying with Rogue Engine. We hope you have a pleasant flight to and stay at **&lt;Planetname&gt;**.

2. **ANNOUNCEMENT** (technical difficulties):

> We are experiencing technical difficulties. Please observe and follow instructions from flight personnel

CAUTION / FAIL still push from the passenger-board watchdog when cabin status changes.

## Play

`make play` → wrist map → **`M`** opens inbox (separate UI surface). `1`–`9` open, `a` archive, `d` delete, `b` back. Profiles `1`–`4` reseed welcome with the active planet.

Map and inbox are separate UI surfaces.
