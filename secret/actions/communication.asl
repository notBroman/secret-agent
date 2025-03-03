
delta(Leader,Teammate,Delta) :- Delta = (Leader - Teammate).

+!check_encounter(Step, SenderId, SenderX, SenderY, SLocalX, SLocalY,SenderOwnX,SenderOwnY)[source(Sender)]
:   not lock::mapMerging(_)
<- 
    
    .wait({+data::myent(_,_,_,_,_,_,_)});
    if (data::myent(MyStep,_,_,_,_,_,_))
    {
        ?data::myent(AA,_,_,_,_,_,_);
       
        if (AA = Step)
        {
            //.print("Mystep ", AA,  "Step ", Step);
            !encounter_queue(Step, SenderId, SenderX, SenderY, SLocalX, SLocalY,SenderOwnX,SenderOwnY,Sender);
           
        }
    }

   
    //.print("What is worng ", Step, "My location in Sender X", SenderX, " ", SenderY , " Local ", SLocalX, " ", SLocalY , " Sender own", SenderOwnX, SenderOwnY );

    .

+!check_encounter(Step, SenderId, SenderX, SenderY, SLocalX, SLocalY,SenderOwnX,SenderOwnY)[source(Sender)] 
: lock::mapMerging(_) 
<-
    -iden::newMember;
    -iden::sameSetp;
.

+!check_encounter(Step, SenderId, SenderX, SenderY, SLocalX, SLocalY,SenderOwnX,SenderOwnY)[source(Sender)] 
: team::emailGroup(Mem) & .member(Sender,Mem)
<-
    -iden::newMember;
    -iden::sameSetp;
.

+!check_encounter(Step, SenderId, SenderX, SenderY, SLocalX, SLocalY,SenderOwnX,SenderOwnY)[source(Sender)] 
<-
    -iden::newMember;
    -iden::sameSetp;
.


+!encounter_queue(Step, SenderId, SenderX, SenderY, SLocalX, SLocalY,SenderOwnX,SenderOwnY,Sender)
:    not lock::mapMerging(_)  & data::myent(Step,MLocalX,MLocalY,MyPosX,MyPosY,ObjX,ObjY) & (SLocalX == MLocalX | SLocalX == (-MLocalX)) & (SLocalY == MLocalY | SLocalY == (-MLocalY))
<- 
    
    //.wait(pos::agt_Pos(_, Step,  _, _));
    
    ?team::members(Agt,MyID,AllAgtmbers,MyDeltaX,MyDeltaY);
    .my_name(Agt);
    //.print("Broadcast1 : receive -> Agt ", Agt ,"  Step :", Step," SenderI: ", SenderId, " Sender X: ", SenderX, " SenderY ", SenderY, " SlocalX ", SLocalX, " slocalY ",SLocalY);
    //.print("MY Local X ", MLocalX, " My local Y: ", MLocalY , " My id ",MyID);
    //.print("This is satrt ", Step, "My location in Sender X", SenderX, " ", SenderY , " Local ", SLocalX, " ", SLocalY , " Sender own", SenderOwnX, SenderOwnY );
    //.print("What is start, my location", MyPosX," ", MyPosY);
    //.print("SlocalX ",SLocalX , ",MlocalX  ", MLocalX, ", SlocalY ", SLocalY, ", ", MLocalY );
    //.print("IDs: MyID",MyID, "Sender Id",SenderId);
        
        if ( MyID > SenderId )
        {

            // Calculate offset of coordinate
            !updateMessageList(Sender);
        }
        elif (SenderId > MyID)
        {            
            ?delta(SenderX,MyPosX,DeltaX);
            ?delta(SenderY,MyPosY,DeltaY);            
            // Add it to receiveFrom List
            !updateMessageList(Sender);
            .send(Sender,achieve, com::comfirmMailList);
            
            !merging_prepare( DeltaX, DeltaY,Step, SenderId, SenderX, SenderY, SLocalX, SLocalY,SenderOwnX,SenderOwnY,Sender);
            .print("Begin merging, sender is ", Sender );
        }                    
        
    
    //-data::myent(_,_,_,_,_,_,_);
    -iden::newMember;
    -iden::sameSetp;
    
    .
