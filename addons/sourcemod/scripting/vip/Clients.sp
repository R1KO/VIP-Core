// Bumped on every reset, so timers started for a previous load can tell they are stale
static int g_iClientLoadSerial[MAXPLAYERS+1];
// Loaded before Steam authorized the player: OnClientAuthorized has to check again
static bool g_bClientWaitsForAuth[MAXPLAYERS+1];

// Drops the VIP status only: session flags (spawned, menu open, chat input) stay
void ResetClient(int iClient)
{
	g_ePlayer[iClient].bVIP = false;
	g_ePlayer[iClient].bLoaded = true;
	++g_iClientLoadSerial[iClient];
	
	delete g_ePlayer[iClient].hFeatures;
	delete g_ePlayer[iClient].hFeatureStatus;
}

// Takes the VIP status away from a player in game: modules get their features toggled off first
void Clients_RemoveVIPStatus(int iClient)
{
	Features_TurnOffAll(iClient);
	ResetClient(iClient);
}

public void OnClientPutInServer(int iClient)
{
	DBG_Clients("OnClientPutInServer %N (%d)", iClient, iClient);
	
	if(!IsFakeClient(iClient) && !IsClientSourceTV(iClient))
	{
		Storage_LoadClient(iClient);
		Clients_CheckVipAccess(iClient, true, true);
	}
}

// Steam authorized the player after OnClientPutInServer: storage and the VIP check were skipped then (no account id yet)
public void OnClientAuthorized(int iClient, const char[] szAuth)
{
	if (g_bClientWaitsForAuth[iClient] && IsClientInGame(iClient))
	{
		g_bClientWaitsForAuth[iClient] = false;
		Storage_LoadClient(iClient);
		Clients_CheckVipAccess(iClient, true, true);
	}
}

public void OnClientDisconnect(int iClient)
{
	/*	if (g_bIsClientVIP[iClient])
	{
		SaveClient(iClient);
	}*/

	if(!IsFakeClient(iClient))
	{
		CreateForward_OnClientDisconnect(iClient);
		Storage_SaveClient(iClient);
	}
	Storage_ResetClient(iClient);
	
	ResetClient(iClient);
	delete g_ePlayer[iClient].hData;
	g_ePlayer[iClient].ClearFlags();
	g_bClientWaitsForAuth[iClient] = false;
}

void Clients_CheckVipAccess(int iClient, bool bNotify = false, bool bForward = false)
{
	if(bForward && !CreateForward_OnClientPreLoad(iClient))
	{
		return;
	}

	Clients_RemoveVIPStatus(iClient);
	g_ePlayer[iClient].bLoaded = false;
	
	if (IsFakeClient(iClient) == false && g_bStarted && g_hDatabase)
	{
		Clients_LoadClient(iClient, bNotify);
		//	DBG_Clients("Clients_CheckVipAccess %N:\tis %sa VIP", iClient, g_bIsClientVIP[iClient] ? "":"not ")
	}
	else
	{
		Clients_SetLoaded(iClient);
	}
}

void Clients_SetLoaded(int iClient)
{
	g_ePlayer[iClient].bLoaded = true;
	CreateForward_OnClientLoaded(iClient);
}

void Clients_LoadClient(int iClient, bool bNotify)
{
	char szQuery[512];
	
	int iAccountID = GetSteamAccountID(iClient);

	DBG_Clients("Clients_LoadClient %N (%d), VIP: %b - > %x, %u", iClient, iClient, g_ePlayer[iClient].bVIP, g_hDatabase, g_hDatabase);

	// Not authorized yet: loaded as non-VIP for now, checked again from OnClientAuthorized
	if (!iAccountID)
	{
		g_bClientWaitsForAuth[iClient] = true;
		Clients_SetLoaded(iClient);
		return;
	}

	FormatEx(SZF(szQuery), "SELECT `expires`, `group`, `name` \
										FROM `vip_users` \
										WHERE `account_id` = %d%s LIMIT 1;",
										iAccountID, g_szSID);

	DataPack hDataPack = new DataPack();
	hDataPack.WriteCell(UID(iClient));
	hDataPack.WriteCell(iAccountID);
	hDataPack.WriteCell(bNotify);

	DBG_SQL_Query(szQuery);
	g_hDatabase.Query(SQL_Callback_OnClientAuthorized, szQuery, hDataPack);
}

