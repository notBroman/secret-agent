+!move(n)
	:   obstacle(0,-1) 
<-

	.print("222222222222222 n");
	.
// Avoid clear markers moving south
+!move(s)
	:   obstacle(0,1) 
<-
	.print("222222222222222 s");
	.
// Avoid clear markers moving east
+!move(e)
	:   obstacle(1,0)
<-
	.print("222222222222222 e");
	.
// Avoid clear markers moving west
+!move(w)
	:    obstacle(-1,0)
<-
	.print("222222222222222 w");
	.	
//// Go around a friendly agent
//+!move(Direction)
//	: exploration::check_agent(Direction) & not common::avoid(_)
//<-
//	!common::go_around(Direction);
//	!action::commit_action(move(Direction));
//	.
// Default move behaviour
+!move(Direction)
<-
move(Direction);
.
-!move(Direction)[code(.fail(action(Action),result(failed_parameter)))] <- .print("Fail::::: Direction ",Direction," is not valid, it should be one of {n,s,e,w}.").
// Improve this failure to drop disjunction into two different plans
-!move(Direction)[code(.fail(action(Action),result(failed_path)))] : common::direction_block(Direction,X,Y) & retrieve::block(X,Y) & not common::check_obstacle_bounds(Direction) <- .print("Fail:::::  Destination is out of bounds for my block."); +action::out_of_bounds(Direction).
-!move(Direction)[code(.fail(action(Action),result(failed_path)))] <- .print("Fail::::: Destination is blocked, or one of my attached things is blocking.").
-!move(Direction)[code(.fail(action(Action),result(failed_forbidden)))] <- .print("Fail::::: Destination is out of bounds."); +action::out_of_bounds(Direction).
