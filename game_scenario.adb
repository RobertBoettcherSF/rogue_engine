--  SPDX-License-Identifier: MIT
--  Copyright (c) 2026 Robert Boettcher

pragma Ada_2022;

with Game_Grid;

package body Game_Scenario is


   function Destination_Planet_Name (Kind : Atmosphere_Kind) return String is
   begin
      case Kind is
         when Bunker_Earth_Storm =>
            return "Earth";
         when Mars_Thin_Storm | Mars_Exterior =>
            return "Mars";
         when Titan_Surface =>
            return "Titan";
      end case;
   end Destination_Planet_Name;

   function Exterior_Air
     (Kind : Atmosphere_Kind) return Game_Atmosphere.Tile_Atmosphere
   is
   begin
      case Kind is
         when Bunker_Earth_Storm | Mars_Thin_Storm =>
            return Game_Atmosphere.Mars_Thin_Storm_Air;
         when Mars_Exterior =>
            return Game_Atmosphere.Mars_Exterior_Air;
         when Titan_Surface =>
            return Game_Atmosphere.Titan_Exterior_Air;
      end case;
   end Exterior_Air;

   function Load_Scenario (Id : Scenario_Id) return Scenario_Config is
      C : Scenario_Config;
      Ext : Game_Atmosphere.Tile_Atmosphere;
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
            C.Outdoor_Role := Strider;
            C.Atmosphere := Bunker_Earth_Storm;
            C.Surface_G_Tenths := Game_Atmosphere.Earth_Surface_G_Tenths;
            C.Dream_RSI_On_Outdoor := True;
            C.Storm := Game_Environment.Default_Storm;
         when Titan_Flight_Control =>
            C.Human_Floor := 1;
            C.Outdoor_Role := Lander;
            C.Atmosphere := Titan_Surface;
            C.Surface_G_Tenths := Game_Atmosphere.Titan_Surface_G_Tenths;
            C.Dream_RSI_On_Outdoor := True;
            Ext := Game_Atmosphere.Titan_Exterior_Air;
            C.Storm :=
              (Pressure_kPa   => Ext.Pressure_kPa,
               Temp_C         => -100,
               Visibility_M   => 500,
               Radio_Says     => Game_Environment.Midday,
               Looks_Dark     => False,
               Aurora_Visible => False);
         when Mars_Surface_Ops =>
            C.Human_Floor := Positive (Game_Environment.Bunker_Floor_Depth);
            C.Outdoor_Role := Strider;
            C.Atmosphere := Mars_Exterior;
            C.Surface_G_Tenths := Game_Atmosphere.Mars_Surface_G_Tenths;
            C.Dream_RSI_On_Outdoor := True;
            Ext := Game_Atmosphere.Mars_Exterior_Air;
            C.Storm :=
              (Pressure_kPa   => Ext.Pressure_kPa,
               Temp_C         => -60,
               Visibility_M   => 1_000,
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
      --  Human remains at ops-room operator seat (remote pilot).
      Game_Actors.Initialize_Human (Human, Seat, Speed => 1);
      --  Outdoor linked machine (Strider / rover / lander) starts on storm pad.
      Game_Actors.Initialize_Robot
        (Robot, Location => (X => 10, Y => 10), Speed => 2);
   end Apply_Start;

end Game_Scenario;
