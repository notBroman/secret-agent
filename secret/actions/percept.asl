+!location_obstacles(Agt,S,NewX,NewY)
<-  
    .setof([NX,NY], (stock::myobstacle(Agt,AS,AX,AY) & AS == S & NX = AX + NewX & NY= AY + NewY), NewL);
    ?stock::agt_Map_Obs(Agt,_,OldL);
    .union(NewL,OldL,ObsList);
    -stock::agt_Map_Obs(Agt,_,_);  
    +stock::agt_Map_Obs(Agt,S,ObsList);
    .abolish(stock::myobstacle(Agt,_,_,_));
    

    .


+!location_goal(Agt,S,NewX,NewY)
<-
    .setof([NX,NY], (stock::mygoal(Agt,AS,AX,AY) & AS == S & NX = AX + NewX & NY= AY + NewY), NewL);
    
    ?stock::agt_Map_Goa(Agt,_,OldL);
    .union(NewL,OldL,GoaList);
    -stock::agt_Map_Goa(Agt,_,_);  
    +stock::agt_Map_Goa(Agt,S,GoaList);
    .abolish(stock::mygoal(Me,_,_,_));
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
    .abolish(stock::mydispenser(Me,_,_,_,_));
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
    .abolish(stock::myblock(Me,_,_,_,_));
    .

+!location_edg(Agt,NewL)
: stock::agt_Map_Edg(Agt,_)
<-
    ?stock::agt_Map_Edg(Agt,OldL);
    .union(NewL,OldL,EdgList);
    -stock::agt_Map_Edg(Agt,_);
    +stock::agt_Map_Edg(Agt,NewL);
    .
    
+!location_edg(Agt,NewL)
: not stock::agt_Map_Edg(Agt,_)
<-
    -stock::agt_Map_Edg(Agt,_);
    +stock::agt_Map_Edg(Agt,NewL);
    .



+!location_ent(Agt,S,NewX,NewY)
: stock::myent(_,S,_,_,ET) & team::members(Agt,Inx,Tname,_) & ET == Tname
<-
    ?stock::myent(_,S,EX,EY,ET);
    .broadcast(tell,com::encounter_queue(S,Inx,NewX,NewY,EX,EY));
    !location_ent(Agt,S,NewX,NewY);    
    .

