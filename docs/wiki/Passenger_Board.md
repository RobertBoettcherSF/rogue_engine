# Passenger board / live watchdog

Map is nav only. Monitor: **ANNOUNCEMENT / CAUTION / FAIL** (+ NOMINAL when clear). Plain text now; FUTURE colors: yellow / orange / red.

## Warning ladder (urgency) — DS SI

| Level | Urgency | Examples | Passenger sees |
|-------|---------|----------|----------------|
| **NOMINAL** | clear | O2-partial **16–24 kPa**; CO2 ≤0.4 kPa; sealed suit loop | `cabin_status=NOMINAL` |
| **ANNOUNCEMENT** | low | Info, MET ticks | `ANNOUNCEMENT:` |
| **CAUTION** | medium | O2-partial **>24 kPa** (cabin allow still ~19–30); CO2 **>0.4 kPa**; Atm toward edge; suit reserve low; G greyout ~3.5–4.5 g | `CAUTION` |
| **FAIL** | high / immediate | O2-partial **<16 kPa only** (not >24); CO2 **≥3 kPa**; Atm outside **0.90–1.10**; suit pierce/unseal in thin air; suit P **≤6.3 kPa** Armstrong; G blackout ~5 g+ | `FAIL` — act now |

## Routines (sim)

Every **turn / ~1 s tick**: recompute → set master status. FAIL keeps critical lines visible even if vision dim. CAUTION does not hard-stop. FAIL on suit/cabin air → hypoxia path; blackout blocks voluntary glance.

`./play` wrist map: [Wrist_Map.md](Wrist_Map.md). Pierce: [Suit.md](Suit.md).

Offline: `make test`.
