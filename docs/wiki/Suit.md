# EVA suit

EMU-class: **~145 kg**, **29.6 kPa** 100% O2, **~8 h** + **30 min**. Orlan: **~110 kg**, **40 kPa**, **~7 h**.

Worn = `Mass_Kilograms` + AP penalty.

## Sealed

Breathe suit loop. O2-partial ≈ suit absolute P (pure O2 — do **not** ×0.21). Watchdog every **turn / ~1 s sim tick** (continuous IRL; no slow poll).

## Pierce (lean)

| Kind | Dump | Wrist |
|------|------|-------|
| **Pinhole** | Suit P falls over **minutes** toward ambient | CAUTION→FAIL as P drops |
| **Rip** | Toward ambient in **seconds** (same tick FAIL if already thin) | **FAIL** + falling suit P |

**Armstrong limit ~6.3 kPa:** hard FAIL (body fluids boil at body temp) even before hard vacuum. Near-vacuum unsealed: useful consciousness often **~10–15 s** — not a long warning.

Path: Pierce → unseal → ambient `P×mix`. Thin exterior ⇒ hypoxia. Cabin board unchanged unless vehicle hull breached.

See [Passenger_Board.md](Passenger_Board.md), [Physical_Data.md](Physical_Data.md).
