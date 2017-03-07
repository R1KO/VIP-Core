
CreateForwards()
{
	// Global Forwards
	g_hGlobalForward_OnVIPLoaded					= CreateGlobalForward("VIP_OnVIPLoaded", ET_Ignore);
	g_hGlobalForward_OnClientLoaded					= CreateGlobalForward("VIP_OnClientLoaded", ET_Ignore, Param_Cell, Param_Cell);
	g_hGlobalForward_OnVIPClientLoaded				= CreateGlobalForward("VIP_OnVIPClientLoaded", ET_Ignore, Param_Cell);
	g_hGlobalForward_OnVIPClientAdded				= CreateGlobalForward("VIP_OnVIPClientAdded", ET_Ignore, Param_Cell, Param_Cell);
	g_hGlobalForward_OnVIPClientRemoved				= CreateGlobalForward("VIP_OnVIPClientRemoved", ET_Ignore, Param_Cell, Param_String);
	g_hGlobalForward_OnPlayerSpawn					= CreateGlobalForward("VIP_OnPlayerSpawn", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
}

// Global Forwards
CreateForward_OnVIPLoaded()
{
	Call_StartForward(g_hGlobalForward_OnVIPLoaded);
	Call_Finish();
}

CreateForward_OnClientLoaded(iClient)
{
	Call_StartForward(g_hGlobalForward_OnClientLoaded);
	Call_PushCell(iClient);
	Call_PushCell(g_iClientInfo[iClient] & IS_VIP);
	Call_Finish();
}

CreateForward_OnVIPClientLoaded(iClient)
{
	Call_StartForward(g_hGlobalForward_OnVIPClientLoaded);
	Call_PushCell(iClient);
	Call_Finish();
}

CreateForward_OnVIPClientAdded(iAdmin, iClient)
{
	Call_StartForward(g_hGlobalForward_OnVIPClientAdded);
	Call_PushCell(iAdmin);
	Call_PushCell(iClient);
	Call_Finish();
}

CreateForward_OnVIPClientRemoved(iClient, const String:sReason[])
{
	Call_StartForward(g_hGlobalForward_OnVIPClientRemoved);
	Call_PushCell(iClient);
	Call_PushString(sReason);
	Call_Finish();
}

CreateForward_OnPlayerSpawn(iClient, iTeam)
{
	Call_StartForward(g_hGlobalForward_OnPlayerSpawn);
	Call_PushCell(iClient);
	Call_PushCell(iTeam);
	Call_PushCell(g_iClientInfo[iClient] & IS_VIP);
	Call_Finish();
}

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max) 
{
	// Global
	CreateNative("VIP_IsVIPLoaded",				Native_IsVIPLoaded);

	CreateNative("VIP_GetDatabase",				Native_GetDatabase);
	CreateNative("VIP_GetDatabaseType",			Native_GetDatabaseType);

	// Features
	CreateNative("VIP_RegisterFeature",			Native_RegisterFeature);
	CreateNative("VIP_UnregisterFeature",		Native_UnregisterFeature);
	CreateNative("VIP_IsValidFeature",			Native_IsValidFeature);

	// Clients
	CreateNative("VIP_SetClientVIP",			Native_SetClientVIP);
	CreateNative("VIP_RemoveClientVIP",			Native_RemoveClientVIP);

	CreateNative("VIP_CheckClient",				Native_CheckClient);
	CreateNative("VIP_IsClientVIP",				Native_IsClientVIP);

	CreateNative("VIP_GetClientID",				Native_GetClientID);

	CreateNative("VIP_GetClientVIPGroup",		Native_GetClientVIPGroup);
	CreateNative("VIP_SetClientVIPGroup",		Native_SetClientVIPGroup);
	
	CreateNative("VIP_GetClientAccessTime",		Native_GetClientAccessTime);
	CreateNative("VIP_SetClientAccessTime",		Native_SetClientAccessTime);

	CreateNative("VIP_GetVIPClientTrie",		Native_GetVIPClientTrie);
	
	CreateNative("VIP_GetClientAuthType",		Native_GetClientAuthType);

	CreateNative("VIP_SendClientVIPMenu",		Native_SendClientVIPMenu);

	CreateNative("VIP_IsValidVIPGroup",			Native_IsValidVIPGroup);

	CreateNative("VIP_GetClientFeatureStatus",	Native_GetClientFeatureStatus);
	CreateNative("VIP_SetClientFeatureStatus",	Native_SetClientFeatureStatus);
	
	CreateNative("VIP_IsClientFeatureUse",		Native_IsClientFeatureUse);

	CreateNative("VIP_GetClientFeatureInt",		Native_GetClientFeatureInt);
	CreateNative("VIP_GetClientFeatureFloat",	Native_GetClientFeatureFloat);
	CreateNative("VIP_GetClientFeatureBool",	Native_GetClientFeatureBool);
	CreateNative("VIP_GetClientFeatureString",	Native_GetClientFeatureString);

//	CreateNative("VIP_GiveClientFeature",	Native_GiveClientFeature);
	
	// Helpers
	CreateNative("VIP_PrintToChatClient",		Native_PrintToChatClient);
	CreateNative("VIP_PrintToChatAll",			Native_PrintToChatAll);
	CreateNative("VIP_LogMessage",				Native_LogMessage);
	CreateNative("VIP_TimeToSeconds",			Native_TimeToSeconds);
	CreateNative("VIP_SecondsToTime",			Native_SecondsToTime);
	CreateNative("VIP_GetTimeFromStamp",		Native_GetTimeFromStamp);
	CreateNative("VIP_AddStringToggleStatus",	Native_AddStringToggleStatus);

	MarkNativeAsOptional("BfWriteByte");
	MarkNativeAsOptional("BfWriteString");
	MarkNativeAsOptional("PbSetInt");
	MarkNativeAsOptional("PbSetBool");
	MarkNativeAsOptional("PbSetString");
	MarkNativeAsOptional("PbAddString");

	RegPluginLibrary("vip_core");

	return APLRes_Success; 
}

