// Agent starts
+!initiate : true <- 
    .print("Agent initializing...");
    +facing(n);
    !navigate.

// Rotation theorem handling
+!turn(clockwise) : facing(Current) <- 
    (Current == n & -facing(n) & +facing(e)) |
    (Current == e & -facing(e) & +facing(s)) |
    (Current == s & -facing(s) & +facing(w)) |
    (Current == w & -facing(w) & +facing(n)).

+!turn(counterclockwise) : facing(Current) <- 
    (Current == n & -facing(n) & +facing(w)) |
    (Current == w & -facing(w) & +facing(s)) |
    (Current == s & -facing(s) & +facing(e)) |
    (Current == e & -facing(e) & +facing(n)).

// Movement logic with rotation awareness
+!moveForward : facing(n) & position(X,Y) <- 
    -position(X,Y);
    +position(X,Y-1).

+!moveForward : facing(s) & position(X,Y) <- 
    -position(X,Y);
    +position(X,Y+1).

+!moveForward : facing(e) & position(X,Y) <- 
    -position(X,Y);
    +position(X+1,Y).

+!moveForward : facing(w) & position(X,Y) <- 
    -position(X,Y);
    +position(X-1,Y).

// Random movement choice
+!navigate : true <- 
    .random(R),
    (R =< 0.25 & +next(n)) |
    (R =< 0.5  & +next(e)) |
    (R =< 0.75 & +next(s)) |
    (+next(w)).

+!next(Dir) : facing(Dir) <- !moveForward.
+!next(Dir) : not facing(Dir) <- 
    !turn(clockwise);
    !next(Dir).

// Reach target logic
+!reach(X,Y) : position(X,Y) <- 
    .print("Arrived at destination!").

+!reach(X,Y) : position(A,B) & A < X <- 
    !next(e);
    !reach(X,Y).

+!reach(X,Y) : position(A,B) & A > X <- 
    !next(w);
    !reach(X,Y).

+!reach(X,Y) : position(A,B) & B < Y <- 
    !next(s);
    !reach(X,Y).

+!reach(X,Y) : position(A,B) & B > Y <- 
    !next(n);
    !reach(X,Y).
