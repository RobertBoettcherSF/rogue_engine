# Messages (communicator inbox)

Incoming only for now (list / read / archive / delete). No compose. Package: `Game_Messages`.

Communicator tells story from values. Same inbox for all kinds.

## Kinds

| Kind | Role | Examples |
|------|------|----------|
| **STORY** | narrative | welcome / flight to &lt;Planetname&gt; |
| **ANNOUNCEMENT** | general PA | technical difficulties |
| **CAUTION** | soft systems | O2 drifting, CO2 up, greyout |
| **ALERT** | hard FAIL | hypoxia, pierce, Armstrong, blackout |
| **GUIDANCE** | nav | course set / distance m |

Watchdog pushes CAUTION/ALERT from SI. STORY/ANNOUNCEMENT are scripted. GUIDANCE from wrist-map.

## Priority (IRL cuff rule)

**ALERT > CAUTION > ANNOUNCEMENT / GUIDANCE > STORY**

- ALERT / CAUTION must **never** wait on STORY (`Active_Slot` / list order).
- STORY must **never** rewrite SI numbers (kPa / s / kg). Life path = raw SI + locked trips; story is narrative only.

## Seeds

**STORY:** Dear Passenger… pleasant flight to and stay at **&lt;Planetname&gt;**.

**ANNOUNCEMENT:** We are experiencing technical difficulties. Please observe and follow instructions from flight personnel.

## Game vs IRL suit cuff

Same Ada core (P, O2-partial, seal, timer, CAUTION/ALERT). STORY optional for fiction; life-critical path always on. L2–L4 labeled for later prove.

## Play

`make play` → wrist map → **`M`** opens inbox. `1`–`9` open, `a` archive, `d` delete, `b` back.
