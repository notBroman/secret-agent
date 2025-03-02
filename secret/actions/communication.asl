


+!delta(Leader,Local,Teammate,Delta,New)
: true
<-
    New = (Leader - Teammate) + Local;
    Delta = Leader - Teammate;
    .

+!check_encounter(Step,SenderId,SenderX,SenderY,SLocalX,SLocalY)[source(Sender)]
:  not iden::sameSetp | not iden::sameSetp 
<- 
    +iden::identifying(check);
    .wait(1);
    if (team::emailGroup(E))
    {
        if ( not .member(Sender,E))
            {
            
            +iden::newMember;

            }
    }
    else
    {
        +iden::newMember;
    }
    
    .wait({+data::myent(_,_,_,_,_)});
    if (data::myent(MyStep,_,_,_,_))
    {
       
        if (MyStep = Step)
        {
            +iden::sameSetp;
        }
    }

    -iden::identifying(check);

    !encounter_queue(Step,SenderId,SenderX,SenderY,SLocalX,SLocalY,Sender);
    .

+!check_encounter(Step,SenderId,SenderX,SenderY,SLocalX,SLocalY)[source(Sender)] 
: lock::mapMerging(_)  | iden::identifying(_) 
<-
    -iden::newMember;
    -iden::sameSetp;
.

+!check_encounter(Step,SenderId,SenderX,SenderY,SLocalX,SLocalY)[source(Sender)] 
<-
    -iden::newMember;
    -iden::sameSetp;
.


+!encounter_queue(Step,SenderId,SenderX,SenderY,SLocalX,SLocalY,Sender)
:  iden::sameSetp & iden::newMember & not lock::mapMerging(_)  & not iden::identifying(_) 
<- 
    +iden::identifying(encounter);

    ?data::myent(Mystep,MLocalX,MLocalY,MyPosX,MyPosY);
    ?team::members(Agt,MyID,AllAgtmbers,MyDeltaX,MyDeltaY);
    .my_name(Agt);
    //.print("Broadcast1 : receive -> Agt ", Agt ,"  Step :", Step," SenderI: ", SenderId, " Sender X: ", SenderX, " SenderY ", SenderY, " SlocalX ", SLocalX, " slocalY ",SLocalY);
    //.print("MY Local X ", MLocalX, " My local Y: ", MLocalY , " My id ",MyID);

    if ( SLocalX == MLocalX | SLocalX == (-MLocalX) | SLocalY == MLocalY | SLocalY == (-MLocalY) )
    {
        
        if ( MyID > SenderId )
        {

            // Calculate offset of coordinate
            !updateMessageList(Sender);

        }
        elif (SenderId > MyID)
        {            
            !delta(SenderX,SLocalX,MyPosX,DeltaX,NewPosX);
            !delta(SenderY,SLocalY,MyPosY,DeltaY,NewPosY);            
            // Add it to receiveFrom List
            !updateMessageList(Sender);
            
            !merging_prepare( DeltaX, DeltaY,SenderId);

        }                    
        
    } 
    -data::myent(_,_,_,_,_);
    -iden::newMember;
    -iden::sameSetp;
    -iden::identifying(encounter);
    .
+!encounter_queue(Step,SenderId,SenderX,SenderY,SLocalX,SLocalY,Sender)
<-
    !skip;
    .

+!updateMessageList(ContactInfo)
: not team::emailGroup
<-
    
    +team::emailGroup([ContactInfo]);
    
.

+!updateMessageList(ContactInfo)
<-
    
    ?team::emailGroup(Slist);
    .union(ContactInfo,Slist,NewSlist);
    +team::emailGroup(NewSlist);
    -team::emailGroup(Slist);
    
    .

+!broadcastMessage(Agents, DeltaX, DeltaY, NewId) 
<- 
    for (.member(R, Agents)) {
        .send(R, achieve, com::merging_prepare(DeltaX, DeltaY, NewId));
    }
        .

// Mergering : goal
+!merging_map( DeltaX, DeltaY)
: .my_name(Agt) & stock::agt_Map_Goa(GoaList)
<-
    

    +lock::mapMerging(goa);
    .print("updata Map Goal"," Offset is ", DeltaX," and ",DeltaY, " Original GoaList: ", GoaList);
    .setof([NX,NY], (.member([AX,AY], GoaList)& NX = AX + DeltaX & NY= AY + DeltaY), NewGoaList);
    .print("After Merging GoaList:", NewGoaList);
    //!update_list(GoaList, DeltaX, DeltaY, NewGoaList);
    -stock::agt_Map_Goa(_);
    +stock::agt_Map_Goa(NewGoaList);
    -lock::mapMerging(goa);
    
    .

// Mergering : Obstacle
+!merging_map( DeltaX, DeltaY)
: .my_name(Agt) & stock::agt_Map_Obs(ObsList)
<- 
    +lock::mapMerging(obs);
    .print("updata Map Obs"," Offset is ", DeltaX," and ",DeltaY, "Original ObsList:", ObsList);
    .setof([NX,NY], (.member([AX,AY], ObsList)& NX = AX + DeltaX & NY= AY + DeltaY), NewObsList);
    .print("After Merging NewObsList:", NewObsList);
    //!update_list(ObsList, DeltaX, DeltaY, NewObsList); 
    -stock::agt_Map_Obs(_);
    +stock::agt_Map_Obs( NewObsList);
    -lock::mapMerging(obs);
    .

