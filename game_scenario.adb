--  SPDX-License-Identifier: MIT
--  Copyright (c) 2026 Robert Boettcher

pragma Ada_2022;

with Game_Grid;

package body Game_Scenario is

   function Load_Scenario (Id : Scenario_Id) return Scenario_Config is
      C : Scenario_Config;
   begin
      C.Id := Id;
      C.Ops := Game_Ops_Room.Make_Default_Ops_Room;
      C.Lock :=
        (Inner                => Game_Environment.Closed,
         Outer                => Game_Environment.Closed,
         Chamber_Pressure_kPa => Game_Environment.Nominal_Bunker_Pressure);

      case Id is
         when Bunker_Rover_Storm =>
            C.Human_Floor := Positive (Game_Environment.Bunker_Floor_Depth);
            C.Outdoor_Role := Rover;
            C.Atmosphere := Bunker_Earth_Storm;
            C.Dream_RSI_On_Outdoor := True;
            C.Storm := Game_Environment.Default_Storm;
         when Titan_Flight_Control =>
            C.Human_Floor := 1;
            C.Outdoor_Role := Lander;
            C.Atmosphere := Titan_Surface;
            C.Dream_RSI_On_Outdoor := True;
            C.Storm :=
              (Pressure_kPa   => 147,
               Temp_C         => -100,
               Visibility_M   => 500,
               Radio_Says     => Game_Environment.Midday,
               Looks_Dark     => False,
               Aurora_Visible => False);
      end case;
      return C;
   end Load_Scenario;

   procedure Apply_Start
     (Config : Scenario_Config;
      Human  : out Game_Actors.Human_Actor;
      Robot  : out Game_Actors.Robot_Actor)
   is
      Seat : constant Game_Grid.Point :=
        (X => Game_Grid.Coordinate (Config.Ops.Seat_X),
         Y => Game_Grid.Coordinate (Config.Ops.Seat_Y));
   begin
      Game_Actors.Initialize_Human (Human, Seat, Speed => 1);
      Game_Actors.Initialize_Robot
        (Robot, Location => (X => 0, Y => 0), Speed => 2);
   end Apply_Start;

end Game_Scenario;
