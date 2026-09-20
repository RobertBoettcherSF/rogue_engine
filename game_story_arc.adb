--  SPDX-License-Identifier: MIT
--  Copyright (c) 2026 Robert Boettcher

pragma Ada_2022;

package body Game_Story_Arc is

   function Phase_Name (P : Story_Phase) return String is
   begin
      case P is
         when Bunker => return "Bunker";
         when Pad => return "Pad";
         when Ascent => return "Ascent";
         when Coast => return "Coast";
         when Dock => return "Dock";
      end case;
   end Phase_Name;

   function Rad_Band_Label (Rate : Dose_Rate_uSv_h) return String is
   begin
      if Rate >= Rad_Alert_uSv_h then return "ALERT";
      elsif Rate >= Rad_Caution_uSv_h then return "CAUTION";
      else return "NOMINAL";
      end if;
   end Rad_Band_Label;

   function Profile_For (P : Story_Phase) return Arc_State is
      A : Arc_State;
   begin
      A.Phase := P;
      A.Cabin := Game_Atmosphere.Cabin_Earth_Air;
      A.Lerp_Ticks_Left := 0;
      A.Target_CO2_Percent := 0;
      case P is
         when Bunker | Pad =>
            A.Exterior := Game_Atmosphere.Storm_Exterior_Air;
            A.G_Load_Tenths := 10; A.Target_G_Tenths := 10;
            A.Micro_G := False; A.Rad_uSv_h := Cabin_Rad_uSv_h;
         when Ascent =>
            A.Exterior := Game_Atmosphere.Storm_Exterior_Air;
            A.G_Load_Tenths := Ascent_Peak_G_Tenths;
            A.Target_G_Tenths := Ascent_Peak_G_Tenths;
            A.Micro_G := False; A.Rad_uSv_h := Ascent_SAA_uSv_h;
            A.Target_CO2_Percent := 1;
         when Coast =>
            A.Exterior := Game_Atmosphere.Storm_Exterior_Air;
            A.G_Load_Tenths := 0; A.Target_G_Tenths := 0;
            A.Micro_G := True; A.Rad_uSv_h := Coast_GCR_uSv_h;
         when Dock =>
            A.Exterior := Game_Atmosphere.Vacuum_Exterior_Air;
            A.G_Load_Tenths := 0; A.Target_G_Tenths := 0;
            A.Micro_G := True; A.Rad_uSv_h := Dock_EVA_Rad_uSv_h;
      end case;
      return A;
   end Profile_For;

   procedure Apply_Human_Load (Arc : Arc_State; Human : in out Game_Actors.Human_Actor) is
   begin
      Game_Actors.Set_G_Load (Human, Arc.G_Load_Tenths);
      Game_Actors.Apply_G_Vision_Effects (Human);
   end Apply_Human_Load;

   procedure Seed_Phase (Phase : Story_Phase; Mail : in out Game_Messages.Inbox; Dest : String) is
      D : constant String := (if Dest'Length = 0 then "station" else Dest);
   begin
      case Phase is
         when Bunker =>
            Game_Messages.Post (Mail, Game_Messages.Story, "Welcome P",
               "Dear P. " & Passenger_P_Name & " — ops bunker online. Proceed to pad when ready. Flight destination: " & D & ".");
         when Pad =>
            Game_Messages.Post (Mail, Game_Messages.Announcement, "Boarding",
               "ANNOUNCEMENT: Passenger_P boarding. Airlock dP checks. Capsule secure for ascent.");
         when Ascent =>
            Game_Messages.Post (Mail, Game_Messages.Announcement, "Technical difficulties",
               "We are experiencing technical difficulties. Please observe and follow instructions from flight personnel. High-g — wrist hard to raise.");
         when Coast =>
            Game_Messages.Post (Mail, Game_Messages.Story, "Coast MET",
               "Dear P. Quiet coast. Micro-g. Cabin air held. MET continues.");
         when Dock =>
            Game_Messages.Post (Mail, Game_Messages.Story, "Welcome station",
               "Dear P. Welcome to " & D & " station. Cabin bands locked; exterior vacuum. Surface EVA is a later phase.");
      end case;
   end Seed_Phase;

   procedure Start_Arc
     (Arc : out Arc_State; Human : in out Game_Actors.Human_Actor;
      Mail : in out Game_Messages.Inbox; Dest : String)
   is
   begin
      Arc := Profile_For (Bunker);
      Apply_Human_Load (Arc, Human);
      Game_Messages.Clear (Mail);
      Seed_Phase (Bunker, Mail, Dest);
   end Start_Arc;

   procedure Tick_Sensors
     (Arc : in out Arc_State; Human : in out Game_Actors.Human_Actor;
      Steps : Positive := 1)
   is
      Cur_G, Tgt_G, Dg, Cur_C, Tgt_C, Dc : Integer;
   begin
      for Unused in 1 .. Steps loop
         pragma Unreferenced (Unused);
         exit when Arc.Lerp_Ticks_Left = 0;
         Cur_G := Integer (Arc.G_Load_Tenths);
         Tgt_G := Integer (Arc.Target_G_Tenths);
         Dg := (Tgt_G - Cur_G) / Integer (Arc.Lerp_Ticks_Left);
         if Dg = 0 and then Cur_G /= Tgt_G then
            Dg := (if Tgt_G > Cur_G then 1 else -1);
         end if;
         Cur_G := Integer'Max (0, Integer'Min (100, Cur_G + Dg));
         Arc.G_Load_Tenths := Game_Actors.G_Load_Tenths (Cur_G);
         Cur_C := Integer (Arc.Cabin.CO2_Percent);
         Tgt_C := Integer (Arc.Target_CO2_Percent);
         Dc := (Tgt_C - Cur_C) / Integer (Arc.Lerp_Ticks_Left);
         if Dc = 0 and then Cur_C /= Tgt_C then
            Dc := (if Tgt_C > Cur_C then 1 else -1);
         end if;
         Cur_C := Integer'Max (0, Integer'Min (100, Cur_C + Dc));
         Arc.Cabin.CO2_Percent := Game_Atmosphere.Percent (Cur_C);
         Arc.Lerp_Ticks_Left := Arc.Lerp_Ticks_Left - 1;
         if Arc.Lerp_Ticks_Left = 0 then
            Arc.G_Load_Tenths := Arc.Target_G_Tenths;
            Arc.Cabin.CO2_Percent := Arc.Target_CO2_Percent;
         end if;
      end loop;
      Apply_Human_Load (Arc, Human);
   end Tick_Sensors;

   procedure Advance_Phase
     (Arc : in out Arc_State; Human : in out Game_Actors.Human_Actor;
      Mail : in out Game_Messages.Inbox; Dest : String)
   is
      Next : Story_Phase;
      Prev_G : constant Game_Actors.G_Load_Tenths := Arc.G_Load_Tenths;
      Prev_C : constant Game_Atmosphere.Percent := Arc.Cabin.CO2_Percent;
      Settled : Arc_State;
   begin
      if Arc.Phase = Dock then
         return;
      end if;
      Next := Story_Phase'Succ (Arc.Phase);
      Settled := Profile_For (Next);
      Arc.Phase := Settled.Phase;
      Arc.Exterior := Settled.Exterior;
      Arc.Rad_uSv_h := Settled.Rad_uSv_h;
      Arc.Micro_G := Settled.Micro_G;
      Arc.Cabin.Zone := Settled.Cabin.Zone;
      Arc.Cabin.Pressure_kPa := Settled.Cabin.Pressure_kPa;
      Arc.Cabin.O2_Percent := Settled.Cabin.O2_Percent;
      Arc.Cabin.Volume_Liters := Settled.Cabin.Volume_Liters;
      Arc.Target_G_Tenths := Settled.Target_G_Tenths;
      Arc.Target_CO2_Percent := Settled.Target_CO2_Percent;
      case Next is
         when Ascent | Coast =>
            Arc.G_Load_Tenths := Prev_G;
            Arc.Cabin.CO2_Percent := Prev_C;
            Arc.Lerp_Ticks_Left := Ascent_Lerp_Ticks;
         when Bunker | Pad | Dock =>
            Arc.G_Load_Tenths := Settled.G_Load_Tenths;
            Arc.Cabin.CO2_Percent := Settled.Cabin.CO2_Percent;
            Arc.Lerp_Ticks_Left := 0;
      end case;
      Apply_Human_Load (Arc, Human);
      Seed_Phase (Next, Mail, Dest);
   end Advance_Phase;

end Game_Story_Arc;
