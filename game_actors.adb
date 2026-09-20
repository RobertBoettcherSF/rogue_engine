--  SPDX-License-Identifier: MIT
--  Copyright (c) 2026 Robert Boettcher

pragma Ada_2022;

package body Game_Actors is

   function Clamp_0_100 (Raw : Integer) return Natural is
   begin
      if Raw < 0 then
         return 0;
      elsif Raw > 100 then
         return 100;
      else
         return Natural (Raw);
      end if;
   end Clamp_0_100;

   procedure Clamp_AP
     (AP       : in out Action_Points;
      Delta_AP : Integer)
   is
      Raw : constant Long_Long_Integer :=
        Long_Long_Integer (AP) + Long_Long_Integer (Delta_AP);
      Lo  : constant Long_Long_Integer :=
        Long_Long_Integer (Action_Points'First);
      Hi  : constant Long_Long_Integer :=
        Long_Long_Integer (Action_Points'Last);
   begin
      if Raw < Lo then
         AP := Action_Points'First;
      elsif Raw > Hi then
         AP := Action_Points'Last;
      else
         AP := Action_Points (Raw);
      end if;
   end Clamp_AP;

   function Human_Status (Self : Human_Actor) return Human_Condition is
   begin
      if Self.Oxygenation = 0 then
         return Dead;
      elsif Self.Oxygenation < Wounded_O2_Min then
         return Critical;
      elsif Self.Oxygenation < Healthy_O2_Min then
         return Wounded;
      else
         return Healthy;
      end if;
   end Human_Status;

   function Robot_Status (Self : Robot_Actor) return Robot_Condition is
   begin
      if Self.Power = 0 or else Self.Hull = 0 then
         return Offline;
      elsif Self.Thermal > Safe_Robot_Temp_Max
        or else Self.Power < 30
        or else Self.Hull < 30
      then
         return Critical;
      elsif Self.Power < 70 or else Self.Hull < 70 then
         return Degraded;
      else
         return Nominal;
      end if;
   end Robot_Status;

   procedure Initialize_Human
     (Self     : out Human_Actor;
      Location : Game_Grid.Point;
      Speed    : Speed_Value)
   is
   begin
      Self :=
        (Position    => Location,
         Speed       => Speed,
         AP          => 0,
         Oxygenation => 100,
         Hunger      => 40,
         Thirst      => 40,
         Fatigue     => 60,
         Sleeping    => False);
   end Initialize_Human;

   procedure Initialize_Robot
     (Self     : out Robot_Actor;
      Location : Game_Grid.Point;
      Speed    : Speed_Value)
   is
   begin
      Self :=
        (Position => Location,
         Speed    => Speed,
         AP       => 0,
         Power    => 100,
         Hull     => 100,
         Thermal  => 20);
   end Initialize_Robot;

   procedure Adjust_Action_Points
     (Self     : in out Human_Actor;
      Delta_AP : Integer)
   is
   begin
      Clamp_AP (Self.AP, Delta_AP);
   end Adjust_Action_Points;

   procedure Adjust_Action_Points
     (Self     : in out Robot_Actor;
      Delta_AP : Integer)
   is
   begin
      Clamp_AP (Self.AP, Delta_AP);
   end Adjust_Action_Points;

   procedure Adjust_Oxygenation
     (Self   : in out Human_Actor;
      Amount : Integer)
   is
   begin
      Self.Oxygenation :=
        Tissue_Oxygenation
          (Clamp_0_100 (Integer (Self.Oxygenation) + Amount));
   end Adjust_Oxygenation;

   procedure Adjust_Hunger
     (Self   : in out Human_Actor;
      Amount : Integer)
   is
   begin
      Self.Hunger :=
        Vital_Percent (Clamp_0_100 (Integer (Self.Hunger) + Amount));
   end Adjust_Hunger;

   procedure Adjust_Thirst
     (Self   : in out Human_Actor;
      Amount : Integer)
   is
   begin
      Self.Thirst :=
        Vital_Percent (Clamp_0_100 (Integer (Self.Thirst) + Amount));
   end Adjust_Thirst;

   procedure Adjust_Fatigue
     (Self   : in out Human_Actor;
      Amount : Integer)
   is
   begin
      Self.Fatigue :=
        Vital_Percent (Clamp_0_100 (Integer (Self.Fatigue) + Amount));
   end Adjust_Fatigue;

   procedure Breathe_In_Bunker
     (Self : in out Human_Actor;
      Room : Bunker_Room)
   is
      Shift : Integer := 0;
   begin
      --  Sealed small room: low O2 or high CO2 bleeds tissue oxygenation.
      if Room.O2_Percent < 16 then
         Shift := Shift - (16 - Integer (Room.O2_Percent));
      elsif Room.O2_Percent >= 20 then
         Shift := Shift + 1;  -- slow recovery in good air
      end if;
      if Room.CO2_Percent > 2 then
         Shift := Shift - Integer (Room.CO2_Percent);
      end if;
      if Room.Pressure_kPa < 70 then
         Shift := Shift - 5;
      end if;
      Adjust_Oxygenation (Self, Shift);
   end Breathe_In_Bunker;

   procedure Autopilot_Breathe
     (Self         : in out Human_Actor;
      O2_Percent   : Percent;
      CO2_Percent  : Percent;
      Pressure_kPa : Room_Pressure_kPa)
   is
      --  Effective O2 partial pressure (kPa) = P * O2% / 100.
      Partial : constant Natural :=
        (Natural (Pressure_kPa) * Natural (O2_Percent)) / 100;
      Shift   : Integer := 0;
   begin
      --  CO2 danger rises before O2 runs out (Physical_Data).
      if CO2_Percent > 2 then
         Shift := Shift - Integer (CO2_Percent);
      end if;

      if Partial < 16 then
         --  Hypoxia scales with how far below the safe band.
         Shift := Shift - (16 - Integer (Partial));
         if Partial <= 4 then
            --  Storm exterior ~4 kPa: severe, unsurvivable without cabin/suit.
            Shift := Shift - 10;
         end if;
      elsif O2_Percent >= 95 and then Pressure_kPa >= 25 then
         --  Sealed EVA pure-O2 loop (~29.6 kPa EMU): treat as safe supply.
         if CO2_Percent <= 2 then
            Shift := Shift + 1;
         end if;
      elsif Partial > 24 then
         Shift := Shift - (Integer (Partial) - 24);
      elsif CO2_Percent <= 2 then
         --  In 16..24 kPa Earth-air band with low CO2: slow recovery.
         Shift := Shift + 1;
      end if;

      Adjust_Oxygenation (Self, Shift);
   end Autopilot_Breathe;

   procedure Begin_Sleep (Self : in out Human_Actor) is
   begin
      Self.Sleeping := True;
   end Begin_Sleep;

   procedure Wake (Self : in out Human_Actor) is
   begin
      Self.Sleeping := False;
   end Wake;

   procedure Adjust_Power
     (Self   : in out Robot_Actor;
      Amount : Integer)
   is
   begin
      Self.Power :=
        Power_Percent (Clamp_0_100 (Integer (Self.Power) + Amount));
   end Adjust_Power;

   procedure Adjust_Hull
     (Self   : in out Robot_Actor;
      Amount : Integer)
   is
   begin
      Self.Hull :=
        Hull_Percent (Clamp_0_100 (Integer (Self.Hull) + Amount));
   end Adjust_Hull;

   procedure Set_Thermal
     (Self : in out Robot_Actor;
      Temp : Thermal_C)
   is
   begin
      Self.Thermal := Temp;
   end Set_Thermal;

   procedure Move_To
     (Self        : in out Human_Actor;
      Destination : Game_Grid.Point)
   is
   begin
      if Self.Sleeping then
         raise Asleep_Error;
      end if;
      if not Game_Grid.Are_Adjacent (Self.Position, Destination) then
         raise Invalid_Move;
      end if;
      Self.Position := Destination;
   end Move_To;

   procedure Move_To
     (Self        : in out Robot_Actor;
      Destination : Game_Grid.Point)
   is
   begin
      if not Game_Grid.Are_Adjacent (Self.Position, Destination) then
         raise Invalid_Move;
      end if;
      Self.Position := Destination;
   end Move_To;

end Game_Actors;
