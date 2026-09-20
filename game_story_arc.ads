--  SPDX-License-Identifier: MIT
--  Copyright (c) 2026 Robert Boettcher

pragma Ada_2022;

with Game_Actors;
with Game_Atmosphere;
with Game_Messages;

--  Lean Story_Arc (Story_Arc.md): phase → world profile swaps.
--  Passenger_P (P) rides Bunker → Pad → Ascent → Coast → Dock/Station.
--  STORY/ANNOUNCEMENT seed the communicator; ALERT/CAUTION stay watchdog-only
--  (never blocked by STORY; STORY never mutates SI — Advance_Phase does SI).
package Game_Story_Arc is

   --  Human role name (lean): Passenger_P / P in seeds and board copy.
   Passenger_P_Name : constant String := "Passenger_P";

   type Story_Phase is (Bunker, Pad, Ascent, Coast, Dock);

   --  Ascent peak ~3–4 g (tenths). Greyout band ~4.5+ g lives in Actors
   --  (Apply_G_Vision_Effects: >=46 → heavy dim).
   Ascent_Peak_G_Tenths : constant Game_Actors.G_Load_Tenths := 35;  -- 3.5 g

   type Arc_State is record
      Phase         : Story_Phase := Bunker;
      Cabin         : Game_Atmosphere.Tile_Atmosphere;
      Exterior      : Game_Atmosphere.Tile_Atmosphere;
      G_Load_Tenths : Game_Actors.G_Load_Tenths := 10;
      Micro_G       : Boolean := False;
   end record;

   function Phase_Name (P : Story_Phase) return String
   with Global => null;

   function Profile_For (P : Story_Phase) return Arc_State
   with Global => null;

   procedure Start_Arc
     (Arc   : out Arc_State;
      Human : in out Game_Actors.Human_Actor;
      Mail  : in out Game_Messages.Inbox;
      Dest  : String)
   with Global => null;

   --  Next phase SI swap + STORY/ANNOUNCEMENT seed. No Clear (ALERT stays).
   --  No-op at Dock.
   procedure Advance_Phase
     (Arc   : in out Arc_State;
      Human : in out Game_Actors.Human_Actor;
      Mail  : in out Game_Messages.Inbox;
      Dest  : String)
   with Global => null;

   procedure Apply_Human_Load
     (Arc   : Arc_State;
      Human : in out Game_Actors.Human_Actor)
   with Global => null;

end Game_Story_Arc;
