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
with Game_Actors;
with Game_Grid;

--  Growing standalone test suite and usage example for the rogue engine.
procedure Tests is
   package TIO renames Ada.Text_IO;
   package G renames Game_Grid;
   package A renames Game_Actors;
   use type G.Coordinate;
   use type G.Terrain_Type;
   use type A.Health_Status;

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

   A_Pt, B_Pt, C_Pt : G.Point;
   Map              : G.Chunk :=
     [others => [others => G.Make_Tile (G.Dirt)]];
   T                : G.Tile;

   Hero             : A.Actor;
   Dest             : G.Point;
begin
   TIO.Put_Line ("=== Game_Grid ===");

   --  Point / Make_Tile defaults
   A_Pt := (X => 0, Y => 0);
   B_Pt := (X => 3, Y => -4);
   Check (G.Make_Tile (G.Wall).Is_Passable = False, "Wall is impassable");
   Check (G.Make_Tile (G.Floor).Is_Passable = True, "Floor is passable");
   Check (G.Make_Tile (G.Door_Open).Is_Passable = True, "Open door is passable");
   Check
     (G.Make_Tile (G.Door_Closed).Is_Passable = False,
      "Closed door is impassable");
   Check (G.Make_Tile (G.Water).Is_Passable = False, "Water is impassable");

   --  Chebyshev distance
   Check (G.Chebyshev_Distance (A_Pt, A_Pt) = 0, "Distance to self is 0");
   Check
     (G.Chebyshev_Distance (A_Pt, B_Pt) = 4,
      "Chebyshev (0,0)->(3,-4) is 4");
   C_Pt := (X => 1, Y => 1);
   Check
     (G.Chebyshev_Distance (A_Pt, C_Pt) = 1,
      "Diagonal neighbor distance is 1");
   Check (G.Are_Adjacent (A_Pt, C_Pt), "Diagonal neighbors are adjacent");
   Check (not G.Are_Adjacent (A_Pt, B_Pt), "Distant points are not adjacent");

   --  Line of sight between adjacent points
   declare
      Wall_Tile : constant G.Tile := G.Make_Tile (G.Wall);
      Open_Door : constant G.Tile := G.Make_Tile (G.Door_Open);
      Closed    : constant G.Tile := G.Make_Tile (G.Door_Closed);
      Grass_T   : constant G.Tile := G.Make_Tile (G.Grass);
   begin
      Check
        (G.Blocks_Line_Of_Sight (A_Pt, C_Pt, Wall_Tile),
         "Wall blocks adjacent LOS");
      Check
        (not G.Blocks_Line_Of_Sight (A_Pt, C_Pt, Open_Door),
         "Open door does not block adjacent LOS");
      Check
        (G.Blocks_Line_Of_Sight (A_Pt, C_Pt, Closed),
         "Closed door blocks adjacent LOS");
      Check
        (not G.Blocks_Line_Of_Sight (A_Pt, C_Pt, Grass_T),
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
             (A_Pt, B_Pt, G.Make_Tile (G.Wall));
         pragma Unreferenced (Dummy);
      exception
         when others =>
            Raised := True;
      end;
      Check (Raised, "Blocks_Line_Of_Sight rejects non-adjacent points");
   end;

   TIO.New_Line;
   TIO.Put_Line ("=== Game_Actors ===");

   --  1. Initialization
   A.Initialize (Hero, Location => (X => 5, Y => 7), Speed => 10);
   Check (Hero.Position.X = 5 and then Hero.Position.Y = 7,
          "Initialize sets position");
   Check (Hero.Speed = 10, "Initialize sets speed");
   Check (Hero.AP = 0, "Initialize zeros action points");
   Check (Hero.Health = A.Healthy, "Initialize health is Healthy");

   --  2. Action-point arithmetic (add / deduct)
   A.Adjust_Action_Points (Hero, 250);
   Check (Hero.AP = 250, "Adjust adds action points");
   A.Adjust_Action_Points (Hero, -100);
   Check (Hero.AP = 150, "Adjust deducts action points");

   --  3. AP clamping at both ends of the range
   A.Adjust_Action_Points (Hero, 10_000);
   Check (Hero.AP = A.Action_Points'Last, "Adjust clamps to AP max");
   A.Adjust_Action_Points (Hero, -50_000);
   Check (Hero.AP = A.Action_Points'First, "Adjust clamps to AP min");

   --  4. Valid adjacent move (orthogonal and diagonal)
   A.Initialize (Hero, Location => (X => 0, Y => 0), Speed => 5);
   Dest := (X => 1, Y => 0);
   A.Move_To (Hero, Dest);
   Check
     (Hero.Position.X = 1 and then Hero.Position.Y = 0,
      "Move_To accepts orthogonal neighbor");
   Dest := (X => 2, Y => 1);
   A.Move_To (Hero, Dest);
   Check
     (Hero.Position.X = 2 and then Hero.Position.Y = 1,
      "Move_To accepts diagonal neighbor");

   --  5. Invalid move (distance /= 1) raises Invalid_Move
   declare
      Raised : Boolean := False;
   begin
      begin
         A.Move_To (Hero, Destination => (X => 5, Y => 5));
      exception
         when A.Invalid_Move =>
            Raised := True;
      end;
      Check (Raised, "Move_To rejects non-adjacent destination");
      Check
        (Hero.Position.X = 2 and then Hero.Position.Y = 1,
         "Failed Move_To leaves position unchanged");
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