public Native_CheckClient(Handle:hPlugin, iNumParams)
{
	decl iClient;
	iClient = GetNativeCell(1);
	if(CheckValidClient(iClient, false))
	{
		Clients_CheckVipAccess(iClient, bool:GetNativeCell(2));
	}
}

public Native_IsClientVIP(Handle:hPlugin, iNumParams)
{
	decl iClient;
	iClient = GetNativeCell(1);
	if(CheckValidClient(iClient, false))
	{
		return bool:(g_iClientInfo[iClient] & IS_VIP);
	}

	return false;
}

public Native_PrintToChatClient(Handle:hPlugin, iNumParams)
{
	new iClient = GetNativeCell(1);
	if(CheckValidClient(iClient, false))
	{
		decl String:sMessage[256];
		SetGlobalTransTarget(iClient);
		FormatNativeString(0, 2, 3, sizeof(sMessage), _, sMessage);
	//	Format(sMessage, sizeof(sMessage), "%t%s", "VIP_CHAT_PREFIX", sMessage);
		
		Print(iClient, sMessage);
		
	//	PrintToChat(iClient, "%t%s", "VIP_CHAT_PREFIX", sMessage);
	}
}

public Native_PrintToChatAll(Handle:hPlugin, iNumParams)
{
	decl i, String:sMessage[256];

	for (i = 1; i <= MaxClients; ++i)
	{
		if (IsClientInGame(i) && IsFakeClient(i) == false)
		{
			SetGlobalTransTarget(i);
			FormatNativeString(0, 1, 2, sizeof(sMessage), _, sMessage);
			Print(i, sMessage);
		//	PrintToChat(i, "%t%s", "VIP_CHAT_PREFIX", sMessage);
		}
	}
}

Print(iClient, const String:sFormat[])
{
	decl String:sMessage[256];
	FormatEx(sMessage, sizeof(sMessage), g_EngineVersion == Engine_CSGO ? " \x01%t %s":"\x01%t %s", "VIP_CHAT_PREFIX", sFormat);
	
	ReplaceString(sMessage, sizeof(sMessage), "\\n", "\n");
	ReplaceString(sMessage, sizeof(sMessage), "{DEFAULT}", "\x01");
	ReplaceString(sMessage, sizeof(sMessage), "{GREEN}", "\x04");

	switch(g_EngineVersion)
	{
		case Engine_SourceSDK2006:
		{
			ReplaceString(sMessage, sizeof(sMessage), "{LIGHTGREEN}", "\x03");
			new iColor = ReplaceColors(sMessage, sizeof(sMessage));
			switch(iColor)
			{
				case -1:	SayText2(iClient, 0, sMessage);
				case 0:		SayText2(iClient, iClient, sMessage);
				default:
				{
					SayText2(iClient, FindPlayerByTeam(iColor), sMessage);
				}
			}
		}
		case Engine_CSS, Engine_TF2, Engine_DODS, Engine_HL2DM:
		{
			ReplaceString(sMessage, sizeof(sMessage), "#", "\x07");
			if(ReplaceString(sMessage, sizeof(sMessage), "{TEAM}", "\x03"))
			{
				SayText2(iClient, iClient, sMessage);
			}
			else
			{
				ReplaceString(sMessage, sizeof(sMessage), "{LIGHTGREEN}", "\x03");
				SayText2(iClient, 0, sMessage);
			}
		}
		case Engine_CSGO:
		{
			static const	String:sColorName[][] =
							{
								"{RED}",
								"{LIME}",
								"{LIGHTGREEN}",
								"{LIGHTRED}",
								"{GRAY}",
								"{LIGHTOLIVE}",
								"{OLIVE}",
								"{LIGHTBLUE}",
								"{BLUE}", 
								"{PURPLE}"
							},
							String:sColorCode[][] =
							{
								"\x02",
							    "\x05",
							    "\x06",
							    "\x07",
							    "\x08",
							    "\x09",
							    "\x10",
							    "\x0B",
							    "\x0C",
							    "\x0E"
							};

			for(new i = 0; i < sizeof(sColorName); ++i)
			{
				ReplaceString(sMessage, sizeof(sMessage), sColorName[i], sColorCode[i]);
			}
			
			if(ReplaceString(sMessage, sizeof(sMessage), "{TEAM}", "\x03"))
			{
				SayText2(iClient, iClient, sMessage);
			}
			else
			{
				SayText2(iClient, 0, sMessage);
			}
		}
		default:
		{
			ReplaceString(sMessage, sizeof(sMessage), "{TEAM}",	"\x03");
		}
	}
}

