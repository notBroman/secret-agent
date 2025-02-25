/* rules */
random_dir(DirList,RandomNumber,Dir) :- (RandomNumber <= 0.25 & .nth(0,DirList,Dir)) | (RandomNumber <= 0.5 & .nth(1,DirList,Dir)) | (RandomNumber <= 0.75 & .nth(2,DirList,Dir)) | (.nth(3,DirList,Dir)).

close_in(OPTIONS, DIST, DIR) :- (DIST > 0  & .nth(1, OPTIONS, DIR)) | (.nth(0, OPTIONS, DIR)).

/* Initial beliefs */

/* Initial goals */

!start.

/* Plans */

+!start : true <- 
	.print("hello massim world.").

+step(X) : true <-
	.print("Received step percept.").
	
+actionID(X) : true <- 
	.print("Determining my action");
	!move_random.
//	skip.

+!move_random : .random(RandomNumber) & random_dir([n,s,e,w],RandomNumber,Dir)
<-	move(Dir).


+!reach_destination : goal(0,0) <- .print("We have arrived"); .update_memory; -reach_goal.
+!reach_destination : goal(X,Y) & not (Y == 0) & close_in([s, n], Y, DIR) <-
	   -destination(X, Y);
	   +destination(X, Y-1);
	   move(DIR).
+!reach_destination : goal(X, Y) & not (X == 0) & close_in([w, e], X, DIR) <-
	   -destination(X, Y);
	   +destination(X-1, Y);
	   move(DIR).

