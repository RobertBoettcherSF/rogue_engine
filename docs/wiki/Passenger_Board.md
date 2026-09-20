# Passenger board

Ada keeps SI inside. Passenger sees **NOMINAL / CAUTION / FAIL** (and announcements) as **plain text** this phase.

## Atm_Fraction display

**0.00…1.00**, **1.00 = Earth (~101 kPa)**. Cabin green total P: **0.90–1.10**. Mars-thin ~0.20 (bad for unsuited). EMU ~0.29 pure O2 can still be NOMINAL.

## Status levels (plain Ada now)

| Level | Meaning |
|-------|--------|
| NOMINAL | All clear |
| ANNOUNCEMENT | General info |
| CAUTION | Cautionary warning |
| FAIL | Critical alarm |

**FUTURE color** (not this phase): NOMINAL→green, ANNOUNCEMENT→yellow, CAUTION→orange, FAIL→red (ANSI or UI later).

## Priority lines

1. Cabin air status + critical alarms
2. Current g
3. MET; optional P / O2

Drop dense rates first when Vision_Clarity is low.
