--  SPDX-License-Identifier: MIT
--  Copyright (c) 2026 Robert Boettcher

pragma Ada_2022;

with Game_Actors;
with Game_Atmosphere;
with Game_Dream_RSI;
with Game_ECLSS;
with Game_Environment;
with Game_Grid;
with Game_Items;
with Game_Ops_Room;
with Game_Scenario;
with Game_Strider;
with Game_Suit;
with Game_Turn;

--  Demo: walk / eat / breathe / sleep / dream / remote Strider / suited EVA exit.
package Game_Demo is
   use type Game_Atmosphere.Air_Zone;

   Insufficient_AP : exception;
   Impassable_Tile : exception;
   Link_Down       : exception;
   Suit_Required   : exception;  -- Open_Outer / storm exit without sealed EVA

   type Facing is (North, East, South, West);

   type Demo_State is record
      Human         : Game_Actors.Human_Actor;
      Strider       : Game_Actors.Robot_Actor;
      Chassis       : Game_Strider.Chassis;
      Outdoor_Role  : Game_Scenario.Linked_Outdoor_Role :=
                        Game_Scenario.Strider;
      Ops           : Game_Ops_Room.Ops_Room;
      Pack          : Game_Items.Backpack;
      Clock         : Game_Turn.Clock;
      Cabin_Air     : Game_Atmosphere.Tile_Atmosphere;
      Exterior_Air  : Game_Atmosphere.Tile_Atmosphere;
      Cabin_ECLSS   : Game_ECLSS.Cabin_Loop;
      --  Human body zone (bunker cabin vs storm exterior). Strider is always outdoor.
      Human_Zone    : Game_Atmosphere.Air_Zone := Game_Atmosphere.Cabin;
      Suit          : Game_Suit.EVA_Suit;
      Lock          : Game_Environment.Airlock;
      Strider_Face  : Facing := North;
      Explore       : Game_Dream_RSI.Discovery_Tree;
      Policy        : Game_Dream_RSI.Exploration_Policy;
      Food_Slot     : Game_Items.Slot_Index := 1;
      Drink_Slot    : Game_Items.Slot_Index := 2;
      Last_Scan_Vis : Natural := 0;
   end record;

   Link_Walk_AP  : constant Positive := 1;
   Link_Turn_AP  : constant Positive := 1;
   Link_Scan_AP  : constant Positive := 2;

   --  Wrist / HUD display over existing typed state (no new physics).
   --  Cabin preview values track Tiangong-like Physical_Data propose.
   type Wrist_Readout is record
      Zone            : Game_Atmosphere.Air_Zone;
      Pressure_kPa    : Natural;
      O2_Percent      : Natural;
      O2_Partial_kPa  : Natural;
      CO2_Percent     : Natural;
      Tissue_O2       : Game_Actors.Tissue_Oxygenation;
      Suit_Sealed     : Boolean;
      Suit_Minutes    : Natural;
      AP              : Game_Actors.Action_Points;
   end record;

   function Wrist (State : Demo_State) return Wrist_Readout
   with Global => null;

   procedure Start_Demo (State : out Demo_State)
   with Global => null;

   --  Breathe source: cabin tile, or sealed suit loop outdoors, or storm if unsuited.
   function Human_Air
     (State : Demo_State) return Game_Atmosphere.Tile_Atmosphere
   with Global => null;

   procedure Walk
     (State       : in out Demo_State;
      Destination : Game_Grid.Point)
   with Global => null;

   procedure Strider_Walk
     (State       : in out Demo_State;
      Destination : Game_Grid.Point)
   with Global => null;

   procedure Strider_Turn
     (State : in out Demo_State;
      Face  : Facing)
   with Global => null;

   procedure Strider_Scan (State : in out Demo_State)
   with Global => null;

   procedure Eat (State : in out Demo_State)
   with Global => null;

   procedure Drink (State : in out Demo_State)
   with Global => null;

   procedure Tick (State : in out Demo_State)
   with Global => null;

   procedure Sleep
     (State   : in out Demo_State;
      Minutes : Positive := 30)
   with Global => null;

   procedure Wake (State : in out Demo_State)
   with Global => null;

   function O2_Draw_mL_Per_Min (State : Demo_State) return Positive
   with Global => null;

   --  Don / doff (helmet removable indoors; suit+helmet required to exit).
   procedure Don_EVA (State : in out Demo_State)
   with Global => null;

   procedure Doff_Helmet (State : in out Demo_State)
   with Global => null;

   --  Airlock cycle to storm then Open_Outer; requires sealed EVA.
   procedure Exit_To_Storm (State : in out Demo_State)
   with Global => null;

   --  Cycle to bunker and re-enter cabin zone.
   procedure Return_To_Cabin (State : in out Demo_State)
   with Global => null;

end Game_Demo;
