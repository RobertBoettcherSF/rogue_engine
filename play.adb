--  SPDX-License-Identifier: MIT
--  Copyright (c) 2026 Robert Boettcher
--
--  Interactive wrist terminal: fixed viewport (clear+home each frame).
--  Layout: ASCII map | message | strip P_kPa O2_kPa g_eff uSv_h
--  Keys: WASD/hjkl move, o door, u/U suit, M inbox, n phase, f field, q quit.

pragma Ada_2022;

with Ada.Text_IO;
with Ada.Integer_Text_IO;
with Ada.Characters.Latin_1;

with Game_Atmosphere;
with Game_Demo;
with Game_Environment;
with Game_Messages;
with Game_Ops_Room;
with Game_Passenger_Board;
with Game_Story_Arc;

procedure Play is
   package TIO renames Ada.Text_IO;
   package IIO renames Ada.Integer_Text_IO;
   use type Game_Ops_Room.Cell_Kind;
   use type Game_Environment.Door_State;

   ESC : constant Character := Ada.Characters.Latin_1.ESC;

   State : Game_Demo.Demo_State;
   Arc   : Game_Story_Arc.Arc_State;
   Mail  : Game_Messages.Inbox;
   PX    : Game_Ops_Room.Width_Index := 2;
   PY    : Game_Ops_Room.Depth_Index := 3;
   Key   : Character;
   Done  : Boolean := False;
   Last_Rad : Game_Story_Arc.Dose_Rate_uSv_h :=
     Game_Story_Arc.Cabin_Rad_uSv_h;

   procedure Clear_Frame is
   begin
      TIO.Put (ESC & "[2J" & ESC & "[H");
   end Clear_Frame;

   function Door_Open_Flag
     (Kind : Game_Ops_Room.Cell_Kind) return Boolean
   is
   begin
      case Kind is
         when Game_Ops_Room.Airlock_Door =>
            return State.Lock.Inner = Game_Environment.Open;
         when Game_Ops_Room.Outer_Door =>
            return State.Lock.Outer = Game_Environment.Open;
         when others =>
            return False;
      end case;
   end Door_Open_Flag;

   --  Bind door glyph to real open flag: '+' closed, '.' open.
   function Cell_Glyph
     (Room : Game_Ops_Room.Ops_Room;
      X    : Game_Ops_Room.Width_Index;
      Y    : Game_Ops_Room.Depth_Index) return Character
   is
      C : constant Game_Ops_Room.Room_Cell := Game_Ops_Room.Cell_At (Room, X, Y);
   begin
      if X = PX and then Y = PY then
         return '@';
      end if;
      case C.Kind is
         when Game_Ops_Room.Wall =>
            return '#';
         when Game_Ops_Room.Floor =>
            return '.';
         when Game_Ops_Room.Console_Island =>
            return '=';
         when Game_Ops_Room.Operator_Seat =>
            return 'h';
         when Game_Ops_Room.Airlock_Door | Game_Ops_Room.Outer_Door =>
            if Door_Open_Flag (C.Kind) then
               return '.';
            else
               return '+';
            end if;
         when Game_Ops_Room.Suit_Hook =>
            if Room.Suit_On_Hook then
               return 'S';
            else
               return 's';
            end if;
      end case;
   end Cell_Glyph;

   function Tile_Walkable
     (Room : Game_Ops_Room.Ops_Room;
      X    : Game_Ops_Room.Width_Index;
      Y    : Game_Ops_Room.Depth_Index) return Boolean
   is
      C : constant Game_Ops_Room.Room_Cell := Game_Ops_Room.Cell_At (Room, X, Y);
   begin
      case C.Kind is
         when Game_Ops_Room.Airlock_Door | Game_Ops_Room.Outer_Door =>
            return Door_Open_Flag (C.Kind);
         when others =>
            return Game_Ops_Room.Is_Passable (Room, X, Y);
      end case;
   end Tile_Walkable;


   procedure Put_Map is
      Room : constant Game_Ops_Room.Ops_Room := State.Ops;
   begin
      TIO.Put_Line ("rogue_engine  @=P  WASD  o=door  u/U=suit  M=msg  n=phase  f=field  q=quit");
      for Y in reverse Game_Ops_Room.Depth_Index loop
         for X in Game_Ops_Room.Width_Index loop
            TIO.Put (Cell_Glyph (Room, X, Y));
         end loop;
         TIO.New_Line;
      end loop;
   end Put_Map;

   procedure Put_Message_Block is
      N     : constant Natural := Game_Messages.Active_Count (Mail);
      Slot  : Natural;
      Msg   : Game_Messages.Message;
      Lines : Natural := 0;
      Text  : String (1 .. 80);
      Len   : Natural;
   begin
      TIO.Put_Line ("---- message (max 4x80) ----");
      if N = 0 then
         TIO.Put_Line ("(inbox empty)");
         TIO.Put_Line ("");
         TIO.Put_Line ("");
         TIO.Put_Line ("");
         return;
      end if;
      Slot := Game_Messages.Active_Slot (Mail, 1);
      if Slot = 0 then
         TIO.Put_Line ("(inbox empty)");
         TIO.Put_Line ("");
         TIO.Put_Line ("");
         TIO.Put_Line ("");
         return;
      end if;
      Msg := Game_Messages.Get (Mail, Game_Messages.Slot_Index (Slot));
      declare
         Sub : constant String := Msg.Subject;
         Last : Natural := Sub'Last;
      begin
         while Last >= Sub'First and then Sub (Last) = ' ' loop
            Last := Last - 1;
         end loop;
         TIO.Put (Game_Messages.Kind_Tag (Msg.Kind));
         TIO.Put (" ");
         if Last >= Sub'First then
            TIO.Put_Line (Sub (Sub'First .. Last));
         else
            TIO.New_Line;
         end if;
      end;
      Lines := 1;
      declare
         Pay  : constant String := Msg.Payload;
         Last : Natural := Pay'Last;
         I    : Natural := Pay'First;
      begin
         while Last >= Pay'First and then Pay (Last) = ' ' loop
            Last := Last - 1;
         end loop;
         while I <= Last and then Lines < 4 loop
            Len := Natural'Min (80, Last - I + 1);
            Text := [others => ' '];
            Text (1 .. Len) := Pay (I .. I + Len - 1);
            TIO.Put_Line (Text (1 .. Len));
            I := I + Len;
            Lines := Lines + 1;
         end loop;
      end;
      while Lines < 4 loop
         TIO.New_Line;
         Lines := Lines + 1;
      end loop;
   end Put_Message_Block;

   procedure Put_Strip is
      Board : constant Game_Passenger_Board.Passenger_Board :=
                Game_Demo.Passenger_Panel (State);
      G10 : constant Natural := Natural (Board.Current_G_Tenths);
   begin
      TIO.Put_Line ("---- P strip ----");
      TIO.Put ("P_kPa=");
      IIO.Put (Board.Cabin_P_kPa, Width => 0);
      TIO.Put ("  O2_kPa=");
      IIO.Put (Board.O2_Partial_kPa, Width => 0);
      TIO.Put ("  g_eff=");
      IIO.Put (G10 / 10, Width => 0);
      TIO.Put (".");
      IIO.Put (G10 mod 10, Width => 0);
      TIO.Put ("  uSv_h=");
      TIO.Put (Game_Story_Arc.Format_Rad (Arc.Rad_uSv_h));
      TIO.Put ("  [");
      TIO.Put (Game_Story_Arc.Rad_Band_Label (Arc.Rad_uSv_h));
      TIO.Put ("]  ");
      TIO.Put (Game_Passenger_Board.Status_Label (Board.Cabin_Status));
      TIO.Put ("  phase=");
      TIO.Put_Line (Game_Story_Arc.Phase_Name (Arc.Phase));
   end Put_Strip;

   procedure Sync_Rad_Watchdog is
      Rate : constant Game_Story_Arc.Dose_Rate_uSv_h := Arc.Rad_uSv_h;
   begin
      if Rate = Last_Rad then
         return;
      end if;
      if Rate >= Game_Story_Arc.Rad_Alert_uSv_h then
         Game_Messages.Push_Watchdog
           (Mail, Game_Messages.Alert, "Radiation ALERT",
            "Dose rate elevated (ALERT). EVA / high-GCR.");
      elsif Rate >= Game_Story_Arc.Rad_Caution_uSv_h then
         Game_Messages.Push_Watchdog
           (Mail, Game_Messages.Caution, "Radiation CAUTION",
            "Dose rate elevated (CAUTION). SAA/GCR vs cabin.");
      end if;
      Last_Rad := Rate;
   end Sync_Rad_Watchdog;

   procedure Draw is
   begin
      Clear_Frame;
      Put_Map;
      Put_Message_Block;
      Put_Strip;
      TIO.Flush;
   end Draw;

   procedure Try_Open_Inner is
   begin
      Game_Environment.Close_Outer (State.Lock);
      Game_Environment.Cycle_To_Bunker (State.Lock);
      Game_Environment.Open_Inner (State.Lock);
      State.Human_Zone := Game_Atmosphere.Cabin;
   exception
      when Game_Environment.Both_Doors_Open_Error
         | Game_Environment.Pressure_Unsafe_Error =>
         null;
   end Try_Open_Inner;

   procedure Try_Open_Outer is
   begin
      Game_Demo.Exit_To_Storm (State);
   exception
      when Game_Demo.Suit_Required =>
         Game_Messages.Push_Watchdog
           (Mail, Game_Messages.Caution, "Suit required",
            "Outer door: seal EMU (u on S) before opening.");
      when Game_Environment.Both_Doors_Open_Error
         | Game_Environment.Pressure_Unsafe_Error =>
         null;
   end Try_Open_Outer;

   procedure Toggle_Door_At
     (X : Game_Ops_Room.Width_Index;
      Y : Game_Ops_Room.Depth_Index)
   is
      C : constant Game_Ops_Room.Room_Cell :=
        Game_Ops_Room.Cell_At (State.Ops, X, Y);
   begin
      case C.Kind is
         when Game_Ops_Room.Airlock_Door =>
            if State.Lock.Inner = Game_Environment.Open then
               Game_Environment.Close_Inner (State.Lock);
            else
               Try_Open_Inner;
            end if;
         when Game_Ops_Room.Outer_Door =>
            if State.Lock.Outer = Game_Environment.Open then
               Game_Demo.Return_To_Cabin (State);
               Game_Environment.Close_Inner (State.Lock);
            else
               Try_Open_Outer;
            end if;
         when others =>
            null;
      end case;
   end Toggle_Door_At;

   procedure Try_Door_Key is
      Room : constant Game_Ops_Room.Ops_Room := State.Ops;
      C    : constant Game_Ops_Room.Room_Cell :=
        Game_Ops_Room.Cell_At (Room, PX, PY);
      NX, NY : Integer;
   begin
      if C.Kind = Game_Ops_Room.Airlock_Door
        or else C.Kind = Game_Ops_Room.Outer_Door
      then
         Toggle_Door_At (PX, PY);
         return;
      end if;
      for DX in -1 .. 1 loop
         for DY in -1 .. 1 loop
            if abs DX + abs DY = 1 then
               NX := Integer (PX) + DX;
               NY := Integer (PY) + DY;
               if NX in Game_Ops_Room.Width_Index'Range
                 and then NY in Game_Ops_Room.Depth_Index'Range
               then
                  declare
                     K : constant Game_Ops_Room.Cell_Kind :=
                       Game_Ops_Room.Cell_At
                         (Room,
                          Game_Ops_Room.Width_Index (NX),
                          Game_Ops_Room.Depth_Index (NY)).Kind;
                  begin
                     if K = Game_Ops_Room.Airlock_Door
                       or else K = Game_Ops_Room.Outer_Door
                     then
                        Toggle_Door_At
                          (Game_Ops_Room.Width_Index (NX),
                           Game_Ops_Room.Depth_Index (NY));
                        return;
                     end if;
                  end;
               end if;
            end if;
         end loop;
      end loop;
   end Try_Door_Key;

   procedure Try_Don_Suit is
      C : constant Game_Ops_Room.Room_Cell :=
        Game_Ops_Room.Cell_At (State.Ops, PX, PY);
   begin
      if C.Kind /= Game_Ops_Room.Suit_Hook or else not State.Ops.Suit_On_Hook then
         return;
      end if;
      Game_Demo.Don_EVA (State);
      State.Ops.Suit_On_Hook := False;
   end Try_Don_Suit;

   procedure Try_Doff_Suit is
      C : constant Game_Ops_Room.Room_Cell :=
        Game_Ops_Room.Cell_At (State.Ops, PX, PY);
   begin
      if C.Kind /= Game_Ops_Room.Suit_Hook or else State.Ops.Suit_On_Hook then
         return;
      end if;
      if not State.Suit.Suit_Worn then
         return;
      end if;
      Game_Demo.Doff_EVA (State);
      State.Ops.Suit_On_Hook := True;
   end Try_Doff_Suit;

   procedure Try_Move (DX, DY : Integer) is
      NX : constant Integer := Integer (PX) + DX;
      NY : constant Integer := Integer (PY) + DY;
      TX : Game_Ops_Room.Width_Index;
      TY : Game_Ops_Room.Depth_Index;
      C  : Game_Ops_Room.Room_Cell;
   begin
      if NX not in Game_Ops_Room.Width_Index'Range
        or else NY not in Game_Ops_Room.Depth_Index'Range
      then
         return;
      end if;
      TX := Game_Ops_Room.Width_Index (NX);
      TY := Game_Ops_Room.Depth_Index (NY);
      C := Game_Ops_Room.Cell_At (State.Ops, TX, TY);
      if (C.Kind = Game_Ops_Room.Airlock_Door
          or else C.Kind = Game_Ops_Room.Outer_Door)
        and then not Door_Open_Flag (C.Kind)
      then
         Toggle_Door_At (TX, TY);
         return;
      end if;
      if Tile_Walkable (State.Ops, TX, TY) then
         PX := TX;
         PY := TY;
         Game_Demo.Tick (State);
         Game_Story_Arc.Tick_Sensors (Arc, State.Human, 1);
      end if;
   end Try_Move;

begin
   Game_Demo.Start_Demo (State);
   Game_Story_Arc.Start_Arc (Arc, State.Human, Mail, "station");
   PX := State.Ops.Seat_X;
   PY := State.Ops.Seat_Y;

   loop
      Sync_Rad_Watchdog;
      Draw;
      exit when Done;
      TIO.Get_Immediate (Key);
      case Key is
         when 'q' | 'Q' =>
            Done := True;
         when 'w' | 'W' | 'k' =>
            Try_Move (0, 1);
         when 's' | 'S' | 'j' =>
            Try_Move (0, -1);
         when 'a' | 'A' | 'h' =>
            Try_Move (-1, 0);
         when 'd' | 'D' | 'l' =>
            Try_Move (1, 0);
         when 'M' =>
            declare
               use type Game_Messages.Message_Kind;
               S : constant Natural := Game_Messages.Active_Slot (Mail, 1);
               M : Game_Messages.Message;
            begin
               if S /= 0 then
                  M := Game_Messages.Get (Mail, Game_Messages.Slot_Index (S));
                  if M.Kind = Game_Messages.Alert then
                     for Pass in 1 .. 2 loop
                        for I in 1 .. 3 loop
                           pragma Unreferenced (I);
                           TIO.Put_Line ("WARNING");
                           TIO.Flush;
                           delay 0.08;
                           TIO.Put_Line ("       ");
                           TIO.Flush;
                           delay 0.08;
                        end loop;
                        if Pass = 1 then
                           delay 0.25;
                        end if;
                     end loop;
                  end if;
                  Game_Messages.Mark_Read
                    (Mail, Game_Messages.Slot_Index (S));
               end if;
            end;
         when 'n' | 'N' =>
            Game_Story_Arc.Advance_Phase (Arc, State.Human, Mail, "station");
         when 'o' | 'O' =>
            Try_Door_Key;
         when 'u' =>
            Try_Don_Suit;
         when 'U' =>
            Try_Doff_Suit;
         when 'f' | 'F' =>
            if Arc.G_Load_Tenths = 0 then
               Game_Story_Arc.Set_Force_Field (Arc, State.Human, 10);
            else
               Game_Story_Arc.Set_Force_Field (Arc, State.Human, 0);
            end if;
         when others =>
            null;
      end case;
   end loop;

   Clear_Frame;
   TIO.Put_Line ("quit.");
end Play;
