gotYou(SLocalX,SLocalY,MLocalX,MLocalX) :- 
(SLocalX == MLocalX | SLocalX == (-MLocalX)) & (SLocalY == MLocalY | SLocalY == (-MLocalY)). 


+!delta(Learder,Local,Teammate,Delta)
<-
    New = (Learder + Local) - Teammate;
    Delta = New - Teammate;
    .
//+stock::myent(Me,S,X,Y,Detail);
+encounter_queue(Step,SenderId,SenderX,SenderY,SLocalX,SLocalY)[source(Sender)]
: stock::myent(_,S,_,_,ET) & team::members(Agt,MyID,NameT,_) & ET == NameT
<-
    .my_name(Me);
    ?stock::myent(Me,SEnt,MLocalX,MLocalY,_);
    ?stock::agt_Pos(Me,SPos,MyPosX,MyPosY);

    if (gotYou(SLocalX,SLocalY,MLocalX,MLocalY))
    {
        if ( MyID > SenderId )
        {
            ?team::sendTo(Sendto);
            .union([Sender], Sendto, NewSendto);
            -team::sendTo(Sendto);
            +team::sendTo(NewSendto);
            !delta(MyPosX,MLocalX,Senderx,DeltaX);
            !delta(MyPosY,MLocalY,SenderY,DeltaY);
            +team::posOffset(Sender,DeltaX,DeltaY);
        }
        elif (SenderId > MyID)
        {
            ?team::receiveFrom(ReceiveFrom);
            .union([Sender], ReceiveFrom , NewReceiveFrom);
            -team::receiveFrom(ReceiveFrom);
            +team::receiveFrom(NewReceiveFrom);
            !delta(Senderx,SLocalX,MyPosX,DeltaX);
            !delta(SenderY,SLocalY,MyPosY,DeltaY);
            +team::posOffset(Sender,DeltaX,DeltaY);
        }
    }



    
    encounter_queue(Step,SenderX,SenderY,LocalX,LocalY)[source(Sender)];
    .

