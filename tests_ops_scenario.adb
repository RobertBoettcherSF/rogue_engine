--  SPDX-License-Identifier: MIT
--  Copyright (c) 2026 Robert Boettcher

pragma Ada_2022;

with Ada.Text_IO;
with Game_Actors;
with Game_Atmosphere;
with Game_Environment;
with Game_Ops_Room;
with Game_Scenario;
with Game_Story_Arc;
with Game_Messages;

--  Focused suite for ops room + scenario starts (run via make test)
procedure Tests_Ops_Scenario is
   package TIO renames Ada.Text_IO;
   package A renames Game_Actors;
   package Atm renames Game_Atmosphere;
   package E renames Game_Environment;
   package R renames Game_Ops_Room;
   package S renames Game_Scenario;
   package Arc renames Game_Story_Arc;
   package Msg renames Game_Messages;
   use type R.Cell_Kind;
   use type S.Scenario_Id;
   use type S.Linked_Outdoor_Role;
   use type S.Atmosphere_Kind;
   use type Atm.Tile_Atmosphere;
   use type Arc.Story_Phase;
   use type Msg.Message_Kind;

   Failed, Passed : Natural := 0;

   procedure Check (Condition : Boolean; Message : String) is
   begin
      if Condition then
         Passed := Passed + 1;
         TIO.Put_Line ("PASS: " & Message);
      else
         Failed := Failed + 1;
         TIO.Put_Line ("FAIL: " & Message);
      end if;
   end Check;

   Room : constant R.Ops_Room := R.Make_Default_Ops_Room;
   Cfg_A, Cfg_B, Cfg_M : S.Scenario_Config;
   Human : A.Human_Actor;
   Bot   : A.Robot_Actor;
   Thin, Mars, Titan, Cabin : Atm.Tile_Atmosphere;
