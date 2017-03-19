
void ResetClient(int iClient)
{
	g_iClientInfo[iClient] &= ~IS_VIP;
	
	UTIL_CloseHandleEx(g_hFeatures[iClient]);
	UTIL_CloseHandleEx(g_hFeatureStatus[iClient]);
}

public OnClientPutInServer(iClient)
{
	//	g_iClientInfo[iClient] = 0;
	DebugMessage("OnClientPostAdminCheck %N (%i): %b", iClient, iClient, g_iClientInfo[iClient])
	
	Clients_CheckVipAccess(iClient, true);
}

public OnClientDisconnect(iClient)
{
	/*	if(g_bIsClientVIP[iClient])
	{
		SaveClient(iClient);
	}*/
	
	ResetClient(iClient);
	UTIL_CloseHandleEx(g_ClientData[iClient]);
	g_iClientInfo[iClient] = 0;
}

void Clients_CheckVipAccess(int iClient, bool bNotify = false)
{
	g_iClientInfo[iClient] &= ~IS_LOADED;
	
	ResetClient(iClient);
	
	if (IsFakeClient(iClient) == false && (GLOBAL_INFO & IS_STARTED) && g_hDatabase)
	{
		Clients_LoadClient(iClient, bool bNotify);
		//	DebugMessage("Clients_CheckVipAccess %N:\tИгрок %sявляется VIP игроком", iClient, g_bIsClientVIP[iClient] ? "":"не ")
	}
	else
	{
		g_iClientInfo[iClient] |= IS_LOADED;
		CreateForward_OnClientLoaded(iClient);
	}
}

void Clients_LoadClient(iClient, bool bNotify)
{
	char sQuery[512]; char sAuth[32]; char sName[MAX_NAME_LENGTH * 2 + 1]; char sIP[24];
	
	GetClientAuthId(iClient, AuthId_Engine, sAuth, sizeof(sAuth));
	
	GetClientIP(iClient, sIP, sizeof(sIP));
	GetClientName(iClient, sQuery, sizeof(sQuery));
	
	DebugMessage("Clients_LoadClient %N (%i), %b: - > %x, %u", iClient, iClient, g_iClientInfo[iClient], g_hDatabase, g_hDatabase)
	g_hDatabase.Escape(sQuery, sName, sizeof(sName));
	
	if (GLOBAL_INFO & IS_MySQL)
	{
		FormatEx(sQuery, sizeof(sQuery), "SELECT `u`.`id`, \
												`o`.`expires`, \
												`o`.`group` \
												FROM `vip_users` AS `u` \
												LEFT JOIN `vip_overrides` AS `o` \
												ON `o`.`user_id` = `u`.`id` \
												WHERE `o`.`server_id` = '%i' \
												AND `auth` = '%s' LIMIT 1;",
												g_CVAR_iServerID, sAuth, sIP, sName);
	}
	else
	{
		FormatEx(sQuery, sizeof(sQuery), "SELECT `id`, `expires`, `group` \
											FROM `vip_users` \
											WHERE `auth` = '%s' LIMIT 1;",
											sAuth, sIP, sName);
	}
	
	DataPack hDataPack = new DataPack();
	hDataPack.WriteCell(UID(iClient));
	hDataPack.WriteCell(bNotify);
	hDataPack.WriteString(sAuth);
	
	DebugMessage(sQuery)
	g_hDatabase.Query(SQL_Callback_OnClientAuthorized, sQuery, hDataPack);
}

