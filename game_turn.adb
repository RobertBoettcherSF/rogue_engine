--  SPDX-License-Identifier: MIT
--  Copyright (c) 2026 Robert Boettcher

pragma Ada_2022;

package body Game_Turn is

   procedure Advance_Turn
     (C     : in out Clock;
      Human : in out Game_Actors.Human_Actor;
      Grant : Game_Actors.Action_Points := Default_AP_Grant)
   is
   begin
      C.Turn := C.Turn + 1;
      C.Minutes := C.Minutes + 1;
      Game_Actors.Adjust_Action_Points (Human, Integer (Grant));
   end Advance_Turn;

   procedure Advance_Minutes
     (C       : in out Clock;
      Minutes : Positive)
   is
   begin
      C.Minutes := C.Minutes + Minutes;
   end Advance_Minutes;

end Game_Turn;
