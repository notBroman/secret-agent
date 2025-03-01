+!initialAgent(Agt)
<-


+pos::agt_Pos(Agt, 0 ,0 ,0);	

+team::roles(Agt,explorer);
+team::gamers(Agt);

+stock::findEdge_NW;
+stock::findEdge_ES;

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

+!sortMembers
<-
    .wait(10);
    .my_name(Me);
    .setof(Members, team::gamers(Members), AllMembers);
    .nth(Index, AllMembers, Me);
    NewI = Index + (1);      
    +team::members(Me,NewI,AllMembers,(0),(0));
    .print("Team is ",Me, " ", NewI," ", " " , AllMembers);
    .abolish(team::gamers(_));
    .