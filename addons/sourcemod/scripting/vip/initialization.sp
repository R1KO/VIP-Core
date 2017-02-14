public OnMapStart()
{
	LoadSounds();
	ReadDownloads();
}

OnReadyToStart()
{
	DebugMessage("OnReadyToStart")
	if (!(GLOBAL_INFO & IS_STARTED))
	{
		GLOBAL_INFO |= IS_STARTED;
		
		CreateForward_OnVIPLoaded();
		
		for (new iClient = 1; iClient <= MaxClients; ++iClient)
		{
			if (IsClientInGame(iClient))
			{
				Clients_CheckVipAccess(iClient, false);
			}
		}
	}
}

ReadConfigs()
{
	DebugMessage("ReadConfigs")

	decl String:sFeatureName[255], Handle:hArray, i, iSize;

	if (g_hSortArray != INVALID_HANDLE)
	{
		CloseHandle(g_hSortArray);
		g_hSortArray = INVALID_HANDLE;
	}

	BuildPath(Path_SM, sFeatureName, sizeof(sFeatureName), "data/vip/cfg/sort_menu.ini");
	hArray = OpenFile(sFeatureName, "r");
	if (hArray != INVALID_HANDLE)
	{
		g_hSortArray = CreateArray(ByteCountToCells(FEATURE_NAME_LENGTH));
		
		while (!IsEndOfFile(hArray) && ReadFileLine(hArray, sFeatureName, FEATURE_NAME_LENGTH))
		{
			DebugMessage("ReadFileLine: %s", sFeatureName)
			TrimString(sFeatureName);
			if (sFeatureName[0])
			{
				PushArrayString(g_hSortArray, sFeatureName);
				DebugMessage("PushArrayString: %s (%i)", sFeatureName, FindStringInArray(g_hSortArray, sFeatureName))
			}
		}

		CloseHandle(hArray);
		
		DebugMessage("GetArraySize: %i", GetArraySize(g_hSortArray))
		
		if(GetArraySize(g_hSortArray) == 0)
		{
			CloseHandle(g_hSortArray);
			g_hSortArray = INVALID_HANDLE;
		}
	}

	iSize = GetArraySize(g_hHookPlugins);
	if(iSize > 0)
	{
		for(i=0; i < iSize; ++i)
		{
			RemoveAllFromForward(g_hPrivateForward_OnPlayerSpawn, Handle:GetArrayCell(g_hHookPlugins, i));
		}
	}

	ClearArray(g_hHookPlugins);

	UTIL_CloseHandleEx(g_hGroups);

	g_hGroups = CreateConfig("data/vip/cfg/groups.ini", "VIP_GROUPS");
	GLOBAL_INFO_KV = CreateConfig("data/vip/cfg/info.ini", "VIP_INFO");
}

Handle:CreateConfig(const String:sFile[], const String:sKvName[])
{
	decl String:sPath[PLATFORM_MAX_PATH], Handle:hKv;
	BuildPath(Path_SM, sPath, sizeof(sPath), sFile);

	hKv = CreateKeyValues(sKvName);
	if(FileToKeyValues(hKv, sPath) == false)
	{
		KeyValuesToFile(hKv, sPath);
	}

	KvRewind(hKv);

	return hKv;
}