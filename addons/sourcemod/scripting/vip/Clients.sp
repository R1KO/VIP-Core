
void Clients_ResetClient(int iClient)
{
	g_iClientInfo[iClient] = 0;

	UTIL_CloseHandleEx(g_hFeatures[iClient]);
	UTIL_CloseHandleEx(g_hFeatureStatus[iClient]);
}

public void OnClientPutInServer(int iClient)
{
	//	g_iClientInfo[iClient] = 0;
	DebugMessage("OnClientPutInServer %N (%d): %b", iClient, iClient, g_iClientInfo[iClient])
	
	if(IsFakeClient(iClient) || IsClientSourceTV(iClient))
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

	if(!IsFakeClient(iClient))
	{
		CallForward_OnClientDisconnect(iClient);
		Storage_SaveClient(iClient);
		Storage_ResetClient(iClient);
	}
	
	Clients_ResetClient(iClient);
	UTIL_CloseHandleEx(g_hClientData[iClient]);
	g_iClientInfo[iClient] = 0;
}

void Clients_CheckVipAccess(int iClient, bool bNotify = false, bool bForward = false)
{
	if(bForward && !CallForward_OnClientPreLoad(iClient))
	{
		return;
	}

	Clients_ResetClient(iClient);

	// UNSET_BIT(g_iClientInfo[iClient], IS_LOADED);
	
	if (IsFakeClient(iClient) == false && (GLOBAL_INFO & IS_STARTED) && g_hDatabase)
	{
		Clients_LoadClient(iClient, bNotify);
		//	DebugMessage("Clients_CheckVipAccess %N:\tИгрок %sявляется VIP игроком", iClient, g_bIsClientVIP[iClient] ? "":"не ")
	}
	else
	{
		g_iClientInfo[iClient] |= IS_LOADED;
		CallForward_OnClientLoaded(iClient);
	}
}

void Clients_LoadClient(int iClient, bool bNotify)
{
	char szQuery[512];
	
	int iAccountID = GetSteamAccountID(iClient);

	DebugMessage("Clients_LoadClient %N (%d), %b: - > %x, %u", iClient, iClient, g_iClientInfo[iClient], g_hDatabase, g_hDatabase)

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

	DebugMessage("SQL_Callback_OnClientAuthorized: %d", iClient)
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
	OnClientLoaded(iClient);

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

		// TODO: load from storage
		Clients_LoadVIPFeaturesPre(iClient);
	}
}

