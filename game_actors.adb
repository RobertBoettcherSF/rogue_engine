--  SPDX-License-Identifier: MIT
--  Copyright (c) 2026 Robert Boettcher
--
--  Permission is hereby granted, free of charge, to any person obtaining a copy
--  of this software and associated documentation files (the "Software"), to deal
--  in the Software without restriction, including without limitation the rights
--  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--  copies of the Software, and to permit persons to whom the Software is
--  furnished to do so, subject to the following conditions:
--
--  The above copyright notice and this permission notice shall be included in
--  all copies or substantial portions of the Software.
--
--  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--  SOFTWARE.

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
         Oxygenation => 100);
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
