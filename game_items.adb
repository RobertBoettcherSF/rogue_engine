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

package body Game_Items is

   function Comfortable_Capacity_G
     (Strength : Strength_Level) return Mass_Grams
   is
   begin
      return Mass_Grams (Strength) * 1_000;
   end Comfortable_Capacity_G;

   function Hard_Capacity_G
     (Strength : Strength_Level) return Mass_Grams
   is
   begin
      return Comfortable_Capacity_G (Strength) * 2;
   end Hard_Capacity_G;

   function Container_Mass (C : Container) return Mass_Grams is
   begin
      return C.Hull_Mass + C.Content_Mass;
   end Container_Mass;

   function Total_Load (Pack : Backpack) return Mass_Grams is
      Sum : Mass_Grams := 0;
   begin
      for I in 1 .. Pack.Count loop
         Sum := Sum + Container_Mass (Pack.Slots (I));
      end loop;
      return Sum;
   end Total_Load;

   function Is_Over_Encumbered
     (Pack     : Backpack;
      Strength : Strength_Level) return Boolean
   is
   begin
      return Total_Load (Pack) > Comfortable_Capacity_G (Strength);
   end Is_Over_Encumbered;

   function Over_Encumbrance_AP_Penalty
     (Pack     : Backpack;
      Strength : Strength_Level) return Natural
   is
   begin
      if Is_Over_Encumbered (Pack, Strength) then
         return 2;
      else
         return 0;
      end if;
   end Over_Encumbrance_AP_Penalty;

   function Is_Hull_Intact (C : Container) return Boolean is
   begin
      return C.Integrity > 0;
   end Is_Hull_Intact;

   procedure Clear (Pack : out Backpack) is
   begin
      Pack :=
        (Slots =>
           [others =>
              (Hull_Mass        => 0,
               Integrity        => 100,
               Content_State    => Solid,
               Content_Mass     => 0,
               Content_Capacity => 0)],
         Count => 0);
   end Clear;

   function Make_Container
     (Hull_Mass        : Mass_Grams;
      Integrity        : Integrity_Percent;
      Content_State    : Matter_State;
      Content_Mass     : Mass_Grams;
      Content_Capacity : Mass_Grams) return Container
   is
   begin
      if Content_Mass > Content_Capacity then
         raise Content_Capacity_Error;
      end if;
      return
        (Hull_Mass        => Hull_Mass,
         Integrity        => Integrity,
         Content_State    => Content_State,
         Content_Mass     => Content_Mass,
         Content_Capacity => Content_Capacity);
   end Make_Container;

   procedure Add_Container
     (Pack     : in out Backpack;
      Item     : Container;
      Strength : Strength_Level)
   is
      New_Total : Mass_Grams;
   begin
      if Pack.Count = Max_Backpack_Slots then
         raise Backpack_Full_Error;
      end if;

      New_Total := Total_Load (Pack) + Container_Mass (Item);
      if New_Total > Hard_Capacity_G (Strength) then
         raise Carry_Limit_Exceeded;
      end if;

      Pack.Count := Pack.Count + 1;
      Pack.Slots (Pack.Count) := Item;
   end Add_Container;

   procedure Remove_Last (Pack : in out Backpack) is
   begin
      if Pack.Count = 0 then
         raise Backpack_Empty_Error;
      end if;
      Pack.Slots (Pack.Count) :=
        (Hull_Mass        => 0,
         Integrity        => 100,
         Content_State    => Solid,
         Content_Mass     => 0,
         Content_Capacity => 0);
      Pack.Count := Pack.Count - 1;
   end Remove_Last;

   procedure Damage_Hull
     (C      : in out Container;
      Amount : Integrity_Percent)
   is
   begin
      if Amount >= C.Integrity then
         C.Integrity := 0;
      else
         C.Integrity := C.Integrity - Amount;
      end if;
   end Damage_Hull;

end Game_Items;
