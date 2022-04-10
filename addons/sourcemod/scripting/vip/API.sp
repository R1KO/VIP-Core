#define VIP_CLIENT(%0)	(g_hFeatures[%0] && IS_CLIENT_VIP(%0) && IS_CLIENT_LOADED(%0))

static Handle g_hGlobalForward_OnVIPLoaded;
static Handle g_hGlobalForward_OnClientPreLoad;
static Handle g_hGlobalForward_OnClientLoaded;
static Handle g_hGlobalForward_OnVIPClientLoaded;
static Handle g_hGlobalForward_OnVIPClientAdded;
static Handle g_hGlobalForward_OnVIPClientRemoved;
static Handle g_hGlobalForward_OnPlayerSpawn;
static Handle g_hGlobalForward_OnShowClientInfo;
static Handle g_hGlobalForward_OnFeatureToggle;
static Handle g_hGlobalForward_OnFeatureRegistered;
static Handle g_hGlobalForward_OnFeatureUnregistered;
static Handle g_hGlobalForward_OnClientDisconnect;
static Handle g_hGlobalForward_OnClientStorageLoaded;
static Handle g_hGlobalForward_OnConfigsLoaded;

void API_SetupForwards()
{
	g_hGlobalForward_OnClientPreLoad = CreateGlobalForward("VIP_OnClientPreLoad", ET_Hook, Param_Cell);
	g_hGlobalForward_OnVIPLoaded = CreateGlobalForward("VIP_OnVIPLoaded", ET_Ignore);
	g_hGlobalForward_OnClientLoaded = CreateGlobalForward("VIP_OnClientLoaded", ET_Ignore, Param_Cell, Param_Cell);
	g_hGlobalForward_OnVIPClientLoaded = CreateGlobalForward("VIP_OnVIPClientLoaded", ET_Ignore, Param_Cell);
	g_hGlobalForward_OnVIPClientAdded = CreateGlobalForward("VIP_OnVIPClientAdded", ET_Ignore, Param_Cell, Param_Cell);
	g_hGlobalForward_OnVIPClientRemoved = CreateGlobalForward("VIP_OnVIPClientRemoved", ET_Ignore, Param_Cell, Param_String, Param_Cell);
	g_hGlobalForward_OnPlayerSpawn = CreateGlobalForward("VIP_OnPlayerSpawn", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	g_hGlobalForward_OnShowClientInfo = CreateGlobalForward("VIP_OnShowClientInfo", ET_Hook, Param_Cell, Param_String, Param_String, Param_Cell);
	g_hGlobalForward_OnFeatureToggle = CreateGlobalForward("VIP_OnFeatureToggle", ET_Ignore, Param_Cell, Param_String, Param_Cell, Param_CellByRef);
	g_hGlobalForward_OnFeatureRegistered = CreateGlobalForward("VIP_OnFeatureRegistered", ET_Ignore, Param_String);
	g_hGlobalForward_OnFeatureUnregistered = CreateGlobalForward("VIP_OnFeatureUnregistered", ET_Ignore, Param_String);
	g_hGlobalForward_OnClientDisconnect = CreateGlobalForward("VIP_OnClientDisconnect", ET_Ignore, Param_Cell, Param_Cell);
	g_hGlobalForward_OnClientStorageLoaded = CreateGlobalForward("VIP_OnClientStorageLoaded", ET_Ignore, Param_Cell);
	g_hGlobalForward_OnConfigsLoaded = CreateGlobalForward("VIP_OnConfigsLoaded", ET_Ignore);
}

void CallForward_OnVIPLoaded()
{
	DBG_API("CallForward_OnVIPLoaded()")
	Call_StartForward(g_hGlobalForward_OnVIPLoaded);
	Call_Finish();
}

void CallForward_OnConfigsLoaded()
{
	DBG_API("CallForward_OnConfigsLoaded()")
	Call_StartForward(g_hGlobalForward_OnConfigsLoaded);
	Call_Finish();
}

bool CallForward_OnClientPreLoad(int iClient)
{
	DBG_API("g_hGlobalForward_OnClientPreLoad(%N (%d), %b)", iClient, iClient, IS_CLIENT_VIP(iClient))
	bool bResult = true;
	Call_StartForward(g_hGlobalForward_OnClientPreLoad);
	Call_PushCell(iClient);
	Call_Finish(bResult);
	DBG_API("g_hGlobalForward_OnClientPreLoad = %b", bResult)

	return bResult;
}

void CallForward_OnClientLoaded(int iClient)
{
	DBG_API("CallForward_OnClientLoaded(%N (%d), %b)", iClient, iClient, IS_CLIENT_VIP(iClient))
	Call_StartForward(g_hGlobalForward_OnClientLoaded);
	Call_PushCell(iClient);
	Call_PushCell(IS_CLIENT_VIP(iClient));
	Call_Finish();
}

void CallForward_OnVIPClientLoaded(int iClient)
{
	DBG_API("CallForward_OnVIPClientLoaded(%N (%d))", iClient, iClient)
	Call_StartForward(g_hGlobalForward_OnVIPClientLoaded);
	Call_PushCell(iClient);
	Call_Finish();
}

void CallForward_OnClientDisconnect(int iClient)
{
	DBG_API("CallForward_OnClientDisconnect(%N (%d), %b)", iClient, iClient, IS_CLIENT_VIP(iClient))
	Call_StartForward(g_hGlobalForward_OnClientDisconnect);
	Call_PushCell(iClient);
	Call_PushCell(IS_CLIENT_VIP(iClient));
	Call_Finish();
}

void CallForward_OnVIPClientAdded(int iClient, int iAdmin = OWNER_PLUGIN)
{
	DBG_API("CallForward_OnVIPClientAdded(%N (%d), %d)", iClient, iClient, iAdmin)
	Call_StartForward(g_hGlobalForward_OnVIPClientAdded);
	Call_PushCell(iClient);
	Call_PushCell(iAdmin);
	Call_Finish();
}

void CallForward_OnVIPClientRemoved(int iClient, const char[] sReason, int iAdmin = OWNER_PLUGIN)
{
	DBG_API("CallForward_OnVIPClientRemoved(%N (%d), %d, '%s')", iClient, iClient, iAdmin, sReason)
	Call_StartForward(g_hGlobalForward_OnVIPClientRemoved);
	Call_PushCell(iClient);
	Call_PushString(sReason);
	Call_PushCell(iAdmin);
	Call_Finish();
}

void CallForward_OnPlayerSpawn(int iClient, int iTeam)
{
	DBG_API("CallForward_OnPlayerSpawn(%N (%d), %d, %b)", iClient, iClient, iTeam, IS_CLIENT_VIP(iClient))
	Call_StartForward(g_hGlobalForward_OnPlayerSpawn);
	Call_PushCell(iClient);
	Call_PushCell(iTeam);
	Call_PushCell(IS_CLIENT_VIP(iClient));
	Call_Finish();
}

Action CallForward_OnShowClientInfo(int iClient, const char[] szEvent, const char[] szType, KeyValues hKeyValues)
{
	DBG_API("CallForward_OnShowClientInfo(%N (%d), '%s', '%s')", iClient, iClient, szEvent, szType)
	Action eResult = Plugin_Continue;
	Call_StartForward(g_hGlobalForward_OnShowClientInfo);
	Call_PushCell(iClient);
	Call_PushString(szEvent);
	Call_PushString(szType);
	Call_PushCell(hKeyValues);
	Call_Finish(eResult);
	DBG_API("CallForward_OnShowClientInfo = %d", eResult)

	return eResult;
}

void CallForward_OnClientStorageLoaded(int iClient)
{
	DBG_API("CallForward_OnClientStorageLoaded(%N (%d))", iClient, iClient)
	Call_StartForward(g_hGlobalForward_OnClientStorageLoaded);
	Call_PushCell(iClient);
	Call_Finish();
}

VIP_ToggleState CallForward_OnFeatureToggle(int iClient, const char[] szFeature, VIP_ToggleState eOldStatus, VIP_ToggleState eNewStatus)
{
	DBG_API("CallForward_OnFeatureToggle(%N (%d), '%s', %d, %d)", iClient, iClient, szFeature, eOldStatus, eNewStatus)
	Action aResult = Plugin_Continue;
	VIP_ToggleState eResultStatus = eNewStatus;

	Call_StartForward(g_hGlobalForward_OnFeatureToggle);
	Call_PushCell(iClient);
	Call_PushString(szFeature);
	Call_PushCell(eOldStatus);
	Call_PushCellRef(eResultStatus);
	Call_Finish(aResult);
	DBG_API("CallForward_OnFeatureToggle = %b", bResult)

	switch (aResult)
	{
		case Plugin_Continue:
		{
			return eNewStatus;
		}
		case Plugin_Changed:
		{
			return eResultStatus;
		}
		case Plugin_Handled, Plugin_Stop:
		{
			return eOldStatus;
		}
	}

	return eResultStatus;
}

void CallForward_OnFeatureRegistered(const char[] szFeature)
{
	DBG_API("CallForward_OnFeatureRegistered('%s')", szFeature)
	Call_StartForward(g_hGlobalForward_OnFeatureRegistered);
	Call_PushString(szFeature);
	Call_Finish();
}

void CallForward_OnFeatureUnregistered(const char[] szFeature)
{
	DBG_API("CallForward_OnFeatureUnregistered('%s')", szFeature)
	Call_StartForward(g_hGlobalForward_OnFeatureUnregistered);
	Call_PushString(szFeature);
	Call_Finish();
}

VIP_ToggleState Function_OnItemToggle(Handle hPlugin, Function FuncToggle, int iClient, const char[] szFeature, const VIP_ToggleState eOldStatus, const VIP_ToggleState eNewStatus)
{
	VIP_ToggleState eResultStatus = eNewStatus;
	Action aResult;
	Call_StartFunction(hPlugin, FuncToggle);
	Call_PushCell(iClient);
	Call_PushString(szFeature);
	Call_PushCell(eOldStatus);
	Call_PushCellRef(eResultStatus);
	Call_Finish(aResult);
	
	switch (aResult)
	{
		case Plugin_Continue:
		{
			return eNewStatus;
		}
		case Plugin_Changed:
		{
			return eResultStatus;
		}
		case Plugin_Handled, Plugin_Stop:
		{
			return eOldStatus;
		}
	}

	return eResultStatus;
}

bool Function_OnItemSelect(Handle hPlugin, Function FuncSelect, int iClient, const char[] szFeature)
{
	bool bResult;
	Call_StartFunction(hPlugin, FuncSelect);
	Call_PushCell(iClient);
	Call_PushString(szFeature);
	Call_Finish(bResult);
	
	return bResult;
}


#define RegNative(%0)	CreateNative("VIP_" ... #%0, Native_%0)

public APLRes AskPluginLoad2(Handle myself, bool bLate, char[] szError, int err_max) 
{
	// Global
	RegNative(IsVIPLoaded);

	RegNative(GetDatabase);
	RegNative(GetDatabaseType);

	// Features
	RegNative(RegisterFeature);
	RegNative(UnregisterFeature);
	RegNative(UnregisterMe);
	RegNative(IsValidFeature);
	RegNative(GetFeatureType);
	RegNative(GetFeatureValueType);
	RegNative(FillArrayByFeatures);

	// Clients
	RegNative(GiveClientVIP);
	RegNative(SetClientVIP);
	RegNative(RemoveClientVIP);
	RegNative(RemoveClientVIP2);

	RegNative(CheckClient);
	RegNative(IsClientVIP);

	RegNative(GetClientID);

	RegNative(GetClientVIPGroup);
	RegNative(SetClientVIPGroup);

	RegNative(GetClientAccessTime);
	RegNative(SetClientAccessTime);

	RegNative(GetVIPClientTrie);

	RegNative(SendClientVIPMenu);

	RegNative(IsValidVIPGroup);
	RegNative(IsGroupExists);
	RegNative(AddGroup);
	RegNative(RemoveGroup);

	RegNative(GetClientFeatureStatus);
	RegNative(SetClientFeatureStatus);

	RegNative(IsClientFeatureUse);

	RegNative(GetClientFeatureInt);
	RegNative(GetClientFeatureFloat);
	RegNative(GetClientFeatureBool);
	RegNative(GetClientFeatureString);

	RegNative(GiveClientFeature);
	RegNative(RemoveClientFeature);

	// Storage
	RegNative(SetClientStorageValue);
	RegNative(GetClientStorageValue);

	// Helpers
	RegNative(PrintToChatClient);
	RegNative(PrintToChatAll);
	RegNative(LogMessage);
	RegNative(TimeToSeconds);
	RegNative(SecondsToTime);
	RegNative(GetTimeFromStamp);
	RegNative(AddStringToggleStatus);

	MarkNativeAsOptional("BfWriteByte");
	MarkNativeAsOptional("BfWriteString");
	MarkNativeAsOptional("PbSetInt");
	MarkNativeAsOptional("PbSetBool");
	MarkNativeAsOptional("PbSetString");
	MarkNativeAsOptional("PbAddString");

	MarkNativeAsOptional("TranslationPhraseExists");
	MarkNativeAsOptional("IsTranslatedForLanguage");

	RegPluginLibrary("vip_core");
	
	return APLRes_Success;
}

public int Native_CheckClient(Handle hPlugin, int iNumParams)
{
	DBG_API("Native_CheckClient(%d)", iNumParams)
	int iClient = GetNativeCell(1);
	DBG_API("iClient = %d", iClient)
	if (CheckValidClient(iClient, false))
	{
		Clients_CheckVipAccess(iClient, view_as<bool>(GetNativeCell(2)), view_as<bool>(GetNativeCell(3)));
	}

	return 0;
}

public int Native_IsClientVIP(Handle hPlugin, int iNumParams)
{
	DBG_API("Native_IsClientVIP(%d)", iNumParams)
	int iClient = GetNativeCell(1);
	DBG_API("iClient = %d", iClient)
	if (CheckValidClient(iClient, false))
	{
		DBG_API("IS_VIP = %b", IS_CLIENT_VIP(iClient))
		DBG_API("IS_CLIENT_LOADED = %b", (g_iClientInfo[iClient] & IS_LOADED))
		return IS_CLIENT_VIP(iClient) && IS_CLIENT_LOADED(iClient);
	}

	return 0;
}

public int Native_PrintToChatClient(Handle hPlugin, int iNumParams)
{
	DBG_API("Native_PrintToChatClient(%d)", iNumParams)
	int iClient = GetNativeCell(1);
	DBG_API("iClient = %d", iClient)
	if (CheckValidClient(iClient, false))
	{
		char szMessage[PMP];
		SetGlobalTransTarget(iClient);
		FormatNativeString(0, 2, 3, sizeof(szMessage), _, szMessage);

		Colors_Print(iClient, szMessage);
	}

	return 0;
}

public int Native_PrintToChatAll(Handle hPlugin, int iNumParams)
{
	DBG_API("Native_PrintToChatAll(%d)", iNumParams)
	char szMessage[PMP];

	for (int i = 1; i <= MCL; ++i)
	{
		if (IsClientInGame(i) && !IsFakeClient(i))
		{
			SetGlobalTransTarget(i);
			FormatNativeString(0, 1, 2, sizeof(szMessage), _, szMessage);
			Colors_Print(i, szMessage);
		}
	}

	return 0;
}

public int Native_LogMessage(Handle hPlugin, int iNumParams)
{
	DBG_API("Native_LogMessage(%d)", iNumParams)

	char szMessage[512];
	SetGlobalTransTarget(LANG_SERVER);
	FormatNativeString(0, 1, 2, sizeof(szMessage), _, szMessage);
	
	LogToFile(g_szLogFile, szMessage);

	return 0;
}

public int Native_GetClientID(Handle hPlugin, int iNumParams)
{
	DBG_API("Native_LogMessage(%d)", iNumParams)
	int iClient = GetNativeCell(1);
	DBG_API("iClient = %d", iClient)
	if (CheckValidClient(iClient, false) && VIP_CLIENT(iClient))
	{
		DBG_API("VIP_CLIENT")
		int iClientID;
		if (g_hFeatures[iClient].GetValue(KEY_CID, iClientID))
		{
			DBG_API("GetValue(%s) = %d", KEY_CID, iClientID)
			return iClientID;
		}
	}
	
	return 0;
}

public int Native_GetClientVIPGroup(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	if (CheckValidClient(iClient, false) && VIP_CLIENT(iClient))
	{
		char szGroup[64];
		
		szGroup[0] = 0;
		
		if (g_hFeatures[iClient].GetString(KEY_GROUP, SZF(szGroup)))
		{
			SetNativeString(2, szGroup, GetNativeCell(3), true);
			return true;
		}
	}
	
	SetNativeString(2, NULL_STRING, GetNativeCell(3), true);
	return false;
}

public int Native_SetClientVIPGroup(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	if (!CheckValidClient(iClient))
	{
		return 0;
	}
	char szGroup[64];
	GetNativeString(2, SZF(szGroup));
	if (!UTIL_CheckValidVIPGroup(szGroup))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid group (%s)", szGroup);
	}

	if (!g_hFeatures[iClient].SetString(KEY_GROUP, szGroup))
	{
		return 0;
	}
	if (view_as<bool>(GetNativeCell(3)))
	{
		int iClientID;
		if (g_hFeatures[iClient].GetValue(KEY_CID, iClientID) && iClientID != -1)
		{
			char szQuery[PMP];
			FormatEx(SZF(szQuery), "UPDATE `vip_users` SET `group` = '%s' WHERE `account_id` = %d%s;", szGroup, iClientID, g_szSID);
			DBG_SQL_Query(szQuery)
			g_hDatabase.Query(SQL_Callback_ChangeClientSettings, szQuery, UID(iClient));

			char szName[MNL], szAdmin[128], szPluginName[128], szOldGroup[64];
			GetClientName(iClient, SZF(szName));
			GetPluginInfo(hPlugin, PlInfo_Name, SZF(szPluginName));
			FormatEx(SZF(szAdmin), "%T %s", "BY_PLUGIN", LANG_SERVER, szPluginName);
			g_hFeatures[iClient].GetString(KEY_GROUP, SZF(szOldGroup));
			g_hFeatures[iClient].GetValue(KEY_CID, iClientID);
			LogToFile(g_szLogFile, "%T", "LOG_CHANGE_GROUP", LANG_SERVER, szName, iClientID, szOldGroup, szGroup, szAdmin);
		}

		return 1;
	}

	Clients_LoadFeatures(iClient);

	return 1;
}