ReplaceColors(String:sMsg[], MaxLength)
{
	if(ReplaceString(sMsg, MaxLength, "{TEAM}",	"\x03"))	return 0;

	if(ReplaceString(sMsg, MaxLength, "{BLUE}",	"\x03"))	return 3;
	if(ReplaceString(sMsg, MaxLength, "{RED}",	"\x03"))	return 2;
	if(ReplaceString(sMsg, MaxLength, "{GRAY}",	"\x03"))	return 1;

	return -1;
}

FindPlayerByTeam(iTeam)
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == iTeam) return i;
	}

	return 0;
}

SayText2(iClient, iAuthor = 0, const String:sMessage[])
{
	decl iClients[1], Handle:hBuffer;
	iClients[0] = iClient;
	hBuffer = StartMessage("SayText2", iClients, 1, USERMSG_RELIABLE|USERMSG_BLOCKHOOKS);
	if(GetUserMessageType() == UM_Protobuf)
	{
		PbSetInt(hBuffer, "ent_idx", iAuthor);
		PbSetBool(hBuffer, "chat", true);
		PbSetString(hBuffer, "msg_name", sMessage);
		PbAddString(hBuffer, "params", "");
		PbAddString(hBuffer, "params", "");
		PbAddString(hBuffer, "params", "");
		PbAddString(hBuffer, "params", "");
	}
	else
	{
		BfWriteByte(hBuffer, iAuthor);
		BfWriteByte(hBuffer, true);
		BfWriteString(hBuffer, sMessage);
	}
	EndMessage();
}

public Native_LogMessage(Handle:hPlugin, iNumParams)
{
	if(g_CVAR_bLogsEnable)
	{
		decl String:sMessage[512];
		SetGlobalTransTarget(LANG_SERVER);
		FormatNativeString(0, 1, 2, sizeof(sMessage), _, sMessage);
		
		LogToFile(g_sLogFile, sMessage);
	}
}

public Native_GetClientID(Handle:hPlugin, iNumParams)
{
	decl iClient;
	iClient = GetNativeCell(1);
	if(CheckValidClient(iClient))
	{
		decl iClientID;
		if(GetTrieValue(g_hFeatures[iClient], KEY_CID, iClientID))
		{
			return iClientID;
		}
	}

	return -1;
}

public Native_GetClientVIPGroup(Handle:hPlugin, iNumParams)
{
	decl iClient;
	iClient = GetNativeCell(1);
	if(CheckValidClient(iClient))
	{
		decl String:sGroup[64];
		
		sGroup[0] = 0;

		if(GetTrieString(g_hFeatures[iClient], KEY_GROUP, sGroup, sizeof(sGroup)))
		{
			SetNativeString(2, sGroup, GetNativeCell(3), true);
			return true;
		}
	}
	return false;
}

public Native_SetClientVIPGroup(Handle:hPlugin, iNumParams)
{
	decl iClient;
	iClient = GetNativeCell(1);
	if(CheckValidClient(iClient))
	{
		decl String:sGroup[64];
		GetNativeString(2, sGroup, sizeof(sGroup));
		if(UTIL_CheckValidVIPGroup(sGroup))
		{
			if(SetTrieString(g_hFeatures[iClient], KEY_GROUP, sGroup))
			{
				if(bool:GetNativeCell(3))
				{
					decl iClientID;
					if(GetTrieValue(g_hFeatures[iClient], KEY_CID, iClientID) && iClientID != -1)
					{
						decl String:sQuery[256];
						if (GLOBAL_INFO & IS_MySQL)
						{
							FormatEx(sQuery, sizeof(sQuery), "UPDATE `vip_overrides` SET `group` = '%s' WHERE `user_id` = '%i' AND `server_id` = '%i';", sGroup, iClientID, g_CVAR_iServerID);
						}
						else
						{
							FormatEx(sQuery, sizeof(sQuery), "UPDATE `vip_users` SET `group` = '%s' WHERE `id` = '%i';", sGroup, iClientID);
						}
						SQL_TQuery(g_hDatabase, SQL_Callback_ChangeClientSettings, sQuery, UID(iClient));
					}
				}

				return true;
			}
		}
		else
		{
			ThrowNativeError(SP_ERROR_NATIVE, "Invalid group/Некорректная VIP-группа (%s)", sGroup);
		}
	}
	return false;
}

