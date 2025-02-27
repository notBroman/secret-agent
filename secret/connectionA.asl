/* {include("actions/exploration.asl", exploration) } */
{include("actions/action.asl",action)}
{include("actions/initial.asl",init) }
{include("actions/stock.asl",stock)}
{include("actions/evalu.asl",evalu)}

random_dir(DirList,RandomNumber,Dir) :- (RandomNumber <= 0.25 & .nth(0,DirList,Dir)) | (RandomNumber <= 0.5 & .nth(1,DirList,Dir)) | (RandomNumber <= 0.75 & .nth(2,DirList,Dir)) | (.nth(3,DirList,Dir)).

	
!start.

/* Plans */

+!start : true 
<- 
.print("hello massim world.");
.my_name(Me);
!init::initialAgent(Me);
.

/* Percept */
+obstacle(X,Y) 
: true 
<-
    .my_name(Agt);
    /* .print("here are obstacle",Agt," ", X," ", Y); */
    !stock::agtMemory(Agt,X,Y,obstacle,[]);
    .

+goal(X,Y)
: true 
<-
    .my_name(Agt);
    /* .print("Goal: ",Agt, " ", X , " " ,Y); */
    !stock::agtMemory(Agt,X,Y,goal,[]);
    .   

+thing(X,Y,dispenser,Detail)
: true 
<-
    .my_name(Agt);
    /* .print("Dispenser: ",Agt, " ", X , " " ,Y); */
    !stock::agtMemory(Agt,X,Y,dispenser,Detail);
    .

+thing(X,Y,entity,Detail)
: true 
<-
    .my_name(Agt);
    /* .print("Entity: ",Agt, " ", X , " " ,Y); */
    .

+thing(X,Y,block,Detail)
: true 
<-
    .my_name(Agt);
    /* .print("block: ",Agt, " ", X , " " ,Y); */
    .

+lastAction(move)
: not lastActionResult(failed_forbidden) & not lastActionResult(failed_path) & not lastActionResult(failed_parameter)
<-
    ?action::mutexStep(Agt,Token);
    NewToken = Token + 1;
    -action::mutexStep(Agt,Token);
    +action::mutexStep(Agt,NewToken);
    ?lastActionParams([Direction]);
    !evalu::updataAgentPos(Direction,Agt);
    .

+lastAction(move)
: lastActionResult(failed_forbidden)
<-
    ?action::mutexStep(Agt,Token);
    NewToken = Token + 1;
    -action::mutexStep(Agt,Token);
    +action::mutexStep(Agt,NewToken);

    .my_name(Agt);
    ?lastActionParams([Direction]);
    ?stock::agt_Pos(Agt,X,Y);
    !stock::agtMemory(Agt,X,Y,mapEdge,Direction);
    .print("forbidden move fails"," ",Agt," ",X," ",Y," ", Direction);
    .







+actionID(X) : true <- 
	/* .print("Determining my action"); */
	!move_random;
    .
//	skip.



+!move_random : .random(RandomNumber) & random_dir([n,s,e,w],RandomNumber,Dir)
<-	
    !action::move(n);
    .


