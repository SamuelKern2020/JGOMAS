/////////////////////////////////
//  Planes formacion
/////////////////////////////////

+!iniciar_formacion(MedicTroop,BackupTroop) <- 
	?my_position(X,Y,Z);
	.my_team(BackupTroop,BackupTeam);
	.my_team(MedicTroop,Medic1);
	.concat("formar(",X,",",Y,",",Z+10,")",GotoMedic1);
	.send_msg_with_conversation_id(Medic1,tell,GotoMedic1,"INT");
	.nth(0,BackupTeam,Backup1);
	.nth(1,BackupTeam,Backup2);
	.concat("formar(",X-15,",",Y,",",Z+15,")",GotoBackup1);
	.concat("formar(",X+15,",",Y,",",Z+15,")",GotoBackup2);
	.send_msg_with_conversation_id(Backup1,tell,GotoBackup1,"INT");
	.send_msg_with_conversation_id(Backup2,tell,GotoBackup2,"INT");
	.println("Tropa formada").


+formar(X,Y,Z)[source(A)] <- 
	.println("RECIBIDO MENSAJE DE ",A);
	!safe_pos(X,Y,Z);
	?safe_pos(XSafe,YSafe,ZSafe);
    !add_task(task(3000,"TASK_GOTO_POSITION_1",A,pos(XSafe,YSafe,ZSafe),""));
    -+state(standing);
    -goto(_,_,_).
