/* rules */
random_dir(DirList,RandomNumber,Dir) :- (RandomNumber <= 0.25 & .nth(0,DirList,Dir)) |
	(RandomNumber <= 0.5 & .nth(1,DirList,Dir)) |
	(RandomNumber <= 0.75 & .nth(2,DirList,Dir)) |
	(.nth(3,DirList,Dir)).

dealers_choice(OPTIONS,CHOICE) :- .random(OPTIONS,CHOICE).

cardinalDirToNum(CardinalDir,X,Y,NX,NY) :- 
	(CardinalDir == n & NY = Y - 1 & NX = X) |
	(CardinalDir == s & NY = Y + 1 & NX = X) |
	(CardinalDir == e & NX = X + 1 & NY = Y) |
	(CardinalDir == w & NX = X - 1 & NY = Y).

numToCardinalDir(X,Y,L) :- 
	(X > 0 & L = e) | 
	(X < 0 & L = w) |
	(Y > 0 & L = s) |
	(Y < 0 & L = n).

close_in(OPTIONS,DIST,DIR) :- (DIST > 0  & .nth(1,OPTIONS,DIR)) | (.nth(0,OPTIONS,DIR)).

adjacent_thing(L,Thing) :- 
	.findall(thing(X,Y),(thing(X,Y,Thing,T)&is_adjacent(X,Y)),List) & // find all things that are adjacent and put them into List
	not .empty(List) & .nth(0, List, thing(A,B)) &
	numToCardinalDir(A,B,L).

distance(X,Y,R) :- R = math.abs(X) + math.abs(Y).

is_adjacent(X,Y) :- distance(X,Y,R) & R == 1.

block_type(BlockDir, BlockType) :- 
	cardinalDirToNum(BlockDir, 0, 0, Nx, Ny) & 
	thing(Nx, Ny, block, BlockType).


cw_rotation(BOrientation,ROrientation) :- .nth(IDX,[s,w,n,e],BOrientation) &
	.nth(((IDX+1) mod 4 ),[s,w,n,e],ROrientation).

ccw_rotation(BOrientation,ROrientation) :- .nth(IDX,[s,e,n,w],BOrientation) &
	.nth(((IDX+1) mod 4),[s,e,n,w],ROrientation).

/* Initial beliefs */

me(0,0).
loseStreak(0).

/* Initial goals */

!start.

/* Plans */

+!start : true <- 
	.print("hello massim world.").

+step(X) : true <-
	.print("Received step percept.");
	!update;
	!!addDispensers;
	!!addGoals.
	
+actionID(X) : true <- !think.
//	skip.

//deliberate on what to do
// when to do exploration
+!think : loseStreak(X) & X > 5 <- !thisIsNotWorking.

+!think : (not attached_block(_,_) & not my_b0(_,_) & not my_b1(_,_)) | (attached_block(_,_) & not my_goal(X,Y) )
	<- !explore.
// get to the destination
+!think : destination(_,_,_) 
	<- .print("Go to destination"); !reach_destination.
+!think : not adjacent_thing(D,dispenser) & not attached_block(_,_) & (my_b0(X,Y) | my_b1(X,Y)) & not destination(_,_,_) 
	<- .print("Go to dispenser", D); +destination(X,Y,dispenser); !reach_destination.
+!think : attached_block(_,_) & my_goal(X,Y) & not me(X,Y) <- +destination(X,Y,g); !reach_destination.
// what to do when at dispenser
+!think : adjacent_thing(ListDispenser,dispenser) & not .empty(ListDispenser) & 
	(not adjacent_thing(ListBlock,block) | .empty(ListBlock))
	<- .print("At a dispenser, requesting block"); !requestBlock(ListDispenser).
+!think : adjacent_thing(D,dispenser) & not .empty(D) & not attached_block(_,_) & 
	adjacent_thing(B,block) & not lastActionResult(failed_blocked)
	<- .print("Attach block from dispenser"); attach(B).
// submission logic
+!think : attached_block(CardinalDir,BType) & not my_task(_,_) 
	<- !pickTask(BType,TaskName,Orientation); !submitTask.
+!think : my_task(_,_) 
	<- !submitTask.
// fail safe
+!think : true <- .print("(╭ರ_•́)").

+!explore : true <- !move_random.
+!move_random : .random([n,s,e,w],Dir)
	<- move(Dir).

