MODULE Demo;
IMPORT maxwelld, Out, SYSTEM;

CONST
  MoveMsgType = 0;
  DrawMsgType = 1;

TYPE
  MoveMsg* = POINTER TO MoveMsgDesc;
  MoveMsgDesc* = RECORD (maxwelld.MessageDesc)
    dx*, dy*: LONGINT;
  END;

  DrawMsg* = POINTER TO DrawMsgDesc;
  DrawMsgDesc* = RECORD (maxwelld.MessageDesc)
    color*: LONGINT;
  END;

  MyObject* = POINTER TO MyObjectDesc;
  MyObjectDesc* = RECORD
    id: LONGINT;
  END;

PROCEDURE HandleMove(obj: SYSTEM.PTR; msg: maxwelld.Message);
VAR
  myObj: MyObject;
  move: MoveMsg;
BEGIN
  myObj := obj(MyObject);
  move := msg(MoveMsg);
  Out.String("Object "); Out.Int(myObj.id, 0);
  Out.String(" moved by ("); Out.Int(move.dx, 0);
  Out.String(","); Out.Int(move.dy, 0); Out.String(")");
  Out.Ln;
END HandleMove;

PROCEDURE HandleDraw(obj: SYSTEM.PTR; msg: maxwelld.Message);
VAR
  myObj: MyObject;
  draw: DrawMsg;
BEGIN
  myObj := obj(MyObject);
  draw := msg(DrawMsg);
  Out.String("Object "); Out.Int(myObj.id, 0);
  Out.String(" drawn with color "); Out.Int(draw.color, 0);
  Out.Ln;
END HandleDraw;

PROCEDURE Run*;
VAR
  obj1, obj2: MyObject;
  move: MoveMsg;
  draw: DrawMsg;
BEGIN
  (* Create objects *)
  NEW(obj1); obj1.id := 1;
  NEW(obj2); obj2.id := 2;

  (* Register for messages *)
  maxwelld.Register(MoveMsgType, obj1, HandleMove);
  maxwelld.Register(DrawMsgType, obj1, HandleDraw);
  maxwelld.Register(MoveMsgType, obj2, HandleMove);

  (* Create and send messages *)
  NEW(move); move.dx := 10; move.dy := 20;
  maxwelld.Send(MoveMsgType, move);

  NEW(draw); draw.color := 0FF0000H;
  maxwelld.Send(DrawMsgType, draw);
END Run;

BEGIN
END Demo.

