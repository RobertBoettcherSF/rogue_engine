# Passenger board / live watchdog

Map is nav only. Live monitor is separate: **NOMINAL / CAUTION / FAIL** (plain text; FUTURE colors).

## Watchdog SI trips (leave NOMINAL)

| Trip | Condition |
|------|-----------|
| Cabin total P | Atm_Fraction outside **0.90–1.10** (Earth = 1.00) |
| Cabin O2 | O2-partial outside **~16–24 kPa** |
| Cabin CO2 | **> 0.4 kPa** long-term (emergency **> 3 kPa** → FAIL) |
| Suit | Seal fail or life-support timer exhausted |
| G | `G_Load` into greyout / blackout band |

Map may stay visible; these lights are independent.

Ada stores kPa; board may show Atm_Fraction. Offline watchdog = `make test` PASS suite.
