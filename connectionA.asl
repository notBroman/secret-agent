/* Initial beliefs and rules */

current_task(0).

seen([]).

close_in(OPTIONS, DIST, DIR) :- (DIST > 0  & .nth(1, OPTIONS, DIR)) | (.nth(0, OPTIONS, DIR)).
choose_dir(Rand, DIR) :- (RAND < 0.5 & close_in([w, e], goal_x, DIR)) | close_in([s, n], goal_y, DIR).
goal_x(1).
goal_y(1).

/* Initial goals */

!start.
!reach_goal.

/* Plans */

+!start : true <- 
	.print("hello massim world.").

+!reach_goal : goal_x = 0 & goal_y = 0 <- true.
+!reach_goal : goal_x = 0 & not goal_y = 0 
	<- close_in([s, n], goal_y, DIR); !move(DIR).
+!reach_goal : not goal_x = 0 & goal_y = 0 
	<- close_in([w, e], goal_x, DIR); !move(DIR).
+!reach_goal: not goal_x = 0 & not goal_y = 0 & .random(RandNum) & choose_dir(RandNum, DIR)
	<- !move(DIR).


+step(X) : true <-
	.print("Received step percept.").
	
+actionID(X) : true <- 
	.print("Determining my action");
	!reach_goal.
//	skip.

