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

--  Backpack load, containers (cans/canisters), hull vs content mass, and
--  strict carry-weight rules.
--
--  Model:
--    Backpack.Total_Load = sum over slots of (Hull_Mass + Content_Mass)
--    Container holds Solid | Liquid | Gas | Plasma content
--    Hull_Integrity 0..100 (0 = ruptured)
--
--  Calibration: Comfortable_Capacity_G (S) = S * 1_000
--  (Strength 5 => 5 kg). Hard_Capacity_G = 2x (Strength 5 => 10 kg).
package Game_Items is

   subtype Mass_Grams is Natural range 0 .. 1_000_000;
   subtype Strength_Level is Positive range 1 .. 20;

   --  Hull structural health: 100 intact, 0 ruptured / useless seal.
   subtype Integrity_Percent is Natural range 0 .. 100;

   type Matter_State is (Solid, Liquid, Gas, Plasma);

   Max_Backpack_Slots : constant := 32;
   subtype Slot_Count is Natural range 0 .. Max_Backpack_Slots;
   subtype Slot_Index is Positive range 1 .. Max_Backpack_Slots;

   type Container is record
      Hull_Mass         : Mass_Grams     := 0;
      Integrity         : Integrity_Percent := 100;
      Content_State     : Matter_State   := Solid;
      Content_Mass      : Mass_Grams     := 0;
      Content_Capacity  : Mass_Grams     := 0;
   end record;

   type Container_Array is array (Slot_Index) of Container;

   --  Worn / carried pack: total load is sum of container masses.
   type Backpack is record
      Slots : Container_Array :=
        [others =>
           (Hull_Mass        => 0,
            Integrity        => 100,
            Content_State    => Solid,
            Content_Mass     => 0,
            Content_Capacity => 0)];
      Count : Slot_Count := 0;
   end record;

   Backpack_Full_Error      : exception;
   Backpack_Empty_Error     : exception;
   Carry_Limit_Exceeded     : exception;
   Content_Capacity_Error   : exception;
   Hull_Ruptured_Error      : exception;

   function Comfortable_Capacity_G
     (Strength : Strength_Level) return Mass_Grams
   with
     Global => null,
     Post   =>
       Comfortable_Capacity_G'Result = Mass_Grams (Strength) * 1_000;

   function Hard_Capacity_G
     (Strength : Strength_Level) return Mass_Grams
   with
     Global => null,
     Post   =>
       Hard_Capacity_G'Result = Comfortable_Capacity_G (Strength) * 2;

   --  Container mass = hull weight + content weight.
   function Container_Mass (C : Container) return Mass_Grams
   with
     Global => null,
     Post   => Container_Mass'Result = C.Hull_Mass + C.Content_Mass;

   --  Backpack total load (what Strength checks against).
   function Total_Load (Pack : Backpack) return Mass_Grams
   with Global => null;

   function Is_Over_Encumbered
     (Pack     : Backpack;
      Strength : Strength_Level) return Boolean
   with
     Global => null,
     Post   =>
       Is_Over_Encumbered'Result =
         (Total_Load (Pack) > Comfortable_Capacity_G (Strength));

   function Over_Encumbrance_AP_Penalty
     (Pack     : Backpack;
      Strength : Strength_Level) return Natural
   with
     Global => null,
     Post   =>
       (if Is_Over_Encumbered (Pack, Strength) then
          Over_Encumbrance_AP_Penalty'Result = 2
        else
          Over_Encumbrance_AP_Penalty'Result = 0);

   function Is_Hull_Intact (C : Container) return Boolean
   with
     Global => null,
     Post   => Is_Hull_Intact'Result = (C.Integrity > 0);

   --  Empty backpack.
   procedure Clear (Pack : out Backpack)
   with
     Global => null,
     Post   => Pack.Count = 0 and then Total_Load (Pack) = 0;

   --  Build a filled container; Content_Mass must fit Content_Capacity.
   function Make_Container
     (Hull_Mass        : Mass_Grams;
      Integrity        : Integrity_Percent;
      Content_State    : Matter_State;
      Content_Mass     : Mass_Grams;
      Content_Capacity : Mass_Grams) return Container
   with
     Global => null,
     Pre    =>
       Content_Mass <= Content_Capacity
       and then Hull_Mass + Content_Mass <= Mass_Grams'Last,
     Post   =>
       Make_Container'Result.Hull_Mass = Hull_Mass
       and then Make_Container'Result.Content_Mass = Content_Mass
       and then Make_Container'Result.Content_State = Content_State;

   --  Place container in backpack if slot free and hard carry allows.
   procedure Add_Container
     (Pack     : in out Backpack;
      Item     : Container;
      Strength : Strength_Level)
   with
     Global => null,
     Pre    => Container_Mass (Item) > 0,
     Post   => Pack.Count = Pack.Count'Old + 1;

   procedure Remove_Last (Pack : in out Backpack)
   with
     Global => null,
     Post   => Pack.Count = Pack.Count'Old - 1;

   --  Damage hull; Integrity 0 means ruptured (seal lost).
   procedure Damage_Hull
     (C      : in out Container;
      Amount : Integrity_Percent)
   with Global => null;

end Game_Items;