public int Native_GetClientAccessTime(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	if (CheckValidClient(iClient, false) && VIP_CLIENT(iClient))
	{
		int iExp;
		if (g_hFeatures[iClient].GetValue(KEY_EXPIRES, iExp))
		{
			return iExp;
		}
	}
	
	return -1;
}

public int Native_SetClientAccessTime(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	if (CheckValidClient(iClient))
	{
		int iTime = GetNativeCell(2);
		
		if (iTime < 0 || (iTime != 0 && iTime < GetTime()))
		{
			return ThrowNativeError(SP_ERROR_NATIVE, "Invalid time (%i)", iTime);
		}
		
		if (g_hFeatures[iClient].SetValue(KEY_EXPIRES, iTime))
		{
			if (view_as<bool>(GetNativeCell(3)))
			{
				int iClientID;
				if (g_hFeatures[iClient].GetValue(KEY_CID, iClientID) && iClientID != -1)
				{
					char szQuery[PMP];
					FormatEx(SZF(szQuery), "UPDATE `vip_users` SET `expires` = %d WHERE `account_id` = %d%s;", iTime, iClientID, g_szSID);
					DBG_SQL_Query(szQuery)
					g_hDatabase.Query(SQL_Callback_ChangeClientSettings, szQuery, UID(iClient));
				}
			}
			
			return true;
		}
	}
	
	return false;
}

