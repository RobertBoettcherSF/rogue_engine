# DEMO: Playable walk / eat / breathe / sleep-dream / strider / EVA suit

Status: **Spec ready**.

Player can walk, eat/drink, autopilot-breathe, sleep/dream, remote-pilot a strider from the ops room, and **don helmet+suit to exit the airlock outdoors** using IRL EMU-class numbers in [Physical_Data](Physical_Data.md).

Clean-room Ada only; no third-party novel text.

## Success criteria

1. Walk on bunker tiles with AP.
2. Eat/drink; content mass in grams decreases.
3. Autopilot breathe from current cell when unsuited (P x O2%; ~16–24 kPa band).
4. Sleep / Dream-RSI as before.
5. Strider remote-pilot from console (demo 50 t / 500 kg payload; full-class wiki-only).
6. **EVA suit exit:**
   - Don suit + lock helmet (EMU default: ~145 kg total ISS config, **29.6 kPa** 100% O2, ~8 h primary + ~30 min reserve).
   - Airlock cycle to storm; both doors never open together.
   - Outdoors: breathe from **suit loop**, not storm tile air.
   - Without sealed suit, outer exit blocked or fatal on thin exterior.
   - Suit mass applies encumbrance; Orlan alt profile optional (110 kg, 40 kPa, ~7 h).

Document `make play` when green. Data Scientist SI-audits the PR.

## Done when

- [ ] Prior demo criteria green
- [ ] Helmet+suit don / airlock / outdoor suit-loop breathe green
- [ ] README try steps
- [ ] Board DEMO card to Done
