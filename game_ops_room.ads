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

with Game_Actors;

--  Small sealed bunker ops room (player habitat). Not a world chunk:
--  3x3 tiles at 1 m -> 9 m2. Every tile carries clear height (cm).
--  Suit hook hang height = 2000 mm (200 cm). Dual airlock doors on map.
package Game_Ops_Room is

   Tile_Edge_Cm : constant := 100;  -- 1 m tiles (Physical Data / playable scale)

   Room_Width  : constant := 3;   -- X
   Room_Depth  : constant := 3;   -- Y
   --  Floor area = 3 x 3 x 1 m2 = 9 m2

   subtype Width_Index is Positive range 1 .. Room_Width;
   subtype Depth_Index is Positive range 1 .. Room_Depth;

   --  Clear height from floor to ceiling obstruction on that cell (cm).
   subtype Height_Cm is Natural range 0 .. 1_000;
   Default_Clear_Height_Cm : constant Height_Cm := 220;
   --  DS SI: spacesuit hang height 2000 mm = 200 cm.
   Suit_Hook_Hang_Height_Cm : constant Height_Cm := 200;

   type Cell_Kind is
     (Wall,
      Floor,
      Console_Island,
      Operator_Seat,
      Airlock_Door,   -- inner (cabin-side)
      Outer_Door,     -- storm / surface side
      Suit_Hook);

   type Room_Cell is record
      Kind     : Cell_Kind := Floor;
      Passable : Boolean := True;
      Height   : Height_Cm := Default_Clear_Height_Cm;
   end record;

   type Room_Map is array (Width_Index, Depth_Index) of Room_Cell;

   type Ops_Room is record
      Cells               : Room_Map;
      Floor_Below_Surface : Positive := 4;
      Air                 : Game_Actors.Bunker_Room;
      Console_X           : Width_Index := 2;
      Console_Y           : Depth_Index := 2;
      Seat_X              : Width_Index := 2;
      Seat_Y              : Depth_Index := 3;
      Door_X              : Width_Index := 1;  -- inner
      Door_Y              : Depth_Index := 1;
      Outer_Door_X        : Width_Index := 3;
      Outer_Door_Y        : Depth_Index := 1;
      Suit_Hook_X         : Width_Index := 3;
      Suit_Hook_Y         : Depth_Index := 3;
      Suit_On_Hook        : Boolean := True;
   end record;

   function Floor_Area_M2 return Natural
   with
     Global => null,
     Post   => Floor_Area_M2'Result = Room_Width * Room_Depth;

   function Make_Default_Ops_Room return Ops_Room
   with Global => null;

   function Cell_At
     (Room : Ops_Room;
      X    : Width_Index;
      Y    : Depth_Index) return Room_Cell
   with Global => null;

   function Is_Passable
     (Room : Ops_Room;
      X    : Width_Index;
      Y    : Depth_Index) return Boolean
   with Global => null;

   function Has_Center_Console (Room : Ops_Room) return Boolean
   with Global => null;

end Game_Ops_Room;
