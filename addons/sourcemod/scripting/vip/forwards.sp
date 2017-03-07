
void CreateForwards()
{
	// Global Forwards
	g_hGlobalForward_OnVIPLoaded						= CreateGlobalForward("VIP_OnVIPLoaded", ET_Ignore);
	g_hGlobalForward_OnClientLoaded					= CreateGlobalForward("VIP_OnClientLoaded", ET_Ignore, Param_Cell, Param_Cell);
	g_hGlobalForward_OnVIPClientLoaded				= CreateGlobalForward("VIP_OnVIPClientLoaded", ET_Ignore, Param_Cell);
	g_hGlobalForward_OnVIPClientRemoved				= CreateGlobalForward("VIP_OnVIPClientRemoved", ET_Ignore, Param_Cell, Param_String);
	g_hGlobalForward_OnPlayerSpawn						= CreateGlobalForward("VIP_OnPlayerSpawn", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);

	// Private Forwards
	g_hPrivateForward_OnPlayerSpawn					= CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
//	g_hPrivateForward_OnClientVIPMenuCreated			= CreateForward(ET_Ignore, Param_Cell, Param_CellByRef);
}

// Global Forwards
void CreateForward_OnVIPLoaded()
{
	/*
	decl Handle:hPlugin, Handle:hMyHandle, Handle:hIter, Function:func;

	hMyHandle = GetMyHandle();
	hIter = GetPluginIterator();

	while (MorePlugins(hIter))
	{
		hPlugin = ReadPlugin(hIter);
		
		if (hPlugin != hMyHandle && GetPluginStatus(hPlugin) == Plugin_Running)
		{
			func = GetFunctionByName(hPlugin, "VIP_OnVIPLoaded");

			if (func != INVALID_FUNCTION)
			{
				Call_StartFunction(hPlugin, func);
				Call_Finish();
			}
		}
	}
	
	CloseHandle(hIter);
	*/

	Call_StartForward(g_hGlobalForward_OnVIPLoaded);
	Call_Finish();
}

void CreateForward_OnClientLoaded(int iClient)
{
	Call_StartForward(g_hGlobalForward_OnClientLoaded);
	Call_PushCell(iClient);
	Call_PushCell(g_iClientInfo[iClient] & IS_VIP);
	Call_Finish();
}

void CreateForward_OnVIPClientLoaded(int iClient)
{
	Call_StartForward(g_hGlobalForward_OnVIPClientLoaded);
	Call_PushCell(iClient);
	Call_Finish();
}

void CreateForward_OnVIPClientRemoved(int iClient, const char[] sReason)
{
	Call_StartForward(g_hGlobalForward_OnVIPClientRemoved);
	Call_PushCell(iClient);
	Call_PushString(sReason);
	Call_Finish();
}

// Private Forwards
/*
void CreateForward_OnClientVIPMenuCreated(int iClient, Handle &hMenu)
{
	Call_StartForward(g_hPrivateForward_OnClientVIPMenuCreated);
	Call_PushCell(iClient);
	Call_PushCellRef(hMenu);
	Call_Finish();
}
*/
void CreateForward_OnPlayerSpawn(int iClient, int iTeam)
{
	Call_StartForward(g_hGlobalForward_OnPlayerSpawn);
	Call_PushCell(iClient);
	Call_PushCell(iTeam);
	Call_PushCell(g_iClientInfo[iClient] & IS_VIP);
	Call_Finish();

	Call_StartForward(g_hPrivateForward_OnPlayerSpawn);
	Call_PushCell(iClient);
	Call_PushCell(iTeam);
	Call_PushCell(g_iClientInfo[iClient] & IS_VIP);
	Call_Finish();
}

