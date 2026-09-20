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

with Game_Actors;
with Game_Atmosphere;
with Game_Items;

--  EVA helmet + pressure suit. Mass in grams (fits Mass_Grams; personal gear).
--  IRL refs (Physical_Data): NASA EMU ~120–150 kg, ~29.6 kPa pure O2;
--  Orlan ~110 kg class. Demo defaults to EMU mid-mass.
package Game_Suit is

   subtype Mass_Grams is Game_Items.Mass_Grams;
   subtype Percent is Game_Actors.Percent;
   subtype Abs_Pressure_kPa is Game_Atmosphere.Abs_Pressure_kPa;

   --  ----- Real-world baselines (Ops/DS may revise) -----
   --  NASA EMU: empty mass order ~120–150 kg; operating pressure ~4.3 psi ≈ 29.6 kPa,
   --  typically near-pure O2 in the suit loop.
   EMU_Empty_Mass_Min_g : constant Mass_Grams := 120_000;
   EMU_Empty_Mass_Max_g : constant Mass_Grams := 150_000;
   EMU_Empty_Mass_g     : constant Mass_Grams := 130_000;  -- mid-class demo default
   EMU_Operating_P_kPa  : constant Abs_Pressure_kPa := 30;  -- round 29.6
   EMU_O2_Percent       : constant Percent := 100;          -- pure O2 loop

   --  Orlan (reference peer): ~110 kg class.
   Orlan_Empty_Mass_g   : constant Mass_Grams := 110_000;

   --  Suit O2-partial ≈ 30 kPa × 100% = 30 kPa (above 16–24 band high side —
   --  playability: treat as safe sealed supply; tissue recovery still applies).
   Helmet_Mass_g        : constant Mass_Grams := 8_000;   -- rough helmet share
   Soft_Suit_Mass_g     : constant Mass_Grams := 122_000; -- EMU_Empty - helmet

   type EVA_Suit is record
      Helmet_Worn     : Boolean := False;
      Suit_Worn       : Boolean := False;
      Empty_Mass_g    : Mass_Grams := EMU_Empty_Mass_g;
      Pressure_kPa    : Abs_Pressure_kPa := EMU_Operating_P_kPa;
      O2_Percent      : Percent := EMU_O2_Percent;
      CO2_Percent     : Percent := 0;
   end record;

   function Make_EMU return EVA_Suit
   with
     Global => null,
     Post   =>
       Make_EMU'Result.Empty_Mass_g = EMU_Empty_Mass_g
       and then Make_EMU'Result.Pressure_kPa = EMU_Operating_P_kPa
       and then Make_EMU'Result.O2_Percent = EMU_O2_Percent
       and then not Make_EMU'Result.Helmet_Worn
       and then not Make_EMU'Result.Suit_Worn;

   --  Sealed for storm exit: both helmet and pressure garment worn.
   function Is_Sealed_For_EVA (S : EVA_Suit) return Boolean
   with
     Global => null,
     Post   =>
       Is_Sealed_For_EVA'Result =
         (S.Helmet_Worn and then S.Suit_Worn);

   function Worn_Mass_g (S : EVA_Suit) return Mass_Grams
   with Global => null;

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

   --  Internal suit loop as Tile_Atmosphere (Cabin zone semantics for breathe).
   function Suit_Atmosphere
     (S : EVA_Suit) return Game_Atmosphere.Tile_Atmosphere
   with
     Global => null,
     Pre    => Is_Sealed_For_EVA (S);

end Game_Suit;
