--  SPDX-License-Identifier: MIT
--  Copyright (c) 2026 Robert Boettcher

pragma Ada_2022;

package body Game_Ops_Room is

   function Floor_Area_M2 return Natural is
   begin
      return Room_Width * Room_Depth;
   end Floor_Area_M2;

   function Make_Default_Ops_Room return Ops_Room is
      R : Ops_Room;
   begin
      --  3x3 open deck (no perimeter wall ring - every tile is playable area).
      for X in Width_Index loop
         for Y in Depth_Index loop
            R.Cells (X, Y) :=
              (Kind => Floor, Passable => True, Height => Default_Clear_Height_Cm);
         end loop;
      end loop;

      --  North row: inner door (cabin) west, chamber floor, outer door east.
      R.Door_X := 1;
      R.Door_Y := 1;
      R.Cells (R.Door_X, R.Door_Y) :=
        (Kind => Airlock_Door, Passable => False, Height => Default_Clear_Height_Cm);

      R.Outer_Door_X := 3;
      R.Outer_Door_Y := 1;
      R.Cells (R.Outer_Door_X, R.Outer_Door_Y) :=
        (Kind => Outer_Door, Passable => False, Height => Default_Clear_Height_Cm);

      --  Center console island (impassable).
      R.Console_X := 2;
      R.Console_Y := 2;
      R.Cells (R.Console_X, R.Console_Y) :=
        (Kind => Console_Island, Passable => False, Height => 180);

      --  Operator seat south of console.
      R.Seat_X := 2;
      R.Seat_Y := 3;
      R.Cells (R.Seat_X, R.Seat_Y) :=
        (Kind => Operator_Seat, Passable => True, Height => Default_Clear_Height_Cm);

      --  Spacesuit on hook ~2000 mm (200 cm) hang height.
      R.Suit_Hook_X := 3;
      R.Suit_Hook_Y := 3;
      R.Suit_On_Hook := True;
      R.Cells (R.Suit_Hook_X, R.Suit_Hook_Y) :=
        (Kind => Suit_Hook, Passable => True, Height => Suit_Hook_Hang_Height_Cm);

      R.Floor_Below_Surface := 4;
      --  9 m2 x 2.2 m ~ 19.8 m3 -> 20_000 L
      R.Air :=
        (O2_Percent    => 21,
         CO2_Percent   => 0,
         Pressure_kPa  => 101,
         Volume_Liters => 20_000);

      return R;
   end Make_Default_Ops_Room;

   function Cell_At
     (Room : Ops_Room;
      X    : Width_Index;
      Y    : Depth_Index) return Room_Cell
   is
   begin
      return Room.Cells (X, Y);
   end Cell_At;

   function Is_Passable
     (Room : Ops_Room;
      X    : Width_Index;
      Y    : Depth_Index) return Boolean
   is
   begin
      return Room.Cells (X, Y).Passable;
   end Is_Passable;

   function Has_Center_Console (Room : Ops_Room) return Boolean is
   begin
      return Room.Cells (Room.Console_X, Room.Console_Y).Kind = Console_Island;
   end Has_Center_Console;

end Game_Ops_Room;