public void SQL_Callback_ChangeClientSettings(Database hOwner, DBResultSet hResult, const char[] szError, any iClient)
{
	DBG_SQL_Response("SQL_Callback_SelectVipClientInfo")
	if (szError[0])
	{
		LogError("SQL_Callback_ChangeClientSettings: %s", szError);
	}

	DBG_SQL_Response("hResult.AffectedRows = %d", hResult.AffectedRows)

	if ((iClient = CID(iClient)) && hResult.AffectedRows)
	{
		Clients_CheckVipAccess(iClient, false);
	}
}

public int Native_GetVIPClientTrie(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	if (CheckValidClient(iClient, false) && g_hFeatures[iClient])
	{
		return view_as<int>(g_hFeatures[iClient]);
	}

	return 0;
}

public int Native_SendClientVIPMenu(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	if (!CheckValidClient(iClient))
	{
		return 0;
	}

	bool bSelection = false;

	if (iNumParams == 2)
	{
		bSelection = view_as<bool>(GetNativeCell(2));
	}
	
	if (bSelection)
	{
		DisplayVipMenu(iClient);
		return 0;
	}
	
	int iItem = 0;
	g_hFeatures[iClient].GetValue(KEY_MENUITEM, iItem);

	DisplayVipMenu(iClient, iItem);

	return 0;
}

