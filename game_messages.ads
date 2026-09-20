--  SPDX-License-Identifier: MIT
--  Copyright (c) 2026 Robert Boettcher

pragma Ada_2022;

--  Passenger MESSAGE INBOX (Messages.md). Incoming only — list / open /
--  archive / delete. No compose.
--  Kinds lean: STORY, ANNOUNCEMENT, CAUTION, ALERT, GUIDANCE.
--  Priority (cuff): ALERT > CAUTION > ANNOUNCEMENT/GUIDANCE > STORY.
--  ALERT/CAUTION never wait on STORY. STORY never rewrites SI (kPa/s/kg).
--  Life path = raw SI + locked trips; communicator story is separate.
--  FUTURE color: ANNOUNCEMENT yellow (plain text now).
package Game_Messages is

   Max_Messages : constant := 16;
   subtype Slot_Index is Positive range 1 .. Max_Messages;

   --  Align with passenger urgency ladder (board + Messages Spec).
   type Message_Kind is (Story, Announcement, Caution, Alert, Guidance);
   type Message_Flag is (Unread, Read, Archived, Deleted);

   Subject_Length : constant := 48;
   Payload_Length    : constant := 200;

   subtype Subject_Text is String (1 .. Subject_Length);
   subtype Payload_Text is String (1 .. Payload_Length);

   type Message is record
      Kind    : Message_Kind := Story;
      Flag    : Message_Flag := Unread;
      Subject : Subject_Text := (others => ' ');
      Payload : Payload_Text := (others => ' ');
      Used    : Boolean := False;
   end record;

   type Inbox is private;

   procedure Clear (Box : out Inbox)
   with Global => null;

   --  Seed (1) welcome STORY with Planetname (2) technical-difficulties ANNOUNCEMENT.
   procedure Seed_Inbox (Box : in out Inbox; Planet : String)
   with Global => null;

   procedure Post
     (Box     : in out Inbox;
      Kind    : Message_Kind;
      Subject : String;
      Text    : String)
   with Global => null;

   --  Watchdog pushes (CAUTION / ALERT). No-op for OK/NOMINAL.
   procedure Push_Watchdog
     (Box     : in out Inbox;
      Kind    : Message_Kind;
      Subject : String;
      Text    : String)
   with Global => null,
        Pre => Kind = Caution or else Kind = Alert;

   function Active_Count (Box : Inbox) return Natural
   with Global => null;

   function Unread_Count (Box : Inbox) return Natural
   with Global => null;

   --  Nth active by cuff priority (ALERT first … STORY last); 0 if missing.
   function Active_Slot (Box : Inbox; N : Positive) return Natural
   with Global => null;

   function Get (Box : Inbox; Slot : Slot_Index) return Message
   with Global => null;

   procedure Mark_Read (Box : in out Inbox; Slot : Slot_Index)
   with Global => null;

   procedure Archive (Box : in out Inbox; Slot : Slot_Index)
   with Global => null;

   procedure Delete (Box : in out Inbox; Slot : Slot_Index)
   with Global => null;

   function Kind_Tag (K : Message_Kind) return String
   with Global => null;

   --  Cuff priority rank: higher surfaces first in Active_Slot / Put_List.
   --  ALERT=4, CAUTION=3, ANNOUNCEMENT|GUIDANCE=2, STORY=1.
   function Urgency (K : Message_Kind) return Natural
   with Global => null;

   procedure Put_List (Box : Inbox);
   procedure Put_Open (Box : in out Inbox; N : Positive);

private

   type Message_Array is array (Slot_Index) of Message;

   type Inbox is record
      Msgs : Message_Array;
   end record;

end Game_Messages;