begin
   TIO.Put_Line ("=== Game_Ops_Room / Game_Scenario ===");

   Check (R.Floor_Area_M2 = 20, "Ops room floor area is 20 m2 (5x4 @ 1m)");
   Check (R.Has_Center_Console (Room), "Ops room has center console island");
   Check
     (R.Cell_At (Room, Room.Console_X, Room.Console_Y).Kind = R.Console_Island,
      "Console cell kind is Console_Island");
   Check
     (R.Cell_At (Room, Room.Console_X, Room.Console_Y).Height = 180,
      "Every tile has height; console clear height 180 cm");
   Check
     (R.Cell_At (Room, Room.Seat_X, Room.Seat_Y).Kind = R.Operator_Seat,
      "Seat south of console");
   Check
     (not R.Is_Passable (Room, Room.Console_X, Room.Console_Y),
      "Console island is impassable");

   Cfg_A := S.Load_Scenario (S.Bunker_Rover_Storm);
   Cfg_B := S.Load_Scenario (S.Titan_Flight_Control);
   Cfg_M := S.Load_Scenario (S.Mars_Surface_Ops);
   Check (Cfg_A.Id = S.Bunker_Rover_Storm, "Load bunker scenario");
   Check (Cfg_B.Id = S.Titan_Flight_Control, "Load Titan scenario");
   Check (Cfg_M.Id = S.Mars_Surface_Ops, "Load Mars surface scenario");
   Check (Cfg_A.Human_Floor = 4, "Bunker scenario human at floor 4");
   Check (Cfg_B.Outdoor_Role = S.Lander, "Titan scenario outdoor role is Lander");
   Check (Cfg_B.Atmosphere = S.Titan_Surface, "Titan scenario atmosphere kind");
   Check (Cfg_M.Atmosphere = S.Mars_Exterior, "Mars scenario atmosphere kind");
   Check
     (Cfg_B.Surface_G_Tenths = Atm.Titan_Surface_G_Tenths,
      "Titan surface g0 tenths ~0.14");
   Check
     (Cfg_M.Surface_G_Tenths = Atm.Mars_Surface_G_Tenths,
      "Mars surface g0 tenths ~0.38");
   Check (E.Both_Doors_Closed (Cfg_A.Lock), "Scenario starts with sealed airlock");
   S.Apply_Start (Cfg_A, Human, Bot);
   Check (Human.Oxygenation = 100, "Scenario start human full O2");
   Check (Bot.Power = 100, "Scenario start robot full power");

   --  Body profiles via data (same P×mix breathe; no engine fork).
   Cabin := Atm.Cabin_Earth_Air;
   Thin := Atm.Mars_Thin_Storm_Air;
   Mars := Atm.Mars_Exterior_Air;
   Titan := Atm.Titan_Exterior_Air;
   Check (Atm.O2_Partial_kPa (Cabin) = 21, "Earth cabin O2-partial 21 kPa");
   Check (Thin.Pressure_kPa = 20, "Mars-thin storm demo P=20 kPa");
   Check (Atm.O2_Partial_kPa (Thin) = 4, "Mars-thin storm O2-partial 4 kPa");
   Check (Mars.Pressure_kPa = 1, "Mars exterior P=1 kPa (~0.6 stored)");
   Check (Mars.O2_Percent = 0, "Mars exterior O2%=0 (CO2, suit)");
   Check (Atm.O2_Partial_kPa (Mars) = 0, "Mars exterior O2-partial 0");
   Check (Titan.Pressure_kPa = 147, "Titan exterior P=147 kPa");
   Check (Titan.O2_Percent = 0, "Titan exterior O2%=0 (N2+CH4, suit)");
   Check (Atm.O2_Partial_kPa (Titan) = 0, "Titan exterior O2-partial 0");
   Check
     (S.Exterior_Air (S.Mars_Exterior) = Mars,
      "Scenario Exterior_Air Mars_Exterior profile");
   Check
     (S.Exterior_Air (S.Titan_Surface) = Titan,
      "Scenario Exterior_Air Titan_Surface profile");
   Check
     (S.Exterior_Air (S.Mars_Thin_Storm) = Thin,
      "Scenario Exterior_Air Mars_Thin_Storm profile");
   Check
     (Cfg_M.Storm.Pressure_kPa = Mars.Pressure_kPa,
      "Mars scenario storm P matches exterior profile");
   Check
     (Cfg_B.Storm.Pressure_kPa = Titan.Pressure_kPa,
      "Titan scenario storm P matches exterior profile");

   --  Story_Arc phase → SI (Passenger_P / P).
   declare
      Story : Arc.Arc_State;
      Mail  : Msg.Inbox;
      Slot  : Natural;
      M     : Msg.Message;
   begin
      A.Initialize_Human
        (Human, Location => (X => 1, Y => 1), Speed => 1);
      Arc.Start_Arc (Story, Human, Mail, "Station");
      Check (Story.Phase = Arc.Bunker, "Start_Arc phase Bunker");
      Check (Story.Cabin.Pressure_kPa = 101, "Bunker cabin P 101");
      Check (Atm.O2_Partial_kPa (Story.Cabin) = 21, "Bunker cabin O2p 21");
      Check (Story.G_Load_Tenths = 10, "Bunker g=1.00");
      Check (not Story.Micro_G, "Bunker not micro-g");
      Check (Human.G_Load = 10, "Bunker human G 10");

      Arc.Advance_Phase (Story, Human, Mail, "Station");
      Check (Story.Phase = Arc.Pad, "Advance to Pad");
      Check (Story.Cabin.Pressure_kPa = 101, "Pad cabin held");

      Arc.Advance_Phase (Story, Human, Mail, "Station");
      Check (Story.Phase = Arc.Ascent, "Advance to Ascent");
      Check (Story.G_Load_Tenths = Arc.Ascent_Peak_G_Tenths, "Ascent peak const");
      Check (Story.G_Load_Tenths >= 30 and then Story.G_Load_Tenths <= 40,
             "Ascent peak in 3-4 g");
      Check (Story.Cabin.Pressure_kPa = 101, "Ascent cabin P held");
      Check (Atm.O2_Partial_kPa (Story.Cabin) = 21, "Ascent O2p held");
      Check (Human.G_Load = Arc.Ascent_Peak_G_Tenths, "Ascent human G");
      Check (Human.Vision_Clarity > 0, "Ascent not blackout");

      Arc.Advance_Phase (Story, Human, Mail, "Station");
      Check (Story.Phase = Arc.Coast, "Advance to Coast");
      Check (Story.G_Load_Tenths = 0, "Coast g≈0");
      Check (Story.Micro_G, "Coast micro-g");
      Check (Human.G_Load = 0, "Coast human G 0");

      Arc.Advance_Phase (Story, Human, Mail, "Station");
      Check (Story.Phase = Arc.Dock, "Advance to Dock");
      Check (Story.Exterior.Pressure_kPa = 0, "Dock exterior vacuum");
      Check (Story.Cabin.Pressure_kPa = 101, "Dock cabin station bands");
      Check (Atm.O2_Partial_kPa (Story.Cabin) = 21, "Dock cabin O2p");
      Check (Story.Micro_G, "Dock micro-g");
      Check (Atm.Vacuum_Exterior_Air.Pressure_kPa = 0, "Vacuum profile P=0");
      Check (Story.Exterior.Pressure_kPa /= Mars.Pressure_kPa, "Dock not Mars surface");
      Check (Story.Exterior.Pressure_kPa /= Titan.Pressure_kPa, "Dock not Titan surface");

      Msg.Push_Watchdog
        (Mail, Msg.Alert, "Test ALERT", "Watchdog ALERT after STORY.");
      Slot := Msg.Active_Slot (Mail, 1);
      Check (Slot /= 0, "Active after ALERT");
      M := Msg.Get (Mail, Slot);
      Check (M.Kind = Msg.Alert, "ALERT above STORY");

      Arc.Advance_Phase (Story, Human, Mail, "Station");
      Check (Story.Phase = Arc.Dock, "Dock advance no-op");
   end;


   TIO.New_Line;
   TIO.Put_Line
     ("Summary: "
      & Natural'Image (Passed)
      & " passed,"
      & Natural'Image (Failed)
      & " failed");
   if Failed > 0 then
      raise Program_Error with "tests_ops_scenario failed";
   end if;
end Tests_Ops_Scenario;