+!encounter_queue(Step, SenderId, SenderX, SenderY, SLocalX, SLocalY,SenderOwnX,SenderOwnY,Sender)
<-
    !skip;
    .



+!updateMessageList(ContactInfo)
: team::emailGroup(Slist)
<-
    
    
    .union([ContactInfo],Slist,NewSlist);
    +team::emailGroup(NewSlist);
    -team::emailGroup(Slist);
    
    .

+!updateMessageList(ContactInfo)
: not team::emailGroup(_)
<-
    +team::emailGroup([ContactInfo]);
.


+!comfirmMailList[source(Sender)]
<-
    .my_name(Agt);
     if (team::emailGroup(E))
    {
        if ( not .member(Sender,E))
            {
                .print("I ", Agt, "Add.", Sender, " to mail list");
                !updateMessageList(Sender);

            }
        else
        {
            .print("I ", Agt, "already got you.", Sender);
        }
    }
    else
    {
        .print("I ", Agt, "Add.", Sender, " to mail list");
        !updateMessageList(Sender);
        
    }

    .

+!broadcastMessage(Agents, DeltaX, DeltaY, NewId) 
<- 
    for (.member(R, Agents)) {
        .send(R, achieve, merging_map( DeltaX, DeltaY,Step, SenderId, SenderX, SenderY, SLocalX, SLocalY,SenderOwnX,SenderOwnY,Sender, DeltaX, DeltaY));
    }
        .

// Mergering : goal
 +!merging_map_goa( DeltaX, DeltaY,Step, SenderId, SenderX, SenderY, SLocalX, SLocalY,SenderOwnX,SenderOwnY,Sender, DeltaX, DeltaY)
: .my_name(Agt) & stock::agt_Map_Goa(GoaList)
<-
    

    +lock::mapMerging(goa);
    .print("What is worng ", Step, "My location in Sender X", SenderX, " ", SenderY , " Local ", SLocalX, " ", SLocalY , " Sender own", SenderOwnX, SenderOwnY );
    .print("updata Map Goal Offset is ", DeltaX," and ",DeltaY, ", The Original GoaList: ", GoaList);
    .setof([NX,NY], (.member([AX,AY], GoaList)& NX = AX + DeltaX & NY= AY + DeltaY), NewGoaList);
    .print("After Merging GoaList:", NewGoaList);
    //!update_list(GoaList, DeltaX, DeltaY, NewGoaList);
    -stock::agt_Map_Goa(_);
    +stock::agt_Map_Goa(NewGoaList);
    -lock::mapMerging(goa);
        
    . 
+!merging_map_goa( DeltaX, DeltaY,Step, SenderId, SenderX, SenderY, SLocalX, SLocalY,SenderOwnX,SenderOwnY,Sender, DeltaX, DeltaY)
<-
    .print(" merg goa fail");
    .
// Mergering : Obstacle
+!merging_map_obs( DeltaX, DeltaY,Step, SenderId, SenderX, SenderY, SLocalX, SLocalY,SenderOwnX,SenderOwnY,Sender, DeltaX, DeltaY)
: .my_name(Agt) & stock::agt_Map_Obs(ObsList)
<- 
    +lock::mapMerging(obs);
    .print("What is worng ", Step, "My location in Sender X", SenderX, " ", SenderY , " Local ", SLocalX, " ", SLocalY , " Sender own", SenderOwnX, SenderOwnY );
    .print("updata Map Obs"," Offset is ", DeltaX," and ",DeltaY, ", The Original ObsList:", ObsList);
    .setof([NX,NY], (.member([AX,AY], ObsList) & NX = AX + DeltaX & NY= AY + DeltaY), NewObsList);
    .print("After Merging NewObsList:", NewObsList);
    //!update_list(ObsList, DeltaX, DeltaY, NewObsList); 
    -stock::agt_Map_Obs(_);
    +stock::agt_Map_Obs( NewObsList);
    -lock::mapMerging(obs);
    
    .
+!merging_map_obs( DeltaX, DeltaY,Step, SenderId, SenderX, SenderY, SLocalX, SLocalY,SenderOwnX,SenderOwnY,Sender, DeltaX, DeltaY)
<-
    .print(" merg obs fail");
    .

