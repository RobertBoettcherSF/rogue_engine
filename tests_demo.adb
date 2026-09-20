--  SPDX-License-Identifier: MIT
--  Copyright (c) 2026 Robert Boettcher

pragma Ada_2022;

with Ada.Text_IO;
with Game_Actors;
with Game_Atmosphere;
with Game_Demo;
with Game_ECLSS;
with Game_Passenger_Board;
with Game_Grid;
with Game_Items;
with Game_Ops_Room;
with Game_Scenario;
with Game_Strider;
with Game_Suit;
with Game_Turn;

--  Demo Spec + Strider remote-pilot suite.
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
      Check (not W.Suit_Sealed, "Wrist suit not sealed at start");
   end;
   Seat :=
     (X => G.Coordinate (State.Ops.Seat_X),
      Y => G.Coordinate (State.Ops.Seat_Y));
   Check
     (State.Human.Position.X = Seat.X and then State.Human.Position.Y = Seat.Y,
      "Human starts at ops-room operator seat");
   Check
     (State.Outdoor_Role = S.Strider,
      "Bunker scenario outdoor role is Strider");
   Check
     (State.Strider.Position.X = 10 and then State.Strider.Position.Y = 10,
      "Strider starts on outdoor storm pad");
   Check (State.Human.AP >= 4, "Turn clock granted starting AP");

   --  Atmosphere: cabin ~21 kPa O2-partial; storm exterior ~4 kPa.
   Air := Atm.Cabin_Earth_Air;
   Check (Atm.O2_Partial_kPa (Air) = 21, "Cabin Earth air O2-partial is 21 kPa");
   Check (Atm.In_Safe_O2_Band (Air), "Cabin air in 16-24 kPa safe band");
   Air := Atm.Storm_Exterior_Air;
   Check (Atm.O2_Partial_kPa (Air) = 4, "Storm exterior O2-partial is 4 kPa");
   Check (not Atm.In_Safe_O2_Band (Air), "Storm exterior outside safe O2 band");
   Check
     (D.Human_Air (State).Zone = Atm.Cabin,
      "Human_Air is always Cabin zone");
   Check
     (Atm.O2_Partial_kPa (D.Human_Air (State)) = 21,
      "Piloting still uses bunker ~21 kPa O2-partial");

   --  Walk on ops-room floor (seat is 3,3; walk to 2,3 if passable).
   Dest := (X => 2, Y => 3);
   Check (R.Is_Passable (State.Ops, 2, 3), "Tile (2,3) is passable floor");
   D.Walk (State, Dest);
   Check
     (State.Human.Position.X = 2 and then State.Human.Position.Y = 3,
      "Walk moves human on ops-room tiles");
   Check
     (State.Strider.Position.X = 10 and then State.Strider.Position.Y = 10,
      "Human walk does not move Strider");

   --  Human cannot walk onto storm / out of room.
   Raised := False;
   begin
      D.Walk (State, Destination => (X => 20, Y => 20));
   exception
      when D.Impassable_Tile | A.Invalid_Move =>
         Raised := True;
   end;
   Check (Raised, "Human walk rejects storm / out-of-room tiles");

   --  Remote Strider Walk / Turn / Scan consume link AP; human stays put.
   declare
      Hx : constant G.Coordinate := State.Human.Position.X;
      Hy : constant G.Coordinate := State.Human.Position.Y;
      AP0 : constant A.Action_Points := State.Strider.AP;
      P0  : constant A.Power_Percent := State.Strider.Power;
   begin
      Check
        (State.Chassis.Empty_Mass_kg = St.Demo_Empty_Mass_kg,
         "Demo Strider empty mass is 5e4 kg");
      Check
        (State.Chassis.Payload_Cap_kg = St.Demo_Payload_Cap_kg,
         "Demo Strider payload cap is 5e2 kg");
      Check
        (State.Chassis.Step_Meters = 1,
         "Demo Strider step is 1 m (1 tile)");
      Check
        (State.Chassis.Power_Budget_kW = St.Demo_Power_Budget_kW,
         "Demo Strider power budget is in kW");
      declare
         Ratio : constant Natural := St.Demo_To_Full_Mass_Ratio;
      begin
         Check
           (Ratio = Natural (St.Full_Empty_Mass_kg) / Natural (St.Demo_Empty_Mass_kg),
            "Demo_To_Full_Mass_Ratio matches full/demo empty mass");
         --  Documented ≈ 1/34; integer ratio is 33.
         Check (Ratio = 33, "Integer full/demo mass ratio is 33 (~1/34 doc)");
      end;
      pragma Assert
        (St.Payload_Is_Trivial (St.Full_Empty_Mass_kg, St.Full_Payload_kg));
      Check
        (St.Payload_Is_Trivial (St.Full_Empty_Mass_kg, St.Full_Payload_kg),
         "Full-class 100 t payload is trivial vs empty mass");
      Check
        (St.Can_Load (State.Chassis, 500),
         "Demo chassis Can_Load accepts payload at cap");
      Check
        (not St.Can_Load (State.Chassis, 501),
         "Demo chassis Can_Load rejects payload over Payload_Cap_kg");

      D.Strider_Walk (State, Destination => (X => 11, Y => 10));
      Check
        (State.Strider.Position.X = 11 and then State.Strider.Position.Y = 10,
         "Strider_Walk moves outdoor linked actor");
      Check
        (State.Human.Position.X = Hx and then State.Human.Position.Y = Hy,
         "Strider_Walk leaves human on ops-room tile");
      Check
        (State.Strider.AP = AP0 - A.Action_Points (D.Link_Walk_AP),
         "Strider_Walk spends AP on the strider");
      Check (State.Strider.Power < P0, "Strider_Walk drains machine power");

      D.Strider_Turn (State, D.East);
      Check (State.Strider_Face = D.East, "Strider_Turn sets facing East");

      D.Tick (State);  -- refresh link AP for scan
      D.Strider_Scan (State);
      Check (State.Last_Scan_Vis = 0, "Strider_Scan reports 0 m storm visibility");
   end;

   --  Eat / drink: Content_Mass drops; hunger/thirst rise.
   Mass0 := State.Pack.Slots (State.Food_Slot).Content_Mass;
   declare
      H0 : constant A.Vital_Percent := State.Human.Hunger;
   begin
      D.Eat (State);
      Mass1 := State.Pack.Slots (State.Food_Slot).Content_Mass;
      Check (Mass1 < Mass0, "Bite subtracts food Content_Mass grams");
      Check (State.Human.Hunger > H0, "Eat restores hunger");
   end;
   Mass0 := State.Pack.Slots (State.Drink_Slot).Content_Mass;
   declare
      T0 : constant A.Vital_Percent := State.Human.Thirst;
   begin
      D.Drink (State);
      Mass1 := State.Pack.Slots (State.Drink_Slot).Content_Mass;
      Check (Mass1 < Mass0, "Sip subtracts drink Content_Mass grams");
      Check (State.Human.Thirst > T0, "Drink restores thirst");
   end;

   --  Autopilot breathe: cabin stays healthy; exterior air would kill tissue O2
   --  but human never uses it while piloting.
   Oxy0 := State.Human.Oxygenation;
   D.Tick (State);
   Check
     (State.Human.Oxygenation >= Oxy0 - 2,
      "Tick autopilot breathe in cabin keeps tissue O2 stable");
   Check
     (D.O2_Draw_mL_Per_Min (State) = Atm.Resting_O2_mL_Per_Min,
      "Awake O2 draw is Resting_O2_mL_Per_Min (0.84 kg/day SoT)");

   --  Force exterior breathe path to prove cabin/exterior split math.
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
        (Victim.Oxygenation < 100,
         "Storm 20 kPa * 21% O2 (~4 kPa) drops tissue O2");
      Check
        (State.Human.Oxygenation > Victim.Oxygenation,
         "Human piloting does not silently use storm exterior air");
   end;

   --  Sleep / dream / wake: fatigue recovers; walk blocked; O2 draw drops.
   declare
      F0 : constant A.Vital_Percent := State.Human.Fatigue;
      M0 : constant Game_Turn.Wall_Minutes := State.Clock.Minutes;
   begin
      D.Sleep (State, Minutes => 10);
      Check (State.Human.Sleeping, "Sleep sets Sleeping flag");
      Check
        (State.Clock.Minutes = M0 + 10,
         "Sleep advances wall minutes");
      Check
        (State.Human.Fatigue < F0,
         "Sleep recovers fatigue");
      Check
        (D.O2_Draw_mL_Per_Min (State) = Atm.Sleep_O2_mL_Per_Min,
         "Sleep O2 draw drops to 286 mL/min (~0.70x resting)");
      Check
        (abs (State.Policy.Exploration_Weight - 0.5) <= 0.05,
         "Dream phase improves Explore policy toward 0.5");

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
      Check (Raised, "Strider link blocked while operator asleep");

      D.Wake (State);
      Check (not State.Human.Sleeping, "Wake clears Sleeping flag");
   end;

   --  EVA suit: cannot exit unsuited; suited survives storm tick; doff helmet indoors.
   declare
      Raised : Boolean;
      Oxy_S  : A.Tissue_Oxygenation;
   begin
      Check
        (State.Suit.Worn_Mass_kg = Su.EMU_Worn_Mass_kg,
         "Demo EVA worn mass is 145 kg Mass_Kilograms (not backpack grams)");
      Check
        (State.Suit.Pressure_kPa = Su.EMU_Operating_P_kPa,
         "EMU operating pressure ~30 kPa integer (29.6 IRL / tenths=296)");
      Check
        (State.Suit.Life_Left_Min =
           Su.EMU_Primary_Life_Min + Su.EMU_Reserve_Life_Min,
         "EMU life support 8 h primary + 30 min reserve");
      --  Never route 145 kg through Strength 5 kg carry.
      Check
        (Su.Worn_Mass_kg (State.Suit) = 0,
         "Undonned worn mass is 0 kg (Mass_Kilograms API, not Strength carry)");
      Raised := False;
      begin
         D.Exit_To_Storm (State);
      exception
         when D.Suit_Required =>
            Raised := True;
      end;
      Check (Raised, "Cannot exit to storm without sealed helmet+suit");

      D.Don_EVA (State);
      Check (Su.Is_Sealed_For_EVA (State.Suit), "Don_EVA seals helmet and suit");
      Check
        (Su.Worn_Mass_kg (State.Suit) = 145,
         "Sealed EMU worn mass 145 kg (not Strength carry)");
      Check
        (Su.Mobility_AP_Penalty (State.Suit) = Su.EMU_Worn_AP_Penalty,
         "Sealed suit applies mobility AP penalty");
      Check
        (Su.Suit_O2_Partial_kPa (State.Suit) = Natural (Su.EMU_Operating_P_kPa),
         "Suit O2-partial equals suit P at 100% O2 (not x 21% air-mix)");
      Check
        (Su.Is_Suit_Loop_Healthy (State.Suit),
         "EMU 29.6 kPa / 100% O2 treated as healthy suit loop");
      D.Exit_To_Storm (State);
      Check
        (State.Human_Zone = Atm.Exterior,
         "Exit_To_Storm places human in exterior zone");
      Oxy_S := State.Human.Oxygenation;
      D.Tick (State);
      Check
        (State.Human.Oxygenation >= Oxy_S - 2,
         "Suited human survives storm tick on suit atmosphere");
      Check
        (Atm.O2_Partial_kPa (D.Human_Air (State)) =
           Su.Suit_O2_Partial_kPa (State.Suit),
         "Suited breathe uses suit-loop partial (= P at 100% O2), not storm");
      Check
        (Atm.O2_Partial_kPa (D.Human_Air (State)) /=
           (Natural (State.Exterior_Air.Pressure_kPa) * 21) / 100,
         "Suited breathe is not storm 20 kPa x 21%");

      --  Unsuited on exterior: rapid tissue O2 drop.
      D.Doff_Helmet (State);
      declare
         O0 : constant A.Tissue_Oxygenation := State.Human.Oxygenation;
      begin
         D.Tick (State);
         Check
           (State.Human.Oxygenation < O0,
            "Unsuited on storm exterior drops tissue O2 (hypoxia)");
      end;

      D.Don_EVA (State);
      D.Return_To_Cabin (State);
      Check
        (State.Human_Zone = Atm.Cabin, "Return_To_Cabin restores cabin zone");
      D.Doff_Helmet (State);
      Check
        (not State.Suit.Helmet_Worn,
         "Helmet removable indoors after return");
   end;

   TIO.New_Line;

   --  ECLSS Ops-locked (Physical_Data) + cabin tick over hours.
   declare
      Air  : Atm.Tile_Atmosphere := Atm.Cabin_Earth_Air;
      Cabin : Ec.Cabin_Loop;
   begin
      --  Rates Ops-locked in Physical_Data / Game_ECLSS:
      --  O2 408, CO2 354, scrubber 2121, OGA 1118 mL/min (1x person demo).
      Cabin.Enabled := False;
      Air.Volume_Liters := 5_000;
      for H in 1 .. 20 loop
         Ec.Tick_Cabin (Air, Cabin, Occupants => 1, Minutes => 60);
      end loop;
      Check (Air.CO2_Percent > 0, "No scrubber: CO2 rises over hours");
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
         Check (Dirty.CO2_Percent < 5, "Scrubber reduces elevated CO2");
         Check (Dirty.O2_Percent >= 18, "OGA sustains O2 near band");
      end;
   end;


   --  High-g cuff glance (Physical_Data Ops): AP cost, Can_Raise_Arm, garble, alarm push.
   declare
      W : D.Wrist_Readout;
      Raised : Boolean;
   begin
      D.Start_Demo (State);
      Check (State.Human.G_Load = 10, "Default G_Load is 1.0 g (tenths=10)");
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
      D.Tick (State);  -- refresh AP
      D.Glance_Wrist (State, W);
      Check (W.Garbled, "Dim vision garbles non-critical cuff lines");
      Check (W.O2_Percent = D.Unreadable_Sentinel, "Garbled O2% is sentinel");
      Check (W.Tissue_O2 = State.Human.Oxygenation, "Tissue O2 still readable");

      D.Push_Critical_Alarm (State, Code => 42);
      W := D.Wrist (State);
      Check (W.Alarm_Pushed and then W.Alarm_Code = 42,
             "Critical alarm pushes without arm raise");

      A.Set_G_Load (State.Human, 55);
      A.Apply_G_Vision_Effects (State.Human);
      Check (A.Is_Blacked_Out (State.Human), ">5 g blacks out");
      Check (not A.Can_Raise_Arm (State.Human), "Blackout blocks Can_Raise_Arm");
      Raised := False;
      begin
         D.Glance_Wrist (State, W);
      exception
         when D.Glance_Failed =>
            Raised := True;
      end;
      Check (Raised, "Blackout blocks voluntary glance until G drops");

      A.Set_G_Load (State.Human, 10);
      A.Apply_G_Vision_Effects (State.Human);
      Check (A.Can_Raise_Arm (State.Human), "Glance restored after G drops");
   end;


   --  Passenger board computer (Passenger_Board.md Ops+DS).
   declare
      Panel : Pb.Passenger_Board;
   begin
      D.Start_Demo (State);
      Panel := D.Passenger_Panel (State);
      Check (Panel.Cabin_Status = Pb.OK, "Passenger board cabin OK at start");
      Check (Panel.Current_G_Tenths = 10, "Passenger board shows 1.0 g");
      Check (not Panel.Dense_Dropped, "Dense lines kept when vision clear");
      Check (Panel.Cabin_P_kPa = 101, "Passenger board cabin P 101 kPa");
      Check (Panel.O2_Partial_kPa = 21, "Passenger board O2-partial 21");

      A.Set_G_Load (State.Human, 50);
      A.Apply_G_Vision_Effects (State.Human);
      D.Push_Critical_Alarm (State, 7);
      Panel := D.Passenger_Panel (State);
      Check (Panel.Vision_Clarity = 20, "Board sees 20% clarity at ~5 g");
      Check (Panel.Dense_Dropped, "Dense ECLSS/fuel/attitude dropped at 20%");
      Check (Panel.Priority2_Garbled, "Priority-2 MET/P/O2 garbled at 20%");
      Check (Panel.Warning_Red and then Panel.Alarm_Code = 7,
             "Red warning push on passenger board");
      Check (Panel.Cabin_Status = Pb.OK or else Panel.Cabin_Status = Pb.Caution
               or else Panel.Cabin_Status = Pb.Fail,
             "Priority-1 cabin status still present when dim");
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
