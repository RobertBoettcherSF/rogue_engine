# Passenger board / live watchdog

Map is nav only. Live monitor: **NOMINAL / CAUTION / FAIL** (plain text; FUTURE colors).

## Watchdog SI trips (leave NOMINAL)

| Trip | Condition |
|------|-----------|
| Cabin total P | Atm_Fraction outside **0.90–1.10** |
| Cabin O2 | O2-partial outside **~16–24 kPa** |
| Cabin CO2 | **> 0.4 kPa** (emergency **> 3 kPa** → FAIL) |
| Suit | Seal fail, Pierce, or life-support timer out |
| G | `G_Load` into greyout / blackout |

## Sealed suit display

Breathe **suit loop** (~29.6 kPa, 100% O2). Show seal, O2 time, NOMINAL/CAUTION/FAIL. Ambient thin air does not feed lungs while sealed.

## Pierce (lean Spec — next Ada)

`Pierce` → unseal → breathe **ambient P×mix**. In Mars-thin / true Mars / Titan outdoor: O2-partial collapses → tissue hypoxia → **FAIL** (“suit pressure”). No timed pinhole vs blowout in v0 — binary unseal is enough. Cabin passengers stay on cabin board unless the vehicle hull is breached.

Offline watchdog: `make test`.
