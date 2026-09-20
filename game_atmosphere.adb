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

   function Mars_Thin_Storm_Air return Tile_Atmosphere is
   begin
      return Storm_Exterior_Air;
   end Mars_Thin_Storm_Air;

   function Mars_Exterior_Air return Tile_Atmosphere is
   begin
      --  ~0.6 kPa CO2-dominated; lean integer P=1 kPa, O2%=0.
      return
        (Zone          => Exterior,
         O2_Percent    => 0,
         CO2_Percent   => 95,
         Pressure_kPa  => Mars_Exterior_Pressure_kPa,
         Volume_Liters => 1_000_000);
   end Mars_Exterior_Air;

   function Titan_Exterior_Air return Tile_Atmosphere is
   begin
      --  ~147 kPa N2+CH4; no O2 field for CH4 -- O2%=0 means unbreathable.
      return
        (Zone          => Exterior,
         O2_Percent    => 0,
         CO2_Percent   => 0,
         Pressure_kPa  => Titan_Exterior_Pressure_kPa,
         Volume_Liters => 1_000_000);
   end Titan_Exterior_Air;

end Game_Atmosphere;
