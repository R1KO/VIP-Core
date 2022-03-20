
void Clients_ResetClient(int iClient)
{
	g_iClientInfo[iClient] = 0;

	UTIL_CloseHandleEx(g_hFeatures[iClient]);
	UTIL_CloseHandleEx(g_hFeatureStatus[iClient]);
}

public void OnClientPutInServer(int iClient)
{
	//	g_iClientInfo[iClient] = 0;
	DBG_CLIENTS("OnClientPutInServer %N (%d): %b", iClient, iClient, g_iClientInfo[iClient])
	
	if (IsFakeClient(iClient) || IsClientSourceTV(iClient))
	{
		return;
	}

	Storage_LoadClient(iClient);
	Clients_CheckVipAccess(iClient, true, true);
}

public void OnClientDisconnect(int iClient)
{
	/*	if (g_bIsClientVIP[iClient])
	{
		SaveClient(iClient);
	}*/

	if (!IsFakeClient(iClient))
	{
		CallForward_OnClientDisconnect(iClient);
		Storage_SaveClient(iClient);
	}

	Clients_ResetClient(iClient);
	UTIL_CloseHandleEx(g_hClientData[iClient]);
	g_iClientInfo[iClient] = 0;

	Storage_ResetClient(iClient);
}

void Clients_CheckVipAccess(int iClient, bool bNotify = false, bool bForward = false)
{
	if (bForward && !CallForward_OnClientPreLoad(iClient))
	{
		return;
	}

	Clients_ResetClient(iClient);

	// UNSET_BIT(g_iClientInfo[iClient], IS_LOADED);
	
	if (IsFakeClient(iClient) == false && (GLOBAL_INFO & IS_STARTED) && g_hDatabase)
	{
		Clients_LoadClient(iClient, bNotify);
		//	DBG_CLIENTS("Clients_CheckVipAccess %N:\tИгрок %sявляется VIP игроком", iClient, g_bIsClientVIP[iClient] ? "":"не ")
	}
	else
	{
		SET_BIT(g_iClientInfo[iClient], IS_LOADED);
		CallForward_OnClientLoaded(iClient);
	}
}

void Clients_LoadClient(int iClient, bool bNotify)
{
	char szQuery[512];
	
	int iAccountID = GetSteamAccountID(iClient);

	DBG_CLIENTS("Clients_LoadClient %N (%d), %b: - > %x, %u", iClient, iClient, g_iClientInfo[iClient], g_hDatabase, g_hDatabase)

	FormatEx(SZF(szQuery), "SELECT `expires`, `group`, `name` \
										FROM `vip_users` \
										WHERE `account_id` = %d%s LIMIT 1;",
										iAccountID, g_szSID);

	DataPack hDataPack = new DataPack();
	hDataPack.WriteCell(UID(iClient));
	hDataPack.WriteCell(iAccountID);
	hDataPack.WriteCell(bNotify);

	DBG_SQL_Query(szQuery)
	g_hDatabase.Query(SQL_Callback_OnClientAuthorized, szQuery, hDataPack);
}

