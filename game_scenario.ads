--  SPDX-License-Identifier: MIT
--  Copyright (c) 2026 Robert Boettcher

pragma Ada_2022;

with Game_Actors;
with Game_Environment;
with Game_Ops_Room;

--  Flexible starts (Spec): bunker+strider/rover storm OR Titan-style flight control.
package Game_Scenario is

   type Scenario_Id is (Bunker_Rover_Storm, Titan_Flight_Control);

   --  Outdoor linked machine. Strider = remote-piloted walker (clean-room);
   --  Rover kept as alias-class peer for older starts.
   type Linked_Outdoor_Role is (Rover, Strider, Lander, None);

   type Atmosphere_Kind is (Bunker_Earth_Storm, Titan_Surface);

   type Scenario_Config is record
      Id                   : Scenario_Id := Bunker_Rover_Storm;
      Human_Floor          : Positive := 4;
      Outdoor_Role         : Linked_Outdoor_Role := Strider;
      Atmosphere           : Atmosphere_Kind := Bunker_Earth_Storm;
      Dream_RSI_On_Outdoor : Boolean := True;
      Ops                  : Game_Ops_Room.Ops_Room;
      Storm                : Game_Environment.Outdoor_Storm;
      Lock                 : Game_Environment.Airlock;
   end record;

   function Load_Scenario (Id : Scenario_Id) return Scenario_Config
   with Global => null;

   procedure Apply_Start
     (Config : Scenario_Config;
      Human  : out Game_Actors.Human_Actor;
      Robot  : out Game_Actors.Robot_Actor)
   with Global => null;

end Game_Scenario;
