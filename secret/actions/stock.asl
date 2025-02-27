

+!agtMemory(Agt,X,Y,Type,Detail)
: Type == obstacle
<-
/* .print("22222222222222222222Type"," ",Type); */
?stock::agt_Map_Obs(Agt,OldList);
.union(OldList,[[X,Y,Type,Detail]],U);
-stock::agt_Map_Obs(Agt,OldList); 
+stock::agt_Map_Obs(Agt, U);  
?stock::agt_Map_Obs(Agt,Test);
/* .print("22222222222222222222New Obs:",Test);     */

.

+!agtMemory(Agt,X,Y,Type,Detail)
: Type == goal
<-
/* .print("22222222222222222222Type"," ",Type); */
?stock::agt_Map_Goa(Agt,OldList);
.union(OldList,[[X,Y,Type,Detail]],U);
-stock::agt_Map_Goa(Agt,OldList); 
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
-stock::agt_Map_Dis(Agt,OldList); 
+stock::agt_Map_Dis(Agt, U);  
?stock::agt_Map_Dis(Agt,Test);
// .print("22222222222222222222New Dis:",Test);    
.
