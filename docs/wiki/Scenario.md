# SPEC: Game_Scenario (flexible starts)

Status: **Implemented** on main (`game_scenario.ads/.adb`, `tests_ops_scenario`). Engine stays generic; scenarios are data + thin Ada packages.

---

## Goal

Players must be able to start as **bunker + rover dust-storm ops** *or* **Titan-style flight-control / orbital-landing ops** (and later others) **without forking** grid, actors, items, environment, or Dream-RSI.

Titan flight-control is a **scenario**, not the engine identity.

---

## Package: `Game_Scenario`

### Types

- `Scenario_Id` - `Bunker_Rover_Storm`, `Titan_Flight_Control`
- `Linked_Outdoor_Role` - rover / lander / none
- `Atmosphere_Kind` - bunker-earth-storm vs Titan surface
- `Scenario_Config` - floor, outdoor role, atmosphere, Dream-RSI flag, ops room, storm, airlock

### Operations

- `Load_Scenario (Id) -> Scenario_Config`
- `Apply_Start (Config, Human, Robot)` - place human at ops seat; seed outdoor robot; airlock sealed

### Invariants

- Exactly one active scenario per run (caller-held)
- Airlock both-open still forbidden
- Human vitality = tissue O2 + room air; robot = power/hull/thermal outdoors
- Weight / mass rules always on

---

## Scenario A - Bunker + rover (default)

| Field | Value |
|-------|-------|
| Cast | Human 4 floors down; rover outside |
| Link | Sealed double-door airlock |
| Outdoor | Earth dust storm, Mars-like hostility (see Physical_Data) |
| Ops | 3x3 @ 1 m (9 m2): console, seat, suit hook 2000 mm, inner+outer doors |
| Dream-RSI | Rover Explore -> bunker Construct/Dream -> Redeploy |

## Scenario B - Titan-style flight control

| Field | Value |
|-------|-------|
| Cast | Operator in control room; linked lander role |
| Atmosphere | Titan surface profile from Physical_Data (clamped degC for now) |
| Dream-RSI | Optional; exploration policy on approach/landing branches |
| Note | Same packages; different atmosphere + start layout |

---

## Done when

- [x] `game_scenario.ads/.adb` + tests green on main
- [x] At least two start configs selectable in tests
- [x] Wiki Home links this page; Packages lists `Game_Scenario`
- [ ] Board card moves In progress -> Done

Hand-off: Ops owns Physical_Data numbers; ADA implements contracts from this Spec.