// terminal conditions
+!reach_destination : me(Mx,My) & destination(X,Y,T) & T == dispenser & is_adjacent(X-Mx,Y-My) <- .print("We are next to a dispenser"); -destination(X,Y,T).
+!reach_destination : me(Mx,My) & destination(Mx,My,dispenser) <- !move_random.
+!reach_destination : me(X,Y) & destination(X,Y,T) & (T == g | T == avoid) <- .print("We have arrived"); -destination(X,Y,T).
// movement logic
+!reach_destination : destination(X,Y,_) & lastActionResult(success) & me(Mx,My) & not (Y == My) & close_in([n,s],Y-My,DIR) 
	<- move(DIR).
+!reach_destination : destination(X,Y,_) & me(Mx,My) & not (X == Mx) & close_in([w,e],X-Mx,DIR) 
	<- move(DIR).
+!reach_destination : true <- .print("DBG MSG"); skip.

+!addGoals : not my_goal(_,_) & goal(X,Y) & me(Mx,My)
		<- +my_goal(X + Mx,Y + My).
+!addGoals : my_goal(_,_) <- .print("Already know goals").
+!addGoals : not goal(_,_) <- .print("No goals in vision").

+!addDispensers : not my_b0(_,_) & thing(X,Y,dispenser,b0) & me(Mx,My) <- +my_b0(Mx + X,My + Y).
+!addDispensers : not my_b1(_,_) & thing(X,Y,dispenser,b1) & me(Mx,My) <- +my_b1(Mx + X,My + Y).
+!addDispensers : not thing(_,_,dispenser,_) <- .print("No dispensers in vision").
+!addDispensers : my_b0(_,_) | my_b1(_,_) <- .print("Already found my dispensers").
+!addDispensers : true <- .print("What?").

+!requestBlock(Dir) : true <- request(Dir).

// find all tasks with just one block of given type
+!pickTask(BType,TaskName,Orientation) : .findall(t(TName,X,Y),task(TName,_,_,[req(X,Y,BType)])&not claimedTask(TName),T) 
	& not .empty(T) & .nth(0,T,t(TaskName,TX,TY)) & numToCardinalDir(TX,TY,Car)
	<- .print(PickedTask); .broadcast(tell, claimedTask(TaskName)); +my_task(TaskName,s).
+!pickTask(BType,TaskName,Orientation) : .print("No applicable unclaimed task").


+!submitTask : my_task(TaskName,TOrientation) & attached_block(TOrientation,BType) <- submit(TaskName).
+!submitTask : not my_task(TaskName,_) & attached_block(BType,_) <- !pickTask(BType,TaskName,Orientation).
+!submitTask : my_task(TaskName,TOrientation) & attached_block(BOrientation,BType) & not (TOrientation == BOrientation) & cw_rotation(BOrientation,ROrientation) <-
	.print(BOrientation, "->", ROrientation);
	-attached_block(BOrientation,BType);
	+attached_block(ROrientation,BType);
	rotate(cw).
+!submitTask : true <- 
  .print("There is no block, how did we get here?").

@update[atomic]
+!update : true <- !!updateMyPos; !!updateMyAttached; !!updateMyTask.


+!updateMyPos : lastActionResult(success) & lastActionParams(ActionParams) & lastAction(move) & .nth(0,ActionParams,LastAction) & me(X,Y) & cardinalDirToNum(LastAction,X,Y,NX,NY)
	<- -me(X,Y); +me(NX,NY).
+!updateMyPos : lastActionResult(failed) & lastAction(rotate) & attached_block(Pos, B) & ccw_rotation(Pos, NPos) 
	<- -attached_block(Pos, B); +attached_block(NPos, B).
+!updateMyPos : true <- .print("No change").

+!updateMyAttached : lastActionResult(success) & lastActionParams(ActionParams) & 
			lastAction(attach) & .nth(0,ActionParams,Dir) & 
			block_type(Dir,BType) <- +attached_block(Dir,BType).
+!updateMyAttached : lastActionResult(success) & lastAction(submit) & attached_block(A, B)  <- -attached_block(A, B).
+!updateMyAttached : lastActionParams(ActionParams) & lastAction(A) & lastActionResult(R) <- .print(A, ": ", ActionParams, "<-", R).
+!updateMyAttached : true <- true.

+!updateMyTask : my_task(_,_) & lastAction(submit) & lastActionResult(success) <- -my_task(_,_).
+!updateMyTask : lastActionResult(failed_target) <- -my_task(_,_).
+!updateMyTask : true <- true.

+!countFail : not lastActionResult(success) & loseStreak(Num) <- -loseStreak(Num); +loseStreak(Num+1).
+!countFail : lastActionResult(success) <- -loseStreak(_); +loseStreak(0).
