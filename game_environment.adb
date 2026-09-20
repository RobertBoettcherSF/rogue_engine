--  SPDX-License-Identifier: MIT
--  Copyright (c) 2026 Robert Boettcher

pragma Ada_2022;

package body Game_Environment is

   function Both_Doors_Closed (A : Airlock) return Boolean is
   begin
      return A.Inner = Closed and then A.Outer = Closed;
   end Both_Doors_Closed;

   function Is_Safe_Airlock (A : Airlock) return Boolean is
   begin
      return not (A.Inner = Open and then A.Outer = Open);
   end Is_Safe_Airlock;

   procedure Open_Inner (A : in out Airlock) is
   begin
      if A.Outer = Open then
         raise Both_Doors_Open_Error;
      end if;
      if A.Chamber_Pressure_kPa /= Nominal_Bunker_Pressure then
         raise Pressure_Unsafe_Error;
      end if;
      A.Inner := Open;
   end Open_Inner;

   procedure Open_Outer (A : in out Airlock) is
   begin
      if A.Inner = Open then
         raise Both_Doors_Open_Error;
      end if;
      if A.Chamber_Pressure_kPa /= Storm_Outside_Pressure then
         raise Pressure_Unsafe_Error;
      end if;
      A.Outer := Open;
   end Open_Outer;

   procedure Close_Inner (A : in out Airlock) is
   begin
      A.Inner := Closed;
   end Close_Inner;

   procedure Close_Outer (A : in out Airlock) is
   begin
      A.Outer := Closed;
   end Close_Outer;

   procedure Cycle_To_Bunker (A : in out Airlock) is
   begin
      if not Both_Doors_Closed (A) then
         raise Both_Doors_Open_Error;
      end if;
      A.Chamber_Pressure_kPa := Nominal_Bunker_Pressure;
   end Cycle_To_Bunker;

   procedure Cycle_To_Storm (A : in out Airlock) is
   begin
      if not Both_Doors_Closed (A) then
         raise Both_Doors_Open_Error;
      end if;
      A.Chamber_Pressure_kPa := Storm_Outside_Pressure;
   end Cycle_To_Storm;

   function Capture_Satellite_Picture
     (Storm : Outdoor_Storm) return Satellite_Frame
   is
   begin
      return
        (Shows_Storm_Edge => True,
         Shows_Aurora     => Storm.Aurora_Visible,
         Ground_Visible   => False);
   end Capture_Satellite_Picture;

   function Default_Storm return Outdoor_Storm is
   begin
      return
        (Pressure_kPa   => Storm_Outside_Pressure,
         Temp_C         => Storm_Outside_Temp_C,
         Visibility_M   => Storm_Visibility_M,
         Radio_Says     => Midday,
         Looks_Dark     => True,
         Aurora_Visible => True);
   end Default_Storm;

end Game_Environment;
