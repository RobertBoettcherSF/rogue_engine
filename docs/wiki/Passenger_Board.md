# Passenger board / live watchdog

Map is nav only. Monitor: **NOMINAL / ANNOUNCEMENT / CAUTION / FAIL**. Plain text; FUTURE colors.

## Warning ladder

| Level | Urgency | SI trips |
|-------|---------|----------|
| **NOMINAL** | clear | All in band |
| **ANNOUNCEMENT** | low | Info / MET / inbox INFO |
| **CAUTION** | medium | Atm_Fraction toward edge; O2-partial **outside 16–24 kPa** (cabin may still be OK up to ~30); CO2 **>0.4 kPa**; suit reserve; G greyout ~3.5–4.5 g |
| **FAIL** | immediate | Atm outside **0.90–1.10**; O2-partial **<16 kPa** only (not >24); CO2 **≥3 kPa**; suit pierce/unseal in thin air; suit P **≤6.3 kPa**; G blackout ~5 g+ |

Every sim tick. FAIL lines stay visible when dim.

Inbox: warnings/INFO also land as messages — see [Messages.md](Messages.md).
