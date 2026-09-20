--  SPDX-License-Identifier: MIT
--  Copyright (c) 2026 Robert Boettcher

pragma Ada_2022;

with Game_Actors;
with Game_Atmosphere;

--  EVA suit. Pierce Spec: Pierce -> unseal -> ambient; pinhole minutes;
--  rip seconds; Armstrong ~6.3 kPa = FAIL; sealed pure-O2 = NOMINAL.
package Game_Suit is

   subtype Mass_Kilograms is Natural range 0 .. 2_000_000;
   subtype Percent is Game_Actors.Percent;
   subtype Abs_Pressure_kPa is Game_Atmosphere.Abs_Pressure_kPa;
   subtype Life_Minutes is Natural;

   EMU_Worn_Mass_kg           : constant Mass_Kilograms := 145;
   EMU_Operating_P_Tenths_kPa : constant := 296;
   EMU_Operating_P_kPa        : constant Abs_Pressure_kPa := 30;
   EMU_O2_Percent             : constant Percent := 100;
   EMU_Primary_Life_Min       : constant Life_Minutes := 8 * 60;
   EMU_Reserve_Life_Min       : constant Life_Minutes := 30;
   EMU_Worn_AP_Penalty        : constant Positive := 2;

   Orlan_Worn_Mass_kg         : constant Mass_Kilograms := 110;
   Orlan_Operating_P_kPa      : constant Abs_Pressure_kPa := 40;
   Orlan_O2_Percent           : constant Percent := 100;
   Orlan_Primary_Life_Min     : constant Life_Minutes := 7 * 60;

   Armstrong_Limit_kPa : constant Abs_Pressure_kPa := 6;
   Vacuum_Consciousness_S : constant Natural := 12;
   Pinhole_kPa_Per_Min : constant Positive := 3;
   Rip_kPa_Per_Sec     : constant Positive := 5;

   type Suit_Profile is (EMU_ISS, Orlan);
   type Breach_Kind is (Intact, Pinhole, Rip);
   type Suit_Alert is (Nominal, Caution, Fail);

   type EVA_Suit is record
      Profile          : Suit_Profile := EMU_ISS;
      Helmet_Worn      : Boolean := False;
      Suit_Worn        : Boolean := False;
      Worn_Mass_kg     : Mass_Kilograms := EMU_Worn_Mass_kg;
      Pressure_kPa     : Abs_Pressure_kPa := EMU_Operating_P_kPa;
      O2_Percent       : Percent := EMU_O2_Percent;
      CO2_Percent      : Percent := 0;
      Life_Left_Min    : Life_Minutes := EMU_Primary_Life_Min + EMU_Reserve_Life_Min;
      Primary_Min      : Life_Minutes := EMU_Primary_Life_Min;
      Reserve_Min      : Life_Minutes := EMU_Reserve_Life_Min;
      Breach           : Breach_Kind := Intact;
      Consciousness_S  : Natural := Vacuum_Consciousness_S;
   end record;

   function Make_EMU return EVA_Suit with Global => null;
   function Make_Orlan return EVA_Suit with Global => null;
   function Is_Sealed_For_EVA (S : EVA_Suit) return Boolean with Global => null;
   function Suit_O2_Partial_kPa (S : EVA_Suit) return Natural
   with Global => null, Pre => Is_Sealed_For_EVA (S);
   function Is_Suit_Loop_Healthy (S : EVA_Suit) return Boolean
   with Global => null, Pre => Is_Sealed_For_EVA (S);
   function Below_Armstrong (S : EVA_Suit) return Boolean with Global => null;
   function Suit_Alert_Status (S : EVA_Suit) return Suit_Alert with Global => null;
   function Alert_Label (A : Suit_Alert) return String with Global => null;
   function Worn_Mass_kg (S : EVA_Suit) return Mass_Kilograms with Global => null;
   function Mobility_AP_Penalty (S : EVA_Suit) return Natural with Global => null;
   procedure Don_Suit (S : in out EVA_Suit) with Global => null, Post => S.Suit_Worn;
   procedure Don_Helmet (S : in out EVA_Suit) with Global => null, Post => S.Helmet_Worn;
   procedure Doff_Helmet (S : in out EVA_Suit) with Global => null, Post => not S.Helmet_Worn;
   procedure Doff_Suit (S : in out EVA_Suit)
   with Global => null, Post => not S.Suit_Worn and then not S.Helmet_Worn;
   procedure Pierce (S : in out EVA_Suit; Kind : Breach_Kind)
   with Global => null, Pre => Kind = Pinhole or else Kind = Rip;
   procedure Tick_Breach
     (S : in out EVA_Suit; Ambient_P_kPa : Abs_Pressure_kPa; Seconds : Positive := 1)
   with Global => null;
   procedure Tick_Life_Support (S : in out EVA_Suit; Minutes : Positive := 1)
   with Global => null;
   function Suit_Atmosphere (S : EVA_Suit) return Game_Atmosphere.Tile_Atmosphere
   with Global => null, Pre => Is_Sealed_For_EVA (S);

end Game_Suit;
