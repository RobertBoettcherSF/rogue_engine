# Dream-RSI (in rogue_engine)

Closed loop for rover exploration policy (bunker “dreams,” storm “explores”):

1. **Explore** — online policy drives discovery; log every branch/score/cost into a `Discovery_Tree`.
2. **Construct** — `Construct_Replay_Simulator` keeps evaluated history as a cheap world.
3. **Dream** — `Evaluate_Policy` / `Improve_Policy` test candidate weights offline.
4. **Redeploy** — best `Exploration_Policy` goes back online (`Dream_RSI_Exploration`).

Ada package: `Game_Dream_RSI` (`game_dream_rsi.ads` / `.adb`).
