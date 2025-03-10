public void OnMapStart()
{
	LoadSounds();
	ReadDownloads();

	if (g_hDatabase && (g_CVAR_iDeleteExpired != -1 || g_CVAR_iOutdatedExpired != -1))
	{
		RemoveExpAndOutPlayers();
	}
}

void OnReadyToStart()
{
	DebugMessage("OnReadyToStart");
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
	DBG_Config("ReadConfigs");

	ReadSortingMenu();

	UTIL_CloseHandleEx(g_hGroups);

	g_hGroups = CreateConfig("data/vip/cfg/groups.ini", "VIP_GROUPS");
	g_hInfo = CreateConfig("data/vip/cfg/info.ini", "VIP_INFO");
}

void ReadSortingMenu()
{
	if (g_hSortArray != null)
	{
		delete g_hSortArray;
		g_hSortArray = null;
	}

	char szFeature[PMP];
	BuildPath(Path_SM, SZF(szFeature), "data/vip/cfg/sort_menu.ini");
	File hFile = OpenFile(szFeature, "r");
	if (!hFile)
		return;

	g_hSortArray = new ArrayList(ByteCountToCells(FEATURE_NAME_LENGTH));

	while (!hFile.EndOfFile() && hFile.ReadLine(szFeature, FEATURE_NAME_LENGTH))
	{
		DBG_Config("ReadFileLine: %s", szFeature);
		TrimString(szFeature);
		if (szFeature[0])
		{
			g_hSortArray.PushString(szFeature);
			DBG_Config("PushString: %s (%i)", szFeature, g_hSortArray.FindString(szFeature));
		}
	}

	delete hFile;

	DBG_Config("g_hSortArray.Length: %i", g_hSortArray.Length);

	if (g_hSortArray.Length == 0)
	{
		delete g_hSortArray;
		g_hSortArray = null;
	}
}

KeyValues CreateConfig(const char[] szFile, const char[] szKvName)
{
	char szPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, SZF(szPath), szFile);
	
	KeyValues hKeyValues = new KeyValues(szKvName);
	if (hKeyValues.ImportFromFile(szPath) == false)
	{
		hKeyValues.ExportToFile(szPath);
	}
	
	hKeyValues.Rewind();
	
	return hKeyValues;
}