public Native_GetClientAccessTime(Handle:hPlugin, iNumParams)
{
	decl iClient;
	iClient = GetNativeCell(1);
	if(CheckValidClient(iClient))
	{
		decl iExp;
		if(GetTrieValue(g_hFeatures[iClient], KEY_EXPIRES, iExp))
		{
			return iExp;
		}
	}

	return -1;
}

public Native_SetClientAccessTime(Handle:hPlugin, iNumParams)
{
	new iClient = GetNativeCell(1);
	if(CheckValidClient(iClient))
	{
		new iTime = GetNativeCell(2);
		
		if(iTime < 0 || (iTime != 0 && iTime < GetTime()))
		{
			ThrowNativeError(SP_ERROR_NATIVE, "Invalid time/Некорректное время (%i)", iTime);
			return false;
		}
		
		if(SetTrieValue(g_hFeatures[iClient], KEY_EXPIRES, iTime))
		{
			if(bool:GetNativeCell(3))
			{
				decl iClientID;
				if(GetTrieValue(g_hFeatures[iClient], KEY_CID, iClientID) && iClientID != -1)
				{
					decl String:sQuery[256];
					if (GLOBAL_INFO & IS_MySQL)
					{
						FormatEx(sQuery, sizeof(sQuery), "UPDATE `vip_overrides` SET `expires` = '%i' WHERE `user_id` = '%i' AND `server_id` = '%i';", iTime, iClientID, g_CVAR_iServerID);
					}
					else
					{
						FormatEx(sQuery, sizeof(sQuery), "UPDATE `vip_users` SET `expires` = '%i' WHERE `id` = '%i';", iTime, iClientID);
					}

					SQL_TQuery(g_hDatabase, SQL_Callback_ChangeClientSettings, sQuery, UID(iClient));
				}
			}

			return true;
		}
	}

	return false;
}

public SQL_Callback_ChangeClientSettings(Handle:hOwner, Handle:hQuery, const String:sError[], any:UserID)
{
	if (sError[0])
	{
		LogError("SQL_Callback_ChangeClientSettings: %s", sError);
	}
	
	new iClient = CID(UserID);
	if(iClient && SQL_GetAffectedRows(hOwner))
	{
		Clients_CheckVipAccess(iClient, false);
	}
}
	
public Native_GetVIPClientTrie(Handle:hPlugin, iNumParams)
{
	decl iClient;
	iClient = GetNativeCell(1);
	if(CheckValidClient(iClient))
	{
		return _:g_hFeatures[iClient];
	}
	return _:INVALID_HANDLE;
}

public Native_GetClientAuthType(Handle:hPlugin, iNumParams)
{
	decl iClient;
	iClient = GetNativeCell(1);
	if(CheckValidClient(iClient))
	{
		decl VIP_AuthType:AuthType;
		if(GetTrieValue(g_hFeatures[iClient], KEY_AUTHTYPE, AuthType))
		{
			return _:AuthType;
		}
	}
	return -1;
}

public Native_SendClientVIPMenu(Handle:hPlugin, iNumParams)
{
	decl iClient;
	iClient = GetNativeCell(1);
	if(CheckValidClient(iClient))
	{
		DisplayMenu(g_hVIPMenu, iClient, MENU_TIME_FOREVER);
	}
}

