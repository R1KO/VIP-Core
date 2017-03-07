public OnMapStart()
{
	LoadSounds();
	ReadDownloads();
}

void OnReadyToStart()
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

void ReadConfigs()
{
	DebugMessage("ReadConfigs")

	char sFeatureName[255]; Handle:hFile;

	if (g_hSortArray != INVALID_HANDLE)
	{
		CloseHandle(g_hSortArray);
		g_hSortArray = INVALID_HANDLE;
	}

	BuildPath(Path_SM, sFeatureName, sizeof(sFeatureName), "data/vip/cfg/sort_menu.ini");
	hFile = OpenFile(sFeatureName, "r");
	if (hFile != INVALID_HANDLE)
	{
		g_hSortArray = CreateArray(ByteCountToCells(FEATURE_NAME_LENGTH));
		
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
			CloseHandle(g_hSortArray);
			g_hSortArray = INVALID_HANDLE;
		}
	}

	UTIL_CloseHandleEx(g_hGroups);

	g_hGroups = CreateConfig("data/vip/cfg/groups.ini", "VIP_GROUPS");
	GLOBAL_INFO_KV = CreateConfig("data/vip/cfg/info.ini", "VIP_INFO");
}

Handle CreateConfig(const char[] sFile, const char[] sKvName)
{
	char sPath[PLATFORM_MAX_PATH]; Handle:hKv;
	BuildPath(Path_SM, sPath, sizeof(sPath), sFile);

	hKv = CreateKeyValues(sKvName);
	if(FileToKeyValues(hKv, sPath) == false)
	{
		KeyValuesToFile(hKv, sPath);
	}

	KvRewind(hKv);

	return hKv;
}