/* {include("actions/exploration.asl", exploration) } */
{include("actions/action.asl",action)}
{include("actions/initial.asl",init) }
{include("actions/stock.asl",stock)}
{include("actions/evalu.asl",evalu)}
{include("actions/percept.asl",per)}

random_dir(DirList,RandomNumber,Dir) :- (RandomNumber <= 0.25 & .nth(0,DirList,Dir)) | (RandomNumber <= 0.5 & .nth(1,DirList,Dir)) | (RandomNumber <= 0.75 & .nth(2,DirList,Dir)) | (.nth(3,DirList,Dir)).

	
!start.

/* Plans */

+!start : true 
<- 
.print("hello massim world.");
.my_name(Me);
!init::initialAgent(Me);
.
@atomic
+actionID(S) : true <- 
	/* .print("Determining my action"); */
    +lock::token(S);
    .print(S);
    .my_name(Me);
    if (S ==  (0))
    {
        +stock::agt_Pos(Me, (0) ,(0) ,(0));	

    }

    
    if (lastAction(move))
    {
        ?stock::agt_Pos(Me, Sa,  CX, CY);
        .print("hererererere, "," ",Me, " ",Sa ," ",S, " ", CX, " ", CY);
        if (lastActionResult(success))
        {
            .print("lastActionResult success");
            
    
            ?lastActionParams([Direction]);
            +lock::updatePos_token(pos,S,Me);
            
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

            -stock::agt_Pos(Me, _,  CX, CY); 
            +stock::agt_Pos(Me, S,  NewX, NewY);

            !per::location_obstacles(Me,S,NewX,NewY);
            !per::location_goal(Me,S,NewX,NewY);
            -lock::updatePos_token(pos,S,Me);
            -lastAction(move);
            
        }    
        elif ( lastActionResult(failed_forbidden))
        {
            .print("lastActionResult failed");
            ?lastActionParams([Direction]);
            /* !stock::agtMemory(Me,CX,CY,mapEdge,Direction); */
            -lastAction(move);
        }  
    }
    
        
        
    !move_random(S);
            
    -lock::token(S);
    .

/* Percept */
+obstacle(X,Y)
: lastAction(move)
<-  
    .my_name(Me);
    ?actionID(S);    
    -stock::myobstacle(Me, _, _,_);
    +stock::myobstacle(Me, S, X,Y);

    .



+goal(X,Y)
: lastAction(move) 
<-  
    .my_name(Me);
    ?actionID(S);    
    -stock::mygoal(Me,_,_,_);
    +stock::mygoal(Me,S,X,Y);
    

    .

+thing(X,Y,dispenser,Detail)
: true 
<-
    .my_name(Me);
    ?actionID(S);
    +stock::mydispenserl(Me,S,X,Y,dispenser,Detail);    
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

+!move_random(S)
: .random(RandomNumber) & random_dir([n,s,e,w],RandomNumber,Dir)
<-	
    !action::move(Dir,S);
    .

