/////////////////////////////////
//  Planes Retirada
/////////////////////////////////


+tenemos_bandera(X,Y,Z,X1,Y1,Z1)[source(A)] <-
	.println(A," ha cogido la bandera, esperando a que nos adelante para rodearlo...");
	-+tasks([]);
	-+state(standing);
	!add_task(task(3100,"TASK_GOTO_POSITION_4",A,pos(X,Y,Z),""));
	!add_task(task(2000,"TASK_GOTO_POSITION_3",A,pos(X1,Y1,Z1),""));
	-+state(standing);
	Wait = math.random(8500);
	// Esperar cada uno un numero aleatorio (no lo hace) // 
	.wait(math.floor(Wait)).
	

