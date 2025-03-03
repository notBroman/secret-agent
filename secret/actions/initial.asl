+!initialAgent(Agt)
<-
+stock::agt_Map_Blo([ ]);
+stock::agt_Map_Dis([ ]);
+stock::agt_Map_Goa([ ]);
+stock::agt_Map_Obs([ ]);

+team::roles(Agt,explorer);
+team::gamers(Agt);
+team::emailGroup([ ]);

+stock::findEdge_NW;
+stock::findEdge_ES;
+lock::allow_update_location;

/* +data::myent(0,0,0,0,0); */

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
/*     for (.member(R, AllMembers)) {
        +iden::sender(R,(0),(0));
    } */
    .print("Team is ",Me, " ", NewI," ", " " , AllMembers);
    .abolish(team::gamers(_));
    .