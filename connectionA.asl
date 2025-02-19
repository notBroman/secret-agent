/* Initial beliefs */

me(0,0).
current_task(0).
goal(0,0).
dispensor_0(nan, nan).
dispensor_1(nan, nan).

/* Rules */

close_in(OPTIONS, DIST, DIR) :- (DIST > 0  & .nth(1, OPTIONS, DIR)) | (.nth(0, OPTIONS, DIR)).

!start.

/* Plans */

// use the think goal to deliberate what to do
// take task
// go to dispensor
// go to submission point
// submit the task
+!think : true <- .print("(╭ರ_•́)"); skip.
// move toward dispenser
+!think : not has_block & not at_dispensor & closest_dispensor(DX, DY) & goal(X, Y)
	<- -goal(X, Y); +goal(DX, DY); !reach_goal.
// move toward submission with block
+!think : has_block & not at_submission & closest_submission(SX, SY) & goal(X, Y) 
	<- -goal(X, Y); +goal(SX, SY); !reach_goal.
// take block from dispensor
+!think : not has_block & at_dispensor & not block_adjacent 
	<- !dispense_block.
// attach to block
+!think : not has_blockk & at_dispensor & block_adjacent 
	<- !attach_block.

+!attach_block : true <- true.
+!dispense_block : true <- true.

+!start : true <- 
	.print("hello massim world.").

+!reach_goal : goal(0,0) <- .print("We have arrived"); .update_memory; -reach_goal.
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
	!think.

