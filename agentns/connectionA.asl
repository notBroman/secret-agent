/* Initial beliefs and rules */
random_dir(DirList,RandomNumber,Dir) :- (RandomNumber <= 0.25 & .nth(0,DirList,Dir)) | (RandomNumber <= 0.5 & .nth(1,DirList,Dir)) | (RandomNumber <= 0.75 & .nth(2,DirList,Dir)) | (.nth(3,DirList,Dir)).
block_attached([0,1,b1]).
task(0,33,2,[req(0,1,b1)]).
goal(0,0).
goal(0,-1).
/* Initial goals */

!start.

/* Plans */

+!start : true <- 
	.print("hello massim world.").

+step(X) : true <-
	.print("Received step percept.").
	
+actionID(X) : true <- 
	.print("Determining my action");
	//!move_random;
	!submit_block(BX,BY,B).
//	skip.

+!move_random : .random(RandomNumber) & random_dir([n,s,e,w],RandomNumber,Dir)
<-	move(Dir).


//for single blocks submissions 
// fails when agent try to rotate
// case 1 - when both the agent and block is in goal positions
+!submit_block(BX,BY,B): block_attached([BX,BY,B]) & task(TASKID,STEPX,_,[req(BX,BY,B)]) & goal(0,0) & goal(BX,BY)
	<- submit(TASKID);
	.print(TASKID," Submitted.");
	detach(BX,BY);
	-block_attached([BX,BY,B]).

//case 2 - when agent is in a goal position but not the block
+!submit_block(BX,BY,B): block_attached([BX,BY,B]) & task(TASKID,STEPX,_,[req(BX,BY,B)]) & goal(0,0) & not(goal(BX,BY))
	<- .print("Block not in a goal position. Try rotating the block");
	if(rotate(cc) & BY>0 & BX==0){
		-block_attached([BX,BY,B]);
		+block_attached([BX+1,BY-1,B]);
		submit_block(BX+1,BY-1,B);
	}elif(rotate(cc) & BY==0 & BX==1){
		-block_attached([BX,BY,B]);
		+block_attached([BX-1,BY-1,B]);
		submit_block(BX-1,BY-1,B);
	}elif(rotate(cc) & BY<0 & BX==0){
		.print("checking condition A");
		-block_attached([BX,BY,B]);
		+block_attached([BX-1,BY+1,B]);
		submit_block(BX-1,BY+1,B);
	}elif(rotate(cc) & BY==0 & BX<0){
		.print("checking condition B");
		-block_attached([BX,BY,B]);
		+block_attached([BX+1,BY+1,B]);
		submit_block(BX+1,BY+1,B);
	}elif(not(rotate(cc))){
		.print("cannot rotate, try moving agent");
	}.

//case 3 - when agent and block both not in the goal positions
+!submit_block(BX,BY,B): block_attached([BX,BY,B]) & task(TASKID,STEPX,_,[req(BX,BY,B)]) & not(goal(0,0)) & not(goal(BX,BY))
	<- move(Dir);    //move agent to a goal position and try submitting
	submit_block(BX,BY,B).


// 	!try_rotate(BX,BY,B,0).

// +!try_rotate(BX,BY,B,Count): Count<4
// 	<- rotate(cc);
// 	.print("Rotated",BX,BY,B,Count).