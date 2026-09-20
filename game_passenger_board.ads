--  SPDX-License-Identifier: MIT
--  Copyright (c) 2026 Robert Boettcher

pragma Ada_2022;

with Game_Actors;
with Game_Atmosphere;
with Game_Turn;

--  Passenger board computer (Passenger_Board.md Ops+DS). Calm meta panel —
--  not pilot glass. Ada keeps SI (kPa, g tenths, MET s) under the hood;
--  passenger-facing dump is plain text labels this phase.
--  SPARK: FUTURE climb — L2–L4 candidate (IRL: cabin status under g / dim vision).
--  Ada-only this phase (incl. production screenshots later); formal prove later — no gnatprove required now.
--  FUTURE color (not this phase; no ANSI yet):
--    NOMINAL / all clear     → green
--    ANNOUNCEMENT / info     → yellow
--    CAUTION (cautionary)    → orange
--    FAIL / critical alarms  → red
package Game_Passenger_Board is
   use type Game_Atmosphere.Air_Zone;

   --  Internal SI band enum; display collapses via Status_Label.
   type Cabin_Status_Kind is (OK, Caution, Fail);

   --  Priority 1 always; priority 2 may garble; dense (fuel/attitude/ECLSS
   --  rates) dropped when Vision_Clarity <= 20.
   type Passenger_Board is record
      Cabin_Status     : Cabin_Status_Kind := OK;
      Warning_Red      : Boolean := False;
      Alarm_Code       : Natural := 0;
      Current_G_Tenths : Game_Actors.G_Load_Tenths := 10;  -- display /10.0 g
      MET_Seconds      : Natural := 0;
      Cabin_P_kPa      : Natural := 101;
      O2_Partial_kPa   : Natural := 21;
      CO2_Partial_kPa  : Natural := 0;
      Vision_Clarity   : Game_Actors.Vision_Clarity_Percent := 100;
      --  When True, priority-2 lines are unreliable / sentinel.
      Priority2_Garbled : Boolean := False;
      --  Dense fuel/attitude/ECLSS rates omitted under dim vision.
      Dense_Dropped    : Boolean := False;
   end record;

   Unreadable_Sentinel : constant Natural := 999;

   --  Earth reference for Atm_Fraction display (1.00 = ~101 kPa).
   Earth_Reference_kPa : constant Natural := 101;

   --  Build from cabin air + human g/vision + MET + optional alarm.
   function Build
     (Cabin   : Game_Atmosphere.Tile_Atmosphere;
      Human   : Game_Actors.Human_Actor;
      Clock   : Game_Turn.Clock;
      Alarm   : Natural := 0) return Passenger_Board
   with Global => null;

   --  Passenger-facing label (OK→NOMINAL). Display only; SI enum unchanged.
   function Status_Label (Kind : Cabin_Status_Kind) return String
   with Global => null;

   --  Atm_Fraction hundredths (100 = 1.00 Earth). Sentinel stays sentinel.
   function Atm_Fraction_Hundredths (Cabin_P_kPa : Natural) return Natural
   with Global => null;

   --  Plain-text dump for make play / console. No ANSI this phase
   --  (FUTURE color map in package header). Text_IO side effects.
   procedure Put_Text_Dump (Board : Passenger_Board);

end Game_Passenger_Board;
