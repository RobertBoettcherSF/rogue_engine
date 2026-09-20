--  SPDX-License-Identifier: MIT
--  Copyright (c) 2026 Robert Boettcher

pragma Ada_2022;

with Ada.Text_IO;
with Game_Atmosphere;
with Game_Demo;
with Game_Grid;
with Game_Passenger_Board;
with Game_Scenario;

--  Thin try-local demo: bunker seat + remote Strider + eat/drink/sleep.
--  Passenger board dump is plain Ada text this phase (SI under the hood).
--  FUTURE color (not landed): NOMINAL=green ANNOUNCEMENT=yellow
--  CAUTION=orange FAIL=red — see Game_Passenger_Board.
procedure Play is
   package TIO renames Ada.Text_IO;
   package D renames Game_Demo;
   package G renames Game_Grid;
   package Atm renames Game_Atmosphere;
   package Pb renames Game_Passenger_Board;
   State : D.Demo_State;
   Panel : Pb.Passenger_Board;
begin
   TIO.Put_Line ("rogue_engine demo — ops room + remote Strider");
   D.Start_Demo (State);

   Panel := D.Passenger_Panel (State);
   Pb.Put_Text_Dump (Panel);

   TIO.Put_Line
     ("Human at ops seat ("
      & G.Coordinate'Image (State.Human.Position.X)
      & ","
      & G.Coordinate'Image (State.Human.Position.Y)
      & ") role="
      & Game_Scenario.Linked_Outdoor_Role'Image (State.Outdoor_Role));
   TIO.Put_Line
     ("Cabin O2-partial kPa="
      & Natural'Image (Atm.O2_Partial_kPa (D.Human_Air (State)))
      & "  storm exterior O2-partial kPa="
      & Natural'Image (Atm.O2_Partial_kPa (State.Exterior_Air)));

   D.Walk (State, (X => 2, Y => 3));
   TIO.Put_Line ("Walked to floor tile (2,3)");
   D.Eat (State);
   D.Drink (State);
   TIO.Put_Line
     ("Ate/drank  hunger="
      & Natural'Image (Natural (State.Human.Hunger))
      & " thirst="
      & Natural'Image (Natural (State.Human.Thirst)));

   D.Strider_Turn (State, D.East);
   D.Strider_Walk (State, (X => 11, Y => 10));
   D.Strider_Scan (State);
   TIO.Put_Line
     ("Strider at ("
      & G.Coordinate'Image (State.Strider.Position.X)
      & ","
      & G.Coordinate'Image (State.Strider.Position.Y)
      & ") scan_vis_m="
      & Natural'Image (State.Last_Scan_Vis)
      & " human still at ("
      & G.Coordinate'Image (State.Human.Position.X)
      & ","
      & G.Coordinate'Image (State.Human.Position.Y)
      & ")");

   D.Sleep (State, Minutes => 5);
   D.Wake (State);
   TIO.Put_Line
     ("Slept/woke  fatigue="
      & Natural'Image (Natural (State.Human.Fatigue))
      & " tissue_O2="
      & Natural'Image (Natural (State.Human.Oxygenation))
      & " policy_w="
      & Float'Image (State.Policy.Exploration_Weight));

   Panel := D.Passenger_Panel (State);
   Pb.Put_Text_Dump (Panel);

   TIO.Put_Line ("Demo sequence OK.");
end Play;
