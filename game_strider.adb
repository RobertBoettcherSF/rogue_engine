--  SPDX-License-Identifier: MIT
--  Copyright (c) 2026 Robert Boettcher

pragma Ada_2022;

package body Game_Strider is

   function Make_Demo_Chassis return Chassis is
   begin
      return
        (Empty_Mass_kg   => Demo_Empty_Mass_kg,
         Payload_kg      => 0,
         Payload_Cap_kg  => Demo_Payload_Cap_kg,
         Power_Budget_kW => Demo_Power_Budget_kW,
         Power_Draw_kW   => 0,
         Step_Meters     => Demo_Step_Meters);
   end Make_Demo_Chassis;

   function Total_Mass_kg (C : Chassis) return Mass_Kilograms is
   begin
      return C.Empty_Mass_kg + C.Payload_kg;
   end Total_Mass_kg;

   function Demo_To_Full_Mass_Ratio return Natural is
   begin
      return Natural (Full_Empty_Mass_kg) / Natural (Demo_Empty_Mass_kg);
   end Demo_To_Full_Mass_Ratio;

end Game_Strider;
