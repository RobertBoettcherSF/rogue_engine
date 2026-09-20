--  SPDX-License-Identifier: MIT
--  Copyright (c) 2026 Robert Boettcher

pragma Ada_2022;

with Ada.Text_IO;
with Game_Actors;
with Game_Atmosphere;
with Game_Demo;
with Game_Messages;
with Game_Grid;
with Game_Ops_Room;
with Game_Passenger_Board;
with Game_Scenario;
with Game_Suit;
with Game_Turn;

--  Wrist_Map Spec v0: lean ASCII overmap in make play (no GUI / ANSI / ncurses).
--  Same UI any surface - Scenario / Atmosphere profile supplies P, mix, g0,
--  outdoor breathable. Coords LEVEL/X/Y; course length m (1 tile = 1 m).
procedure Play is
   package TIO renames Ada.Text_IO;
   package D renames Game_Demo;
   package G renames Game_Grid;
   package R renames Game_Ops_Room;
   package Atm renames Game_Atmosphere;
   package Pb renames Game_Passenger_Board;
   package S renames Game_Scenario;
   package Msg renames Game_Messages;
   use type R.Cell_Kind;
   use type S.Atmosphere_Kind;
   use type Pb.Cabin_Status_Kind;

   Tile_Edge_M : constant := 1;

   Map_W : constant := 16;
   Map_H : constant := 10;
   subtype MX is Positive range 1 .. Map_W;
   subtype MY is Positive range 1 .. Map_H;

   type Terrain_Ch is
     (Open_Ground, Rough, Wall_Rock, Bunker_Pad, Goal_Mark);

   type Over_Cell is record
      Kind : Terrain_Ch := Open_Ground;
   end record;

   type Over_Map is array (MX, MY) of Over_Cell;

   type View_Mode is (Local_Room, Overmap_Wrist, Inbox_View);
   type Course_State is (None, Preview, Confirmed);

   type Profile_Id is (Earth_Cabin, Mars_Thin_Demo, Mars_True, Titan);

   State     : D.Demo_State;
   Cfg       : S.Scenario_Config;
   Mode      : View_Mode := Overmap_Wrist;
   Profile   : Profile_Id := Mars_Thin_Demo;
   Mail      : Msg.Inbox;
   Opened_N  : Natural := 0;
   Last_Board : Pb.Cabin_Status_Kind := Pb.OK;
   Quit      : Boolean := False;
   Key       : Character;
   World     : Over_Map;
   Level     : Integer := 0;
   PX, PY    : Integer := 3;
   CX, CY    : Integer := 3;
   GX        : constant Integer := 14;
   GY        : constant Integer := 8;
   Course    : Course_State := None;
   TX, TY    : Integer := 3;

   function Img (N : Integer) return String is
      S0 : constant String := Integer'Image (N);
   begin
      if S0'Length > 0 and then S0 (S0'First) = ' ' then
         return S0 (S0'First + 1 .. S0'Last);
      end if;
      return S0;
   end Img;

   function Img_N (N : Natural) return String is
   begin
      return Img (Integer (N));
   end Img_N;

   function Glyph (K : Terrain_Ch) return Character is
   begin
      case K is
         when Open_Ground => return '.';
         when Rough => return ',';
         when Wall_Rock => return '#';
         when Bunker_Pad => return 'B';
         when Goal_Mark => return 'G';
      end case;
   end Glyph;

   function Passable (X, Y : Integer) return Boolean is
   begin
      if X not in MX'Range or else Y not in MY'Range then
         return False;
      end if;
      return World (MX (X), MY (Y)).Kind /= Wall_Rock;
   end Passable;

   function Man_Dist (AX, AY, BX, BY : Integer) return Natural is
   begin
      return Natural (abs (AX - BX) + abs (AY - BY));
   end Man_Dist;

   function Course_Length_M return Natural is
      DX : constant Natural := Natural (abs (TX - PX));
      DY : constant Natural := Natural (abs (TY - PY));
   begin
      if Course = None then return 0; end if;
      if DX > DY then return DX * Tile_Edge_M; else return DY * Tile_Edge_M; end if;
   end Course_Length_M;

   function On_Course_Line (X, Y : Integer) return Boolean is
      SX, SY, CX0, CY0 : Integer;
      Steps : Natural;
   begin
      if Course = None then return False; end if;
      if PX = TX and then PY = TY then return X = PX and then Y = PY; end if;
      SX := 0; SY := 0;
      if TX > PX then SX := 1; elsif TX < PX then SX := -1; end if;
      if TY > PY then SY := 1; elsif TY < PY then SY := -1; end if;
      CX0 := PX; CY0 := PY; Steps := Man_Dist (PX, PY, TX, TY);
      for I in 0 .. Steps loop
         pragma Unreferenced (I);
         if CX0 = X and then CY0 = Y then return True; end if;
         if abs (TX - CX0) >= abs (TY - CY0) then CX0 := CX0 + SX; else CY0 := CY0 + SY; end if;
         if SX = 0 and then SY = 0 then exit; end if;
      end loop;
      return False;
   end On_Course_Line;

   procedure Build_Overmap is
   begin
      for Y in MY loop
         for X in MX loop
            if X = 1 or else X = Map_W or else Y = 1 or else Y = Map_H then
               World (X, Y) := (Kind => Wall_Rock);
            elsif (X + Y) mod 7 = 0 then
               World (X, Y) := (Kind => Rough);
            else
               World (X, Y) := (Kind => Open_Ground);
            end if;
         end loop;
      end loop;
      World (3, 5) := (Kind => Bunker_Pad);
      World (4, 5) := (Kind => Bunker_Pad);
      World (MX (GX), MY (GY)) := (Kind => Goal_Mark);
      PX := 3; PY := 5; CX := PX; CY := PY; Level := 0;
   end Build_Overmap;

   function Active_Kind return S.Atmosphere_Kind is
   begin
      case Profile is
         when Earth_Cabin => return S.Bunker_Earth_Storm;
         when Mars_Thin_Demo => return S.Mars_Thin_Storm;
         when Mars_True => return S.Mars_Exterior;
         when Titan => return S.Titan_Surface;
      end case;
   end Active_Kind;

   function Planet_Name return String is
   begin
      return S.Destination_Planet_Name (Active_Kind);
   end Planet_Name;

   function Profile_Name return String is
   begin
      case Profile is
         when Earth_Cabin => return "Earth-cabin";
         when Mars_Thin_Demo => return "Mars-thin-demo";
         when Mars_True => return "Mars-exterior";
         when Titan => return "Titan";
      end case;
   end Profile_Name;

   function Outdoor_Air return Atm.Tile_Atmosphere is
   begin
      return S.Exterior_Air (Active_Kind);
   end Outdoor_Air;

   function Surface_G_Tenths return Game_Actors.G_Load_Tenths is
   begin
      case Profile is
         when Earth_Cabin | Mars_Thin_Demo => return Atm.Earth_Surface_G_Tenths;
         when Mars_True => return Atm.Mars_Surface_G_Tenths;
         when Titan => return Atm.Titan_Surface_G_Tenths;
      end case;
   end Surface_G_Tenths;

   function Outdoor_Breathable return Boolean is
      Air : constant Atm.Tile_Atmosphere := Outdoor_Air;
   begin
      return Atm.In_Safe_O2_Band (Air);
   end Outdoor_Breathable;

   function G0_Text return String is
      T : constant Natural := Natural (Surface_G_Tenths);
   begin
      return Img_N (T / 10) & "." & Img_N (T mod 10);
   end G0_Text;

   procedure Put_Vitals is
      Panel : constant Pb.Passenger_Board := D.Passenger_Panel (State);
      Air   : constant Atm.Tile_Atmosphere := D.Human_Air (State);
      Ext   : constant Atm.Tile_Atmosphere := Outdoor_Air;
      AP_N  : Natural;
      Breath : constant String := (if Outdoor_Breathable then "yes" else "no-suit");
   begin
      if State.Human.AP < 0 then AP_N := 0; else AP_N := Natural (State.Human.AP); end if;
      TIO.Put_Line ("LEVEL=" & Img (Level) & "  X=" & Img (PX) & "  Y=" & Img (PY) & "  cursor X=" & Img (CX) & " Y=" & Img (CY));
      TIO.Put_Line (Pb.Status_Label (Panel.Cabin_Status) & "  cabin_P=" & Img_N (Natural (Air.Pressure_kPa)) & " kPa  O2p=" & Img_N (Atm.O2_Partial_kPa (Air)) & "  AP=" & Img_N (AP_N));
      TIO.Put_Line ("PROFILE " & Profile_Name & "  P=" & Img_N (Natural (Ext.Pressure_kPa)) & " kPa  O2%=" & Img_N (Natural (Ext.O2_Percent)) & "  g0=" & G0_Text & "  outdoor=" & Breath);
      if State.Suit.Suit_Worn or else State.Suit.Helmet_Worn then
         TIO.Put_Line ("SUIT " & Game_Suit.Alert_Label (Game_Suit.Suit_Alert_Status (State.Suit)) & "  suit_P=" & Img_N (Natural (State.Suit.Pressure_kPa)) & " kPa  breach=" & Game_Suit.Breach_Kind'Image (State.Suit.Breach) & "  cons_s=" & Img_N (State.Suit.Consciousness_S));
      end if;
   end Put_Vitals;

   procedure Put_Sidebar (Row : Integer; Map_Done : Boolean) is
      Dist_G : constant Natural := Man_Dist (PX, PY, GX, GY) * Tile_Edge_M;
      Len_M  : constant Natural := Course_Length_M;
   begin
      if not Map_Done then TIO.Put (" | "); end if;
      case Row is
         when 1 => TIO.Put_Line ("goal: ridge G");
         when 2 => TIO.Put_Line ("goal " & Img_N (Dist_G) & " m");
         when 3 =>
            case Course is
               when None => TIO.Put_Line ("course: -");
               when Preview => TIO.Put_Line ("course: PREVIEW");
               when Confirmed => TIO.Put_Line ("course: SET");
            end case;
         when 4 => TIO.Put_Line ("len " & Img_N (Len_M) & " m  ->(" & Img (TX) & "," & Img (TY) & ")");
         when 5 => TIO.Put_Line ("guide: W chart  .=step");
         when 6 => TIO.Put_Line ("pan wasd/hjkl");
         when 7 => TIO.Put_Line ("1-4 profile  m room");
         when others =>
            if not Map_Done then TIO.New_Line; end if;
      end case;
   end Put_Sidebar;

   procedure Put_Overmap is
      Ch : Character;
   begin
      TIO.Put_Line ("WRIST MAP  (1 tile = 1 m)  M=inbox  m=ops  q=quit");
      TIO.Put ("   ");
      for X in MX loop
         TIO.Put (Character'Val (Character'Pos ('0') + (X mod 10)));
      end loop;
      TIO.Put_Line (" | MONITOR");
      for Y in MY loop
         if Y < 10 then
            TIO.Put (' '); TIO.Put (Character'Val (Character'Pos ('0') + Y)); TIO.Put (' ');
         else
            TIO.Put (Img (Y)); TIO.Put (' ');
         end if;
         for X in MX loop
            if X = CX and then Y = CY and then (X /= PX or else Y /= PY) then Ch := '+';
            elsif X = PX and then Y = PY then Ch := '@';
            elsif On_Course_Line (X, Y) and then not (X = PX and then Y = PY) and then not (X = TX and then Y = TY) then
               if Course = Preview then Ch := '*'; else Ch := '='; end if;
            elsif X = TX and then Y = TY and then Course /= None then Ch := 'X';
            else Ch := Glyph (World (X, Y).Kind);
            end if;
            TIO.Put (Ch);
         end loop;
         Put_Sidebar (Y, Map_Done => False);
      end loop;
   end Put_Overmap;

   function Cell_Glyph (Room : R.Ops_Room; X : R.Width_Index; Y : R.Depth_Index) return Character is
      C : constant R.Room_Cell := R.Cell_At (Room, X, Y);
   begin
      case C.Kind is
         when R.Wall => return '#';
         when R.Floor => return '.';
         when R.Console_Island => return '=';
         when R.Operator_Seat => return '_';
         when R.Airlock_Door => return '+';
      end case;
   end Cell_Glyph;

   procedure Put_Local_Room is
      HX : constant Integer := Integer (State.Human.Position.X);
      HY : constant Integer := Integer (State.Human.Position.Y);
      Ch : Character;
   begin
      Level := -Integer (Cfg.Human_Floor);
      TIO.Put_Line ("LOCAL ops  LEVEL=" & Img (Level) & " X=" & Img (HX) & " Y=" & Img (HY) & "  m=wrist");
      for Y in R.Depth_Index loop
         for X in R.Width_Index loop
            if HX = X and then HY = Y then Ch := '@'; else Ch := Cell_Glyph (State.Ops, X, Y); end if;
            TIO.Put (Ch);
         end loop;
         TIO.New_Line;
      end loop;
      TIO.Put_Line ("move WASD/hjkl  q=quit");
   end Put_Local_Room;

   procedure Redraw is
   begin
      for I in 1 .. 10 loop TIO.New_Line; end loop;
      case Mode is
         when Inbox_View =>
            TIO.Put_Line ("MESSAGES  planet=" & Planet_Name & "  unread=" & Natural'Image (Msg.Unread_Count (Mail)) & "  M/b=map");
            if Opened_N = 0 then Msg.Put_List (Mail); else Msg.Put_Open (Mail, Opened_N); end if;
         when Overmap_Wrist => Put_Vitals; Level := 0; Put_Overmap;
         when Local_Room => Put_Vitals; Put_Local_Room;
      end case;
      TIO.Flush;
   end Redraw;

   procedure Pan (DX, DY : Integer) is
      NX : constant Integer := CX + DX;
      NY : constant Integer := CY + DY;
   begin
      if NX in MX'Range and then NY in MY'Range then CX := NX; CY := NY; end if;
   end Pan;

   procedure Chart_Or_Confirm is
   begin
      case Course is
         when None => TX := CX; TY := CY; Course := Preview;
         when Preview =>
            if CX = TX and then CY = TY then Course := Confirmed;
            else TX := CX; TY := CY; Course := Preview;
            end if;
         when Confirmed => TX := CX; TY := CY; Course := Preview;
      end case;
   end Chart_Or_Confirm;

   procedure Step_Along_Course is
      NX, NY, SX, SY : Integer := 0;
   begin
      if Course = None then return; end if;
      if PX = TX and then PY = TY then Course := None; return; end if;
      if TX > PX then SX := 1; elsif TX < PX then SX := -1; end if;
      if TY > PY then SY := 1; elsif TY < PY then SY := -1; end if;
      if abs (TX - PX) >= abs (TY - PY) then NX := PX + SX; NY := PY; else NX := PX; NY := PY + SY; end if;
      if Passable (NX, NY) then
         PX := NX; PY := NY;
         if State.Human.AP < Game_Actors.Action_Points (Game_Turn.Walk_AP_Cost) then
            Game_Turn.Advance_Turn (State.Clock, State.Human);
         end if;
         Game_Actors.Adjust_Action_Points (State.Human, -Integer (Game_Turn.Walk_AP_Cost));
         if (PX = GX and then PY = GY) or else (PX = TX and then PY = TY) then Course := None; end if;
      end if;
   end Step_Along_Course;

   procedure Try_Room_Step (DX, DY : Integer) is
      NX : constant Integer := Integer (State.Human.Position.X) + DX;
      NY : constant Integer := Integer (State.Human.Position.Y) + DY;
      Dest : G.Point;
   begin
      if NX < Integer (G.Coordinate'First) or else NX > Integer (G.Coordinate'Last)
        or else NY < Integer (G.Coordinate'First) or else NY > Integer (G.Coordinate'Last) then return;
      end if;
      Dest := (X => G.Coordinate (NX), Y => G.Coordinate (NY));
      if State.Human.AP < Game_Actors.Action_Points (Game_Turn.Walk_AP_Cost) then
         Game_Turn.Advance_Turn (State.Clock, State.Human);
      end if;
      begin
         D.Walk (State, Dest);
      exception
         when D.Impassable_Tile | Game_Actors.Invalid_Move => null;
         when D.Insufficient_AP =>
            Game_Turn.Advance_Turn (State.Clock, State.Human);
            begin
               D.Walk (State, Dest);
            exception
               when D.Impassable_Tile | Game_Actors.Invalid_Move | D.Insufficient_AP => null;
            end;
      end;
   end Try_Room_Step;

   procedure Reseed_Mail is
   begin
      Msg.Seed_Inbox (Mail, Planet_Name);
      Opened_N := 0;
   end Reseed_Mail;

   procedure Sync_Watchdog is
      Panel : constant Pb.Passenger_Board := D.Passenger_Panel (State);
   begin
      if Panel.Cabin_Status = Last_Board then return; end if;
      case Panel.Cabin_Status is
         when Pb.Caution =>
            Msg.Push_Watchdog (Mail, Msg.Caution, "Cabin CAUTION", "Passenger board reports CAUTION. Check O2/CO2 and suit.");
         when Pb.Fail =>
            Msg.Push_Watchdog (Mail, Msg.Alert, "Cabin ALERT", "Passenger board reports FAIL. Act now - hypoxia / suit risk.");
         when Pb.OK => null;
      end case;
      Last_Board := Panel.Cabin_Status;
   end Sync_Watchdog;

   procedure Apply_Profile_To_Demo is
      Ext : constant Atm.Tile_Atmosphere := Outdoor_Air;
   begin
      State.Exterior_Air := Ext;
      Cfg.Atmosphere := Active_Kind;
      Cfg.Surface_G_Tenths := Surface_G_Tenths;
      Cfg.Storm.Pressure_kPa := Ext.Pressure_kPa;
   end Apply_Profile_To_Demo;

begin
   TIO.Put_Line ("rogue_engine - Wrist_Map v0 (plain Ada; profile-swappable)");
   D.Start_Demo (State);
   Cfg := S.Load_Scenario (S.Bunker_Rover_Storm);
   Build_Overmap;
   Profile := Mars_Thin_Demo;
   Apply_Profile_To_Demo;

   while not Quit loop
      Sync_Watchdog;
      Redraw;
      TIO.Get_Immediate (Key);

      case Mode is
         when Inbox_View =>
            case Key is
               when 'q' | 'Q' => Quit := True;
               when 'b' | 'B' | 'M' =>
                  if Opened_N /= 0 then Opened_N := 0; else Mode := Overmap_Wrist; end if;
               when '1' .. '9' => Opened_N := Character'Pos (Key) - Character'Pos ('0');
               when 'a' | 'A' =>
                  if Opened_N /= 0 then
                     declare Slot : constant Natural := Msg.Active_Slot (Mail, Opened_N);
                     begin
                        if Slot /= 0 then Msg.Archive (Mail, Msg.Slot_Index (Slot)); end if;
                     end;
                     Opened_N := 0;
                  end if;
               when 'd' | 'D' =>
                  if Opened_N /= 0 then
                     declare Slot : constant Natural := Msg.Active_Slot (Mail, Opened_N);
                     begin
                        if Slot /= 0 then Msg.Delete (Mail, Msg.Slot_Index (Slot)); end if;
                     end;
                     Opened_N := 0;
                  end if;
               when others => null;
            end case;

         when Overmap_Wrist =>
            case Key is
               when 'q' | 'Q' => Quit := True;
               when 'M' => Mode := Inbox_View; Opened_N := 0;
               when 'm' => Mode := Local_Room;
               when '1' => Profile := Earth_Cabin; Apply_Profile_To_Demo; Reseed_Mail;
               when '2' => Profile := Mars_Thin_Demo; Apply_Profile_To_Demo; Reseed_Mail;
               when '3' => Profile := Mars_True; Apply_Profile_To_Demo; Reseed_Mail;
               when '4' => Profile := Titan; Apply_Profile_To_Demo; Reseed_Mail;
               when 'w' => Pan (0, -1);
               when 'W' => Chart_Or_Confirm;
               when 's' | 'j' => Pan (0, 1);
               when 'a' | 'h' => Pan (-1, 0);
               when 'd' | 'l' => Pan (1, 0);
               when 'k' => Pan (0, -1);
               when '.' | ASCII.LF | ASCII.CR =>
                  if Course = Preview then Course := Confirmed; end if;
                  Step_Along_Course;
               when 'x' | 'X' | ASCII.ESC => Course := None;
               when others => null;
            end case;

         when Local_Room =>
            case Key is
               when 'q' | 'Q' => Quit := True;
               when 'M' => Mode := Inbox_View; Opened_N := 0;
               when 'm' => Mode := Overmap_Wrist; Level := 0;
               when 'w' | 'W' | 'k' => Try_Room_Step (0, -1);
               when 's' | 'S' | 'j' => Try_Room_Step (0, 1);
               when 'a' | 'A' | 'h' => Try_Room_Step (-1, 0);
               when 'd' | 'D' | 'l' => Try_Room_Step (1, 0);
               when others => null;
            end case;
      end case;
   end loop;

   TIO.Put_Line ("Quit.");
end Play;