public void SQL_Callback_OnClientAuthorized(Database hOwner, DBResultSet hResult, const char[] szError, any hPack)
{
	DBG_SQL_Response("SQL_Callback_OnClientAuthorized")
	DataPack hDataPack = view_as<DataPack>(hPack);
	if (hResult == null || szError[0])
	{
		LogError("SQL_Callback_OnClientAuthorized: %s", szError);
		delete hDataPack;
		return;
	}
	
	hDataPack.Reset();
	
	int iClient = CID(hDataPack.ReadCell());
	int iAccountID = hDataPack.ReadCell();
	bool bNotify = view_as<bool>(hDataPack.ReadCell());
	delete hDataPack;

	DBG_CLIENTS("SQL_Callback_OnClientAuthorized: %d", iClient)
	if (!iClient || !IsClientInGame(iClient))
	{
		return;
	}

	if (!hResult.FetchRow())
	{
		OnClientLoaded(iClient);
		return;
	}
	DBG_SQL_Response("hResult.FetchRow()")

	int iExpires = hResult.FetchInt(0);
	DBG_SQL_Response("hResult.FetchInt(0) = %d", iExpires)
	char szGroup[64];
	hResult.FetchString(1, SZF(szGroup));
	DBG_SQL_Response("hResult.FetchString(1) = '%s", szGroup)

	
	LoadClient(iClient, iAccountID, szGroup, iExpires);

	if (IS_CLIENT_VIP(iClient))
	{
		char szName[MAX_NAME_LENGTH*2+1];
		hResult.FetchString(2, SZF(szName));
		DB_UpdateClient(iClient, szName);

		if (bNotify)
		{
			if (g_CVAR_bAutoOpenMenu)
			{
				g_hVIPMenu.Display(iClient, MENU_TIME_FOREVER);
			}

			DisplayClientInfo(iClient, iExpires == 0 ? "connect_info_perm":"connect_info_time");
		}

		Clients_TryLoadFeatures(iClient);
		return;
	}

	OnClientLoaded(iClient);
}

void LoadClient(int iClient, int iAccountID, const char[] szGroup, int iExpires)
{
	DBG_CLIENTS("LoadClient: %d, %d, %s, %d", iClient, iAccountID, szGroup, iExpires)
	if (!szGroup[0] || !UTIL_CheckValidVIPGroup(szGroup))
	{
		LogError("Invalid VIP-Group/Некорректная VIP-группа: %s (Игрок: %d)", szGroup, iAccountID);
		return;
	}

	if (iExpires > 0)
	{
		int iTime = GetTime();

		if (iTime > iExpires)
		{
			if (g_CVAR_iDeleteExpired == 0 || (g_CVAR_iDeleteExpired > 0 && iTime >= ((g_CVAR_iDeleteExpired * 86400) + iExpires)))
			{
				LogToFile(g_szLogFile, "%T", "REMOVING_PLAYER", LANG_SERVER, iClient);

				DBG_CLIENTS("Clients_LoadClient %N (%d): >>> Delete", iClient, iClient)

				Clients_RemoveVipPlayer(REASON_EXPIRED, iClient, iAccountID, true);
			}

			CallForward_OnVIPClientRemoved(iClient, "Expired");

			DisplayClientInfo(iClient, "expired_info");

			return;
		}

		Clients_CreateExpiredTimer(iClient, iExpires, iTime);
	}

	Clients_InitVIPClient(iClient, iAccountID, szGroup, iExpires);
}


void OnClientLoaded(int iClient)
{
	SET_BIT(g_iClientInfo[iClient], IS_LOADED);
	CallForward_OnClientLoaded(iClient);
}

void OnVIPClientLoaded(int iClient)
{
	SET_BIT(g_iClientInfo[iClient], IS_LOADED);
	CallForward_OnVIPClientLoaded(iClient);
}

stock void Clients_OnVIPClientLoaded(int iClient)
{
	Features_TurnOnAll(iClient);

	CallForward_OnVIPClientLoaded(iClient);
}

void Clients_InitVIPClient(int iClient, int iAccountID = -1, const char[] szGroup = NULL_STRING, int iExpires = 0)
{
	DBG_CLIENTS("Clients_InitVIPClient: %d, %d, %s, %d", iClient, iAccountID, szGroup, iExpires)
	g_hFeatures[iClient] = new StringMap();
	g_hFeatureStatus[iClient] = new StringMap();

	g_hFeatures[iClient].SetValue(KEY_EXPIRES, iExpires);
	g_hFeatures[iClient].SetString(KEY_GROUP, szGroup);
	g_hFeatures[iClient].SetValue(KEY_CID, iAccountID);

	SET_BIT(g_iClientInfo[iClient], IS_VIP);
}

