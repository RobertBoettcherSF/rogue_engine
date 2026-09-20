--  SPDX-License-Identifier: MIT
--  Copyright (c) 2026 Robert Boettcher

pragma Ada_2022;

with Ada.Text_IO;

package body Game_Messages is

   package TIO renames Ada.Text_IO;

   Tech_Difficulties_Body : constant String :=
     "We are experiencing technical difficulties. Please observe and follow instructions from flight personnel";

   function Pad_Subject (S : String) return Subject_Text is
      R : Subject_Text := (others => ' ');
      N : constant Natural := Natural'Min (S'Length, Subject_Length);
   begin
      if N > 0 then
         R (1 .. N) := S (S'First .. S'First + N - 1);
      end if;
      return R;
   end Pad_Subject;

   function Pad_Payload (S : String) return Payload_Text is
      R : Payload_Text := (others => ' ');
      N : constant Natural := Natural'Min (S'Length, Payload_Length);
   begin
      if N > 0 then
         R (1 .. N) := S (S'First .. S'First + N - 1);
      end if;
      return R;
   end Pad_Payload;

   function Trim_Right (S : String) return String is
      L : Natural := S'Last;
   begin
      while L >= S'First and then S (L) = ' ' loop
         L := L - 1;
      end loop;
      if L < S'First then
         return "";
      end if;
      return S (S'First .. L);
   end Trim_Right;

   procedure Clear (Box : out Inbox) is
   begin
      for I in Slot_Index loop
         Box.Msgs (I).Used := False;
         Box.Msgs (I).Flag := Deleted;
         Box.Msgs (I).Kind := Story;
         Box.Msgs (I).Subject := (others => ' ');
         Box.Msgs (I).Payload := (others => ' ');
      end loop;
   end Clear;

   procedure Post
     (Box     : in out Inbox;
      Kind    : Message_Kind;
      Subject : String;
      Text    : String)
   is
   begin
      for I in Slot_Index loop
         if not Box.Msgs (I).Used or else Box.Msgs (I).Flag = Deleted then
            Box.Msgs (I) :=
              (Kind    => Kind,
               Flag    => Unread,
               Subject => Pad_Subject (Subject),
               Payload => Pad_Payload (Text),
               Used    => True);
            return;
         end if;
      end loop;
   end Post;

   procedure Seed_Inbox (Box : in out Inbox; Planet : String) is
      P : constant String :=
        (if Planet'Length = 0 then "destination" else Planet);
   begin
      Clear (Box);
      --  (1) welcome STORY (communicator / values)
      Post
        (Box,
         Story,
         "Welcome aboard",
         "Dear Passenger. Thank you for flying with Rogue Engine. "
           & "We hope you have a pleasant flight to and stay at "
           & P
           & ".");
      --  (2) technical-difficulties ANNOUNCEMENT (yellow / FUTURE)
      Post
        (Box,
         Announcement,
         "Technical difficulties",
         Tech_Difficulties_Body);
   end Seed_Inbox;

   procedure Push_Watchdog
     (Box     : in out Inbox;
      Kind    : Message_Kind;
      Subject : String;
      Text    : String)
   is
   begin
      Post (Box, Kind, Subject, Text);
   end Push_Watchdog;

   function Is_Active (M : Message) return Boolean is
   begin
      return M.Used
        and then M.Flag /= Deleted
        and then M.Flag /= Archived;
   end Is_Active;

   function Active_Count (Box : Inbox) return Natural is
      N : Natural := 0;
   begin
      for I in Slot_Index loop
         if Is_Active (Box.Msgs (I)) then
            N := N + 1;
         end if;
      end loop;
      return N;
   end Active_Count;

   function Unread_Count (Box : Inbox) return Natural is
      N : Natural := 0;
   begin
      for I in Slot_Index loop
         if Box.Msgs (I).Used and then Box.Msgs (I).Flag = Unread then
            N := N + 1;
         end if;
      end loop;
      return N;
   end Unread_Count;

   function Active_Slot (Box : Inbox; N : Positive) return Natural is
      Seen   : Natural := 0;
      Best_U : Natural;
      Best_I : Natural;
      U      : Natural;
      Taken  : array (Slot_Index) of Boolean := (others => False);
   begin
      --  Emit actives in cuff order: ALERT > CAUTION > ANNOUNCEMENT/GUIDANCE > STORY.
      --  Within same urgency, lower slot index wins (stable).
      for Pass in 1 .. Max_Messages loop
         Best_U := 0;
         Best_I := 0;
         for I in Slot_Index loop
            if Is_Active (Box.Msgs (I)) and then not Taken (I) then
               U := Urgency (Box.Msgs (I).Kind);
               if Best_I = 0
                 or else U > Best_U
                 or else (U = Best_U and then Natural (I) < Best_I)
               then
                  Best_U := U;
                  Best_I := Natural (I);
               end if;
            end if;
         end loop;
         exit when Best_I = 0;
         Taken (Slot_Index (Best_I)) := True;
         Seen := Seen + 1;
         if Seen = N then
            return Best_I;
         end if;
      end loop;
      return 0;
   end Active_Slot;

   function Get (Box : Inbox; Slot : Slot_Index) return Message is
   begin
      return Box.Msgs (Slot);
   end Get;

   procedure Mark_Read (Box : in out Inbox; Slot : Slot_Index) is
   begin
      if Box.Msgs (Slot).Used and then Box.Msgs (Slot).Flag = Unread then
         Box.Msgs (Slot).Flag := Read;
      end if;
   end Mark_Read;

   procedure Archive (Box : in out Inbox; Slot : Slot_Index) is
   begin
      if Box.Msgs (Slot).Used and then Box.Msgs (Slot).Flag /= Deleted then
         Box.Msgs (Slot).Flag := Archived;
      end if;
   end Archive;

   procedure Delete (Box : in out Inbox; Slot : Slot_Index) is
   begin
      if Box.Msgs (Slot).Used then
         Box.Msgs (Slot).Flag := Deleted;
         Box.Msgs (Slot).Used := False;
      end if;
   end Delete;


   function Urgency (K : Message_Kind) return Natural is
   begin
      case K is
         when Alert =>
            return 4;
         when Caution =>
            return 3;
         when Announcement | Guidance =>
            return 2;
         when Story =>
            return 1;
      end case;
   end Urgency;

   function Kind_Tag (K : Message_Kind) return String is
   begin
      case K is
         when Story =>
            return "STORY";
         when Announcement =>
            return "ANNOUNCEMENT";
         when Caution =>
            return "CAUTION";
         when Alert =>
            return "ALERT";
         when Guidance =>
            return "GUIDANCE";
      end case;
   end Kind_Tag;

   function Flag_Tag (F : Message_Flag) return String is
   begin
      case F is
         when Unread =>
            return "U";
         when Read =>
            return "R";
         when Archived =>
            return "A";
         when Deleted =>
            return "-";
      end case;
   end Flag_Tag;

   procedure Put_List (Box : Inbox) is
      N    : Natural := 0;
      Slot : Natural;
   begin
      TIO.Put_Line
        ("--- INBOX ---  active="
         & Natural'Image (Active_Count (Box))
         & "  unread="
         & Natural'Image (Unread_Count (Box)));
      for I in 1 .. Max_Messages loop
         Slot := Active_Slot (Box, I);
         exit when Slot = 0;
         N := N + 1;
         declare
            M : constant Message := Box.Msgs (Slot_Index (Slot));
         begin
            TIO.Put_Line
              (Natural'Image (N)
               & ". ["
               & Flag_Tag (M.Flag)
               & "] "
               & Kind_Tag (M.Kind)
               & "  "
               & Trim_Right (M.Subject));
         end;
      end loop;
      if N = 0 then
         TIO.Put_Line ("(empty)");
      end if;
      TIO.Put_Line ("1-9 open  a archive#  d delete#  b back to map");
   end Put_List;

   procedure Put_Open (Box : in out Inbox; N : Positive) is
      Slot : constant Natural := Active_Slot (Box, N);
   begin
      if Slot = 0 then
         TIO.Put_Line ("(no such message)");
         return;
      end if;
      Mark_Read (Box, Slot_Index (Slot));
      declare
         M : constant Message := Box.Msgs (Slot_Index (Slot));
      begin
         TIO.Put_Line ("--- MESSAGE ---");
         TIO.Put_Line
           ("["
            & Kind_Tag (M.Kind)
            & "] "
            & Trim_Right (M.Subject));
         TIO.Put_Line (Trim_Right (M.Payload));
         TIO.Put_Line ("--- end ---  a archive  d delete  b list");
      end;
   end Put_Open;

end Game_Messages;
