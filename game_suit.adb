--  SPDX-License-Identifier: MIT
--  Copyright (c) 2026 Robert Boettcher

pragma Ada_2022;

package body Game_Suit is

   function Make_EMU return EVA_Suit is
   begin
      return
        (Profile         => EMU_ISS,
         Helmet_Worn     => False,
         Suit_Worn       => False,
         Worn_Mass_kg    => EMU_Worn_Mass_kg,
         Pressure_kPa    => EMU_Operating_P_kPa,
         O2_Percent      => EMU_O2_Percent,
         CO2_Percent     => 0,
         Life_Left_Min   => EMU_Primary_Life_Min + EMU_Reserve_Life_Min,
         Primary_Min     => EMU_Primary_Life_Min,
         Reserve_Min     => EMU_Reserve_Life_Min,
         Breach          => Intact,
         Consciousness_S => Vacuum_Consciousness_S);
   end Make_EMU;

   function Make_Orlan return EVA_Suit is
   begin
      return
        (Profile         => Orlan,
         Helmet_Worn     => False,
         Suit_Worn       => False,
         Worn_Mass_kg    => Orlan_Worn_Mass_kg,
         Pressure_kPa    => Orlan_Operating_P_kPa,
         O2_Percent      => Orlan_O2_Percent,
         CO2_Percent     => 0,
         Life_Left_Min   => Orlan_Primary_Life_Min,
         Primary_Min     => Orlan_Primary_Life_Min,
         Reserve_Min     => 0,
         Breach          => Intact,
         Consciousness_S => Vacuum_Consciousness_S);
   end Make_Orlan;

   function Is_Sealed_For_EVA (S : EVA_Suit) return Boolean is
   begin
      return S.Helmet_Worn and then S.Suit_Worn and then S.Breach = Intact;
   end Is_Sealed_For_EVA;

   function Suit_O2_Partial_kPa (S : EVA_Suit) return Natural is
   begin
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

   function Below_Armstrong (S : EVA_Suit) return Boolean is
   begin
      return S.Pressure_kPa < Armstrong_Limit_kPa;
   end Below_Armstrong;

   function Suit_Alert_Status (S : EVA_Suit) return Suit_Alert is
   begin
      if Is_Sealed_For_EVA (S) and then Is_Suit_Loop_Healthy (S) then
         return Nominal;  -- sealed pure-O2 loop
      end if;
      if S.Breach /= Intact then
         return Fail;  -- wrist: suit P falling + FAIL
      end if;
      if Below_Armstrong (S) or else S.Consciousness_S = 0 then
         return Fail;
      end if;
      if not S.Helmet_Worn or else not S.Suit_Worn then
         return Caution;
      end if;
      return Caution;
   end Suit_Alert_Status;

   function Alert_Label (A : Suit_Alert) return String is
   begin
      case A is
         when Nominal =>
            return "NOMINAL";
         when Caution =>
            return "CAUTION";
         when Fail =>
            return "FAIL";
      end case;
   end Alert_Label;

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

   procedure Pierce (S : in out EVA_Suit; Kind : Breach_Kind) is
   begin
      S.Breach := Kind;
      --  Unseal for breathe path (Is_Sealed_For_EVA becomes False).
   end Pierce;

   procedure Step_Pressure_Toward
     (S       : in out EVA_Suit;
      Ambient : Abs_Pressure_kPa;
      Drop    : Natural)
   is
      Cur : constant Natural := Natural (S.Pressure_kPa);
      Amb : constant Natural := Natural (Ambient);
      D   : constant Natural := Drop;
   begin
      if D = 0 then
         return;
      end if;
      if Cur > Amb then
         if Cur - Amb <= D then
            S.Pressure_kPa := Ambient;
         else
            S.Pressure_kPa := Abs_Pressure_kPa (Cur - D);
         end if;
      elsif Cur < Amb then
         if Amb - Cur <= D then
            S.Pressure_kPa := Ambient;
         else
            S.Pressure_kPa := Abs_Pressure_kPa (Cur + D);
         end if;
      end if;
   end Step_Pressure_Toward;

   procedure Tick_Breach
     (S             : in out EVA_Suit;
      Ambient_P_kPa : Abs_Pressure_kPa;
      Seconds       : Positive := 1)
   is
      Drop : Natural := 0;
   begin
      case S.Breach is
         when Intact =>
            return;
         when Pinhole =>
            --  Minutes-scale: kPa/min x seconds / 60 (at least 0).
            Drop := (Pinhole_kPa_Per_Min * Seconds) / 60;
            if Drop = 0 and then Seconds >= 20 then
               Drop := 1;  -- lean floor for long partial minutes
            end if;
         when Rip =>
            Drop := Rip_kPa_Per_Sec * Seconds;
      end case;

      Step_Pressure_Toward (S, Ambient_P_kPa, Drop);

      if Below_Armstrong (S) then
         if S.Consciousness_S > Seconds then
            S.Consciousness_S := S.Consciousness_S - Seconds;
         else
            S.Consciousness_S := 0;
         end if;
      end if;
   end Tick_Breach;

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