#if USE_CLIENTPREFS 1
public void OnClientCookiesCached(int iClient)
{
	DBG_CLIENTS("OnClientCookiesCached %d %N", iClient, iClient)
	
	DBG_CLIENTS("AreClientCookiesCached %b", AreClientCookiesCached(iClient))
	//OnClientStorageLoaded(iClient);
}
#else
public void VIP_OnClientStorageLoaded(int iClient)
{
	DBG_CLIENTS("VIP_OnClientStorageLoaded: %d %N", iClient, iClient)
	//OnClientStorageLoaded(iClient);
}
#endif
/*
void OnClientStorageLoaded(int iClient)
{
	DBG_CLIENTS("OnClientStorageLoaded: %d %N", iClient, iClient)
}
*/

bool IsClientStorageLoaded(int iClient)
{
	#if USE_CLIENTPREFS 1
	DBG_CLIENTS("AreClientCookiesCached: %d %N", iClient, iClient)
	return AreClientCookiesCached(iClient);
	#else
	DBG_CLIENTS("Storage_IsClientLoaded: %d %N", iClient, iClient)
	return Storage_IsClientLoaded(iClient);
	#endif
}

void Clients_TryLoadFeatures(int iClient)
{
	DBG_CLIENTS("Clients_TryLoadFeatures %L", iClient)
	DBG_CLIENTS("IsClientStorageLoaded %b", IsClientStorageLoaded(iClient))

	if (!IsClientStorageLoaded(iClient))
	{
		// TODO: may be will add attempts counter
		DataPack hDataPack = new DataPack();
		hDataPack.WriteCell(UID(iClient));
		CreateTimer(1.0, Timer_CheckStorageLoadFeatures, hDataPack, TIMER_FLAG_NO_MAPCHANGE|TIMER_DATA_HNDL_CLOSE);
		return;
	}
	
	Clients_LoadFeatures(iClient);
}

public Action Timer_CheckStorageLoadFeatures(Handle hTimer, DataPack hDataPack)
{
	hDataPack.Reset();
	int iClient = CID(hDataPack.ReadCell());
	
	DBG_CLIENTS("Timer_CheckStorageLoadFeatures -> iClient: %N (%d), IsClientVIP: %b", iClient, iClient, IS_CLIENT_VIP(iClient))
	if (iClient && IS_CLIENT_VIP(iClient))
	{
		Clients_TryLoadFeatures(iClient);
	}

	return Plugin_Stop;
}


void Clients_TryLoadFeature(int iClient, const char[] szFeature)
{
	DBG_CLIENTS("Clients_TryLoadFeature %L", iClient)

	if (!IsClientStorageLoaded(iClient))
	{
		DataPack hDataPack = new DataPack();
		hDataPack.WriteCell(UID(iClient));
		hDataPack.WriteString(szFeature);
		CreateTimer(1.0, Timer_CheckStorageLoadFeature, hDataPack, TIMER_FLAG_NO_MAPCHANGE|TIMER_DATA_HNDL_CLOSE);
	}

	Clients_LoadFeature(iClient, szFeature);
}

public Action Timer_CheckStorageLoadFeature(Handle hTimer, DataPack hDataPack)
{
	hDataPack.Reset();
	int iClient = CID(hDataPack.ReadCell());
	
	DBG_CLIENTS("Timer_CheckStorageLoadFeature -> iClient: %N (%d), IsClientVIP: %b", iClient, iClient, IS_CLIENT_VIP(iClient))
	if (iClient && IS_CLIENT_VIP(iClient))
	{
		char szFeature[FEATURE_NAME_LENGTH];
		hDataPack.ReadString(SZF(szFeature));
		Clients_LoadFeature(iClient, szFeature);
	}

	return Plugin_Stop;
}

void Clients_LoadFeatures(int iClient)
{
	DBG_CLIENTS("LoadVIPFeatures %N", iClient)

	int iFeaturesCount = g_hFeaturesArray.Length;
	DBG_CLIENTS("FeaturesArraySize: %d", iFeaturesCount)
	if (iFeaturesCount > 0)
	{
		char szFeature[FEATURE_NAME_LENGTH];

		g_hFeatures[iClient].GetString(KEY_GROUP, SZF(szFeature));
		if (UTIL_CheckValidVIPGroup(szFeature))
		{
			for (int i = 0; i < iFeaturesCount; ++i)
			{
				g_hFeaturesArray.GetString(i, SZF(szFeature));
				Clients_LoadFeatureValue(iClient, szFeature);
			}
		}
	}

	DBG_CLIENTS("Clients_OnVIPClientLoaded: %d %N", iClient, iClient)

	OnClientLoaded(iClient);
	OnVIPClientLoaded(iClient);
	Features_TurnOnAll(iClient);
}

