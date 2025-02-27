classify_thing([], [], [], []):-ture.

classify_thing([[X, Y, entity, Detail] | Rest], [X, Y, entity, Detail | Entities], Blocks, Dispensers) :- classify_thing(Rest, Entities, Blocks, Dispensers).
classify_thing([[X, Y, block, Detail] | Rest], Entities, [X, Y, block, Detail | Blocks], Dispensers) :- classify_thing(Rest, Entities, Blocks, Dispensers).
classify_thing([[X, Y, dispenser, Detail] | Rest], Entities, Blocks, [X, Y, dispenser, Detail | Dispensers]) :- classify_thing(Rest, Entities, Blocks, Dispensers).

/* +!agtMemory(X)
: .my_name(Me) & stock::agentPos(Me,AgtPosx,AgtPosy)
<-
.findall([NewX, NewY, Type, Detail], (thing(X, Y, Type, Detail)  & NewX = X + AgtPosx & NewY = Y + AgtPosy), NewThingList);
?stock::agtMap(Me,OldList);
.print(OldList);
.union(OldList,ThingList,U);
-stock::agtMap(Me,OldList);
.print("agtMemory:",U);
+stock::agtMap(Me,U);
. */

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



/* +!classifyMemory
: .my_name(Me)
<-
?stock::agtMap(Me,List);
classify_thing(List,Entities,Blocks,Dispensers);

?stock::agtMapEnti(Me,OldEntis);
.union(OldEntis,Entities,U);
+stock::agtMapEnti(Me,U);

?stock::agtMapBlo(Me,OldBlo);
.union(OldBlo,Block,U);
+stock::agtMapBlo(Me,U);

?stock::agtMapDis(Me,OldDis);
.union(OldDis,Dispensers,U);
+stock::agtMapDis(Me,U);
.
 */

/* +!seek_obs(Agt) 
<- 
.print("Seek_obs:");
for (.member(Xi,[-5,-4,-3,-2,-1,1,2,3,4,5])){    
    for (.member(Yi,[-5,-4,-3,-2,-1,1,2,3,4,5])){    
        .print(Xi," ", Yi, " " , Agt);
        !is_goal(Xi,Yi,Agt);

    }
}.
*/

