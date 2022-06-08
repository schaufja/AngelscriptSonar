/*
* Sprite Sonar
*
* Created by The Seventh
*
* Meant for use in a trigger_script set to think mode every 3 seconds or so
* This trigger_script is placed above a flat surface to represent the radar screen
* (Recommended 1-2 map units above surface)
* 
* trigger_script kvs:
* $s_sourceName - Name of entity which projects sonar (e.g. func_vehicle_custom)
* $f_sonarRadius - Radius of sonar projection, in map units, around the vehicle
* $f_displayRadius - Radius around trigger_script entity to project points, also in map units
* $s_triggerPing -  Name of entities(e.g. ambient_generic for sound) to play for initial ping
* $s_triggerPong - Name of entities(e.g. ambient_generic for sound) to play for pong responses
*
*/

namespace Sonar 
{
	void Init()
	{
		Precache();
		//g_Game.AlertMessage( at_console, "Inside Sonar::Init()\n" );
	}
	
	void SonarPing(CBaseEntity@ pTriggerThink)
	{
		bool DEBUG_MODE = false; //enable console logs
		
		if(DEBUG_MODE)
			g_Game.AlertMessage( at_console, "Inside Sonar::SonarPing()\n" );
		
		float CONST_PI = 3.141592f; 
		float CONST_RADIAN = 180/CONST_PI;
		
		array<CBaseEntity@> aSonarTargets(32); //Only render 32 points per pulse, we shouldn't ever need that many
		
		CustomKeyvalues@ kvTriggerScript = pTriggerThink.GetCustomKeyvalues();
		const string sSourceName = kvTriggerScript.HasKeyvalue( "$s_sourceName" ) ? kvTriggerScript.GetKeyvalue( "$s_sourceName" ).GetString() : "sub_vehicle";
    const float flSonarRadius = kvTriggerScript.HasKeyvalue( "$f_sonarRadius" ) ? kvTriggerScript.GetKeyvalue( "$f_sonarRadius" ).GetFloat() : 240.0f;
		const float flDisplayRadius = kvTriggerScript.HasKeyvalue( "$f_displayRadius" ) ? kvTriggerScript.GetKeyvalue( "$f_displayRadius" ).GetFloat() : 16.0f;
		const string sTriggerPing = kvTriggerScript.HasKeyvalue( "$s_triggerPing" ) ? kvTriggerScript.GetKeyvalue( "$s_triggerPing" ).GetString() : "sonar_ping";
		const string sTriggerPong = kvTriggerScript.HasKeyvalue( "$s_triggerPong" ) ? kvTriggerScript.GetKeyvalue( "$s_triggerPong" ).GetString() : "sonar_pong";
		
		float flScale = flDisplayRadius / flSonarRadius; //our factor to scale the points, based on the display size
		if(DEBUG_MODE)
			g_Game.AlertMessage( at_console, "vehicleName: %1\n sonarRadius: %2\n displayRadius: %3\n scale: %4\n", sSourceName, flSonarRadius, flDisplayRadius, flScale );

		CBaseEntity@ pSonarSource = g_EntityFuncs.FindEntityByTargetname(null, sSourceName); //func_vehicle_custom
		Vector vecSourceOrigin = pSonarSource.pev.origin;
		Vector vecSourceAngles = pSonarSource.pev.angles;
		
		//func_vehicle_custom starts facing west so we add 180 degrees to compensate for most entities starting facing east.
		//Then we get the modulo of a circle in case our angle is ever greater than 360. 
		//Finally, we divide by radians to get the radian rotation we need to apply later
		float vecSourceRotation = (vecSourceAngles.y + 180) % 360 / CONST_RADIAN; 
		
		if(DEBUG_MODE)
			g_Game.AlertMessage( at_console, "Source vector: (%1, %2, %3)\n Source angle: (%4, %5, %6)\n", vecSourceOrigin.x, vecSourceOrigin.y, vecSourceOrigin.z, vecSourceAngles.x, vecSourceAngles.y, vecSourceAngles.z);
		
		//Get monsters to track and get how many
		uint iTargetCount = g_EntityFuncs.MonstersInSphere(aSonarTargets, vecSourceOrigin, flSonarRadius);
		
		if(DEBUG_MODE)
			g_Game.AlertMessage( at_console, "Number of Sonar targets: %1\n", iTargetCount );
		
		g_EntityFuncs.FireTargets( sTriggerPing, null, null, USE_ON, 0.0f, 0.0f );
		
		for ( uint i = 0; i < aSonarTargets.length(); i++ ) //Loop through targets array
		{
			CBaseEntity@ aSonarTarget = aSonarTargets[i];
			
			if (aSonarTarget is null) //check for null and skip
				continue;
				
			Vector vecTargetOrigin = aSonarTarget.pev.origin;
			
			if(DEBUG_MODE)
				g_Game.AlertMessage( at_console, "Target vector: (%1, %2, %3)\n", vecTargetOrigin.x, vecTargetOrigin.y, vecTargetOrigin.z);

			Vector vecOffset = vecSourceOrigin.opSub(vecTargetOrigin); //subtract target unit vector from source to get offset
			vecOffset = vecOffset.opMul(flScale); //
			vecOffset = RotateVector(vecOffset, vecSourceRotation);
			if(DEBUG_MODE)
				g_Game.AlertMessage( at_console, "Offset vector: (%1, %2, %3)\n", vecOffset.x, vecOffset.y, vecOffset.z);
			
			Vector vecSpawnPoint = pTriggerThink.pev.origin.opAdd(vecOffset); //add the offset to the Sonar center
				
			if(DEBUG_MODE)
				g_Game.AlertMessage( at_console, "Spawning point at: (%1, %2, %3) with distance of %4 units\n", vecSpawnPoint.x, vecSpawnPoint.y, vecSpawnPoint.z, vecOffset.Length());
			
			float flDelay = vecOffset.Length() / 12;
			
			g_Scheduler.SetTimeout( "CreatePing", flDelay, vecSpawnPoint, sTriggerPong);
		}
	}
	
	void CreatePing(Vector spawnVec, string triggerPong)
	{
		g_EntityFuncs.FireTargets( triggerPong, null, null, USE_ON, 0.0f, 0.0f ); //Play pong effects
		
		NetworkMessage netMsg( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null );
		netMsg.WriteByte( TE_GLOWSPRITE );
		netMsg.WriteCoord( spawnVec.x );
		netMsg.WriteCoord( spawnVec.y );
		netMsg.WriteCoord( spawnVec.z );
		netMsg.WriteShort(g_EngineFuncs.ModelIndex("sprites/glow01.spr"));
		netMsg.WriteByte(5); //life
		netMsg.WriteByte(1); //scale
		netMsg.WriteByte(255); //renderamt
		netMsg.End();
	}
	
	void Precache()
	{
		g_Game.PrecacheModel("sprites/glow01.spr");
	}
	
	Vector RotateVector(Vector vecInput, float flRotationInput)
	{
		Vector vecNew;
		vecNew.x = vecInput.x * cos(flRotationInput) + vecInput.y * sin(flRotationInput);
		vecNew.y = vecInput.y * cos(flRotationInput) - vecInput.x * sin(flRotationInput);
		return vecNew;
	}
	
	bool lessForDistance(const float &in a, const float &in b)
	{
		return a < b;
	}

} // end namespace (~_~ )