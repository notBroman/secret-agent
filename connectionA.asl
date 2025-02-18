/* Initial beliefs and rules */

current_task(0).

seen([]).

close_in(OPTIONS, DIST, DIR) :- (DIST > 0  & .nth(1, OPTIONS, DIR)) | (.nth(0, OPTIONS, DIR)).
goal(1,1).

/* Initial goals */

!start.

/* Plans */

+!start : true <- 
	.print("hello massim world.").

+!reach_goal : goal(0,0) <- .print("We have arrived").
+!reach_goal : goal(X,Y) & not (Y == 0) & close_in([s, n], Y, DIR) <-
	   -goal(X, Y);
	   +goal(X, Y-1);
	   move(DIR).
+!reach_goal : goal(X, Y) & not (X == 0) & close_in([w, e], X, DIR) <-
	   -goal(X, Y);
	   +goal(X-1, Y);
	   move(DIR).


+step(X) : true <-
	.print("Received step percept.").
	
+actionID(X) : true <- 
	.print("Determining my action");
	!reach_goal.

