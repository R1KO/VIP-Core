/*
SaveClient(iClient)
{
	DebugMessage("SaveClient %N", iClient)
	
	new iFeatures = GetArraySize(GLOBAL_ARRAY);
	if(iFeatures > 0)
	{
		decl String:sFeatureName[FEATURE_NAME_LENGTH],
			String:sBuffer[5],
			Handle:hArray,
			VIP_ToggleState:Status,
			i;

		for(i=0; i < iFeatures; i++)
		{
			GetArrayString(GLOBAL_ARRAY, i, sFeatureName, sizeof(sFeatureName));
			if(GetTrieValue(GLOBAL_TRIE, sFeatureName, hArray))
			{
				if(VIP_FeatureType:GetArrayCell(hArray, FEATURES_ITEM_TYPE) == TOGGLABLE)
				{
					if((Status = GetClientFeatureStatus(iClient, sFeatureName)) != NO_ACCESS)
					{
						IntToString(_:Status, sBuffer, sizeof(sBuffer));
						SetClientCookie(iClient, Handle:GetArrayCell(hArray, FEATURES_COOKIE), sBuffer);
					}
				}
			}
		}
	}
}
*/

ResetClient(iClient)
{
	g_bIsClientAuthorized[iClient] =
	g_bIsClientVIP[iClient] = false;
	CloseHandleEx(g_hFeatures[iClient]);
	CloseHandleEx(g_hFeatureStatus[iClient]);
	CloseHandleEx(g_ClientData[iClient]);
}

public OnClientPutInServer(iClient)
{
	g_bIsClientLoaded[iClient] = false;
}

public OnClientPostAdminCheck(iClient)
{
	DebugMessage("OnClientPostAdminCheck %N", iClient)

	CHECK_CLIENT_VIP_ACCESS(iClient, true);
}

public OnClientDisconnect(iClient)
{
/*	if(g_bIsClientVIP[iClient])
	{
		SaveClient(iClient);
	}*/

	ResetClient(iClient);
}

bool:CHECK_CLIENT_VIP_ACCESS(iClient, bool:bNotify = false)
{
	//ResetClient(iClient);
	
	g_bIsClientAuthorized[iClient] = false;
	
	if(IsFakeClient(iClient) == false)
	{
		g_bIsClientVIP[iClient] = CheckClientVIP(iClient);
		
		g_bIsClientLoaded[iClient] = true;

		DebugMessage("CHECK_CLIENT_VIP_ACCESS %N:\tИгрок %sявляется VIP игроком", iClient, g_bIsClientVIP[iClient] ? "":"не ")

		if(g_bIsClientVIP[iClient])
		{
			if(g_CVAR_bLogsEnable) LogToFile(g_sLogFile, "%T", "VIP_PLAYER_CONNECTED", LANG_SERVER, iClient);

			CreateForward_OnVIPClientLoaded(iClient);

			if(bNotify)
			{
				WelcomeMessage(iClient);
			}
			
			return true;
		}
		
	}

	return false;
}

WelcomeMessage(iClient)
{
	decl iExp;
	GetTrieValue(g_hFeatures[iClient], "expires", iExp);
	if(iExp == 0)
	{
		VIP_PrintToChatClient(iClient, "%t", "WELCOME_MSG_PERM", iClient);
	}
	else
	{
		decl String:sExpTime[100];
		FormatTime(sExpTime, sizeof(sExpTime), "%d/%m/%Y - %H:%M", iExp);
		VIP_PrintToChatClient(iClient, "%t", "WELCOME_MSG_TIME", iClient, sExpTime);
	}
}

bool:CheckClientVIP(iClient)
{
	DebugMessage("CheckClientVIP %N", iClient)

	decl String:sAuth[64];
	if((GetClientAuthString(iClient, sAuth, sizeof(sAuth)) && SearchClientInDB(iClient, sAuth, AUTH_STEAM)) == false)
	{
		if(SearchClientInDB(iClient, "ADMIN_FLAGS", AUTH_FLAGS) == false)
		{
			if(SearchClientInDB(iClient, "ADMIN_GROUPS", AUTH_GROUP) == false)
			{
				if((GetClientIP(iClient, sAuth, sizeof(sAuth)) && SearchClientInDB(iClient, sAuth, AUTH_IP)) == false)
				{
					return (SearchClientInDB(iClient, "NAMES", AUTH_NAME));
				}
			}
		}
	}

	return true;
}

