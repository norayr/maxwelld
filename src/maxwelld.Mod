MODULE maxwelld;  (* Message router inspired by Maxwell's Demon *)

IMPORT SYSTEM;

CONST
  MaxMsgTypes = 128;  (* Maximum distinct message types *)

TYPE
  Message* = POINTER TO MessageDesc;
  MessageDesc* = RECORD END;  (* Base message type *)

  Handler* = PROCEDURE (msg: Message);

  Subscription* = POINTER TO SubscriptionDesc;
  SubscriptionDesc* = RECORD
    handle: Handler;      (* Message handler *)
    next: Subscription;   (* Next subscription *)
  END;

  Router* = POINTER TO RouterDesc;
  RouterDesc* = RECORD
    subscribers: ARRAY MaxMsgTypes OF Subscription;
    Register*: PROCEDURE (r: Router; msgType: LONGINT;
                          handler: Handler);
    Send*: PROCEDURE (r: Router; msgType: LONGINT; msg: Message);
  END;

(* Register object for specific message type *)
PROCEDURE Register*(r: Router; msgType: LONGINT; handler: Handler);
VAR
  sub: Subscription;
BEGIN
  ASSERT(msgType < MaxMsgTypes);
  NEW(sub);
  sub.handle := handler;
  sub.next := r.subscribers[msgType];
  r.subscribers[msgType] := sub;
END Register;

(* Send message to relevant objects *)
PROCEDURE Send*(r: Router; msgType: LONGINT; msg: Message);
VAR
  sub: Subscription;
BEGIN
  ASSERT(msgType < MaxMsgTypes);
  sub := r.subscribers[msgType];
  WHILE sub # NIL DO
    sub.handle(msg);  (* Deliver to handler *)
    sub := sub.next;
  END;
END Send;

(* Create a new router instance *)
PROCEDURE Create*(): Router;
VAR
  router: Router;
  i: LONGINT;
BEGIN
  NEW(router);
  FOR i := 0 TO MaxMsgTypes - 1 DO
    router.subscribers[i] := NIL;
  END;
  router.Register := Register;
  router.Send := Send;
  RETURN router;
END Create;

END maxwelld.
