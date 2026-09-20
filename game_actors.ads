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

with Game_Grid;

--  Entity / creature actors placed on the Game_Grid.
package Game_Actors is
   use type Game_Grid.Point;


   --  Turn-scheduling energy. Clamped on every adjustment.
   subtype Action_Points is Integer range -1_000 .. 1_000;

   type Health_Status is (Healthy, Wounded, Critical, Dead);

   --  Positive base speed used by the turn scheduler (higher = acts more often).
   subtype Speed_Value is Positive;

   type Actor is tagged record
      Position : Game_Grid.Point := (X => 0, Y => 0);
      Speed    : Speed_Value     := 1;
      AP       : Action_Points   := 0;
      Health   : Health_Status   := Healthy;
   end record;

   Invalid_Move : exception;

   procedure Initialize
     (Self     : out Actor;
      Location : Game_Grid.Point;
      Speed    : Speed_Value)
     with
       Global => null,
       Post   =>
         Self.Position = Location
         and then Self.Speed = Speed
         and then Self.AP = 0
         and then Self.Health = Healthy;

   --  Add Delta_AP to Self.AP, clamping into Action_Points'Range.
   procedure Adjust_Action_Points
     (Self     : in out Actor;
      Delta_AP : Integer)
     with Global => null;

   --  Raises Invalid_Move when Destination is not Chebyshev-adjacent
   --  (Chebyshev distance must be exactly 1).
   procedure Move_To
     (Self        : in out Actor;
      Destination : Game_Grid.Point)
     with
       Global => null,
       Post   =>
         (if Game_Grid.Are_Adjacent (Self'Old.Position, Destination) then
            Self.Position = Destination);

end Game_Actors;
