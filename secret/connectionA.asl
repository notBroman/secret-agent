{ include("action/actions.asl", action) }

start.

/* Plans */

+!start : true <- 
	.print("[INFO] hello massim world.").

+step(X) : true <-
	.my_name(Me);
	.print("[INFO] Received step percept.",X);
/*     firstToStop(Me, Flag);
    .print("[DEBUG] firstToStop called by ", Me, " Result: ", Flag);
	plannerResult(Flag);
	.print("[DEBUG] plannerResult called by ",Flag); */
	plannerDone;
	joinRetrievers(Flag);
	setTargetGoal(1, Me, 1, 2, "side");
	updateRetrieverAvailablePos(1, 2);
	getTargetGoal;
	// Must be request
	?getTargetGoalResult(GoalAgent, GoalX, GoalY, Side);
    .print("[DBG] getTargetGoal result:", GoalAgent," ", GoalX," ", GoalY," ", Side);
	.