// Mergering : Dispenser
+!merging_map( DeltaX, DeltaY)
: .my_name(Agt) & stock::agt_Map_Dis(Agt, Step, DisList,DisType)
<-  
    +lock::mapMerging(dis);
    .print("updata Map Dispenser");
    .print("updata Map Dis"," Offset is ", DeltaX," and ",DeltaY, "Original DisList:", DisList);
    .setof([NX,NY,Type], (.member([AX,AY,Type], DisList)& NX = AX + DeltaX & NY= AY + DeltaY), NewDisList);
    .print("After Merging NewDisList:", NewDisList);
    //!update_list(DisList, DeltaX, DeltaY, NewDisList);
    -stock::agt_Map_Dis( DisList);
    +stock::agt_Map_Dis( NewDisList);
    -lock::mapMerging(dis);
    .

+!merging_map( DeltaX, DeltaY)
: .my_name(Agt) & stock::agt_Map_Blo(Agt, Step, BloList,BloType)
<-  
    +lock::mapMerging(blo);
    .print("updata Map Block");
    .print("updata Map Block"," Offset is ", DeltaX," and ",DeltaY, "Original BloList:", BloList);
    .setof([NX,NY], (.member([AX,AY], BloList)& NX = AX + DeltaX & NY= AY + DeltaY), NewBloList);
    .print("After Merging NewDisList:", NewDisList);
    //!update_list(DisList, DeltaX, DeltaY, NewDisList);
    -stock::agt_Map_Blo(Agt, Step, BloList,BloType);
    +stock::agt_Map_Blo(Agt, Step, NewBloList,BloType);
    -lock::mapMerging(blo);
    .

+!merging_prepare( DeltaX, DeltaY,SenderId)
: team::members(Agt,MyID,AllMembers,MyDeltaX,MyDeltaY) & MyID < SenderId & pos::agt_Pos(_, Step,MyPosX,MyPosY)
<-
    +lock::mapMerging(pre);
    // Infected to the same level as the Leader
    .my_name(Agt);
    +team::members(Agt,SenderId,AllMembers,DeltaX,DeltaY);
    -team::members(Agt,MyID,AllMembers,MyDeltaX,MyDeltaY);
    NewPosX = MyPosX + DeltaX ;
    NewPosY = MyPosY + DeltaY ;
    .print("old aix is ", MyPosX, " ", MyPosY, " New is ", NewPosX, " and ", NewPosY, "Deltaa is ", DeltaX , " ", DeltaY, "sendid is ",SenderId);
    -pos::agt_Pos(_,_,_,_);
    +pos::agt_Pos(Agt,Step ,NewPosX ,NewPosY);

    !merging_map(DeltaX, DeltaY);
    -lock::mapMerging(pre);
/*     if(team::emailGroup(Slist))
    {
        !broadcastMessage(Slist,DeltaX,DeltaY, SenderId);
            
    } */
    
    .

+!merging_prepare( DeltaX, DeltaY,SenderId)[source(Sender)]
: team::members(Agt,MyID,AllMembers,MyDeltaX,MyDeltaY) & MyID > SenderId
<-

    // Infected to the same level as the Leader
    
    .send(Sender, achieve, com::merging_prepare(MyDeltaX, MyDeltaY,MyID));
    
    .

+!merging_prepare( DeltaX, DeltaY,SenderId)[source(Sender)]
: team::members(Agt,MyID,AllMembers,MyDeltaX,MyDeltaY) & MyID == SenderId
<-
    .print("We are the same. Do nothing  ", MyID);
    .
// Things Database is empty
+!merging_map( DeltaX, DeltaY)
: not stock::agt_Map_Dis(Agt, Step, DisList) & not stock::agt_Map_Obs(ObsList) & not stock::agt_Map_Goa(GoaList)
<-
!skip    .


+!skip : true . 

+!merging_map(DeltaX,DeltaY)
: stock::agt_Map_Edg_Y_N(Y)
<- 

    NY = Y + DeltaY;
    -stock::agt_Map_Edg_Y_N(_);
    +stock::agt_Map_Edg_Y_N(NY);

    .

+!merging_map(DeltaX,DeltaY)
: stock::agt_Map_Edg_Y_S(Y)
<- 
    
    NY = Y + DeltaY;
    -stock::agt_Map_Edg_Y_S(_);
    +stock::agt_Map_Edg_Y_S(NY);
    
    .

+!merging_map(DeltaX,DeltaY)
: stock::agt_Map_Edg_X_W(X)
<- 
    NX = X + DeltaX;
    -stock::agt_Map_Edg_X_W(_);
    +stock::agt_Map_Edg_X_W(NX);
    .

+!merging_map(DeltaX,DeltaY)
: stock::agt_Map_Edg_X_E(X)
<- 
    NX = X + DeltaX;
    -stock::agt_Map_Edg_X_E(_);
    +stock::agt_Map_Edg_X_E(NX);
    .

