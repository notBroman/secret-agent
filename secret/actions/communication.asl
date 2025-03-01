


+!delta(Leader,Local,Teammate,Delta,New)
: true
<-
    New = (Leader + Local) - Teammate;
    Delta = New - Teammate;
    .


+!encounter_queue(Step,SenderId,SenderX,SenderY,SLocalX,SLocalY)[source(Sender)]
:  .my_name(Agt) &  pos::agt_Pos(Agt,Step,MyPosX,MyPosY) & data::myent(Agt,Step,MLocalX,MLocalY,_) & team::members(Agt,MyID,AllAgtmbers,MyDeltaX,MyDeltaY)
<- 
    
    
    .print("Broadcast1 : receive -> Agt ", Agt ,"  Step :", Step," SenderI: ", SenderId, " Sender X: ", SenderX, " SenderY ", SenderY, " SlocalX ", SLocalX, " slocalY ",SLocalY);
    .print("MY Local X ", MLocalX, " My local Y: ", MLocalY , " My id ",MyID);

    if ( SLocalX == MLocalX | SLocalX == (-MLocalX) | SLocalY == MLocalY | SLocalY == (-MLocalY) )
    {
        
        if ( MyID > SenderId )
        {

            // Calculate offset of coordinate
            !delta(MyPosX,MLocalX,SenderX,DeltaX,NewPosX);
            !delta(MyPosY,MLocalY,SenderY,DeltaY,NewPosY);

            .print("I am Team Leader");
            .print("My X ", MyPosX, " My Local X ", MLocalX, " Sneder X ", SenderX, " DeltaX: ", DeltaX);
            .print("My Y ", MyPosY, " My Local Y ", MLocalY, " Sender Y ", SenderY, " DeltaY: ", DeltaY);

            // Add it to sendTo List.
            !updateMessageList(Sender);

            //.send(Sender,achieve, com::docking(teammate,DeltaX,DeltaY));

        }
        elif (SenderId > MyID)
        {

            

            !delta(SenderX,SLocalX,MyPosX,DeltaX,NewPosX);
            !delta(SenderY,SLocalY,MyPosY,DeltaY,NewPosY);
            .print("I am Teammate."," ");
            
            .print("My X ", MyPosX, " My Local X ", MLocalX, " Sneder X", SenderX, "DeltaX: ", DeltaX);
            .print("My Y ", MyPosY, " My Local Y ", MLocalY, " Sender Y ", SenderY, " DeltaY:  ", DeltaY);

            // Add it to receiveFrom List
            !updateMessageList(Sender);

            // Using the Leader Map
            -pos::agt_Pos(Agt,Step,MyPosX,MyPosY);
            +pos::agt_Pos(Agt, Step ,NewPosX ,NewPosY);

            // Infected to the same level as the Leader

            .print("Update the Pos : Orignal X ", MyPosX, " Orignal Y ", MyPosY, " DeltaX ", DeltaX, " Delta Y ", DeltaY, " New X ", NewPosX, " New Y ", NewPosY);
            
            !merging_prepare( DeltaX, DeltaY,SenderId);

        }
            
        
        
    } 
    -data::myent(Agt,_,_,_,_);
    
    .
+!encounter_queue(Step,SenderId,SenderX,SenderY,SLocalX,SLocalY)[source(Sender)] 
<-
    .print("221b FFFFFFFFFFFFFFFFFFFFFFFFFFF");
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



+!broadcastMessage([],DeltaX,DeltaY,NewId) <- true.

+!broadcastMessage([R | Rest], DeltaX, DeltaY,NewId) 
    <- 
        .print("boradcstMessage : sent to ", R);
        .send(R, achieve, com::merging_prepare(DeltaX, DeltaY,NewId));
        .wait(5);
        !broadcastMessage(Rest, DeltaX, DeltaY,NewId);
   .
// Mergering : goal
+!merging_map( DeltaX, DeltaY)
: .my_name(Agt) & stock::agt_Map_Goa(Agt, Step, GoaList)
<-
    +lock::mapMerging(goa);
    .print("updata Map Goal"," Offset is ", DeltaX," and ",DeltaY);
    .print("Original GoaList:", GoaList);
    .setof([NX,NY], (.member([AX,AY], GoaList)& NX = AX + DeltaX & NY= AY + DeltaY), NewGoaList);
    .print("After Merging GoaList:", NewGoaList);
    //!update_list(GoaList, DeltaX, DeltaY, NewGoaList);
    -stock::agt_Map_Goa(Agt, Step, GoaList);
    +stock::agt_Map_Goa(Agt, Step, NewGoaList);
    -lock::mapMerging(goa);
    .

