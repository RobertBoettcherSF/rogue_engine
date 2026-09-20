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


   function Payload_Is_Trivial
     (Empty, Payload : Mass_Kilograms) return Boolean
   is
   begin
      return Payload * 10 <= Empty;
   end Payload_Is_Trivial;

   function Can_Load
     (C       : Chassis;
      Payload : Mass_Kilograms) return Boolean
   is
   begin
      return Payload <= C.Payload_Cap_kg;
   end Can_Load;

   procedure Set_Payload
     (C       : in out Chassis;
      Payload : Mass_Kilograms)
   is
   begin
      if not Can_Load (C, Payload) then
         raise Constraint_Error;
      end if;
      C.Payload_kg := Payload;
   end Set_Payload;

   function Demo_To_Full_Mass_Ratio return Natural is
   begin
      return Natural (Full_Empty_Mass_kg) / Natural (Demo_Empty_Mass_kg);
   end Demo_To_Full_Mass_Ratio;

end Game_Strider;
