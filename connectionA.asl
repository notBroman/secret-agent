/* rules */
random_dir(DirList,RandomNumber,Dir) :- (RandomNumber <= 0.25 & .nth(0,DirList,Dir)) |
	(RandomNumber <= 0.5 & .nth(1,DirList,Dir)) |
	(RandomNumber <= 0.75 & .nth(2,DirList,Dir)) |
	(.nth(3,DirList,Dir)).

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

/* Initial beliefs */

me(0,0).

/* Initial goals */

!start.

/* Plans */

+!start : true <- 
	.print("hello massim world.").

+step(X) : true <-
	.print("Received step percept.");
	!update;
	!addDispensers;
	!addGoals;
	!cullTasks.
	
+actionID(X) : true <- !think.
//	skip.

//deliberate on what to do
// when to do exploration
+!think : lastActionResult(failed_path) & lastAction(move) & me(X,Y)
	<- +destination(X+1,Y+1).
+!think : not attached_block(_,_) & not my_b0(_,_) & not my_b1(_,_) 
	<- !move_random.
+!think : attached_block(_,_) & not my_goal(X,Y) 
	<- !move_random.
// get to the destination
+!think : destination(_,_,_) 
	<- .print("Go to destination"); !reach_destination.
+!think : not adjacent_thing(D,dispenser) & not attached_block(_,_) & my_b0(X,Y) & not destination(_,_,_) 
	<- .print("Go to dispenser", D); +destination(X,Y,destination); !reach_destination.
+!think : not adjacent_thing(D,dispenser) & not attached_block(_,_) & my_b1(X,Y) & not destination(_,_,_) 
	<- .print("Go to dispenser", D); +destination(X,Y,destination); !reach_destination.
+!think : attached_block(_,_) & my_goal(X,Y) <- +destination(X,Y,g); !reach_destination.
// what to do when at dispenser
+!think : adjacent_thing(ListDispenser,dispenser) & not .empty(ListDispenser) & 
	(not adjacent_thing(ListBlock,block) | .empty(ListBlock))
	<- .print("At a dispenser, requesting block"); !requestBlock(ListDispenser).
+!think : adjacent_thing(D,dispenser) & not .empty(D) & not attached_block(_,_) & adjacent_thing(B,block) 
	<- .print("Attach block from dispenser"); attach(B).
// submission logic
+!think : attached_block(CardinalDir,BType) & not my_task(_) & pickTask(BType,TaskName,Orientation)
	<- +my_task(TaskName,Orientation); !submit_task.
+!think : my_task(_,Orientation) & lastActionResult(failed) 
	<- rotate(cw).
+!think : my_task(_,_) 
	<- !submit_task.
// fail safe
+!think : true <- .print("(╭ರ_•́)").

+!move_random : .random(RandomNumber) & random_dir([n,s,e,w],RandomNumber,Dir)
<-	move(Dir).

// terminal conditions
+!reach_destination : me(Mx,My) & destination(X,Y,T) & T == destination  & is_adjacent(X-Mx,Y-My) <- .print("We are next to a dispenser"); -destination(X,Y,T).
+!reach_destination : me(X,Y) & destination(X,Y,T) & not (T == destination) <- .print("We have arrived"); -destination(X,Y,T).
// movement logic
+!reach_destination : destination(X,Y,_) & me(Mx,My) & not (Y == My) & close_in([n,s],Y-My,DIR) <-
	   move(DIR).
+!reach_destination : destination(X,Y,_) & me(Mx,My) & not (X == Mx) & close_in([w,e],X-Mx,DIR) <-
	   move(DIR).
+!reach_destination : true <- skip.

+!addGoals : not my_goal(_,_) & goal(_,_) & me(Mx,My)
	<- for (goal(X,Y)){
		-goal(X,Y); +my_goal(X + Mx,Y + My);
	}.
+!addGoals : my_goal(_,_) <- .print("Already know goals").
+!addGoals : not goal(_,_) <- .print("No goals in vision").

+!addDispensers : not my_b0(_,_) & thing(X,Y,dispenser,b0) & me(Mx,My) <- +my_b0(Mx + X,My + Y).
+!addDispensers : not my_b1(_,_) & thing(X,Y,dispenser,b1) & me(Mx,My) <- +my_b1(Mx + X,My + Y).
+!addDispensers : not thing(_,_,dispenser,_) <- .print("No dispensers in vision").
+!addDispensers : my_b0(_,_) | my_b1(_,_) <- .print("Already found my dispensers").
+!addDispensers : true <- .print("What?").

+!requestBlock(Dir) : true <- request(Dir).

// find all tasks with just one block of given type
+!pickTask() : .findall()

@update[atomic]
+!update : true <- !updateMyPos; !updateMyAttached.

+!updateMyPos : lastActionResult(success) & lastActionParams(ActionParams) & lastAction(move) & .nth(0,ActionParams,LastAction) & me(X,Y) & cardinalDirToNum(LastAction,X,Y,NX,NY)
	<- -me(X,Y); +me(NX,NY).
+!updateMyPos : true <- .print("No change").

+!updateMyAttached : lastActionResult(success) & lastActionParams(ActionParams) & 
			lastAction(attach) & .nth(0,ActionParams,Dir) & 
			block_type(Dir,BType) <- +attached_block(Dir,BType).
+!updateMyAttached : lastActionResult(success) & lastAction(submit) & attached_block(A, B)  <- -attached_block(A, B).
+!updateMyAttached : lastActionParams(ActionParams) & lastAction(A) & lastActionResult(R) <- .print(A, ": ", ActionParams, "<-", R).
+!updateMyAttached : true <- true.