public void SQL_Callback_OnClientAuthorized(Database hOwner, DBResultSet hResult, const char[] szError, any hPack)
{
	DBG_SQL_Response("SQL_Callback_OnClientAuthorized");
	DataPack hDataPack = view_as<DataPack>(hPack);
	hDataPack.Reset();
	
	int iClient = CID(hDataPack.ReadCell());
	int iAccountID = hDataPack.ReadCell();
	bool bNotify = view_as<bool>(hDataPack.ReadCell());
	delete hDataPack;

	DBG_Clients("SQL_Callback_OnClientAuthorized: %d", iClient);
	if (!iClient || !IsClientInGame(iClient))
	{
		return;
	}

	if (hResult == null || szError[0])
	{
		LogError("SQL_Callback_OnClientAuthorized: %s", szError);
		// Load the player as non-VIP so modules still get OnClientLoaded
		Clients_SetLoaded(iClient);
		return;
	}

	if (hResult.FetchRow())
	{
		DBG_SQL_Response("hResult.FetchRow()");

		int iExpires = hResult.FetchInt(0);
		DBG_SQL_Response("hResult.FetchInt(0) = %d", iExpires);
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

					DBG_Clients("Clients_LoadClient %N (%d):\tDelete", iClient, iClient);

					char szGroup[64];
					hResult.FetchString(1, SZF(szGroup));

					DB_RemoveClientFromID(REASON_EXPIRED, iClient, iAccountID, false, _, szGroup);
				}

				CreateForward_OnVIPClientRemoved(iClient, "Expired");
				
				DisplayClientInfo(iClient, "expired_info");
				
				Clients_SetLoaded(iClient);
				return;
			}
			
			Clients_CreateExpiredTimer(iClient, iExpires, iTime);
		}

		char szGroup[64];
		hResult.FetchString(1, SZF(szGroup));
		DBG_SQL_Response("hResult.FetchString(1) = '%s", szGroup);
		if (szGroup[0] && UTIL_CheckValidVIPGroup(szGroup))
		{
			Clients_CreateClientVIPSettings(iClient, iExpires);

			g_ePlayer[iClient].hFeatures.SetValue(KEY_CID, iAccountID);

			g_ePlayer[iClient].hFeatures.SetString(KEY_GROUP, szGroup);
			
			g_ePlayer[iClient].bVIP = true;

			Clients_SetLoaded(iClient);

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

			Clients_LoadVIPFeaturesPre(iClient);
		}
		else
		{
			LogError("Invalid VIP group: %s (player: %d)", szGroup, iAccountID);
			Clients_SetLoaded(iClient);
		}
		return;
	}

	Clients_SetLoaded(iClient);
}

void Clients_OnVIPClientLoaded(int iClient)
{
	Features_TurnOnAll(iClient);

	CreateForward_OnVIPClientLoaded(iClient);
}

void Clients_CreateClientVIPSettings(int iClient, int iExp)
{
	// A reload may overlap with a load still in flight
	delete g_ePlayer[iClient].hFeatures;
	delete g_ePlayer[iClient].hFeatureStatus;

	g_ePlayer[iClient].hFeatures = new StringMap();
	g_ePlayer[iClient].hFeatureStatus = new StringMap();

	g_ePlayer[iClient].hFeatures.SetValue(KEY_EXPIRES, iExp);
}

#if DEBUG_MODE
public void OnClientCookiesCached(int iClient)
{
	DBG_Clients("OnClientCookiesCached %d %N", iClient, iClient);
	
	DBG_Clients("AreClientCookiesCached %b", AreClientCookiesCached(iClient));
}
#endif

// Fixed retry window: if the store isn't ready by then, statuses fall back to defaults
#define STATUS_STORE_WAIT_ATTEMPTS	120	// x 0.5s

void Clients_LoadVIPFeaturesPre(int iClient, const char[] szFeature = NULL_STRING)
{
	DBG_Clients("Clients_LoadVIPFeaturesPre %N", iClient);

	// Load once, when the status store (cookies / storage) is ready: loading fires OnVIPClientLoaded and turns features on
	if (!Features_IsStatusStoreReady(iClient))
	{
		Clients_WaitForStatusStore(iClient, szFeature, 0);
		return;
	}

	Clients_LoadVIPFeaturesNow(iClient, szFeature);
}