public int Native_GiveClientVIP(Handle hPlugin, int iNumParams)
{
	int iAdmin = GetNativeCell(1);
	int iClient = GetNativeCell(2);
	int iTime = GetNativeCell(3);
	bool bAddToDB = GetNativeCell(5);

	char szGroup[64];
	GetNativeString(4, SZF(szGroup));

	return API_GiveClientVIP(hPlugin, iAdmin, iClient, iTime, szGroup, bAddToDB);
}

public int Native_SetClientVIP(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	int iTime = GetNativeCell(2);
	bool bAddToDB = GetNativeCell(5);

	char szGroup[64];
	GetNativeString(4, SZF(szGroup));

	return API_GiveClientVIP(hPlugin, OWNER_PLUGIN, iClient, iTime, szGroup, bAddToDB);
}

int API_GiveClientVIP(Handle hPlugin,
							int iAdmin,
							int iClient,
							int iTime,
							const char[] szGroup,
							bool bAddToDB)
{
	if (CheckValidClient(iClient, false) && (iAdmin < 1 || CheckValidClient(iAdmin, false)))
	{

		if (!UTIL_CheckValidVIPGroup(szGroup))
		{
			return ThrowNativeError(SP_ERROR_NATIVE, "Invalid VIP-group (%s)", szGroup);
		}

		if (iTime < 0)
		{
			return ThrowNativeError(SP_ERROR_NATIVE, "Invalid time (%d)", iTime);
		}

		if (IS_CLIENT_VIP(iClient))
		{
			int iClientID;
			g_hFeatures[iClient].GetValue(KEY_CID, iClientID);
			if (iClientID == -1 && bAddToDB)
			{
				Clients_ResetClient(iClient);
				SET_BIT(g_iClientInfo[iClient], IS_LOADED);

				CallForward_OnVIPClientRemoved(iClient, "Removed for VIP-status change", iAdmin);
			}
			else
			{
				return ThrowNativeError(SP_ERROR_NATIVE, "The player %L is already a VIP", iClient, iClient);
			}
		}
		
		if (bAddToDB)
		{
			char szPluginName[128];
			GetPluginInfo(hPlugin, PlInfo_Name, SZF(szPluginName));
			Clients_AddVipPlayer(iAdmin, iClient, _, iTime, szGroup, szPluginName);
			return 0;
		}

		int iExpires = iTime;

		if (iTime != 0)
		{
			int iCurrentTime = GetTime();

			iExpires = iTime + iCurrentTime;
			Clients_CreateExpiredTimer(iClient, iExpires, iCurrentTime);
		}

		Clients_InitVIPClient(iClient, -1, szGroup, iExpires);

		Clients_TryLoadFeatures(iClient);

		DisplayClientInfo(iClient, iTime == 0 ? "connect_info_perm":"connect_info_time");

		//	Clients_OnVIPClientLoaded(iClient);
		if (g_CVAR_bAutoOpenMenu)
		{
			g_hVIPMenu.Display(iClient, MENU_TIME_FOREVER);
		}
	}
	
	return 0;
}

