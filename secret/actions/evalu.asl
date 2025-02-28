+!updataAgentPos(Direction,Agt,X,Y)
: true
<- 
    /* ?stock::agt_Pos(Agt, X, Y);  */
   // .print("[DBG] updataAgentPos"," ", Direction," ",Agt," ", X, " ", Y);
    if ( Direction == n  )
    {    

        NewY = (Y - 1); 
        -stock::agt_Pos(Agt, X, Y);
        +stock::agt_Pos(Agt, X, NewY);
        
    }
    elif  (Direction == s )
    {

        NewY = (Y + 1);     
        -stock::agt_Pos(Agt, X, Y);
        +stock::agt_Pos(Agt, X, NewY);

    }
    elif (Direction == e)
    {

        NewX = (X + 1);    
        -stock::agt_Pos(Agt, X, Y);
        +stock::agt_Pos(Agt, NewX, Y);

    }
    elif ( Direction == w  )
    {
        NewX = (X - 1); 
        
        -stock::agt_Pos(Agt, X, Y);
        +stock::agt_Pos(Agt, NewX, Y);
        
    }
   // ?stock::agt_Pos(Agt, X1, Y1); 
    //.print("[DBG] updataAgentPos new"," ", Direction," ",Agt," ", X1, " ", Y1);
    ?lock::curret_token(XC,pos); 
    ?lock::token(XT);
    if (XT > XC)
    {
        .print("Tocken update", XT ," ", XC);
    }
    
    .



+!updateAgentPos(Direction, Agt, X, Y)
: true
<- 
    

    .print("[INFO] Updated position", Agt, "(", CX, ",", CY, ") -> (", NewX, ",", NewY, ")");
.