// Mergering : Dispenser
+!merging_map_dis( DeltaX, DeltaY,Step, SenderId, SenderX, SenderY, SLocalX, SLocalY,SenderOwnX,SenderOwnY,Sender, DeltaX, DeltaY)
: .my_name(Agt) & stock::agt_Map_Dis(DisList)
<-  
    +lock::mapMerging(dis);
    .print("updata Map Dispenser");
    .print("What is worng ", Step, "My location in Sender X", SenderX, " ", SenderY , " Local ", SLocalX, " ", SLocalY , " Sender own", SenderOwnX, SenderOwnY );
    .print("updata Map Dis"," Offset is ", DeltaX," and ",DeltaY, ", Original DisList:", DisList);
    .setof([NX,NY,Type], (.member([AX,AY,Type], DisList)& NX = AX + DeltaX & NY= AY + DeltaY), NewDisList);
    .print("After Merging NewDisList:", NewDisList);
    //!update_list(DisList, DeltaX, DeltaY, NewDisList);
    -stock::agt_Map_Dis( DisList);
    +stock::agt_Map_Dis( NewDisList);
    -lock::mapMerging(dis);
    
    .
+!merging_map_dis( DeltaX, DeltaY,Step, SenderId, SenderX, SenderY, SLocalX, SLocalY,SenderOwnX,SenderOwnY,Sender, DeltaX, DeltaY)
<-
    .print(" merg dis fail");
    .
//Bolock
+!merging_map_blo( DeltaX, DeltaY,Step, SenderId, SenderX, SenderY, SLocalX, SLocalY,SenderOwnX,SenderOwnY,Sender, DeltaX, DeltaY)
: .my_name(Agt) & stock::agt_Map_Blo(BloList)
<-  
    +lock::mapMerging(blo);
    .print("updata Map Block");
    .print("updata Map Block"," Offset is ", DeltaX," and ",DeltaY, ", Original BloList:", BloList);
    .setof([NX,NY], (.member([AX,AY], BloList)& NX = AX + DeltaX & NY= AY + DeltaY), NewBloList);
    .print("After Merging NewDisList:", NewDisList);
    //!update_list(DisList, DeltaX, DeltaY, NewDisList);
    -stock::agt_Map_Blo(Agt, Step, BloList,BloType);
    +stock::agt_Map_Blo(Agt, Step, NewBloList,BloType);
    -lock::mapMerging(blo);
    .
+!merging_map_blo( DeltaX, DeltaY,Step, SenderId, SenderX, SenderY, SLocalX, SLocalY,SenderOwnX,SenderOwnY,Sender, DeltaX, DeltaY)
<-
    .print(" merg blo fail");
    .
+!merging_prepare( DeltaX, DeltaY,Step, SenderId, SenderX, SenderY, SLocalX, SLocalY,SenderOwnX,SenderOwnY,Sender)
: team::members(Agt,MyID,AllMembers,MyDeltaX,MyDeltaY) & MyID < SenderId & pos::agt_Pos(Agt, _ ,MyPosX,MyPosY) & lock::allow_update_location
<-
    
    
    +lock::mapMerging(pre);
    // Infected to the same level as the Leader
    .my_name(Agt);
    
    
    NewPosX = MyPosX + DeltaX ;
    NewPosY = MyPosY + DeltaY ;
    .print("old aix is ", MyPosX, " ", MyPosY, " New is ", NewPosX, " ", NewPosY, " Deltaa is ", DeltaX , " ", DeltaY, " sendid is ",SenderId);
    -lock::allow_update_location;
    -pos::agt_Pos(_,_,_,_);
    +pos::agt_Pos(Agt,Step ,NewPosX ,NewPosY);
    +lock::allow_update_location;

    -team::members(Agt,MyID,AllMembers,MyDeltaX,MyDeltaY);
    +team::members(Agt,SenderId,AllMembers,DeltaX,DeltaY);

    !merging_map_blo( DeltaX, DeltaY,Step, SenderId, SenderX, SenderY, SLocalX, SLocalY,SenderOwnX,SenderOwnY,Sender,DeltaX, DeltaY);
    !merging_map_dis( DeltaX, DeltaY,Step, SenderId, SenderX, SenderY, SLocalX, SLocalY,SenderOwnX,SenderOwnY,Sender,DeltaX, DeltaY);
    !merging_map_goa( DeltaX, DeltaY,Step, SenderId, SenderX, SenderY, SLocalX, SLocalY,SenderOwnX,SenderOwnY,Sender,DeltaX, DeltaY);
    !merging_map_obs( DeltaX, DeltaY,Step, SenderId, SenderX, SenderY, SLocalX, SLocalY,SenderOwnX,SenderOwnY,Sender,DeltaX, DeltaY);
    -lock::mapMerging(pre);
    
    
