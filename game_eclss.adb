--  SPDX-License-Identifier: MIT
--  Copyright (c) 2026 Robert Boettcher

pragma Ada_2022;

package body Game_ECLSS is

   function mL_Per_Percent (Air : Game_Atmosphere.Tile_Atmosphere) return Positive is
   begin
      return Air.Volume_Liters * 10;
   end mL_Per_Percent;

   procedure Clamp_Percent (P : in out Game_Atmosphere.Percent; Raw : Integer) is
   begin
      if Raw < 0 then
         P := 0;
      elsif Raw > 100 then
         P := 100;
      else
         P := Game_Atmosphere.Percent (Raw);
      end if;
   end Clamp_Percent;

   procedure Settle_O2
     (Air : in out Game_Atmosphere.Tile_Atmosphere;
      Acc : in out Integer)
   is
      Step : constant Positive := mL_Per_Percent (Air);
   begin
      while Acc <= -Integer (Step) and then Air.O2_Percent > 0 loop
         Acc := Acc + Integer (Step);
         Clamp_Percent (Air.O2_Percent, Integer (Air.O2_Percent) - 1);
      end loop;
      while Acc >= Integer (Step) and then Air.O2_Percent < 100 loop
         Acc := Acc - Integer (Step);
         Clamp_Percent (Air.O2_Percent, Integer (Air.O2_Percent) + 1);
      end loop;
   end Settle_O2;

   procedure Settle_CO2
     (Air : in out Game_Atmosphere.Tile_Atmosphere;
      Acc : in out Integer)
   is
      Step : constant Positive := mL_Per_Percent (Air);
   begin
      while Acc >= Integer (Step) and then Air.CO2_Percent < 100 loop
         Acc := Acc - Integer (Step);
         Clamp_Percent (Air.CO2_Percent, Integer (Air.CO2_Percent) + 1);
      end loop;
      while Acc <= -Integer (Step) and then Air.CO2_Percent > 0 loop
         Acc := Acc + Integer (Step);
         Clamp_Percent (Air.CO2_Percent, Integer (Air.CO2_Percent) - 1);
      end loop;
   end Settle_CO2;

   procedure Tick_Cabin
     (Air        : in out Game_Atmosphere.Tile_Atmosphere;
      Loop_State : in out Cabin_Loop;
      Occupants  : Natural;
      Minutes    : Positive)
   is
      O2_Used : Integer;
      CO2_Out : Integer;
      Scrub   : Integer;
      Makeup  : Integer;
   begin
      if Air.Zone /= Game_Atmosphere.Cabin then
         return;
      end if;

      --  Metabolic (Physical_Data): 1.0 kg CO2/day, 0.84 kg O2/day per person.
      O2_Used := Integer (Occupants) * Integer (Person_O2_Use_mL_Per_Min)
        * Integer (Minutes);
      CO2_Out := Integer (Occupants) * Integer (Person_CO2_Out_mL_Per_Min)
        * Integer (Minutes);
      Loop_State.O2_Acc_mL := Loop_State.O2_Acc_mL - O2_Used;
      Loop_State.CO2_Acc_mL := Loop_State.CO2_Acc_mL + CO2_Out;

      if Loop_State.Enabled then
         --  ISS-class scrubber ~6 kg CO2/day.
         Scrub := Integer (Scrubber_CO2_mL_Per_Min) * Integer (Minutes);
         Loop_State.CO2_Acc_mL := Loop_State.CO2_Acc_mL - Scrub;

         --  OGA make-up (demo uses range low 2.3 kg/day) when O2 below target.
         if Air.O2_Percent < Target_O2_Percent
           or else Loop_State.O2_Acc_mL < 0
         then
            Makeup := Integer (OGA_O2_Makeup_mL_Per_Min) * Integer (Minutes);
            Loop_State.O2_Acc_mL := Loop_State.O2_Acc_mL + Makeup;
         end if;
      end if;

      Settle_O2 (Air, Loop_State.O2_Acc_mL);
      Settle_CO2 (Air, Loop_State.CO2_Acc_mL);

      if Loop_State.Enabled and then Air.O2_Percent > Target_O2_Percent then
         Air.O2_Percent := Target_O2_Percent;
         if Loop_State.O2_Acc_mL > 0 then
            Loop_State.O2_Acc_mL := 0;
         end if;
      end if;
   end Tick_Cabin;

end Game_ECLSS;