public int Native_RemoveClientVIP(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	bool bInDB = GetNativeCell(2);
	bool bNotify = GetNativeCell(3);

	return API_RemoveClientVIP(hPlugin, 0, iClient, bInDB, bNotify);
}

public int Native_RemoveClientVIP2(Handle hPlugin, int iNumParams)
{
	int iAdmin = GetNativeCell(1);
	int iClient = GetNativeCell(2);
	bool bInDB = GetNativeCell(3);
	bool bNotify = GetNativeCell(4);

	return API_RemoveClientVIP(hPlugin, iAdmin, iClient, bInDB, bNotify);
}

int API_RemoveClientVIP(Handle hPlugin,
							int iAdmin,
							int iClient,
							bool bInDB,
							bool bNotify)
{
	if (CheckValidClient(iClient))
	{
		if (iAdmin)
		{
			CheckValidClient(iAdmin, false);
		}

		char szPluginName[128];
		GetPluginInfo(hPlugin, PlInfo_Name, SZF(szPluginName));
		if (bInDB)
		{
			int iClientID;
			if (g_hFeatures[iClient].GetValue(KEY_CID, iClientID) && iClientID != -1)
			{
				Clients_RemoveVipPlayer(OWNER_PLUGIN, iClient, iClientID, bNotify, szPluginName);
				return 1;
			}
		}

		// TODO: remake this
		if (g_iClientInfo[iClient] & IS_MENU_OPEN)
		{
			CancelClientMenu(iClient);
		}

		Features_TurnOffAll(iClient);
		Clients_ResetClient(iClient);
		SET_BIT(g_iClientInfo[iClient], IS_LOADED);

		char szBuffer[PMP];
		FormatEx(SZF(szBuffer), "Removed by %s", szPluginName);
		CallForward_OnVIPClientRemoved(iClient, szBuffer, iAdmin);

		if (bNotify)
		{
			DisplayClientInfo(iClient, "expired_info");
		}

		return 1;
	}

	return 0;
}

public int Native_IsValidVIPGroup(Handle hPlugin, int iNumParams)
{
	char szGroup[64];
	GetNativeString(1, SZF(szGroup));
	return UTIL_CheckValidVIPGroup(szGroup);
}

public int Native_IsGroupExists(Handle hPlugin, int iNumParams)
{
	char szGroup[64];
	GetNativeString(1, SZF(szGroup));
	return UTIL_CheckValidVIPGroup(szGroup);
}

public int Native_AddGroup(Handle hPlugin, int iNumParams)
{
	char szGroup[64];
	GetNativeString(1, SZF(szGroup));
	if (UTIL_CheckValidVIPGroup(szGroup))
	{
		return 0;
	}

	g_hGroups.Rewind();
	if (g_hGroups.JumpToKey(szGroup, true))
	{
		KeyValues hGroupKv = view_as<KeyValues>(GetNativeCell(2));
		KvCopySubkeys(hGroupKv, g_hGroups);
		g_hGroups.Rewind();
		return 1;
	}

	return 0;
}


public int Native_RemoveGroup(Handle hPlugin, int iNumParams)
{
	char szGroup[64];
	GetNativeString(1, SZF(szGroup));
	if (UTIL_CheckValidVIPGroup(szGroup))
	{
		g_hGroups.DeleteThis();
		g_hGroups.Rewind();
		return 1;
	}

	return 0;
}

public int Native_IsVIPLoaded(Handle hPlugin, int iNumParams)
{
	return ((GLOBAL_INFO & IS_STARTED) && g_hDatabase);
}

public int Native_RegisterFeature(Handle hPlugin, int iNumParams)
{
	char szFeature[FEATURE_NAME_LENGTH];
	GetNativeString(1, SZF(szFeature));
	
	#if DEBUG_MODE
	char sPluginName[FEATURE_NAME_LENGTH];
	GetPluginFilename(hPlugin, sPluginName, FEATURE_NAME_LENGTH);
	DebugMessage("Register feature \"%s\" (%s)", szFeature, sPluginName)
	#endif
	
	if (IsValidFeature(szFeature))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Feature \"%s\" already defined", szFeature);
	}

	if (g_hFeaturesArray.Length == 0)
	{
		g_hVIPMenu.RemoveItem(0);
	}

	g_hFeaturesArray.PushString(szFeature);
	DebugMessage("PushArrayString -> %i", g_hFeaturesArray.FindString(szFeature))

	VIP_FeatureType eType = view_as<VIP_FeatureType>(GetNativeCell(3));
	DebugMessage("FeatureType -> %i", eType)

	ArrayList hArray = new ArrayList();
	GLOBAL_TRIE.SetValue(szFeature, hArray);
	
	hArray.Push(hPlugin);
	hArray.Push(GetNativeCell(2));
	hArray.Push(eType);

	if (eType != HIDE)
	{
		Handle hCookie = null;

		#if USE_CLIENTPREFS 1
		if (eType == TOGGLABLE || (eType == SELECTABLE && iNumParams > 7 && GetNativeCell(8)))
		{
			hCookie = RegClientCookie(szFeature, szFeature, CookieAccess_Private);
		}
		#endif

		Function fCallback = GetNativeCell(4);
		if (eType == SELECTABLE && fCallback == INVALID_FUNCTION)
		{
			return ThrowNativeError(SP_ERROR_NATIVE, "Undefined callback for SELECTABLE feature \"%s\"", szFeature);
		}

		hArray.Push(hCookie);

		DataPack hDataPack = new DataPack();
		hDataPack.WriteFunction(fCallback);
		hDataPack.WriteFunction(GetNativeCell(5));
		hDataPack.WriteFunction(GetNativeCell(6));
		hArray.Push(hDataPack);

		if (eType == TOGGLABLE)
		{
			hArray.Push(iNumParams > 6 ? GetNativeCell(7) : NO_ACCESS);
		}

		AddFeatureToVIPMenu(szFeature);
	}

	CallForward_OnFeatureRegistered(szFeature);
	DebugMessage("Feature \"%s\" registered", szFeature)

	for (int iClient = 1; iClient <= MaxClients; ++iClient)
	{
		if (IsClientInGame(iClient) && VIP_CLIENT(iClient))
		{
			Clients_TryLoadFeature(iClient, szFeature);
		}
	}

	return 1;
}

