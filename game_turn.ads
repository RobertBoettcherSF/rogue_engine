--  SPDX-License-Identifier: MIT
--  Copyright (c) 2026 Robert Boettcher

pragma Ada_2022;

with Game_Actors;

--  Simple turn / wall-minute clock for Demo walk + sleep time advance.
package Game_Turn is

   subtype Turn_Number is Natural;
   subtype Wall_Minutes is Natural;

   Default_AP_Grant : constant Game_Actors.Action_Points := 8;
   Walk_AP_Cost     : constant Positive := 1;

   type Clock is record
      Turn    : Turn_Number := 0;
      Minutes : Wall_Minutes := 0;
   end record;

   --  Advance one turn: +1 turn, +1 wall minute, grant AP (clamped).
   procedure Advance_Turn
     (C     : in out Clock;
      Human : in out Game_Actors.Human_Actor;
      Grant : Game_Actors.Action_Points := Default_AP_Grant)
   with Global => null;

   --  Advance wall time without a fresh AP grant (sleep ticks).
   procedure Advance_Minutes
     (C       : in out Clock;
      Minutes : Positive)
   with
     Global => null,
     Post   => C.Minutes = C.Minutes'Old + Minutes;

end Game_Turn;
