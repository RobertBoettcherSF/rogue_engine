--  SPDX-License-Identifier: MIT
--  Copyright (c) 2026 Robert Boettcher

pragma Ada_2022;

package body Game_Passenger_Board is

   function Build
     (Cabin   : Game_Atmosphere.Tile_Atmosphere;
      Human   : Game_Actors.Human_Actor;
      Clock   : Game_Turn.Clock;
      Alarm   : Natural := 0) return Passenger_Board
   is
      Board : Passenger_Board;
      O2_P  : constant Natural := Game_Atmosphere.O2_Partial_kPa (Cabin);
      CO2_P : constant Natural :=
        (Natural (Cabin.Pressure_kPa) * Natural (Cabin.CO2_Percent)) / 100;
      Clarity : constant Game_Actors.Vision_Clarity_Percent :=
        Human.Vision_Clarity;
   begin
      Board.Current_G_Tenths := Human.G_Load;
      Board.MET_Seconds := Clock.Minutes * 60;
      Board.Vision_Clarity := Clarity;
      Board.Alarm_Code := Alarm;
      Board.Warning_Red := Alarm > 0;

      --  Cabin status from O2-partial band + CO2 (Physical_Data / Tiangong).
      if Cabin.Zone /= Game_Atmosphere.Cabin then
         Board.Cabin_Status := Fail;
      elsif O2_P < Game_Atmosphere.Safe_O2_Partial_Min_kPa
        or else O2_P > Game_Atmosphere.Safe_O2_Partial_Max_kPa
        or else CO2_P >= 3
      then
         Board.Cabin_Status := Fail;
      elsif CO2_P >= 1 or else O2_P < 18 or else O2_P > 22 then
         Board.Cabin_Status := Caution;
      else
         Board.Cabin_Status := OK;
      end if;

      --  Priority 1 always populated (status, warnings, g).
      Board.Cabin_P_kPa := Natural (Cabin.Pressure_kPa);
      Board.O2_Partial_kPa := O2_P;
      Board.CO2_Partial_kPa := CO2_P;

      --  Dense pilot lines drop first at ~20% clarity.
      Board.Dense_Dropped := Clarity > 0 and then Clarity <= 20;

      --  Priority 2: MET / P / O2 / CO2 — garble under heavy dim / blackout.
      if Clarity <= 20 then
         Board.Priority2_Garbled := True;
         Board.MET_Seconds := Unreadable_Sentinel;
         Board.Cabin_P_kPa := Unreadable_Sentinel;
         Board.O2_Partial_kPa := Unreadable_Sentinel;
         Board.CO2_Partial_kPa := Unreadable_Sentinel;
      end if;

      return Board;
   end Build;

end Game_Passenger_Board;