public Native_SetClientVIP(Handle:hPlugin, iNumParams)
{
	decl iClient;
	iClient = GetNativeCell(1);
	if(CheckValidClient(iClient, false))
	{
		if(g_iClientInfo[iClient] & IS_VIP)
		{
			decl iClientID;
			GetTrieValue(g_hFeatures[iClient], KEY_CID, iClientID);
			if(iClientID != -1)
			{
				ThrowNativeError(SP_ERROR_NATIVE, "The player %L is already a VIP/Игрок %L уже является VIP-игроком", iClient, iClient);
				return false;
			}
		}
		
		decl String:sGroup[64];
		GetNativeString(4, sGroup, sizeof(sGroup));
		if(UTIL_CheckValidVIPGroup(sGroup))
		{
			new iTime = GetNativeCell(2);
			if(iTime >= 0)
			{
				new VIP_AuthType:AuthType = GetNativeCell(3);
				if(bool:GetNativeCell(5) == true)
				{
					if(AUTH_STEAM > AuthType || AuthType > AUTH_NAME)
					{
						ThrowNativeError(SP_ERROR_NATIVE, "Invalid auth type/Некорректное тип авторизации (%i)", AuthType);
						return false;
					}

					UTIL_ADD_VIP_PLAYER(0, iClient, _, iTime, AuthType, sGroup);
				}
				else
				{
					if(iTime == 0)
					{
						Clients_CreateClientVIPSettings(iClient, iTime, AuthType);
					}
					else
					{
						new iCurrentTime = GetTime();

						Clients_CreateClientVIPSettings(iClient, iTime+iCurrentTime, AuthType);
						Clients_CreateExpiredTimer(iClient, iTime+iCurrentTime, iCurrentTime);
					}

					SetTrieString(g_hFeatures[iClient], KEY_GROUP, sGroup);
					SetTrieValue(g_hFeatures[iClient], KEY_CID, -1);

					Clients_LoadVIPFeatures(iClient);
					g_iClientInfo[iClient] |= IS_VIP;
					g_iClientInfo[iClient] |= IS_LOADED;
					
					Clients_OnVIPClientLoaded(iClient);
					if(g_CVAR_bAutoOpenMenu)
					{
						DisplayMenu(g_hVIPMenu, iClient, MENU_TIME_FOREVER);
					}

					DisplayClientInfo(iClient, iTime == 0 ? "connect_info_perm":"connect_info_time");
				}
				
				return true;
			}
			else
			{
				ThrowNativeError(SP_ERROR_NATIVE, "Invalid time/Некорректное время (%i)", iTime);
			}
		}
		else
		{
			ThrowNativeError(SP_ERROR_NATIVE, "Invalid VIP-group/Некорректная VIP-группа (%s)", sGroup);
		}
	}

	return false;
}

public Native_RemoveClientVIP(Handle:hPlugin, iNumParams)
{
	decl iClient;
	iClient = GetNativeCell(1);
	if(CheckValidClient(iClient))
	{
		if(bool:GetNativeCell(2) == true)
		{
			decl iClientID;
			if(GetTrieValue(g_hFeatures[iClient], KEY_CID, iClientID) && iClientID != -1)
			{
				DB_RemoveClientFromID(0, iClientID, true);
			}
		}

		ResetClient(iClient);

		CreateForward_OnVIPClientRemoved(iClient, "Removed by native");

		if(bool:GetNativeCell(3))
		{
			DisplayClientInfo(iClient, "expired_info");
		}

		return true;
	}

	return false;
}

public Native_IsValidVIPGroup(Handle:hPlugin, iNumParams)
{
	decl String:sGroup[64];
	GetNativeString(1, sGroup, sizeof(sGroup));
	return UTIL_CheckValidVIPGroup(sGroup);
}

public Native_IsVIPLoaded(Handle:hPlugin, iNumParams)
{
	return ((GLOBAL_INFO & IS_STARTED) && g_hDatabase);
}

public Native_RegisterFeature(Handle:hPlugin, iNumParams)
{
	decl String:sFeatureName[FEATURE_NAME_LENGTH];
	GetNativeString(1, sFeatureName, sizeof(sFeatureName));
	
	#if DEBUG_MODE
	decl String:sPluginName[FEATURE_NAME_LENGTH];
	GetPluginFilename(hPlugin, sPluginName, FEATURE_NAME_LENGTH);
	DebugMessage("Register feature \"%s\" (%s)", sFeatureName, sPluginName)
	#endif

	if(IsValidFeature(sFeatureName) == false)
	{
		if(GetArraySize(g_hFeaturesArray) == 0)
		{
			RemoveMenuItem(g_hVIPMenu, 0);
		}

		PushArrayString(g_hFeaturesArray, sFeatureName);
		DebugMessage("PushArrayString -> %i", FindStringInArray(g_hFeaturesArray, sFeatureName))

		new VIP_FeatureType:FType = GetNativeCell(3);
		DebugMessage("FeatureType -> %i", FType)

		ArrayList hArray = CreateArray();
		SetTrieValue(GLOBAL_TRIE, sFeatureName, hArray);
		
		PushArrayCell(hArray,	hPlugin);
		PushArrayCell(hArray,	GetNativeCell(2));
		PushArrayCell(hArray,	FType);

		switch(FType)
		{
			case TOGGLABLE:
			{
				PushArrayCell(hArray, RegClientCookie(sFeatureName, sFeatureName, CookieAccess_Private));
			}
			case SELECTABLE:
			{
				PushArrayCell(hArray, INVALID_HANDLE);
			}
		}

		if(FType != HIDE)
		{
			DataPack hDataPack = new DataPack();
			hDataPack.WriteFunction(GetNativeCell(4));
			hDataPack.WriteFunction(GetNativeCell(5));
			hDataPack.WriteFunction(GetNativeCell(6));
			PushArrayCell(hArray, hDataPack);

			AddFeatureToVIPMenu(sFeatureName);
		}
		
		decl iClient, String:sGroup[64];
		for (iClient = 1; iClient <= MaxClients; ++iClient)
		{
			if (IsClientInGame(iClient) && g_iClientInfo[iClient] & IS_VIP)
			{
				if(GetTrieString(g_hFeatures[iClient], KEY_GROUP, sGroup, sizeof(sGroup)))
				{
					KvRewind(g_hGroups);
					if(KvJumpToKey(g_hGroups, sGroup, false))
					{
						Clients_LoadVIPFeatures(iClient);
					}
				}
			}
		}

		DebugMessage("Feature \"%s\" registered", sFeatureName)
	}
	else
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Feature \"%s\" already defined/Функция \"%s\" уже существует", sFeatureName, sFeatureName);
	}
}

