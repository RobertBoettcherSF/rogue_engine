# Passenger board / live watchdog

Map is nav only. Monitor: **ANNOUNCEMENT / CAUTION / FAIL** (+ NOMINAL when clear). Plain text now; FUTURE colors: yellow / orange / red.

## Warning ladder (urgency)

| Level | Urgency | Examples | Passenger sees |
|-------|---------|----------|----------------|
| **NOMINAL** | clear | All watchdog SI in band | `cabin_status=NOMINAL` |
| **ANNOUNCEMENT** | low | Info, MET ticks | `ANNOUNCEMENT:` |
| **CAUTION** | medium | Atm_Fraction toward edge; O2-partial toward 16/24 kPa; CO2 rising; suit reserve low; G greyout ~3.5–4.5 g | `CAUTION` |
| **FAIL** | high / immediate | Atm outside **0.90–1.10**; O2-partial **<16 or >24 kPa**; CO2 **>0.4 kPa**; suit pierce/unseal in thin air; suit P **≤6.3 kPa** Armstrong; G blackout ~5 g+ | `FAIL` — act now |

## Routines (sim)

Every **turn / ~1 s tick**: recompute → set master status. FAIL keeps critical lines visible even if vision dim. CAUTION does not hard-stop. FAIL on suit/cabin air → hypoxia path; blackout blocks voluntary glance.

`./play` happy path may only print NOMINAL until Pierce + interactive wrist-map land.

Offline: `make test`.
