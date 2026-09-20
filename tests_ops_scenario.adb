--  SPDX-License-Identifier: MIT
--  Copyright (c) 2026 Robert Boettcher

pragma Ada_2022;

with Ada.Text_IO;
with Game_Actors;
with Game_Atmosphere;
with Game_Environment;
with Game_Ops_Room;
with Game_Scenario;

--  Focused suite for ops room + scenario starts (run via make test)
procedure Tests_Ops_Scenario is
   package TIO renames Ada.Text_IO;
   package A renames Game_Actors;
   package Atm renames Game_Atmosphere;
   package E renames Game_Environment;
   package R renames Game_Ops_Room;
   package S renames Game_Scenario;
   use type R.Cell_Kind;
   use type S.Scenario_Id;
   use type S.Linked_Outdoor_Role;
   use type S.Atmosphere_Kind;
   use type Atm.Tile_Atmosphere;

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
