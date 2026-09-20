--  SPDX-License-Identifier: MIT
--  Copyright (c) 2026 Robert Boettcher

pragma Ada_2022;

--  Strider vehicle SI. Carry/eat/drink stay on Game_Items.Mass_Grams;
--  walker empty mass exceeds 1e6 g, so vehicles use Mass_Kilograms.
package Game_Strider is

   --  Up to ~2000 t so full-class wiki constants type-check.
   subtype Mass_Kilograms is Natural range 0 .. 2_000_000;
   subtype Power_kW is Natural range 0 .. 100_000;
   subtype Speed_m_s is Natural range 0 .. 100;

   --  ----- Full-class (wiki / design SoT only; NOT placed on 1 m tile map) -----
   Full_Empty_Mass_kg     : constant Mass_Kilograms := 1_680_000;  -- ~1680 t
   Full_Step_Meters       : constant := 12;
   Full_Cruise_m_s        : constant Speed_m_s := 13;
   Full_Hard_Limit_m_s    : constant Speed_m_s := 21;
   Full_Power_kW          : constant Power_kW := 14_000;   -- 14 MW
   Full_Overload_kW       : constant Power_kW := 19_000;   -- 19 MW
   Full_Snow_Wade_Meters  : constant := 5;
   Full_Payload_kg        : constant Mass_Kilograms := 100_000;  -- ~1e5 kg class

   --  ----- Demo stand-in (ops-room remote on 1 m tiles) -----
   Demo_Empty_Mass_kg     : constant Mass_Kilograms := 50_000;  -- 5e4 kg
   Demo_Payload_Cap_kg    : constant Mass_Kilograms := 500;     -- 5e2 kg
   Demo_Step_Meters       : constant := 1;  -- 1 tile = 1 m
   Demo_Power_Budget_kW   : constant Power_kW := 400;
   --  Full empty / demo empty ≈ 1_680_000 / 50_000 ≈ 33.6 → document as ≈ 1/34.
   Mass_Scale_Denom       : constant := 34;

   type Chassis is record
      Empty_Mass_kg   : Mass_Kilograms := Demo_Empty_Mass_kg;
      Payload_kg      : Mass_Kilograms := 0;
      Payload_Cap_kg  : Mass_Kilograms := Demo_Payload_Cap_kg;
      Power_Budget_kW : Power_kW := Demo_Power_Budget_kW;
      Power_Draw_kW   : Power_kW := 0;
      Step_Meters     : Positive := Demo_Step_Meters;
   end record;

   function Make_Demo_Chassis return Chassis
   with
     Global => null,
     Post   =>
       Make_Demo_Chassis'Result.Empty_Mass_kg = Demo_Empty_Mass_kg
       and then Make_Demo_Chassis'Result.Payload_Cap_kg = Demo_Payload_Cap_kg
       and then Make_Demo_Chassis'Result.Step_Meters = Demo_Step_Meters
       and then Make_Demo_Chassis'Result.Power_Budget_kW = Demo_Power_Budget_kW;

   function Total_Mass_kg (C : Chassis) return Mass_Kilograms
   with
     Global => null,
     Pre    => C.Empty_Mass_kg <= Mass_Kilograms'Last - C.Payload_kg,
     Post   => Total_Mass_kg'Result = C.Empty_Mass_kg + C.Payload_kg;


   --  "Even 100 t is nothing" on a full-class walker: payload ≤ 10% of empty.
   function Payload_Is_Trivial
     (Empty, Payload : Mass_Kilograms) return Boolean
   with
     Global => null,
     Post   =>
       Payload_Is_Trivial'Result = (Payload * 10 <= Empty);

   function Can_Load
     (C       : Chassis;
      Payload : Mass_Kilograms) return Boolean
   with
     Global => null,
     Post   => Can_Load'Result = (Payload <= C.Payload_Cap_kg);

   procedure Set_Payload
     (C       : in out Chassis;
      Payload : Mass_Kilograms)
   with
     Global => null,
     Pre    => Can_Load (C, Payload),
     Post   => C.Payload_kg = Payload;

   function Demo_To_Full_Mass_Ratio return Natural
   with
     Global => null,
     Post   =>
       Demo_To_Full_Mass_Ratio'Result =
         Natural (Full_Empty_Mass_kg) / Natural (Demo_Empty_Mass_kg);

end Game_Strider;
