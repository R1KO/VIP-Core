public void OnMapStart()
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
		
		for (int iClient = 1; iClient <= MaxClients; ++iClient)
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

	if (g_hSortArray != null)
	{
		delete g_hSortArray;
		g_hSortArray = null;
	}
	
	char sFeatureName[255];
	BuildPath(Path_SM, sFeatureName, sizeof(sFeatureName), "data/vip/cfg/sort_menu.ini");
	File hFile = OpenFile(sFeatureName, "r");
	if (hFile != null)
	{
		g_hSortArray = new ArrayList(ByteCountToCells(FEATURE_NAME_LENGTH));
		
		while (!hFile.EndOfFile() && hFile.ReadLine(sFeatureName, FEATURE_NAME_LENGTH))
		{
			DebugMessage("ReadFileLine: %s", sFeatureName)
			TrimString(sFeatureName);
			if (sFeatureName[0])
			{
				g_hSortArray.PushString(sFeatureName);
				DebugMessage("PushArrayString: %s (%i)", sFeatureName, g_hSortArray.FindString(sFeatureName))
			}
		}
		
		delete hFile;
		
		DebugMessage("GetArraySize: %i", (g_hSortArray).Length)
		
		if ((g_hSortArray).Length == 0)
		{
			delete g_hSortArray;
			g_hSortArray = null;
		}
	}
	
	UTIL_CloseHandleEx(g_hGroups);
	
	g_hGroups = CreateConfig("data/vip/cfg/groups.ini", "VIP_GROUPS");
	g_hInfo = CreateConfig("data/vip/cfg/info.ini", "VIP_INFO");
}

KeyValues CreateConfig(const char[] sFile, const char[] sKvName)
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), sFile);
	
	KeyValues hKeyValues = new KeyValues(sKvName);
	if (hKeyValues.ImportFromFile(sPath) == false)
	{
		hKeyValues.ExportToFile(sPath);
	}
	
	hKeyValues.Rewind();
	
	return hKeyValues;
} 