public int Native_UnregisterFeature(Handle hPlugin, int iNumParams)
{
	char szFeature[FEATURE_NAME_LENGTH];
	GetNativeString(1, SZF(szFeature));
	
	if (!IsValidFeature(szFeature))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Feature \"%s\" is invalid", szFeature);
	}

	ArrayList hArray;
	if (GLOBAL_TRIE.GetValue(szFeature, hArray))
	{
		UnregisterFeature(szFeature, hArray);

		int i = g_hFeaturesArray.FindString(szFeature);
		if (i != -1)
		{
			g_hFeaturesArray.Erase(i);
		}
	}
	
	return 1;
}

public int Native_UnregisterMe(Handle hPlugin, int iNumParams)
{
	DebugMessage("FeaturesArraySize: %d", g_hFeaturesArray.Length)
	if (!g_hFeaturesArray.Length)
	{
		return 0;
	}

	char szFeature[FEATURE_NAME_LENGTH];
	ArrayList hArray;

	for (int i = 0, iSize = g_hFeaturesArray.Length; i < iSize; ++i)
	{
		g_hFeaturesArray.GetString(i, SZF(szFeature));

		if (GLOBAL_TRIE.GetValue(szFeature, hArray))
		{
			if (view_as<Handle>(hArray.Get(FEATURES_PLUGIN)) != hPlugin)
			{
				continue;
			}

			UnregisterFeature(szFeature, hArray);

			g_hFeaturesArray.Erase(i);
			--i;
			--iSize;
		}
	}

	return 1;
}

void UnregisterFeature(const char[] szFeature, ArrayList hArray)
{
	VIP_FeatureType eType = view_as<VIP_FeatureType>(hArray.Get(FEATURES_ITEM_TYPE));
	if (eType == TOGGLABLE)
	{
		delete view_as<Handle>(hArray.Get(FEATURES_COOKIE));
	}
	
	if (eType != HIDE)
	{
		delete view_as<DataPack>(hArray.Get(FEATURES_MENU_CALLBACKS));
	}
	
	delete hArray;
	
	GLOBAL_TRIE.Remove(szFeature);

	if (eType != HIDE)
	{
		char szItemInfo[FEATURE_NAME_LENGTH];
		for (int j = 0, iSize = g_hVIPMenu.ItemCount; j < iSize; ++j)
		{
			g_hVIPMenu.GetItem(j, SZF(szItemInfo));
			if (strcmp(szItemInfo, szFeature, true) == 0)
			{
				g_hVIPMenu.RemoveItem(j);
				break;
			}
		}
	}

	for (int j = 1; j <= MaxClients; ++j)
	{
		if (IsClientInGame(j) && IS_CLIENT_VIP(j))
		{
			g_hFeatures[j].Remove(szFeature);
			g_hFeatureStatus[j].Remove(szFeature);
		}
	}

	CallForward_OnFeatureUnregistered(szFeature);
	DebugMessage("Feature \"%s\" unregistered", szFeature)
}

public int Native_IsValidFeature(Handle hPlugin, int iNumParams)
{
	char szFeature[FEATURE_NAME_LENGTH];
	GetNativeString(1, SZF(szFeature));
	
	return view_as<int>(IsValidFeature(szFeature));
}

public int Native_GetFeatureType(Handle hPlugin, int iNumParams)
{
	char szFeature[FEATURE_NAME_LENGTH];
	GetNativeString(1, SZF(szFeature));
	
	ArrayList hArray;
	if (GLOBAL_TRIE.GetValue(szFeature, hArray))
	{
		return hArray.Get(FEATURES_ITEM_TYPE);
	}

	return ThrowNativeError(SP_ERROR_NATIVE, "Feature \"%s\" is invalid", szFeature);
}

public int Native_GetFeatureValueType(Handle hPlugin, int iNumParams)
{
	char szFeature[FEATURE_NAME_LENGTH];
	GetNativeString(1, SZF(szFeature));
	
	ArrayList hArray;
	if (GLOBAL_TRIE.GetValue(szFeature, hArray))
	{
		return hArray.Get(FEATURES_VALUE_TYPE);
	}

	return ThrowNativeError(SP_ERROR_NATIVE, "Feature \"%s\" is invalid", szFeature);
}

public int Native_FillArrayByFeatures(Handle hPlugin, int iNumParams)
{
	ArrayList hArray = view_as<ArrayList>(GetNativeCell(1));

	hArray.Clear();
	
	int i, iSize;
	char szItemInfo[128];
	iSize = g_hFeaturesArray.Length;
	for (i = 0; i < iSize; ++i)
	{
		g_hFeaturesArray.GetString(i, SZF(szItemInfo));
		hArray.PushString(szItemInfo);
	}
	
	return hArray.Length;
}

