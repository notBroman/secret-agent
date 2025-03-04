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
   //.print("Begin is ", (S));
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
    

+obstacle(ObsX,ObsY)
: lastAction(move)   & actionID(S) & not lock::mapMerging(obs)
<-  
    .wait({+pos::agt_Pos(_, S,  _, _)});
    ?pos::agt_Pos(_ ,S,  OX, OY);    
    ?stock::agt_Map_Obs(OldL);
    NewOX = (ObsX + OX);
    NewOY = (ObsY + OY);

    
    .union([[NewOX,NewOY]],OldL,ObsList);    
    -stock::agt_Map_Obs(_);
    +stock::agt_Map_Obs(ObsList);    

    .


+goal(GoaX,GoaY)
: lastAction(move) & actionID(S)  & not lock::mapMerging(goa)
<-  
    .wait({+pos::agt_Pos(_, S,  _, _)});
    ?pos::agt_Pos(_ ,S,  GX, GY);    
    ?stock::agt_Map_Goa(Ogl);
    
    NewGX = (GoaX + GX);
    NewGY = (GoaY + GY);
    
    .union([[NewGX,NewGY]],Ogl,NewGoaL);    

    -stock::agt_Map_Goa(_);
    +stock::agt_Map_Goa(NewGoaL);    
 

    .

+thing(DisX,DisY,dispenser,Detail)
:  actionID(S)  & not lock::mapMerging(dis)
<-  
    .wait({+pos::agt_Pos(_, S, _, _)});
    ?stock::agt_Map_Dis(DisL);    
    ?pos::agt_Pos(Agt ,S, DX, DY);
    
     NewDX = (DisX + DX);
     NewDY = (DisY + DY);
    
    .union([[NewDX,NewDY,Detail]],DisL,DisList);    
  
    -stock::agt_Map_Dis(_);
    +stock::agt_Map_Dis(DisList);
    . 


+thing(BloX,BloY,block,Detail)
: actionID(S) & not lock::mapMerging(blo)
<-
    .wait({+pos::agt_Pos(_, S,  _, _)});
    ?pos::agt_Pos(_ ,S,  Bx, By);
    ?stock::agt_Map_Blo(BloL);
    NewBX = (BloX + BX);
     NewBY = (BloY + BY);
    
    .union([[NewBX,NewBY]],BloL,BloList);


    -stock::agt_Map_Blo(_);
    +stock::agt_Map_Blo(BloList);
    .
 




 +thing(SLocalX,SLocalY,entity,Detail)
: actionID(Step) & team(T)  & not lock::mapMerging(ent) & team::members(Me,SenderId,AllMembers,DeltaX,DeltaY)
<-
    
    if (SLocalX \== (0) & SlocalY \== (0) & T == Detail)
    {
        .my_name(Me);
        .wait({+pos::agt_Pos(_, Step,  _, _)});    
        ?pos::agt_Pos(_, Step,  SenderOwnX, SenderOwnY);
        
        SenderX = (SenderOwnX + SLocalX );
        SenderY = (SenderOwnY + SLocalY); 
        
        //.print("What is worng ", Step, "My location in Sender X", SenderX, " ", SenderY , " Local ", SLocalX, " ", SLocalY , " Sender own", SenderOwnX, SenderOwnY );
        .broadcast(achieve,com::check_encounter(Step, SenderId, SenderX, SenderY, SLocalX, SLocalY,SenderOwnX,SenderOwnY));         
        -data::myent(_,_,_,_,_,_,_);
        +data::myent(Step,SLocalX,SLocalY,SenderOwnX, SenderOwnY,SenderX,SenderY);

    }
    .



 

 +!move_random
: .random(RandomNumber) & random_dir([n,s,e,w],RandomNumber,Dir)
<-	
    
    !action::move(Dir);
    .

