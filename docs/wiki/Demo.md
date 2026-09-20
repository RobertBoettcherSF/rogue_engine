# DEMO: Playable walk / eat / breathe / sleep-dream / strider

Status: **Spec ready** — ADA owns sim loop; Ops owns wiki/board; Data Scientist owns SI audit.

Player ask (Robert): walk around; eat or drink; breathing on **autopilot** with real limits from surrounding tile atmosphere; sleep and dream; **operate a strider from the existing ops room** (remote-pilot, human stays seated).

Clean-room: invent original names/mechanics in Ada; do **not** paste third-party novel text into the repo.

---

## Success criteria (try-local)

1. **Walk** — move human on ops-room / bunker tiles with AP / turn clock.
2. **Eat / drink** — consumable items restore hunger/thirst; liquid/solid `Content_Mass` in **grams**; sip/bite subtracts mass.
3. **Autopilot breathe** — each tick, inhale from **current tile / room cell** atmosphere (cabin vs exterior split outdoors):
   - Effective O2 = **tile P (kPa) x O2%** (partial pressure), not O2% alone
   - Bunker cell example: ~101 kPa x 21% ≈ **21 kPa** O2-partial
   - Drop tissue O2 when that product leaves ~**16–24 kPa**, or when **CO2% climbs first** (Physical_Data)
   - Storm exterior at **20 kPa** with Earth air ≈ **4 kPa** O2-partial — unsurvivable without sealed cabin/suit; never silently use bunker air outdoors
   - no manual breathe command required
4. **Sleep** — advances time, recovers fatigue, blocks walk until wake; O2 draw may fall toward ~**0.35 L/min** (resting demo default **0.5 L/min**).
5. **Dream** — while asleep (or via explicit dream), run Dream-RSI **Dream** phase on logged Explore tree; wake can **Redeploy** (optional for demo v0).
6. **Strider remote-pilot (from ops room)** — human remains in bunker/ops room; console links to a **strider** outdoor `Robot_Actor`:
   - Linked outdoor role (alongside rover), not become the mech
   - Commands: walk legs on storm grid, face, wait; spend AP on the strider while human stays seated
   - Strider vitals: **power / hull / thermal** (no lungs); exterior air does not breathe for the human
   - Mass class: heavy walker — empty mass and payload in **grams** (`Mass_Grams`); demo may use a smaller stand-in tonnage if map scale requires it, but document the scale factor
   - Link needs console + power; drop link on power loss / out of range (simple range OK for v0)
   - Dream-RSI Explore logs can come from strider ticks while linked

Document `make play` (or equivalent) in README when green. Data Scientist SI-audits the demo PR.

---

## Package touchpoints

| Need | Likely packages |
|------|-----------------|
| Walk | `Game_Grid`, `Game_Actors`, turn clock |
| Eat / drink | `Game_Items` + actor vitals |
| Tile air | `Game_Environment` / ops-room air cells |
| Sleep | actors / turn clock |
| Dream | `Game_Dream_RSI` |
| Strider link | `Game_Scenario` linked outdoor role + console in `Game_Ops_Room` + `Robot_Actor` |
| Start | `Game_Scenario` + `Game_Ops_Room` (shipped) |

---

## Out of scope for first demo

- Full Steam/GUI shell
- Mandatory Titan start (ops room + storm strider is enough)
- Multiplayer
- Novel-accurate vehicle brands or quoted prose

---

## Done when

- [ ] Walk + eat/drink + autopilot breathe + sleep/dream green in tests
- [ ] Console to strider remote walk on outdoor grid green in tests
- [ ] README try steps
- [ ] Board DEMO card to Done
