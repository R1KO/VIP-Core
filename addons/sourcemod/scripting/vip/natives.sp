
public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max) 
{
	CreateNative("VIP_CheckClient",				Native_CheckClient);
	CreateNative("VIP_IsClientVIP",				Native_IsClientVIP);
	
	CreateNative("VIP_PrintToChatClient",		Native_PrintToChatClient);
	CreateNative("VIP_PrintToChatAll",			Native_PrintToChatAll);
	CreateNative("VIP_LogMessage",				Native_LogMessage);

	CreateNative("VIP_GetClientVIPGroup",		Native_GetClientVIPGroup);
	CreateNative("VIP_SetClientVIPGroup",		Native_SetClientVIPGroup);
	
	CreateNative("VIP_GetClientAccessTime",		Native_GetClientAccessTime);
	CreateNative("VIP_SetClientAccessTime",		Native_SetClientAccessTime);

	CreateNative("VIP_SetClientPassword",		Native_SetClientPassword);

	CreateNative("VIP_GetVIPClientTrie",			Native_GetVIPClientTrie);
	
	CreateNative("VIP_GetClientAuthType",		Native_GetClientAuthType);

	CreateNative("VIP_HookClientSpawn",			Native_HookClientSpawn);
	CreateNative("VIP_UnhookClientSpawn",		Native_UnhookClientSpawn);

	CreateNative("VIP_SendClientVIPMenu",		Native_SendClientVIPMenu);

	CreateNative("VIP_SetClientVIP",				Native_SetClientVIP);
	CreateNative("VIP_RemoveClientVIP",			Native_RemoveClientVIP);

	CreateNative("VIP_IsValidVIPGroup",			Native_IsValidVIPGroup);

	CreateNative("VIP_IsVIPLoaded",				Native_IsVIPLoaded);

	CreateNative("VIP_RegisterFeature",			Native_RegisterFeature);
	CreateNative("VIP_UnregisterFeature",		Native_UnregisterFeature);
	CreateNative("VIP_IsValidFeature",			Native_IsValidFeature);

	CreateNative("VIP_GetClientFeatureStatus",	Native_GetClientFeatureStatus);
	CreateNative("VIP_SetClientFeatureStatus",	Native_SetClientFeatureStatus);
	
	CreateNative("VIP_IsClientFeatureUse",		Native_IsClientFeatureUse);

	CreateNative("VIP_GetClientFeatureInt",		Native_GetClientFeatureInt);
	CreateNative("VIP_GetClientFeatureFloat",	Native_GetClientFeatureFloat);
	CreateNative("VIP_GetClientFeatureBool",		Native_GetClientFeatureBool);
	CreateNative("VIP_GetClientFeatureString",	Native_GetClientFeatureString);

//	CreateNative("VIP_GiveClientFeature",	Native_GiveClientFeature);

	CreateNative("VIP_GetDatabase",				Native_GetDatabase);
	CreateNative("VIP_GetDatabaseType",			Native_GetDatabaseType);

	CreateNative("VIP_TimeToSeconds",			Native_TimeToSeconds);
	CreateNative("VIP_SecondsToTime",			Native_SecondsToTime);
	
	CreateNative("VIP_GetTimeFromStamp",			Native_GetTimeFromStamp);
	
	CreateNative("VIP_AddStringToggleStatus",	Native_AddStringToggleStatus);

	MarkNativeAsOptional("GuessSDKVersion");
	MarkNativeAsOptional("GetEngineVersion");
	MarkNativeAsOptional("GetClientAuthId");
	MarkNativeAsOptional("GetClientAuthString");
	MarkNativeAsOptional("SQL_SetCharset");
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
		return ((g_iClientInfo[iClient] & IS_AUTHORIZED) && (g_iClientInfo[iClient] & IS_VIP));
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
	FormatEx(sMessage, sizeof(sMessage), g_GameType == GAME_CSGO ? " \x01%t %s":"\x01%t %s", "VIP_CHAT_PREFIX", sFormat);
	
	ReplaceString(sMessage, sizeof(sMessage), "\\n", "\n");
	ReplaceString(sMessage, sizeof(sMessage), "{DEFAULT}", "\x01");
	ReplaceString(sMessage, sizeof(sMessage), "{GREEN}", "\x04");
	switch(g_GameType)
	{
		case GAME_CSS_34:
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
		case GAME_CSS:
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
		case GAME_CSGO:
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
	if(g_GameType == GAME_CSGO)
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

/*
		
	if(GetFeatureStatus(FeatureType_Native, "GetUserMessageType") == FeatureStatus_Available && GetUserMessageType() == UM_Protobuf) 
	{
		PbSetInt(hBuffer, "ent_idx", author);
		PbSetBool(hBuffer, "chat", true);
		PbSetString(hBuffer, "msg_name", szMessage);
		PbAddString(hBuffer, "params", "");
		PbAddString(hBuffer, "params", "");
		PbAddString(hBuffer, "params", "");
		PbAddString(hBuffer, "params", "");
	}
	else
	{
		BfWriteByte(hBuffer, author);
		BfWriteByte(hBuffer, true);
		BfWriteString(hBuffer, szMessage);
	}
	
	
public Native_PrintToChatClient(Handle:hPlugin, iNumParams)
{
	decl iClient;
	iClient = GetNativeCell(1);
	if(CheckValidClient(iClient, false))
	{
		decl String:sMessage[256];
		FormatNativeString(0, 2, 3, sizeof(sMessage), _, sMessage);

		decl String:sMessage[256];
		SetGlobalTransTarget(iClient);
		FormatNativeString(0, 2, 3, sizeof(sMessage), _, sMessage);
		Format(sMessage, sizeof(sMessage), "%t%s", "VIP_CHAT_PREFIX", sMessage);
		SendChatMessage({iClient}, iClient, sMessage, sizeof(sMessage));

		
		PrintToChat(iClient, "%t%s", "VIP_CHAT_PREFIX", sMessage);
	}
}

public Native_PrintToChatAll(Handle:hPlugin, iNumParams)
{
	decl i, String:sMessage[256];
	SetGlobalTransTarget(LANG_SERVER);

	for (i = 1; i <= MaxClients; ++i)
	{
		if (IsClientInGame(i) && IsFakeClient(i) == false)
		{
			SetGlobalTransTarget(i);
			FormatNativeString(0, 1, 2, sizeof(sMessage), _, sMessage);
			PrintToChat(i, "%t%s", "VIP_CHAT_PREFIX", sMessage);
		}
	}
}

public Native_PrintToChatAll(Handle:hPlugin, iNumParams)
{
	decl String:sMessage[256];
	SetGlobalTransTarget(LANG_SERVER);
	FormatNativeString(0, 1, 2, sizeof(sMessage), _, sMessage);
	
	PrintToChatAll("%t%s", "VIP_CHAT_PREFIX", sMessage);
}

ReplaceColors(String:sMessage[], iMaxLength)
{
	
}

SendChatMessage(iClients[], iCountClients, String:sMessage[], iMaxLength)
{
	// ReplaceColors

	switch(g_GameType)
	{
		case GAME_CSS_34:
		{
			
			PrintToChat(iClient, "%t%s", "VIP_CHAT_PREFIX", sMessage);
		}
		case GAME_CSS:
		{
			
		}
		case GAME_CSGO:
		{
			
		}
	}

	new Handle:hBf = StartMessage("SayText2", iClients, iCountClients, USERMSG_RELIABLE|USERMSG_BLOCKHOOKS);
	if(g_GameType == GAME_CSGO)
	{
		PbSetInt(hBf, "ent_idx", 0);
		PbSetBool(hBf, "chat", true);
		PbSetString(hBf, "msg_name", sMessage);
		PbAddString(hBf, "params", "");
		PbAddString(hBf, "params", "");
		PbAddString(hBf, "params", "");
		PbAddString(hBf, "params", "");
	}
	else
	{
		BfWriteByte(hBf, 0);
		BfWriteByte(hBf, true);
		BfWriteString(hBf, sMessage);
	}
	EndMessage();
}
*/

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

public Native_GetClientVIPGroup(Handle:hPlugin, iNumParams)
{
	decl iClient;
	iClient = GetNativeCell(1);
	if(CheckValidClient(iClient))
	{
		decl String:sGroup[64];
		
		sGroup[0] = 0;

		if(GetTrieString(g_hFeatures[iClient], "vip_group", sGroup, sizeof(sGroup)))
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
			if(SetTrieString(g_hFeatures[iClient], "vip_group", sGroup))
			{
				if(bool:GetNativeCell(3))
				{
					decl iClientID;
					if(GetTrieValue(g_hFeatures[iClient], "ClientID", iClientID))
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
		if(GetTrieValue(g_hFeatures[iClient], "expires", iExp))
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
		
		if(SetTrieValue(g_hFeatures[iClient], "expires", iTime))
		{
			if(bool:GetNativeCell(3))
			{
				decl iClientID;
				if(GetTrieValue(g_hFeatures[iClient], "ClientID", iClientID))
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

public Native_SetClientPassword(Handle:hPlugin, iNumParams)
{
	new iClient = GetNativeCell(1);
	if(CheckValidClient(iClient))
	{
		decl iClientID;
		if(GetTrieValue(g_hFeatures[iClient], "ClientID", iClientID) && iClientID != -1)
		{
			decl String:sPassKey[64], String:sPassword[64], String:sQuery[256], String:sBuffer[64];
			GetNativeString(2, sPassKey, sizeof(sPassKey));
			GetNativeString(3, sPassword, sizeof(sPassword));

			sBuffer[0] = 0;
			if(sPassKey[0])
			{
				FormatEx(sBuffer, sizeof(sBuffer), "`pass_key` = '%s'", sPassKey);
			}
			if(sPassword[0])
			{
				Format(sBuffer, sizeof(sBuffer), "%s, `password` = '%s'", sBuffer, sPassword);
			}
		
			if(!sBuffer[0])
			{
				return false;
			}
			
			FormatEx(sQuery, sizeof(sQuery), "UPDATE `vip_users` SET %s WHERE `id` = '%i';", sBuffer, iClientID);
			SQL_TQuery(g_hDatabase, SQL_Callback_ChangeClientSettings, sQuery, UID(iClient));

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
		if(GetTrieValue(g_hFeatures[iClient], "AuthType", AuthType))
		{
			return _:AuthType;
		}
	}
	return -1;
}

public Native_HookClientSpawn(Handle:hPlugin, iNumParams)
{
	AddToForward(g_hPrivateForward_OnPlayerSpawn, hPlugin, Function:GetNativeCell(1));
	PushArrayCell(g_hHookPlugins, hPlugin);
}

public Native_UnhookClientSpawn(Handle:hPlugin, iNumParams)
{
	RemoveAllFromForward(g_hPrivateForward_OnPlayerSpawn, hPlugin);
	new index = FindValueInArray(g_hHookPlugins, hPlugin);
	if(index != -1)
	{
		RemoveFromArray(g_hHookPlugins, index);
	}
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
			if(g_iClientInfo[iClient] & IS_AUTHORIZED)
			{
				decl iClientID;
				GetTrieValue(g_hFeatures[iClient], "ClientID", iClientID);
				if(iClientID != -1)
				{
					ThrowNativeError(SP_ERROR_NATIVE, "The player %L is already a VIP/Игрок %L уже является VIP-игроком", iClient, iClient);
					return false;
				}
			}
			else
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

					SetTrieString(g_hFeatures[iClient], "vip_group", sGroup);
					//	SetTrieValue(g_hFeatures[iClient], "IsTempVIP", 1);
					SetTrieValue(g_hFeatures[iClient], "ClientID", -1);

					Clients_LoadVIPFeatures(iClient);
					g_iClientInfo[iClient] |= IS_VIP;
					g_iClientInfo[iClient] |= IS_LOADED;
					g_iClientInfo[iClient] |= IS_AUTHORIZED;
					
					Clients_OnVIPClientLoaded(iClient);
					if(g_CVAR_bAutoOpenMenu)
					{
						DisplayMenu(g_hVIPMenu, iClient, MENU_TIME_FOREVER);
					}
					Clients_WelcomeMessage(iClient);
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
			if(GetTrieValue(g_hFeatures[iClient], "ClientID", iClientID) && iClientID != -1)
			{
				DB_RemoveClientFromID(0, iClientID, true);
			}
		}

		ResetClient(iClient);

		CreateForward_OnVIPClientRemoved(iClient, "Removed by native");

		if(bool:GetNativeCell(3))
		{
			ShowClientInfo(iClient, INFO_EXPIRED);
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
		if(GetArraySize(GLOBAL_ARRAY) == 0)
		{
			RemoveMenuItem(g_hVIPMenu, 0);
		}

		PushArrayString(GLOBAL_ARRAY, sFeatureName);
		DebugMessage("PushArrayString -> %i", FindStringInArray(GLOBAL_ARRAY, sFeatureName))

		new Handle:hArray = CreateArray(1, FEATURES_SIZE);
		SetTrieValue(GLOBAL_TRIE, sFeatureName, hArray);
		
		SetArrayCell(hArray, FEATURES_PLUGIN,			hPlugin);
		SetArrayCell(hArray, FEATURES_VALUE_TYPE,		GetNativeCell(2));
		new VIP_FeatureType:FType = GetNativeCell(3);
		DebugMessage("FeatureType -> %i", FType)
		SetArrayCell(hArray, FEATURES_ITEM_TYPE,		FType);

		switch(FType)
		{
			case TOGGLABLE:
			{
				SetArrayCell(hArray, FEATURES_COOKIE,			RegClientCookie(sFeatureName, sFeatureName, CookieAccess_Public));
				SetArrayCell(hArray, FEATURES_ITEM_SELECT,	GetNativeCell(4));
				SetArrayCell(hArray, FEATURES_ITEM_DISPLAY,	GetNativeCell(5));
				SetArrayCell(hArray, FEATURES_ITEM_DRAW,		GetNativeCell(6));
			}
			case SELECTABLE:
			{
				SetArrayCell(hArray, FEATURES_COOKIE,			INVALID_HANDLE);
				SetArrayCell(hArray, FEATURES_ITEM_SELECT,	GetNativeCell(4));
				SetArrayCell(hArray, FEATURES_ITEM_DISPLAY,	GetNativeCell(5));
				SetArrayCell(hArray, FEATURES_ITEM_DRAW,		GetNativeCell(6));
			}
			case HIDE:
			{
				SetArrayCell(hArray, FEATURES_COOKIE,			INVALID_HANDLE);
				SetArrayCell(hArray, FEATURES_ITEM_SELECT,	INVALID_FUNCTION);
				SetArrayCell(hArray, FEATURES_ITEM_DISPLAY,	INVALID_FUNCTION);
				SetArrayCell(hArray, FEATURES_ITEM_DRAW,		INVALID_FUNCTION);
			}
		}
		
		if(FType != HIDE)
		{
			AddFeatureToVIPMenu(sFeatureName);
		}
		
		decl iClient, String:sGroup[64];
		for (iClient = 1; iClient <= MaxClients; ++iClient)
		{
			if (IsClientInGame(iClient) && g_iClientInfo[iClient] & IS_VIP)
			{
				if(GetTrieString(g_hFeatures[iClient], "vip_group", sGroup, sizeof(sGroup)))
				{
					KvRewind(g_hGroups);
					if(KvJumpToKey(g_hGroups, sGroup, false))
					{
						Clients_LoadVIPFeatures(iClient);
					}
				}
			}
		}

		/*
		KvRewind(g_hPhrases);
		if(KvJumpToKey(g_hPhrases, sFeatureName, false) == false)
		{
			#if DEBUG_MODE
			DebugLog("KvJumpToKey(g_hPhrases, \"%s\", false)", sFeatureName);
			#endif
			KvRewind(g_hPhrases);
			if(KvJumpToKey(g_hPhrases, sFeatureName, true))
			{
				#if DEBUG_MODE
				DebugLog("KvJumpToKey(g_hPhrases, \"%s\", true)", sFeatureName);
				#endif
				KvSetString(g_hPhrases, "en", sFeatureName);
				KvRewind(g_hPhrases);
				KeyValuesToFile(g_hPhrases, "addons/sourcemod/translations/vip_modules.phrases.txt");
			}
		}

		KvRewind(g_hPhrases);
*/
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
		decl Handle:hArray;
		if(GetTrieValue(GLOBAL_TRIE, sFeatureName, hArray))
		{
			decl i, VIP_FeatureType:iFeatureType;
			iFeatureType = VIP_FeatureType:GetArrayCell(hArray, FEATURES_ITEM_TYPE);
			if(iFeatureType == TOGGLABLE)
			{
				CloseHandle(GetArrayCell(hArray, FEATURES_COOKIE));
			}

			CloseHandle(hArray);

			RemoveFromTrie(GLOBAL_TRIE, sFeatureName);

			i = FindStringInArray(GLOBAL_ARRAY, sFeatureName);
			if(i != -1)
			{
				RemoveFromArray(GLOBAL_ARRAY, i);
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
		decl String:sFeatureName[FEATURE_NAME_LENGTH], Handle:hArray, VIP_ToggleState:OldStatus, VIP_ToggleState:NewStatus;
		GetNativeString(2, sFeatureName, sizeof(sFeatureName));
		OldStatus = Features_GetStatus(iClient, sFeatureName);

		NewStatus = VIP_ToggleState:GetNativeCell(3);

		if(GetTrieValue(GLOBAL_TRIE, sFeatureName, hArray))
		{
			if(VIP_FeatureType:GetArrayCell(hArray, FEATURES_ITEM_TYPE) == TOGGLABLE)
			{
				new Function:Function_Select = Function:GetArrayCell(hArray, FEATURES_ITEM_SELECT);
				if(Function_Select != INVALID_FUNCTION)
				{
					Function_OnItemToggle(Handle:GetArrayCell(hArray, FEATURES_PLUGIN), Function_Select, iClient, sFeatureName, OldStatus, NewStatus);
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
				SetTrieValue(g_hFeatures[iClient], "ClientID", -1);
				g_iClientInfo[iClient] |= IS_VIP;
				g_iClientInfo[iClient] |= IS_LOADED;
				g_iClientInfo[iClient] |= IS_AUTHORIZED;
			}

			switch(VIP_ValueType:GetArrayCell(hArray, FEATURES_VALUE_TYPE))
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
			
			if(VIP_FeatureType:GetArrayCell(hArray, FEATURES_ITEM_TYPE) == TOGGLABLE)
			{
				new Function:Function_Select = Function:GetArrayCell(hArray, FEATURES_ITEM_SELECT);
				
				if(Function_Select != INVALID_FUNCTION)
				{
					NewStatus = Function_OnItemToggle(Handle:GetArrayCell(hArray, FEATURES_PLUGIN), Function_Select, iClient, sFeatureName, NO_ACCESS, ENABLED);
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
