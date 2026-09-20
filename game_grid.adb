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

package body Game_Grid is

   function Default_Passable (Terrain : Terrain_Type) return Boolean is
   begin
      case Terrain is
         when Wall | Door_Closed | Water =>
            return False;
         when Dirt | Grass | Floor | Door_Open =>
            return True;
      end case;
   end Default_Passable;

   function Make_Tile (Terrain : Terrain_Type) return Tile is
   begin
      return (Terrain => Terrain, Is_Passable => Default_Passable (Terrain));
   end Make_Tile;

   function Chebyshev_Distance (A, B : Point) return Distance_Value is
      DX : constant Natural := abs (Integer (A.X) - Integer (B.X));
      DY : constant Natural := abs (Integer (A.Y) - Integer (B.Y));
   begin
      return Distance_Value (Natural'Max (DX, DY));
   end Chebyshev_Distance;

   function Are_Adjacent (A, B : Point) return Boolean is
   begin
      return Chebyshev_Distance (A, B) = 1;
   end Are_Adjacent;

   function Blocks_Line_Of_Sight
     (From, To : Point; Destination : Tile) return Boolean
   is
      pragma Unreferenced (From, To);
   begin
      --  Adjacency is enforced by Pre. Blocking depends on destination terrain.
      case Destination.Terrain is
         when Wall | Door_Closed =>
            return True;
         when Dirt | Grass | Floor | Water | Door_Open =>
            return False;
      end case;
   end Blocks_Line_Of_Sight;

   function Get_Tile
     (Map : Chunk; X, Y : Chunk_Index) return Tile is
   begin
      return Map (X, Y);
   end Get_Tile;

   procedure Set_Tile
     (Map : in out Chunk; X, Y : Chunk_Index; Value : Tile)
   is
   begin
      Map (X, Y) := Value;
   end Set_Tile;

end Game_Grid;
