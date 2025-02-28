

/* +!is_lastmove
: lastAction(move) & lastActionResult(failed_forbidden)
<-
    .my_name(Agt);





    ?lastActionParams([Direction]);
        !evalu::updataAgentPos(Direction,Agt);
        -lastAction(move);
    . */




+!location_obstacles(Agt,S,NewX,NewY)
<-  
    .setof([NX,NY], (stock::myobstacle(Agt,AS,AX,AY) & AS == S & NX = AX + NewX & NY= AY + NewY), NewL);
    ?stock::agt_Map_Obs(Agt,_,OldL);
    .union(NewL,OldL,ObsList);
    -stock::agt_Map_Obs(Agt,_,_);  
    +stock::agt_Map_Obs(Agt,S,ObsList);
    -stock::myobstacle(Agt,_,_,_);
        
    .print("New location "," ",Agt," ", NewX," ", NewY);
    .


+!location_goal(Agt,S,NewX,NewY)
<-
    .setof([NX,NY], (stock::mygoal(Agt,AS,AX,AY) & AS == S & NX = AX + NewX & NY= AY + NewY), NewL);
    
    ?stock::agt_Map_Goa(Agt,_,OldL);
    .union(NewL,OldL,GoaList);
    -stock::agt_Map_Goa(Agt,_,_);  
    +stock::agt_Map_Goa(Agt,S,GoaList);
    .


+!location_dis(Agt,S,NewX,NewY)
<-
    //+stock::mydispenser(Me,S,X,Y,dispenser,Detail);   
    //+stock::agt_Map_Dis(Me,0,[]);

    .setof([NX,NY,Type], (stock::mydispenser(Agt,AS,AX,AY,Type) & AS == S & NX = AX + NewX & NY= AY + NewY), NewL);
    
    ?stock::agt_Map_Dis(Agt,_,OldL);
    .union(NewL,OldL,DisList);
    -stock::agt_Map_Dis(Agt,_,_);  
    +stock::agt_Map_Dis(Agt,S,DisList);
    .

+!location_blo(Agt,S,NewX,NewY)
<-
    //+stock::mydispenser(Me,S,X,Y,dispenser,Detail);   
    //+stock::agt_Map_Dis(Me,0,[]);

    .setof([NX,NY,Type], (stock::myblock(Agt,AS,AX,AY,Type) & AS == S & NX = AX + NewX & NY= AY + NewY), NewL);
    
    ?stock::agt_Map_Blo(Agt,_,OldL);
    .union(NewL,OldL,BloList);
    -stock::agt_Map_Blo(Agt,_,_);  
    +stock::agt_Map_Blo(Agt,S,BloList);
    .