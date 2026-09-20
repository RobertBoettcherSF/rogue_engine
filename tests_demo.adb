pragma Ada_2022;
with Ada.Text_IO;
with Game_Actors;
with Game_Atmosphere;
with Game_Demo;
with Game_Messages;
with Game_ECLSS;
with Game_Passenger_Board;
with Game_Grid;
with Game_Items;
with Game_Ops_Room;
with Game_Scenario;
with Game_Strider;
with Game_Suit;
with Game_Turn;
procedure Tests_Demo is
 package TIO renames Ada.Text_IO;
 package A renames Game_Actors;
 package Atm renames Game_Atmosphere;
 package D renames Game_Demo;
 package Ec renames Game_ECLSS;
 package Pb renames Game_Passenger_Board;
 package G renames Game_Grid;
 package I renames Game_Items;
 package R renames Game_Ops_Room;
 package S renames Game_Scenario;
 package St renames Game_Strider;
 package Su renames Game_Suit;
 use type Su.Suit_Alert;
 use type Su.Breach_Kind;
 use type Atm.Air_Zone;
 use type S.Linked_Outdoor_Role;
 use type G.Coordinate;
 use type D.Facing;
 use type Pb.Cabin_Status_Kind;
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
 State : D.Demo_State;
 Air   : Atm.Tile_Atmosphere;
 Mass0, Mass1 : I.Mass_Grams;
 Oxy0  : A.Tissue_Oxygenation;
 Seat  : G.Point;
 Dest  : G.Point;
 Raised : Boolean;
begin
 TIO.Put_Line ("=== Demo / Strider ===");
 D.Start_Demo (State);
 declare
  W : constant D.Wrist_Readout := D.Wrist (State);
 begin
  Check (W.Pressure_kPa = 101, "Wrist cabin P 101");
  Check (W.O2_Partial_kPa = 21, "Wrist cabin O2-partial 21");
  Check (W.Zone = Atm.Cabin, "Wrist cabin zone");
  Check (not W.Suit_Sealed, "Wrist suit not sealed at sta");
 end;
 Seat :=
   (X => G.Coordinate (State.Ops.Seat_X),
  Y => G.Coordinate (State.Ops.Seat_Y));
 Check
   (State.Human.Position.X = Seat.X and then State.Human.Position.Y = Seat.Y, "Human starts at ops-room ope");
 Check
   (State.Outdoor_Role = S.Strider, "Bunker scenario outdoor role");
 Check
   (State.Strider.Position.X = 10 and then State.Strider.Position.Y = 10, "Strider starts on outdoor st");
 Check (State.Human.AP >= 4, "Turn clock granted starting ");
 Air := Atm.Cabin_Earth_Air;
 Check (Atm.O2_Partial_kPa (Air) = 21, "Cabin Earth air O2-partial i");
 Check (Atm.In_Safe_O2_Band (Air), "Cabin air in 16-24 kPa safe ");
 Air := Atm.Storm_Exterior_Air;
 Check (Atm.O2_Partial_kPa (Air) = 4, "Storm exterior O2-partial is");
 Check (not Atm.In_Safe_O2_Band (Air), "Storm exterior outside safe ");
 Check
   (D.Human_Air (State).Zone = Atm.Cabin, "Human_Air is always Cabin zo");
 Check
   (Atm.O2_Partial_kPa (D.Human_Air (State)) = 21, "Piloting still uses bunker ~");
 Dest := (X => 1, Y => 2);
 Check (R.Is_Passable (State.Ops, 1, 2), "Tile (1,2) is passable floor");
 D.Walk (State, Dest);
 Check
   (State.Human.Position.X = 1 and then State.Human.Position.Y = 2, "Walk moves human on ops-room");
