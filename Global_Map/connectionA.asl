
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

    
    !check_location;         
    !move_random;    
    .

// Identify the location of Agent for every Action Step.
+!check_location
: lastAction(move) & lastActionResult(success) &  lastActionParams([Direction]) & .my_name(Me) & actionID(S) & pos::agt_Pos(Me, (S-1),  CX, CY) 
<-

    ?agtCoordinate(Direction,CX,CY,NewX,NewY) ;          
    +pos::agt_Pos(Me, S,  NewX, NewY);    
    !!get_goal(NewX,NewY);    
    !find_agent(NewX,NewY);
    !!get_dis(NewX,NewY);
    .

+!check_location
: lastAction(move)  & lastActionResult(failed_forbidden)  &  lastActionParams([Direction]) & .my_name(Me) & actionID(S) & pos::agt_Pos(Me, (S-1),  CX, CY) 
<-

    .my_name(Me);
    ?agtCoordinate(Direction,CX,CY,NewX,NewY);
    -pos::agt_Pos(Me, S-1,  _, _); 
    +pos::agt_Pos(Me, S,  CX, CY);                
    !per::location_edg(Me,Direction,NewX,NewY);                    
    -lastAction(move);
.
+!check_location
: lastAction(move)  &  .my_name(Me) & actionID(S) & pos::agt_Pos(Me, (S-1),  CX, CY) & agtCoordinate(Direction,CX,CY,NewX,NewY) & actionID(S) 
<-
    .my_name(Me);
    -pos::agt_Pos(Me, S-1,  _, _); 
    +pos::agt_Pos(Me, S,  CX, CY);
.

+!check_location
: true.



    
// Identify the goal location 
+!get_goal(Gx,Gy)
:  .my_name(Agt) & actionID(S)   & goal(GoaX, GoaY) & stock::agt_Map_Goa(Ogl) & not .member([[Gx,Gy]],Ogl) & not lock::update_goal
<-  
    
    +lock::update_goal;
    NewGX = (GoaX + Gx);
    NewGY = (GoaY + Gy);
   // .print(NewGX, " ", NewGY);
    .union([[NewGX,NewGY]],Ogl,NewGoaL);    

    -stock::agt_Map_Goa(_);
    +stock::agt_Map_Goa(NewGoaL); 
    -stock::agt_Map_Goa_temp(_);
    +stock::agt_Map_Goa_temp(NewGoaL);
    -lock::update_goal;
    .broadcast(achieve,com::tell_me_your_goal);         
    .
+!get_goal(Gx,Gy).

// Identify the dispenser location
+!get_dis(Dx,Dy)
:  .my_name(Agt) & actionID(S)   & thing(DisX,DisY,dispenser,Detail) & stock::agt_Map_Dis(Ogl) & not .member([[Dx,Dy,Detail]],Ogl) & not lock::update_dis
<-  
    
    +lock::update_dis;
    NewX = (DisX + Dx);
    NewY = (DisY + Dy);
   // .print(NewGX, " ", NewGY);
    .union([[NewX,NewY,Detail]],Ogl,NewDisL);    

    -stock::agt_Map_Dis(_);
    +stock::agt_Map_Dis(NewDisL); 
    -stock::agt_Map_Dis_temp(_);
    +stock::agt_Map_Dis_temp(NewDisL);
    -lock::update_dis;
    .broadcast(achieve,com::tell_me_your_dis);
    .
+!get_dis(Dx,Dy) .
 

// Identify the Agent location
 +!find_agent(MyX, MyY)
: thing(SLocalX,SLocalY,entity,Detail) & actionID(Step) & team(T)  & SLocalX \== (0) & SlocalY \== (0) & T == Detail
<-
    
    
        .my_name(Me);
        
        SenderX = (MyX + SLocalX );
        SenderY = (MyY + SLocalY); 
        
        //.print("What is worng ", Step, "My location in Sender X", SenderX, " ", SenderY , " Local ", SLocalX, " ", SLocalY , " Sender own", SenderOwnX, SenderOwnY );
        -data::myent(_,_,_,_,_,_,_);
        +data::myent(Step,SLocalX,SLocalY,MyX,MyY,SenderX,SenderY);

        .broadcast(achieve,com::check_encounter(Step,  SenderX, SenderY, SLocalX, SLocalY));         
        

    .
+!find_agent(MyX,MyY) .


 

 +!move_random
: .random(RandomNumber) & random_dir([n,s,e,w],RandomNumber,Dir)
<-	
    
    move(Dir);
    .



