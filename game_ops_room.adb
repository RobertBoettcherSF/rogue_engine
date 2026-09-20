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
      --  Perimeter walls; 3×3 only center is non-edge initially
      for X in Width_Index loop
         for Y in Depth_Index loop
            if X = Width_Index'First
              or else X = Width_Index'Last
              or else Y = Depth_Index'First
              or else Y = Depth_Index'Last
            then
               R.Cells (X, Y) :=
                 (Kind => Wall, Passable => False, Height => Default_Clear_Height_Cm);
            else
               R.Cells (X, Y) :=
                 (Kind => Floor, Passable => True, Height => Default_Clear_Height_Cm);
            end if;
         end loop;
      end loop;

      --  North-center airlock door (replace wall)
      R.Door_X := 2;
      R.Door_Y := 1;
      R.Cells (R.Door_X, R.Door_Y) :=
        (Kind => Airlock_Door, Passable => True, Height => Default_Clear_Height_Cm);

      --  Center console island
      R.Console_X := 2;
      R.Console_Y := 2;
      R.Cells (R.Console_X, R.Console_Y) :=
        (Kind => Console_Island, Passable => False, Height => 180);

      --  Operator seat south of console (south mid-wall cell)
      R.Seat_X := 2;
      R.Seat_Y := 3;
      R.Cells (R.Seat_X, R.Seat_Y) :=
        (Kind => Operator_Seat, Passable => True, Height => Default_Clear_Height_Cm);

      --  Side mid walkways so seat can route around impassable console
      --  Layout (Y high→low / print top→bottom): #h# / .=. / #+#
      R.Cells (1, 2) :=
        (Kind => Floor, Passable => True, Height => Default_Clear_Height_Cm);
      R.Cells (3, 2) :=
        (Kind => Floor, Passable => True, Height => Default_Clear_Height_Cm);

      R.Floor_Below_Surface := 4;
      --  ~9 m² × 2.2 m ≈ 20 m³
      R.Air :=
        (O2_Percent   => 21,
         CO2_Percent  => 0,
         Pressure_kPa => 101,
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