void Clients_LoadVIPFeaturesNow(int iClient, const char[] szFeature)
{
	if(szFeature[0])
	{
		Clients_LoadVIPFeature(iClient, szFeature);
		return;
	}
	
	Clients_LoadVIPFeatures(iClient);
}

void Clients_WaitForStatusStore(int iClient, const char[] szFeature, int iAttempt)
{
	DataPack hDataPack = new DataPack();
	hDataPack.WriteCell(UID(iClient));
	hDataPack.WriteCell(g_iClientLoadSerial[iClient]);
	hDataPack.WriteCell(iAttempt);
	hDataPack.WriteString(szFeature);
	CreateTimer(0.5, Timer_CheckCookies, hDataPack, TIMER_FLAG_NO_MAPCHANGE|TIMER_DATA_HNDL_CLOSE);
}

public Action Timer_CheckCookies(Handle hTimer, Handle hDP)
{
	DataPack hDataPack = view_as<DataPack>(hDP);
	hDataPack.Reset();
	int iClient = CID(hDataPack.ReadCell());
	int iLoadSerial = hDataPack.ReadCell();
	int iAttempt = hDataPack.ReadCell();
	char szFeature[FEATURE_NAME_LENGTH];
	hDataPack.ReadString(SZF(szFeature));
	
	DBG_Clients("Timer_CheckCookies -> iClient: %N (%d), IsClientVIP: %b, attempt: %d", iClient, iClient, g_ePlayer[iClient].bVIP, iAttempt);
	// Reloaded in the meantime: the new load waits on its own timer
	if (!iClient || !g_ePlayer[iClient].bVIP || iLoadSerial != g_iClientLoadSerial[iClient])
	{
		return Plugin_Stop;
	}

	if (!Features_IsStatusStoreReady(iClient) && ++iAttempt < STATUS_STORE_WAIT_ATTEMPTS)
	{
		Clients_WaitForStatusStore(iClient, szFeature, iAttempt);
		return Plugin_Stop;
	}

	Clients_LoadVIPFeaturesNow(iClient, szFeature);

	return Plugin_Stop;
}

void Clients_LoadVIPFeatures(int iClient)
{
	DBG_Clients("LoadVIPFeatures %N", iClient);

	int iFeatures = g_hFeaturesArray.Length;
	DBG_Clients("FeaturesArraySize: %d", iFeatures);
	if (iFeatures > 0)
	{
		char szFeature[FEATURE_NAME_LENGTH];

		g_ePlayer[iClient].hFeatures.GetString(KEY_GROUP, SZF(szFeature));
		if (UTIL_CheckValidVIPGroup(szFeature))
		{
			for (int i = 0; i < iFeatures; ++i)
			{
				g_hFeaturesArray.GetString(i, SZF(szFeature));
				Clients_LoadFeature(iClient, szFeature);
			}
		}
	}

	DBG_Clients("Clients_OnVIPClientLoaded: %d %N", iClient, iClient);

	Clients_OnVIPClientLoaded(iClient);
}

void Clients_LoadVIPFeature(int iClient, const char[] szFeature)
{
	DBG_Clients("LoadVIPFeature %N", iClient);

	int iFeatures = g_hFeaturesArray.Length;
	DBG_Clients("FeaturesArraySize: %d", iFeatures);
	if (iFeatures > 0)
	{
		char szGroup[FEATURE_NAME_LENGTH];

		g_ePlayer[iClient].hFeatures.GetString(KEY_GROUP, SZF(szGroup));
		if (UTIL_CheckValidVIPGroup(szGroup))
		{
			Clients_LoadFeature(iClient, szFeature);
		}
	}
/*
	DBG_Clients("Clients_OnVIPClientLoaded: %d %N", iClient, iClient);

	Clients_OnVIPClientLoaded(iClient);
	*/
}

