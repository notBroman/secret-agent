+!initialAgent(Agt)
: true
<-

+stock::agt_Map_Goa(Agt,0,[]);	
+stock::agt_Map_Obs(Agt,0,[]);	
+stock::agt_Map_Ent(Agt,0,[]);
+stock::agt_Map_Blo(Agt,0,[]);
+stock::agt_Map_Dis(Agt,0,[]);



+common::roles(Agt,S,explorer);
.print("Init Agent Done: ", Agt);
.