--  SPDX-License-Identifier: MIT
--  Copyright (c) 2026 Robert Boettcher

pragma Ada_2022;

with Ada.Text_IO;

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

   function Status_Label (Kind : Cabin_Status_Kind) return String is
   begin
      case Kind is
         when OK =>
            return "NOMINAL";  -- FUTURE color: green
         when Caution =>
            return "CAUTION";  -- FUTURE color: orange
         when Fail =>
            return "FAIL";     -- FUTURE color: red
      end case;
   end Status_Label;

   function Atm_Fraction_Hundredths (Cabin_P_kPa : Natural) return Natural is
   begin
      if Cabin_P_kPa = Unreadable_Sentinel then
         return Unreadable_Sentinel;
      end if;
      return (Cabin_P_kPa * 100) / Earth_Reference_kPa;
   end Atm_Fraction_Hundredths;

   --  Trim leading blank from 'Image.
   function Img (N : Natural) return String is
      S : constant String := Natural'Image (N);
   begin
      if S'Length > 0 and then S (S'First) = ' ' then
         return S (S'First + 1 .. S'Last);
      end if;
      return S;
   end Img;

   function Atm_Frac_Text (Hundredths : Natural) return String is
      Whole : constant Natural := Hundredths / 100;
      Frac  : constant Natural := Hundredths mod 100;
   begin
      if Hundredths = Unreadable_Sentinel then
         return "----";
      end if;
      if Frac < 10 then
         return Img (Whole) & ".0" & Img (Frac);
      end if;
      return Img (Whole) & "." & Img (Frac);
   end Atm_Frac_Text;

   procedure Put_Text_Dump (Board : Passenger_Board) is
      package TIO renames Ada.Text_IO;
      Frac    : constant Natural := Atm_Fraction_Hundredths (Board.Cabin_P_kPa);
      G_Whole : constant Natural := Natural (Board.Current_G_Tenths) / 10;
      G_Tenth : constant Natural := Natural (Board.Current_G_Tenths) mod 10;
   begin
      --  Plain Ada dump. FUTURE: wrap Status_Label / alarm / announcement
      --  lines in ANSI (green/yellow/orange/red) that no-ops when TERM=dumb.
      TIO.Put_Line ("--- passenger board ---");
      --  ANNOUNCEMENT (FUTURE color: yellow)
      TIO.Put_Line ("ANNOUNCEMENT: cabin meta panel (plain text)");
      TIO.Put_Line ("cabin_status=" & Status_Label (Board.Cabin_Status));
      if Board.Warning_Red then
         --  Critical alarm (FUTURE color: red)
         TIO.Put_Line ("ALARM_CRITICAL code=" & Img (Board.Alarm_Code));
      end if;
      TIO.Put_Line ("g=" & Img (G_Whole) & "." & Img (G_Tenth));
      if Board.Priority2_Garbled then
         TIO.Put_Line ("MET_s=----  cabin_P_kPa=----  atm_frac=----");
         TIO.Put_Line ("O2_partial_kPa=----  CO2_partial_kPa=----");
      else
         TIO.Put_Line ("MET_s=" & Img (Board.MET_Seconds));
         TIO.Put_Line
           ("cabin_P_kPa="
            & Img (Board.Cabin_P_kPa)
            & "  atm_frac="
            & Atm_Frac_Text (Frac));
         TIO.Put_Line
           ("O2_partial_kPa="
            & Img (Board.O2_Partial_kPa)
            & "  CO2_partial_kPa="
            & Img (Board.CO2_Partial_kPa));
      end if;
      if Board.Dense_Dropped then
         TIO.Put_Line ("(dense ECLSS/fuel/attitude lines dropped)");
      end if;
      TIO.Put_Line ("--- end passenger board ---");
   end Put_Text_Dump;

end Game_Passenger_Board;
