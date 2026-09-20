--  SPDX-License-Identifier: MIT
--  Copyright (c) 2026 Robert Boettcher

pragma Ada_2022;

package body Game_Atmosphere is

   function O2_Partial_kPa (Air : Tile_Atmosphere) return Natural is
   begin
      return (Natural (Air.Pressure_kPa) * Natural (Air.O2_Percent)) / 100;
   end O2_Partial_kPa;

   function In_Safe_O2_Band (Air : Tile_Atmosphere) return Boolean is
      P : constant Natural := O2_Partial_kPa (Air);
   begin
      return P >= Safe_O2_Partial_Min_kPa and then P <= Safe_O2_Partial_Max_kPa;
   end In_Safe_O2_Band;

   function From_Bunker_Room
     (Room : Game_Actors.Bunker_Room;
      Zone : Air_Zone := Cabin) return Tile_Atmosphere
   is
   begin
      return
        (Zone          => Zone,
         O2_Percent    => Room.O2_Percent,
         CO2_Percent   => Room.CO2_Percent,
         Pressure_kPa  => Abs_Pressure_kPa (Room.Pressure_kPa),
         Volume_Liters => Room.Volume_Liters);
   end From_Bunker_Room;

   function Cabin_Earth_Air
     (Volume_Liters : Positive := 44_000) return Tile_Atmosphere
   is
   begin
      return
        (Zone          => Cabin,
         O2_Percent    => 21,
         CO2_Percent   => 0,
         Pressure_kPa  => 101,
         Volume_Liters => Volume_Liters);
   end Cabin_Earth_Air;

   function Storm_Exterior_Air return Tile_Atmosphere is
   begin
      return
        (Zone          => Exterior,
         O2_Percent    => 21,
         CO2_Percent   => 0,
         Pressure_kPa  => Game_Environment.Storm_Outside_Pressure,
         Volume_Liters => 1_000_000);
   end Storm_Exterior_Air;

end Game_Atmosphere;
