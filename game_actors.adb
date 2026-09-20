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

package body Game_Actors is

   procedure Initialize
     (Self     : out Actor;
      Location : Game_Grid.Point;
      Speed    : Speed_Value)
   is
   begin
      Self :=
        (Position => Location,
         Speed    => Speed,
         AP       => 0,
         Health   => Healthy);
   end Initialize;

   procedure Adjust_Action_Points
     (Self     : in out Actor;
      Delta_AP : Integer)
   is
      Raw : constant Long_Long_Integer :=
        Long_Long_Integer (Self.AP) + Long_Long_Integer (Delta_AP);
      Lo  : constant Long_Long_Integer :=
        Long_Long_Integer (Action_Points'First);
      Hi  : constant Long_Long_Integer :=
        Long_Long_Integer (Action_Points'Last);
   begin
      if Raw < Lo then
         Self.AP := Action_Points'First;
      elsif Raw > Hi then
         Self.AP := Action_Points'Last;
      else
         Self.AP := Action_Points (Raw);
      end if;
   end Adjust_Action_Points;

   procedure Move_To
     (Self        : in out Actor;
      Destination : Game_Grid.Point)
   is
   begin
      if not Game_Grid.Are_Adjacent (Self.Position, Destination) then
         raise Invalid_Move;
      end if;
      Self.Position := Destination;
   end Move_To;

end Game_Actors;
