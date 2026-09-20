pragma Ada_2022;
with Ada.Text_IO;
with Game_Demo;
with Game_Environment;
with Game_Passenger_Board;
with Game_Suit;
procedure Tests_Demo is
 package TIO renames Ada.Text_IO;
 package D renames Game_Demo;
 package E renames Game_Environment;
 package Pb renames Game_Passenger_Board;
 package Su renames Game_Suit;
 use type Pb.Cabin_Status_Kind;
 use type E.Door_State;
 Failed, Passed : Natural := 0;
 procedure Check (Condition : Boolean; Message : String) is
 begin
  if Condition then
   Passed := Passed + 1;
   TIO.Put_Line ("PASS: " & Message);
  else
   Failed := Failed + 1;
   TIO.Put_Line ("FAIL: " & Message);
  end if;
 end Check;
 State : D.Demo_State;
 Board : Pb.Passenger_Board;
begin
 TIO.Put_Line ("=== Demo SI lock ===");
 D.Start_Demo (State);
 Board := D.Passenger_Panel (State);
 Check (Board.Cabin_P_kPa = 101, "Cabin strip P 101 before outer open");
 Check (Board.O2_Partial_kPa = 21, "Cabin strip O2p 21");
 begin
  D.Exit_To_Storm (State);
  Check (False, "Exit without suit must raise Suit_Required");
 exception
  when D.Suit_Required =>
   Check (True, "Outer exit requires sealed EMU");
 end;
 D.Don_EVA (State);
 Check (Su.Worn_Mass_kg (State.Suit) = 145, "Donned EMU worn mass 145 kg (panel)");
 Check
   (Su.Mobility_AP_Penalty (State.Suit) = Su.EMU_Worn_AP_Penalty,
    "Donned EMU mobility AP penalty (panel)");
 Check (Su.Is_Suit_Loop_Healthy (State.Suit), "EMU ~29.6 kPa pure O2 loop healthy");
 D.Exit_To_Storm (State);
 Check (State.Lock.Outer = E.Open, "Outer door open after Exit_To_Storm");
 Check (State.Lock.Inner = E.Closed, "Inner closed when outer open");
 Board := D.Passenger_Panel (State);
 Check (Board.Cabin_P_kPa = 20, "Outer open strip surface P 20 kPa");
 Check (Board.O2_Partial_kPa = 4, "Outer open strip surface O2p 4 kPa");
 Check
   (Board.Current_G_Tenths = State.Surface_G_Tenths,
    "Outer open strip g_eff from scenario");
 Check (Board.Cabin_Status = Pb.OK, "Sealed suit outer open is NOMINAL");
 Su.Doff_Suit (State.Suit);
 Board := D.Passenger_Panel (State);
 Check (Board.O2_Partial_kPa = 4, "Unsuited outer open still shows O2p 4");
 Check (Board.Cabin_Status = Pb.Fail, "Unsuited outer open Mars-thin is FAIL");
 TIO.Put_Line
   ("Summary: "
  & Natural'Image (Passed)
  & " passed,"
  & Natural'Image (Failed)
  & " failed");
 if Failed > 0 then
  raise Program_Error with "tests_demo failed";
 end if;
end Tests_Demo;