// A group's feature changed at runtime: reload it for the in-game VIPs of that group
void Clients_ReloadGroupFeature(const char[] szGroup, const char[] szFeature)
{
	Feature eFeature;
	// Not registered yet: the new value is picked up when the module registers it
	if (!Features_Get(szFeature, eFeature))
	{
		return;
	}

	char szClientGroup[64];
	VIP_ToggleState eOldStatus, eNewStatus;
	for (int iClient = 1; iClient <= MaxClients; ++iClient)
	{
		if (
			!IsClientInGame(iClient) ||
			!g_ePlayer[iClient].bVIP ||
			!g_ePlayer[iClient].hFeatures.GetString(KEY_GROUP, SZF(szClientGroup)) ||
			strcmp(szClientGroup, szGroup) != 0
		)
		{
			continue;
		}

		eOldStatus = Features_GetStatus(iClient, szFeature);

		// GetValue only sets non-empty values, so the old one must go first or a removed/zeroed feature would stay
		g_ePlayer[iClient].hFeatures.Remove(szFeature);
		g_ePlayer[iClient].hFeatureStatus.Remove(szFeature);
		Clients_LoadVIPFeature(iClient, szFeature);

		eNewStatus = Features_GetStatus(iClient, szFeature);
		if (eFeature.eType == TOGGLABLE && eNewStatus != eOldStatus)
		{
			if (eFeature.fnSelect != INVALID_FUNCTION)
			{
				Function_OnItemToggle(eFeature.hPlugin, eFeature.fnSelect, iClient, szFeature, eOldStatus, eNewStatus);
			}
			CreateForward_OnFeatureToggle(iClient, szFeature, eOldStatus, eNewStatus);
		}
	}
}

void Clients_LoadFeature(int iClient, const char[] szFeature)
{
	Feature eFeature;
	if (!Features_Get(szFeature, eFeature))
	{
		return;
	}

	DBG_Clients("LoadClientFeature: %s", szFeature);

	if (!GetValue(iClient, eFeature.eValType, szFeature))
	{
		return;
	}

	static VIP_ToggleState eStatus;
	DBG_Clients("GetValue: == true");
	if (eFeature.eType == TOGGLABLE)
	{
		static char szBuffer[4];
		Features_GetSavedStatus(iClient, szFeature, eFeature.hCookie, SZF(szBuffer));
		eStatus = view_as<VIP_ToggleState>(StringToInt(szBuffer));
		DBG_Clients("GetSavedStatus: '%s'", szBuffer);
		if (szBuffer[0] == '\0' || !Features_IsValidStatus(eStatus))
		{
			switch(eFeature.eDefStatus)
			{
				case NO_ACCESS:	eStatus = g_CVAR_bDefaultStatus ? ENABLED : DISABLED;
				case ENABLED:	eStatus = ENABLED;
				case DISABLED:	eStatus = DISABLED;
			}

			// Persist the default only once the store is loaded, so it can't shadow a value that is still loading
			if (Features_IsStatusStoreReady(iClient))
			{
				Features_SaveStatus(iClient, szFeature, eFeature.hCookie, eStatus);
			}
		}
	}
	else
	{
		eStatus = ENABLED;
	}

	Features_SetStatus(iClient, szFeature, eStatus);
}

bool Features_IsValidStatus(VIP_ToggleState eStatus)
{
	return (
		eStatus == NO_ACCESS ||
		eStatus == ENABLED ||
		eStatus == DISABLED
	);
}

bool GetValue(int iClient, VIP_ValueType ValueType, const char[] szFeature)
{
	DBG_Clients("GetValue: %d - %s", ValueType, szFeature);
	switch (ValueType)
	{
		case VIP_NULL:
		{
			return false;
		}
		case BOOL:
		{
			if (g_hGroups.GetNum(szFeature))
			{
				DBG_Clients("value: 1");
				return g_ePlayer[iClient].hFeatures.SetValue(szFeature, true);
			}
			return false;
		}
		case INT:
		{
			int iValue;
			iValue = g_hGroups.GetNum(szFeature);
			if (iValue != 0)
			{
				DBG_Clients("value: %d", iValue);
				return g_ePlayer[iClient].hFeatures.SetValue(szFeature, iValue);
			}
			return false;
		}
		case FLOAT:
		{
			float fValue;
			fValue = g_hGroups.GetFloat(szFeature);
			if (fValue != 0.0)
			{
				DBG_Clients("value: %f", fValue);
				return g_ePlayer[iClient].hFeatures.SetValue(szFeature, fValue);
			}
			
			return false;
		}
		case STRING:
		{
			char szBuffer[256];
			g_hGroups.GetString(szFeature, SZF(szBuffer));
			if (szBuffer[0])
			{
				DBG_Clients("value: %s", szBuffer);
				return g_ePlayer[iClient].hFeatures.SetString(szFeature, szBuffer);
			}
			return false;
		}
	}

	return false;
}

