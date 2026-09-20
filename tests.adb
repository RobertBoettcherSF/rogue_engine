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

with Ada.Text_IO;
with Game_Grid;

--  Growing standalone test suite and usage example for the rogue engine.
procedure Tests is
   package TIO renames Ada.Text_IO;
   package G renames Game_Grid;
   use type G.Coordinate;
   use type G.Terrain_Type;

   Failed : Natural := 0;
   Passed : Natural := 0;

   procedure Check (Condition : Boolean; Message : String) is
   begin
      pragma Assert (Condition, Message);
      if Condition then
         Passed := Passed + 1;
         TIO.Put_Line ("PASS: " & Message);
      else
         Failed := Failed + 1;
         TIO.Put_Line ("FAIL: " & Message);
      end if;
   end Check;

   A, B, C : G.Point;
   Map     : G.Chunk := [others => [others => G.Make_Tile (G.Dirt)]];
   T       : G.Tile;
begin
   TIO.Put_Line ("=== Game_Grid ===");

   --  Point / Make_Tile defaults
   A := (X => 0, Y => 0);
   B := (X => 3, Y => -4);
   Check (G.Make_Tile (G.Wall).Is_Passable = False, "Wall is impassable");
   Check (G.Make_Tile (G.Floor).Is_Passable = True, "Floor is passable");
   Check (G.Make_Tile (G.Door_Open).Is_Passable = True, "Open door is passable");
   Check
     (G.Make_Tile (G.Door_Closed).Is_Passable = False,
      "Closed door is impassable");
   Check (G.Make_Tile (G.Water).Is_Passable = False, "Water is impassable");

   --  Chebyshev distance
   Check (G.Chebyshev_Distance (A, A) = 0, "Distance to self is 0");
   Check
     (G.Chebyshev_Distance (A, B) = 4,
      "Chebyshev (0,0)->(3,-4) is 4");
   C := (X => 1, Y => 1);
   Check
     (G.Chebyshev_Distance (A, C) = 1,
      "Diagonal neighbor distance is 1");
   Check (G.Are_Adjacent (A, C), "Diagonal neighbors are adjacent");
   Check (not G.Are_Adjacent (A, B), "Distant points are not adjacent");

   --  Line of sight between adjacent points
   declare
      Wall_Tile : constant G.Tile := G.Make_Tile (G.Wall);
      Open_Door : constant G.Tile := G.Make_Tile (G.Door_Open);
      Closed    : constant G.Tile := G.Make_Tile (G.Door_Closed);
      Grass_T   : constant G.Tile := G.Make_Tile (G.Grass);
   begin
      Check
        (G.Blocks_Line_Of_Sight (A, C, Wall_Tile),
         "Wall blocks adjacent LOS");
      Check
        (not G.Blocks_Line_Of_Sight (A, C, Open_Door),
         "Open door does not block adjacent LOS");
      Check
        (G.Blocks_Line_Of_Sight (A, C, Closed),
         "Closed door blocks adjacent LOS");
      Check
        (not G.Blocks_Line_Of_Sight (A, C, Grass_T),
         "Grass does not block adjacent LOS");
   end;

   --  Chunk get/set
   T := G.Make_Tile (G.Floor);
   G.Set_Tile (Map, 1, 1, T);
   Check (G.Get_Tile (Map, 1, 1).Terrain = G.Floor, "Set/Get tile terrain");
   Check
     (G.Get_Tile (Map, 1, 1).Is_Passable,
      "Set/Get tile passable flag");
   Check
     (G.Get_Tile (Map, G.Chunk_Extent, G.Chunk_Extent).Terrain = G.Dirt,
      "Unset chunk cell keeps default Dirt");

   --  Expected exception: Pre failure when not adjacent (assertions on)
   declare
      Raised : Boolean := False;
   begin
      declare
         Dummy : Boolean;
      begin
         Dummy :=
           G.Blocks_Line_Of_Sight
             (A, B, G.Make_Tile (G.Wall));
         pragma Unreferenced (Dummy);
      exception
         when others =>
            Raised := True;
      end;
      Check (Raised, "Blocks_Line_Of_Sight rejects non-adjacent points");
   end;

   TIO.New_Line;
   TIO.Put_Line
     ("Summary: "
      & Natural'Image (Passed)
      & " passed,"
      & Natural'Image (Failed)
      & " failed");
   if Failed > 0 then
      raise Program_Error with "tests failed";
   end if;
end Tests;
