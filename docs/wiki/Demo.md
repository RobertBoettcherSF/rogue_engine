# DEMO: Playable walk / eat / breathe / sleep-dream

Status: **Spec ready** — ADA owns sim loop; Ops owns wiki/board; Data Scientist owns SI audit.

Player ask (Robert): walk around; eat or drink; breathing on **autopilot** with real limits from surrounding tile atmosphere; sleep and dream.

---

## Success criteria (try-local)

1. **Walk** — move human (or linked avatar) on ops-room / bunker tiles with AP / turn clock.
2. **Eat / drink** — consumable items restore hunger/thirst (or equivalent vitals); liquid/solid `Content_Mass` in **grams**; sip/bite subtracts mass.
3. **Autopilot breathe** — each tick, inhale from **current tile / room cell** atmosphere (cabin vs exterior split outdoors):
   - Effective O₂ = **tile P (kPa) × O₂%** (partial pressure), not O₂% alone
   - Bunker cell example: ~101 kPa × 21% ≈ **21 kPa** O₂-partial
   - Drop tissue O₂ when that product leaves ~**16–24 kPa**, or when **CO₂% climbs first** (Physical_Data)
   - Storm exterior at **20 kPa** with Earth air ≈ **4 kPa** O₂-partial — unsurvivable without sealed cabin/suit; never silently use bunker air outdoors
   - no manual “breathe” command required
4. **Sleep** — advances time, recovers fatigue, blocks walk until wake; O₂ draw may fall toward ~**0.35 L/min** (resting demo default **0.5 L/min**).
5. **Dream** — while asleep (or via explicit dream), run Dream-RSI **Dream** phase on logged Explore tree (cheap replay); wake can **Redeploy** improved weights (optional for demo v0).

Document `make play` (or equivalent) in README when green. Data Scientist SI-audits the demo PR.

---

## Package touchpoints

| Need | Likely packages |
|------|-----------------|
| Walk | `Game_Grid`, `Game_Actors`, turn clock |
| Eat / drink | `Game_Items` + actor vitals |
| Tile air | `Game_Environment` / ops-room air cells |
| Sleep | new or actors |
| Dream | `Game_Dream_RSI` |
| Start | `Game_Scenario` + `Game_Ops_Room` (shipped) |

---

## Out of scope for first demo

- Full Steam/GUI shell
- Titan start (bunker ops room is enough)
- Multiplayer

---

## Done when

- [ ] Walk + eat/drink + autopilot breathe + sleep/dream green in tests
- [ ] README try steps
- [ ] Board DEMO card → Done
