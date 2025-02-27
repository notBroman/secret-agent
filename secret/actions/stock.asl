

+!agtMemory(Agt,X,Y,Type,Detail)
: Type == obstacle
<-
    ?stock::agt_Map_Obs(Agt,OldList);
    .union(OldList,[[X,Y,Type,Detail]],U);
    -stock::agt_Map_Obs(Agt,_); 
    +stock::agt_Map_Obs(Agt, U);  
    ?stock::agt_Map_Obs(Agt,Test);
    .

+!agtMemory(Agt,X,Y,Type,Detail)
: Type == goal
<-
    /* .print("22222222222222222222Type"," ",Type); */
    ?stock::agt_Map_Goa(Agt,OldList);
    .union(OldList,[[X,Y,Type,Detail]],U);
    -stock::agt_Map_Goa(Agt,_); 
    +stock::agt_Map_Goa(Agt, U);  
    ?stock::agt_Map_Goa(Agt,Test);
    /* .print("22222222222222222222New goal:",Test);     */
    .


+!agtMemory(Agt,X,Y,Type,Detail)
: Type == dispenser 
<-
    /* .print("22222222222222222222Type"," ",Type); */
    ?stock::agt_Map_Dis(Agt,OldList);
    .union(OldList,[[X,Y,Type,Detail]],U);
    -stock::agt_Map_Dis(Agt,_); 
    +stock::agt_Map_Dis(Agt, U);  
    ?stock::agt_Map_Dis(Agt,Test);
    // .print("22222222222222222222New Dis:",Test);    
    .

+!agtMemory(Agt,X,Y,Type,Detail)
: Type ==  mapEdge & Detail == n
<-
    /* .print("22222222222222222222Type"," ",Type); */
    NewY = Y - 1; 
    ?stock::agt_Map_Edg(Agt,OldList);
    .union(OldList,[[X,NewY,Type,Detail]],U);
    -stock::agt_Map_Edg(Agt,_); 
    +stock::agt_Map_Edg(Agt, U);  
    ?stock::agt_Map_Edg(Agt,Test);
    // .print("22222222222222222222New Dis:",Test);    
    .


+!agtMemory(Agt,X,Y,Type,Detail)
: Type ==  mapEdge & Detail == s
<-
    /* .print("22222222222222222222Type"," ",Type); */
    NewY = Y + 1; 
    ?stock::agt_Map_Edg(Agt,OldList);
    .union(OldList,[[X,NewY,Type,Detail]],U);
    -stock::agt_Map_Edg(Agt,_); 
    +stock::agt_Map_Edg(Agt, U);  
    ?stock::agt_Map_Edg(Agt,Test);
    // .print("22222222222222222222New Dis:",Test);    
    .


+!agtMemory(Agt,X,Y,Type,Detail)
: Type ==  mapEdge & Detail == e
<-
    NewX = X + 1; 
    ?stock::agt_Map_Edg(Agt,OldList);
    .union(OldList,[[NewX,Y,Type,Detail]],U);
    -stock::agt_Map_Edg(Agt,_); 
    +stock::agt_Map_Edg(Agt, U);  
    ?stock::agt_Map_Edg(Agt,Test);
    .

+!agtMemory(Agt,X,Y,Type,Detail)
: Type ==  mapEdge & Detail == w
<-
    NewX = X + 1; 
    ?stock::agt_Map_Edg(Agt,OldList);
    .union(OldList,[[NewX,Y,Type,Detail]],U);
    -stock::agt_Map_Edg(Agt,_); 
    +stock::agt_Map_Edg(Agt, U);  
    ?stock::agt_Map_Edg(Agt,Test);
    .