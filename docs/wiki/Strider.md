# Strider (remote outdoor walker)

Clean-room outdoor linked machine. **Demo v0:** human stays in the ops room and remote-pilots the Strider. Vitals: **power / hull / thermal** only (no lungs). Human autopilot breathe always uses **bunker / cabin** air.

## SI lock (Data Scientist)

### Full-class (wiki / design only — NOT on the 1 m tile map)

| Quantity | Value |
|----------|-------|
| Rest / empty mass | **~1.68×10⁶ kg** (1680 t) |
| Step | **~12 m** |
| Cruise | **~13 m/s** |
| Hard limit | **~21 m/s** |
| Power / overload | **14 MW / 19 MW** |
| Snow wade | **~5 m** |
| Payload class | includes **~1×10⁵ kg** radiator lifts |

`Mass_Grams` max (1×10⁶ g = 1 t) is too small for walker empty mass → vehicles use **`Mass_Kilograms`** (`Game_Strider`). Eat/drink/carry stay **grams**.

### Demo stand-in (ops-room remote on 1 m tiles)

| Quantity | Value |
|----------|-------|
| Empty mass | **5×10⁴ kg** |
| Step | **1 tile = 1 m** |
| Payload cap | **5×10² kg** |
| Power budget | **kW** (`Demo_Power_Budget_kW` = 400) |
| Mass scale vs full-class | **≈ 1/34** (1 680 000 / 50 000 ≈ 33.6) |

Ada: `Game_Strider.Make_Demo_Chassis`, remote cmds in `Game_Demo` (`Strider_Walk` / `Turn` / `Scan` spend **strider AP**).

## Try

```bash
make play
make test
```