public Native_UnregisterFeature(Handle:hPlugin, iNumParams)
{
	decl String:sFeatureName[FEATURE_NAME_LENGTH];
	GetNativeString(1, sFeatureName, sizeof(sFeatureName));
	
	if(IsValidFeature(sFeatureName))
	{
		ArrayList hArray;
		if(GetTrieValue(GLOBAL_TRIE, sFeatureName, hArray))
		{
			decl i, VIP_FeatureType:iFeatureType;
			iFeatureType = VIP_FeatureType:hArray.Get(FEATURES_ITEM_TYPE);
			if(iFeatureType == TOGGLABLE)
			{
				delete view_as<Handle>(hArray.Get(FEATURES_COOKIE));
			}
			
			if(iFeatureType != HIDE)
			{
				DataPack hDataPack = view_as<DataPack>(hArray.Get(FEATURES_MENU_CALLBACKS));
				delete hDataPack;

				AddFeatureToVIPMenu(sFeatureName);
			}

			delete hArray;

			RemoveFromTrie(GLOBAL_TRIE, sFeatureName);

			i = FindStringInArray(g_hFeaturesArray, sFeatureName);
			if(i != -1)
			{
				RemoveFromArray(g_hFeaturesArray, i);
			}

			if(iFeatureType != HIDE)
			{
				decl String:sItemInfo[FEATURE_NAME_LENGTH], iSize;
				iSize = GetMenuItemCount(g_hVIPMenu);
				for(i = 0; i < iSize; ++i)
				{
					GetMenuItem(g_hVIPMenu, i, sItemInfo, sizeof(sItemInfo));
					if(strcmp(sItemInfo, sFeatureName, true) == 0)
					{
						RemoveMenuItem(g_hVIPMenu, i);
						break;
					}
				}
				
				if(GetMenuItemCount(g_hVIPMenu) == 0)
				{
					AddMenuItem(g_hVIPMenu, "NO_FEATURES", "NO_FEATURES", ITEMDRAW_DISABLED);
				}
			}
			
			for(i = 1; i <= MaxClients; ++i)
			{
				if(IsClientInGame(i))
				{
					if(g_iClientInfo[i] & IS_VIP)
					{
						RemoveFromTrie(g_hFeatures[i], sFeatureName);
						RemoveFromTrie(g_hFeatureStatus[i], sFeatureName);
					}
				}
			}
		}

		DebugMessage("Feature \"%s\" unregistered", sFeatureName)
	}
	else
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Feature \"%s\" is invalid/Функция \"%s\" не существует", sFeatureName, sFeatureName);
	}
}

public Native_IsValidFeature(Handle:hPlugin, iNumParams)
{
	decl String:sFeatureName[FEATURE_NAME_LENGTH];
	GetNativeString(1, sFeatureName, sizeof(sFeatureName));

	return _:IsValidFeature(sFeatureName);
}

public Native_IsClientFeatureUse(Handle:hPlugin, iNumParams)
{
	decl iClient;
	iClient = GetNativeCell(1);
	if(CheckValidClient(iClient))
	{
		decl String:sFeatureName[FEATURE_NAME_LENGTH];
		GetNativeString(2, sFeatureName, sizeof(sFeatureName));

		DebugMessage("Native_IsClientFeatureUse: %N (%i) - %s -> %i", iClient, iClient, sFeatureName, Features_GetStatus(iClient, sFeatureName))
		return (Features_GetStatus(iClient, sFeatureName) == ENABLED);
	}

	return false;
}

