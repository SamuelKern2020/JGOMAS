/////////////////////////////////
//  Planes formacion
/////////////////////////////////

+!ordenar_bandera(X,Y,Z,MedicTroop) <-
	.my_team(MedicTroop,Medics);
	.my_name(ME);
	.nth(0,Medics,Medic1);
	.nth(1,Medics,Medic2);
	.nth(2,Medics,Medic3);
	.nth(3,Medics,Medic4);
	.nth(4,Medics,Medic5);
	.nth(5,Medics,Medic6);
	.nth(6,Medics,Medic7);
	.concat("por_bandera(",X+4,",",0,",",Z+4,")",GotoObjective1);
	.send_msg_with_conversation_id(Medic1,tell,GotoObjective1,"INT");
	.concat("por_bandera(",X,",",0,",",Z+4,")",GotoObjective2);
	.send_msg_with_conversation_id(Medic2,tell,GotoObjective2,"INT");
	.concat("por_bandera(",X-4,",",0,",",Z+4,")",GotoObjective3);
	.send_msg_with_conversation_id(Medic3,tell,GotoObjective3,"INT");
	.concat("por_bandera(",X-4,",",0,",",Z,")",GotoObjective4);
	.send_msg_with_conversation_id(Medic4,tell,GotoObjective4,"INT");
	.concat("por_bandera(",X+4,",",0,",",Z,")",GotoObjective5);
	.send_msg_with_conversation_id(Medic5,tell,GotoObjective5,"INT");
	.concat("por_bandera(",X-4,",",0,",",Z-4,")",GotoObjective6);
	.send_msg_with_conversation_id(Medic6,tell,GotoObjective6,"INT");
	.concat("por_bandera(",X+4,",",0,",",Z-4,")",GotoObjective7);
	.send_msg_with_conversation_id(Medic7,tell,GotoObjective7,"INT");
	!add_task(task(3000,"TASK_GOTO_POSITION_2",ME,pos(X,Y,Z),"")).
	
+!iniciar_formacion(MedicTroop) <- 
	?my_position(X,Y,Z);
	.my_team(MedicTroop,Medics);
	.nth(0,Medics,Medic1);
	.nth(1,Medics,Medic2);
	.nth(2,Medics,Medic3);
	.nth(3,Medics,Medic4);
	.nth(4,Medics,Medic5);
	.nth(5,Medics,Medic6);
	.nth(6,Medics,Medic7);
	.concat("formar(",X+4,",",Y,",",Z+4,")",GotoMedic1);
	.concat("formar(",X,",",Y,",",Z+4,")",GotoMedic2);
	.concat("formar(",X-4,",",Y,",",Z+4,")",GotoMedic3);
	.concat("formar(",X-4,",",Y,",",Z,")",GotoMedic4);
	.concat("formar(",X+4,",",Y,",",Z,")",GotoMedic5);
	.concat("formar(",X-4,",",Y,",",Z-4,")",GotoMedic6);
	.concat("formar(",X+4,",",Y,",",Z-4,")",GotoMedic7);
	.send_msg_with_conversation_id(Medic1,tell,GotoMedic1,"INT");
	.send_msg_with_conversation_id(Medic2,tell,GotoMedic2,"INT");
	.send_msg_with_conversation_id(Medic3,tell,GotoMedic3,"INT");
	.send_msg_with_conversation_id(Medic4,tell,GotoMedic4,"INT");
	.send_msg_with_conversation_id(Medic5,tell,GotoMedic5,"INT");
	.send_msg_with_conversation_id(Medic6,tell,GotoMedic6,"INT");
	.send_msg_with_conversation_id(Medic7,tell,GotoMedic7,"INT");
	.println("Tropa formada").


+formado(X)[source(A)] <-
    ?formed(Formados);
    -+formed(Formados+1);
    -formado(_).
    
+formar(X,Y,Z)[source(A)] <- 
	//.println("RECIBIDO MENSAJE DE FORMAR DE ",A);
	//!safe_pos(X,Y,Z);
	//?safe_pos(XSafe,YSafe,ZSafe);
	-formar(_,_,_);
	.println("Me han mandado formar");
    !add_task(task(3500,"TASK_GOTO_POSITION_1",A,pos(X,Y,Z),""));
    -+state(standing).
    

+por_bandera(X,Y,Z)[source(A)] <- 
	//.println("RECIBIDO MENSAJE DE IR A POR BANDERA DE ",A);
	//!safe_pos(X,Y,Z);
	//?safe_pos(XSafe,YSafe,ZSafe);
	-por_bandera(_,_,_);
    !add_task(task(3000,"TASK_GOTO_POSITION_2",A,pos(X,Y,Z),""));
	-+state(standing).

+retornar_base(true)[source(A)] <-
    -retornar_base(_);
    ?pos_original(XOriginal,YOriginal,ZOriginal);
    !add_task(task(3000,"TASK_GOTO_POSITION_3",A,pos(XOriginal,YOriginal,ZOriginal),""));
    -+state(standing).
    
+soltar_medicinas(true)[source(A)] <-
	-soltar_medicinas(_);
	?my_position(XPosition,YPosition,ZPosition);
	.my_name(ME);
	.concat("cfm(",XPosition, ", ", YPosition, ", ", ZPosition, ", ", 20, ")", Content2);
	.send_msg_with_conversation_id(ME, tell, Content2, "CFM").
