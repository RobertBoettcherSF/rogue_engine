--  SPDX-License-Identifier: MIT
--  Copyright (c) 2026 Robert Boettcher
--
--  Interactive wrist terminal: fixed viewport (clear+home each frame).
--  Layout: ASCII map | message | strip P_kPa O2_kPa g_eff uSv_h
--  Keys: WASD/hjkl move, M inbox, n next phase (debug), q quit.

pragma Ada_2022;

with Ada.Text_IO;
with Ada.Integer_Text_IO;
with Ada.Characters.Latin_1;

with Game_Demo;
with Game_Messages;
with Game_Ops_Room;
with Game_Environment;
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
         when Game_Ops_Room.Airlock_Door =>
            --  Bunker-side airlock leaf: + closed, . open
            if State.Lock.Inner = Game_Environment.Open then
               return '.';
            else
               return '+';
            end if;
      end case;
   end Cell_Glyph;

   procedure Put_Map is
      Room : constant Game_Ops_Room.Ops_Room := State.Ops;
   begin
      TIO.Put_Line ("rogue_engine  @=P  WASD move  M=msg  n=phase  f=field  q=quit");
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
      G10 : constant Natural := Natural (Arc.G_Load_Tenths);
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
      TIO.Put ("]  phase=");
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

   procedure Try_Move (DX, DY : Integer) is
      NX : constant Integer := Integer (PX) + DX;
      NY : constant Integer := Integer (PY) + DY;
   begin
      if NX in Game_Ops_Room.Width_Index'Range
        and then NY in Game_Ops_Room.Depth_Index'Range
        and then Game_Ops_Room.Is_Passable
                   (State.Ops,
                    Game_Ops_Room.Width_Index (NX),
                    Game_Ops_Room.Depth_Index (NY))
      then
         PX := Game_Ops_Room.Width_Index (NX);
         PY := Game_Ops_Room.Depth_Index (NY);
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
