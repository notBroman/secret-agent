/* rules */
random_dir(DirList,RandomNumber,Dir) :- (RandomNumber <= 0.25 & .nth(0,DirList,Dir)) | (RandomNumber <= 0.5 & .nth(1,DirList,Dir)) | (RandomNumber <= 0.75 & .nth(2,DirList,Dir)) | (.nth(3,DirList,Dir)).
cardinalDirectionToNum(CardinalDir, X, Y, NX, NY) :- (CardinalDir == n & NY = Y - 1 & NX = X) | 
							(CardinalDir == s & NY = Y + 1 & NX = X ) | 
							(CardinalDir == e & NX = X + 1 & NY = Y) | 
							(CardinalDir == w & NX = X - 1 & NY = Y).

close_in(OPTIONS, DIST, DIR) :- (DIST > 0  & .nth(1, OPTIONS, DIR)) | (.nth(0, OPTIONS, DIR)).

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
	//!cullTaskList;
	!addDispensers;
	!addGoals.
	
+actionID(X) : true <- 
	.print("Determining my action");
	!think.
//	skip.

//deliberate on what to do
+!think : my_b0(X, Y) & not destination(_, _) <- +destination(X, Y); !reach_destination.
+!think : my_b1(X, Y) & not destination(_, _) <- +destination(X, Y); !reach_destination.
+!think : not my_b0(_, _) & not my_b1(_, _) <- !move_random.
+!think : destination(_,_) <- !reach_destination.
+!think : true <- true.

+!move_random : .random(RandomNumber) & random_dir([n,s,e,w],RandomNumber,Dir)
<-	move(Dir).


+!reach_destination : me(X,Y) & destination(X,Y) <- .print("We have arrived"); skip.
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
+!addDispensers : my_b0(_,_) & my_b1(_,_) <- .print("Already found my dispensers").
+!addDispensers : true <- .print("What?").

+!cullTaskList : task(_,_,_,_) & step(S) 
	<- for (task(Name,Deadline,Rew,Req)){
		if (Deadline < S) {
			-task(Name, Deadline, Rew, Req);
		}
	}.
+!cullTaskList : true <- true.

@updateMyPos[atomic]
+!updateMyPos : lastActionResult(success) & lastActionParams(ActionParams) & lastAction(move) & .nth(0, ActionParams, LastAction) & me(X,Y) & cardinalDirectionToNum(LastAction, X, Y, NX, NY)
	<- -me(X,Y); +me(NX, NY).
+!updateMyPos : true <- .print("No change").
