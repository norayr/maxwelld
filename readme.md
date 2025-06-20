# maxwelld: Message Routing for Oberon (Inspired by Maxwell's Demon)

>Entropy-reducing message router for Oberon - routes messages only to interested objects, avoiding wasteful broadcasts.

Inspired by [Maxwell's Demon](https://en.wikipedia.org/wiki/Maxwell%2527s_demon), this module efficiently routes messages to relevant objects instead of broadcasting to everyone, reducing computational "entropy" in your Oberon programs.

## Why maxwelld?

Traditional Oberon message handling uses broadcast approach:

```
WHILE p # NIL DO p.meaow(p); p := p.next END
```

or

```
PROCEDURE Broadcast(VAR msg: Message);
VAR f: Figure;
BEGIN
  f := root; (*root is a global variable in the base module*)
  WHILE f # NIL DO f.handle(f, msg); f := f.next END
END Broadcast;
```

The handler is installed in the field handle of every object of type Rectangle.

```
PROCEDURE Handle(f: Figure; VAR msg: Message);
VAR r: Rectangle;
BEGIN r := f(Rectangle);
  IF msg IS DrawMsg THEN (*draw rectangle r*)
  ELSIF msg IS MarkMsg THEN MarkRectangle(r, msg(MarkMsg).on)
  ELSIF msg IS MoveMsg THEN
  INC(r.x, msg(MoveMsg).x); INC(r.y, msg(MoveMsg).y)
  ELSIF …
  END
END Handle
```

or

```
PROCEDURE Handle(f: Figure; VAR msg: Message);
VAR r: Rectangle;
BEGIN r := f(Rectangle);
  CASE msg OF
    DrawMsg: (*draw rectangle r*) |
    MarkMsg: MarkRectangle(r, msg(MarkMsg).on) |
    MoveMsg: INC(r.x, msg(MoveMsg).x); INC(r.y, msg(MoveMsg).y)
  END
END Handle
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

# maxwelld Performance Analysis: Broadcast vs Selective Routing

## The Real Complexity Picture

### Broadcast Approach (Traditional)
```oberon
WHILE f # NIL DO 
  f.handle(f, msg);  (* Every object checks message type *)
  f := f.next 
END
```

**Complexity**: Always **O(N)** where N = total objects in system
- Every object receives every message
- Each object's handler must check message type
- No matter how many objects care about the message

### maxwelld Approach (Selective)
```oberon
sub := router.subscribers[msgType];
WHILE sub # NIL DO
  sub.handle(sub.obj, msg);  (* Only interested objects *)
  sub := sub.next;
END
```

**Complexity**: **O(S)** where S = subscribers for this specific message type
- Only objects that registered for this message type are notified
- No message type checking needed (already filtered)
- S is typically much smaller than N

## Performance Comparison Table

| Scenario | Total Objects (N) | Subscribers (S) | Broadcast Checks | maxwelld Checks | Speedup |
|----------|-------------------|-----------------|------------------|-----------------|---------|
| **Single Subscriber** | 100 | 1 | 100 | 1 | 100x |
| **Few Subscribers** | 100 | 5 | 100 | 5 | 20x |
| **Many Subscribers** | 100 | 25 | 100 | 25 | 4x |
| **Most Subscribe** | 100 | 80 | 100 | 80 | 1.25x |
| **All Subscribe** | 100 | 100 | 100 | 100 | 1x |

## Real-World Scenarios

### GUI Application (1000 objects)
```
Message Type          | Typical Subscribers | Broadcast | maxwelld | Speedup
---------------------|--------------------|-----------|-----------|---------
MouseClick           | 10-20 buttons      | 1000      | 15       | 67x
KeyPress             | 1-3 input fields   | 1000      | 2        | 500x
WindowResize         | 5-10 containers    | 1000      | 8        | 125x
TimerTick            | 50-100 animations  | 1000      | 75       | 13x
```

### Game Engine (5000 objects)
```
Message Type          | Typical Subscribers | Broadcast | maxwelld | Speedup
---------------------|--------------------|-----------|-----------|---------
CollisionDetection   | 200 physics bodies | 5000      | 200      | 25x
RenderUpdate         | 800 visible objects| 5000      | 800      | 6.25x
AIUpdate             | 50 AI entities     | 5000      | 50       | 100x
PlayerInput          | 1 player object    | 5000      | 1        | 5000x
```

## Why maxwelld Wins

### 1. **Selective Notification**
- Broadcast: "Hey everyone, here's a message - figure out if you care"
- maxwelld: "Hey interested parties, here's your message"

### 2. **No Type Checking Overhead**
```oberon
(* Broadcast handler - every object does this *)
IF msg IS DrawMsg THEN (* ... *)
ELSIF msg IS MoveMsg THEN (* ... *)
ELSIF msg IS CollisionMsg THEN (* ... *)
END

(* maxwelld handler - already filtered *)
PROCEDURE HandleMove(obj: SYSTEM.PTR; msg: Message);
BEGIN
  (* We know it's a MoveMsg, no checking needed *)
END
```

### 3. **Cache Locality**
- Broadcast: Jumps around memory visiting all objects
- maxwelld: Traverses focused subscription list (better cache usage)

## The Mathematics

**Broadcast cost**: `N × (type_check_cost + handler_cost)`
**maxwelld cost**: `S × handler_cost + lookup_cost`

Where:
- N = total objects in system
- S = subscribers for specific message type  
- lookup_cost ≈ O(1) array access
- type_check_cost = multiple IF/CASE statements per object
- handler_cost = actual message processing

**Speedup formula**: `(N × type_check_cost) / S`

## When maxwelld Doesn't Help

1. **Universal messages**: If every object needs every message (S ≈ N)
2. **Tiny systems**: With only 2-3 objects, overhead isn't worth it
3. **Single message type**: If you only ever send one type of message

## Memory Trade-off

**maxwelld memory overhead**: 
- Subscription records: `S × (pointer + handler + next)`
- Router arrays: `MaxMsgTypes × pointer`
- Typically small compared to object data

**Benefit**: Eliminates wasted CPU cycles that scale with system size

## Bottom Line

maxwelld's advantage grows with:
- ✅ Larger number of total objects (N)
- ✅ Smaller ratio of interested objects (S/N)
- ✅ More complex type checking in handlers
- ✅ Diverse message types with different audiences

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


![](https://upload.wikimedia.org/wikipedia/commons/thumb/0/0b/Maxwell%2527s_demon.svg/440px-Maxwell%2527s_demon.svg.png)

## License

GPL
