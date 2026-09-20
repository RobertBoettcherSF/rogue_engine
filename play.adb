--  SPDX-License-Identifier: MIT
--  Copyright (c) 2026 Robert Boettcher
--
--  Fixed-viewport wrist map: ANSI clear+home each frame (no scroll flood).
--  Layout: ops ASCII map | status strip | keys
--  WASD/hjkl move, M glance wrist, q quit.

pragma Ada_2022;

with Ada.Text_IO;
with Ada.Integer_Text_IO;
with Ada.Characters.Latin_1;

with Game_Actors;
with Game_Atmosphere;
with Game_Demo;
with Game_Grid;
with Game_Ops_Room;
with Game_Passenger_Board;

procedure Play is
   package TIO renames Ada.Text_IO;
   package IIO renames Ada.Integer_Text_IO;
   use type Game_Ops_Room.Cell_Kind;
   use type Game_Atmosphere.Air_Zone;

   ESC : constant Character := Ada.Characters.Latin_1.ESC;

   State : Game_Demo.Demo_State;
   Key   : Character;
   Done  : Boolean := False;

   procedure Clear_Frame is
   begin
      TIO.Put (ESC & "[2J" & ESC & "[H");
   end Clear_Frame;

   function Cell_Glyph
     (Room : Game_Ops_Room.Ops_Room;
      X    : Game_Ops_Room.Width_Index;
      Y    : Game_Ops_Room.Depth_Index) return Character
   is
      C : constant Game_Ops_Room.Room_Cell :=
            Game_Ops_Room.Cell_At (Room, X, Y);
      Hx : constant Integer := Integer (State.Human.Position.X);
      Hy : constant Integer := Integer (State.Human.Position.Y);
   begin
      if Hx = Integer (X) and then Hy = Integer (Y) then
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
            return '+';
      end case;
   end Cell_Glyph;

   procedure Put_Map is
   begin
      TIO.Put_Line ("rogue_engine  @=you  #=wall  .=floor  ==console  h=seat  +=door");
      for Y in reverse Game_Ops_Room.Depth_Index loop
         for X in Game_Ops_Room.Width_Index loop
            TIO.Put (Cell_Glyph (State.Ops, X, Y));
            TIO.Put (' ');
         end loop;
         TIO.New_Line;
      end loop;
   end Put_Map;

   procedure Put_Strip is
      W : constant Game_Demo.Wrist_Readout := Game_Demo.Wrist (State);
      B : constant Game_Passenger_Board.Passenger_Board :=
            Game_Demo.Passenger_Panel (State);
      G_Tenths : constant Natural := Natural (State.Human.G_Load);
   begin
      TIO.Put_Line ("---- strip (P) ----");
      TIO.Put (Game_Passenger_Board.Status_Label (B.Cabin_Status));
      TIO.Put ("  P_kPa=");
      IIO.Put (W.Pressure_kPa, Width => 0);
      TIO.Put ("  O2_kPa=");
      IIO.Put (W.O2_Partial_kPa, Width => 0);
      TIO.Put ("  g_eff=");
      IIO.Put (G_Tenths / 10, Width => 0);
      TIO.Put ('.');
      IIO.Put (G_Tenths mod 10, Width => 0);
      TIO.Put ("  AP=");
      IIO.Put (Integer (W.AP), Width => 0);
      TIO.New_Line;
      TIO.Put ("pos ");
      IIO.Put (Integer (State.Human.Position.X), Width => 0);
      TIO.Put (',');
      IIO.Put (Integer (State.Human.Position.Y), Width => 0);
      TIO.Put ("  zone=");
      if W.Zone = Game_Atmosphere.Cabin then
         TIO.Put ("cabin");
      else
         TIO.Put ("exterior");
      end if;
      TIO.Put_Line ("  keys: WASD move  M wrist  q quit");
   end Put_Strip;

   procedure Draw is
   begin
      Clear_Frame;
      Put_Map;
      Put_Strip;
      TIO.Flush;
   end Draw;

   procedure Try_Step (DX, DY : Integer) is
      NX : constant Integer := Integer (State.Human.Position.X) + DX;
      NY : constant Integer := Integer (State.Human.Position.Y) + DY;
      Dest : Game_Grid.Point;
   begin
      if NX < Integer (Game_Ops_Room.Width_Index'First)
        or else NX > Integer (Game_Ops_Room.Width_Index'Last)
        or else NY < Integer (Game_Ops_Room.Depth_Index'First)
        or else NY > Integer (Game_Ops_Room.Depth_Index'Last)
      then
         return;
      end if;
      if not Game_Ops_Room.Is_Passable
        (State.Ops,
         Game_Ops_Room.Width_Index (NX),
         Game_Ops_Room.Depth_Index (NY))
      then
         return;
      end if;
      Dest.X := Game_Grid.Coordinate (NX);
      Dest.Y := Game_Grid.Coordinate (NY);
      begin
         Game_Demo.Walk (State, Dest);
      exception
         when Game_Demo.Insufficient_AP | Game_Demo.Impassable_Tile =>
            null;
      end;
   end Try_Step;

begin
   Game_Demo.Start_Demo (State);

   loop
      Draw;
      exit when Done;
      TIO.Get_Immediate (Key);
      case Key is
         when 'q' | 'Q' =>
            Done := True;
         when 'w' | 'W' | 'k' =>
            Try_Step (0, 1);
         when 's' | 'S' | 'j' =>
            Try_Step (0, -1);
         when 'a' | 'A' | 'h' =>
            Try_Step (-1, 0);
         when 'd' | 'D' | 'l' =>
            Try_Step (1, 0);
         when 'M' =>
            declare
               W : Game_Demo.Wrist_Readout;
            begin
               Game_Demo.Glance_Wrist (State, W);
            exception
               when Game_Demo.Glance_Failed | Game_Demo.Insufficient_AP =>
                  null;
            end;
         when others =>
            null;
      end case;
   end loop;

   Clear_Frame;
   TIO.Put_Line ("quit.");
end Play;