public void SQL_Callback_OnClientAuthorized(Handle hOwner, Handle hQuery, const char[] sError, any hPack)
{
	DataPack hDataPack = view_as<DataPack>(hPack);
	if (hQuery == null || sError[0])
	{
		LogError("SQL_Callback_OnClientAuthorized: %s", sError);
		delete hDataPack;
		return;
	}
	
	hDataPack.Reset();
	
	int iClient = CID(hDataPack.ReadCell());
	DebugMessage("SQL_Callback_OnClientAuthorized: %i", iClient)
	if (iClient)
	{
		if ((hQuery).FetchRow())
		{
			int iExpires = hQuery.FetchInt(1),
			iClientID = hQuery.FetchInt(0);
			DebugMessage("Clients_LoadClient %N (%i):\texpires: %i", iClient, iClient, iExpires)
			if (iExpires > 0)
			{
				int iTime = GetTime();
				DebugMessage("Clients_LoadClient %N (%i):\tTime: %i", iClient, iClient, iTime)
				
				if (iTime > iExpires)
				{
					delete hDataPack;
					DebugMessage("Clients_LoadClient %N (%i):\tTime: %i", iClient, iClient, iTime)
					
					if (g_CVAR_iDeleteExpired == 0 || iTime >= ((g_CVAR_iDeleteExpired * 86400) + iExpires))
					{
						if (g_CVAR_bLogsEnable)
						{
							LogToFile(g_sLogFile, "%T", "REMOVING_PLAYER", LANG_SERVER, iClient);
						}
						
						DebugMessage("Clients_LoadClient %N (%i):\tDelete", iClient, iClient)
						
						DB_RemoveClientFromID(0, iClientID, false);
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
			hQuery.FetchString(2, sGroup, sizeof(sGroup));
			DebugMessage("Clients_LoadClient %N (%i):\tvip_group: %s", iClient, iClient, sGroup)
			if (sGroup[0] && UTIL_CheckValidVIPGroup(sGroup))
			{
				Clients_CreateClientVIPSettings(iClient, iExpires);

				g_hFeatures[iClient].SetValue(KEY_CID, iClientID);

				g_hFeatures[iClient].SetString(KEY_GROUP, sGroup);
				DebugMessage("AreClientCookiesCached %b", AreClientCookiesCached(iClient))
				if (AreClientCookiesCached(iClient))
				{
					Clients_LoadVIPFeatures(iClient);
				}
				else
				{
					CreateTimer(1.0, Timer_CheckCookies, UID(iClient), TIMER_FLAG_NO_MAPCHANGE);
				}
				
				g_iClientInfo[iClient] |= IS_VIP;
				g_iClientInfo[iClient] |= IS_LOADED;

				CreateForward_OnClientLoaded(iClient);
				Clients_OnVIPClientLoaded(iClient);

				if (g_CVAR_bUpdateName)
				{
					DB_UpdateClientName(iClient);
				}

				if (hDataPack.ReadCell())
				{
					if(g_CVAR_bAutoOpenMenu)
					{
						DisplayMenu(g_hVIPMenu, iClient, MENU_TIME_FOREVER);
					}

					DisplayClientInfo(iClient, iExpires == 0 ? "connect_info_perm":"connect_info_time");
				}
			}
			else
			{
				hDataPack.ReadCell();
				char sAuth[32];
				hDataPack.ReadString(sAuth, sizeof(sAuth));
				LogError("Invalid VIP-Group/Некорректная VIP-группа: %s (Игрок: %s)", sGroup, sAuth);
			}
		}
		else
		{
			CreateForward_OnClientLoaded(iClient);
		}
	}
	
	delete hDataPack;
}

public Action Timer_CheckCookies(Handle hTimer, any UserID)
{
	int iClient = CID(UserID);
	DebugMessage("Timer_CheckCookies -> UserID: %i, iClient: %i, IsClientVIP: %b,", UserID, iClient, g_bIsClientVIP[iClient])
	if (iClient && g_iClientInfo[iClient] & IS_VIP)
	{
		DebugMessage("AreClientCookiesCached %b", AreClientCookiesCached(iClient))
		if (AreClientCookiesCached(iClient))
		{
			Clients_LoadVIPFeatures(iClient);
			
			return Plugin_Stop;
		}
		
		CreateTimer(1.0, Timer_CheckCookies, UserID, TIMER_FLAG_NO_MAPCHANGE);
	}
	
	return Plugin_Stop;
}

void Clients_OnVIPClientLoaded(int iClient)
{
	CreateForward_OnVIPClientLoaded(iClient);
	
	Features_TurnOnAll(iClient);
}

void Clients_CreateClientVIPSettings(int iClient, int iExp)
{
	g_hFeatures[iClient] = new StringMap();
	g_hFeatureStatus[iClient] = new StringMap();

	g_hFeatures[iClient].SetValue(KEY_EXPIRES, iExp);
}

#if DEBUG_MODE 1

public void OnClientCookiesCached(int iClient)
{
	DebugMessage("OnClientCookiesCached %i %N", iClient, iClient)
	
	DebugMessage("AreClientCookiesCached %b", AreClientCookiesCached(iClient))
}
#endif

void Clients_LoadVIPFeatures(int iClient)
{
	DebugMessage("LoadVIPFeatures %N", iClient)
	
	DebugMessage("AreClientCookiesCached %b", AreClientCookiesCached(iClient))

	int iFeatures = g_hFeaturesArray.Length;
	DebugMessage("FeaturesArraySize: %i", iFeatures)
	if (iFeatures > 0)
	{
		char sFeatureName[FEATURE_NAME_LENGTH];

		g_hFeatures[iClient].GetString(KEY_GROUP, sFeatureName, sizeof(sFeatureName));
		if (UTIL_CheckValidVIPGroup(sFeatureName))
		{
			char				sBuffer[4];
			Handle				hCookie;
			VIP_ToggleState		Status;
			ArrayList hArray;
			for (int i = 0; i < iFeatures; ++i)
			{
				g_hFeaturesArray.GetString(i, SZF(sFeatureName));
				if(GLOBAL_TRIE.GetValue(sFeatureName, hArray))
				{
					DebugMessage("LoadClientFeature: %i - %s", i, sFeatureName)

					if(GetValue(iClient, view_as<VIP_ValueType>(hArray.Get(FEATURES_VALUE_TYPE)), sFeatureName))
					{
						DebugMessage("GetValue: == true")
						if(view_as<VIP_FeatureType>(hArray.Get(FEATURES_ITEM_TYPE)) == TOGGLABLE)
						{
							hCookie = view_as<Handle>(hArray.Get(FEATURES_COOKIE));
							GetClientCookie(iClient, hCookie, SZF(sBuffer));
							DebugMessage("GetFeatureCookie: %s", sBuffer)
							if (sBuffer[0] == '\0' ||
								(StringToIntEx(sBuffer, _:Status) &&
								(_:Status > 2 || _:Status < 0)))
							{
								Status = ENABLED;
								IntToString(_:Status, SZF(sBuffer));
								SetClientCookie(iClient, hCookie, sBuffer);
								//	Features_SaveStatus(iClient, sFeatureName, hCookie, Status);
							}
						}
						else
						{
							Status = ENABLED;
						}
						
						Features_SetStatus(iClient, sFeatureName, Status);
						//	Function_OnItemToggle(view_as<Handle>(hArray.Get(FEATURES_PLUGIN)), Function:hArray.Get(FEATURES_ITEM_SELECT), iClient, sFeatureName, NO_ACCESS, ENABLED);
					}
				}
			}
		}
	}
}

bool GetValue(int iClient, VIP_ValueType ValueType, const char[] sFeatureName)
{
	DebugMessage("GetValue: %i - %s", ValueType, sFeatureName)
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
				DebugMessage("value: %i", iValue)
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
			g_hGroups.GetString(sFeatureName, sBuffer, sizeof(sBuffer));
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
	DebugMessage("Clients_CreateExpiredTimer %N (%i):\tiTimeLeft: %i", iClient, iClient, iTimeLeft)
	if (iTimeLeft > 0)
	{
		DebugMessage("Clients_CreateExpiredTimer %N (%i):\tiTimeLeft+iTime: %i", iClient, iClient, iTimeLeft + iTime)
		if ((iTimeLeft + iTime) > iExp)
		{
			DebugMessage("Clients_CreateExpiredTimer %N (%i):\tTimerDealy: %f", iClient, iClient, float((iExp - iTime) + 3))
			
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
	DebugMessage("Event_PlayerSpawn: %N (%i)", iClient, iClient)
	if (!(g_iClientInfo[iClient] & IS_SPAWNED))
	{
		CreateTimer(g_CVAR_fSpawnDelay, Timer_OnPlayerSpawn, UserID, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public void Event_PlayerDeath(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
	int iClient = CID(hEvent.GetInt("userid"));
	DebugMessage("Event_PlayerDeath: %N (%i)", iClient, iClient)
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
			DebugMessage("Timer_OnPlayerSpawn: %N (%i)", iClient, iClient)
			
			if (g_iClientInfo[iClient] & IS_VIP)
			{
				decl iExp;
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
	DebugMessage("Timer_VIP_Expired %i:", UserID)
	
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
			if(g_CVAR_bLogsEnable)
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