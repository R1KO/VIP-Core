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

	StringMap hResolved = new StringMap();	// group -> StringMap of its effective values
	ArrayList hExtended = new ArrayList(ByteCountToCells(MAX_NAME_LENGTH));
	ArrayList hStack = new ArrayList(ByteCountToCells(MAX_NAME_LENGTH));
	int iGroups = hNames.Length;
	for (int i = 0; i < iGroups; ++i)
	{
		hNames.GetString(i, SZF(szGroup));
		Configs_ResolveGroup(hGroups, szGroup, hResolved, hExtended, hStack);
	}

	StringMap hValues;
	int iExtended = hExtended.Length;
	for (int i = 0; i < iExtended; ++i)
	{
		hExtended.GetString(i, SZF(szGroup));
		hResolved.GetValue(szGroup, hValues);
		Configs_WriteGroupValues(hGroups, szGroup, hValues);
	}

	StringMapSnapshot hSnapshot = hResolved.Snapshot();
	for (int i = 0; i < hSnapshot.Length; ++i)
	{
		hSnapshot.GetKey(i, SZF(szGroup));
		hResolved.GetValue(szGroup, hValues);
		delete hValues;
	}
	delete hSnapshot;
	delete hResolved;
	delete hExtended;
	delete hStack;
	delete hNames;
	hGroups.Rewind();
}

static StringMap Configs_ResolveGroup(KeyValues hGroups, const char[] szGroup, StringMap hResolved, ArrayList hExtended, ArrayList hStack)
{
	StringMap hValues;
	if (hResolved.GetValue(szGroup, hValues))
	{
		return hValues;
	}

	StringMap hOwn = new StringMap();
	char szExtend[256];
	Configs_ReadGroupValues(hGroups, szGroup, hOwn, SZF(szExtend));

	hValues = new StringMap();
	if (szExtend[0])
	{
		hExtended.PushString(szGroup);
	}
	hStack.PushString(szGroup);

	// One name buffer instead of an ExplodeString array: this recurses once per inheritance level
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

		// KeyValues names are case-insensitive: use the section's own spelling as the key
		hGroups.Rewind();
		if (!hGroups.JumpToKey(szParent))
		{
			LogError("groups.ini: group \"%s\" extends unknown group \"%s\"", szGroup, szParent);
			continue;
		}
		hGroups.GetSectionName(SZF(szParent));

		if (hStack.FindString(szParent) != -1)
		{
			LogError("groups.ini: group \"%s\" extends \"%s\", which leads back to itself", szGroup, szParent);
			continue;
		}

		Configs_CopyValues(Configs_ResolveGroup(hGroups, szParent, hResolved, hExtended, hStack), hValues);
	}
	while (iNext != -1);

	hStack.Erase(hStack.Length - 1);

	Configs_CopyValues(hOwn, hValues);
	delete hOwn;

	hResolved.SetValue(szGroup, hValues);
	return hValues;
}

// Plain values only: nested sections are not inherited.
// Keys are lowercased because KeyValues keys are case-insensitive and StringMap keys are not ("HP" must override "hp").
static void Configs_ReadGroupValues(KeyValues hGroups, const char[] szGroup, StringMap hValues, char[] szExtend, int iMaxLength)
{
	szExtend[0] = 0;
	hGroups.Rewind();
	if (!hGroups.JumpToKey(szGroup) || !hGroups.GotoFirstSubKey(false))
	{
		return;
	}

	char szKey[FEATURE_NAME_LENGTH], szValue[256];
	do
	{
		if (hGroups.GetDataType(NULL_STRING) == KvData_None)
		{
			continue;
		}

		hGroups.GetSectionName(SZF(szKey));
		// Floats come back as "%f" (6 decimals), which is enough for feature values
		hGroups.GetString(NULL_STRING, SZF(szValue));
		if (strcmp(szKey, GROUP_EXTEND_KEY, false) == 0)
		{
			strcopy(szExtend, iMaxLength, szValue);
			continue;
		}

		for (int i = 0; szKey[i]; ++i)
		{
			szKey[i] = CharToLower(szKey[i]);
		}
		hValues.SetString(szKey, szValue);
	}
	while (hGroups.GotoNextKey(false));
}

// An own "" removes the inherited value
static void Configs_CopyValues(StringMap hFrom, StringMap hTo)
{
	StringMapSnapshot hSnapshot = hFrom.Snapshot();
	char szKey[FEATURE_NAME_LENGTH], szValue[256];
	for (int i = 0; i < hSnapshot.Length; ++i)
	{
		hSnapshot.GetKey(i, SZF(szKey));
		hFrom.GetString(szKey, SZF(szValue));
		if (szValue[0])
		{
			hTo.SetString(szKey, szValue);
		}
		else
		{
			hTo.Remove(szKey);
		}
	}
	delete hSnapshot;
}

// Own keys are rewritten too (KeyValues matches them case-insensitively); own "" keys are dropped
static void Configs_WriteGroupValues(KeyValues hGroups, const char[] szGroup, StringMap hValues)
{
	StringMap hOwn = new StringMap();
	char szExtend[256];
	Configs_ReadGroupValues(hGroups, szGroup, hOwn, SZF(szExtend));

	hGroups.Rewind();
	if (!hGroups.JumpToKey(szGroup))
	{
		delete hOwn;
		return;
	}

	hGroups.DeleteKey(GROUP_EXTEND_KEY);

	StringMapSnapshot hSnapshot = hOwn.Snapshot();
	char szKey[FEATURE_NAME_LENGTH], szValue[256];
	for (int i = 0; i < hSnapshot.Length; ++i)
	{
		hSnapshot.GetKey(i, SZF(szKey));
		if (!hValues.GetString(szKey, SZF(szValue)))
		{
			hGroups.DeleteKey(szKey);
		}
	}
	delete hSnapshot;
	delete hOwn;

	hSnapshot = hValues.Snapshot();
	for (int i = 0; i < hSnapshot.Length; ++i)
	{
		hSnapshot.GetKey(i, SZF(szKey));
		hValues.GetString(szKey, SZF(szValue));
		hGroups.SetString(szKey, szValue);
	}
	delete hSnapshot;
}
