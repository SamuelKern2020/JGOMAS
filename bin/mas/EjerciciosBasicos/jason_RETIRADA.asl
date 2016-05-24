/////////////////////////////////
//  Planes Retirada
/////////////////////////////////

+objectivePackTaken(on) <- 
	// Decir a la ¿mitad/todos/alguno? de los agentes medicos que lancen paquetes de medicinas //
	// Una vez lanzados los paquetes de medicinas, decirles que vuelvan a la base //
	-+tasks([]);
	?my_health(Hr);
	.my_name(ME);
	-+tenemos_bandera(true);
	.my_team("medico_ALLIED",MedicosRasos);
	.my_team("capitan_ALLIED",Capitan);
	.concat(MedicosRasos,Capitan,Medics);
	?my_position(X,Y,Z);
	?pos_original(XOriginal,YOriginal,ZOriginal);
    // Decirles a todos que ya tenemos la bandera, para gestionar el soltado de paquetes de medicina a la vuelta a la base //
    .concat("tenemos_bandera(true)",TenemosBandera);
    .send_msg_with_conversation_id(Medics,tell,TenemosBandera,"INT");
    // Decirles que vuelvan a la base //
    .concat("retornar_base(true)",GotoBase);
    .send_msg_with_conversation_id(Medics,tell,GotoBase,"INT");
    
    // ARREGLAR EL SOLTADO DE PAQUETES DE MEDICINA //
    // Decirles que suelten todos paquetes de medicinas ¿DONDE?//
    .concat("soltar_medicinas(true)",Content2);
    .send_msg_with_conversation_id(Medics, tell, Content2, "INT").
	//.concat("cfm(",X-10, ", ", Y, ", ", Z-10, ", ", 20, ")", Content2);
    //.send_msg_with_conversation_id(Medics, tell, Content2, "CFM");
    

+tenemos_bandera(true)[source(A)] <-
	.println(A," ha cogido la bandera, esperando a que nos adelante para rodearlo...");
	-+tasks([]);
	.wait(8500).
