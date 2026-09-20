--  SPDX-License-Identifier: MIT
--  Copyright (c) 2026 Robert Boettcher

pragma Ada_2022;

with Game_Actors;
with Game_Atmosphere;
with Game_Messages;

--  Lean Story_Arc: phase→profile. Passenger_P (P). STORY never mutates SI.
--  Step: phase / exterior vacuum / rad. Lerp: g + cabin CO2 (ascent/coast).
package Game_Story_Arc is

   Passenger_P_Name : constant String := "Passenger_P";

   type Story_Phase is (Bunker, Pad, Ascent, Coast, Dock);

   Ascent_Peak_G_Tenths : constant Game_Actors.G_Load_Tenths := 35;
   Ascent_Lerp_Ticks    : constant Positive := 5;

   --  Live µSv/h (Physical_Data). Cabin 0 → Format_Rad "0.1".
   --  L2–L4 candidate: rad / pressure watchdog.
   subtype Dose_Rate_uSv_h is Natural;
   Cabin_Rad_uSv_h    : constant Dose_Rate_uSv_h := 0;    -- display 0.1
   Ascent_SAA_uSv_h   : constant Dose_Rate_uSv_h := 30;   -- mid 10–50
   Coast_GCR_uSv_h    : constant Dose_Rate_uSv_h := 75;   -- mid 50–100
   Dock_EVA_Rad_uSv_h : constant Dose_Rate_uSv_h := 500;  -- exterior EVA ≫
   Rad_Caution_uSv_h  : constant Dose_Rate_uSv_h := 10;
   Rad_Alert_uSv_h    : constant Dose_Rate_uSv_h := 200;

   type Arc_State is record
      Phase              : Story_Phase := Bunker;
      Cabin              : Game_Atmosphere.Tile_Atmosphere;
      Exterior           : Game_Atmosphere.Tile_Atmosphere;
      G_Load_Tenths      : Game_Actors.G_Load_Tenths := 10;
      Micro_G            : Boolean := False;
      Rad_uSv_h          : Dose_Rate_uSv_h := Cabin_Rad_uSv_h;
      Target_G_Tenths    : Game_Actors.G_Load_Tenths := 10;
      Target_CO2_Percent : Game_Atmosphere.Percent := 0;
      Lerp_Ticks_Left    : Natural := 0;
   end record;

   function Phase_Name (P : Story_Phase) return String with Global => null;
   function Profile_For (P : Story_Phase) return Arc_State with Global => null;
   function Rad_Band_Label (Rate : Dose_Rate_uSv_h) return String with Global => null;
   function Format_Rad (Rate : Dose_Rate_uSv_h) return String with Global => null;

   --  Force field = set target g_eff only (×g0 tenths). No fake units.
   procedure Set_Force_Field
     (Arc : in out Arc_State; Human : in out Game_Actors.Human_Actor;
      Target_G_Tenths : Game_Actors.G_Load_Tenths) with Global => null;

   procedure Start_Arc
     (Arc : out Arc_State; Human : in out Game_Actors.Human_Actor;
      Mail : in out Game_Messages.Inbox; Dest : String) with Global => null;

   procedure Advance_Phase
     (Arc : in out Arc_State; Human : in out Game_Actors.Human_Actor;
      Mail : in out Game_Messages.Inbox; Dest : String) with Global => null;

   procedure Tick_Sensors
     (Arc : in out Arc_State; Human : in out Game_Actors.Human_Actor;
      Steps : Positive := 1) with Global => null;

   procedure Apply_Human_Load
     (Arc : Arc_State; Human : in out Game_Actors.Human_Actor) with Global => null;

end Game_Story_Arc;
