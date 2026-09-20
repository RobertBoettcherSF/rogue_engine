--  SPDX-License-Identifier: MIT
--  Copyright (c) 2026 Robert Boettcher

pragma Ada_2022;

with Game_Actors;
with Game_Atmosphere;
with Game_Environment;
with Game_Ops_Room;

--  Flexible starts (Spec): bunker+strider/rover storm OR Titan-style flight control
--  OR Mars surface. Atmosphere is Scenario *data* (profiles in Game_Atmosphere) --
--  not a fork of the engine.
package Game_Scenario is

   type Scenario_Id is
     (Bunker_Rover_Storm, Titan_Flight_Control, Mars_Surface_Ops);

   --  Outdoor linked machine. Strider = remote-piloted walker (clean-room);
   --  Rover kept as alias-class peer for older starts.
   type Linked_Outdoor_Role is (Rover, Strider, Lander, None);

   --  Selects exterior body profile + surface g0 (cabin stays Earth air indoors).
   type Atmosphere_Kind is
     (Bunker_Earth_Storm,  -- Earth cabin + Mars-thin 20 kPa storm demo
      Mars_Thin_Storm,     -- same 20 kPa demo profile, named explicitly
      Mars_Exterior,       -- true Mars ~0.6 kPa CO2 (1 kPa SI)
      Titan_Surface);      -- Titan ~147 kPa N2+CH4

   type Scenario_Config is record
      Id                   : Scenario_Id := Bunker_Rover_Storm;
      Human_Floor          : Positive := 4;
      Outdoor_Role         : Linked_Outdoor_Role := Strider;
      Atmosphere           : Atmosphere_Kind := Bunker_Earth_Storm;
      Surface_G_Tenths     : Game_Actors.G_Load_Tenths :=
                               Game_Atmosphere.Earth_Surface_G_Tenths;
      Dream_RSI_On_Outdoor : Boolean := True;
      Ops                  : Game_Ops_Room.Ops_Room;
      Storm                : Game_Environment.Outdoor_Storm;
      Lock                 : Game_Environment.Airlock;
   end record;

   function Load_Scenario (Id : Scenario_Id) return Scenario_Config
   with Global => null;

   --  Exterior tile air for Config.Atmosphere (same P×mix breathe path).
   function Exterior_Air
     (Kind : Atmosphere_Kind) return Game_Atmosphere.Tile_Atmosphere
   with Global => null;

   --  Planetname for passenger inbox welcome (Messages.md).
   function Destination_Planet_Name (Kind : Atmosphere_Kind) return String
   with Global => null;

   procedure Apply_Start
     (Config : Scenario_Config;
      Human  : out Game_Actors.Human_Actor;
      Robot  : out Game_Actors.Robot_Actor)
   with Global => null;

end Game_Scenario;
