--  SPDX-License-Identifier: MIT
--  Copyright (c) 2026 Robert Boettcher
--
--  Permission is hereby granted, free of charge, to any person obtaining a copy
--  of this software and associated documentation files (the "Software"), to deal
--  in the Software without restriction, including without limitation the rights
--  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--  copies of the Software, and to permit persons to whom the Software is
--  furnished to do so, subject to the following conditions:
--
--  The above copyright notice and this permission notice shall be included in
--  all copies or substantial portions of the Software.
--
--  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--  SOFTWARE.

pragma Ada_2022;

with Game_Actors;
with Game_Environment;
with Game_Ops_Room;

--  Flexible starts (Spec): bunker+rover storm OR Titan-style flight control.
package Game_Scenario is

   type Scenario_Id is (Bunker_Rover_Storm, Titan_Flight_Control);

   type Linked_Outdoor_Role is (Rover, Lander, None);

   type Atmosphere_Kind is (Bunker_Earth_Storm, Titan_Surface);

   type Scenario_Config is record
      Id                   : Scenario_Id := Bunker_Rover_Storm;
      Human_Floor          : Positive := 4;
      Outdoor_Role         : Linked_Outdoor_Role := Rover;
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
