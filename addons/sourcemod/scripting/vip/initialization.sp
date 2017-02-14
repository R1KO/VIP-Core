public OnMapStart()
{

//	g_bIsVIPLoaded = false;

//	UTIL_CloseHandleEx(g_hDatabase);
	
//	DB_Connect();

	LoadSounds();
	ParseInfo();
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
	decl String:sFeatureName[FEATURE_NAME_LENGTH], Handle:hArray, i, iSize;

	if (g_hSortArray != INVALID_HANDLE)
	{
		CloseHandle(g_hSortArray);
		g_hSortArray = INVALID_HANDLE;
	}

	hArray = OpenFile("addons/sourcemod/data/vip/cfg/sort_menu.ini", "r");
	if (hArray != INVALID_HANDLE)
	{
		g_hSortArray = CreateArray(ByteCountToCells(FEATURE_NAME_LENGTH));
		
		while (!IsEndOfFile(hArray) && ReadFileLine(hArray, sFeatureName, sizeof(sFeatureName)))
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

//	g_bIsVIPLoaded = false;

	UTIL_CloseHandleEx(g_hGroups);

	/*
	iSize = GetArraySize(GLOBAL_ARRAY);
	if(iSize > 0)
	{
		for(i=0; i < iSize; ++i)
		{
			GetArrayString(GLOBAL_ARRAY, i, sFeatureName, sizeof(sFeatureName));
			if(GetTrieValue(GLOBAL_TRIE, sFeatureName, hArray))
			{
				if(VIP_FeatureType:GetArrayCell(hArray, FEATURES_ITEM_TYPE) == TOGGLABLE)
				{
					CloseHandle(GetArrayCell(hArray, FEATURES_COOKIE));
				}
				CloseHandle(hArray);
			}
		}
	}
	*/

	iSize = GetArraySize(g_hHookPlugins);
	if(iSize > 0)
	{
		for(i=0; i < iSize; ++i)
		{
			RemoveAllFromForward(g_hPrivateForward_OnPlayerSpawn, Handle:GetArrayCell(g_hHookPlugins, i));
		}
	}

	ClearArray(g_hHookPlugins);

	/*
	ClearArray(GLOBAL_ARRAY);
	ClearTrie(GLOBAL_TRIE);
	*/

	g_hGroups = CreateConfig("data/vip/cfg/groups.ini", "VIP_GROUPS");
	
//	CreateForward_OnVIPLoaded();
	
//	g_bIsVIPLoaded = true;
//	CreateTimer(2.0, Timer_OnVIPLoaded,_, TIMER_FLAG_NO_MAPCHANGE);
}
/*
public Action:Timer_OnVIPLoaded(Handle:hTimer)
{
	DebugMessage("OnVIPLoaded Post")
	InitializeVIPMenu();

	return Plugin_Stop;
}
*/
Handle:CreateConfig(const String:sFile[], const String:sKvName[])
{
	decl String:sPath[PLATFORM_MAX_PATH], Handle:hKv;
	BuildPath(Path_SM, sPath, sizeof(sPath), sFile);
/*	if (!FileExists(sPath)) SetFailState("Файл \"%s\" не найден!", sPath);

	new Handle:hKv = CreateKeyValues(sKvName);
	if (!FileToKeyValues(hKv, sPath)) SetFailState("Не удалось открыть файл \"%s\"", sPath);
*/
	hKv = CreateKeyValues(sKvName);
	if(FileToKeyValues(hKv, sPath) == false)
	{
		LogMessage("Was unable to open that file '%s'. Automatically creating file...", sPath);
		KeyValuesToFile(hKv, sPath);
	}

	KvRewind(hKv);

	return hKv;
}