bool:SearchClientInDB(iClient, const String:sAuth[], const VIP_AuthType:AuthType)
{
	DebugMessage("SearchClientOnDB %N:\tКлюч: %s Тип: %i", iClient, sAuth, AuthType)

	KvRewind(g_hUsers);
	if (KvJumpToKey(g_hUsers, sAuth, false))
	{
		DebugMessage("\tКлюч %s найден", sAuth)
		
		switch (AuthType)
		{
			case AUTH_STEAM, AUTH_IP:
			{
				DebugMessage("\tИдентификатор %s найден", sAuth)
				
				return LoadVIPClient(iClient, AuthType);
			}
			case AUTH_FLAGS: 
			{
				if (ReadFlags(iClient))
				{
					
					DebugMessage("\tФлаги найдены")
					
					return LoadVIPClient(iClient, AuthType);
				}
			}
			case AUTH_GROUP:
			{
				new AdminId:aid = GetUserAdmin(iClient);
				if (aid != INVALID_ADMIN_ID)
				{
					decl String:group[64];
					new iGroups = GetAdminGroupCount(aid);
					if(iGroups > 0)
					{
						for (new i = 0; i < iGroups; ++i)
						{
							if (GetAdminGroup(aid, i, group, sizeof(group)) != INVALID_GROUP_ID && KvJumpToKey(g_hUsers, group))
							{
								
								DebugMessage("\tГруппа %s найдена", group)
								
								return LoadVIPClient(iClient, AuthType);
							}
						}
					}
				}
			}
			case AUTH_NAME:
			{
				decl String:sName[MAX_NAME_LENGTH];
				if (GetClientName(iClient, sName, sizeof(sName)) && KvJumpToKey(g_hUsers, sName))
				{
					
					DebugMessage("\tИмя %s найдено", sName)
					
					return LoadVIPClient(iClient, AuthType);
				}
			}
		}
	}
	
	DebugMessage("SearchClientOnDB:\tfalse")

	return false;
}

bool:ReadFlags(iClient)
{
	DebugMessage("\tReadFlags (%N:%i)", iClient, iClient)

	if (KvGotoFirstSubKey(g_hUsers))
	{
		new iFlags = GetUserFlagBits(iClient);
		if(iFlags)
		{
			do
			{
				if (iFlags & KvGetNum(g_hUsers, "flags_bin")) return true;
			}
			while (KvGotoNextKey(g_hUsers));
		}
	}
	KvRewind(g_hUsers);
	
	return false;
}

