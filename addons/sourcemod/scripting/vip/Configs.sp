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
	if (!g_bStarted)
	{
		g_bStarted = true;
		
		CreateForward_OnVIPLoaded();
		
		// VIP access is checked right after by UTIL_ReloadVIPPlayers (SQL_Callback_TableCreate)
		for (int iClient = 1; iClient <= MaxClients; ++iClient)
		{
			if (IsClientInGame(iClient) && !IsFakeClient(iClient))
			{
				Storage_LoadClient(iClient);
			}
		}
	}
}

void ReadConfigs()
{
	DBG_Config("ReadConfigs");

	ReadSortingMenu();

	delete g_hGroups;
	delete g_hInfo;

	g_hGroups = CreateConfig("data/vip/cfg/groups.ini", "VIP_GROUPS");
	Configs_ResolveGroupExtends(g_hGroups);
	g_hInfo = CreateConfig("data/vip/cfg/info.ini", "VIP_INFO");

	CreateForward_OnConfigsLoaded();
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
	{
		return;
	}

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

#define GROUP_EXTEND_KEY	"extend"

// "extend" "base;silver" in groups.ini: the group inherits the plain values of the listed groups.
// A later group in the list beats an earlier one, the group's own values beat all of them, and an own "" removes an inherited value.
// Resolved once here into flat groups, so the rest of the core never sees "extend".
// Groups added later by VIP_AddGroup are not resolved.
static void Configs_ResolveGroupExtends(KeyValues hGroups)
{
	ArrayList hNames = new ArrayList(ByteCountToCells(MAX_NAME_LENGTH));
	char szGroup[MAX_NAME_LENGTH];
	hGroups.Rewind();
	if (hGroups.GotoFirstSubKey())
	{
		do
		{
			hGroups.GetSectionName(SZF(szGroup));
			hNames.PushString(szGroup);
		}
		while (hGroups.GotoNextKey());
	}

	ArrayList hResolved = new ArrayList(ByteCountToCells(MAX_NAME_LENGTH));
	ArrayList hStack = new ArrayList(ByteCountToCells(MAX_NAME_LENGTH));
	for (int i = 0; i < hNames.Length; ++i)
	{
		hNames.GetString(i, SZF(szGroup));
		Configs_ResolveGroup(hGroups, hNames, szGroup, hResolved, hStack);
	}

	delete hResolved;
	delete hStack;
	delete hNames;
	hGroups.Rewind();
}

static void Configs_ResolveGroup(KeyValues hGroups, ArrayList hNames, const char[] szGroup, ArrayList hResolved, ArrayList hStack)
{
	if (hResolved.FindString(szGroup) != -1)
	{
		return;
	}

	char szExtend[256];
	hGroups.Rewind();
	hGroups.JumpToKey(szGroup);
	hGroups.GetString(GROUP_EXTEND_KEY, SZF(szExtend));
	if (!szExtend[0])
	{
		hResolved.PushString(szGroup);
		return;
	}

	hStack.PushString(szGroup);

	// Parents in list order, then the group's own values on top
	KeyValues hMerged = new KeyValues(szGroup);
	char szParent[MAX_NAME_LENGTH];
	int iPos = 0, iNext;
	do
	{
		iNext = SplitString(szExtend[iPos], ";", SZF(szParent));
		if (iNext == -1)
		{
			strcopy(SZF(szParent), szExtend[iPos]);
		}
		else
		{
			iPos += iNext;
		}

		TrimString(szParent);
		if (!szParent[0])
		{
			continue;
		}

		if (hNames.FindString(szParent) == -1)
		{
			LogError("groups.ini: group \"%s\" extends unknown group \"%s\"", szGroup, szParent);
			continue;
		}

		if (hStack.FindString(szParent) != -1)
		{
			LogError("groups.ini: group \"%s\" extends \"%s\", which leads back to itself", szGroup, szParent);
			continue;
		}

		Configs_ResolveGroup(hGroups, hNames, szParent, hResolved, hStack);
		Configs_CopyGroupValues(hGroups, szParent, hMerged);
	}
	while (iNext != -1);

	hStack.Erase(hStack.Length - 1);

	Configs_CopyGroupValues(hGroups, szGroup, hMerged);

	hGroups.Rewind();
	hGroups.JumpToKey(szGroup);
	hGroups.DeleteKey(GROUP_EXTEND_KEY);

	// Only own "" values are left in hMerged (parents are already resolved): they remove the inherited value
	char szKey[FEATURE_NAME_LENGTH], szValue[256];
	if (hMerged.GotoFirstSubKey(false))
	{
		do
		{
			hMerged.GetSectionName(SZF(szKey));
			hMerged.GetString(NULL_STRING, SZF(szValue));
			if (szValue[0])
			{
				hGroups.SetString(szKey, szValue);
			}
			else
			{
				hGroups.DeleteKey(szKey);
			}
		}
		while (hMerged.GotoNextKey(false));
	}

	delete hMerged;
	hResolved.PushString(szGroup);
}

// Plain values only: nested sections are not inherited
static void Configs_CopyGroupValues(KeyValues hGroups, const char[] szGroup, KeyValues hTo)
{
	hGroups.Rewind();
	if (!hGroups.JumpToKey(szGroup) || !hGroups.GotoFirstSubKey(false))
	{
		return;
	}

	char szKey[FEATURE_NAME_LENGTH], szValue[256];
	do
	{
		hGroups.GetSectionName(SZF(szKey));
		if (hGroups.GetDataType(NULL_STRING) == KvData_None || strcmp(szKey, GROUP_EXTEND_KEY, false) == 0)
		{
			continue;
		}

		// Floats come back as "%f" (6 decimals), which is enough for feature values
		hGroups.GetString(NULL_STRING, SZF(szValue));
		hTo.SetString(szKey, szValue);
	}
	while (hGroups.GotoNextKey(false));
}
