
void ResetClient(int iClient)
{
	g_iClientInfo[iClient] &= ~IS_VIP;
	
	UTIL_CloseHandleEx(g_hFeatures[iClient]);
	UTIL_CloseHandleEx(g_hFeatureStatus[iClient]);
}

public void OnClientPutInServer(int iClient)
{
	//	g_iClientInfo[iClient] = 0;
	DebugMessage("OnClientPutInServer %N (%d): %b", iClient, iClient, g_iClientInfo[iClient])
	
	if(!IsFakeClient(iClient) && !IsClientSourceTV(iClient))
	{
		Clients_CheckVipAccess(iClient, true);
	}
}

public void OnClientDisconnect(int iClient)
{
	/*	if (g_bIsClientVIP[iClient])
	{
		SaveClient(iClient);
	}*/
	
	ResetClient(iClient);
	UTIL_CloseHandleEx(g_hClientData[iClient]);
	g_iClientInfo[iClient] = 0;
}

void Clients_CheckVipAccess(int iClient, bool bNotify = false)
{
	g_iClientInfo[iClient] &= ~IS_LOADED;
	
	ResetClient(iClient);
	
	if (IsFakeClient(iClient) == false && (GLOBAL_INFO & IS_STARTED) && g_hDatabase)
	{
		Clients_LoadClient(iClient, bNotify);
		//	DebugMessage("Clients_CheckVipAccess %N:\tИгрок %sявляется VIP игроком", iClient, g_bIsClientVIP[iClient] ? "":"не ")
	}
	else
	{
		g_iClientInfo[iClient] |= IS_LOADED;
		CreateForward_OnClientLoaded(iClient);
	}
}

void Clients_LoadClient(int iClient, bool bNotify)
{
	char sQuery[512];
	
	int iAccountID = GetSteamAccountID(iClient);

	DebugMessage("Clients_LoadClient %N (%d), %b: - > %x, %u", iClient, iClient, g_iClientInfo[iClient], g_hDatabase, g_hDatabase)

	if (GLOBAL_INFO & IS_MySQL)
	{
		FormatEx(sQuery, sizeof(sQuery), "SELECT `u`.`id`, \
												`o`.`expires`, \
												`o`.`group`, \
												`u`.`name` \
												FROM `vip_users` AS `u` \
												LEFT JOIN `vip_overrides` AS `o` \
												ON `o`.`user_id` = `u`.`id` \
												WHERE `o`.`server_id` = %d \
												AND `account_id` = %d LIMIT 1;",
												g_CVAR_iServerID, iAccountID);
	}
	else
	{
		FormatEx(sQuery, sizeof(sQuery), "SELECT `id`, `expires`, `group`, `name` \
											FROM `vip_users` \
											WHERE `account_id` = %d LIMIT 1;",
											iAccountID);
	}
	
	DataPack hDataPack = new DataPack();
	hDataPack.WriteCell(UID(iClient));
	hDataPack.WriteCell(bNotify);
	hDataPack.WriteCell(iAccountID);
	
	DebugMessage(sQuery)
	g_hDatabase.Query(SQL_Callback_OnClientAuthorized, sQuery, hDataPack);
}

public void SQL_Callback_OnClientAuthorized(Database hOwner, DBResultSet hResult, const char[] sError, any hPack)
{
	DataPack hDataPack = view_as<DataPack>(hPack);
	if (hResult == null || sError[0])
	{
		LogError("SQL_Callback_OnClientAuthorized: %s", sError);
		delete hDataPack;
		return;
	}
	
	hDataPack.Reset();
	
	int iClient = CID(hDataPack.ReadCell());
	DebugMessage("SQL_Callback_OnClientAuthorized: %d", iClient)
	if (iClient)
	{
		if (hResult.FetchRow())
		{
			int iExpires = hResult.FetchInt(1),
			iClientID = hResult.FetchInt(0);
			DebugMessage("Clients_LoadClient %N (%d):\texpires: %d", iClient, iClient, iExpires)
			if (iExpires > 0)
			{
				int iTime = GetTime();
				DebugMessage("Clients_LoadClient %N (%d):\tTime: %d", iClient, iClient, iTime)
				
				if (iTime > iExpires)
				{
					delete hDataPack;
					DebugMessage("Clients_LoadClient %N (%d):\tTime: %d", iClient, iClient, iTime)
					
					if (g_CVAR_iDeleteExpired == 0 || iTime >= ((g_CVAR_iDeleteExpired * 86400) + iExpires))
					{
						if (g_CVAR_bLogsEnable)
						{
							LogToFile(g_sLogFile, "%T", "REMOVING_PLAYER", LANG_SERVER, iClient);
						}
						
						DebugMessage("Clients_LoadClient %N (%d):\tDelete", iClient, iClient)
						
						char sName[MAX_NAME_LENGTH*2+1];
						hResult.FetchString(3, SZF(sName));
						DB_RemoveClientFromID(0, iClientID, false, sName);
					}

					CreateForward_OnVIPClientRemoved(iClient, "Expired");
					
					DisplayClientInfo(iClient, "expired_info");
					
					g_iClientInfo[iClient] |= IS_LOADED;
					CreateForward_OnClientLoaded(iClient);
					return;
				}
				
				Clients_CreateExpiredTimer(iClient, iExpires, iTime);
			}

			char sGroup[64];
			hResult.FetchString(2, SZF(sGroup));
			DebugMessage("Clients_LoadClient %N (%d):\tvip_group: %s", iClient, iClient, sGroup)
			if (sGroup[0] && UTIL_CheckValidVIPGroup(sGroup))
			{
				Clients_CreateClientVIPSettings(iClient, iExpires);

				g_hFeatures[iClient].SetValue(KEY_CID, iClientID);

				g_hFeatures[iClient].SetString(KEY_GROUP, sGroup);
				
				g_iClientInfo[iClient] |= IS_VIP;
				g_iClientInfo[iClient] |= IS_LOADED;

				CreateForward_OnClientLoaded(iClient);

				if (g_CVAR_bUpdateName)
				{
					DB_UpdateClientName(iClient);
				}

				if (hDataPack.ReadCell())
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
				hDataPack.ReadCell();
				int iAccountID = hDataPack.ReadCell();
				LogError("Invalid VIP-Group/Некорректная VIP-группа: %s (Игрок: %d)", sGroup, iAccountID);
			}
		}
		else
		{
			CreateForward_OnClientLoaded(iClient);
		}
	}
	
	delete hDataPack;
}

