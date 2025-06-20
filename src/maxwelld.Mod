MODULE maxwelld;  (* Message router inspired by Maxwell's Demon *)

IMPORT SYSTEM;

CONST
  MaxMsgTypes = 32;  (* Maximum distinct message types *)

TYPE
  Message* = POINTER TO MessageDesc;
  MessageDesc* = RECORD END;  (* Base message type *)

  Handler* = PROCEDURE (obj: SYSTEM.PTR; msg: Message);

  Subscription* = POINTER TO SubscriptionDesc;
  SubscriptionDesc* = RECORD
    obj: SYSTEM.PTR;      (* Object pointer *)
    handle: Handler;      (* Message handler *)
    next: Subscription;   (* Next subscription *)
  END;

  Router* = POINTER TO RouterDesc;
  RouterDesc* = RECORD
    subscribers: ARRAY MaxMsgTypes OF Subscription;
  END;

VAR
  router*: Router;  (* Global router instance *)

(* Initialize router *)
PROCEDURE Init*;
BEGIN
  NEW(router);
END Init;

(* Register object for specific message type *)
PROCEDURE Register*(msgType: LONGINT; obj: SYSTEM.PTR; handler: Handler);
VAR
  sub: Subscription;
BEGIN
  ASSERT(msgType < MaxMsgTypes);
  NEW(sub);
  sub.obj := obj;
  sub.handle := handler;
  sub.next := router.subscribers[msgType];
  router.subscribers[msgType] := sub;
END Register;

(* Send message to relevant objects *)
PROCEDURE Send*(msgType: LONGINT; msg: Message);
VAR
  sub: Subscription;
BEGIN
  ASSERT(msgType < MaxMsgTypes);
  sub := router.subscribers[msgType];
  WHILE sub # NIL DO
    sub.handle(sub.obj, msg);  (* Deliver to subscriber *)
    sub := sub.next;
  END;
END Send;

BEGIN
  Init;
END maxwelld.

