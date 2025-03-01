
// Obstacle
+!seeSomeThing(Agt,S,NewX,NewY)
:  data::myobstacle(Agt,S,_,_) & stock::agt_Map_Obs(Agt,_,OldL) &  not lock::mapMerging(obs) 
<-  
    .setof([NX,NY], (data::myobstacle(Agt,S,AX,AY)  & NX = AX + NewX & NY= AY + NewY), NewL);
    .union(NewL,OldL,ObsList);
    .print("I am ",Agt, " I found A obstacle in ", ObsList );
    -stock::agt_Map_Obs(Agt,_,_);  
    +stock::agt_Map_Obs(Agt,S,ObsList);
    .abolish(data::myobstacle(Agt,_,_,_));
    .

+!seeSomeThing(Agt,S,NewX,NewY)
: data::myobstacle(Agt,S,_,_)  & not stock::agt_Map_Obs(Agt,_,_)  & not lock::mapMerging(obs)
<-
    .setof([NX,NY], (data::myobstacle(Agt,S,AX,AY) & AS == S & NX = AX + NewX & NY= AY + NewY), NewL);
    +stock::agt_Map_Obs(Agt,S,NewL);
    .

// Goal
+!seeSomeThing(Agt,S,NewX,NewY)
: data::mygoal(Agt,S,_,_) & stock::agt_Map_Goa(Agt,_,OldL) & not lock::mapMerging(goa) 
<-    
    .print("I am ",Agt, " I found Goal in ", OldL );
    .setof([NX,NY], (data::mygoal(Agt,S,AX,AY) & NX = AX + NewX & NY= AY + NewY), NewL);
    .union(NewL,OldL,GoaList);
    -stock::agt_Map_Goa(Agt,_,_);  
    .wait(5);
    +stock::agt_Map_Goa(Agt,S,GoaList);
    .abolish(data::mygoal(Agt,_,_,_));
    .

+!seeSomeThing(Agt,S,NewX,NewY)
: data::mygoal(Agt,S,_,_) & not stock::agt_Map_Goa(Agt,_,_) & not lock::mapMerging(goa)
<-
    .setof([NX,NY], (data::mygoal(Agt,S,AX,AY)  & NX = AX + NewX & NY= AY + NewY), NewL);
    +stock::agt_Map_Goa(Agt,S,NewL)
    .

// Dispenser

+!seeSomeThing(Agt,S,NewX,NewY)
: data::mydispenser(Agt,S,_,_,_) & stock::agt_Map_Dis(Agt,_,_,OldL,OldT) & not lock::mapMerging(dis) 
<-
    //+data::mydispenser(Me,S,X,Y,dispenser,Detail);   
    //+stock::agt_Map_Dis(Me,0,[]);

    .setof([NX,NY], (data::mydispenser(Agt,S,AX,AY,Type) & NX = AX + NewX & NY= AY + NewY), NewL);
    .setof([Type], data::mydispenser(Agt,S,AX,AY,Type), NewT);
    .union(NewL,OldL,DisList);
    .union(NewT,OldT,DisListT);
    -stock::agt_Map_Dis(Agt,_,_,_);  
    .wait(5);
    +stock::agt_Map_Dis(Agt,S,DisList,DisListT);
    .abolish(data::mydispenser(Agt,_,_,_,_));
    .
+!seeSomeThing(Agt,S,NewX,NewY)
: data::mydispenser(Agt,S,_,_,_) & not stock::agt_Map_Dis(Agt,_,_,_,_) & not lock::mapMerging(dis)
<- 
    .setof([NX,NY], (data::mydispenser(Agt,S,AX,AY,Type) & NX = AX + NewX & NY= AY + NewY), NewL);
    .setof([Type], data::mydispenser(Agt,S,AX,AY,Type), NewT);
    +stock::agt_Map_Dis(Agt,S,NewL,NewT);
    .

// Block

+!seeSomeThing(Agt,S,NewX,NewY)
: data::myblock(Agt,S,_,_,_) & stock::agt_Map_Blo(Agt,_,OldL,OldT) & not lock::mapMerging(blo)
<-
    //+data::mydispenser(Me,S,X,Y,dispenser,Detail);   
    //+stock::agt_Map_Dis(Me,0,[]);

    .setof([NX,NY,Type], (data::myblock(Agt,S,AX,AY,Type)  & NX = AX + NewX & NY= AY + NewY), NewL);
    .setof([Type], data::myblock(Agt,S,AX,AY,Type) , NewT);
    ?stock::agt_Map_Blo(Agt,_,OldL);
    .union(NewL,OldL,BloList);
    .union(NewT,OldT,BloListT);
    -stock::agt_Map_Blo(_,_,_,_);  
    .wait(5);
    +stock::agt_Map_Blo(Agt,S,BloList,BlockT);
    .abolish(data::myblock(Agt,_,_,_,_));
    .

+!seeSomeThing(Agt,S,NewX,NewY)
: data::myblock(Agt,S,_,_,_) &  not stock::agt_Map_Blo(Agt,_,OldL,OldT) & not lock::mapMerging(blo)
<- 
    .setof([NX,NY,Type], (data::myblock(Agt,AS,AX,AY,Type)  & NX = AX + NewX & NY= AY + NewY), NewL);
    .setof([Type], data::myblock(Agt,AS,AX,AY,Type) , NewT);
    +stock::agt_Map_Dis(Agt,S,NewL,NewT);
    .

+!seeSomeThing(Agt,S,NewX,NewY)    
<- 
    !seeSomeThing(Agt,S,NewX,NewY);
    .print("Add new item to locations fail!!!!!!");
    .

 
// Map Edg
+!location_edg(Agt,Direction,EdgX,EdgY )
: Direction == n & not stock::agt_Map_Edg_Y_N(_) & not stock::agt_Map_Edg_X_W(_)
<-
    .print("I ", Agt, " found edge in ", Direction);
    +stock::agt_Map_Edg_Y_N(EdgY);
    +stock::agt_Map_Edg_X_W(EdgY);
    -stock::findEdge_NW;
    .

+!location_edg(Agt,Direction,EdgX,EdgY )
: Direction == w & not stock::agt_Map_Edg_Y_N(_) & not stock::agt_Map_Edg_X_W(_)
<-
    .print("I ", Agt, " found edge in ", Direction);
    +stock::agt_Map_Edg_X_W(EdgX);
    +stock::agt_Map_Edg_Y_N(EdgX);
    -stock::findEdge_NW;
    .

+!location_edg(Agt,Direction,EdgX,EdgY )
: Direction == e  & not stock::agt_Map_Edg_X_E(_) & not stock::agt_Map_Edg_Y_S(_)
<-
    .print("I ", Agt, " found edge in ", Direction);
    +stock::agt_Map_Edg_X_E(EdgX);
    +stock::agt_Map_Edg_Y_S(EdgX);
    -stock::findEdge_ES;
    .

+!location_edg(Agt,Direction,EdgX,EdgY )
: Direction == s & not stock::agt_Map_Edg_Y_S(_) & not stock::agt_Map_Edg_X_E(_)
<-
    .print("I ", Agt, " found edge in ", Direction);
    +stock::agt_Map_Edg_Y_S(EdgY);
    +stock::agt_Map_Edg_X_E(EdgY);
    -stock::findEdge_ES;
    .

+!location_edg(Agt,Direction,EdgX,EdgY ) : true .