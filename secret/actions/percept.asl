

// Map Edg
+!location_edg(Agt,Direction,EdgX,EdgY )
: Direction == n & not stock::agt_Map_Edg_Y_N(_) & not stock::agt_Map_Edg_X_W(_)
<-
    +stock::agt_Map_Edg_Y_N(EdgY);
    +stock::agt_Map_Edg_X_W(EdgY);
    -stock::findEdge_NW;
    .

+!location_edg(Agt,Direction,EdgX,EdgY )
: Direction == w & not stock::agt_Map_Edg_Y_N(_) & not stock::agt_Map_Edg_X_W(_)
<-
    +stock::agt_Map_Edg_X_W(EdgX);
    +stock::agt_Map_Edg_Y_N(EdgX);
    -stock::findEdge_NW;
    .

+!location_edg(Agt,Direction,EdgX,EdgY )
: Direction == e  & not stock::agt_Map_Edg_X_E(_) & not stock::agt_Map_Edg_Y_S(_)
<-
    +stock::agt_Map_Edg_X_E(EdgX);
    +stock::agt_Map_Edg_Y_S(EdgX);
    -stock::findEdge_ES;
    .

+!location_edg(Agt,Direction,EdgX,EdgY )
: Direction == s & not stock::agt_Map_Edg_Y_S(_) & not stock::agt_Map_Edg_X_E(_)
<-
    +stock::agt_Map_Edg_Y_S(EdgY);
    +stock::agt_Map_Edg_X_E(EdgY);
    -stock::findEdge_ES;
    .

+!location_edg(Agt,Direction,EdgX,EdgY ) : true .