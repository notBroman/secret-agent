
delta(Leader,Teammate,Delta) :- Delta = (Leader - Teammate).

// Filter encounter information
+!check_encounter(Step, SenderX, SenderY, SLocalX, SLocalY)[source(Sender)]
:   not lock::mapMerging(_) | team::emailGroup(Mem) & not .member(Sender,Mem)
<- 
    .wait({+data::myent(_,_,_,_,_,_,_)});
    if (data::myent(MyStep,_,_,_,_,_,_))
    {
        ?data::myent(AA,_,_,_,_,_,_);
       
        if (AA = Step)
        {
            //.print("Mystep ", AA,  "Step ", Step);
            !encounter_queue(Step, SenderX, SenderY, SLocalX, SLocalY,Sender);

           
        }
    }
    .

+!check_encounter(Step, SenderX, SenderY, SLocalX, SLocalY)[source(Sender)] 
<-
    -iden::newMember;
    -iden::sameSetp;
.

// Identify teammates
+!encounter_queue(Step, SenderX, SenderY, SLocalX, SLocalY,Sender)
:  not team::members(Sender,_,_,_,_) &  not lock::mapMerging(_)  & data::myent(Step,MLocalX,MLocalY,MyPosX,MyPosY,ObjX,ObjY) & SLocalX == (-MLocalX) & SLocalY == (-MLocalY)
<- 
    
    //.wait(pos::agt_Pos(_, Step,  _, _));
    .my_name(Agt);
    ?team::members(Agt,_,AllMembers,_,_);
    +lock::mapMerging(enc);
    .nth(Index, AllMembers, Sender);
   // .my_name(Agt);
    DeltaX = (MyPosX - SenderX);
    DeltaY = (MyPosY - SenderY);    
    .print(Sender, " " ,MyPosX, " ", MyPosY);
    .print(Sender, " " ,SenderX, " ", SenderY);
    .print(Sender, " " ,DeltaX, " ", DeltaY);
    +team::members(Sender,Index,AllMembers,DeltaX,DeltaY);

    ?team::emailGroup(Email);
    .union([[Sender]],Email,NewEmail);    
    -team::emailGroup(_);
    +team::emailGroup(NewEmail);
    .wait(1);

    -iden::newMember;
    -iden::sameSetp;
    -lock::mapMerging(enc);
    .
+!encounter_queue(Step, SenderX, SenderY, SLocalX, SLocalY,Sender).


// Merge known information from teammates.
+!tell_me_your_goal[source(Sender)]
: team::members(Sender,Index,AllMembers,DeltaX,DeltaY) & .my_name(Agt) & stock::agt_Map_Goa(MyList) & not lock::update_goal
<-
+lock::update_goal;
//-stock::agt_Map_Goa_temp([]);
.send(Sender, askOne , stock::agt_Map_Goa_temp(IsList));
.wait(stock::agt_Map_Goa_temp(_)[source(Sender)]);
?stock::agt_Map_Goa_temp(YourList)[source(Sender)];
.print("here goal ",YourList);

.setof([NX,NY], (.member([AX,AY], YourList)& NX = AX + DeltaX & NY= AY + DeltaY), NewList);
+strock::yourList(Sender,NewList);

.union(NewList,MyList,NewMylist);
-stock::agt_Map_Goa(_);
+stock::agt_Map_Goa(NewMylist);


-stock::agt_Map_Goa_temp(_)[source(Sender)];
.abolish(agt_Map_Goa_temp(_));
+stock::agt_Map_Goa_temp(NewMylist);
.wait(1);

-lock::update_goal;
.


+!tell_me_your_goal[source(Sender)].


+!tell_me_your_dis[source(Sender)]
: stock::agt_Map_Dis(MyList) & team::members(Sender,Index,AllMembers,DeltaX,DeltaY) & .my_name(Agt) &  not lock::update_dis
<-
+lock::update_dis;

.send(Sender, askOne , stock::agt_Map_Dis_temp(IsList));
.print(Sender);
.wait(1);
?stock::agt_Map_Dis_temp(YourList)[source(Sender)];
.print("here dis ",YourList);

.setof([NX,NY,Type], (.member([AX,AY,Type], YourList)& NX = AX + DeltaX & NY= AY + DeltaY), NewList);
+strock::yourList_dis(Sender,NewList);

.union(NewList,MyList,NewMylist);
-stock::agt_Map_Dis(_);
+stock::agt_Map_Dis(NewMylist);


-stock::agt_Map_Dis_temp(_)[source(Sender)];
.abolish(agt_Map_Dis_temp(_)[source(Self)]);
+stock::agt_Map_Dis_temp(NewMylist);
.wait(1);

-lock::update_dis;
.


+!tell_me_your_dis[source(Sender)].