public Native_GetClientFeatureStatus(Handle:hPlugin, iNumParams)
{
	decl iClient;
	iClient = GetNativeCell(1);
	if(CheckValidClient(iClient))
	{
		decl String:sFeatureName[FEATURE_NAME_LENGTH];
		GetNativeString(2, sFeatureName, sizeof(sFeatureName));

		return _:Features_GetStatus(iClient, sFeatureName);
	}

	return _:NO_ACCESS;
}

public Native_SetClientFeatureStatus(Handle:hPlugin, iNumParams)
{
	decl iClient;
	iClient = GetNativeCell(1);
	if(CheckValidClient(iClient))
	{
		decl String:sFeatureName[FEATURE_NAME_LENGTH], VIP_ToggleState:OldStatus, VIP_ToggleState:NewStatus;
		GetNativeString(2, sFeatureName, sizeof(sFeatureName));
		OldStatus = Features_GetStatus(iClient, sFeatureName);

		NewStatus = VIP_ToggleState:GetNativeCell(3);

		ArrayList hArray;
		if(GetTrieValue(GLOBAL_TRIE, sFeatureName, hArray))
		{
			if(VIP_FeatureType:hArray.Get(FEATURES_ITEM_TYPE) == TOGGLABLE)
			{
				DataPack hDataPack = view_as<DataPack>(hArray.Get(FEATURES_MENU_CALLBACKS));
				hDataPack.Position = ITEM_SELECT;
				Function Function_Select = hDataPack.ReadFunction();
				if(Function_Select != INVALID_FUNCTION)
				{
					Function_OnItemToggle(view_as<Handle>(hArray.Get(FEATURES_PLUGIN)), Function_Select, iClient, sFeatureName, OldStatus, NewStatus);
				}

				if(OldStatus != NewStatus)
				{
					Features_SetStatus(iClient, sFeatureName, NewStatus);
					return true;
				}
			}
		}
	}
	
	return false;
}

public Native_GetClientFeatureInt(Handle:hPlugin, iNumParams)
{
	decl iClient;
	iClient = GetNativeCell(1);
	if(CheckValidClient(iClient))
	{
		decl String:sFeatureName[FEATURE_NAME_LENGTH], iValue;
		GetNativeString(2, sFeatureName, sizeof(sFeatureName));

		if(GetTrieValue(g_hFeatures[iClient], sFeatureName, iValue) && iValue != 0)
		{
			return iValue;
		}
	}

	return 0;
}

public Native_GetClientFeatureFloat(Handle:hPlugin, iNumParams)
{
	decl iClient;
	iClient = GetNativeCell(1);
	if(CheckValidClient(iClient))
	{
		decl String:sFeatureName[FEATURE_NAME_LENGTH], Float:fValue;
		GetNativeString(2, sFeatureName, sizeof(sFeatureName));

		if(GetTrieValue(g_hFeatures[iClient], sFeatureName, fValue) && fValue != 0.0)
		{
			return _:fValue;
		}
	}
	return _:0.0;
}

public Native_GetClientFeatureBool(Handle:hPlugin, iNumParams)
{
	decl iClient;
	iClient = GetNativeCell(1);
	if(CheckValidClient(iClient))
	{
		decl String:sFeatureName[FEATURE_NAME_LENGTH], bool:bValue;
		GetNativeString(2, sFeatureName, sizeof(sFeatureName));

		return GetTrieValue(g_hFeatures[iClient], sFeatureName, bValue);
	}

	return false;
}

public Native_GetClientFeatureString(Handle:hPlugin, iNumParams)
{
	decl iClient;
	iClient = GetNativeCell(1);
	if(CheckValidClient(iClient))
	{
		decl String:sFeatureName[64], String:sBuffer[256], iLen;
		GetNativeString(2, sFeatureName, sizeof(sFeatureName));

		iLen = GetNativeCell(4);
		if(GetTrieString(g_hFeatures[iClient], sFeatureName, sBuffer, sizeof(sBuffer)))
		{
			SetNativeString(3, sBuffer, iLen, true);
			return true;
		}
	}

	return false;
}

