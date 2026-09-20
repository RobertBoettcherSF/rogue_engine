--  SPDX-License-Identifier: MIT
--  Copyright (c) 2026 Robert Boettcher

pragma Ada_2022;

--  Backpack load, containers (cans/canisters), hull vs content mass, and
--  strict carry-weight rules.
--
--  Model:
--    Backpack.Total_Load = sum over slots of (Hull_Mass + Content_Mass)
--    Container holds Solid | Liquid | Gas | Plasma content
--    Hull integrity 0..100 (0 = ruptured)
--    Hull_Temp_C and Content_Temp_C in Celsius (rover-grade telemetry)
--
--  Calibration: Comfortable_Capacity_G (S) = S * 1_000
--  (Strength 5 => 5 kg). Hard_Capacity_G = 2x (Strength 5 => 10 kg).
--  SPARK: FUTURE climb — L2–L4 candidate if containment/plasma life-critical. Ada-only this phase; no gnatprove required.
package Game_Items is

   subtype Mass_Grams is Natural range 0 .. 1_000_000;
   subtype Strength_Level is Positive range 1 .. 20;

   --  Hull structural health: 100 intact, 0 ruptured / useless seal.
   subtype Integrity_Percent is Natural range 0 .. 100;

   --  Celsius; floor at absolute zero, ceiling for plasma / industrial heat.
   subtype Celsius_Degrees is Integer range -273 .. 10_000;

   --  Bare-hand safe band for hull contact (fun, not a physics lecture).
   Max_Safe_Hull_C : constant Celsius_Degrees := 60;

   --  Hull must be at or below this integrity before content can be accessed
   --  (opening / breaching the seal). 100 = fully sealed, inaccessible.
   Access_Integrity_Threshold : constant Integrity_Percent := 50;

   type Matter_State is (Solid, Liquid, Gas, Plasma);

   Max_Backpack_Slots : constant := 32;
   subtype Slot_Count is Natural range 0 .. Max_Backpack_Slots;
   subtype Slot_Index is Positive range 1 .. Max_Backpack_Slots;

   type Container is record
      Hull_Mass         : Mass_Grams        := 0;
      Integrity         : Integrity_Percent  := 100;
      Hull_Temp_C       : Celsius_Degrees   := 20;
      Content_State     : Matter_State      := Solid;
      Content_Mass      : Mass_Grams        := 0;
      Content_Capacity  : Mass_Grams        := 0;
      Content_Temp_C    : Celsius_Degrees   := 20;
   end record;

   type Container_Array is array (Slot_Index) of Container;

   --  Worn / carried pack: total load is sum of container masses.
   type Backpack is record
      Slots : Container_Array :=
        [others =>
           (Hull_Mass        => 0,
            Integrity        => 100,
            Hull_Temp_C      => 20,
            Content_State    => Solid,
            Content_Mass     => 0,
            Content_Capacity => 0,
            Content_Temp_C   => 20)];
      Count : Slot_Count := 0;
   end record;

   Backpack_Full_Error      : exception;
   Backpack_Empty_Error     : exception;
   Carry_Limit_Exceeded     : exception;
   Content_Capacity_Error   : exception;
   Hull_Ruptured_Error      : exception;
   Content_Sealed_Error     : exception;  -- hull still too intact to open
   Plasma_Containment_Lost  : exception;  -- ruptured plasma => game over
   Wrong_Matter_State_Error : exception;  -- drill/sample expects Solid (etc.)
   Sample_Empty_Error       : exception;  -- nothing left to sample
   Already_Open_Error       : exception;  -- can opener on already-open can

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
      Hull_Temp_C      : Celsius_Degrees;
      Content_State    : Matter_State;
      Content_Mass     : Mass_Grams;
      Content_Capacity : Mass_Grams;
      Content_Temp_C   : Celsius_Degrees) return Container
   with
     Global => null,
     Pre    =>
       Content_Mass <= Content_Capacity
       and then Hull_Mass + Content_Mass <= Mass_Grams'Last,
     Post   =>
       Make_Container'Result.Hull_Mass = Hull_Mass
       and then Make_Container'Result.Content_Mass = Content_Mass
       and then Make_Container'Result.Content_State = Content_State
       and then Make_Container'Result.Hull_Temp_C = Hull_Temp_C
       and then Make_Container'Result.Content_Temp_C = Content_Temp_C;

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

   procedure Set_Temperatures
     (C             : in out Container;
      Hull_Temp_C   : Celsius_Degrees;
      Content_Temp_C : Celsius_Degrees)
   with
     Global => null,
     Post   =>
       C.Hull_Temp_C = Hull_Temp_C
       and then C.Content_Temp_C = Content_Temp_C;

   --  True when hull is hotter than Max_Safe_Hull_C (bare-hand risk).
   function Is_Too_Hot_To_Handle (C : Container) return Boolean
   with
     Global => null,
     Post   =>
       Is_Too_Hot_To_Handle'Result = (C.Hull_Temp_C > Max_Safe_Hull_C);

   --  Content is reachable only after hull integrity is lowered enough
   --  (breached/opened). Fully sealed cans (Integrity > threshold) stay closed.
   function Can_Access_Content (C : Container) return Boolean
   with
     Global => null,
     Post   =>
       Can_Access_Content'Result =
         (C.Integrity > 0
          and then C.Integrity <= Access_Integrity_Threshold);

   --  Mass of accessible content; raises Content_Sealed_Error if still sealed,
   --  Hull_Ruptured_Error if integrity is 0 (and plasma raises Plasma_Containment_Lost).
   function Access_Content_Mass (C : Container) return Mass_Grams
   with Global => null;

   --  Ruptured plasma container: containment lost => game over signal.
   function Is_Plasma_Catastrophe (C : Container) return Boolean
   with
     Global => null,
     Post   =>
       Is_Plasma_Catastrophe'Result =
         (C.Content_State = Plasma
          and then C.Content_Mass > 0
          and then C.Integrity = 0);

   --  What a plasma breach does to the surroundings / handler.
   type Leak_Effects is record
      Burn         : Boolean := False;  -- thermal flash / fire
      Electrocute  : Boolean := False;  -- charge dump through conductors
      Heat_Spike_C : Celsius_Degrees := 0;  -- ambient / hull jump
   end record;

   Plasma_Breach_Heat_C : constant Celsius_Degrees := 3_000;

   --  On full plasma rupture: cook the can (temp spike) and report burn+shock.
   function Plasma_Leak_Effects (C : Container) return Leak_Effects
   with
     Global => null,
     Pre    => Is_Plasma_Catastrophe (C),
     Post   =>
       Plasma_Leak_Effects'Result.Burn
       and then Plasma_Leak_Effects'Result.Electrocute
       and then Plasma_Leak_Effects'Result.Heat_Spike_C = Plasma_Breach_Heat_C;

   --  Apply breach physics to the container (raises hull + content temp).
   --  Call after Integrity hits 0 with plasma still inside.
   procedure Apply_Plasma_Breach (C : in out Container)
   with
     Global => null,
     Pre    => Is_Plasma_Catastrophe (C),
     Post   =>
       C.Hull_Temp_C = Plasma_Breach_Heat_C
       and then C.Content_Temp_C = Plasma_Breach_Heat_C;

   --  After Damage_Hull, call to enforce plasma rupture = game over
   --  (temps should already be spiked via Apply_Plasma_Breach).
   procedure Check_Containment (C : Container)
   with Global => null;

   --  Field sample taken from solid content (rover core / scoop).
   type Sample is record
      Mass     : Mass_Grams      := 0;
      State    : Matter_State    := Solid;
      Temp_C   : Celsius_Degrees := 20;
      Refined  : Boolean         := False;
   end record;

   --  Controlled open: lowers hull to Access_Integrity_Threshold without
   --  rupturing (like a can opener). Does not work on already-open or
   --  ruptured containers.
   procedure Open_With_Can_Opener (C : in out Container)
   with
     Global => null,
     Post   =>
       C.Integrity = Access_Integrity_Threshold
       and then Can_Access_Content (C);

   --  Drill into solid content and extract a sample of up to Requested grams.
   --  If still sealed, the drill pierces the hull to the access threshold first.
   --  Reduces Content_Mass by the sampled amount. Raises Wrong_Matter_State_Error
   --  unless Content_State = Solid; Sample_Empty_Error if no content mass.
   procedure Drill_Sample
     (C         : in out Container;
      Requested : Mass_Grams;
      Out_Sample : out Sample)
   with
     Global => null,
     Pre    => Requested > 0;

   --  Process / refine a sample (crush & analyze). Fun, not a chemistry sim.
   procedure Process_Sample (S : in out Sample)
   with
     Global => null,
     Pre    => S.Mass > 0,
     Post   => S.Refined;

   Default_Bite_Grams : constant Mass_Grams := 50;
   Default_Sip_Grams  : constant Mass_Grams := 100;

   --  Bite solid content (food). Subtracts mass; raises if sealed/wrong state/empty.
   procedure Bite
     (C      : in out Container;
      Grams  : Mass_Grams := Default_Bite_Grams;
      Taken  : out Mass_Grams)
   with
     Global => null,
     Pre    => Grams > 0;

   --  Sip liquid content (drink). Subtracts mass; raises if sealed/wrong state/empty.
   procedure Sip
     (C      : in out Container;
      Grams  : Mass_Grams := Default_Sip_Grams;
      Taken  : out Mass_Grams)
   with
     Global => null,
     Pre    => Grams > 0;

end Game_Items;