public int Native_IsClientFeatureUse(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	if (CheckValidClient(iClient, false) && VIP_CLIENT(iClient))
	{
		char szFeature[FEATURE_NAME_LENGTH];
		GetNativeString(2, SZF(szFeature));
		
		DebugMessage("Native_IsClientFeatureUse: %N (%i) - %s -> %i", iClient, iClient, szFeature, Features_GetStatus(iClient, szFeature))
		return (Features_GetStatus(iClient, szFeature) == ENABLED);
	}
	
	return false;
}

public int Native_GetClientFeatureStatus(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	if (CheckValidClient(iClient, false) && VIP_CLIENT(iClient))
	{
		char szFeature[FEATURE_NAME_LENGTH];
		GetNativeString(2, SZF(szFeature));
		
		return view_as<int>(Features_GetStatus(iClient, szFeature));
	}
	
	return view_as<int>(NO_ACCESS);
}

public int Native_SetClientFeatureStatus(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	if (CheckValidClient(iClient))
	{
		char szFeature[FEATURE_NAME_LENGTH]; VIP_ToggleState eOldStatus; VIP_ToggleState eNewStatus;
		GetNativeString(2, SZF(szFeature));
		eOldStatus = Features_GetStatus(iClient, szFeature);
		
		eNewStatus = view_as<VIP_ToggleState>(GetNativeCell(3));
		ArrayList hArray;
		if (GLOBAL_TRIE.GetValue(szFeature, hArray))
		{
			if (view_as<VIP_FeatureType>(hArray.Get(FEATURES_ITEM_TYPE)) == TOGGLABLE)
			{
				if (iNumParams > 3 && GetNativeCell(4))
				{
					DataPack hDataPack = view_as<DataPack>(hArray.Get(FEATURES_MENU_CALLBACKS));
					hDataPack.Position = ITEM_SELECT;
					Function Function_Select = hDataPack.ReadFunction();
					if (Function_Select != INVALID_FUNCTION)
					{
						Function_OnItemToggle(view_as<Handle>(hArray.Get(FEATURES_PLUGIN)), Function_Select, iClient, szFeature, eOldStatus, eNewStatus);
					}
				}
				
				if (eOldStatus != eNewStatus)
				{
					Features_SetStatus(iClient, szFeature, eNewStatus);
					if (iNumParams > 4 && GetNativeCell(5))
					{
						Features_SetStatusToStorage(iClient, szFeature, eNewStatus);
					}
					return true;
				}
			}
		}
	}
	
	return false;
}

public int Native_GetClientFeatureInt(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	if (CheckValidClient(iClient, false) && VIP_CLIENT(iClient))
	{
		char szFeature[FEATURE_NAME_LENGTH]; int iValue;
		GetNativeString(2, SZF(szFeature));

		if (g_hFeatures[iClient].GetValue(szFeature, iValue) && iValue != 0)
		{
			return iValue;
		}
	}
	
	return 0;
}

public int Native_GetClientFeatureFloat(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	if (CheckValidClient(iClient, false) && VIP_CLIENT(iClient))
	{
		char szFeature[FEATURE_NAME_LENGTH]; float fValue;
		GetNativeString(2, SZF(szFeature));

		if (g_hFeatures[iClient].GetValue(szFeature, fValue) && fValue != 0.0)
		{
			return view_as<int>(fValue);
		}
	}
	return view_as<int>(0.0);
}

public int Native_GetClientFeatureBool(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	if (CheckValidClient(iClient, false) && VIP_CLIENT(iClient))
	{
		char szFeature[FEATURE_NAME_LENGTH]; bool bValue;
		GetNativeString(2, SZF(szFeature));

		return g_hFeatures[iClient].GetValue(szFeature, bValue);
	}
	
	return false;
}

public int Native_GetClientFeatureString(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	int iLen = GetNativeCell(4);
	if (CheckValidClient(iClient, false) && VIP_CLIENT(iClient))
	{
		char szFeature[64], szBuffer[PMP];
		GetNativeString(2, SZF(szFeature));

		if (g_hFeatures[iClient].GetString(szFeature, SZF(szBuffer)))
		{
			SetNativeString(3, szBuffer, iLen, true);
			return true;
		}
	}

	SetNativeString(3, NULL_STRING, iLen, true);
	return false;
}

public int Native_GiveClientFeature(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	if (CheckValidClient(iClient, false))
	{
		char szFeature[64];
		GetNativeString(2, SZF(szFeature));
		ArrayList hArray;
		if (!IsValidFeature(szFeature) || !GLOBAL_TRIE.GetValue(szFeature, hArray))
		{
			return ThrowNativeError(SP_ERROR_NATIVE, "Feature \"%s\" is invalid", szFeature);
		}

		char szValue[PMP];
		GetNativeString(3, SZF(szValue));
		
		if (IS_CLIENT_VIP(iClient))
		{
			Clients_InitVIPClient(iClient, -1, NULL_STRING, 0);
			g_hFeatures[iClient].SetValue(KEY_CID, -1);
			SET_BIT(g_iClientInfo[iClient], IS_VIP);
			SET_BIT(g_iClientInfo[iClient], IS_LOADED);
		}

		switch (view_as<VIP_ValueType>(hArray.Get(FEATURES_VALUE_TYPE)))
		{
			case BOOL:
			{
				g_hFeatures[iClient].SetValue(szFeature, !!StringToInt(szValue));
			}
			case INT:
			{
				g_hFeatures[iClient].SetValue(szFeature, StringToInt(szValue));
			}
			case FLOAT:
			{
				g_hFeatures[iClient].SetValue(szFeature, StringToFloat(szValue));
			}
			case STRING:
			{
				g_hFeatures[iClient].SetString(szFeature, szValue);
			}
		}

		Features_SetStatus(iClient, szFeature, ENABLED);

		if (view_as<VIP_FeatureType>(hArray.Get(FEATURES_ITEM_TYPE)) == TOGGLABLE)
		{
			DataPack hDataPack = view_as<DataPack>(hArray.Get(FEATURES_MENU_CALLBACKS));
			hDataPack.Position = ITEM_SELECT;
			Function fCallback = hDataPack.ReadFunction();

			if (fCallback != INVALID_FUNCTION)
			{
				Function_OnItemToggle(view_as<Handle>(hArray.Get(FEATURES_PLUGIN)), fCallback, iClient, szFeature, NO_ACCESS, ENABLED);
			}
			CallForward_OnFeatureToggle(iClient, szFeature, NO_ACCESS, ENABLED);
		}

		return 1;
	}

	return 0;
}

