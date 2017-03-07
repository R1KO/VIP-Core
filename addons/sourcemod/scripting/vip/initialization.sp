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

	decl String:sFeatureName[255], Handle:hFile;

	if (g_hSortArray != null)
	{
		delete g_hSortArray;
		g_hSortArray = null;
	}

	BuildPath(Path_SM, sFeatureName, sizeof(sFeatureName), "data/vip/cfg/sort_menu.ini");
	hFile = OpenFile(sFeatureName, "r");
	if (hFile != null)
	{
		g_hSortArray = new ArrayList(ByteCountToCells(FEATURE_NAME_LENGTH));
		
		while (!IsEndOfFile(hFile) && ReadFileLine(hFile, sFeatureName, FEATURE_NAME_LENGTH))
		{
			DebugMessage("ReadFileLine: %s", sFeatureName)
			TrimString(sFeatureName);
			if (sFeatureName[0])
			{
				PushArrayString(g_hSortArray, sFeatureName);
				DebugMessage("PushArrayString: %s (%i)", sFeatureName, FindStringInArray(g_hSortArray, sFeatureName))
			}
		}

		CloseHandle(hFile);
		
		DebugMessage("GetArraySize: %i", GetArraySize(g_hSortArray))
		
		if(GetArraySize(g_hSortArray) == 0)
		{
			delete g_hSortArray;
			g_hSortArray = null;
		}
	}

	UTIL_CloseHandleEx(g_hGroups);

	g_hGroups = CreateConfig("data/vip/cfg/groups.ini", "VIP_GROUPS");
	g_hInfo = CreateConfig("data/vip/cfg/info.ini", "VIP_INFO");
}

KeyValues CreateConfig(const String:sFile[], const String:sKvName[])
{
	decl String:sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), sFile);

	KeyValues hKeyValues = new KeyValues(sKvName);
	if(FileToKeyValues(hKeyValues, sPath) == false)
	{
		KeyValuesToFile(hKeyValues, sPath);
	}

	KvRewind(hKeyValues);

	return hKeyValues;
}