/////////////////////////////////
//  Planes Retirada
/////////////////////////////////

+tenemos_bandera(true)[source(A)] <-
	.println(A," ha cogido la bandera, esperando a que nos adelante para rodearlo...");
	-+tasks([]);
	Wait = math.random(8500);
	// Esperar cada uno un numero aleatorio (no lo hace) // 
	.wait(math.floor(Wait)).
	
