# EVA suit

EMU-class default: **~145 kg**, **29.6 kPa** 100% O2, **~8 h** + **30 min** reserve. Orlan alt: **~110 kg**, **40 kPa**, **~7 h**.

Worn = `Mass_Kilograms` + AP penalty (never Strength 5 kg carry).

## Sealed

Breathe suit loop. O2-partial ≈ suit absolute P (pure O2 — do **not** ×0.21). Board / wrist: **NOMINAL** if sealed + healthy loop.

## Pierce / unseal (lean)

`Pierce (Pinhole | Rip)` → **unseal** → breathe **ambient** `P×mix` (same law as cabin/exterior).

| Kind | Suit P toward ambient | Notes |
|------|----------------------|--------|
| **Pinhole** | **Minutes** (~3 kPa/min lean) | Wrist: suit P falling + **FAIL** |
| **Rip** | **Seconds** (~5 kPa/s lean) | Fast equalize |

**Armstrong:** suit P below **~6.3 kPa** (Ada **6**) = hard **FAIL**. Near vacuum / Armstrong: useful consciousness **~10–15 s** (`Consciousness_S`, default 12).

Thin exterior (Mars-thin 20 kPa, Mars ~0.6 kPa, Titan non-O2) → hypoxia on ambient path.

See [Passenger_Board.md](Passenger_Board.md), [Physical_Data.md](Physical_Data.md), [Wrist_Map.md](Wrist_Map.md).
