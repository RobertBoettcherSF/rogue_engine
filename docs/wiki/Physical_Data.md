# Physical Data (Ops-owned)

Factual baselines for typed Ada contracts. **Code may clamp for playability**, but units and order-of-magnitude must match these tables.

Owner: Operations Manager. Unit convention: [SI_Units.md](SI_Units.md).

SI-audit: EMU/Orlan **pass**; ECLSS **pass** (metabolic SoT unified).

---

## Metabolic SoT

| State | O2 | CO2 |
|-------|----|-----|
| Awake | **0.84 kg/day/person** | **1.0 kg/day/person** |
| Sleep | **~0.59 kg/day** (~0.7×) | ~0.7× |

Awake STP volume ~**0.41 L/min**. Demo ECLSS 1× matches awake row.

---

## Mass / carry (human)

Comfortable carry @ Strength 4–6: **5 kg**. Unit: `Mass_Grams` for backpack/food only.

---

## EVA suit / helmet

EMU ISS default: **~145 kg**, **29.6 kPa** 100% O2, **~8 h** + **30 min**. Orlan: **~110 kg**, **40 kPa**, **~7 h**. Worn = `Mass_Kilograms` + AP penalty — never Strength carry.

### Wrist cuff

| Mode | Readouts |
|------|----------|
| Unsuited cabin | P, O2%/CO2%, O2-partial, temp, ECLSS status, warnings |
| Suited | suit P, O2 time (+reserve), thermal, seals, battery |
| Optional rocket | cabin ΔP outside, MET/clock |

**High-g / near-blackout:**

| State | Behavior |
|-------|----------|
| Soft coast | Normal voluntary glance |
| High `Thrust_g` / `G_Load` | Raise-arm costs AP; may fail `Can_Raise_Arm` |
| Near-blackout (e.g. **~20% Vision_Clarity** = 80% dim) | Non-critical cuff/console lines omit or garble; **red alarms still push** |
| Full blackout | No voluntary glance until G drops |

---

## Tiangong-like cabin

~101 kPa; O2 partial ~19–30 kPa; CO2 ≤0.4 kPa long-term / ≤3 kPa emergency; ~20–25 C; RH ~50–65%.

---

## ECLSS

CDRA-class ~6 kg CO2/day; OGA ~2.3–9.3 kg O2/day; demo 1× scrub 1.0 / make-up 0.84 kg/day.

---

## Strider

Full: 1,680,000 kg empty / 100,000 kg trivial payload. Demo: 50,000 / 500 kg.

---

## Airlock / storm / Titan

Both-open forbidden. Name Mars-thin if ~20 kPa exterior. Titan ~1.47–1.50 bar, ~94 K.

---

## Update rule

Ops revises numbers; ADA implements; same-PR fix for drift.
