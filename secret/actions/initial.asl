+!initialAgent(Agt)
: true
<-

+stock::agt_Map_Goa(Agt,0,[]);	
+stock::agt_Map_Obs(Agt,0,[]);	
+stock::agt_Map_Ent(Agt,0,[]);
+stock::agt_Map_Blo(Agt,0,[]);
+stock::agt_Map_Dis(Agt,0,[]);

+team::roles(Agt,explorer);
+team::gamers(Agt);

.print("Init Agent Done: ", Agt);
.



+!joinTeam[source(Sender)]
: not joining
<- 
    +joining;
    +team::gamers(Sender);
    -joining;
.
+!joinTeam[source(Sender)]
: joining
<-
!joinTeam[source(Sender)];

.

+!sortMembers(Tname)
<-
    .wait(10);
    .my_name(Me);
    .setof(Members, team::gamers(Members), AllMembers);
    .nth(Index, AllMembers, Me);
    NewI = Index + (1);      
    +team::members(Me,NewI,Tname,AllMembers);
    .print("Team is ",Me, " ", NewI," ",Tname, " " , AllMembers);
    .abolish(team::gamers(_));
    .