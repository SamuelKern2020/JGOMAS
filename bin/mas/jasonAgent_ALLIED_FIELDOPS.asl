debug(3).

// Name of the manager
manager("Manager").

// Team of troop.
team("ALLIED").
// Type of troop.
type("CLASS_FIELDOPS").






{ include("jgomas.asl") }




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
 
+!get_agent_to_aim	//prevent friendly-fire in this plan
<-  ?debug(Mode); if (Mode<=2) { .println("Looking for agents to aim."); }
?fovObjects(FOVObjects);
.length(FOVObjects, Length);

?debug(Mode); if (Mode<=1) { .println("The number of objects in this agent's FOV is:", Length); }

if (Length > 0) {
    +bucle(0);	//update the belief "bucle" to 0
    
    -+aimed("false");
    
    while (aimed("false") & bucle(X) & (X < Length)) {
        
        //.println("En el bucle, y X vale:", X);
        
        .nth(X, FOVObjects, Object); //assign Object to be the Xth object in FOVObjects
        // Object structure
        // [#, TEAM, TYPE, ANGLE, DISTANCE, HEALTH, POSITION ]
        .nth(2, Object, Type);	//assign Type to be the value held in index 2 of the array called Object
        
        ?debug(Mode); if (Mode<=2) { .println("Objeto Analizado: ", Object); }
        
        if (Type > 1000) {
            ?debug(Mode); if (Mode<=2) { .println("I found some object."); }
        } else {
            // Object may be an enemy
            .nth(1, Object, Team);
            ?my_formattedTeam(MyTeam);
            
            if (Team == 200) {  // Only if I'm ALLIED
			//Now ensure that there aren't any agents of the same team in front of the enemy
			
			.nth(4, Object, Distance);	//get the distance between the agent and the targeted enemy
			
			+safeToFire("true");
			+innerLoop(0);
			while (safeToFire("true") & innerLoop(Y) & (Y < Length)) {//while safeToFire is still true, iterate using innerLoop through all the objects in FOV (# = Length)
				.nth(Y, FOVObjects, TestObject); //assign Object to be the Yth object in FOVObjects
				.nth(2, TestObject, TestObjectType);
				.nth(1, TestObject, TestObjectTeam);
				.nth(3, TestObject, TestObjectAngle);
				.nth(4, TestObject, TestObjectDistance);
				
				if(TestObjectType < 1000){
					if(TestObjectTeam == 100){	//if the object is an alled agent (on the same team)
						if(TestObjectDistance <= Distance){//if a team mate is closer than the targeted enemy, don't fire
						-+safeToFire("false");
						?debug(Mode); if (Mode<=2) {.println("FRIENDLY FIRE AVOIDED");}
						//have the agent move to a position where it can fire safely 
						
						}
					}
				}
				-+innerLoop(Y+1);
			}
			
			if(safeToFire("true")){
			 ?debug(Mode); if (Mode<=2) { .println("Aiming an enemy. . .", MyTeam, " ", .number(MyTeam) , " ", Team, " ", .number(Team)); }
                +aimed_agent(Object);	
                -+aimed("true");	//in these two beliefs, the agent immediately changes direction, shoots at the agent, and then returns to previous direction 
                
			
			}
			
            }
            
        }
        
        -+bucle(X+1);
        
    }
    
    
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
      
        
//When the agent grabs the flag, the belief objectivePackTaken is updated. When that happens, the agent should send a message to all of its team members and 
//have them execute a new task TASK_GOTO_POSITION where the position is the agent's current position. 
+objectivePackTaken(on)
	<- ?debug(Mode); if (Mode<=3) { .println("THIS MOTHER FUCKIN AGENT HAS THE FUCKING FLAG!!!"); };
		+iHaveTheFlag(true);
		?my_position(X,Y,Z);
		.my_team("ALLIED", E1);
		.concat("goto(",X, ", ", Y, ", ", Z, ")", Content1); .send_msg_with_conversation_id(E1, tell, Content1, "INT");
		.println("I just sent a message to everyone!").
      
+goto(X,Y,Z)[source(A)]
 <-
    .println("Received a message of the type goto from ", A);
 .
 
+protectFlagCarrier(X,Y,Z)[source(A)] //called if the agent has the flag. Sends a message w/ its location so all other agents can come give help. 
 <-
    .println("Received a message of the type protectFlagCarrier from ", A);
	//Add logic that has agent go protect the agent with the flag, who is currently located at X, Y, Z
	!add_task(task(1000,"TASK_GOTO_POSITION", A, pos(X, Y, Z), "")); // (OPTIONAL_PRIORITY, TASK_NAME, AGENT_WHO_TRIGGERED_TASK, POSITION, OPTIONAL_CONTENT)
    -+state(standing);
    -goto(_,_,_) 
	.
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
//launched in each cycle (called by !look)

+!perform_look_action 	
   <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR PERFORM_LOOK_ACTION GOES HERE.") }
   		//Can add functionality here (follow a friend, do something with a medic pac, etc)
		//You can add a new task that is "follow the leader"
		
		if(iHaveTheFlag(true)){//if the current agent has the flag, it will send out a message to all other agents each turn with its location
			.println("I HAVE THE FLAG :) "); 
			?my_position(X,Y,Z);
			.my_team("ALLIED", E1);
			.concat("protectFlagCarrier(",X, ", ", Y, ", ", Z, ")", Content1); .send_msg_with_conversation_id(E1, tell, Content1, "INT");
			.println("I just sent a message to everyone!")
		}
   
   .


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
        +task_priority("TASK_GIVE_MEDICPAKS", 0);
        +task_priority("TASK_GIVE_AMMOPAKS", 2000);
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
	<-	?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR UPDATE_TARGETS GOES HERE.") }.
	
	
	
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
       
       ?my_health_threshold(Ht);
       ?my_health(Hr);
       
       if (Hr <= Ht) { 
          ?my_position(X, Y, Z);
          
         .my_team("medic_ALLIED", E2);
         //.println("Mi equipo medico: ", E2 );
         .concat("cfm(",X, ", ", Y, ", ", Z, ", ", Hr, ")", Content2);
         .send_msg_with_conversation_id(E2, tell, Content2, "CFM");

       }
       .
       
/////////////////////////////////
//  ANSWER_ACTION_CFM_OR_CFA
/////////////////////////////////

    
+cfm_agree[source(M)]
   <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR cfm_agree GOES HERE.")};
      -cfm_agree.  

+cfa_agree[source(M)]
   <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR cfa_agree GOES HERE.")};
      -cfa_agree.  

+cfm_refuse[source(M)]
   <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR cfm_refuse GOES HERE.")};
      -cfm_refuse.  

+cfa_refuse[source(M)]
   <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR cfa_refuse GOES HERE.")};
      -cfa_refuse.  


/////////////////////////////////
//  Initialize variables
/////////////////////////////////

+!init
   <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR init GOES HERE.")}.  