bool:LoadVIPClient(iClient, const VIP_AuthType:AuthType)
{
	DebugMessage("LoadVIPClient %N", iClient)

	new iExp = KvGetNum(g_hUsers, "expires");
	DebugMessage("LoadVIPClient %N:\texpires: %i", iClient, iExp)
	
	if(iExp > 0)
	{
		new iTime = GetTime();
		DebugMessage("LoadVIPClient %N:\tTime: %i", iClient, iTime)
		
		if(iTime > iExp)
		{
			DebugMessage("LoadVIPClient %N:\tTime: %i", iClient, iTime)
			
			if(g_CVAR_bDeleteExpired)
			{
				DebugMessage("LoadVIPClient %N:\tDelete", iClient)

				KvGetSectionSymbol(g_hUsers, iExp);
				if(KvJumpToKeySymbol(g_hUsers, iExp))
				{
					KvDeleteThis(g_hUsers);
					UTIL_SaveUsers();
				}

				if(g_CVAR_bLogsEnable)
				{
					LogToFile(g_sLogFile, "%T", "REMOVING_PLAYER", LANG_SERVER, iClient);
					LogToFile(g_sLogFile, "VIP-игрок %L удален", iClient);
				}
			}

			CreateForward_OnVIPClientRemoved(iClient, "Expired");

			ShowClientInfo(iClient, INFO_EXPIRED);

			return false;
		}
		
		decl iTimeLeft;
		GetMapTimeLeft(iTimeLeft);
		DebugMessage("LoadVIPClient %N:\tiTimeLeft: %i", iClient, iTimeLeft)
		if(iTimeLeft > 0)
		{
			DebugMessage("LoadVIPClient %N:\tiTimeLeft+iTime: %i", iClient, iTimeLeft+iTime)
			if((iTimeLeft+iTime) > iExp)
			{
				new Float:fTimerDealy = float((iExp - iTime)+3);
				
				DebugMessage("LoadVIPClient %N:\tTimerDealy: %f", iClient, fTimerDealy)
				
				CreateTimer(fTimerDealy, Timer_VIP_Expired, GetClientUserId(iClient), TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}

	g_bIsClientAuthorized[iClient] = true;
	
	decl String:sBuffer[64];
	if(AuthType <= AUTH_IP)
	{
		GetClientName(iClient, sBuffer, sizeof(sBuffer));
		UTIL_EscapeString(sBuffer, sizeof(sBuffer));
		KvSetString(g_hUsers, "name", sBuffer);
		UTIL_SaveUsers();
	}

	KvGetString(g_hUsers, "password", sBuffer, sizeof(sBuffer));
	if(sBuffer[0])
	{
		DebugMessage("LoadVIPClient %N:\tpassword: %s", iClient, sBuffer)
		
		decl String:sClientCvar[64], String:sClientPass[64];
		KvGetString(g_hUsers, "client_cvar", sClientCvar, sizeof(sClientCvar), "vip");
		GetClientInfo(iClient, sClientCvar, sClientPass, sizeof(sClientPass));
		if(strcmp(sBuffer, sClientPass) != 0)
		{
			if(g_CVAR_bKickNotAuthorized)
			{
				KickClient(iClient, "%t", "INVALID_PASSWORD");
			}
			else
			{
				VIP_PrintToChatClient(iClient, "%t", "WAIT_PASSWORD");
				
				DebugMessage("LoadVIPClient %N:\tFailed password: %s", iClient, sClientPass)
				
				if(g_CVAR_bLogsEnable) LogToFile(g_sLogFile, "%T", "FAILED_AUTHORIZE", LANG_SERVER, iClient);
			}
			return false;
		}
	}

	CreateClientVIPSettings(iClient, iExp, AuthType);

	if(AuthType <= AUTH_NAME)
	{
		KvGetSectionSymbol(g_hUsers, iExp);
		SetTrieValue(g_hFeatures[iClient], "ClientID", iExp);
	}

	KvGetString(g_hUsers, "vip_group", sBuffer, sizeof(sBuffer));
	DebugMessage("LoadVIPClient %N:\tvip_group: %s", iClient, sBuffer)
	if(sBuffer[0] && UTIL_CheckValidVIPGroup(sBuffer))
	{
		SetTrieString(g_hFeatures[iClient], "vip_group", sBuffer);
		new Handle:hGroups = CloneHandle(g_hGroups);
		DebugMessage("LoadVIPClient %N:\t(kv: %u %x)", iClient, hGroups, hGroups)
		LoadVIPFeatures(iClient, hGroups);
		CloseHandle(hGroups);
	}

	LoadVIPFeatures(iClient, g_hUsers);
	
//	g_hMenu[iClient] = CreateVIPMenu(iClient);

	
	DebugMessage("LoadVIPClient %N:\tgroup: %s", iClient, sBuffer)
	

	return true;
}

CreateClientVIPSettings(iClient, iExp, VIP_AuthType:AuthType = AUTH_STEAM)
{
	g_hFeatures[iClient] = CreateTrie();
	g_hFeatureStatus[iClient] = CreateTrie();

	SetTrieValue(g_hFeatures[iClient], "expires", iExp);
	SetTrieValue(g_hFeatures[iClient], "AuthType", AuthType);
}

public Action:Timer_VIP_Expired(Handle:hTimer, any:UserId)
{
	DebugMessage("Timer_VIP_Expired %i:", UserId)
	
	new iClient = GetClientOfUserId(UserId);
	if(iClient)
	{
		DebugMessage("Timer_VIP_Expired %N:", iClient)
		
		CHECK_CLIENT_VIP_ACCESS(iClient, true);
	}
}

LoadVIPFeatures(iClient, Handle:hKeyValues)
{
	DebugMessage("LoadVIPFeatures %N", iClient)

	new iFeatures = GetArraySize(GLOBAL_ARRAY);
	if(iFeatures > 0)
	{
		DebugMessage("FeaturesArraySize: %i", iFeatures)
		

		decl String:sFeatureName[FEATURE_NAME_LENGTH],
			String:sBuffer[64],
			Handle:hArray,
			Handle:hCookie,
			iStatus,
			i;
		
		for(i=0; i < iFeatures; ++i)
		{
			GetArrayString(GLOBAL_ARRAY, i, sFeatureName, sizeof(sFeatureName));
			if(GetTrieValue(GLOBAL_TRIE, sFeatureName, hArray))
			{
				DebugMessage("LoadClientFeature: %i - %s", i, sFeatureName)

				if(GetValue(iClient, VIP_ValueType:GetArrayCell(hArray, FEATURES_VALUE_TYPE), hKeyValues, sFeatureName))
				{
					DebugMessage("GetValue: == true")
					if(VIP_FeatureType:GetArrayCell(hArray, FEATURES_ITEM_TYPE) == TOGGLABLE)
					{
						hCookie = Handle:GetArrayCell(hArray, FEATURES_COOKIE);

						GetClientCookie(iClient, hCookie, sBuffer, sizeof(sBuffer));
						if(sBuffer[0])
						{
							StringToIntEx(sBuffer, iStatus);
							if(2 >= iStatus >= 0)
							{
								SetClientFeatureStatus(iClient, sFeatureName, VIP_ToggleState:iStatus);
								continue;
							}
						}

						IntToString(_:ENABLED, sBuffer, sizeof(sBuffer));
						SetClientCookie(iClient, hCookie, sBuffer);
					}

					SetClientFeatureStatus(iClient, sFeatureName, ENABLED);
				}
			}
		}
	}
}

bool:GetValue(const &iClient, VIP_ValueType:ValueType, Handle:hKeyValues, const String:sFeatureName[])
{
	DebugMessage("GetValue: %i - %s", ValueType, sFeatureName)
	switch(ValueType)
	{
		case VIP_NULL:
		{
			return false;
		}
		case BOOL:
		{
			if(bool:KvGetNum(hKeyValues, sFeatureName))
			{
				DebugMessage("return true")
				return SetTrieValue(g_hFeatures[iClient], sFeatureName, true);
			}
			return false;
		}
		case INT:
		{
			decl iValue;
			iValue = KvGetNum(hKeyValues, sFeatureName);
			DebugMessage("INT: %i", iValue)
			if(iValue != 0)
			{
				DebugMessage("return true")
				return SetTrieValue(g_hFeatures[iClient], sFeatureName, iValue);
			}
			return false;
		}
		case FLOAT:
		{
			decl Float:fValue;
			fValue = KvGetFloat(hKeyValues, sFeatureName);
			DebugMessage("FLOAT: %f", fValue)
			if(fValue != 0.0)
			{
				DebugMessage("return true")
				return SetTrieValue(g_hFeatures[iClient], sFeatureName, fValue);
			}
			
			return false;
		}
		case STRING:
		{
			decl String:sBuffer[256];
			KvGetString(hKeyValues, sFeatureName, sBuffer, sizeof(sBuffer));
			DebugMessage("STRING: %s", sBuffer)
			if(sBuffer[0])
			{
				DebugMessage("return true")
				return SetTrieString(g_hFeatures[iClient], sFeatureName, sBuffer);
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

public Event_RoundEnd(Handle:hEvent, const String:name[], bool:dontBroadcast)
{
	decl iTime, iExp, i;
	iTime = GetTime();
	for(i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && g_bIsClientVIP[i] && GetTrieValue(g_hFeatures[i], "expires", iExp))
		{
			if(0 < iExp < iTime)
			{
				CHECK_CLIENT_VIP_ACCESS(i, true);
			}
		}
	}
}