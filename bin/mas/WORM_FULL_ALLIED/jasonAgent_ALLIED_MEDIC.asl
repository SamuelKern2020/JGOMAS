debug(3).

// Name of the manager
manager("Manager").

// Team of troop.
team("ALLIED").
// Type of troop.
type("CLASS_MEDIC").




{ include("jgomas.asl") }
{ include("WORM_FULL_ALLIED/jason_FORMACION.asl") }
{ include("WORM_FULL_ALLIED/jason_RETIRADA.asl") }

// Plans


/*******************************
*
* Actions definitions
*
*******************************/

/////////////////////////////////
//  GET AGENT TO AIM 
/////////////////////////////////  
/**
 * Calculates if there is an enemy at sight.
 *
 * This plan scans the list <tt> m_FOVObjects</tt> (objects in the Field
 * Of View of the agent) looking for an enemy. If an enemy agent is found, a
 * value of aimed("true") is returned. Note that there is no criterion (proximity, etc.) for the
 * enemy found. Otherwise, the return value is aimed("false")
 *
 * <em> It's very useful to overload this plan. </em>
 * 
 */
+!get_agent_to_aim
<-  ?debug(Mode); if (Mode<=2) { .println("Looking for agents to aim."); }
?fovObjects(FOVObjects);
.length(FOVObjects, Length);

?debug(Mode); if (Mode<=1) { .println("El numero de objetos es:", Length); }
if (Length > 0) {
    +bucle(0);
    
    -+aimed("false");
    AxisAimed = 0;
    -+fuego_amigo(false);
    while (aimed("false") & bucle(X) & (X < Length)) {
        
        //.println("En el bucle, y X vale:", X);
        
        .nth(X, FOVObjects, Object);
        // Object structure
        // [#, TEAM, TYPE, ANGLE, DISTANCE, HEALTH, POSITION ]
        .nth(2, Object, Type);
        
        ?debug(Mode); if (Mode<=2) { .println("Objeto Analizado: ", Object); }
        
        if (Type > 1000) {
            ?debug(Mode); if (Mode<=2) { .println("I found some object."); }
        } else {
            // Object may be an enemy
            .nth(1, Object, Team);
            ?my_formattedTeam(MyTeam);
            // En cuanto vea a uno de mi equipo ya no busco mas, no apuntar //
            //if (Team == 100) { 
			//	-+fuego_amigo(true);
			//}
            if (Team == 200) {  // Only if I'm ALLIED				
                ?debug(Mode); if (Mode<=2) { .println("Aiming an enemy. . .", MyTeam, " ", .number(MyTeam) , " ", Team, " ", .number(Team)); }
                //AxisAimed = Object;
                // APUNTAR PARA DISPARAR SI Y SOLO SI NO VEO AGENTES MIOS //
                //+aimed_agent(Object);
                //-+aimed("true");               
            }            
        }        
        -+bucle(X+1);       
    }
    //?fuego_amigo(FuegoAmigo);
    //if(FuegoAmigo==false & not(AxisAimed==0)){
	//	+aimed_agent(AxisAimed);
	//	-+aimed("true");
	//}  
}
-bucle(_).

/////////////////////////////////
//  LOOK RESPONSE
/////////////////////////////////
+look_response(FOVObjects)[source(M)]
    <-  //-waiting_look_response;
        .length(FOVObjects, Length);
        if (Length > 0) {
            ///?debug(Mode); if (Mode<=1) { .println("HAY ", Length, " OBJETOS A MI ALREDEDOR:\n", FOVObjects); }
        };    
        -look_response(_)[source(M)];
        -+fovObjects(FOVObjects);
        //.//;
        !look.
      
        
