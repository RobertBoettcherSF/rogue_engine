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

--  Core 2D map grid types and geometry for the rogue engine.
package Game_Grid is
   --  World / chunk coordinate axis. Bounded to keep distance math overflow-safe.
   type Coordinate is range -10_000 .. 10_000;

   type Point is record
      X : Coordinate := 0;
      Y : Coordinate := 0;
   end record;

   type Terrain_Type is
     (Dirt,
      Grass,
      Wall,
      Floor,
      Water,
      Door_Closed,
      Door_Open);

   type Tile is record
      Terrain     : Terrain_Type := Dirt;
      Is_Passable : Boolean      := True;
   end record;

   Chunk_Extent : constant := 24;
   subtype Chunk_Index is Positive range 1 .. Chunk_Extent;

   type Chunk is array (Chunk_Index, Chunk_Index) of Tile;

   --  Maximum Chebyshev distance between any two Points in Coordinate'Range.
   subtype Distance_Value is Natural range 0 .. 20_000;

   function Default_Passable (Terrain : Terrain_Type) return Boolean
     with Inline;

   function Make_Tile (Terrain : Terrain_Type) return Tile
     with Post =>
       Make_Tile'Result.Terrain = Terrain
       and then Make_Tile'Result.Is_Passable = Default_Passable (Terrain);

   function Chebyshev_Distance (A, B : Point) return Distance_Value
     with Post =>
       Chebyshev_Distance'Result
       = Distance_Value
           (Natural'Max
              (abs (Integer (A.X) - Integer (B.X)),
               abs (Integer (A.Y) - Integer (B.Y))));

   function Are_Adjacent (A, B : Point) return Boolean
     with Post => Are_Adjacent'Result = (Chebyshev_Distance (A, B) = 1);

   --  True when the destination tile blocks line of sight for an adjacent step.
   --  Walls and closed doors block; open doors and open terrain do not.
   function Blocks_Line_Of_Sight
     (From, To : Point; Destination : Tile) return Boolean
     with Pre => Are_Adjacent (From, To);

   function Get_Tile
     (Map : Chunk; X, Y : Chunk_Index) return Tile
     with Inline;

   procedure Set_Tile
     (Map : in out Chunk; X, Y : Chunk_Index; Value : Tile)
     with Post => Get_Tile (Map, X, Y) = Value;

   Out_Of_Bounds : exception;

end Game_Grid;
