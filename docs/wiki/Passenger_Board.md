# Passenger board

Ada keeps SI inside. Passenger sees **NOMINAL / CAUTION / FAIL** first; numbers optional.

## Atm_Fraction display

**0.00…1.00**, **1.00 = Earth (~101 kPa)**. Cabin green total P: **0.90–1.10**. Mars-thin ~0.20 (red unsuited). EMU ~0.29 pure O2 can still be NOMINAL.

## Terminal colors (ANSI, `make play`)

| Level | Color | Use |
|-------|-------|-----|
| NOMINAL | **green** | Important values OK |
| CAUTION | **yellow** | Watch / soft limit |
| WARN | **orange** | Urgent but not failed |
| FAIL | **red** | Immediate action / alarm push |

Text UI only until screenshot gate.

## Priority lines

1. Cabin air status (+ red warnings push)
2. Current g
3. MET; optional P / O2 as Atm_Fraction or kPa

Drop dense rates first when Vision_Clarity is low.
