+!initialAgent(Agt)
: true
<-

+stock::agt_Map_Goa(Me,0,[]);	
+stock::agt_Map_Obs(Me,0,[]);	
+stock::agt_Map_Ent(Me,0,[]);
+stock::agt_Map_Blo(Me,0,[]);
+stock::agt_Map_Dis(Me,0,[]);
+stock::agt_Map_Edg(Me,0,[]);


+common::roles(Me,S,explorer);
.print("Init Agent Done: ", Agt);
.