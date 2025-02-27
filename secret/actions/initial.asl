+!initialAgent(Agt)
: true
<-
+action::mutexStep(Agt,0);
+stock::agtMap(Agt,[]);	
+stock::mutexStep(Agt,[]);	
+stock::agt_Map_Goa(Agt,[]);	
+stock::agt_Map_Obs(Agt,[]);	
+stock::agt_Map_Ent(Agt,[]);
+stock::agt_Map_Blo(Agt,[]);
+stock::agt_Map_Dis(Agt,[]);
+stock::agt_Pos(Agt, 0 ,0 );	
+common::roles(Agt,explorer);
.print("Init Agent Done: ", Agt);
.