void Clients_LoadFeature(int iClient, const char[] szFeature)
{
	DBG_CLIENTS("LoadVIPFeature %N", iClient)

	int iFeaturesCount = g_hFeaturesArray.Length;
	DBG_CLIENTS("FeaturesArraySize: %d", iFeaturesCount)
	if (iFeaturesCount > 0)
	{
		char szGroup[FEATURE_NAME_LENGTH];

		g_hFeatures[iClient].GetString(KEY_GROUP, SZF(szGroup));
		if (UTIL_CheckValidVIPGroup(szGroup))
		{
			Clients_LoadFeatureValue(iClient, szFeature);
		}
	}
/*
	DBG_CLIENTS("Clients_OnVIPClientLoaded: %d %N", iClient, iClient)

	Clients_OnVIPClientLoaded(iClient);
	*/
}

void Clients_LoadFeatureValue(int iClient, const char[] szFeature)
{
	static ArrayList hArray;
	if (GLOBAL_TRIE.GetValue(szFeature, hArray))
	{
		DBG_CLIENTS("Clients_LoadFeatureValue: %s", szFeature)

		if (GetFeatureValue(iClient, view_as<VIP_ValueType>(hArray.Get(FEATURES_VALUE_TYPE)), szFeature))
		{
			static VIP_ToggleState eStatus;
			DBG_CLIENTS("GetValue: == true")
			if (view_as<VIP_FeatureType>(hArray.Get(FEATURES_ITEM_TYPE)) == TOGGLABLE)
			{
				eStatus = Features_GetStatusFromStorage(iClient, szFeature, hArray);
				DBG_CLIENTS("Features_GetStatusFromStorage: '%d'", eStatus)
			}
			else
			{
				eStatus = ENABLED;
			}

			Features_SetStatus(iClient, szFeature, eStatus);
			//	Function_OnItemToggle(view_as<Handle>(hArray.Get(FEATURES_PLUGIN)), Function:hArray.Get(FEATURES_ITEM_SELECT), iClient, szFeature, NO_ACCESS, ENABLED);
		}
	}
}

bool GetFeatureValue(int iClient, VIP_ValueType ValueType, const char[] szFeature)
{
	DBG_CLIENTS("GetFeatureValue: %d - %s", ValueType, szFeature)
	switch (ValueType)
	{
		case BOOL:
		{
			if (g_hGroups.GetNum(szFeature))
			{
				DBG_CLIENTS("value: 1")
				return g_hFeatures[iClient].SetValue(szFeature, true);
			}
			return false;
		}
		case INT:
		{
			int iValue;
			iValue = g_hGroups.GetNum(szFeature);
			if (iValue != 0)
			{
				DBG_CLIENTS("value: %d", iValue)
				return g_hFeatures[iClient].SetValue(szFeature, iValue);
			}
			return false;
		}
		case FLOAT:
		{
			float fValue;
			fValue = g_hGroups.GetFloat(szFeature);
			if (fValue != 0.0)
			{
				DBG_CLIENTS("value: %f", fValue)
				return g_hFeatures[iClient].SetValue(szFeature, fValue);
			}
			
			return false;
		}
		case STRING:
		{
			char szBuffer[PMP];
			g_hGroups.GetString(szFeature, SZF(szBuffer));
			if (szBuffer[0])
			{
				DBG_CLIENTS("value: %s", szBuffer)
				return g_hFeatures[iClient].SetString(szFeature, szBuffer);
			}
			return false;
		}
		case VIP_NULL:
		{
			return false;
		}
	}

	return false;
}