void Clients_CreateExpiredTimer(int iClient, int iExp, int iTime)
{
	int iTimeLeft;
	GetMapTimeLeft(iTimeLeft);
	DBG_Clients("Clients_CreateExpiredTimer %N (%d):\tiTimeLeft: %d", iClient, iClient, iTimeLeft);
	if (iTimeLeft > 0)
	{
		DBG_Clients("Clients_CreateExpiredTimer %N (%d):\tiTimeLeft+iTime: %d", iClient, iClient, iTimeLeft + iTime);
		if ((iTimeLeft + iTime) > iExp)
		{
			DBG_Clients("Clients_CreateExpiredTimer %N (%d):\tTimerDealy: %f", iClient, iClient, float((iExp - iTime) + 3));
			
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
	DBG_Clients("Event_PlayerSpawn: %N (%d)", iClient, iClient);
	if (!g_ePlayer[iClient].bSpawned)
	{
		CreateTimer(g_CVAR_fSpawnDelay, Timer_OnPlayerSpawn, UserID, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public void Event_PlayerDeath(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
	int iClient = CID(hEvent.GetInt("userid"));
	DBG_Clients("Event_PlayerDeath: %N (%d)", iClient, iClient);
	g_ePlayer[iClient].bSpawned = false;
}

public Action Timer_OnPlayerSpawn(Handle hTimer, any UserID)
{
	int iClient = CID(UserID);
	if (iClient && IsClientInGame(iClient))
	{
		int iTeam = GetClientTeam(iClient);
		if (iTeam > 1 && IsPlayerAlive(iClient))
		{
			DBG_Clients("Timer_OnPlayerSpawn: %N (%d)", iClient, iClient);
			
			if (g_ePlayer[iClient].bVIP)
			{
				int iExp;
				if (g_ePlayer[iClient].hFeatures.GetValue(KEY_EXPIRES, iExp) && iExp > 0 && iExp < GetTime())
				{
					Clients_ExpiredClient(iClient);
				}
			}
			
			g_ePlayer[iClient].bSpawned = true;
			CreateForward_OnPlayerSpawn(iClient, iTeam);
		}
	}
	return Plugin_Stop;
}

public void Event_RoundEnd(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
	DBG_Clients("Event_RoundEnd");
	int iTime, iExp, i;
	iTime = GetTime();
	for (i = 1; i <= MaxClients; ++i)
	{
		if (IsClientInGame(i))
		{
			g_ePlayer[i].bSpawned = false;
			if (g_ePlayer[i].bVIP && g_ePlayer[i].hFeatures.GetValue(KEY_EXPIRES, iExp) && iExp > 0 && iExp < iTime)
			{
				Clients_ExpiredClient(i);
			}
		}
	}
}

public Action Timer_VIP_Expired(Handle hTimer, any UserID)
{
	DBG_Clients("Timer_VIP_Expired %d:", UserID);
	
	int iClient = CID(UserID);
	if (iClient && g_ePlayer[iClient].bVIP)
	{
		int iExp;
		if (g_ePlayer[iClient].hFeatures.GetValue(KEY_EXPIRES, iExp) && iExp > 0 && iExp < GetTime())
		{
			DBG_Clients("Timer_VIP_Expired %N:", iClient);
			
			Clients_ExpiredClient(iClient);
		}
	}

	return Plugin_Continue;
}

void Clients_ExpiredClient(int iClient)
{
	DBG_Clients("Clients_ExpiredClient %N:", iClient);
	
	int iClientID;
	g_ePlayer[iClient].hFeatures.GetValue(KEY_EXPIRES, iClientID);
	if (g_CVAR_iDeleteExpired == 0 || (g_CVAR_iDeleteExpired > 0 && GetTime() >= ((g_CVAR_iDeleteExpired*86400) + iClientID)))
	{
		if (g_ePlayer[iClient].hFeatures.GetValue(KEY_CID, iClientID) && iClientID != -1)
		{
			if (g_CVAR_bLogsEnable)
			{
				LogToFile(g_szLogFile, "%T", "REMOVING_PLAYER", LANG_SERVER, iClient);
			}
			
			DB_RemoveClientFromID(REASON_EXPIRED, iClient, _, false);
		}
	}
	
	if (g_ePlayer[iClient].bMenuOpen)
	{
		CancelClientMenu(iClient);
	}

	Clients_RemoveVIPStatus(iClient);
	
	CreateForward_OnVIPClientRemoved(iClient, "Expired");
	
	DisplayClientInfo(iClient, "expired_info");
}