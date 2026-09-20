--  SPDX-License-Identifier: MIT
--  Copyright (c) 2026 Robert Boettcher

pragma Ada_2022;

with Ada.Text_IO;
with Game_Actors;
with Game_Environment;
with Game_Ops_Room;
with Game_Scenario;

--  Focused suite for ops room + scenario starts (run via make test)
procedure Tests_Ops_Scenario is
   package TIO renames Ada.Text_IO;
   package A renames Game_Actors;
   package E renames Game_Environment;
   package R renames Game_Ops_Room;
   package S renames Game_Scenario;
   use type R.Cell_Kind;
   use type S.Scenario_Id;
   use type S.Linked_Outdoor_Role;

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
   Cfg_A, Cfg_B : S.Scenario_Config;
   Human : A.Human_Actor;
   Bot   : A.Robot_Actor;
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
   Check (Cfg_A.Id = S.Bunker_Rover_Storm, "Load bunker scenario");
   Check (Cfg_B.Id = S.Titan_Flight_Control, "Load Titan scenario");
   Check (Cfg_A.Human_Floor = 4, "Bunker scenario human at floor 4");
   Check (Cfg_B.Outdoor_Role = S.Lander, "Titan scenario outdoor role is Lander");
   Check (E.Both_Doors_Closed (Cfg_A.Lock), "Scenario starts with sealed airlock");
   S.Apply_Start (Cfg_A, Human, Bot);
   Check (Human.Oxygenation = 100, "Scenario start human full O2");
   Check (Bot.Power = 100, "Scenario start robot full power");

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