void Clients_OnVIPClientLoaded(int iClient)
{
	CreateForward_OnVIPClientLoaded(iClient);

	Features_TurnOnAll(iClient);
}

void Clients_CreateClientVIPSettings(int iClient, int iExp)
{
	/*
	g_hFeatures[iClient] = new StringMap();
	g_hFeatureStatus[iClient] = new StringMap();
	*/
	g_hFeatures[iClient] = CreateTrie();
	g_hFeatureStatus[iClient] = CreateTrie();

	g_hFeatures[iClient].SetValue(KEY_EXPIRES, iExp);
}

#if DEBUG_MODE 1
public void OnClientCookiesCached(int iClient)
{
	DebugMessage("OnClientCookiesCached %d %N", iClient, iClient)
	
	DebugMessage("AreClientCookiesCached %b", AreClientCookiesCached(iClient))
}
#endif

void Clients_LoadVIPFeaturesPre(int iClient, const char[] sFeatureName = NULL_STRING)
{
	DebugMessage("Clients_LoadVIPFeaturesPre %N", iClient)

	DebugMessage("AreClientCookiesCached %b", AreClientCookiesCached(iClient))

	if (!AreClientCookiesCached(iClient))
	{
		DataPack hDataPack = new DataPack();
		hDataPack.WriteCell(UID(iClient));
		if(sFeatureName[0])
		{
			hDataPack.WriteCell(true);
			hDataPack.WriteString(sFeatureName);
		}
		else
		{
			hDataPack.WriteCell(false);
		}
		CreateTimer(0.5, Timer_CheckCookies, hDataPack, TIMER_FLAG_NO_MAPCHANGE|TIMER_DATA_HNDL_CLOSE);
	}

	if(sFeatureName[0])
	{
		Clients_LoadVIPFeature(iClient, sFeatureName);
		return;
	}
	
	Clients_LoadVIPFeatures(iClient);
}

public Action Timer_CheckCookies(Handle hTimer, Handle hDP)
{
	DataPack hDataPack = view_as<DataPack>(hDP);
	hDataPack.Reset();
	int iClient = CID(hDataPack.ReadCell());
	
	DebugMessage("Timer_CheckCookies -> iClient: %N (%d), IsClientVIP: %b,", iClient, iClient, view_as<bool>(g_iClientInfo[iClient] & IS_VIP))
	if (iClient && g_iClientInfo[iClient] & IS_VIP)
	{
		char sFeatureName[FEATURE_NAME_LENGTH];
		if(hDataPack.ReadCell())
		{
			hDataPack.ReadString(SZF(sFeatureName));
		}
		else
		{
			sFeatureName[0] = 0;
		}
		Clients_LoadVIPFeaturesPre(iClient, sFeatureName);
	}

	return Plugin_Stop;
}

void Clients_LoadVIPFeatures(int iClient)
{
	DebugMessage("LoadVIPFeatures %N", iClient)

	int iFeatures = g_hFeaturesArray.Length;
	DebugMessage("FeaturesArraySize: %d", iFeatures)
	if (iFeatures > 0)
	{
		char sFeatureName[FEATURE_NAME_LENGTH];

		g_hFeatures[iClient].GetString(KEY_GROUP, SZF(sFeatureName));
		if (UTIL_CheckValidVIPGroup(sFeatureName))
		{
			for (int i = 0; i < iFeatures; ++i)
			{
				g_hFeaturesArray.GetString(i, SZF(sFeatureName));
				Clients_LoadFeature(iClient, sFeatureName);
			}
		}
	}

	DebugMessage("Clients_OnVIPClientLoaded: %d %N", iClient, iClient)

	Clients_OnVIPClientLoaded(iClient);
}