void Clients_CreateExpiredTimer(int iClient, int iExp, int iTime)
{
	int iTimeLeft;
	GetMapTimeLeft(iTimeLeft);
	DBG_CLIENTS("Clients_CreateExpiredTimer %N (%d): iTimeLeft: %d", iClient, iClient, iTimeLeft)
	if (iTimeLeft > 0)
	{
		DBG_CLIENTS("Clients_CreateExpiredTimer %N (%d): iTimeLeft+iTime: %d", iClient, iClient, iTimeLeft + iTime)
		if ((iTimeLeft + iTime) < iExp)
		{
			DBG_CLIENTS("Skip timer")
			return;
		}
	}

	DBG_CLIENTS("Clients_CreateExpiredTimer %N (%d): TimerDealy: %f", iClient, iClient, float((iExp - iTime) + 3))
	CreateTimer(float((iExp - iTime) + 3), Timer_VIP_Expired, UID(iClient), TIMER_FLAG_NO_MAPCHANGE);
}

public void Event_MatchEndRestart(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
	RemoveExpAndOutPlayers();
}

public void Event_PlayerSpawn(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
	int UserID = hEvent.GetInt("userid");
	int iClient = CID(UserID);
	DBG_CLIENTS("Event_PlayerSpawn: %N (%d)", iClient, iClient)
	if (!(g_iClientInfo[iClient] & IS_SPAWNED))
	{
		CreateTimer(g_CVAR_fSpawnDelay, Timer_OnPlayerSpawn, UserID, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public void Event_PlayerDeath(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
	int iClient = CID(hEvent.GetInt("userid"));
	DBG_CLIENTS("Event_PlayerDeath: %N (%d)", iClient, iClient)
	g_iClientInfo[iClient] &= ~IS_SPAWNED;
}

public Action Timer_OnPlayerSpawn(Handle hTimer, any UserID)
{
	int iClient = CID(UserID);
	if (iClient && IsClientInGame(iClient))
	{
		int iTeam = GetClientTeam(iClient);
		if (iTeam > 1 && IsPlayerAlive(iClient))
		{
			DBG_CLIENTS("Timer_OnPlayerSpawn: %N (%d)", iClient, iClient)
			
			if (IS_CLIENT_VIP(iClient))
			{
				int iExp;
				if (g_hFeatures[iClient].GetValue(KEY_EXPIRES, iExp) && iExp > 0 && iExp < GetTime())
				{
					Clients_ExpiredClient(iClient);
				}
			}
			
			g_iClientInfo[iClient] |= IS_SPAWNED;
			CallForward_OnPlayerSpawn(iClient, iTeam);
		}
	}
	return Plugin_Stop;
}

public void Event_RoundEnd(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
	DBG_CLIENTS("Event_RoundEnd")
	int iTime, iExp, i;
	iTime = GetTime();
	for (i = 1; i <= MaxClients; ++i)
	{
		if (IsClientInGame(i))
		{
			g_iClientInfo[i] &= ~IS_SPAWNED;
			if (IS_CLIENT_VIP(i) && g_hFeatures[i].GetValue(KEY_EXPIRES, iExp) && iExp > 0 && iExp < iTime)
			{
				Clients_ExpiredClient(i);
			}
		}
	}
}

public Action Timer_VIP_Expired(Handle hTimer, any UserID)
{
	DBG_CLIENTS("Timer_VIP_Expired %d:", UserID)
	
	int iClient = CID(UserID);
	if (iClient && IS_CLIENT_VIP(iClient))
	{
		int iExp;
		if (g_hFeatures[iClient].GetValue(KEY_EXPIRES, iExp) && iExp > 0 && iExp < GetTime())
		{
			DBG_CLIENTS("Timer_VIP_Expired %N:", iClient)
			
			Clients_ExpiredClient(iClient);
		}
	}

	return Plugin_Stop;
}

void Clients_ExpiredClient(int iClient)
{
	DBG_CLIENTS("Clients_ExpiredClient %N:", iClient)
	Features_TurnOffAll(iClient);
	
	int iClientID;
	g_hFeatures[iClient].GetValue(KEY_EXPIRES, iClientID);
	if (g_CVAR_iDeleteExpired == 0 || GetTime() >= ((g_CVAR_iDeleteExpired*86400) + iClientID))
	{
		if (g_hFeatures[iClient].GetValue(KEY_CID, iClientID) && iClientID != -1)
		{
			LogToFile(g_szLogFile, "%T", "REMOVING_PLAYER", LANG_SERVER, iClient);

			Clients_RemoveVipPlayer(REASON_EXPIRED, iClient, _, true);
			return;
		}
	}
	
	if (g_iClientInfo[iClient] & IS_MENU_OPEN)
	{
		CancelClientMenu(iClient);
	}

	Clients_ResetClient(iClient);
	SET_BIT(g_iClientInfo[iClient], IS_LOADED);

	CallForward_OnVIPClientRemoved(iClient, "Expired");

	DisplayClientInfo(iClient, "expired_info");
} 

void Clients_AddVipPlayer(
	int iAdmin = OWNER_SERVER,
	int iTarget = 0,
	int iTargetAccountID = 0,
	int iDuration,
	const char[] szGroup,
	const char[] szByWho = NULL_STRING
)
{
	char szAdminInfo[PMP], szTargetInfo[PMP];
	int iExpires;

	if (iDuration)
	{
		iExpires = iDuration + GetTime();
	}
	else
	{
		iExpires = iDuration;
	}
	
	if (iTarget)
	{
		iTargetAccountID = GetSteamAccountID(iTarget);
		UTIL_GetClientInfo(iTarget, SZF(szTargetInfo));
	}
	else
	{
		char szAuth[32];
		UTIL_GetSteamIDFromAccountID(iTargetAccountID, SZF(szAuth));
		FormatEx(SZF(szTargetInfo), "unknown (%s, unknown)", szAuth);
	}

	switch(iAdmin)
	{
		case OWNER_PLUGIN:
		{
			FormatEx(SZF(szAdminInfo), "%T %s", "BY_PLUGIN", LANG_SERVER, szByWho);
		}
		case OWNER_SERVER:
		{
			FormatEx(SZF(szAdminInfo), "%T", "BY_SERVER", LANG_SERVER);
		}
		default:
		{
			char szAdmin[128];
			UTIL_GetClientInfo(iAdmin, SZF(szAdmin));
			FormatEx(SZF(szAdminInfo), "%T %s", "BY_ADMIN", LANG_SERVER, szAdmin);
			iAdmin = UID(iAdmin);
		}
	}

	DB_AddVipPlayer(
		iAdmin,
		szAdminInfo,
		iTarget,
		iTargetAccountID,
		szTargetInfo,
		iDuration,
		iExpires,
		szGroup
	);
}

void Clients_OnVipPlayerAdded(
	const int iAdmin,
	const char[] szAdminInfo,
	const int iTarget,
	const int iTargetAccountID,
	const char[] szTargetInfo,
	const int iDuration,
	const int iExpires,
	const char[] szGroup
)
{
	char szExpires[64], szDuration[64];

	if (iTarget)
	{
		Clients_CheckVipAccess(iTarget, true);
		CallForward_OnVIPClientAdded(iTarget, iAdmin);
	}

	if (iAdmin >= 0)
	{
		if (iDuration)
		{
			UTIL_GetTimeFromStamp(SZF(szDuration), iDuration, iAdmin);
			FormatTime(SZF(szExpires), "%d/%m/%Y - %H:%M", iExpires);
		}
		else
		{
			FormatEx(SZF(szDuration), "%T", "PERMANENT", iAdmin);
			FormatEx(SZF(szExpires), "%T", "NEVER", iAdmin);
		}
		UTIL_Reply(iAdmin, "%t", "ADMIN_VIP_ADD_SUCCESS", szTargetInfo, szGroup);
	}

	if (iDuration)
	{
		UTIL_GetTimeFromStamp(SZF(szExpires), iDuration, LANG_SERVER);
	}
	else
	{
		FormatEx(SZF(szExpires), "%T", "PERMANENT", LANG_SERVER);
		FormatEx(SZF(szExpires), "%T", "NEVER", LANG_SERVER);
	}

	LogToFile(g_szLogFile, "%T", "LOG_VIP_ADDED", LANG_SERVER, szTargetInfo, iTargetAccountID, szDuration, szExpires, szGroup, szAdminInfo);
}

void Clients_RemoveVipPlayer(
	int iAdmin = 0,
	int iTarget = 0,
	int iTargetAccountID = 0,
	bool bNotify,
	const char[] szByWho = NULL_STRING
)
{
	DBG_CLIENTS("Clients_RemoveVipPlayer %d: - > iTargetAccountID: %d, : bNotify: %b", iTarget, iTargetAccountID, bNotify)

	if (iTarget) {
		iTargetAccountID = GetSteamAccountID(iTarget);
	}

	char szAdminInfo[PMP];
	switch(iAdmin)
	{
		case REASON_EXPIRED:
		{
			FormatEx(SZF(szAdminInfo), "%T", "REASON_EXPIRED", LANG_SERVER);
		}
		case REASON_OUTDATED:
		{
			FormatEx(SZF(szAdminInfo), "%T", "REASON_INACTIVITY", LANG_SERVER);
		}
		case OWNER_PLUGIN:
		{
			FormatEx(SZF(szAdminInfo), "%T %s", "BY_PLUGIN", LANG_SERVER, szByWho);
		}
		case OWNER_SERVER:
		{
			FormatEx(SZF(szAdminInfo), "%T", "BY_SERVER", LANG_SERVER);
		}
		default:
		{
			char szAdmin[128];
			UTIL_GetClientInfo(iAdmin, SZF(szAdmin));
			FormatEx(SZF(szAdminInfo), "%T %s", "BY_ADMIN", LANG_SERVER, szAdmin);
		}
	}

	DB_RemoveVipPlayer(
		iAdmin,
		szAdminInfo,
		iTarget,
		iTargetAccountID,
		bNotify
	);
}

void Clients_OnVipPlayerRemoved(
	const int iAdmin,
	const char[] szAdminInfo,
	const int iTarget,
	const int iTargetAccountID,
	const char[] szTargetInfo,
	const char[] szGroup,
	const bool bNotify
)
{
	LogToFile(g_szLogFile, "%T", "LOG_VIP_DELETED", LANG_SERVER, szTargetInfo, iTargetAccountID, szGroup, szAdminInfo);

	DebugMessage("Clients_OnVipPlayerRemoved(iAdmin: %d, szAdminInfo: %s, iTarget: %d, iTargetAccountID: %d, szTargetInfo: %s", iAdmin, szAdminInfo, iTarget, iTargetAccountID, szTargetInfo)

	if (iTarget)
	{
		if (g_iClientInfo[iTarget] & IS_MENU_OPEN)
		{
			CancelClientMenu(iTarget);
		}

		Features_TurnOffAll(iTarget);
		Clients_ResetClient(iTarget);
		SET_BIT(g_iClientInfo[iTarget], IS_LOADED);

		// TODO: Fix this
		CallForward_OnVIPClientRemoved(iTarget, "Expired");

		DisplayClientInfo(iTarget, "expired_info");

		if (bNotify)
		{
			// TODO: notify player
		}
	}

	if (iAdmin > 0)
	{
		UTIL_Reply(iAdmin, "%t", "ADMIN_VIP_PLAYER_DELETED", szTargetInfo, szGroup);
	}
}

void Clients_ReloadVipPlayers(int iClient, bool bNotify)
{
	for (int i = 1; i <= MaxClients; ++i)
	{
		if (IsClientInGame(i))
		{
			Clients_CheckVipAccess(i, false, true);
		}
	}
	
	if (bNotify)
	{
		UTIL_Reply(iClient, "%t", "VIP_CACHE_REFRESHED");
	}
}