/*
public Native_GiveClientFeature(Handle:hPlugin, iNumParams)
{
	decl iClient;
	iClient = GetNativeCell(1);
	if(CheckValidClient(iClient))
	{
		decl String:sFeatureName[64], Handle:hArray, String:sFeatureValue[256];
		if(GetTrieValue(GLOBAL_TRIE, sFeatureName, hArray))
		{
			decl String:sFeatureValue[256];
			GetNativeString(3, sFeatureValue, sizeof(sFeatureValue));
			
			if(!(g_iClientInfo[iClient] & IS_VIP))
			{
				Clients_CreateClientVIPSettings(iClient, 0);
				SetTrieValue(g_hFeatures[iClient], KEY_CID, -1);
				g_iClientInfo[iClient] |= IS_VIP;
				g_iClientInfo[iClient] |= IS_LOADED;
				g_iClientInfo[iClient] |= IS_AUTHORIZED;
			}

			switch(VIP_ValueType:hArray.Get(FEATURES_VALUE_TYPE))
			{
				case BOOL:
				{
					SetTrieValue(g_hFeatures[iClient], sFeatureName, bool:StringToInt(sFeatureValue));
				}
				case INT:
				{
					SetTrieValue(g_hFeatures[iClient], sFeatureName, StringToInt(sFeatureValue));
				}
				case FLOAT:
				{
					SetTrieValue(g_hFeatures[iClient], sFeatureName, StringToFloat(sFeatureValue));
				}
				case STRING:
				{
					SetTrieString(g_hFeatures[iClient], sFeatureName, sFeatureValue);
				}
				default:
				{
					ResetClient(iClient);
					ThrowNativeError(SP_ERROR_NATIVE, "Invalid feature value (%s). The feature is of type VIP_NULL", sFeatureValue);
					return false;
				}
			}

			Features_SetStatus(iClient, sFeatureName, ENABLED);
			
			if(VIP_FeatureType:hArray.Get(FEATURES_ITEM_TYPE) == TOGGLABLE)
			{
				new Function:Function_Select = Function:hArray.Get(FEATURES_ITEM_SELECT);
				
				if(Function_Select != INVALID_FUNCTION)
				{
					NewStatus = Function_OnItemToggle(view_as<Handle>(hArray.Get(FEATURES_PLUGIN)), Function_Select, iClient, sFeatureName, NO_ACCESS, ENABLED);
				}
			}

			return true;
		}

		ThrowNativeError(SP_ERROR_NATIVE, "Invalid feature (%s)", sFeatureName);
	}

	
	return false;
}
*/

public Native_GetDatabase(Handle:hPlugin, iNumParams)
{
	return _:CloneHandle(g_hDatabase, hPlugin);
}

public Native_GetDatabaseType(Handle:hPlugin, iNumParams)
{
	return (GLOBAL_INFO & IS_MySQL);
}

public Native_TimeToSeconds(Handle:hPlugin, iNumParams)
{
	return UTIL_TimeToSeconds(GetNativeCell(1));
}

public Native_SecondsToTime(Handle:hPlugin, iNumParams)
{
	return UTIL_SecondsToTime(GetNativeCell(1));
}

public Native_GetTimeFromStamp(Handle:hPlugin, iNumParams)
{
	new iTimeStamp = GetNativeCell(3);
	if(iTimeStamp > 0)
	{
		new iClient = GetNativeCell(4);
		if(iClient == 0 || CheckValidClient(iClient, false))
		{
			decl String:sBuffer[64];
			UTIL_GetTimeFromStamp(sBuffer, sizeof(sBuffer), iTimeStamp, iClient);
			SetNativeString(1, sBuffer, GetNativeCell(2), true);
			return true;
		}
	}

	return false;
}

public Native_AddStringToggleStatus(Handle:hPlugin, iNumParams)
{
	decl String:sFeatureName[FEATURE_NAME_LENGTH];
	GetNativeString(4, sFeatureName, sizeof(sFeatureName));
	if(IsValidFeature(sFeatureName))
	{
		new iClient = GetNativeCell(5);
		if(CheckValidClient(iClient))
		{
			new iSize = GetNativeCell(3);
			decl String:sBuffer[iSize];
			GetNativeString(1, sBuffer, iSize);
			Format(sBuffer, iSize, "%s [%T]", sBuffer, g_sToggleStatus[_:Features_GetStatus(iClient, sFeatureName)], iClient);
			SetNativeString(2, sBuffer, iSize, true);
		}
	}
	else
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Feature \"%s\" is invalid/Функция \"%s\" не существует", sFeatureName, sFeatureName);
	}
}

bool:CheckValidClient(const &iClient, bool:bCheckVIP = true)
{
	if (iClient < 1 || iClient > MaxClients)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index/Некорректный индекс игрока (%i)", iClient);
		return false;
	}
	if (IsClientInGame(iClient) == false)
	{	
		ThrowNativeError(SP_ERROR_NATIVE, "Client %i is not connected/Игрок %i не подключен", iClient, iClient);
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
		if (!(g_iClientInfo[iClient] & IS_VIP) || !(g_iClientInfo[iClient] & IS_AUTHORIZED))
		{
			ThrowNativeError(SP_ERROR_NATIVE, "Client %i is not VIP", iClient);
			return false;
		}
		*/
		
		return bool:(g_iClientInfo[iClient] & IS_VIP);
	}

	return true;
}
