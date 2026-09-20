--  SPDX-License-Identifier: MIT
--  Copyright (c) 2026 Robert Boettcher

pragma Ada_2022;

with Game_Atmosphere;

--  Cabin ECLSS scrubber / O2 make-up. Rates from Physical_Data (Ops-locked).
--  Contracts: Global/Pre/Post Ada style (proof FUTURE).
--  SPARK: FUTURE climb — L2–L4 candidate (IRL life-critical: cabin ECLSS tick). Ada-only this phase; no gnatprove required.
package Game_ECLSS is
   use type Game_Atmosphere.Air_Zone;


   --  ----- Ops-locked (Physical_Data ECLSS) -----
   --  Per person metabolic SoT: ~1.0 kg CO2/day, ~0.84 kg O2/day awake
   --  (sleep ~0.7x is Game_Atmosphere.Sleep_O2_mL_Per_Min).
   --  ISS-class scrubber ~6 kg CO2/day; OGA ~2.3-9.3 kg O2/day (demo uses low end).
   --  STP convert: mL/min = kg/day * 1000 / MW * 22400 / 1440.

   Person_CO2_Out_mL_Per_Min : constant Positive := 354;   -- 1.0 kg/day
   Person_O2_Use_mL_Per_Min  : constant Positive := 408;   -- 0.84 kg/day

   Scrubber_CO2_mL_Per_Min   : constant Positive := 2_121; -- 6 kg/day
   OGA_O2_Makeup_mL_Per_Min  : constant Positive := 1_118; -- 2.3 kg/day (range low)

   Target_CO2_Percent : constant Game_Atmosphere.Percent := 0;
   Target_O2_Percent  : constant Game_Atmosphere.Percent := 21;

   type Cabin_Loop is record
      Enabled    : Boolean := True;
      O2_Acc_mL  : Integer := 0;
      CO2_Acc_mL : Integer := 0;
   end record;

   function mL_Per_Percent (Air : Game_Atmosphere.Tile_Atmosphere) return Positive
   with
     Global => null,
     Post   => mL_Per_Percent'Result = Air.Volume_Liters * 10;

   --  Demo cell: Occupants = 1. Metabolic + scrubber + OGA make-up.
   procedure Tick_Cabin
     (Air        : in out Game_Atmosphere.Tile_Atmosphere;
      Loop_State : in out Cabin_Loop;
      Occupants  : Natural;
      Minutes    : Positive)
   with
     Global => null,
     Pre    => Minutes <= 24 * 60,
     Post   =>
       Air.Zone = Air.Zone'Old
       and then Air.Volume_Liters = Air.Volume_Liters'Old
       and then Air.Pressure_kPa = Air.Pressure_kPa'Old
       and then (if Air.Zone'Old /= Game_Atmosphere.Cabin then
                   Air.O2_Percent = Air.O2_Percent'Old
                   and then Air.CO2_Percent = Air.CO2_Percent'Old
                   and then Loop_State.O2_Acc_mL = Loop_State.O2_Acc_mL'Old
                   and then Loop_State.CO2_Acc_mL = Loop_State.CO2_Acc_mL'Old);

end Game_ECLSS;
