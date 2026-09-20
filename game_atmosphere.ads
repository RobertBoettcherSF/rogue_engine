--  SPDX-License-Identifier: MIT
--  Copyright (c) 2026 Robert Boettcher

pragma Ada_2022;

with Game_Actors;
with Game_Environment;

--  Tile / room-cell atmosphere for autopilot breathe (Demo Spec).
--  Effective O2 partial pressure = P(kPa) * O2% / 100 (not O2% alone).
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

   --  Safe O2-partial band (kPa). Leave band => tissue O2 drops.
   Safe_O2_Partial_Min_kPa : constant := 16;
   Safe_O2_Partial_Max_kPa : constant := 24;

   --  O2 draw rates (mL/min). Physical_Data Ops-locked ~0.84 kg/day ~= 408 mL/min;
   --  sleep ~0.70x resting.
   Resting_O2_mL_Per_Min : constant Positive := 408;
   Sleep_O2_mL_Per_Min   : constant Positive := 286;

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

   --  Bunker / sealed cabin (Tiangong-like preview): ~101 kPa * 21% ≈ 21 kPa O2-partial
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

   --  Storm exterior at 20 kPa with Earth air fraction ≈ 4 kPa O2-partial.
   --  Unsurvivable without sealed cabin/suit (Demo Spec; storm P locked for now).
   function Storm_Exterior_Air return Tile_Atmosphere
   with
     Global => null,
     Post   =>
       Storm_Exterior_Air'Result.Zone = Exterior
       and then Storm_Exterior_Air'Result.Pressure_kPa =
                  Game_Environment.Storm_Outside_Pressure
       and then Storm_Exterior_Air'Result.O2_Percent = 21
       and then O2_Partial_kPa (Storm_Exterior_Air'Result) = 4;

end Game_Atmosphere;
