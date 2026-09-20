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
 Dest := (X => 2, Y => 3);
 Check (R.Is_Passable (State.Ops, 2, 3), "Tile (2,3) is passable floor");
 D.Walk (State, Dest);
 Check
   (State.Human.Position.X = 2 and then State.Human.Position.Y = 3, "Walk moves human on ops-room");
 Check
   (State.Strider.Position.X = 10 and then State.Strider.Position.Y = 10, "Human walk does not move Str");
 Raised := False;
 begin
  D.Walk (State, Destination => (X => 20, Y => 20));
 exception
  when D.Impassable_Tile | A.Invalid_Move =>
   Raised := True;
 end;
 Check (Raised, "Human walk rejects storm / o");
 declare
  Hx : constant G.Coordinate := State.Human.Position.X;
  Hy : constant G.Coordinate := State.Human.Position.Y;
  AP0 : constant A.Action_Points := State.Strider.AP;
  P0  : constant A.Power_Percent := State.Strider.Power;
 begin
  Check
    (State.Chassis.Empty_Mass_kg = St.Demo_Empty_Mass_kg, "Demo Strider empty mass is 5");
  Check
    (State.Chassis.Payload_Cap_kg = St.Demo_Payload_Cap_kg, "Demo Strider payload cap is ");
  Check
    (State.Chassis.Step_Meters = 1, "Demo Strider step is 1 m (1 ");
  Check
    (State.Chassis.Power_Budget_kW = St.Demo_Power_Budget_kW, "Demo Strider power budget is");
  declare
   Ratio : constant Natural := St.Demo_To_Full_Mass_Ratio;
  begin
   Check
     (Ratio = Natural (St.Full_Empty_Mass_kg) / Natural (St.Demo_Empty_Mass_kg), "Demo_To_Full_Mass_Ratio matc");
   Check (Ratio = 33, "Integer full/demo mass ratio");
  end;
  pragma Assert
    (St.Payload_Is_Trivial (St.Full_Empty_Mass_kg, St.Full_Payload_kg));
  Check
    (St.Payload_Is_Trivial (St.Full_Empty_Mass_kg, St.Full_Payload_kg), "Full-class 100 t payload is ");
  Check
    (St.Can_Load (State.Chassis, 500), "Demo chassis Can_Load accept");
  Check
    (not St.Can_Load (State.Chassis, 501), "Demo chassis Can_Load reject");
  D.Strider_Walk (State, Destination => (X => 11, Y => 10));
  Check
    (State.Strider.Position.X = 11 and then State.Strider.Position.Y = 10, "Strider_Walk moves outdoor l");
  Check
    (State.Human.Position.X = Hx and then State.Human.Position.Y = Hy, "Strider_Walk leaves human on");
  Check
    (State.Strider.AP = AP0 - A.Action_Points (D.Link_Walk_AP), "Strider_Walk spends AP on th");
  Check (State.Strider.Power < P0, "Strider_Walk drains machine ");
  D.Strider_Turn (State, D.East);
  Check (State.Strider_Face = D.East, "Strider_Turn sets facing Eas");
  D.Tick (State);
  D.Strider_Scan (State);
  Check (State.Last_Scan_Vis = 0, "Strider_Scan reports 0 m sto");
 end;
 Mass0 := State.Pack.Slots (State.Food_Slot).Content_Mass;
 declare
  H0 : constant A.Vital_Percent := State.Human.Hunger;
 begin
  D.Eat (State);
  Mass1 := State.Pack.Slots (State.Food_Slot).Content_Mass;
  Check (Mass1 < Mass0, "Bite subtracts food Content_");
  Check (State.Human.Hunger > H0, "Eat restores hunger");
 end;
 Mass0 := State.Pack.Slots (State.Drink_Slot).Content_Mass;
 declare
  T0 : constant A.Vital_Percent := State.Human.Thirst;
 begin
  D.Drink (State);
  Mass1 := State.Pack.Slots (State.Drink_Slot).Content_Mass;
  Check (Mass1 < Mass0, "Sip subtracts drink Content_");
  Check (State.Human.Thirst > T0, "Drink restores thirst");
 end;
 Oxy0 := State.Human.Oxygenation;
 D.Tick (State);
 Check
   (State.Human.Oxygenation >= Oxy0 - 2, "Tick autopilot breathe in ca");
 Check
   (D.O2_Draw_mL_Per_Min (State) = Atm.Resting_O2_mL_Per_Min, "Awake O2 draw is Resting_O2_");
 declare
  Victim : A.Human_Actor := State.Human;
  Ext    : constant Atm.Tile_Atmosphere := Atm.Storm_Exterior_Air;
 begin
  Victim.Oxygenation := 100;
  A.Autopilot_Breathe
    (Victim,
   Ext.O2_Percent,
   Ext.CO2_Percent,
   A.Room_Pressure_kPa (Ext.Pressure_kPa));
  Check
    (Victim.Oxygenation < 100, "Storm 20 kPa * 21% O2 (~4 kP");
  Check
    (State.Human.Oxygenation > Victim.Oxygenation, "Human piloting does not sile");
 end;
 declare
  F0 : constant A.Vital_Percent := State.Human.Fatigue;
  M0 : constant Game_Turn.Wall_Minutes := State.Clock.Minutes;
 begin
  D.Sleep (State, Minutes => 10);
  Check (State.Human.Sleeping, "Sleep sets Sleeping flag");
  Check
    (State.Clock.Minutes = M0 + 10, "Sleep advances wall minutes");
  Check
    (State.Human.Fatigue < F0, "Sleep recovers fatigue");
  Check
    (D.O2_Draw_mL_Per_Min (State) = Atm.Sleep_O2_mL_Per_Min, "Sleep O2 draw drops to 286 m");
  Check
    (abs (State.Policy.Exploration_Weight - 0.5) <= 0.05, "Dream phase improves Explore");
  Raised := False;
  begin
   D.Walk (State, Destination => (X => 2, Y => 2));
  exception
   when A.Asleep_Error =>
    Raised := True;
  end;
  Check (Raised, "Walk blocked while asleep");
  Raised := False;
  begin
   D.Strider_Walk (State, Destination => (X => 12, Y => 10));
  exception
   when A.Asleep_Error =>
    Raised := True;
  end;
  Check (Raised, "Strider link blocked while o");
  D.Wake (State);
  Check (not State.Human.Sleeping, "Wake clears Sleeping flag");
 end;
 declare
  Raised : Boolean;
  Oxy_S  : A.Tissue_Oxygenation;
 begin
  Check
    (State.Suit.Worn_Mass_kg = Su.EMU_Worn_Mass_kg, "Demo EVA worn mass is 145 kg");
  Check
    (State.Suit.Pressure_kPa = Su.EMU_Operating_P_kPa, "EMU operating pressure ~30 k");
  Check
    (State.Suit.Life_Left_Min =
     Su.EMU_Primary_Life_Min + Su.EMU_Reserve_Life_Min, "EMU life support 8 h primary");
  Check
    (Su.Worn_Mass_kg (State.Suit) = 0, "Undonned worn mass is 0 kg (");
  Raised := False;
  begin
   D.Exit_To_Storm (State);
  exception
   when D.Suit_Required =>
    Raised := True;
  end;
  Check (Raised, "Cannot exit to storm without");
  D.Don_EVA (State);
  Check (Su.Is_Sealed_For_EVA (State.Suit), "Don_EVA seals helmet and sui");
  Check
    (Su.Worn_Mass_kg (State.Suit) = 145, "Sealed EMU worn mass 145 kg ");
  Check
    (Su.Mobility_AP_Penalty (State.Suit) = Su.EMU_Worn_AP_Penalty, "Sealed suit applies mobility");
  Check
    (Su.Suit_O2_Partial_kPa (State.Suit) = Natural (Su.EMU_Operating_P_kPa), "Suit O2-partial equals suit ");
  Check
    (Su.Is_Suit_Loop_Healthy (State.Suit), "EMU 29.6 kPa / 100% O2 treat");
  D.Exit_To_Storm (State);
  Check
    (State.Human_Zone = Atm.Exterior, "Exit_To_Storm places human i");
  Oxy_S := State.Human.Oxygenation;
  D.Tick (State);
  Check
    (State.Human.Oxygenation >= Oxy_S - 2, "Suited human survives storm ");
  Check
    (Atm.O2_Partial_kPa (D.Human_Air (State)) =
     Su.Suit_O2_Partial_kPa (State.Suit), "Suited breathe uses suit-loo");
  Check
    (Atm.O2_Partial_kPa (D.Human_Air (State)) /=
     (Natural (State.Exterior_Air.Pressure_kPa) * 21) / 100, "Suited breathe is not storm ");
  D.Doff_Helmet (State);
  declare
   O0 : constant A.Tissue_Oxygenation := State.Human.Oxygenation;
  begin
   D.Tick (State);
   Check
     (State.Human.Oxygenation < O0, "Unsuited on storm exterior d");
  end;
  D.Don_EVA (State);
  D.Return_To_Cabin (State);
  Check
    (State.Human_Zone = Atm.Cabin, "Return_To_Cabin restores cab");
  D.Doff_Helmet (State);
  Check
    (not State.Suit.Helmet_Worn, "Helmet removable indoors aft");
 end;
 declare
  P0 : Su.Abs_Pressure_kPa;
  C0 : Natural;
 begin
  D.Don_EVA (State);
  Check
    (Su.Suit_Alert_Status (State.Suit) = Su.Nominal, "Sealed pure-O2 loop is NOMIN");
  Check
    (Su.Is_Suit_Loop_Healthy (State.Suit), "Sealed loop healthy before p");
  D.Exit_To_Storm (State);
  P0 := State.Suit.Pressure_kPa;
  D.Pierce_Suit (State, Su.Pinhole);
  Check (not Su.Is_Sealed_For_EVA (State.Suit), "Pierce unseals (pinhole)");
  Check
    (Su.Suit_Alert_Status (State.Suit) = Su.Fail, "Wrist: pierce FAIL while s");
  Check
    (Atm.O2_Partial_kPa (D.Human_Air (State)) =
     Atm.O2_Partial_kPa (State.Exterior_Air), "Pierce breathe ambient");
  D.Tick (State);
  Check
    (State.Suit.Pressure_kPa < P0
     or else State.Suit.Pressure_kPa =
       State.Exterior_Air.Pressure_kPa, "Pinhole tick drops suit P to");
  D.Return_To_Cabin (State);
  D.Don_EVA (State);
  D.Exit_To_Storm (State);
  D.Pierce_Suit (State, Su.Rip);
  Check (State.Suit.Breach = Su.Rip, "Rip breach kind set");
  Su.Tick_Breach
    (State.Suit,
   Ambient_P_kPa => State.Exterior_Air.Pressure_kPa,
   Seconds       => 15);
  Check
    (Natural (State.Suit.Pressure_kPa) <=
     Natural (State.Exterior_Air.Pressure_kPa) + 5
     or else Su.Below_Armstrong (State.Suit), "Rip ~15 s drives suit P towa");
  State.Suit.Pressure_kPa := 5;
  Check
    (Su.Below_Armstrong (State.Suit), "Below ~6.3 kPa Armstrong = h");
  Check
    (Su.Suit_Alert_Status (State.Suit) = Su.Fail, "Armstrong / pierce alert is ");
  C0 := State.Suit.Consciousness_S;
  Su.Tick_Breach (State.Suit, Ambient_P_kPa => 0, Seconds => 5);
  Check
    (State.Suit.Consciousness_S < C0
     or else State.Suit.Consciousness_S = 0, "Near vacuum: consciousness f");
  D.Return_To_Cabin (State);
  D.Don_EVA (State);
  Check
    (Su.Suit_Alert_Status (State.Suit) = Su.Nominal, "Re-seal restores NOMINAL pur");
 end;
 TIO.New_Line;
 declare
  Air  : Atm.Tile_Atmosphere := Atm.Cabin_Earth_Air;
  Cabin : Ec.Cabin_Loop;
 begin
  Cabin.Enabled := False;
  Air.Volume_Liters := 5_000;
  for H in 1 .. 20 loop
   Ec.Tick_Cabin (Air, Cabin, Occupants => 1, Minutes => 60);
  end loop;
  Check (Air.CO2_Percent > 0, "No scrubber: CO2 rises over ");
  declare
   Dirty : Atm.Tile_Atmosphere := Atm.Cabin_Earth_Air;
   L2    : Ec.Cabin_Loop;
  begin
   Dirty.Volume_Liters := 5_000;
   Dirty.CO2_Percent := 5;
   Dirty.O2_Percent := 18;
   for H in 1 .. 48 loop
    Ec.Tick_Cabin (Dirty, L2, Occupants => 1, Minutes => 60);
   end loop;
   Check (Dirty.CO2_Percent < 5, "Scrubber reduces elevated CO");
   Check (Dirty.O2_Percent >= 18, "OGA sustains O2 near band");
  end;
 end;
 declare
  W : D.Wrist_Readout;
  Raised : Boolean;
 begin
  D.Start_Demo (State);
  Check (State.Human.G_Load = 10, "Default G_Load is 1.0 g (ten");
  Check (State.Human.Vision_Clarity = 100, "Default vision clarity 100");
  Check (A.Can_Raise_Arm (State.Human), "Can raise arm at 1 g");
  Check (A.Glance_AP_Cost (State.Human) = 0, "Soft coast glance AP cost 0");
  D.Glance_Wrist (State, W);
  Check (W.Glance_Ok and then not W.Garbled, "Coast glance clear telemetry");
  A.Set_G_Load (State.Human, 30);
  A.Apply_G_Vision_Effects (State.Human);
  Check (State.Human.Vision_Clarity = 100, "<=3 g stays clear");
  A.Set_G_Load (State.Human, 40);
  A.Apply_G_Vision_Effects (State.Human);
  Check (State.Human.Vision_Clarity = 40, "3.5-4.5 g tunnel/grey (~40%)");
  A.Set_G_Load (State.Human, 50);
  A.Apply_G_Vision_Effects (State.Human);
  Check (State.Human.Vision_Clarity = 20, "~5 g -> ~20% readable");
  D.Tick (State);
  D.Glance_Wrist (State, W);
  Check (W.Garbled, "Dim vision garbles non-criti");
  Check (W.O2_Percent = D.Unreadable_Sentinel, "Garbled O2% is sentinel");
  Check (W.Tissue_O2 = State.Human.Oxygenation, "Tissue O2 still readable");
  D.Push_Critical_Alarm (State, Code => 42);
  W := D.Wrist (State);
  Check (W.Alarm_Pushed and then W.Alarm_Code = 42, "Critical alarm pushes withou");
  A.Set_G_Load (State.Human, 55);
  A.Apply_G_Vision_Effects (State.Human);
  Check (A.Is_Blacked_Out (State.Human), ">5 g blacks out");
  Check (not A.Can_Raise_Arm (State.Human), "Blackout blocks Can_Raise_Ar");
  Raised := False;
  begin
   D.Glance_Wrist (State, W);
  exception
   when D.Glance_Failed =>
    Raised := True;
  end;
  Check (Raised, "Blackout blocks voluntary gl");
  A.Set_G_Load (State.Human, 10);
  A.Apply_G_Vision_Effects (State.Human);
  Check (A.Can_Raise_Arm (State.Human), "Glance restored after G drop");
 end;
 declare
  Panel : Pb.Passenger_Board;
 begin
  D.Start_Demo (State);
  Panel := D.Passenger_Panel (State);
  Check (Panel.Cabin_Status = Pb.OK, "Passenger board cabin OK at ");
  declare
   High_O2 : Atm.Tile_Atmosphere := Atm.Cabin_Earth_Air;
   Hi_CO2  : Atm.Tile_Atmosphere := Atm.Cabin_Earth_Air;
   P_Hi    : Pb.Passenger_Board;
   P_CO2   : Pb.Passenger_Board;
  begin
   High_O2.O2_Percent := 30;
   P_Hi := Pb.Build (High_O2, State.Human, State.Clock);
   Check (P_Hi.Cabin_Status = Pb.Caution, "O2>24 is CAUTION not FAIL");
   Hi_CO2.CO2_Percent := 1;
   P_CO2 := Pb.Build (Hi_CO2, State.Human, State.Clock);
   Check (P_CO2.Cabin_Status = Pb.Caution, "CO2>0.4 kPa (int>=1) is CAUT");
   Hi_CO2.CO2_Percent := 3;
   P_CO2 := Pb.Build (Hi_CO2, State.Human, State.Clock);
   Check (P_CO2.Cabin_Status = Pb.Fail, "CO2>=3 kPa is FAIL");
  end;
  Check (Panel.Current_G_Tenths = 10, "Passenger board shows 1.0 g");
  Check (not Panel.Dense_Dropped, "Dense lines kept when vision");
  Check (Panel.Cabin_P_kPa = 101, "Passenger board cabin P 101 ");
  Check (Panel.O2_Partial_kPa = 21, "Passenger board O2-partial 2");
  A.Set_G_Load (State.Human, 50);
  A.Apply_G_Vision_Effects (State.Human);
  D.Push_Critical_Alarm (State, 7);
  Panel := D.Passenger_Panel (State);
  Check (Panel.Vision_Clarity = 20, "Board sees 20% clarity at ~5");
  Check (Panel.Dense_Dropped, "Dense ECLSS/fuel/attitude dr");
  Check (Panel.Priority2_Garbled, "Priority-2 MET/P/O2 garbled ");
  Check (Panel.Warning_Red and then Panel.Alarm_Code = 7, "Red warning push on passenge");
  Check (Panel.Cabin_Status = Pb.OK or else Panel.Cabin_Status = Pb.Caution
     or else Panel.Cabin_Status = Pb.Fail, "Priority-1 cabin status stil");
 end;
 declare
  package Msg renames Game_Messages;
  use type Msg.Message_Kind;
  Box : Msg.Inbox;
  M1, M2 : Msg.Message;
  Slot : Natural;
 begin
  Msg.Seed_Inbox (Box, "Mars");
  Check (Msg.Active_Count (Box) = 2, "Seed inbox has 2 active");
  Check (Msg.Unread_Count (Box) = 2, "Both seed messages unread");
  Slot := Msg.Active_Slot (Box, 1);
  Check (Slot /= 0, "Welcome slot present");
  M1 := Msg.Get (Box, Msg.Slot_Index (Slot));
  Check (M1.Kind = Msg.Announcement, "Priority lists ANNOUNCEMENT ");
  Check (M1.Payload (1 .. 12) = "We are exper", "Tech-difficulties body");
  Slot := Msg.Active_Slot (Box, 2);
  M2 := Msg.Get (Box, Msg.Slot_Index (Slot));
  Check (M2.Kind = Msg.Story, "Welcome is STORY");
  Check (M2.Payload (1 .. 7) = "Dear P.", "Welcome Dear P");
  declare
   B : constant String := M2.Payload;
   Found : Boolean := False;
  begin
   for I in B'First .. B'Last - 3 loop
    if B (I .. I + 3) = "Mars" then
     Found := True;
     exit;
    end if;
   end loop;
   Check (Found, "Welcome embeds Planetname Ma");
  end;
  Msg.Mark_Read (Box, Msg.Slot_Index (Msg.Active_Slot (Box, 1)));
  Check (Msg.Unread_Count (Box) = 1, "Mark_Read drops unread");
  Msg.Archive (Box, Msg.Slot_Index (Msg.Active_Slot (Box, 1)));
  Check (Msg.Active_Count (Box) = 1, "Archive removes from active");
  Msg.Delete (Box, Msg.Slot_Index (Msg.Active_Slot (Box, 1)));
  Check (Msg.Active_Count (Box) = 0, "Delete clears last active");
  Msg.Push_Watchdog
    (Box, Msg.Caution, "Cabin CAUTION", "test caution body");
  Msg.Push_Watchdog
    (Box, Msg.Alert, "Cabin ALERT", "test fail body");
  Check (Msg.Active_Count (Box) = 2, "Watchdog CAUTION+ALERT poste");
  Check (Msg.Kind_Tag (Msg.Announcement) = "ANNOUNCEMENT", "Kind_Tag ANNOUNCEMENT");
  Msg.Seed_Inbox (Box, "Titan");
  Msg.Push_Watchdog (Box, Msg.Alert, "Cabin ALERT", "hypoxia trip");
  Slot := Msg.Active_Slot (Box, 1);
  Check (Slot /= 0, "priority slot 1 present");
  Check (Msg.Get (Box, Msg.Slot_Index (Slot)).Kind = Msg.Alert, "ALERT listed before STORY");
  Check (Msg.Urgency (Msg.Alert) > Msg.Urgency (Msg.Story), "Urgency ALERT > STORY");
  Check (Msg.Urgency (Msg.Caution) > Msg.Urgency (Msg.Announcement), "Urgency CAUTION > ANNOUNCEME");
  Check (Msg.Urgency (Msg.Guidance) = Msg.Urgency (Msg.Announcement), "GUIDANCE ties ANNOUNCEMENT");
 end;
 TIO.Put_Line
   ("Summary: "
  & Natural'Image (Passed)
  & " passed,"
  & Natural'Image (Failed)
  & " failed");
 if Failed > 0 then
  raise Program_Error with "tests_demo failed";
 end if;
end Tests_Demo;
