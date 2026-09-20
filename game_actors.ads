--  SPDX-License-Identifier: MIT
--  Copyright (c) 2026 Robert Boettcher

pragma Ada_2022;

with Game_Grid;

--  Twofold cast:
--    Human -- stays in a small sealed bunker; vitality = tissue oxygenation.
--    Robot -- works outdoors; vitality = power / hull / thermal (no lungs).
package Game_Actors is
   use type Game_Grid.Point;

   subtype Action_Points is Integer range -1_000 .. 1_000;
   subtype Speed_Value is Positive;

   --  ----- Human (bunker) -----
   --  Tissue oxygenation % (SpO2-style). This is human "health".
   subtype Tissue_Oxygenation is Natural range 0 .. 100;

   Healthy_O2_Min  : constant Tissue_Oxygenation := 95;
   Wounded_O2_Min  : constant Tissue_Oxygenation := 70;

   type Human_Condition is (Healthy, Wounded, Critical, Dead);

   --  Small sealed bunker room atmosphere (drives oxygenation over time).
   subtype Percent is Natural range 0 .. 100;
   subtype Room_Pressure_kPa is Natural range 0 .. 200;

   --  Defaults preview Tiangong-like cabin (DS propose): ~101 kPa, ~21 kPa O2-partial.
   --  Full band / CO2 kPa / RH / scrubber await Ops Physical_Data lock.
   type Bunker_Room is record
      O2_Percent     : Percent := 21;
      CO2_Percent    : Percent := 0;
      Pressure_kPa   : Room_Pressure_kPa := 101;
      Volume_Liters  : Positive := 20_000;  -- ~ small shelter room
   end record;

   --  Demo vitals: hunger/thirst/fatigue are game scalars 0..100.
   subtype Vital_Percent is Natural range 0 .. 100;

   type Human_Actor is record
      Position     : Game_Grid.Point := (X => 0, Y => 0);
      Speed        : Speed_Value := 1;
      AP           : Action_Points := 0;
      Oxygenation  : Tissue_Oxygenation := 100;
      Hunger       : Vital_Percent := 40;
      Thirst       : Vital_Percent := 40;
      Fatigue      : Vital_Percent := 60;
      Sleeping     : Boolean := False;
   end record;

   --  ----- Robot (outdoors) -----
   subtype Power_Percent is Natural range 0 .. 100;
   subtype Hull_Percent is Natural range 0 .. 100;
   subtype Thermal_C is Integer range -100 .. 200;

   Safe_Robot_Temp_Max : constant Thermal_C := 80;

   type Robot_Condition is (Nominal, Degraded, Critical, Offline);

   type Robot_Actor is record
      Position : Game_Grid.Point := (X => 0, Y => 0);
      Speed    : Speed_Value := 1;
      AP       : Action_Points := 0;
      Power    : Power_Percent := 100;
      Hull     : Hull_Percent := 100;
      Thermal  : Thermal_C := 20;
   end record;

   Invalid_Move  : exception;
   Asleep_Error  : exception;

   function Human_Status (Self : Human_Actor) return Human_Condition
   with Global => null;

   function Robot_Status (Self : Robot_Actor) return Robot_Condition
   with Global => null;

   procedure Initialize_Human
     (Self     : out Human_Actor;
      Location : Game_Grid.Point;
      Speed    : Speed_Value)
   with
     Global => null,
     Post   =>
       Self.Position = Location
       and then Self.Speed = Speed
       and then Self.AP = 0
       and then Self.Oxygenation = 100
       and then Self.Hunger = 40
       and then Self.Thirst = 40
       and then Self.Fatigue = 60
       and then Self.Sleeping = False;

   --  Compat alias used by older tests / Step 2 call sites.
   procedure Initialize
     (Self     : out Human_Actor;
      Location : Game_Grid.Point;
      Speed    : Speed_Value) renames Initialize_Human;

   procedure Initialize_Robot
     (Self     : out Robot_Actor;
      Location : Game_Grid.Point;
      Speed    : Speed_Value)
   with
     Global => null,
     Post   =>
       Self.Position = Location
       and then Self.Speed = Speed
       and then Self.AP = 0
       and then Self.Power = 100
       and then Self.Hull = 100
       and then Self.Thermal = 20;

   procedure Adjust_Action_Points
     (Self     : in out Human_Actor;
      Delta_AP : Integer)
   with Global => null;

   procedure Adjust_Action_Points
     (Self     : in out Robot_Actor;
      Delta_AP : Integer)
   with Global => null;

   procedure Adjust_Oxygenation
     (Self   : in out Human_Actor;
      Amount : Integer)
   with Global => null;

   procedure Adjust_Hunger
     (Self   : in out Human_Actor;
      Amount : Integer)
   with Global => null;

   procedure Adjust_Thirst
     (Self   : in out Human_Actor;
      Amount : Integer)
   with Global => null;

   procedure Adjust_Fatigue
     (Self   : in out Human_Actor;
      Amount : Integer)
   with Global => null;

   --  Tick bunker air -> shift human oxygenation (simple sealed-room model).
   procedure Breathe_In_Bunker
     (Self : in out Human_Actor;
      Room : Bunker_Room)
   with Global => null;

   --  Autopilot breathe from current tile/room cell atmosphere (Demo Spec).
   --  Effective O2 = P(kPa) * O2% / 100. Drop tissue O2 when product leaves
   --  16..24 kPa band, or when CO2% climbs first. No manual breathe command.
   --  Sleeping uses lower O2 draw (metabolic); hypoxia rules still apply.
   procedure Autopilot_Breathe
     (Self         : in out Human_Actor;
      O2_Percent   : Percent;
      CO2_Percent  : Percent;
      Pressure_kPa : Room_Pressure_kPa)
   with Global => null;

   procedure Begin_Sleep (Self : in out Human_Actor)
   with
     Global => null,
     Post   => Self.Sleeping;

   procedure Wake (Self : in out Human_Actor)
   with
     Global => null,
     Post   => not Self.Sleeping;

   procedure Adjust_Power
     (Self   : in out Robot_Actor;
      Amount : Integer)
   with Global => null;

   procedure Adjust_Hull
     (Self   : in out Robot_Actor;
      Amount : Integer)
   with Global => null;

   procedure Set_Thermal
     (Self : in out Robot_Actor;
      Temp : Thermal_C)
   with
     Global => null,
     Post   => Self.Thermal = Temp;

   procedure Move_To
     (Self        : in out Human_Actor;
      Destination : Game_Grid.Point)
   with
     Global => null,
     Pre    => not Self.Sleeping;

   procedure Move_To
     (Self        : in out Robot_Actor;
      Destination : Game_Grid.Point)
   with Global => null;

end Game_Actors;
