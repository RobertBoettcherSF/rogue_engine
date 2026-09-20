--  SPDX-License-Identifier: MIT
--  Copyright (c) 2026 Robert Boettcher

pragma Ada_2022;

package body Game_Demo is

   Hunger_Per_Bite         : constant := 15;
   Thirst_Per_Sip          : constant := 20;
   Fatigue_Per_Sleep_Min   : constant := 1;

   function Human_Air
     (State : Demo_State) return Game_Atmosphere.Tile_Atmosphere
   is
   begin
      case State.Human_Zone is
         when Game_Atmosphere.Cabin =>
            return State.Cabin_Air;
         when Game_Atmosphere.Exterior =>
            if Game_Suit.Is_Sealed_For_EVA (State.Suit) then
               return Game_Suit.Suit_Atmosphere (State.Suit);
            else
               --  Unsuited on storm: lethal ~4 kPa O2-partial.
               return State.Exterior_Air;
            end if;
      end case;
   end Human_Air;

   function Build_Wrist
     (State : Demo_State;
      Garble_Noncritical : Boolean) return Wrist_Readout
   is
      Air : constant Game_Atmosphere.Tile_Atmosphere := Human_Air (State);
      W   : Wrist_Readout;
   begin
      W :=
        (Zone           => Air.Zone,
         Pressure_kPa   => Natural (Air.Pressure_kPa),
         O2_Percent     => Natural (Air.O2_Percent),
         O2_Partial_kPa => Game_Atmosphere.O2_Partial_kPa (Air),
         CO2_Percent    => Natural (Air.CO2_Percent),
         Tissue_O2      => State.Human.Oxygenation,
         Suit_Sealed    => Game_Suit.Is_Sealed_For_EVA (State.Suit),
         Suit_Minutes   => Natural (State.Suit.Life_Left_Min),
         AP             => State.Human.AP,
         Vision_Clarity => State.Human.Vision_Clarity,
         G_Load         => State.Human.G_Load,
         Garbled        => Garble_Noncritical,
         Alarm_Pushed   => State.Last_Alarm_Code > 0,
         Alarm_Code     => State.Last_Alarm_Code,
         Glance_Ok      => True);
      if Garble_Noncritical then
         --  Non-critical telemetry unreadable; keep tissue O2 / alarms path.
         W.O2_Percent := Unreadable_Sentinel;
         W.CO2_Percent := Unreadable_Sentinel;
         W.Pressure_kPa := Unreadable_Sentinel;
         W.O2_Partial_kPa := Unreadable_Sentinel;
         W.Suit_Minutes := Unreadable_Sentinel;
      end if;
      return W;
   end Build_Wrist;

   function Wrist (State : Demo_State) return Wrist_Readout is
      Garble : constant Boolean :=
        State.Human.Vision_Clarity > 0
        and then State.Human.Vision_Clarity <= 20;
   begin
      --  Snapshot: garble when heavy dim (~20%) but not full blackout.
      return Build_Wrist (State, Garble_Noncritical => Garble);
   end Wrist;

   procedure Glance_Wrist
     (State : in out Demo_State;
      Out_W : out Wrist_Readout)
   is
      Cost   : Natural;
      Garble : Boolean;
   begin
      if State.Human.Sleeping then
         raise Game_Actors.Asleep_Error;
      end if;
      --  Blackout blocks voluntary glance until G drops (Ops).
      if not Game_Actors.Can_Raise_Arm (State.Human) then
         raise Glance_Failed;
      end if;
      Cost := Game_Actors.Glance_AP_Cost (State.Human);
      if State.Human.AP < Game_Actors.Action_Points (Cost) then
         raise Insufficient_AP;
      end if;
      if Cost > 0 then
         Game_Actors.Adjust_Action_Points (State.Human, -Integer (Cost));
      end if;
      Garble :=
        State.Human.Vision_Clarity > 0
        and then State.Human.Vision_Clarity <= 20;
      Out_W := Build_Wrist (State, Garble_Noncritical => Garble);
      Out_W.Glance_Ok := True;
   end Glance_Wrist;

   procedure Push_Critical_Alarm
     (State : in out Demo_State;
      Code  : Positive)
   is
   begin
      --  Critical alarms push (tone + auto cuff line) without Can_Raise_Arm.
      State.Last_Alarm_Code := Code;
   end Push_Critical_Alarm;

   function Passenger_Panel
     (State : Demo_State) return Game_Passenger_Board.Passenger_Board
   is
   begin
      return Game_Passenger_Board.Build
        (Cabin => State.Cabin_Air,
         Human => State.Human,
         Clock => State.Clock,
         Alarm => State.Last_Alarm_Code);
   end Passenger_Panel;



   function O2_Draw_mL_Per_Min (State : Demo_State) return Positive is
   begin
      if State.Human.Sleeping then
         return Game_Atmosphere.Sleep_O2_mL_Per_Min;
      else
         return Game_Atmosphere.Resting_O2_mL_Per_Min;
      end if;
   end O2_Draw_mL_Per_Min;

   procedure Autopilot_Human (State : in out Demo_State) is
      Air : Game_Atmosphere.Tile_Atmosphere := Human_Air (State);
   begin
      --  Dead PLSS: suit loop no longer healthy -> breathe as empty (hypoxia).
      if State.Human_Zone = Game_Atmosphere.Exterior
        and then Game_Suit.Is_Sealed_For_EVA (State.Suit)
        and then State.Suit.Life_Left_Min = 0
      then
         Air := State.Exterior_Air;
      end if;
      Game_Actors.Autopilot_Breathe
        (State.Human,
         O2_Percent   => Air.O2_Percent,
         CO2_Percent  => Air.CO2_Percent,
         Pressure_kPa => Game_Actors.Room_Pressure_kPa (Air.Pressure_kPa));
   end Autopilot_Human;

   procedure Spend_Link_AP (State : in out Demo_State; Cost : Positive) is
   begin
      if State.Human.Sleeping then
         raise Game_Actors.Asleep_Error;
      end if;
      if State.Strider.AP < Game_Actors.Action_Points (Cost) then
         raise Insufficient_AP;
      end if;
      if State.Strider.Power = 0 or else State.Strider.Hull = 0 then
         raise Link_Down;
      end if;
      Game_Actors.Adjust_Action_Points (State.Strider, -Integer (Cost));
   end Spend_Link_AP;

   procedure Start_Demo (State : out Demo_State) is
      Cfg      : constant Game_Scenario.Scenario_Config :=
        Game_Scenario.Load_Scenario (Game_Scenario.Bunker_Rover_Storm);
      Food     : Game_Items.Container;
      Drink    : Game_Items.Container;
      Strength : constant Game_Items.Strength_Level := 5;
      Id       : Game_Dream_RSI.Valid_Node_Index;
   begin
      State.Ops := Cfg.Ops;
      State.Outdoor_Role := Cfg.Outdoor_Role;
      State.Clock := (Turn => 0, Minutes => 0);
      State.Cabin_Air :=
        Game_Atmosphere.From_Bunker_Room (Cfg.Ops.Air, Game_Atmosphere.Cabin);
      State.Exterior_Air := Game_Scenario.Exterior_Air (Cfg.Atmosphere);
      State.Human_Zone := Game_Atmosphere.Cabin;
      State.Suit := Game_Suit.Make_EMU;
      State.Lock := Cfg.Lock;
      State.Strider_Face := North;
      State.Policy := (Exploration_Weight => 1.0);
      State.Last_Scan_Vis := 0;
      State.Last_Alarm_Code := 0;
      State.Cabin_ECLSS := (Enabled => True, O2_Acc_mL => 0, CO2_Acc_mL => 0);
      Game_Items.Clear (State.Pack);

      Game_Scenario.Apply_Start (Cfg, State.Human, State.Strider);
      State.Chassis := Game_Strider.Make_Demo_Chassis;
      Game_Turn.Advance_Turn (State.Clock, State.Human);
      Game_Actors.Adjust_Action_Points
        (State.Strider, Integer (Game_Turn.Default_AP_Grant));

      Food :=
        Game_Items.Make_Container
          (Hull_Mass        => 100,
           Integrity        => 100,
           Hull_Temp_C      => 20,
           Content_State    => Game_Items.Solid,
           Content_Mass     => 500,
           Content_Capacity => 500,
           Content_Temp_C   => 20);
      Game_Items.Open_With_Can_Opener (Food);
      Drink :=
        Game_Items.Make_Container
          (Hull_Mass        => 200,
           Integrity        => 100,
           Hull_Temp_C      => 20,
           Content_State    => Game_Items.Liquid,
           Content_Mass     => 1_000,
           Content_Capacity => 1_000,
           Content_Temp_C   => 15);
      Game_Items.Open_With_Can_Opener (Drink);
      Game_Items.Add_Container (State.Pack, Food, Strength);
      Game_Items.Add_Container (State.Pack, Drink, Strength);
      State.Food_Slot := 1;
      State.Drink_Slot := 2;

      Game_Dream_RSI.Initialize_Root (State.Explore, 10.0);
      Game_Dream_RSI.Add_Node
        (State.Explore, 1, Game_Dream_RSI.Evaluated, 12.0, 1.0, Id);
      Game_Dream_RSI.Add_Node
        (State.Explore, 1, Game_Dream_RSI.Evaluated, 18.0, 1.5, Id);

      Autopilot_Human (State);
   end Start_Demo;

   procedure Walk
     (State       : in out Demo_State;
      Destination : Game_Grid.Point)
   is
      DX : Game_Ops_Room.Width_Index;
      DY : Game_Ops_Room.Depth_Index;
   begin
      if State.Human.Sleeping then
         raise Game_Actors.Asleep_Error;
      end if;
      if State.Human.AP < Game_Actors.Action_Points (Game_Turn.Walk_AP_Cost) then
         raise Insufficient_AP;
      end if;

      if State.Human_Zone = Game_Atmosphere.Cabin then
         if Integer (Destination.X) < Integer (Game_Ops_Room.Width_Index'First)
           or else Integer (Destination.X) > Integer (Game_Ops_Room.Width_Index'Last)
           or else Integer (Destination.Y) < Integer (Game_Ops_Room.Depth_Index'First)
           or else Integer (Destination.Y) > Integer (Game_Ops_Room.Depth_Index'Last)
         then
            raise Impassable_Tile;
         end if;
         DX := Game_Ops_Room.Width_Index (Destination.X);
         DY := Game_Ops_Room.Depth_Index (Destination.Y);
         if not Game_Ops_Room.Is_Passable (State.Ops, DX, DY) then
            raise Impassable_Tile;
         end if;
      end if;

      Game_Actors.Move_To (State.Human, Destination);
      declare
         Cost : constant Integer :=
           Integer (Game_Turn.Walk_AP_Cost)
           + Integer (Game_Suit.Mobility_AP_Penalty (State.Suit));
      begin
         Game_Actors.Adjust_Action_Points (State.Human, -Cost);
      end;
      Autopilot_Human (State);
   end Walk;

   procedure Strider_Walk
     (State       : in out Demo_State;
      Destination : Game_Grid.Point)
   is
   begin
      Spend_Link_AP (State, Link_Walk_AP);
      Game_Actors.Move_To (State.Strider, Destination);
      Game_Actors.Adjust_Power (State.Strider, -1);
      if State.Chassis.Power_Draw_kW < State.Chassis.Power_Budget_kW then
         State.Chassis.Power_Draw_kW := State.Chassis.Power_Draw_kW + 1;
      end if;
      Autopilot_Human (State);
   end Strider_Walk;

   procedure Strider_Turn
     (State : in out Demo_State;
      Face  : Facing)
   is
   begin
      Spend_Link_AP (State, Link_Turn_AP);
      State.Strider_Face := Face;
      Autopilot_Human (State);
   end Strider_Turn;

   procedure Strider_Scan (State : in out Demo_State) is
   begin
      Spend_Link_AP (State, Link_Scan_AP);
      Game_Actors.Adjust_Power (State.Strider, -1);
      State.Last_Scan_Vis := 0;
      Autopilot_Human (State);
   end Strider_Scan;

   procedure Eat (State : in out Demo_State) is
      Taken : Game_Items.Mass_Grams;
   begin
      if State.Human.Sleeping then
         raise Game_Actors.Asleep_Error;
      end if;
      Game_Items.Bite (State.Pack.Slots (State.Food_Slot), Taken => Taken);
      if Taken > 0 then
         Game_Actors.Adjust_Hunger (State.Human, Hunger_Per_Bite);
      end if;
      Autopilot_Human (State);
   end Eat;

   procedure Drink (State : in out Demo_State) is
      Taken : Game_Items.Mass_Grams;
   begin
      if State.Human.Sleeping then
         raise Game_Actors.Asleep_Error;
      end if;
      Game_Items.Sip (State.Pack.Slots (State.Drink_Slot), Taken => Taken);
      if Taken > 0 then
         Game_Actors.Adjust_Thirst (State.Human, Thirst_Per_Sip);
      end if;
      Autopilot_Human (State);
   end Drink;

   procedure Tick (State : in out Demo_State) is
      use type Game_Suit.Breach_Kind;
   begin
      if State.Human_Zone = Game_Atmosphere.Cabin then
         Game_ECLSS.Tick_Cabin
           (Air        => State.Cabin_Air,
            Loop_State => State.Cabin_ECLSS,
            Occupants  => 1,
            Minutes    => 1);
      end if;
      Game_Turn.Advance_Turn (State.Clock, State.Human);
      Game_Actors.Adjust_Action_Points
        (State.Strider, Integer (Game_Turn.Default_AP_Grant));
      if State.Human_Zone = Game_Atmosphere.Exterior
        and then Game_Suit.Is_Sealed_For_EVA (State.Suit)
      then
         Game_Suit.Tick_Life_Support (State.Suit, Minutes => 1);
      end if;
      if State.Suit.Breach /= Game_Suit.Intact then
         Game_Suit.Tick_Breach
           (State.Suit,
            Ambient_P_kPa => State.Exterior_Air.Pressure_kPa,
            Seconds       => 60);
      end if;
      Autopilot_Human (State);
      if not State.Human.Sleeping then
         Game_Actors.Adjust_Hunger (State.Human, -1);
         Game_Actors.Adjust_Thirst (State.Human, -1);
         Game_Actors.Adjust_Fatigue (State.Human, 1);
      end if;
   end Tick;

   procedure Sleep
     (State   : in out Demo_State;
      Minutes : Positive := 30)
   is
      Sim : Game_Dream_RSI.Discovery_Tree;
   begin
      Game_Actors.Begin_Sleep (State.Human);
      Game_Turn.Advance_Minutes (State.Clock, Minutes);
      for I in 1 .. Minutes loop
         if State.Human_Zone = Game_Atmosphere.Cabin then
            Game_ECLSS.Tick_Cabin
              (Air        => State.Cabin_Air,
               Loop_State => State.Cabin_ECLSS,
               Occupants  => 1,
               Minutes    => 1);
         end if;
         Autopilot_Human (State);
         Game_Actors.Adjust_Fatigue (State.Human, -Fatigue_Per_Sleep_Min);
      end loop;
      Sim := Game_Dream_RSI.Construct_Replay_Simulator (State.Explore);
      if Sim.Count > 0 then
         State.Policy := Game_Dream_RSI.Improve_Policy (Sim);
      end if;
   end Sleep;

   procedure Wake (State : in out Demo_State) is
   begin
      Game_Actors.Wake (State.Human);
      Autopilot_Human (State);
   end Wake;

   procedure Don_EVA (State : in out Demo_State) is
   begin
      Game_Suit.Don_Suit (State.Suit);
      Game_Suit.Don_Helmet (State.Suit);
      State.Suit.Breach := Game_Suit.Intact;
      State.Suit.Pressure_kPa := Game_Suit.EMU_Operating_P_kPa;
      State.Suit.Consciousness_S := Game_Suit.Vacuum_Consciousness_S;
   end Don_EVA;

   procedure Pierce_Suit
     (State : in out Demo_State;
      Kind  : Game_Suit.Breach_Kind)
   is
      use type Game_Suit.Breach_Kind;
   begin
      if Kind = Game_Suit.Intact then
         return;
      end if;
      Game_Suit.Pierce (State.Suit, Kind);
      Autopilot_Human (State);
   end Pierce_Suit;

   procedure Doff_Helmet (State : in out Demo_State) is
   begin
      Game_Suit.Doff_Helmet (State.Suit);
      Autopilot_Human (State);
   end Doff_Helmet;

   procedure Exit_To_Storm (State : in out Demo_State) is
   begin
      if State.Human.Sleeping then
         raise Game_Actors.Asleep_Error;
      end if;
      if not Game_Suit.Is_Sealed_For_EVA (State.Suit) then
         raise Suit_Required;
      end if;
      Game_Environment.Close_Inner (State.Lock);
      Game_Environment.Close_Outer (State.Lock);
      Game_Environment.Cycle_To_Storm (State.Lock);
      Game_Environment.Open_Outer (State.Lock);
      State.Human_Zone := Game_Atmosphere.Exterior;
      Autopilot_Human (State);
   end Exit_To_Storm;

   procedure Return_To_Cabin (State : in out Demo_State) is
   begin
      Game_Environment.Close_Outer (State.Lock);
      Game_Environment.Cycle_To_Bunker (State.Lock);
      Game_Environment.Open_Inner (State.Lock);
      State.Human_Zone := Game_Atmosphere.Cabin;
      Autopilot_Human (State);
   end Return_To_Cabin;

end Game_Demo;
