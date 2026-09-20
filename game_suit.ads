--  SPDX-License-Identifier: MIT
--  Copyright (c) 2026 Robert Boettcher

pragma Ada_2022;

with Game_Actors;
with Game_Atmosphere;

--  EVA helmet + pressure suit. WORN mass is Mass_Kilograms -- never Strength /
--  backpack Mass_Grams (5 kg comfortable carry). Physical_Data SI lock.
package Game_Suit is

   --  Shared with vehicles; personal wear, not backpack load.
   subtype Mass_Kilograms is Natural range 0 .. 2_000_000;
   subtype Percent is Game_Actors.Percent;
   subtype Abs_Pressure_kPa is Game_Atmosphere.Abs_Pressure_kPa;
   subtype Life_Minutes is Natural;

   --  ----- ISS EMU-class (default) -- NASA EMU fact sheet -----
   --  Total mass PLSS + SAFER (ISS) ~145 kg (319 lb). Operating 4.3 psi = 29.6 kPa,
   --  100% O2. Primary ~8 h + ~30 min Secondary Oxygen Pack.
   EMU_Worn_Mass_kg          : constant Mass_Kilograms := 145;
   EMU_Operating_P_Tenths_kPa : constant := 296;  -- 29.6 kPa as tenths
   EMU_Operating_P_kPa       : constant Abs_Pressure_kPa := 30;
   --  ^ integer kPa for Tile_Atmosphere; Partial at 100% O2 = suit P (not x21%).
   EMU_O2_Percent            : constant Percent := 100;
   EMU_Primary_Life_Min      : constant Life_Minutes := 8 * 60;   -- 8 h
   EMU_Reserve_Life_Min      : constant Life_Minutes := 30;

   --  Mobility: worn sealed suit costs extra AP (not Strength encumbrance).
   EMU_Worn_AP_Penalty       : constant Positive := 2;

   --  ----- Orlan-class (alternate) -----
   Orlan_Worn_Mass_kg        : constant Mass_Kilograms := 110;
   Orlan_Operating_P_kPa     : constant Abs_Pressure_kPa := 40;
   Orlan_O2_Percent          : constant Percent := 100;
   Orlan_Primary_Life_Min    : constant Life_Minutes := 7 * 60;  -- ~7 h

   type Suit_Profile is (EMU_ISS, Orlan);

   type EVA_Suit is record
      Profile         : Suit_Profile := EMU_ISS;
      Helmet_Worn     : Boolean := False;
      Suit_Worn       : Boolean := False;
      Worn_Mass_kg    : Mass_Kilograms := EMU_Worn_Mass_kg;
      Pressure_kPa    : Abs_Pressure_kPa := EMU_Operating_P_kPa;
      O2_Percent      : Percent := EMU_O2_Percent;
      CO2_Percent     : Percent := 0;
      Life_Left_Min   : Life_Minutes := EMU_Primary_Life_Min + EMU_Reserve_Life_Min;
      Primary_Min     : Life_Minutes := EMU_Primary_Life_Min;
      Reserve_Min     : Life_Minutes := EMU_Reserve_Life_Min;
   end record;

   function Make_EMU return EVA_Suit
   with
     Global => null,
     Post   =>
       Make_EMU'Result.Profile = EMU_ISS
       and then Make_EMU'Result.Worn_Mass_kg = EMU_Worn_Mass_kg
       and then Make_EMU'Result.Pressure_kPa = EMU_Operating_P_kPa
       and then Make_EMU'Result.O2_Percent = EMU_O2_Percent
       and then Make_EMU'Result.Life_Left_Min =
                  EMU_Primary_Life_Min + EMU_Reserve_Life_Min
       and then not Make_EMU'Result.Helmet_Worn
       and then not Make_EMU'Result.Suit_Worn;

   function Make_Orlan return EVA_Suit
   with
     Global => null,
     Post   =>
       Make_Orlan'Result.Profile = Orlan
       and then Make_Orlan'Result.Worn_Mass_kg = Orlan_Worn_Mass_kg
       and then Make_Orlan'Result.Pressure_kPa = Orlan_Operating_P_kPa;

   function Is_Sealed_For_EVA (S : EVA_Suit) return Boolean
   with
     Global => null,
     Post   =>
       Is_Sealed_For_EVA'Result =
         (S.Helmet_Worn and then S.Suit_Worn);

   --  Suit O2-partial = suit absolute P when 100% O2 (NOT P x 21% air-mix).
   function Suit_O2_Partial_kPa (S : EVA_Suit) return Natural
   with
     Global => null,
     Pre    => Is_Sealed_For_EVA (S),
     Post   =>
       (if S.O2_Percent = 100 then
          Suit_O2_Partial_kPa'Result = Natural (S.Pressure_kPa)
        else
          Suit_O2_Partial_kPa'Result =
            (Natural (S.Pressure_kPa) * Natural (S.O2_Percent)) / 100);

   function Is_Suit_Loop_Healthy (S : EVA_Suit) return Boolean
   with
     Global => null,
     Pre    => Is_Sealed_For_EVA (S),
     Post   =>
       Is_Suit_Loop_Healthy'Result =
         (S.O2_Percent = 100
          and then S.Pressure_kPa >= 29
          and then S.CO2_Percent <= 2
          and then S.Life_Left_Min > 0);

   --  Never compared to Strength / Comfortable_Capacity_G.
   function Worn_Mass_kg (S : EVA_Suit) return Mass_Kilograms
   with
     Global => null,
     Post   =>
       (if Is_Sealed_For_EVA (S) or else S.Suit_Worn then
          Worn_Mass_kg'Result = S.Worn_Mass_kg
        else
          Worn_Mass_kg'Result = 0);

   function Mobility_AP_Penalty (S : EVA_Suit) return Natural
   with
     Global => null,
     Post   =>
       (if Is_Sealed_For_EVA (S) then
          Mobility_AP_Penalty'Result = EMU_Worn_AP_Penalty
        else
          Mobility_AP_Penalty'Result = 0);

   procedure Don_Suit (S : in out EVA_Suit)
   with Global => null, Post => S.Suit_Worn;

   procedure Don_Helmet (S : in out EVA_Suit)
   with Global => null, Post => S.Helmet_Worn;

   procedure Doff_Helmet (S : in out EVA_Suit)
   with Global => null, Post => not S.Helmet_Worn;

   procedure Doff_Suit (S : in out EVA_Suit)
   with
     Global => null,
     Post   => not S.Suit_Worn and then not S.Helmet_Worn;

   procedure Tick_Life_Support
     (S       : in out EVA_Suit;
      Minutes : Positive := 1)
   with Global => null;

   function Suit_Atmosphere
     (S : EVA_Suit) return Game_Atmosphere.Tile_Atmosphere
   with
     Global => null,
     Pre    => Is_Sealed_For_EVA (S);

end Game_Suit;
