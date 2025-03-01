/* {include("actions/exploration.asl", exploration) } */
{include("actions/action.asl",action)}
{include("actions/initial.asl",init) }
{include("actions/percept.asl",per)}
{include("actions/communication.asl",com)}

random_dir(DirList,RandomNumber,Dir) :- (RandomNumber <= 0.25 & .nth(0,DirList,Dir)) | (RandomNumber <= 0.5 & .nth(1,DirList,Dir)) | (RandomNumber <= 0.75 & .nth(2,DirList,Dir)) | (.nth(3,DirList,Dir)).

	
!start.

/* Plans */

+!start : true 
<- 
    .my_name(Me);
    .print("hello massim world.");
    !init::initialAgent(Me);
    .broadcast(achieve, init::joinTeam);
    ?team(Tname)[source(Percept)];
    !init::sortMembers(Tname);
    .

@atomic
+actionID(S) : true <- 
	/* .print("Determining my action"); */
    +lock::token(S);
    .my_name(Me);
    if (S ==  (0))
    {
        +stock::agt_Pos(Me, (0) ,(0) ,(0));	

    }

    
    if (lastAction(move))
    {
        .wait(100);
        ?stock::agt_Pos(Me, Sa,  CX, CY);
        ?lastActionParams([Direction]);
        if ( Direction == n  ) 
        {
            NewX = CX ;
            NewY = (CY - 1);
            Edg = [0,(CY - 1)];
            
        }
        elif (Direction == s) 
        {
            NewX = CX;
            NewY = (CY + 1);
            Edg = [0,(CY + 1)];
        } 
        elif (Direction == e)  
        {
            NewX = (CX + 1);
            NewY = CY; 
            Edg = [(CX + 1),0];
        }
        elif (Direction == w) 
        {
            NewX = (CX - 1);
            NewY = CY;
            Edg = [(CX - 1),0];
        }

        if (lastActionResult(success))
        {
            .print("lastActionResult success");
                        
            +lock::updatePos_token(pos,S,Me);
            
            -stock::agt_Pos(Me, _,  CX, CY); 
            +stock::agt_Pos(Me, S,  NewX, NewY);
            !per::location_obstacles(Me,S,NewX,NewY);
            !per::location_goal(Me,S,NewX,NewY);
            !per::location_dis(Me,S,NewX,NewY);
            !per::location_blo(Me,S,NewX,NewY);
            -lock::updatePos_token(pos,S,Me);
            -lastAction(move);
            
        }    
        elif ( lastActionResult(failed_forbidden))
        {
            .print("lastActionResult failed");
            !per::location_edg(Me,[Direction,Edg]);
            -lastAction(move);
        }  
    }
    !per::location_ent(Me,S,NewX,NewY);
        
        
    !move_random(S);
            
    -lock::token(S);
    .

/* Percept */
+obstacle(X,Y)
: lastAction(move)
<-  
    .my_name(Me);
    ?actionID(S);    
    
    +stock::myobstacle(Me, S, X,Y);

    .



+goal(X,Y)
: lastAction(move) 
<-  
    .my_name(Me);
    ?actionID(S);        
    +stock::mygoal(Me,S,X,Y);
    
    .

+thing(X,Y,dispenser,Detail)
: true 
<-
    .my_name(Me);
    ?actionID(S);
    +stock::mydispenser(Me,S,X,Y,Detail);    
    .

+thing(X,Y,entity,Detail)
: true 
<-
    .my_name(Me);
    ?actionID(S);
    +stock::myent(Me,S,X,Y,Detail);
    
    .print("here is entities:",X,Y,Detail);
    
    .

+thing(X,Y,block,Detail)
: true 
<-
    .my_name(Me);
    ?actionID(S);
    
    +stock::myblock(Me,S,X,Y,Detail);    
    .

+!move_random(S)
: .random(RandomNumber) & random_dir([n,s,e,w],RandomNumber,Dir)
<-	
    !action::move(Dir,S);
    .