void Clients_LoadVIPFeature(int iClient, const char[] sFeatureName)
{
	DebugMessage("LoadVIPFeature %N", iClient)

	int iFeatures = g_hFeaturesArray.Length;
	DebugMessage("FeaturesArraySize: %d", iFeatures)
	if (iFeatures > 0)
	{
		char sGroup[FEATURE_NAME_LENGTH];

		g_hFeatures[iClient].GetString(KEY_GROUP, SZF(sGroup));
		if (UTIL_CheckValidVIPGroup(sGroup))
		{
			Clients_LoadFeature(iClient, sFeatureName);
		}
	}
/*
	DebugMessage("Clients_OnVIPClientLoaded: %d %N", iClient, iClient)

	Clients_OnVIPClientLoaded(iClient);
	*/
}

void Clients_LoadFeature(int iClient, const char[] sFeatureName)
{
	static ArrayList hArray;
	if (GLOBAL_TRIE.GetValue(sFeatureName, hArray))
	{
		DebugMessage("LoadClientFeature: %s", sFeatureName)

		if (GetValue(iClient, view_as<VIP_ValueType>(hArray.Get(FEATURES_VALUE_TYPE)), sFeatureName))
		{
			static VIP_ToggleState	eStatus;
			DebugMessage("GetValue: == true")
			if (view_as<VIP_FeatureType>(hArray.Get(FEATURES_ITEM_TYPE)) == TOGGLABLE)
			{
				static char	 			sBuffer[4];
				static Handle			hCookie;
				hCookie = view_as<Handle>(hArray.Get(FEATURES_COOKIE));
				GetClientCookie(iClient, hCookie, SZF(sBuffer));
				eStatus = view_as<VIP_ToggleState>(StringToInt(sBuffer));
				DebugMessage("GetFeatureCookie: '%s'", sBuffer)
				if (sBuffer[0] == '\0' || (view_as<int>(eStatus) > 2 || view_as<int>(eStatus) < 0))
				{
					switch(hArray.Get(FEATURES_DEF_STATUS))
					{
						case NO_ACCESS:		eStatus = g_CVAR_bDefaultStatus ? ENABLED:DISABLED;
						case ENABLED:		eStatus = ENABLED;
						case DISABLED:		eStatus = DISABLED;
					}

					IntToString(view_as<int>(eStatus), SZF(sBuffer));
					SetClientCookie(iClient, hCookie, sBuffer);
					//	Features_SaveStatus(iClient, sFeatureName, hCookie, eStatus);
				}
			}
			else
			{
				eStatus = ENABLED;
			}

			Features_SetStatus(iClient, sFeatureName, eStatus);
			//	Function_OnItemToggle(view_as<Handle>(hArray.Get(FEATURES_PLUGIN)), Function:hArray.Get(FEATURES_ITEM_SELECT), iClient, sFeatureName, NO_ACCESS, ENABLED);
		}
	}
}

bool GetValue(int iClient, VIP_ValueType ValueType, const char[] sFeatureName)
{
	DebugMessage("GetValue: %d - %s", ValueType, sFeatureName)
	switch (ValueType)
	{
		case VIP_NULL:
		{
			return false;
		}
		case BOOL:
		{
			if (g_hGroups.GetNum(sFeatureName))
			{
				DebugMessage("value: 1")
				return g_hFeatures[iClient].SetValue(sFeatureName, true);
			}
			return false;
		}
		case INT:
		{
			int iValue;
			iValue = g_hGroups.GetNum(sFeatureName);
			if (iValue != 0)
			{
				DebugMessage("value: %d", iValue)
				return g_hFeatures[iClient].SetValue(sFeatureName, iValue);
			}
			return false;
		}
		case FLOAT:
		{
			float fValue;
			fValue = g_hGroups.GetFloat(sFeatureName);
			if (fValue != 0.0)
			{
				DebugMessage("value: %f", fValue)
				return g_hFeatures[iClient].SetValue(sFeatureName, fValue);
			}
			
			return false;
		}
		case STRING:
		{
			char sBuffer[256];
			g_hGroups.GetString(sFeatureName, SZF(sBuffer));
			if (sBuffer[0])
			{
				DebugMessage("value: %s", sBuffer)
				return g_hFeatures[iClient].SetString(sFeatureName, sBuffer);
			}
			return false;
		}
		default:
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
	if (g_CVAR_iDeleteExpired != -1)
	{
		RemoveExpiredPlayers();
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
			CreateForward_OnPlayerSpawn(iClient, iTeam);
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
				LogToFile(g_sLogFile, "%T", "REMOVING_PLAYER", LANG_SERVER, iClient);
			}
			
			DB_RemoveClientFromID(0, iClientID, false);
		}
	}

	ResetClient(iClient);
	
	CreateForward_OnVIPClientRemoved(iClient, "Expired");
	
	DisplayClientInfo(iClient, "expired_info");
} 