// Mergering : Obstacle
+!merging_map( DeltaX, DeltaY)
: .my_name(Agt) & stock::agt_Map_Obs(Agt, Step, ObsList)
<- 
    +lock::mapMerging(obs);
    .print("updata Map Obstacle");
    .print("Original ObsList:", ObsList);
    .setof([NX,NY], (.member([AX,AY], ObsList)& NX = AX + DeltaX & NY= AY + DeltaY), NewObsList);
    .print("After Merging NewObsList:", NewObsList);
    //!update_list(ObsList, DeltaX, DeltaY, NewObsList); 
    -stock::agt_Map_Obs(Agt, Step, ObsList);
    +stock::agt_Map_Obs(Agt, Step, NewObsList);
    -lock::mapMerging(obs);
    .

// Mergering : Dispenser
+!merging_map( DeltaX, DeltaY)
: .my_name(Agt) & stock::agt_Map_Dis(Agt, Step, DisList,DisType)
<-  
    +lock::mapMerging(dis);
    .print("updata Map Dispenser");
    .print("Original DisList:", DisList);
    .setof([NX,NY], (.member([AX,AY], DisList)& NX = AX + DeltaX & NY= AY + DeltaY), NewDisList);
    .print("After Merging NewDisList:", NewDisList);
    //!update_list(DisList, DeltaX, DeltaY, NewDisList);
    -stock::agt_Map_Dis(Agt, Step, DisList,DisType);
    +stock::agt_Map_Dis(Agt, Step, NewDisList,DisType);
    -lock::mapMerging(dis);
    .

+!merging_map( DeltaX, DeltaY)
: .my_name(Agt) & stock::agt_Map_Blo(Agt, Step, BloList,BloType)
<-  
    +lock::mapMerging(blo);
    .print("updata Map Block");
    .print("Original BloList:", BloList);
    .setof([NX,NY], (.member([AX,AY], BloList)& NX = AX + DeltaX & NY= AY + DeltaY), NewBloList);
    .print("After Merging NewDisList:", NewDisList);
    //!update_list(DisList, DeltaX, DeltaY, NewDisList);
    -stock::agt_Map_Dis(Agt, Step, BloList,BloType);
    +stock::agt_Map_Dis(Agt, Step, NewBloList,BloType);
    -lock::mapMerging(blo);
    .

+!merging_prepare( DeltaX, DeltaY,SenderId)
: team::members(Agt,MyID,AllMembers,MyDeltaX,MyDeltaY) & MyID < SenderId
<-

    // Infected to the same level as the Leader
    +team::members(Agt,SenderId,AllMembers,DeltaX,DeltaY);
    -team::members(Agt,MyID,AllMembers,MyDeltaX,MyDeltaY);
    .print("My Id is change ", Sender, " -> ", SenderId);

    !merging_map(DeltaX, DeltaY);

    if(team::emailGroup(Slist))
    {
        .print("boradcstMessage Begin : ", Slist);
        !broadcastMessage(Slist,DeltaX,DeltaY, SenderId);
            
    }
    
    .

+!merging_prepare( DeltaX, DeltaY,SenderId)[source(Sender)]
: team::members(Agt,MyID,AllMembers,MyDeltaX,MyDeltaY) & MyID > SenderId
<-

    // Infected to the same level as the Leader
    
    .print("I am Bosssssssssssssssssssss.  ", MyID);
    .send(Sender, achieve, com::merging_prepare(MyDeltaX, MyDeltaY,MyID));
    
    .

+!merging_prepare( DeltaX, DeltaY,SenderId)[source(Sender)]
: team::members(Agt,MyID,AllMembers,MyDeltaX,MyDeltaY) & MyID == SenderId
<-
    .print("We are the same. Do nothing  ", MyID);
    .
// Things Database is empty
+!merging_map( DeltaX, DeltaY)
: not stock::agt_Map_Dis(Agt, Step, DisList) & not stock::agt_Map_Obs(Agt, Step, ObsList) & not stock::agt_Map_Goa(Agt, Step, GoaList)
<-
    .print(" Merging Map fail : No data base for all database");
    .

/* +!update_list([], _, _, []).
+!update_list([[X, Y] | Rest], DeltaX, DeltaY, [[NX, NY] | NewRest])
: true
<-
    NX = X + DeltaX;
    NY = Y + DeltaY;
    !update_list(Rest, DeltaX, DeltaY, NewRest);
    . */


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

