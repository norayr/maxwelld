MODULE Demo;
IMPORT maxwelld, Out;

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

PROCEDURE HandleMove(msg: maxwelld.Message);
VAR
  move: MoveMsg;
BEGIN
  move := msg(MoveMsg);  (* Type guard *)
  Out.String("Moved by ("); Out.Int(move.dx, 0);
  Out.String(","); Out.Int(move.dy, 0); Out.String(")");
  Out.Ln;
END HandleMove;

PROCEDURE HandleDraw(msg: maxwelld.Message);
VAR
  draw: DrawMsg;
BEGIN
  draw := msg(DrawMsg);  (* Type guard *)
  Out.String("Drawn with color "); Out.Int(draw.color, 0);
  Out.Ln;
END HandleDraw;

PROCEDURE Run*;
VAR
  move: MoveMsg;
  draw: DrawMsg;
  router: maxwelld.Router;
BEGIN
  router := maxwelld.Create();
  
  (* Register handlers *)
  router.Register(router, MoveMsgType, HandleMove);
  router.Register(router, DrawMsgType, HandleDraw);

  (* Send messages *)
  NEW(move); move.dx := 10; move.dy := 20;
  router.Send(router, MoveMsgType, move);

  NEW(draw); draw.color := 0FF0000H;
  router.Send(router, DrawMsgType, draw);
END Run;

BEGIN
END Demo.