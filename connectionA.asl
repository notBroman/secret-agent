/* rules */
random_dir(DirList,RandomNumber,Dir) :- (RandomNumber <= 0.25 & .nth(0,DirList,Dir)) | (RandomNumber <= 0.5 & .nth(1,DirList,Dir)) | (RandomNumber <= 0.75 & .nth(2,DirList,Dir)) | (.nth(3,DirList,Dir)).
cardinalDirectionToNum(CardinalDir, X, Y, NX, NY) :- (CardinalDir == n & NY = Y - 1 & NX = X) |
							(CardinalDir == s & NY = Y + 1 & NX = X) |
							(CardinalDir == e & NX = X + 1 & NY = Y) |
							(CardinalDir == w & NX = X - 1 & NY = Y).

close_in(OPTIONS, DIST, DIR) :- (DIST > 0  & .nth(1, OPTIONS, DIR)) | (.nth(0, OPTIONS, DIR)).

adjacent_disp(L) :- .findall( thing(X, Y, D, T), (math.abs(X) + math.abs(Y) == 1), L ).

distance(X, Y, R) :- R = math.abs(X) + math.abs(Y).

is_adjacent(X,Y) :- distance(X, Y, R) & R == 1.

/* Initial beliefs */

me(0,0).

/* Initial goals */

!start.

/* Plans */

+!start : true <- 
	.print("hello massim world.").

+step(X) : true <-
	.print("Received step percept.");
	!updateMyPos;
	!addDispensers;
	!addGoals.
	
+actionID(X) : true | adjacent_disp(L) <-
	.print(L);
	!think.
//	skip.

//deliberate on what to do
// get to the destination
+!think : destination(_, _) <- .print("Go to destination"); !reach_destination.
+!think : not adjacent_Thing(_, dispenser) & not attached(_) & my_b0(X, Y) & not destination(_, _) <- .print("Go to dispenser"); +destination(X, Y); !reach_destination.
+!think : not adjacent_Thing(_, dispenser) & not attached(_) & my_b1(X, Y) & not destination(_, _) <- .print("Go to dispenser"); +destination(X, Y); !reach_destination.
+!think : not adjacent_Thing(_, dispenser) & not my_b0(_, _) & not my_b1(_, _) <- !move_random.
+!think : attached(_) & my_goal(X, Y) <- destination(X,Y).
// what to do when at dispenser
+!think : adjacent_Thing(ListDispenser, dispeneser) & not adjacent_Thing(_, block) <- .print("At a dispenser, requesting block"); !requestBlock(ListDispenser).
+!think : adjacent_Thing(_, dispenser) & not attached(_) & adjacent_Thing(List,block) & .nth(0, List, B) <- .print("Attach block from dispenser"); attach(B).
+!think : true <- true.

+!move_random : .random(RandomNumber) & random_dir([n,s,e,w],RandomNumber,Dir)
<-	move(Dir).


+!reach_destination : thing(Dx, Dy, dispenser, _) & destination(X,Y) & (my_b0(X, Y) | my_b1(X, Y)) & is_adjacent(Dx, Dy) <- .print("We are next to a dispenser"); -destination(X, Y).
+!reach_destination : me(X,Y) & destination(X,Y) <- .print("We have arrived"); -destination(X, Y).
+!reach_destination : destination(X,Y) & me(Mx, My) & not (Y == My) & close_in([n, s], Y-My, DIR) <-
	   move(DIR).
+!reach_destination : destination(X, Y) & me(Mx, My) & not (X == Mx) & close_in([w, e], X-Mx, DIR) <-
	   move(DIR).
+!reach_destination : true <- skip.

+!addGoals : not my_goal(_,_) & goal(_,_) & me(Mx, My)
	<- for (goal(X,Y)){
		-goal(X,Y); +my_goal(X + Mx, Y + My);
	}.
+!addGoals : my_goal(_,_) <- .print("Already know goals").
+!addGoals : not goal(_,_) <- .print("No goals in vision").

+!addDispensers : not my_b0(_,_) & thing(X,Y,dispenser,b0) & me(Mx, My) <- +my_b0(Mx + X, My + Y).
+!addDispensers : not my_b1(_,_) & thing(X,Y,dispenser,b1) & me(Mx, My) <- +my_b1(Mx + X, My + Y).
+!addDispensers : not thing(_,_,dispenser,_) <- .print("No dispensers in vision").
+!addDispensers : my_b0(_,_) | my_b1(_,_) <- .print("Already found my dispensers").
+!addDispensers : true <- .print("What?").

+!requestBlock(ListHopper) : .nth(0, ListHopper, Dir) <- request(Dir).

@updateMyPos[atomic]
+!updateMyPos : lastActionResult(success) & lastActionParams(ActionParams) & lastAction(move) & .nth(0, ActionParams, LastAction) & me(X,Y) & cardinalDirectionToNum(LastAction, X, Y, NX, NY)
	<- -me(X,Y); +me(NX, NY).
+!updateMyPos : true <- .print("No change").
