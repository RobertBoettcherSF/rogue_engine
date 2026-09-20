# DEMO: Playable walk / eat / breathe / sleep-dream / strider

Status: **Spec ready** — ADA owns sim loop; Ops owns wiki/board; Data Scientist owns SI audit.

Player can walk, eat/drink, breathe automatically from current tile air, sleep/dream, and remote-pilot a strider from the existing ops room. Clean-room: no third-party prose or brands in repo.

## Success criteria

1. Walk on bunker tiles with AP.
2. Eat/drink; `Content_Mass` in grams decreases per bite/sip.
3. Autopilot breathe from current cell: effective O2 = absolute pressure kPa x O2 fraction; healthy band roughly 16–24 kPa; CO2 can fail first; no manual breathe command.
4. Sleep advances time, recovers fatigue, blocks walk until wake; target O2 draw ~0.35 L/min vs 0.5 resting.
5. Dream runs Dream-RSI replay while asleep; optional Redeploy on wake.
6. Strider remote-pilot: human stays seated in bunker air; console links outdoor `Robot_Actor`; walk/facing/wait cost strider AP; vitals power/hull/thermal; link needs console/power/range.

### Strider scale

| Quantity | Full class | Demo |
|----------|------------|------|
| Empty mass | 1,680,000 kg | 50,000 kg |
| Payload | **100,000 kg (100 t; trivial/light for full class)** | 500 kg |
| Step | ~12 m | 1 m tile |
| Power | 14 MW, 19 MW overload | kW budget |

Use `Mass_Kilograms` for vehicles; grams remain for food/drink/carry. Full and demo profiles must be named; no silent scale substitution. Full-class code should type-check 100 t as trivial payload.

Dream-RSI Explore logs may come from linked strider ticks.

Document `make play` (or equivalent) in README when green. Data Scientist SI-audits the PR.

## Done when

- [ ] Walk + eat/drink + autopilot breathe + sleep/dream tests green
- [ ] Console-to-strider outdoor remote walk tests green
- [ ] `Payload_Is_Trivial` proves/tests 100,000 kg for full class
- [ ] README try steps
- [ ] Board DEMO card to Done
