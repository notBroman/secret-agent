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
    .wait(100);
    .broadcast(achieve, init::joinTeam);
    
    !init::sortMembers;
    .

@atomic
+actionID(S) : true <- 
	/* .print("Determining my action"); */
    
    .my_name(Me);
    if (S ==  (0))
    {
        +pos::agt_Pos(Me, (0) ,(0) ,(0));	

    }

    
    if (lastAction(move))
    {
        
        ?pos::agt_Pos(Me, Sa,  CX, CY);
        ?lastActionParams([Direction]);
        if ( Direction == n  ) 
        {
            NewX = CX ;
            NewY = (CY - 1);  

            
        }
        elif (Direction == s) 
        {
            NewX = CX;
            NewY = (CY + 1);

        } 
        elif (Direction == e)  
        {
            NewX = (CX + 1);
            NewY = CY; 

        }
        elif (Direction == w) 
        {
            NewX = (CX - 1);
            NewY = CY;
  
        }

        if (lastActionResult(success))
        {
                        
                    
            -pos::agt_Pos(Me, _,  CX, CY); 
            +pos::agt_Pos(Me, S,  NewX, NewY);
            !per::seeSomeThing(Me,S,NewX,NewY);
            
            
            -lastAction(move);
            
        }    
        elif ( lastActionResult(failed_forbidden))
        {
            
                
            !per::location_edg(Me,Direction,NewX,NewY);
            
            
            -lastAction(move);
        }  
        else
        {
            -lastAction(move);
        }
        
    }
    
    if (data::myent(Me,S,SLocalX,SLocalY,ET) & pos::agt_Pos(Me, S,  SenderX, SenderY) & team::members(Me,SenderId,AllMembers,MyDeltaX,MyDeltaY) )
    {
         
         /* & team::members(Me,SenderId,AllMembers) & pos::agt_Pos(Agt, Step,  SenderX, SenderY) */
        .print("Broadcast : bengin - >  Me ", Me ,"  Step :", S," SenderId: ", SenderId, " Sender X: ", SenderX, " SenderY ", SenderY, " SlocalX ", SLocalX, " slocalY ",SLocalY);
        .broadcast(achieve,com::encounter_queue(S,SenderId,SenderX,SenderY,SLocalX,SLocalY)); 

    }
    
         
    !move_random(S);
    
    .
/* Percept */
+obstacle(X,Y)
: lastAction(move)
<-  
    .my_name(Me);
    ?actionID(S);    
    
    +data::myobstacle(Me, S, X,Y);

    .



+goal(X,Y)
: lastAction(move) 
<-  
    .my_name(Me);
    ?actionID(S);        
    +data::mygoal(Me,S,X,Y);
    
    .

+thing(X,Y,dispenser,Detail)
: true 
<-
    .my_name(Me);
    ?actionID(S);
    +data::mydispenser(Me,S,X,Y,Detail);    
    .

+thing(X,Y,entity,Detail)
: true 
<-
    if (X \== (0) & Y \== (0))
    {
        .my_name(Me);
        ?actionID(S);
        +data::myent(Me,S,X,Y,Detail);    
    }
    .

+thing(X,Y,block,Detail)
: true 
<-
    .my_name(Me);
    ?actionID(S);
    
    +data::myblock(Me,S,X,Y,Detail);    
    .

+!move_random(S)
: .random(RandomNumber) & random_dir([n,s,e,w],RandomNumber,Dir)
<-	
    !action::move(Dir,S);
    .