public int Native_RemoveClientFeature(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	if (!CheckValidClient(iClient))
	{
		return 0;
	}

	char szFeature[64];
	GetNativeString(2, SZF(szFeature));
	ArrayList hArray;
	if (!IsValidFeature(szFeature) || !GLOBAL_TRIE.GetValue(szFeature, hArray))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Feature \"%s\" is invalid", szFeature);
	}

	VIP_ToggleState eToggleState = Features_GetStatus(iClient, szFeature);

	g_hFeatures[iClient].Remove(szFeature);
	g_hFeatureStatus[iClient].Remove(szFeature);

	/*
	if (!g_hFeatures[iClient].Size)
	{
		Clients_ResetClient(iClient);
		SET_BIT(g_iClientInfo[iClient], IS_LOADED);
	}
	*/

	if (eToggleState != NO_ACCESS && view_as<VIP_FeatureType>(hArray.Get(FEATURES_ITEM_TYPE)) == TOGGLABLE)
	{
		DataPack hDataPack = view_as<DataPack>(hArray.Get(FEATURES_MENU_CALLBACKS));
		hDataPack.Position = ITEM_SELECT;
		Function fCallback = hDataPack.ReadFunction();

		if (fCallback != INVALID_FUNCTION)
		{
			Function_OnItemToggle(view_as<Handle>(hArray.Get(FEATURES_PLUGIN)), fCallback, iClient, szFeature, eToggleState, NO_ACCESS);
		}
		CallForward_OnFeatureToggle(iClient, szFeature, eToggleState, NO_ACCESS);
	}

	return 1;
}

public int Native_SetClientStorageValue(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	if (!CheckValidClient(iClient, false))
	{
		return 0;
	}

	char szKey[128], szValue[PMP];
	GetNativeString(2, SZF(szKey));
	GetNativeString(3, SZF(szValue));

	Storage_SetClientValue(iClient, szKey, szValue);

	return 0;
}

public int Native_GetClientStorageValue(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	if (!CheckValidClient(iClient, false))
	{
		return 0;
	}

	char szKey[128], szValue[PMP];
	GetNativeString(2, SZF(szKey));

	Storage_GetClientValue(iClient, szKey, SZF(szValue));
	SetNativeString(3, szValue, GetNativeCell(4), true);

	return 0;
}

public int Native_GetDatabase(Handle hPlugin, int iNumParams)
{
	return view_as<int>(CloneHandle(g_hDatabase, hPlugin));
}

public int Native_GetDatabaseType(Handle hPlugin, int iNumParams)
{
	return (GLOBAL_INFO & IS_MySQL);
}

public int Native_TimeToSeconds(Handle hPlugin, int iNumParams)
{
	return UTIL_TimeToSeconds(GetNativeCell(1));
}

public int Native_SecondsToTime(Handle hPlugin, int iNumParams)
{
	return UTIL_SecondsToTime(GetNativeCell(1));
}

public int Native_GetTimeFromStamp(Handle hPlugin, int iNumParams)
{
	int iTimeStamp = GetNativeCell(3);
	if (iTimeStamp > 0)
	{
		int iClient = GetNativeCell(4);
		if (iClient == LANG_SERVER || CheckValidClient(iClient, false))
		{
			char szBuffer[64];
			UTIL_GetTimeFromStamp(SZF(szBuffer), iTimeStamp, iClient);
			SetNativeString(1, szBuffer, GetNativeCell(2), true);
			return true;
		}
	}
	
	return false;
}

public int Native_AddStringToggleStatus(Handle hPlugin, int iNumParams)
{
	char szFeature[FEATURE_NAME_LENGTH];
	GetNativeString(4, SZF(szFeature));
	if (!IsValidFeature(szFeature))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Feature \"%s\" is invalid", szFeature);
	}

	int iClient = GetNativeCell(5);
	if (CheckValidClient(iClient))
	{
		int iSize = GetNativeCell(3);
		char[] szBuffer = new char[iSize]; // char szBuffer[iSize];
		GetNativeString(1, szBuffer, iSize);
		Format(szBuffer, iSize, "%s [%T]", szBuffer, g_szToggleStatus[view_as<int>(Features_GetStatus(iClient, szFeature))], iClient);
		SetNativeString(2, szBuffer, iSize, true);
	}

	return 0;
}

bool CheckValidClient(const int &iClient, bool bCheckVIP = true)
{
	if (iClient < 1 || iClient > MaxClients)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%i)", iClient);
		return false;
	}
	if (IsClientInGame(iClient) == false)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Client %i is not connected", iClient);
		return false;
	}
	if (bCheckVIP)
	{
		/*
		if (!(g_iClientInfo[iClient] & IS_LOADED))
		{
			ThrowNativeError(SP_ERROR_NATIVE, "Client %i is not loaded", iClient);
			return false;
		}
		if (!IS_CLIENT_VIP(iClient) || !(g_iClientInfo[iClient] & IS_AUTHORIZED))
		{
			ThrowNativeError(SP_ERROR_NATIVE, "Client %i is not VIP", iClient);
			return false;
		}
		*/
		
		return IS_CLIENT_VIP(iClient);
	}
	
	return true;
}