/*     if(team::emailGroup(Slist))
    {
        !broadcastMessage(Slist,DeltaX,DeltaY, SenderId);
            
    } */
    
    .

+!merging_prepare( DeltaX, DeltaY,Step, SenderId, SenderX, SenderY, SLocalX, SLocalY,SenderOwnX,SenderOwnY,Sender)
: not lock::allow_update_location
<-
    !merging_prepare( DeltaX, DeltaY,Step, SenderId, SenderX, SenderY, SLocalX, SLocalY,SenderOwnX,SenderOwnY,Sender);
.
/* +!merging_prepare( DeltaX, DeltaY,Step, SenderId, SenderX, SenderY, SLocalX, SLocalY,SenderOwnX,SenderOwnY,Sender)[source(Sender)]
: team::members(Agt,MyID,AllMembers,MyDeltaX,MyDeltaY) & MyID > SenderId
<-

    // Infected to the same level as the Leader
    
    .send(Sender, achieve, com::merging_prepare(MyDeltaX, MyDeltaY,MyID));
    
    . */

+!merging_prepare( DeltaX, DeltaY,Step, SenderId, SenderX, SenderY, SLocalX, SLocalY,SenderOwnX,SenderOwnY,Sender)
: team::members(Agt,MyID,AllMembers,MyDeltaX,MyDeltaY) & MyID == SenderId
<-
    .print("We are the same. Do nothing  ", MyID);
    .
+!merging_prepare( DeltaX, DeltaY,Step, SenderId, SenderX, SenderY, SLocalX, SLocalY,SenderOwnX,SenderOwnY,Sender) : true .
// Things Database is empty
+!merging_map( DeltaX, DeltaY,Step, SenderId, SenderX, SenderY, SLocalX, SLocalY,SenderOwnX,SenderOwnY,Sender, DeltaX, DeltaY)
: true
<-
    .print("Merging Fail.");
     .


+!skip : true . 



+!merging_map( DeltaX, DeltaY,Step, SenderId, SenderX, SenderY, SLocalX, SLocalY,SenderOwnX,SenderOwnY,Sender, DeltaX,DeltaY)
: stock::agt_Map_Edg_Y_N(Y)
<- 

    NY = Y + DeltaY;
    -stock::agt_Map_Edg_Y_N(_);
    +stock::agt_Map_Edg_Y_N(NY);

    .

+!merging_map( DeltaX, DeltaY,Step, SenderId, SenderX, SenderY, SLocalX, SLocalY,SenderOwnX,SenderOwnY,Sender, DeltaX,DeltaY)
: stock::agt_Map_Edg_Y_S(Y)
<- 
    
    NY = Y + DeltaY;
    -stock::agt_Map_Edg_Y_S(_);
    +stock::agt_Map_Edg_Y_S(NY);
    
    .

+!merging_map( DeltaX, DeltaY,Step, SenderId, SenderX, SenderY, SLocalX, SLocalY,SenderOwnX,SenderOwnY,Sender, DeltaX,DeltaY)
: stock::agt_Map_Edg_X_W(X)
<- 
    NX = X + DeltaX;
    -stock::agt_Map_Edg_X_W(_);
    +stock::agt_Map_Edg_X_W(NX);
    .

+!merging_map( DeltaX, DeltaY,Step, SenderId, SenderX, SenderY, SLocalX, SLocalY,SenderOwnX,SenderOwnY,Sender, DeltaX,DeltaY)
: stock::agt_Map_Edg_X_E(X)
<- 
    NX = X + DeltaX;
    -stock::agt_Map_Edg_X_E(_);
    +stock::agt_Map_Edg_X_E(NX);
    .

