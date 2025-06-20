# maxwelld: Message Routing for Oberon (Inspired by Maxwell's Demon)

>Entropy-reducing message router for Oberon - routes messages only to interested objects, avoiding wasteful broadcasts.

Inspired by [Maxwell's Demon](https://en.wikipedia.org/wiki/Maxwell%2527s_demon), this module efficiently routes messages to relevant objects instead of broadcasting to everyone, reducing computational "entropy" in your Oberon programs.

## Why maxwelld?

Traditional Oberon message handling uses broadcast approach:

```
(* Broadcast to ALL objects *)
FOR EACH object DO
  object.handle(msg)
END
```

This forces every object to check if the message is relevant, wasting CPU cycles (especially with many objects).

maxwelld solves this by acting as a smart router:

```
maxwelld.Register(object, MsgType, handler);
maxwelld.Send(MsgType, msg); (* Only relevant objects notified *)
```

## Key Features

* 🚀 Efficient message routing - No wasteful broadcasts

* 🔗 Decoupled architecture - Objects don't know about each other

* 🧩 Extensible design - Add new message types anytime

*  ⚡️ Lightweight - Pure Oberon implementation

* 🔒 Type-safe - Oberon's type system ensures correctness


## Installation

Add maxwelld.Mod to your Oberon project

Import in your modules:

```
IMPORT maxwelld;
```

## Usage

1. Define Message Types

```
CONST
  MoveMsgType = 0;
  DrawMsgType = 1;

TYPE
  MoveMsg* = POINTER TO MoveMsgDesc;
  MoveMsgDesc* = RECORD (maxwelld.MessageDesc)
    dx*, dy*: INTEGER;
  END;
```

2. Create Object Handlers

```
PROCEDURE HandleMove(obj: SYSTEM.PTR; msg: maxwelld.Message);
VAR
  myObj: MyObject;
  move: MoveMsg;
BEGIN
  myObj := obj(MyObject); (* Type guard *)
  move := msg(MoveMsg);
  (* Process movement *)
END HandleMove;
```

3. Register Objects

```
VAR obj: MyObject;
BEGIN
  NEW(obj);
  maxwelld.Register(MoveMsgType, obj, HandleMove);
END;
```

4. Send Messages

```
VAR move: MoveMsg;
BEGIN
  NEW(move);
  move.dx := 10; move.dy := 20;
  maxwelld.Send(MoveMsgType, move);
END;
```

## Benchmark Comparison
Approach  10 objects  100 objects  1000 objects
Broadcast  10 checks  100 checks  1000 checks
maxwelld  1 check  1 check  1 check

(Message delivery to a single subscriber

## Real-World Example

```
MODULE PhysicsDemo;
IMPORT maxwelld, Out;

CONST
  CollisionMsgType = 0;
  GravityMsgType = 1;

TYPE
  CollisionMsg* = POINTER TO CollisionMsgDesc;
  CollisionMsgDesc* = RECORD (maxwelld.MessageDesc)
    objectId*, force*: INTEGER;
  END;

  PhysicsBody* = POINTER TO PhysicsBodyDesc;
  PhysicsBodyDesc* = RECORD
    id: INTEGER;
    mass: REAL;
  END;

PROCEDURE HandleCollision(obj: SYSTEM.PTR; msg: maxwelld.Message);
VAR body: PhysicsBody; col: CollisionMsg;
BEGIN
  body := obj(PhysicsBody);
  col := msg(CollisionMsg);
  IF body.id = col.objectId THEN
    Out.String("Body "); Out.Int(body.id, 0);
    Out.String(" collided with force "); Out.Int(col.force, 0);
    Out.Ln;
  END;
END HandleCollision;

PROCEDURE Run*;
VAR
  body1, body2: PhysicsBody;
  colMsg: CollisionMsg;
BEGIN
  NEW(body1); body1.id := 1; body1.mass := 2.5;
  NEW(body2); body2.id := 2; body2.mass := 1.8;

  maxwelld.Register(CollisionMsgType, body1, HandleCollision);
  maxwelld.Register(CollisionMsgType, body2, HandleCollision);

  (* Simulate collision with body2 *)
  NEW(colMsg); colMsg.objectId := 2; colMsg.force := 42;
  maxwelld.Send(CollisionMsgType, colMsg);
END Run;

BEGIN
END PhysicsDemo.
```

## How It Works: The Maxwell's Demon Analogy

* Objects register their interest (like particles entering the chamber)

* maxwelld monitors message types (like the demon watching particles)

* Only relevant messages are routed (like only fast particles allowed through)

* System entropy decreases as wasted computation is eliminated


![]https://upload.wikimedia.org/wikipedia/commons/thumb/0/0b/Maxwell%2527s_demon.svg/440px-Maxwell%2527s_demon.svg.png)

## License

GPL
