// Initial beliefs
me(0,0).
loseStreak(0).

// Initial goals
!start.

// Plans
+!start : true <-
    .print("hello massim world.").

+step(X) : true <-
    .print("Received step percept.");
    !update;
    !addDispensers;
    !addGoals.

+actionID(X) : true <- !think.

// Deliberate on what to do
+!think : loseStreak(X) & X > 5 <- !thisIsNotWorking.
+!think : lastActionResult(failed_path) & lastAction(move) & me(X,Y)
    <- +destination(X+1,Y+1).
+!think : not attached_block(_,_) & not my_b0(_,_) & not my_b1(_,_)
    <- !explore.
+!think : attached_block(_,_) & not my_goal(X,Y)
    <- .print("Attached block but no goal seen, exploring..."); !explore.
+!think : destination(_,_,_)
    <- .print("Go to destination"); !reach_destination.
+!think : not adjacent_thing(D,dispenser) & not attached_block(_,_) & my_b0(X,Y) & not destination(_,_,_)
    <- .print("Go to dispenser", D); +destination(X,Y,dispenser); !reach_destination.
+!think : not adjacent_thing(D,dispenser) & not attached_block(_,_) & my_b1(X,Y) & not destination(_,_,_)
    <- .print("Go to dispenser", D); +destination(X,Y,dispenser); !reach_destination.
+!think : attached_block(_,_) & my_goal(X,Y) & not me(X,Y)
    <- +destination(X,Y,g); !reach_destination.
+!think : adjacent_thing(ListDispenser,dispenser) & not .empty(ListDispenser) &
    (not adjacent_thing(ListBlock,block) | .empty(ListBlock))
    <- .print("At a dispenser, requesting block"); !requestBlock(ListDispenser).
+!think : adjacent_thing(D,dispenser) & not .empty(D) & not attached_block(_,_) &
    adjacent_thing(B,block) & not lastActionResult(failed_blocked)
    <- .print("Attach block from dispenser"); attach(B).
+!think : attached_block(CardinalDir,BType) & not my_task(_,_)
    <- !pickTask(BType,TaskName,Orientation); !submitTask.
+!think : my_task(_,Orientation) & lastActionResult(failed) & lastAction(submit)
    <- rotate(cw).
+!think : my_task(_,_)
    <- !submitTask.
+!think : true <- .print("(╭ರ_•́)").


+!explore : not explore(_) <- !setexplore.

@explore[atomic]     
+!explore: explore(Dir) & me(X,Y) <-
    // Check if the current explore direction is still valid
    if(Dir = n & (boundary(Y-1, n) | thing(X,Y-1,obstacle,_))){
        .print("Explore: Direction n invalid, calling setexplore");
        -explore(_);
        !setexplore;
    } elif(Dir = s & (boundary(Y+1, s) | thing(X,Y+1,obstacle,_))){
        .print("Explore: Direction s invalid, calling setexplore");
        -explore(_);
        !setexplore;
    } elif(Dir = e & (boundary(X+1, e) | thing(X+1,Y,obstacle,_))){
        .print("Explore: Direction e invalid, calling setexplore");
        -explore(_);
        !setexplore;
    } elif(Dir = w & (boundary(X-1, w) | thing(X-1,Y,obstacle,_))){
        .print("Explore: Direction w invalid, calling setexplore");
        -explore(_);
        !setexplore;
    } else {
        .print("Explore: Valid direction", Dir, "- moving");
        move(Dir)
    }.

+!setexplore: .random(N) & random_dir([n,s,e,w],N,Dir) & me(X,Y) <-
    .print("setexplore: random number =", N, "chosen Dir =", Dir);
    -explore(_);
    if(Dir = n & not (boundary(Y-1, n)) & not (thing(X,Y-1,obstacle,_))) {
        .print("setexplore: setting direction n");
        +explore(n);
    } elif(Dir = s & not (boundary(Y+1, s)) & not (thing(X,Y+1,obstacle,_))) {
        .print("setexplore: setting direction s");
        +explore(s);
    } elif(Dir = e & not (boundary(X+1, e)) & not (thing(X+1,Y,obstacle,_))) {
        .print("setexplore: setting direction e");
        +explore(e);
    } elif(Dir = w & not (boundary(X-1, w)) & not (thing(X-1,Y,obstacle,_))) {
        .print("setexplore: setting direction w");
        +explore(w);
    } else{
        .print("setexplore: invalid Dir", Dir, "retrying...");
        !setexplore;   
    }.

// movement logic
+!reach_destination : me(Mx,My) & destination(X,Y,T) & T == dispenser & is_adjacent(X-Mx,Y-My)
    <- .print("We are next to a dispenser"); -destination(X,Y,T).
+!reach_destination : me(X,Y) & destination(X,Y,T) & T == g
    <- .print("We have arrived"); -destination(X,Y,T).
