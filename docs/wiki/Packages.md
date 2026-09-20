# Packages (Ada 2022) — inventory SoT

**Ada-only this phase** (through production screenshots). SPARK L2–L4 = labels / FUTURE prove — no `gnatprove` required now.

| Package | On main | Role | Proof label |
|---------|---------|------|-------------|
| `Game_Grid` | yes | Points, terrain, chunks, LOS | L2–L4 candidate |
| `Game_Actors` | yes | Human (O2, hunger/thirst/fatigue, sleep, breathe, `G_Load`/`Vision_Clarity`, glance AP) · Robot · AP | L2–L4 (breathe) |
| `Game_Items` | yes | Mass, containers, Sip/Bite, tools, plasma | L2–L4 if life-critical |
| `Game_Dream_RSI` | yes | Explore→Construct→Dream→Redeploy | L2–L4 candidate |
| `Game_Environment` | yes | Bunker depth, airlock, storm, satellite, aurora | L2–L4 (airlock) |
| `Game_Atmosphere` | yes | Tile air; O2-partial = P×O2%; cabin vs exterior | L2–L4 candidate |
| `Game_Turn` | yes | Turn / wall-minute clock; AP grant; walk cost | L2–L4 candidate |
| `Game_Ops_Room` | yes | 5×4 @ 1 m, heights, ~44 m³ | L2–L4 candidate |
| `Game_Scenario` | yes | Starts; linked outdoor **Strider** | L2–L4 candidate |
| `Game_Strider` | yes | Vehicle kg/kW; full + demo chassis; remote link | L2–L4 (strider-link) |
| `Game_Suit` | yes | EMU 145 kg worn; 29.6 kPa O2; Orlan alt | L2–L4 (suit) |
| `Game_ECLSS` | yes | Cabin scrubber / O2 make-up tick (Ops rates) | L2–L4 (ECLSS) |
| `Game_Demo` | yes | Walk, eat/drink, tick+ECLSS, sleep/dream, Strider, `Glance_Wrist`, `Passenger_Panel` | L2–L4 candidate |
| `Game_Messages` | yes | Inbox STORY/ANNOUNCEMENT/CAUTION/ALERT/GUIDANCE; cuff priority; no compose | L2–L4 candidate |
| `Game_Passenger_Board` | yes | OK/CAUTION/FAIL; g, MET, P, O2/CO2; vision-dim drops dense lines | L2–L4 candidate |

Also: `play.adb`, `tests.adb`, `tests_ops_scenario.adb`, `tests_demo.adb`.

Facts: [Physical_Data](Physical_Data.md) · Units: [SI_Units](SI_Units.md) · Demo: [Demo](Demo.md) · Strider: [Strider](Strider.md) · Passenger: [Passenger_Board](Passenger_Board.md) · Proof: [Proof](Proof.md)