/////////////////////////////////
//  PERFORM ACTIONS
/////////////////////////////////
/**
* Action to do when agent has an enemy at sight.
* 
* This plan is called when agent has looked and has found an enemy,
* calculating (in agreement to the enemy position) the new direction where
* is aiming.
*
*  It's very useful to overload this plan.
* 
*/
+!perform_aim_action
    <-  // Aimed agents have the following format:
        // [#, TEAM, TYPE, ANGLE, DISTANCE, HEALTH, POSITION ]
        ?aimed_agent(AimedAgent);
        ?debug(Mode); if (Mode<=1) { .println("AimedAgent ", AimedAgent); }
        .nth(1, AimedAgent, AimedAgentTeam);
        ?debug(Mode); if (Mode<=2) { .println("BAJO EL PUNTO DE MIRA TENGO A ALGUIEN DEL EQUIPO ", AimedAgentTeam);             }
        ?my_formattedTeam(MyTeam);


        if (AimedAgentTeam == 200) {
    
                .nth(6, AimedAgent, NewDestination);
                ?debug(Mode); if (Mode<=1) { .println("NUEVO DESTINO DEBERIA SER: ", NewDestination); }
          
            }
.
/**
* Action to do when the agent is looking at.
*
* This plan is called just after Look method has ended.
* 
* <em> It's very useful to overload this plan. </em>
* 
*/
+!perform_look_action .
/**
* Action to do if this agent cannot shoot.
* 
* This plan is called when the agent try to shoot, but has no ammo. The
* agent will spit enemies out. :-)
* 
* <em> It's very useful to overload this plan. </em>
* 
*/  
+!perform_no_ammo_action . 
   /// <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR PERFORM_NO_AMMO_ACTION GOES HERE.") }.
    
/**
     * Action to do when an agent is being shot.
     * 
     * This plan is called every time this agent receives a messager from
     * agent Manager informing it is being shot.
     * 
     * <em> It's very useful to overload this plan. </em>
     * 
     */
+!perform_injury_action .
    ///<- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR PERFORM_INJURY_ACTION GOES HERE.") }. 
        

/////////////////////////////////
//  SETUP PRIORITIES
/////////////////////////////////
/**  You can change initial priorities if you want to change the behaviour of each agent  **/+!setup_priorities
    <-  +task_priority("TASK_NONE",0);
        +task_priority("TASK_GIVE_MEDICPAKS", 5000);
        +task_priority("TASK_GIVE_AMMOPAKS", 0);
        +task_priority("TASK_GIVE_BACKUP", 0);
        +task_priority("TASK_GET_OBJECTIVE",1000);
        +task_priority("TASK_ATTACK", 1000);
        +task_priority("TASK_RUN_AWAY", 1500);
        +task_priority("TASK_GOTO_POSITION", 750);
        +task_priority("TASK_PATROLLING", 500);
        +task_priority("TASK_WALKING_PATH", 1750).   



/////////////////////////////////
//  UPDATE TARGETS
/////////////////////////////////
/**
 * Action to do when an agent is thinking about what to do.
 *
 * This plan is called at the beginning of the state "standing"
 * The user can add or eliminate targets adding or removing tasks or changing priorities
 *
 * <em> It's very useful to overload this plan. </em>
 *
 */
+!update_targets
	<-	?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR UPDATE_TARGETS GOES HERE.") };
		?tasks(TASKS);
		?form(Formed);
		?objectivePackTaken(TengoBandera);
		.length(TASKS,LengthTasks);
		if(LengthTasks==0 & Formed==false){
			.my_team("capitan_ALLIED",Captain);
			.println("Formado estoy");
			-+form(true);
			Formado = "formado(true)";
			.send_msg_with_conversation_id(Captain,tell,Formado,"INT");
			?my_position(XOriginal,YOriginal,ZOriginal);
			+pos_original(XOriginal,YOriginal,ZOriginal);
		}
		else{
			// Cuando el agente haya cogido la bandera y tenga la tarea de volver a la base... //
			if(LengthTasks==1 & TengoBandera==on){
				.println("Tareas cuando estoy volviendo a la base y llevo la bandera: " , TASKS);
				.nth(0,TASKS,TaskReturnBase);
				-+TaskReturnBase;
				?task(_,_,_,PosReturnBase,_);
				.println(PosReturnBase);
				-+PosReturnBase;
				?pos(XReturnBase,YReturnBase,ZReturnBase);
				.my_team("medico_ALLIED",MedicosRasos);
				.my_team("capitan_ALLIED",Capitan);
				.concat(MedicosRasos,Capitan,Medics);
				// Decirles a todos que ya tenemos la bandera, para gestionar el soltado de paquetes de medicina en la vuelta a la base //
				.concat("tenemos_bandera(true)",TenemosBandera);
				.send_msg_with_conversation_id(Medics,tell,TenemosBandera,"INT");
				// Enviar mensaje de retorno a la base //
				.concat("retornar_base(",XReturnBase,",",YReturnBase,",",ZReturnBase,")",GotoBase);
				.send_msg_with_conversation_id(Medics,tell,GotoBase,"INT");
				// Decirles que suelten todos paquetes de medicinas //
				.concat("soltar_medicinas(true)",Content2);
				.send_msg_with_conversation_id(Medics, tell, Content2, "INT");	
			}
		}.
	
	
