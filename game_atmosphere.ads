--  SPDX-License-Identifier: MIT
--  Copyright (c) 2026 Robert Boettcher

pragma Ada_2022;

with Game_Actors;
with Game_Environment;

--  Tile / room-cell atmosphere for autopilot breathe (Demo Spec).
--  Effective O2 partial pressure = P(kPa) * O2% / 100 (not O2% alone).
--  Body profiles (data only; Scenario selects -- no engine fork):
--    Earth cabin ~101 kPa air, breathable, g0=1.00
--    Mars-thin storm demo 20 kPa (keep named; not true Mars)
--    Mars exterior ~0.6 kPa CO2 -> 1 kPa SI integer, suit required, g0~0.38
--    Titan exterior ~147 kPa N2+CH4, suit required, g0~0.14
package Game_Atmosphere is

   subtype Percent is Game_Actors.Percent;
   subtype Abs_Pressure_kPa is Game_Environment.Abs_Pressure_kPa;

   type Air_Zone is (Cabin, Exterior);

   type Tile_Atmosphere is record
      Zone          : Air_Zone := Cabin;
      O2_Percent    : Percent := 21;
      CO2_Percent   : Percent := 0;
      Pressure_kPa  : Abs_Pressure_kPa := 101;
      Volume_Liters : Positive := 44_000;
   end record;

   --  O2-partial watchdog (kPa). DS SI: FAIL only <16; CAUTION if >24;
   --  cabin allow ~19-30 (no FAIL above 24). Autopilot softens only >30.
   Safe_O2_Partial_Min_kPa : constant := 16;
   Safe_O2_Partial_Max_kPa : constant := 24;  -- nominal green upper; not FAIL
   Cabin_O2_Allow_Max_kPa  : constant := 30;  -- DS cabin allow ~19-30

   --  O2 draw rates (mL/min). Physical_Data Ops-locked ~0.84 kg/day ~= 408 mL/min;
   --  sleep ~0.70x resting.
   Resting_O2_mL_Per_Min : constant Positive := 408;
   Sleep_O2_mL_Per_Min   : constant Positive := 286;

   --  Surface g0 in tenths (10 = 1.00 g). Scenario / body data, not thrust load.
   Earth_Surface_G_Tenths : constant Game_Actors.G_Load_Tenths := 10;  -- 1.00
   Mars_Surface_G_Tenths  : constant Game_Actors.G_Load_Tenths := 4;   -- ~0.38
   Titan_Surface_G_Tenths : constant Game_Actors.G_Load_Tenths := 1;   -- ~0.14

   --  True Mars exterior ~0.6 kPa; lean SI integer stores 1 kPa.
   Mars_Exterior_Pressure_kPa : constant Abs_Pressure_kPa := 1;
   Titan_Exterior_Pressure_kPa : constant Abs_Pressure_kPa := 147;

   --  Effective O2 partial pressure in kPa: floor(P * O2% / 100).
   function O2_Partial_kPa (Air : Tile_Atmosphere) return Natural
   with
     Global => null,
     Post   =>
       O2_Partial_kPa'Result =
         (Natural (Air.Pressure_kPa) * Natural (Air.O2_Percent)) / 100;

   function In_Safe_O2_Band (Air : Tile_Atmosphere) return Boolean
   with
     Global => null,
     Post   =>
       In_Safe_O2_Band'Result =
         (O2_Partial_kPa (Air) >= Safe_O2_Partial_Min_kPa
          and then O2_Partial_kPa (Air) <= Safe_O2_Partial_Max_kPa);

   function From_Bunker_Room
     (Room : Game_Actors.Bunker_Room;
      Zone : Air_Zone := Cabin) return Tile_Atmosphere
   with Global => null;

   --  Bunker / sealed cabin (Tiangong-like preview): ~101 kPa * 21% ~= 21 kPa O2-partial
   --  (DS propose O2-partial 19-30 kPa; Ops lock before widening autopilot band).
   function Cabin_Earth_Air
     (Volume_Liters : Positive := 44_000) return Tile_Atmosphere
   with
     Global => null,
     Post   =>
       Cabin_Earth_Air'Result.Zone = Cabin
       and then Cabin_Earth_Air'Result.Pressure_kPa = 101
       and then Cabin_Earth_Air'Result.O2_Percent = 21
       and then O2_Partial_kPa (Cabin_Earth_Air'Result) = 21;

   --  Mars-thin storm exterior (20 kPa) with Earth air fraction ~= 4 kPa O2-partial.
   --  Demo / bunker-storm ADA lock -- NOT true Mars ~0.6 kPa (see Mars_Exterior_Air).
   function Storm_Exterior_Air return Tile_Atmosphere
   with
     Global => null,
     Post   =>
       Storm_Exterior_Air'Result.Zone = Exterior
       and then Storm_Exterior_Air'Result.Pressure_kPa =
                  Game_Environment.Storm_Outside_Pressure
       and then Storm_Exterior_Air'Result.O2_Percent = 21
       and then O2_Partial_kPa (Storm_Exterior_Air'Result) = 4;

   --  Alias: same 20 kPa Mars-thin storm demo profile.
   function Mars_Thin_Storm_Air return Tile_Atmosphere
   with Global => null, Post => Mars_Thin_Storm_Air'Result = Storm_Exterior_Air;

   --  True Mars exterior: ~0.6 kPa CO2 (stored 1 kPa), O2%=0 -- not breathable (suit).
   function Mars_Exterior_Air return Tile_Atmosphere
   with
     Global => null,
     Post   =>
       Mars_Exterior_Air'Result.Zone = Exterior
       and then Mars_Exterior_Air'Result.Pressure_kPa =
                  Mars_Exterior_Pressure_kPa
       and then Mars_Exterior_Air'Result.O2_Percent = 0
       and then O2_Partial_kPa (Mars_Exterior_Air'Result) = 0;

   --  Titan exterior: ~147 kPa N2+CH4 (O2%=0) -- not breathable (suit).
   function Titan_Exterior_Air return Tile_Atmosphere
   with
     Global => null,
     Post   =>
       Titan_Exterior_Air'Result.Zone = Exterior
       and then Titan_Exterior_Air'Result.Pressure_kPa =
                  Titan_Exterior_Pressure_kPa
       and then Titan_Exterior_Air'Result.O2_Percent = 0
       and then O2_Partial_kPa (Titan_Exterior_Air'Result) = 0;

end Game_Atmosphere;
