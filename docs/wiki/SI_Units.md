# SI / units convention

Source of truth for physical units in `rogue_engine`. Playability clamps are fine; units and order of magnitude must match [Physical_Data](Physical_Data.md).

Owner: Data Scientist (units) + Operations Manager (numbers). Consumer: ADA contracts.

| Quantity | Base / allowed unit | Ada naming |
|----------|---------------------|------------|
| Human / item mass | gram (g) | `Mass_Grams` |
| **Vehicle mass** | **kilogram (kg)** (megagram/t for docs) | **`Mass_Kilograms`** |
| Length | metre (m); mm for integer precision | `Length_mm`, `Height_mm` |
| Area | m2 | `Floor_Area_m2` |
| Volume | litre (L), m3 docs | `Volume_Liters` |
| Pressure | absolute kPa | `Abs_Pressure_kPa` |
| Temperature | kelvin SoT; Celsius telemetry | shared K / wide Celsius type |
| Time | second | cycle/wall time |
| Power | kW demo; MW full vehicle docs | typed power budget |
| Visibility | metre | `Visibility_Meters` |

Do not use `Mass_Grams` for vehicles: the shipped human/item range tops at 1,000,000 g (1 t), while full strider mass is 1,680,000 kg.

Game scalars (AP, tile indices, percentages for tissue/hull/power/integrity) are explicitly non-SI.

`Chunk_Extent` is tile count, not metres. Floor m2 and air volume m3 are separate.

Open alignment items: named storm profiles instead of unnamed 20 kPa Earth default; consolidate temperature types / Kelvin for Titan; tile physical dimensions/heights.