void LoadClient(int iClient, int iAccountID, const char[] szGroup, int iExpires)
{
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
				if (g_CVAR_bLogsEnable)
				{
					LogToFile(g_szLogFile, "%T", "REMOVING_PLAYER", LANG_SERVER, iClient);
				}

				DebugMessage("Clients_LoadClient %N (%d):\tDelete", iClient, iClient)

				DB_RemoveClientFromID(REASON_EXPIRED, iClient, iAccountID, false, _, szGroup);
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

void Clients_OnVIPClientLoaded(int iClient)
{
	Features_TurnOnAll(iClient);

	CallForward_OnVIPClientLoaded(iClient);
}

void Clients_InitVIPClient(int iClient, int iAccountID = -1, const char[] szGroup = NULL_STRING, int iExpires = 0)
{
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
	DebugMessage("OnClientCookiesCached %d %N", iClient, iClient)
	
	DebugMessage("AreClientCookiesCached %b", AreClientCookiesCached(iClient))
	OnClientStorageLoaded(iClient);
}
#else
public void VIP_OnClientStorageLoaded(int iClient)
{
	DebugMessage("VIP_OnClientStorageLoaded: %d %N", iClient, iClient)
	OnClientStorageLoaded(iClient);
}
#endif

void OnClientStorageLoaded(int iClient)
{
	DebugMessage("OnClientStorageLoaded: %d %N", iClient, iClient)
}

bool IsClientStorageLoaded(int iClient)
{
	#if USE_CLIENTPREFS 1
	return AreClientCookiesCached(iClient);
	#else
	return Storage_IsClientLoaded(iClient);
	#endif
}

void Clients_LoadVIPFeaturesPre(int iClient, const char[] szFeature = NULL_STRING)
{
	DebugMessage("Clients_LoadVIPFeaturesPre %N", iClient)

	// DebugMessage("AreClientCookiesCached %b", AreClientCookiesCached(iClient))

	if (!IsClientStorageLoaded(iClient))
	{
		DataPack hDataPack = new DataPack();
		hDataPack.WriteCell(UID(iClient));
		if(szFeature[0])
		{
			hDataPack.WriteCell(true);
			hDataPack.WriteString(szFeature);
		}
		else
		{
			hDataPack.WriteCell(false);
		}
		CreateTimer(0.5, Timer_CheckCookies, hDataPack, TIMER_FLAG_NO_MAPCHANGE|TIMER_DATA_HNDL_CLOSE);
	}

	if(szFeature[0])
	{
		Clients_LoadVIPFeature(iClient, szFeature);
		return;
	}
	
	Clients_LoadVIPFeatures(iClient);
}

public Action Timer_CheckCookies(Handle hTimer, Handle hDP)
{
	DataPack hDataPack = view_as<DataPack>(hDP);
	hDataPack.Reset();
	int iClient = CID(hDataPack.ReadCell());
	
	DebugMessage("Timer_CheckCookies -> iClient: %N (%d), IsClientVIP: %b", iClient, iClient, IS_CLIENT_VIP(iClient))
	if (iClient && g_iClientInfo[iClient] & IS_VIP)
	{
		char szFeature[FEATURE_NAME_LENGTH];
		if(hDataPack.ReadCell())
		{
			hDataPack.ReadString(SZF(szFeature));
		}
		else
		{
			szFeature[0] = 0;
		}
		Clients_LoadVIPFeaturesPre(iClient, szFeature);
	}

	return Plugin_Stop;
}

void Clients_LoadVIPFeatures(int iClient)
{
	DebugMessage("LoadVIPFeatures %N", iClient)

	int iFeaturesCount = g_hFeaturesArray.Length;
	DebugMessage("FeaturesArraySize: %d", iFeaturesCount)
	if (iFeaturesCount > 0)
	{
		char szFeature[FEATURE_NAME_LENGTH];

		g_hFeatures[iClient].GetString(KEY_GROUP, SZF(szFeature));
		if (UTIL_CheckValidVIPGroup(szFeature))
		{
			for (int i = 0; i < iFeaturesCount; ++i)
			{
				g_hFeaturesArray.GetString(i, SZF(szFeature));
				Clients_LoadFeature(iClient, szFeature);
			}
		}
	}

	DebugMessage("Clients_OnVIPClientLoaded: %d %N", iClient, iClient)

	OnVIPClientLoaded(iClient);
}


void Clients_LoadVIPFeature(int iClient, const char[] szFeature)
{
	DebugMessage("LoadVIPFeature %N", iClient)

	int iFeaturesCount = g_hFeaturesArray.Length;
	DebugMessage("FeaturesArraySize: %d", iFeaturesCount)
	if (iFeaturesCount > 0)
	{
		char szGroup[FEATURE_NAME_LENGTH];

		g_hFeatures[iClient].GetString(KEY_GROUP, SZF(szGroup));
		if (UTIL_CheckValidVIPGroup(szGroup))
		{
			Clients_LoadFeature(iClient, szFeature);
		}
	}
/*
	DebugMessage("Clients_OnVIPClientLoaded: %d %N", iClient, iClient)

	Clients_OnVIPClientLoaded(iClient);
	*/
}

void Clients_LoadFeature(int iClient, const char[] szFeature)
{
	static ArrayList hArray;
	if (GLOBAL_TRIE.GetValue(szFeature, hArray))
	{
		DebugMessage("LoadClientFeature: %s", szFeature)

		if (GetValue(iClient, view_as<VIP_ValueType>(hArray.Get(FEATURES_VALUE_TYPE)), szFeature))
		{
			static VIP_ToggleState	eStatus;
			DebugMessage("GetValue: == true")
			if (view_as<VIP_FeatureType>(hArray.Get(FEATURES_ITEM_TYPE)) == TOGGLABLE)
			{
				eStatus = Features_GetStatusFromStorage(iClient, szFeature, hArray);
				DebugMessage("Features_GetStatusFromStorage: '%d'", eStatus)

				Features_SetStatusToStorage(iClient, szFeature, hArray, eStatus);
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

bool GetValue(int iClient, VIP_ValueType ValueType, const char[] szFeature)
{
	DebugMessage("GetValue: %d - %s", ValueType, szFeature)
	switch (ValueType)
	{
		case BOOL:
		{
			if (g_hGroups.GetNum(szFeature))
			{
				DebugMessage("value: 1")
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
				DebugMessage("value: %d", iValue)
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
				DebugMessage("value: %f", fValue)
				return g_hFeatures[iClient].SetValue(szFeature, fValue);
			}
			
			return false;
		}
		case STRING:
		{
			char szBuffer[256];
			g_hGroups.GetString(szFeature, SZF(szBuffer));
			if (szBuffer[0])
			{
				DebugMessage("value: %s", szBuffer)
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
	DebugMessage("Clients_CreateExpiredTimer %N (%d):\tiTimeLeft: %d", iClient, iClient, iTimeLeft)
	if (iTimeLeft > 0)
	{
		DebugMessage("Clients_CreateExpiredTimer %N (%d):\tiTimeLeft+iTime: %d", iClient, iClient, iTimeLeft + iTime)
		if ((iTimeLeft + iTime) > iExp)
		{
			DebugMessage("Clients_CreateExpiredTimer %N (%d):\tTimerDealy: %f", iClient, iClient, float((iExp - iTime) + 3))
			
			CreateTimer(float((iExp - iTime) + 3), Timer_VIP_Expired, UID(iClient), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

public void Event_MatchEndRestart(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
	if (g_CVAR_iDeleteExpired != -1 || g_CVAR_iOutdatedExpired != -1)
	{
		RemoveExpAndOutPlayers();
	}
}

public void Event_PlayerSpawn(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
	int UserID = hEvent.GetInt("userid");
	int iClient = CID(UserID);
	DebugMessage("Event_PlayerSpawn: %N (%d)", iClient, iClient)
	if (!(g_iClientInfo[iClient] & IS_SPAWNED))
	{
		CreateTimer(g_CVAR_fSpawnDelay, Timer_OnPlayerSpawn, UserID, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public void Event_PlayerDeath(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
	int iClient = CID(hEvent.GetInt("userid"));
	DebugMessage("Event_PlayerDeath: %N (%d)", iClient, iClient)
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
			DebugMessage("Timer_OnPlayerSpawn: %N (%d)", iClient, iClient)
			
			if (g_iClientInfo[iClient] & IS_VIP)
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
	DebugMessage("Event_RoundEnd")
	int iTime, iExp, i;
	iTime = GetTime();
	for (i = 1; i <= MaxClients; ++i)
	{
		if (IsClientInGame(i))
		{
			g_iClientInfo[i] &= ~IS_SPAWNED;
			if ((g_iClientInfo[i] & IS_VIP) && g_hFeatures[i].GetValue(KEY_EXPIRES, iExp) && iExp > 0 && iExp < iTime)
			{
				Clients_ExpiredClient(i);
			}
		}
	}
}

public Action Timer_VIP_Expired(Handle hTimer, any UserID)
{
	DebugMessage("Timer_VIP_Expired %d:", UserID)
	
	int iClient = CID(UserID);
	if (iClient && g_iClientInfo[iClient] & IS_VIP)
	{
		int iExp;
		if (g_hFeatures[iClient].GetValue(KEY_EXPIRES, iExp) && iExp > 0 && iExp < GetTime())
		{
			DebugMessage("Timer_VIP_Expired %N:", iClient)
			
			Clients_ExpiredClient(iClient);
		}
	}
}

void Clients_ExpiredClient(int iClient)
{
	DebugMessage("Clients_ExpiredClient %N:", iClient)
	Features_TurnOffAll(iClient);
	
	int iClientID;
	g_hFeatures[iClient].GetValue(KEY_EXPIRES, iClientID);
	if (g_CVAR_iDeleteExpired == 0 || GetTime() >= ((g_CVAR_iDeleteExpired*86400) + iClientID))
	{
		if (g_hFeatures[iClient].GetValue(KEY_CID, iClientID) && iClientID != -1)
		{
			if (g_CVAR_bLogsEnable)
			{
				LogToFile(g_szLogFile, "%T", "REMOVING_PLAYER", LANG_SERVER, iClient);
			}
			
			DB_RemoveClientFromID(REASON_EXPIRED, iClient, _, false);
		}
	}
	
	if(g_iClientInfo[iClient] & IS_MENU_OPEN)
	{
		CancelClientMenu(iClient);
	}

	Clients_ResetClient(iClient);
	SET_BIT(g_iClientInfo[iClient], IS_LOADED);

	CallForward_OnVIPClientRemoved(iClient, "Expired");

	DisplayClientInfo(iClient, "expired_info");
} 
