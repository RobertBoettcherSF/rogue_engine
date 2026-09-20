# DEMO: Playable walk / eat / breathe / sleep-dream

Status: **Spec ready** — ADA owns sim loop; Ops owns wiki/board; Data Scientist owns SI audit.

Player ask (Robert): walk around; eat or drink; breathing on **autopilot** with real limits from surrounding tile atmosphere; sleep and dream.

---

## Success criteria (try-local)

1. **Walk** — move human (or linked avatar) on ops-room / bunker tiles with AP / turn clock.
2. **Eat / drink** — consumable items restore hunger/thirst (or equivalent vitals); mass decreases.
3. **Autopilot breathe** — each tick, inhale from **current tile / room cell** atmosphere:
   - pressure (kPa), O₂%, CO₂%, volume mixing per [Physical_Data](Physical_Data.md) + [SI_Units](SI_Units.md)
   - tissue oxygenation updates; hypoxia if tile air bad or pressure too low
   - no manual “breathe” command required
4. **Sleep** — action that advances time, recovers fatigue, blocks walk until wake.
5. **Dream** — while asleep (or via explicit dream), run Dream-RSI **Dream** phase on logged Explore tree (cheap replay); wake can **Redeploy** improved weights (optional for demo v0).

Document `make play` (or equivalent) in README when green.

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
