/* Initial beliefs */

me(0,0).
current_task(nan).
destination(nan,nan).
attached_blocks([]).
destinations([]).

/* Rules */

close_in(OPTIONS, DIST, DIR) :- (DIST > 0  & .nth(1, OPTIONS, DIR)) | (.nth(0, OPTIONS, DIR)).
has_block :- attached_blocks(X) & not .empty(X).
at_submission :- false.
at_dispenser :- flase.
closest_dispenser(DX, DY) :- false.
closest_submission(SX, SY) :- false.


!start.

/* Plans */

// use the think destination to deliberate what to do
+!think : true <- .print("(╭ರ_•́)"); skip.
// take task
+!think : current_task(nan) <- !accept_task.
// submit the task
+!think : has_block & at_submission & not .correctConfig 
	<- !reconfig.
+!think : has_block & at_submission & .correctConfig
	<- !submit_structure.
// go to dispenser
+!think : not has_block(_) & not at_dispenser & closest_dispenser(DX, DY) & destination(X, Y)
	<- -destination(X, Y); +goal(DX, DY); !reach_goal.
// move toward submission with block
+!think : has_block(_) & not at_submission & closest_submission(SX, SY) & destination(X, Y) 
	<- -destination(X, Y); +goal(SX, SY); !reach_goal.
// take block from dispenser
+!think : not has_block & at_dispenser & not block_adjacent 
	<- !dispense_block.
// attach to block
+!think : not has_block(X) & at_dispenser & block_adjacent 
	<- !attach_block.

+!attach_block : true <- true.
+!dispense_block : true <- true.
+!accept_task : true <- true.
+!reconfig : true <- true.
+!submit_structure : true <- true.

+!start : true <- 
	.print("hello massim world.").

+!reach_destination : goal(0,0) <- .print("We have arrived"); .update_memory; -reach_goal.
+!reach_destination : goal(X,Y) & not (Y == 0) & close_in([s, n], Y, DIR) <-
	   -destination(X, Y);
	   +destination(X, Y-1);
	   move(DIR).
+!reach_destination : goal(X, Y) & not (X == 0) & close_in([w, e], X, DIR) <-
	   -destination(X, Y);
	   +destination(X-1, Y);
	   move(DIR).

+!handlePercepts(AGENTNAME) : goal(A, B) & destinations(D) <- -goal(A,B).
+!handlePercepts(AGENTNAME) : true <- .print("No goals found").

+step(X) : true & name(AGENTNAME) <-
	.print("Received step percept.");
	!handlePercepts(AGENTNAME).
	
+actionID(X) : true <- 
	.print("Determining my action");
	!think.