/////////////////////////////////
//  CHECK MEDIC ACTION (ONLY MEDICS)
/////////////////////////////////
/**
 * Action to do when a medic agent is thinking about what to do if other agent needs help.
 *
 * By default always go to help
 *
 * <em> It's very useful to overload this plan. </em>
 *
 */
 +!checkMedicAction
     <-  -+medicAction(on).
      // go to help
      
      
/////////////////////////////////
//  CHECK FIELDOPS ACTION (ONLY FIELDOPS)
/////////////////////////////////
/**
 * Action to do when a fieldops agent is thinking about what to do if other agent needs help.
 *
 * By default always go to help
 *
 * <em> It's very useful to overload this plan. </em>
 *
 */
 +!checkAmmoAction
     <-  -+fieldopsAction(on).
      //  go to help



/////////////////////////////////
//  PERFORM_TRESHOLD_ACTION
/////////////////////////////////
/**
 * Action to do when an agent has a problem with its ammo or health.
 *
 * By default always calls for help
 *
 * <em> It's very useful to overload this plan. </em>
 *
 */
+!performThresholdAction
       <-
       
       ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR PERFORM_TRESHOLD_ACTION GOES HERE.") }
       
       ?my_ammo_threshold(At);
       ?my_ammo(Ar);
       
       if (Ar <= At) { 
          ?my_position(X, Y, Z);
          
         .my_team("fieldops_ALLIED", E1);
         //.println("Mi equipo intendencia: ", E1 );
         .concat("cfa(",X, ", ", Y, ", ", Z, ", ", Ar, ")", Content1);
         .send_msg_with_conversation_id(E1, tell, Content1, "CFA");
       
       
       }
       
       // Modificado para pedir medicinas al agente mas cercano //
       ?my_health_threshold(Ht);
       ?my_health(Hr);     
       if (Hr <= Ht) { 
         ?my_position(X, Y, Z);         
         .my_team("ALLIED", E2); // todos son medicos, coger el mas cercano //
         !nearest(E2);
         ?nearest(NearestMedic,_,_);
         // Pedir medicinas al agente mas cercano //
         .concat("cfm(",X, ", ", Y, ", ", Z, ", ", Hr, ")", Content2);
         .send_msg_with_conversation_id(NearestMedic, tell, Content2, "CFM");
       }.
/////////////////////////////////
//  ANSWER_ACTION_CFM_OR_CFA
/////////////////////////////////


    
+cfm_agree[source(M)]
   <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR cfm_agree GOES HERE.")};
	  .println("AGREE");
      -cfm_agree.  

+cfa_agree[source(M)]
   <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR cfa_agree GOES HERE.")};
      -cfa_agree.  

+cfm_refuse[source(M)]
   <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR cfm_refuse GOES HERE.")};
	  .println("DISAGREE");
      -cfm_refuse.  

+cfa_refuse[source(M)]
   <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR cfa_refuse GOES HERE.")};
      -cfa_refuse.  


/////////////////////////////////
//  Initialize variables
/////////////////////////////////

+!init
   <- 
   ?debug(Mode); if (Mode<=1) { .println("Codigo de inicializacion")};
   +form(false);
   -+objectivePackTaken(off);
   .register("JGOMAS","medico_ALLIED");
   +tenemos_bandera(false);
   +rango(medico);  
   ?objective(ObjectiveX,_,ObjectiveZ);
   +bandera_inicial(ObjectiveX,0,ObjectiveZ);
   -+tasks([]).
