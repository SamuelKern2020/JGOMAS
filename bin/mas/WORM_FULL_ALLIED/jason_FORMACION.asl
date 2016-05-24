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
	.concat("por_bandera(",X,",",0,",",Z,")",GotoObjective);
	.send_msg_with_conversation_id(Medic1,tell,GotoObjective,"INT");
	.send_msg_with_conversation_id(Medic2,tell,GotoObjective,"INT");
	.send_msg_with_conversation_id(Medic3,tell,GotoObjective,"INT");
	.send_msg_with_conversation_id(Medic4,tell,GotoObjective,"INT");
	.send_msg_with_conversation_id(Medic5,tell,GotoObjective,"INT");
	.send_msg_with_conversation_id(Medic6,tell,GotoObjective,"INT");
	.send_msg_with_conversation_id(Medic7,tell,GotoObjective,"INT");
	!add_task(task(1500,"TASK_GOTO_POSITION_2",ME,pos(X,Y,Z),"")).
	
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
	.concat("formar(",X,",",Y,",",Z,")",GotoMedic);
	.send_msg_with_conversation_id(Medic1,tell,GotoMedic,"INT");
	.send_msg_with_conversation_id(Medic2,tell,GotoMedic,"INT");
	.send_msg_with_conversation_id(Medic3,tell,GotoMedic,"INT");
	.send_msg_with_conversation_id(Medic4,tell,GotoMedic,"INT");
	.send_msg_with_conversation_id(Medic5,tell,GotoMedic,"INT");
	.send_msg_with_conversation_id(Medic6,tell,GotoMedic,"INT");
	.send_msg_with_conversation_id(Medic7,tell,GotoMedic,"INT");
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

+retornar_base(X,Y,Z)[source(A)] <-
    -retornar_base(_);
    !add_task(task(3000,"TASK_GOTO_POSITION_3",A,pos(X,Y,Z),""));
    Wait = math.random(8500);
	// Esperar cada uno un numero aleatorio (no lo hace) // 
	.wait(math.floor(Wait)).

+soltar_medicinas(true)[source(A)] <-
	-soltar_medicinas(_);
	?my_position(XPosition,YPosition,ZPosition);
	.my_name(ME);
	.concat("cfm(",XPosition, ", ", YPosition, ", ", ZPosition, ", ", 20, ")", Content2);
	.send_msg_with_conversation_id(ME, tell, Content2, "CFM");
	Wait = math.random(8500);
	// Esperar cada uno un numero aleatorio (no lo hace) // 
	.wait(math.floor(Wait)).
