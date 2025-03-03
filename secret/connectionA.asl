/* {include("actions/exploration.asl", exploration) } */
{include("actions/action.asl",action)}
{include("actions/initial.asl",init) }
{include("actions/percept.asl",per)}
{include("actions/communication.asl",com)}

random_dir(DirList,RandomNumber,Dir) :- (RandomNumber <= 0.25 & .nth(0,DirList,Dir)) | (RandomNumber <= 0.5 & .nth(1,DirList,Dir)) | (RandomNumber <= 0.75 & .nth(2,DirList,Dir)) | (.nth(3,DirList,Dir)).

agtCoordinate (n, CX , CY , NewX , NewY) :-   NewX = CX  & NewY = (CY - 1).
agtCoordinate (s, CX , CY , NewX , NewY) :-   NewX = CX  & NewY = (CY + 1).
agtCoordinate (e, CX , CY , NewX , NewY) :-   NewX = (CX + 1) & NewY = CY.
agtCoordinate (w, CX , CY , NewX , NewY) :-   NewX = (CX - 1) & NewY = CY.


!start.

/* Plans */

+!start : true 
<- 
    .my_name(Me);
    .print("hello massim world.");
    !init::initialAgent(Me);
    .broadcast(achieve, init::joinTeam);
    
    !init::sortMembers;
    .

@atomic
+actionID(S) : true <- 
	/* .print("Determining my action"); */
    .my_name(Me);
    .print("Begin is ", (S));
    if (pos::agt_Pos(Me, (S-1),  CX, CY))
    {
                        
    }
    else
    {
        CX = (0);
        CY = (0);
        +pos::agt_Pos(Me, (0),  CX, CY);
    }

    .wait(lock::allow_update_location);
    - lock::allow_update_location;
    if (lastAction(move))
    {
        
        ?lastActionParams([Direction]);
        ?agtCoordinate(Direction,CX,CY,NewX,NewY);

        if (lastActionResult(success))
        {   
            -pos::agt_Pos(Me, S-1,  _, _);             
            +pos::agt_Pos(Me, S,  NewX, NewY);
            .wait(1);
            
            -lastAction(move);
            
        }    
        elif ( lastActionResult(failed_forbidden))
        {
            -pos::agt_Pos(Me, S-1,  _, _); 
            +pos::agt_Pos(Me, S,  CX, CY);                
            !per::location_edg(Me,Direction,NewX,NewY);                    
            -lastAction(move);
            
        }  
        else
        {
            -pos::agt_Pos(Me, S-1,  _, _); 
            +pos::agt_Pos(Me, S,  CX, CY);
            -lastAction(move);
            
        }
        
    } 
    else
    {

        -pos::agt_Pos(Me, S-1,  _, _); 
        +pos::agt_Pos(Me, S,  CX, CY);
        .wait(1);
    }
    +lock::allow_update_location;
    
         
    !move_random;
    
    .
/* Percept */
    

+obstacle(X,Y)
: lastAction(move)   & actionID(S)
<-  
    .wait(pos::agt_Pos(_, S,  _, _));
    ?pos::agt_Pos(_ ,S,  Lx, Ly);    
    ?stock::agt_Map_Obs(OldL);

    .union([[(Lx + X),(Ly + Y)]],OldL,ObsList);    
    .wait(1);

    -stock::agt_Map_Obs(_);
    +stock::agt_Map_Obs(ObsList);    
    

    .


+goal(X,Y)
: lastAction(move) & actionID(S) & not lock::mapMerging(goa)
<-  
    .wait(pos::agt_Pos(_, S,  _, _));    
    ?pos::agt_Pos(_ ,S,  Lx, Ly);
    ?stock::agt_Map_Goa(GoaL);

    .union([[(Lx + X),(Ly + Y)]],GoaL,GoaList);
    .wait(1);

    -stock::agt_Map_Goa(_);
    +stock::agt_Map_Goa(GoaList);    
    .

+thing(X,Y,dispenser,Detail)
:  lastAction(move) & actionID(S) & not lock::mapMerging(dis)
 
<-
    .wait(pos::agt_Pos(_, S,  _, _));    
    ?pos::agt_Pos(_ ,S,   Lx, Ly);
    ?stock::agt_Map_Dis(DisL);
    
    .union([[(Lx + X),(Ly + Y)]],DisL,DisList);    
    .wait(1);    
    -stock::agt_Map_Dis(_);
    +stock::agt_Map_Dis(DisList);
    . 


+thing(X,Y,block,Detail)
: lastAction(move) & actionID(S) & not lock::mapMerging(blo)
<-
    .wait(pos::agt_Pos(_, S,  _, _));    
    ?pos::agt_Pos(_ ,S,  Lx, Ly);
    ?stock::agt_Map_Blo(BloL);

    
    .union([[(Lx + X),(Ly + Y)]],BloL,BloList);
    .wait(1);

    -stock::agt_Map_Blo(_);
    +stock::agt_Map_Blo(BloList);
    .
 




 +thing(X,Y,entity,Detail)
: actionID(S) & team(T) & lastAction(move) & not lock::mapMerging(ent)
<-
    
    if (X \== (0) & Y \== (0) & T == Detail)
    {
        .my_name(Me);
        .wait(pos::agt_Pos(_, S,  _, _));    
        .wait(team::members(Me,_,_,_,_));
        ?pos::agt_Pos(Me, S,  MyX, MyY);
        ?team::members(Me,SenderId,_,_,_);
        ObjX = (MyX + X );
        ObjY = (MyY + Y); 
        .broadcast(achieve,com::check_encounter(S,SenderId,ObjX,ObjX,X,Y));         
        -data::myent(_,_,_,_,_,_,_);
        +data::myent(S,X,Y,MyX, MyY,ObjX,ObjY);

    }
    .



 

 +!move_random
: .random(RandomNumber) & random_dir([n,s,e,w],RandomNumber,Dir)
<-	
    
    !action::move(Dir);
    .

