--  SPDX-License-Identifier: MIT
--  Copyright (c) 2026 Robert Boettcher

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
               Hull_Temp_C      => 20,
               Content_State    => Solid,
               Content_Mass     => 0,
               Content_Capacity => 0,
               Content_Temp_C   => 20)],
         Count => 0);
   end Clear;

   function Make_Container
     (Hull_Mass        : Mass_Grams;
      Integrity        : Integrity_Percent;
      Hull_Temp_C      : Celsius_Degrees;
      Content_State    : Matter_State;
      Content_Mass     : Mass_Grams;
      Content_Capacity : Mass_Grams;
      Content_Temp_C   : Celsius_Degrees) return Container
   is
   begin
      if Content_Mass > Content_Capacity then
         raise Content_Capacity_Error;
      end if;
      return
        (Hull_Mass        => Hull_Mass,
         Integrity        => Integrity,
         Hull_Temp_C      => Hull_Temp_C,
         Content_State    => Content_State,
         Content_Mass     => Content_Mass,
         Content_Capacity => Content_Capacity,
         Content_Temp_C   => Content_Temp_C);
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
         Hull_Temp_C      => 20,
         Content_State    => Solid,
         Content_Mass     => 0,
         Content_Capacity => 0,
         Content_Temp_C   => 20);
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

      --  Plasma vent: heat spike + (caller uses Check_Containment for game over).
      if Is_Plasma_Catastrophe (C) then
         Apply_Plasma_Breach (C);
      end if;
   end Damage_Hull;

   procedure Set_Temperatures
     (C              : in out Container;
      Hull_Temp_C    : Celsius_Degrees;
      Content_Temp_C : Celsius_Degrees)
   is
   begin
      C.Hull_Temp_C := Hull_Temp_C;
      C.Content_Temp_C := Content_Temp_C;
   end Set_Temperatures;

   function Is_Too_Hot_To_Handle (C : Container) return Boolean is
   begin
      return C.Hull_Temp_C > Max_Safe_Hull_C;
   end Is_Too_Hot_To_Handle;

   function Can_Access_Content (C : Container) return Boolean is
   begin
      return C.Integrity > 0
        and then C.Integrity <= Access_Integrity_Threshold;
   end Can_Access_Content;

   function Access_Content_Mass (C : Container) return Mass_Grams is
   begin
      if C.Integrity = 0 then
         if C.Content_State = Plasma and then C.Content_Mass > 0 then
            raise Plasma_Containment_Lost;
         end if;
         raise Hull_Ruptured_Error;
      end if;
      if not Can_Access_Content (C) then
         raise Content_Sealed_Error;
      end if;
      return C.Content_Mass;
   end Access_Content_Mass;

   function Is_Plasma_Catastrophe (C : Container) return Boolean is
   begin
      return C.Content_State = Plasma
        and then C.Content_Mass > 0
        and then C.Integrity = 0;
   end Is_Plasma_Catastrophe;

   function Plasma_Leak_Effects (C : Container) return Leak_Effects is
      pragma Unreferenced (C);
   begin
      return
        (Burn         => True,
         Electrocute  => True,
         Heat_Spike_C => Plasma_Breach_Heat_C);
   end Plasma_Leak_Effects;

   procedure Apply_Plasma_Breach (C : in out Container) is
   begin
      C.Hull_Temp_C := Plasma_Breach_Heat_C;
      C.Content_Temp_C := Plasma_Breach_Heat_C;
   end Apply_Plasma_Breach;

   procedure Check_Containment (C : Container) is
   begin
      if Is_Plasma_Catastrophe (C) then
         raise Plasma_Containment_Lost;
      end if;
   end Check_Containment;

   procedure Open_With_Can_Opener (C : in out Container) is
   begin
      if C.Integrity = 0 then
         raise Hull_Ruptured_Error;
      end if;
      if Can_Access_Content (C) then
         raise Already_Open_Error;
      end if;
      --  Controlled lid cut: stop at access threshold (never auto-rupture).
      C.Integrity := Access_Integrity_Threshold;
   end Open_With_Can_Opener;

   procedure Drill_Sample
     (C          : in out Container;
      Requested  : Mass_Grams;
      Out_Sample : out Sample)
   is
      Taken : Mass_Grams;
   begin
      if C.Content_State /= Solid then
         raise Wrong_Matter_State_Error;
      end if;
      if C.Content_Mass = 0 then
         raise Sample_Empty_Error;
      end if;
      if C.Integrity = 0 then
         if Is_Plasma_Catastrophe (C) then
            raise Plasma_Containment_Lost;
         end if;
         raise Hull_Ruptured_Error;
      end if;

      --  Pierce sealed hull like a rover drill collar.
      if not Can_Access_Content (C) then
         C.Integrity := Access_Integrity_Threshold;
      end if;

      if Requested >= C.Content_Mass then
         Taken := C.Content_Mass;
      else
         Taken := Requested;
      end if;

      Out_Sample :=
        (Mass    => Taken,
         State   => Solid,
         Temp_C  => C.Content_Temp_C,
         Refined => False);
      C.Content_Mass := C.Content_Mass - Taken;
   end Drill_Sample;

   procedure Process_Sample (S : in out Sample) is
   begin
      if S.Mass = 0 then
         raise Sample_Empty_Error;
      end if;
      S.Refined := True;
   end Process_Sample;

   procedure Consume_Matter
     (C           : in out Container;
      Expected    : Matter_State;
      Grams       : Mass_Grams;
      Taken       : out Mass_Grams)
   is
   begin
      if C.Content_State /= Expected then
         raise Wrong_Matter_State_Error;
      end if;
      if C.Integrity = 0 then
         if Is_Plasma_Catastrophe (C) then
            raise Plasma_Containment_Lost;
         end if;
         raise Hull_Ruptured_Error;
      end if;
      if not Can_Access_Content (C) then
         raise Content_Sealed_Error;
      end if;
      if C.Content_Mass = 0 then
         raise Sample_Empty_Error;
      end if;

      if Grams >= C.Content_Mass then
         Taken := C.Content_Mass;
      else
         Taken := Grams;
      end if;
      C.Content_Mass := C.Content_Mass - Taken;
   end Consume_Matter;

   procedure Bite
     (C      : in out Container;
      Grams  : Mass_Grams := Default_Bite_Grams;
      Taken  : out Mass_Grams)
   is
   begin
      Consume_Matter (C, Solid, Grams, Taken);
   end Bite;

   procedure Sip
     (C      : in out Container;
      Grams  : Mass_Grams := Default_Sip_Grams;
      Taken  : out Mass_Grams)
   is
   begin
      Consume_Matter (C, Liquid, Grams, Taken);
   end Sip;

end Game_Items;
