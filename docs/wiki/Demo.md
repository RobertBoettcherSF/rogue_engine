# DEMO: Playable walk / eat / breathe / sleep-dream / strider / EVA suit

Status: **Spec ready**.

Player can walk, eat/drink, autopilot-breathe, sleep/dream, remote-pilot a strider from the ops room, don helmet+suit for airlock exit, and see suit vitals on a **wrist/cuff terminal** (display over typed state).

Clean-room Ada only; no third-party novel text. Numbers: [Physical_Data](Physical_Data.md).

## Success criteria

1. Walk on bunker tiles with AP.
2. Eat/drink; content mass in grams decreases.
3. Autopilot breathe from current cell when unsuited (P x O2%; ~16–24 kPa band).
4. Sleep / Dream-RSI as before.
5. Strider remote-pilot from console (demo 50 t / 500 kg; full-class wiki-only).
6. EVA suit exit (EMU ~145 kg, 29.6 kPa 100% O2, ~8 h + 30 min); outdoors suit-loop only.
7. **Wrist terminal** shows at least: suit P, O2 time left, CO2/caution, thermal, power, seal status, tissue O2 — no new physics, no ECG required for v0.

Optional later: Tiangong-class cabin profile from Physical_Data.

Document `make play` when green. Data Scientist SI-audits the PR.

## Done when

- [ ] Criteria 1–7 green in tests / play
- [ ] README try steps
- [ ] Board DEMO card to Done
