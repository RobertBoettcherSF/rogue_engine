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

--  Site layout and weather: bunker (human, N floors down), sealed double-door
--  airlock, outdoor rover dust storm (Mars-like on Earth).
package Game_Environment is

   subtype Abs_Pressure_kPa is Natural range 0 .. 200;
   subtype Celsius is Integer range -100 .. 80;
   subtype Visibility_Meters is Natural range 0 .. 10_000;
   subtype Floor_Count is Positive range 1 .. 20;

   --  Human habitat depth below surface.
   Bunker_Floor_Depth : constant Floor_Count := 4;

   Nominal_Bunker_Pressure : constant Abs_Pressure_kPa := 101;
   Storm_Outside_Pressure  : constant Abs_Pressure_kPa := 20;  -- crashed
   Storm_Outside_Temp_C    : constant Celsius := -25;
   Storm_Visibility_M      : constant Visibility_Meters := 0;

   type Clock_Phase is (Night, Dawn, Midday, Dusk);

   type Outdoor_Storm is record
      Pressure_kPa     : Abs_Pressure_kPa := Storm_Outside_Pressure;
      Temp_C           : Celsius := Storm_Outside_Temp_C;
      Visibility_M     : Visibility_Meters := Storm_Visibility_M;
      Radio_Says       : Clock_Phase := Midday;
      Looks_Dark       : Boolean := True;   -- dust blacks out midday sun
      Aurora_Visible   : Boolean := True;   -- over the storm (satellite / sky)
   end record;

   type Door_State is (Closed, Open);

   --  Sealed double door: never both open (airlock invariant).
   type Airlock is record
      Inner : Door_State := Closed;  -- bunker side
      Outer : Door_State := Closed;  -- storm side
      Chamber_Pressure_kPa : Abs_Pressure_kPa := Nominal_Bunker_Pressure;
   end record;

   Both_Doors_Open_Error : exception;
   Pressure_Unsafe_Error : exception;

   function Both_Doors_Closed (A : Airlock) return Boolean
   with
     Global => null,
     Post   => Both_Doors_Closed'Result =
                 (A.Inner = Closed and then A.Outer = Closed);

   function Is_Safe_Airlock (A : Airlock) return Boolean
   with
     Global => null,
     Post   => Is_Safe_Airlock'Result =
                 (not (A.Inner = Open and then A.Outer = Open));

   procedure Open_Inner (A : in out Airlock)
   with
     Global => null,
     Pre    => A.Outer = Closed,
     Post   => A.Inner = Open and then A.Outer = Closed;

   procedure Open_Outer (A : in out Airlock)
   with
     Global => null,
     Pre    => A.Inner = Closed,
     Post   => A.Outer = Open and then A.Inner = Closed;

   procedure Close_Inner (A : in out Airlock)
   with Global => null, Post => A.Inner = Closed;

   procedure Close_Outer (A : in out Airlock)
   with Global => null, Post => A.Outer = Closed;

   --  Equalize chamber toward bunker or toward storm before opening that side.
   procedure Cycle_To_Bunker (A : in out Airlock)
   with
     Global => null,
     Pre    => Both_Doors_Closed (A),
     Post   => A.Chamber_Pressure_kPa = Nominal_Bunker_Pressure;

   procedure Cycle_To_Storm (A : in out Airlock)
   with
     Global => null,
     Pre    => Both_Doors_Closed (A),
     Post   => A.Chamber_Pressure_kPa = Storm_Outside_Pressure;

   --  High satellite still: coarse overhead despite ground visibility 0.
   type Satellite_Frame is record
      Shows_Storm_Edge : Boolean := True;
      Shows_Aurora     : Boolean := True;
      Ground_Visible   : Boolean := False;  -- dust column hides surface detail
   end record;

   function Capture_Satellite_Picture
     (Storm : Outdoor_Storm) return Satellite_Frame
   with
     Global => null,
     Post   =>
       Capture_Satellite_Picture'Result.Shows_Aurora = Storm.Aurora_Visible
       and then Capture_Satellite_Picture'Result.Ground_Visible = False;

   function Default_Storm return Outdoor_Storm
   with Global => null;

end Game_Environment;