+!reach_destination : destination(X,Y,_) & me(Mx,My) & not (Y == My) & close_in([n,s],Y-My,DIR)
    <- move(DIR).
+!reach_destination : destination(X,Y,_) & me(Mx,My) & not (X == Mx) & close_in([w,e],X-Mx,DIR)
    <- move(DIR).
+!reach_destination : me(Mx,My) & (my_b0(X,Y) | my_b1(X,Y))
    <- !move_random.
+!reach_destination : true <- .print("DBG MSG"); skip.
+!addGoals : not my_goal(_,_) & goal(X,Y) & me(Mx,My)
    <- +my_goal(X + Mx,Y + My).
+!addGoals : not my_goal(_,_) & not goal(_,_) & attached_block(_, _)
    <- .print("No visible goal while holding block; exploring for goal."); !explore.
+!addGoals : my_goal(_,_) <- .print("Already know goals").
+!addGoals : not goal(_,_) <- .print("No goals in vision").

+!addDispensers : not my_b0(_,_) & thing(X,Y,dispenser,b0) & me(Mx,My)
    <- +my_b0(Mx + X,My + Y).
+!addDispensers : not my_b1(_,_) & thing(X,Y,dispenser,b1) & me(Mx,My)
    <- +my_b1(Mx + X,My + Y).
+!addDispensers : not thing(_,_,dispenser,_) <- .print("No dispensers in vision").
+!addDispensers : my_b0(_,_) | my_b1(_,_) <- .print("Already found my dispensers").
+!addDispensers : true <- .print("What?").

+!requestBlock(Dir) : true <- request(Dir).

// find all tasks with just one block of given type
+!pickTask(BType,TaskName,Orientation) : .findall(t(TName,X,Y), task(TName,_,_,[req(X,Y,BType)]) & not claimedTask(TName), T)
    & not .empty(T) & .nth(0,T, t(TaskName,TX,TY)) & numToCardinalDir(TX,TY,Car)
    <- .print("PickedTask:", TaskName); .broadcast(tell, claimedTask(TaskName)); +my_task(TaskName,s).
+!pickTask(BType,TaskName,Orientation) : .findall(t(TName,X,Y), task(TName,_,_,[req(X,Y,BType)]), T)
    <- .print("why: [] - No available tasks for block type", BType); !explore.

+!submitTask : my_task(TaskName,_) <- submit(TaskName).
+!submitTask : not my_task(TaskName,_) & attached_block(BType,_) <- !pickTask(BType,TaskName,Orientation).
+!submitTask : true <- .print("There is no block, how did we get here?").

@update[atomic]
+!update : true <- !updateMyPos; !updateMyAttached; !updateMyTask.

+!updateMyPos : lastActionResult(success) & lastActionParams(ActionParams) &
                 lastAction(move) & .nth(0,ActionParams,LastAction) & me(X,Y) &
                 cardinalDirToNum(LastAction,X,Y,NX,NY)
    <- -me(X,Y); +me(NX,NY).
+!updateMyPos : true <- .print("No change").

+!updateMyAttached : lastActionResult(success) & lastActionParams(ActionParams) &
                      lastAction(attach) & .nth(0,ActionParams,Dir) &
                      block_type(Dir,BType)
    <- +attached_block(Dir,BType).
+!updateMyAttached : lastActionResult(success) & lastAction(submit) & attached_block(A, B)
    <- -attached_block(A, B).
+!updateMyAttached : lastActionParams(ActionParams) & lastAction(A) & lastActionResult(R)
    <- .print(A, ": ", ActionParams, "<-", R).
+!updateMyAttached : true <- true.

+!updateMyTask : my_task(_,_) & lastAction(submit) & lastActionResult(success)
    <- -my_task(_,_).
+!updateMyTask : true <- true.

+!countFail : not lastActionResult(success) & loseStreak(Num)
    <- -loseStreak(Num); +loseStreak(Num+1).
+!countFail : lastActionResult(success)
    <- -loseStreak(_); +loseStreak(0).

// Utility predicates
random_dir(DirList,RandomNumber,Dir) :- 
    (RandomNumber <= 0.25 & .nth(0,DirList,Dir)) |
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

close_in(OPTIONS,DIST,DIR) :- 
    (DIST > 0  & .nth(1,OPTIONS,DIR)) | (.nth(0,OPTIONS,DIR)).

adjacent_thing(L,Thing) :-
    .findall(thing(X,Y), (thing(X,Y,Thing,T) & is_adjacent(X,Y)), List) &
    not .empty(List) & .nth(0, List, thing(A,B)) &
    numToCardinalDir(A,B,L).

distance(X,Y,R) :- R = math.abs(X) + math.abs(Y).

is_adjacent(X,Y) :- distance(X,Y,R) & R == 1.

block_type(BlockDir, BlockType) :-
    cardinalDirToNum(BlockDir, 0, 0, Nx, Ny) &
    thing(Nx, Ny, block, BlockType).



