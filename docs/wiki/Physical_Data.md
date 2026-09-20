# Physical Data (Ops-owned)

Unit convention: [SI_Units.md](SI_Units.md).

## Passenger strip (4 values)

`P_kPa` · `O2_kPa` · `g_eff` (x g0) · `uSv_h` (uSv/h live). Cumulative mission mSv = later.

## g_eff (artificial gravity / force field)

Store only g_eff as multiples of g0. Field on sets a target g_eff — no fake units.

| Place | Typical g_eff |
|-------|----------------|
| Bunker / Earth surface | 1.00 |
| Ascent | peaks ~3-4 (greyout risk ~4.5+) |
| Coast (field off) | ~0 (micro-g flag) |
| Coast / station (field on) | target e.g. 1.00 or 0.38 |
| Mars surface | ~0.38 |
| Titan surface | ~0.14 |

## Radiation (live uSv/h)

| Phase / place | Lean default uSv/h | Watchdog |
|---------------|--------------------|----------|
| Cabin / bunker | ~0.1 | NOMINAL |
| Ascent bump | ~10-50 (minutes) | CAUTION |
| Coast GCR | ~50-100 | CAUTION |
| Exterior EVA / vacuum | much higher | ALERT |

## Atmosphere / worlds

| World | Ambient P | Unsuited? |
|-------|-----------|-----------|
| Earth cabin | ~101 kPa air | yes |
| Dock exterior | ~0 kPa vacuum | no |
| Mars surface | ~0.6 kPa | no (later) |
| Titan surface | ~147 kPa | no (later) |
| Demo Mars-thin storm | 20 kPa named | no |

Atm_Fraction cabin green: 0.90-1.10 (Earth=1.00).

## Watchdog abbrev

O2 FAIL less than 16 kPa; O2 CAUTION outside 16-24; CO2 CAUTION greater than 0.4, FAIL at/above 3; Armstrong suit 6.3 kPa; ALERT blink 3x / 3x.
