--  SPDX-License-Identifier: MIT
--  Copyright (c) 2026 Robert Boettcher

pragma Ada_2022;

package body Game_Story_Arc is

   function Phase_Name (P : Story_Phase) return String is
   begin
      case P is
         when Bunker => return "Bunker";
         when Pad    => return "Pad";
         when Ascent => return "Ascent";
         when Coast  => return "Coast";
         when Dock   => return "Dock";
      end case;
   end Phase_Name;

   function Profile_For (P : Story_Phase) return Arc_State is
      A : Arc_State;
   begin
      A.Phase := P;
      A.Cabin := Game_Atmosphere.Cabin_Earth_Air;
      case P is
         when Bunker | Pad =>
            A.Exterior := Game_Atmosphere.Storm_Exterior_Air;
            A.G_Load_Tenths := 10;
            A.Micro_G := False;
         when Ascent =>
            A.Exterior := Game_Atmosphere.Storm_Exterior_Air;
            A.G_Load_Tenths := Ascent_Peak_G_Tenths;
            A.Micro_G := False;
         when Coast =>
            A.Exterior := Game_Atmosphere.Storm_Exterior_Air;
            A.G_Load_Tenths := 0;
            A.Micro_G := True;
         when Dock =>
            A.Exterior := Game_Atmosphere.Vacuum_Exterior_Air;
            A.G_Load_Tenths := 0;
            A.Micro_G := True;
      end case;
      return A;
   end Profile_For;

   procedure Apply_Human_Load
     (Arc   : Arc_State;
      Human : in out Game_Actors.Human_Actor)
   is
   begin
      Game_Actors.Set_G_Load (Human, Arc.G_Load_Tenths);
      Game_Actors.Apply_G_Vision_Effects (Human);
   end Apply_Human_Load;

   procedure Seed_Phase
     (Phase : Story_Phase;
      Mail  : in out Game_Messages.Inbox;
      Dest  : String)
   is
      D : constant String := (if Dest'Length = 0 then "station" else Dest);
   begin
      case Phase is
         when Bunker =>
            Game_Messages.Post
              (Mail, Game_Messages.Story, "Welcome P",
               "Dear P. " & Passenger_P_Name
                 & " — ops bunker online. Proceed to pad when ready. "
                 & "Flight destination: " & D & ".");
         when Pad =>
            Game_Messages.Post
              (Mail, Game_Messages.Announcement, "Boarding",
               "ANNOUNCEMENT: Passenger_P boarding. Airlock dP checks. "
                 & "Capsule secure for ascent.");
         when Ascent =>
            Game_Messages.Post
              (Mail, Game_Messages.Announcement, "Technical difficulties",
               "We are experiencing technical difficulties. "
                 & "Please observe and follow instructions from flight "
                 & "personnel. High-g — wrist hard to raise.");
         when Coast =>
            Game_Messages.Post
              (Mail, Game_Messages.Story, "Coast MET",
               "Dear P. Quiet coast. Micro-g. Cabin air held. MET continues.");
         when Dock =>
            Game_Messages.Post
              (Mail, Game_Messages.Story, "Welcome station",
               "Dear P. Welcome to " & D
                 & " station. Cabin bands locked; exterior vacuum. "
                 & "Surface EVA is a later phase.");
      end case;
   end Seed_Phase;

   procedure Start_Arc
     (Arc   : out Arc_State;
      Human : in out Game_Actors.Human_Actor;
      Mail  : in out Game_Messages.Inbox;
      Dest  : String)
   is
   begin
      Arc := Profile_For (Bunker);
      Apply_Human_Load (Arc, Human);
      Game_Messages.Clear (Mail);
      Seed_Phase (Bunker, Mail, Dest);
   end Start_Arc;

   procedure Advance_Phase
     (Arc   : in out Arc_State;
      Human : in out Game_Actors.Human_Actor;
      Mail  : in out Game_Messages.Inbox;
      Dest  : String)
   is
      Next : Story_Phase;
   begin
      if Arc.Phase = Dock then
         return;
      end if;
      Next := Story_Phase'Succ (Arc.Phase);
      Arc := Profile_For (Next);
      Apply_Human_Load (Arc, Human);
      Seed_Phase (Next, Mail, Dest);
   end Advance_Phase;

end Game_Story_Arc;
