--  SPDX-License-Identifier: MIT
--  Copyright (c) 2026 Robert Boettcher

pragma Ada_2022;

package body Game_Suit is

   function Make_EMU return EVA_Suit is
   begin
      return
        (Profile       => EMU_ISS,
         Helmet_Worn   => False,
         Suit_Worn     => False,
         Worn_Mass_kg  => EMU_Worn_Mass_kg,
         Pressure_kPa  => EMU_Operating_P_kPa,
         O2_Percent    => EMU_O2_Percent,
         CO2_Percent   => 0,
         Life_Left_Min => EMU_Primary_Life_Min + EMU_Reserve_Life_Min,
         Primary_Min   => EMU_Primary_Life_Min,
         Reserve_Min   => EMU_Reserve_Life_Min);
   end Make_EMU;

   function Make_Orlan return EVA_Suit is
   begin
      return
        (Profile       => Orlan,
         Helmet_Worn   => False,
         Suit_Worn     => False,
         Worn_Mass_kg  => Orlan_Worn_Mass_kg,
         Pressure_kPa  => Orlan_Operating_P_kPa,
         O2_Percent    => Orlan_O2_Percent,
         CO2_Percent   => 0,
         Life_Left_Min => Orlan_Primary_Life_Min,
         Primary_Min   => Orlan_Primary_Life_Min,
         Reserve_Min   => 0);
   end Make_Orlan;

   function Is_Sealed_For_EVA (S : EVA_Suit) return Boolean is
   begin
      return S.Helmet_Worn and then S.Suit_Worn;
   end Is_Sealed_For_EVA;

   function Suit_O2_Partial_kPa (S : EVA_Suit) return Natural is
   begin
      --  100% O2: inspired partial ≈ suit absolute P (do NOT × 0.21).
      if S.O2_Percent = 100 then
         return Natural (S.Pressure_kPa);
      end if;
      return (Natural (S.Pressure_kPa) * Natural (S.O2_Percent)) / 100;
   end Suit_O2_Partial_kPa;

   function Is_Suit_Loop_Healthy (S : EVA_Suit) return Boolean is
   begin
      return S.O2_Percent = 100
        and then S.Pressure_kPa >= 29
        and then S.CO2_Percent <= 2
        and then S.Life_Left_Min > 0;
   end Is_Suit_Loop_Healthy;

   function Worn_Mass_kg (S : EVA_Suit) return Mass_Kilograms is
   begin
      if S.Suit_Worn or else S.Helmet_Worn then
         return S.Worn_Mass_kg;
      end if;
      return 0;
   end Worn_Mass_kg;

   function Mobility_AP_Penalty (S : EVA_Suit) return Natural is
   begin
      if Is_Sealed_For_EVA (S) then
         return EMU_Worn_AP_Penalty;
      end if;
      return 0;
   end Mobility_AP_Penalty;

   procedure Don_Suit (S : in out EVA_Suit) is
   begin
      S.Suit_Worn := True;
   end Don_Suit;

   procedure Don_Helmet (S : in out EVA_Suit) is
   begin
      S.Helmet_Worn := True;
   end Don_Helmet;

   procedure Doff_Helmet (S : in out EVA_Suit) is
   begin
      S.Helmet_Worn := False;
   end Doff_Helmet;

   procedure Doff_Suit (S : in out EVA_Suit) is
   begin
      S.Suit_Worn := False;
      S.Helmet_Worn := False;
   end Doff_Suit;

   procedure Tick_Life_Support
     (S       : in out EVA_Suit;
      Minutes : Positive := 1)
   is
   begin
      if S.Life_Left_Min > Minutes then
         S.Life_Left_Min := S.Life_Left_Min - Minutes;
      else
         S.Life_Left_Min := 0;
      end if;
   end Tick_Life_Support;

   function Suit_Atmosphere
     (S : EVA_Suit) return Game_Atmosphere.Tile_Atmosphere
   is
   begin
      return
        (Zone          => Game_Atmosphere.Cabin,
         O2_Percent    => S.O2_Percent,
         CO2_Percent   => S.CO2_Percent,
         Pressure_kPa  => S.Pressure_kPa,
         Volume_Liters => 100);
   end Suit_Atmosphere;

end Game_Suit;
