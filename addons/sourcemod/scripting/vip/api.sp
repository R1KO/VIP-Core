
void CreateForwards()
{
	// Global Forwards
	g_hGlobalForward_OnVIPLoaded = CreateGlobalForward("VIP_OnVIPLoaded", ET_Ignore);
	g_hGlobalForward_OnClientLoaded = CreateGlobalForward("VIP_OnClientLoaded", ET_Ignore, Param_Cell, Param_Cell);
	g_hGlobalForward_OnVIPClientLoaded = CreateGlobalForward("VIP_OnVIPClientLoaded", ET_Ignore, Param_Cell);
	g_hGlobalForward_OnVIPClientAdded = CreateGlobalForward("VIP_OnVIPClientAdded", ET_Ignore, Param_Cell, Param_Cell);
	g_hGlobalForward_OnVIPClientRemoved = CreateGlobalForward("VIP_OnVIPClientRemoved", ET_Ignore, Param_Cell, Param_String);
	g_hGlobalForward_OnPlayerSpawn = CreateGlobalForward("VIP_OnPlayerSpawn", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
}

// Global Forwards
void CreateForward_OnVIPLoaded()
{
	Call_StartForward(g_hGlobalForward_OnVIPLoaded);
	Call_Finish();
}

void CreateForward_OnClientLoaded(int iClient)
{
	Call_StartForward(g_hGlobalForward_OnClientLoaded);
	Call_PushCell(iClient);
	Call_PushCell(g_iClientInfo[iClient] & IS_VIP);
	Call_Finish();
}

void CreateForward_OnVIPClientLoaded(int iClient)
{
	Call_StartForward(g_hGlobalForward_OnVIPClientLoaded);
	Call_PushCell(iClient);
	Call_Finish();
}

void CreateForward_OnVIPClientAdded(int iAdmin, int iClient)
{
	Call_StartForward(g_hGlobalForward_OnVIPClientAdded);
	Call_PushCell(iAdmin);
	Call_PushCell(iClient);
	Call_Finish();
}

void CreateForward_OnVIPClientRemoved(int iClient, const char[] sReason)
{
	Call_StartForward(g_hGlobalForward_OnVIPClientRemoved);
	Call_PushCell(iClient);
	Call_PushString(sReason);
	Call_Finish();
}

void CreateForward_OnPlayerSpawn(int iClient, int iTeam)
{
	Call_StartForward(g_hGlobalForward_OnPlayerSpawn);
	Call_PushCell(iClient);
	Call_PushCell(iTeam);
	Call_PushCell(g_iClientInfo[iClient] & IS_VIP);
	Call_Finish();
}

public APLRes:AskPluginLoad2(Handle:myself, bool late, char[] error, err_max)
{
	CreateNative("VIP_CheckClient", Native_CheckClient);
	CreateNative("VIP_IsClientVIP", Native_IsClientVIP);
	
	CreateNative("VIP_PrintToChatClient", Native_PrintToChatClient);
	CreateNative("VIP_PrintToChatAll", Native_PrintToChatAll);
	CreateNative("VIP_LogMessage", Native_LogMessage);
	
	CreateNative("VIP_GetClientID", Native_GetClientID);
	
	CreateNative("VIP_GetClientVIPGroup", Native_GetClientVIPGroup);
	CreateNative("VIP_SetClientVIPGroup", Native_SetClientVIPGroup);
	
	CreateNative("VIP_GetClientAccessTime", Native_GetClientAccessTime);
	CreateNative("VIP_SetClientAccessTime", Native_SetClientAccessTime);
	
	CreateNative("VIP_SetClientPassword", Native_SetClientPassword);
	
	CreateNative("VIP_GetVIPClientTrie", Native_GetVIPClientTrie);
	
	CreateNative("VIP_GetClientAuthType", Native_GetClientAuthType);
	
	CreateNative("VIP_SendClientVIPMenu", Native_SendClientVIPMenu);
	
	CreateNative("VIP_SetClientVIP", Native_SetClientVIP);
	CreateNative("VIP_RemoveClientVIP", Native_RemoveClientVIP);
	
	CreateNative("VIP_IsValidVIPGroup", Native_IsValidVIPGroup);
	
	CreateNative("VIP_IsVIPLoaded", Native_IsVIPLoaded);
	
	CreateNative("VIP_RegisterFeature", Native_RegisterFeature);
	CreateNative("VIP_UnregisterFeature", Native_UnregisterFeature);
	CreateNative("VIP_IsValidFeature", Native_IsValidFeature);
	
	CreateNative("VIP_GetClientFeatureStatus", Native_GetClientFeatureStatus);
	CreateNative("VIP_SetClientFeatureStatus", Native_SetClientFeatureStatus);
	
	CreateNative("VIP_IsClientFeatureUse", Native_IsClientFeatureUse);
	
	CreateNative("VIP_GetClientFeatureInt", Native_GetClientFeatureInt);
	CreateNative("VIP_GetClientFeatureFloat", Native_GetClientFeatureFloat);
	CreateNative("VIP_GetClientFeatureBool", Native_GetClientFeatureBool);
	CreateNative("VIP_GetClientFeatureString", Native_GetClientFeatureString);
	
	//	CreateNative("VIP_GiveClientFeature",	Native_GiveClientFeature);
	
	CreateNative("VIP_GetDatabase", Native_GetDatabase);
	CreateNative("VIP_GetDatabaseType", Native_GetDatabaseType);
	
	CreateNative("VIP_TimeToSeconds", Native_TimeToSeconds);
	CreateNative("VIP_SecondsToTime", Native_SecondsToTime);
	
	CreateNative("VIP_GetTimeFromStamp", Native_GetTimeFromStamp);
	
	CreateNative("VIP_AddStringToggleStatus", Native_AddStringToggleStatus);
	
	MarkNativeAsOptional("GetClientAuthId");
	MarkNativeAsOptional("GetClientAuthString");
	MarkNativeAsOptional("BfWriteByte");
	MarkNativeAsOptional("BfWriteString");
	MarkNativeAsOptional("PbSetInt");
	MarkNativeAsOptional("PbSetBool");
	MarkNativeAsOptional("PbSetString");
	MarkNativeAsOptional("PbAddString");
	
	RegPluginLibrary("vip_core");
	
	return APLRes_Success;
}

public int Native_CheckClient(Handle hPlugin, int iNumParams)
{
	decl iClient;
	iClient = GetNativeCell(1);
	if (CheckValidClient(iClient, false))
	{
		Clients_CheckVipAccess(iClient, view_as<bool>(GetNativeCell(2)));
	}
}

public int Native_IsClientVIP(Handle hPlugin, int iNumParams)
{
	decl iClient;
	iClient = GetNativeCell(1);
	if (CheckValidClient(iClient, false))
	{
		return ((g_iClientInfo[iClient] & IS_AUTHORIZED) && (g_iClientInfo[iClient] & IS_VIP));
	}
	
	return false;
}

public int Native_PrintToChatClient(Handle hPlugin, int iNumParams)
{
	new iClient = GetNativeCell(1);
	if (CheckValidClient(iClient, false))
	{
		char sMessage[256];
		SetGlobalTransTarget(iClient);
		FormatNativeString(0, 2, 3, sizeof(sMessage), _, sMessage);
		//	Format(sMessage, sizeof(sMessage), "%t%s", "VIP_CHAT_PREFIX", sMessage);
		
		Print(iClient, sMessage);
		
		//	PrintToChat(iClient, "%t%s", "VIP_CHAT_PREFIX", sMessage);
	}
}

public int Native_PrintToChatAll(Handle hPlugin, int iNumParams)
{
	decl i; char sMessage[256];
	
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

void Print(int iClient, const char[] sFormat)
{
	char sMessage[256];
	FormatEx(sMessage, sizeof(sMessage), g_EngineVersion == Engine_CSGO ? " \x01%t %s":"\x01%t %s", "VIP_CHAT_PREFIX", sFormat);
	
	ReplaceString(sMessage, sizeof(sMessage), "\\n", "\n");
	ReplaceString(sMessage, sizeof(sMessage), "{DEFAULT}", "\x01");
	ReplaceString(sMessage, sizeof(sMessage), "{GREEN}", "\x04");
	
	switch (g_EngineVersion)
	{
		case Engine_SourceSDK2006:
		{
			ReplaceString(sMessage, sizeof(sMessage), "{LIGHTGREEN}", "\x03");
			new iColor = ReplaceColors(sMessage, sizeof(sMessage));
			switch (iColor)
			{
				case  - 1:SayText2(iClient, 0, sMessage);
				case 0:SayText2(iClient, iClient, sMessage);
				default:
				{
					SayText2(iClient, FindPlayerByTeam(iColor), sMessage);
				}
			}
		}
		case Engine_CSS, Engine_TF2, Engine_DODS, Engine_HL2DM:
		{
			ReplaceString(sMessage, sizeof(sMessage), "#", "\x07");
			if (ReplaceString(sMessage, sizeof(sMessage), "{TEAM}", "\x03"))
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
			static const char sColorName[][] = 
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
			char sColorCode[][] = 
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
			
			for (new i = 0; i < sizeof(sColorName); ++i)
			{
				ReplaceString(sMessage, sizeof(sMessage), sColorName[i], sColorCode[i]);
			}
			
			if (ReplaceString(sMessage, sizeof(sMessage), "{TEAM}", "\x03"))
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
			ReplaceString(sMessage, sizeof(sMessage), "{TEAM}", "\x03");
		}
	}
}

int ReplaceColors(char[] sMsg, int MaxLength)
{
	if (ReplaceString(sMsg, MaxLength, "{TEAM}", "\x03"))return 0;
	
	if (ReplaceString(sMsg, MaxLength, "{BLUE}", "\x03"))return 3;
	if (ReplaceString(sMsg, MaxLength, "{RED}", "\x03"))return 2;
	if (ReplaceString(sMsg, MaxLength, "{GRAY}", "\x03"))return 1;
	
	return -1;
}

int FindPlayerByTeam(int iTeam)
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == iTeam)return i;
	}
	
	return 0;
}

void SayText2(int iClient, int iAuthor = 0, const char[] sMessage)
{
	decl iClients[1], Handle:hBuffer;
	iClients[0] = iClient;
	hBuffer = StartMessage("SayText2", iClients, 1, USERMSG_RELIABLE | USERMSG_BLOCKHOOKS);
	if (GetUserMessageType() == UM_Protobuf)
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
		hBuffer.WriteByte(iAuthor);
		hBuffer.WriteByte(true);
		BfWriteString(hBuffer, sMessage);
	}
	EndMessage();
}

public int Native_LogMessage(Handle hPlugin, int iNumParams)
{
	if (g_CVAR_bLogsEnable)
	{
		char sMessage[512];
		SetGlobalTransTarget(LANG_SERVER);
		FormatNativeString(0, 1, 2, sizeof(sMessage), _, sMessage);
		
		LogToFile(g_sLogFile, sMessage);
	}
}

public int Native_GetClientID(Handle hPlugin, int iNumParams)
{
	decl iClient;
	iClient = GetNativeCell(1);
	if (CheckValidClient(iClient))
	{
		decl iClientID;
		if (g_hFeatures[iClient].GetValue(KEY_CID, iClientID))
		{
			return iClientID;
		}
	}
	
	return -1;
}

public int Native_GetClientVIPGroup(Handle hPlugin, int iNumParams)
{
	decl iClient;
	iClient = GetNativeCell(1);
	if (CheckValidClient(iClient))
	{
		char sGroup[64];
		
		sGroup[0] = 0;
		
		if (g_hFeatures[iClient].GetString(KEY_GROUP, sGroup, sizeof(sGroup)))
		{
			SetNativeString(2, sGroup, GetNativeCell(3), true);
			return true;
		}
	}
	return false;
}

public int Native_SetClientVIPGroup(Handle hPlugin, int iNumParams)
{
	decl iClient;
	iClient = GetNativeCell(1);
	if (CheckValidClient(iClient))
	{
		char sGroup[64];
		GetNativeString(2, sGroup, sizeof(sGroup));
		if (UTIL_CheckValidVIPGroup(sGroup))
		{
			if (g_hFeatures[iClient].SetString(KEY_GROUP, sGroup))
			{
				if (view_as<bool>(GetNativeCell(3)))
				{
					decl iClientID;
					if (g_hFeatures[iClient].GetValue(KEY_CID, iClientID) && iClientID != -1)
					{
						char sQuery[256];
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

public int Native_GetClientAccessTime(Handle hPlugin, int iNumParams)
{
	decl iClient;
	iClient = GetNativeCell(1);
	if (CheckValidClient(iClient))
	{
		decl iExp;
		if (g_hFeatures[iClient].GetValue(KEY_EXPIRES, iExp))
		{
			return iExp;
		}
	}
	
	return -1;
}

public int Native_SetClientAccessTime(Handle hPlugin, int iNumParams)
{
	new iClient = GetNativeCell(1);
	if (CheckValidClient(iClient))
	{
		new iTime = GetNativeCell(2);
		
		if (iTime < 0 || (iTime != 0 && iTime < GetTime()))
		{
			ThrowNativeError(SP_ERROR_NATIVE, "Invalid time/Некорректное время (%i)", iTime);
			return false;
		}
		
		if (g_hFeatures[iClient].SetValue(KEY_EXPIRES, iTime))
		{
			if (view_as<bool>(GetNativeCell(3)))
			{
				decl iClientID;
				if (g_hFeatures[iClient].GetValue(KEY_CID, iClientID) && iClientID != -1)
				{
					char sQuery[256];
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

public int Native_SetClientPassword(Handle hPlugin, int iNumParams)
{
	new iClient = GetNativeCell(1);
	if (CheckValidClient(iClient))
	{
		decl iClientID;
		if (g_hFeatures[iClient].GetValue(KEY_CID, iClientID) && iClientID != -1)
		{
			char sPassKey[64]; char sPassword[64]; char sQuery[256]; char sBuffer[64];
			GetNativeString(2, sPassKey, sizeof(sPassKey));
			GetNativeString(3, sPassword, sizeof(sPassword));
			
			sBuffer[0] = 0;
			if (sPassKey[0])
			{
				FormatEx(sBuffer, sizeof(sBuffer), "`pass_key` = '%s'", sPassKey);
			}
			if (sPassword[0])
			{
				Format(sBuffer, sizeof(sBuffer), "%s, `password` = '%s'", sBuffer, sPassword);
			}
			
			if (!sBuffer[0])
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

public void SQL_Callback_ChangeClientSettings(Handle hOwner, Handle hQuery, const char[] sError, any UserID)
{
	if (sError[0])
	{
		LogError("SQL_Callback_ChangeClientSettings: %s", sError);
	}
	
	new iClient = CID(UserID);
	if (iClient && SQL_GetAffectedRows(hOwner))
	{
		Clients_CheckVipAccess(iClient, false);
	}
}

public int Native_GetVIPClientTrie(Handle hPlugin, int iNumParams)
{
	decl iClient;
	iClient = GetNativeCell(1);
	if (CheckValidClient(iClient))
	{
		return _:g_hFeatures[iClient];
	}
	return _:INVALID_HANDLE;
}

public int Native_GetClientAuthType(Handle hPlugin, int iNumParams)
{
	decl iClient;
	iClient = GetNativeCell(1);
	if (CheckValidClient(iClient))
	{
		decl VIP_AuthType:AuthType;
		if (g_hFeatures[iClient].GetValue(KEY_AUTHTYPE, AuthType))
		{
			return _:AuthType;
		}
	}
	return -1;
}

public int Native_SendClientVIPMenu(Handle hPlugin, int iNumParams)
{
	decl iClient;
	iClient = GetNativeCell(1);
	if (CheckValidClient(iClient))
	{
		DisplayMenu(g_hVIPMenu, iClient, MENU_TIME_FOREVER);
	}
}

public int Native_SetClientVIP(Handle hPlugin, int iNumParams)
{
	decl iClient;
	iClient = GetNativeCell(1);
	if (CheckValidClient(iClient, false))
	{
		if (g_iClientInfo[iClient] & IS_VIP)
		{
			if (g_iClientInfo[iClient] & IS_AUTHORIZED)
			{
				decl iClientID;
				g_hFeatures[iClient].GetValue(KEY_CID, iClientID);
				if (iClientID != -1)
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
		
		char sGroup[64];
		GetNativeString(4, sGroup, sizeof(sGroup));
		if (UTIL_CheckValidVIPGroup(sGroup))
		{
			new iTime = GetNativeCell(2);
			if (iTime >= 0)
			{
				new VIP_AuthType:AuthType = GetNativeCell(3);
				if (view_as<bool>(GetNativeCell(5)) == true)
				{
					if (AUTH_STEAM > AuthType || AuthType > AUTH_NAME)
					{
						ThrowNativeError(SP_ERROR_NATIVE, "Invalid auth type/Некорректное тип авторизации (%i)", AuthType);
						return false;
					}
					
					UTIL_ADD_VIP_PLAYER(0, iClient, _, iTime, AuthType, sGroup);
				}
				else
				{
					if (iTime == 0)
					{
						Clients_CreateClientVIPSettings(iClient, iTime, AuthType);
					}
					else
					{
						new iCurrentTime = GetTime();
						
						Clients_CreateClientVIPSettings(iClient, iTime + iCurrentTime, AuthType);
						Clients_CreateExpiredTimer(iClient, iTime + iCurrentTime, iCurrentTime);
					}
					
					g_hFeatures[iClient].SetString(KEY_GROUP, sGroup);
					g_hFeatures[iClient].SetValue(KEY_CID, -1);
					
					Clients_LoadVIPFeatures(iClient);
					g_iClientInfo[iClient] |= IS_VIP;
					g_iClientInfo[iClient] |= IS_LOADED;
					g_iClientInfo[iClient] |= IS_AUTHORIZED;
					
					Clients_OnVIPClientLoaded(iClient);
					if (g_CVAR_bAutoOpenMenu)
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

public int Native_RemoveClientVIP(Handle hPlugin, int iNumParams)
{
	decl iClient;
	iClient = GetNativeCell(1);
	if (CheckValidClient(iClient))
	{
		if (view_as<bool>(GetNativeCell(2)) == true)
		{
			decl iClientID;
			if (g_hFeatures[iClient].GetValue(KEY_CID, iClientID) && iClientID != -1)
			{
				DB_RemoveClientFromID(0, iClientID, true);
			}
		}
		
		ResetClient(iClient);
		
		CreateForward_OnVIPClientRemoved(iClient, "Removed by native");
		
		if (view_as<bool>(GetNativeCell(3)))
		{
			DisplayClientInfo(iClient, "expired_info");
		}
		
		return true;
	}
	
	return false;
}

public int Native_IsValidVIPGroup(Handle hPlugin, int iNumParams)
{
	char sGroup[64];
	GetNativeString(1, sGroup, sizeof(sGroup));
	return UTIL_CheckValidVIPGroup(sGroup);
}

public int Native_IsVIPLoaded(Handle hPlugin, int iNumParams)
{
	return ((GLOBAL_INFO & IS_STARTED) && g_hDatabase);
}

public int Native_RegisterFeature(Handle hPlugin, int iNumParams)
{
	char sFeatureName[FEATURE_NAME_LENGTH];
	GetNativeString(1, sFeatureName, sizeof(sFeatureName));
	
	#if DEBUG_MODE
	char sPluginName[FEATURE_NAME_LENGTH];
	GetPluginFilename(hPlugin, sPluginName, FEATURE_NAME_LENGTH);
	DebugMessage("Register feature \"%s\" (%s)", sFeatureName, sPluginName)
	#endif
	
	if (IsValidFeature(sFeatureName) == false)
	{
		if ((GLOBAL_ARRAY).Length == 0)
		{
			RemoveMenuItem(g_hVIPMenu, 0);
		}
		
		GLOBAL_ARRAY.PushString(sFeatureName);
		DebugMessage("PushArrayString -> %i", GLOBAL_ARRAY.FindString(sFeatureName))
		
		new VIP_FeatureType:FType = GetNativeCell(3);
		DebugMessage("FeatureType -> %i", FType)
		
		ArrayList hArray = new ArrayList();
		GLOBAL_TRIE.SetValue(sFeatureName, hArray);
		
		hArray.Push(hPlugin);
		hArray.Push(GetNativeCell(2));
		hArray.Push(FType);
		
		switch (FType)
		{
			case TOGGLABLE:
			{
				hArray.Push(RegClientCookie(sFeatureName, sFeatureName, CookieAccess_Private));
			}
			case SELECTABLE:
			{
				hArray.Push(INVALID_HANDLE);
			}
		}
		
		if (FType != HIDE)
		{
			DataPack hDataPack = new DataPack();
			hDataPack.WriteFunction(GetNativeCell(4));
			hDataPack.WriteFunction(GetNativeCell(5));
			hDataPack.WriteFunction(GetNativeCell(6));
			hArray.Push(hDataPack);
			
			AddFeatureToVIPMenu(sFeatureName);
		}
		
		decl iClient; char sGroup[64];
		for (iClient = 1; iClient <= MaxClients; ++iClient)
		{
			if (IsClientInGame(iClient) && g_iClientInfo[iClient] & IS_VIP)
			{
				if (g_hFeatures[iClient].GetString(KEY_GROUP, sGroup, sizeof(sGroup)))
				{
					KvRewind(g_hGroups);
					if (KvJumpToKey(g_hGroups, sGroup, false))
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

public int Native_UnregisterFeature(Handle hPlugin, int iNumParams)
{
	char sFeatureName[FEATURE_NAME_LENGTH];
	GetNativeString(1, sFeatureName, sizeof(sFeatureName));
	
	if (IsValidFeature(sFeatureName))
	{
		ArrayList hArray;
		if (GLOBAL_TRIE.GetValue(sFeatureName, hArray))
		{
			decl i, VIP_FeatureType:iFeatureType;
			iFeatureType = VIP_FeatureType:hArray.Get(FEATURES_ITEM_TYPE);
			if (iFeatureType == TOGGLABLE)
			{
				delete view_as<Handle>(hArray.Get(FEATURES_COOKIE));
			}
			
			if (iFeatureType != HIDE)
			{
				DataPack hDataPack = view_as<DataPack>(hArray.Get(FEATURES_MENU_CALLBACKS));
				delete hDataPack;
				
				AddFeatureToVIPMenu(sFeatureName);
			}
			
			delete hArray;
			
			GLOBAL_TRIE.Remove(sFeatureName);
			
			i = GLOBAL_ARRAY.FindString(sFeatureName);
			if (i != -1)
			{
				GLOBAL_ARRAY.Erase(i);
			}
			
			if (iFeatureType != HIDE)
			{
				char sItemInfo[FEATURE_NAME_LENGTH]; iSize;
				iSize = GetMenuItemCount(g_hVIPMenu);
				for (i = 0; i < iSize; ++i)
				{
					GetMenuItem(g_hVIPMenu, i, sItemInfo, sizeof(sItemInfo));
					if (strcmp(sItemInfo, sFeatureName, true) == 0)
					{
						RemoveMenuItem(g_hVIPMenu, i);
						break;
					}
				}
				
				if (GetMenuItemCount(g_hVIPMenu) == 0)
				{
					AddMenuItem(g_hVIPMenu, "NO_FEATURES", "NO_FEATURES", ITEMDRAW_DISABLED);
				}
			}
			
			for (i = 1; i <= MaxClients; ++i)
			{
				if (IsClientInGame(i))
				{
					if (g_iClientInfo[i] & IS_VIP)
					{
						g_hFeatures[i].Remove(sFeatureName);
						g_hFeatureStatus[i].Remove(sFeatureName);
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

public int Native_IsValidFeature(Handle hPlugin, int iNumParams)
{
	char sFeatureName[FEATURE_NAME_LENGTH];
	GetNativeString(1, sFeatureName, sizeof(sFeatureName));
	
	return _:IsValidFeature(sFeatureName);
}

public int Native_IsClientFeatureUse(Handle hPlugin, int iNumParams)
{
	decl iClient;
	iClient = GetNativeCell(1);
	if (CheckValidClient(iClient))
	{
		char sFeatureName[FEATURE_NAME_LENGTH];
		GetNativeString(2, sFeatureName, sizeof(sFeatureName));
		
		DebugMessage("Native_IsClientFeatureUse: %N (%i) - %s -> %i", iClient, iClient, sFeatureName, Features_GetStatus(iClient, sFeatureName))
		return (Features_GetStatus(iClient, sFeatureName) == ENABLED);
	}
	
	return false;
}

public int Native_GetClientFeatureStatus(Handle hPlugin, int iNumParams)
{
	decl iClient;
	iClient = GetNativeCell(1);
	if (CheckValidClient(iClient))
	{
		char sFeatureName[FEATURE_NAME_LENGTH];
		GetNativeString(2, sFeatureName, sizeof(sFeatureName));
		
		return _:Features_GetStatus(iClient, sFeatureName);
	}
	
	return _:NO_ACCESS;
}

public int Native_SetClientFeatureStatus(Handle hPlugin, int iNumParams)
{
	decl iClient;
	iClient = GetNativeCell(1);
	if (CheckValidClient(iClient))
	{
		char sFeatureName[FEATURE_NAME_LENGTH]; VIP_ToggleState:OldStatus, VIP_ToggleState:NewStatus;
		GetNativeString(2, sFeatureName, sizeof(sFeatureName));
		OldStatus = Features_GetStatus(iClient, sFeatureName);
		
		NewStatus = VIP_ToggleState:GetNativeCell(3);
		
		ArrayList hArray;
		if (GLOBAL_TRIE.GetValue(sFeatureName, hArray))
		{
			if (VIP_FeatureType:hArray.Get(FEATURES_ITEM_TYPE) == TOGGLABLE)
			{
				DataPack hDataPack = view_as<DataPack>(hArray.Get(FEATURES_MENU_CALLBACKS));
				hDataPack.Position = ITEM_SELECT;
				Function Function_Select = hDataPack.ReadFunction();
				if (Function_Select != INVALID_FUNCTION)
				{
					Function_OnItemToggle(view_as<Handle>(hArray.Get(FEATURES_PLUGIN)), Function_Select, iClient, sFeatureName, OldStatus, NewStatus);
				}
				
				if (OldStatus != NewStatus)
				{
					Features_SetStatus(iClient, sFeatureName, NewStatus);
					return true;
				}
			}
		}
	}
	
	return false;
}

public int Native_GetClientFeatureInt(Handle hPlugin, int iNumParams)
{
	decl iClient;
	iClient = GetNativeCell(1);
	if (CheckValidClient(iClient))
	{
		char sFeatureName[FEATURE_NAME_LENGTH]; iValue;
		GetNativeString(2, sFeatureName, sizeof(sFeatureName));
		
		if (g_hFeatures[iClient].GetValue(sFeatureName, iValue) && iValue != 0)
		{
			return iValue;
		}
	}
	
	return 0;
}

public int Native_GetClientFeatureFloat(Handle hPlugin, int iNumParams)
{
	decl iClient;
	iClient = GetNativeCell(1);
	if (CheckValidClient(iClient))
	{
		char sFeatureName[FEATURE_NAME_LENGTH]; Float:fValue;
		GetNativeString(2, sFeatureName, sizeof(sFeatureName));
		
		if (g_hFeatures[iClient].GetValue(sFeatureName, fValue) && fValue != 0.0)
		{
			return _:fValue;
		}
	}
	return _:0.0;
}

public int Native_GetClientFeatureBool(Handle hPlugin, int iNumParams)
{
	decl iClient;
	iClient = GetNativeCell(1);
	if (CheckValidClient(iClient))
	{
		char sFeatureName[FEATURE_NAME_LENGTH]; bool bValue;
		GetNativeString(2, sFeatureName, sizeof(sFeatureName));
		
		return g_hFeatures[iClient].GetValue(sFeatureName, bValue);
	}
	
	return false;
}

public int Native_GetClientFeatureString(Handle hPlugin, int iNumParams)
{
	decl iClient;
	iClient = GetNativeCell(1);
	if (CheckValidClient(iClient))
	{
		char sFeatureName[64]; char sBuffer[256]; iLen;
		GetNativeString(2, sFeatureName, sizeof(sFeatureName));
		
		iLen = GetNativeCell(4);
		if (g_hFeatures[iClient].GetString(sFeatureName, sBuffer, sizeof(sBuffer)))
		{
			SetNativeString(3, sBuffer, iLen, true);
			return true;
		}
	}
	
	return false;
}

/*
public int Native_GiveClientFeature(Handle hPlugin, int iNumParams)
{
	decl iClient;
	iClient = GetNativeCell(1);
	if(CheckValidClient(iClient))
	{
		char sFeatureName[64]; Handle:hArray; char sFeatureValue[256];
		if(GLOBAL_TRIE.GetValue(sFeatureName, hArray))
		{
			char sFeatureValue[256];
			GetNativeString(3, sFeatureValue, sizeof(sFeatureValue));
			
			if(!(g_iClientInfo[iClient] & IS_VIP))
			{
				Clients_CreateClientVIPSettings(iClient, 0);
				g_hFeatures[iClient].SetValue(KEY_CID, -1);
				g_iClientInfo[iClient] |= IS_VIP;
				g_iClientInfo[iClient] |= IS_LOADED;
				g_iClientInfo[iClient] |= IS_AUTHORIZED;
			}

			switch(VIP_ValueType:hArray.Get(FEATURES_VALUE_TYPE))
			{
				case BOOL:
				{
					g_hFeatures[iClient].SetValue(sFeatureName, view_as<bool>(StringToInt(sFeatureValue)));
				}
				case INT:
				{
					g_hFeatures[iClient].SetValue(sFeatureName, StringToInt(sFeatureValue));
				}
				case FLOAT:
				{
					g_hFeatures[iClient].SetValue(sFeatureName, StringToFloat(sFeatureValue));
				}
				case STRING:
				{
					g_hFeatures[iClient].SetString(sFeatureName, sFeatureValue);
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

public int Native_GetDatabase(Handle hPlugin, int iNumParams)
{
	return _:CloneHandle(g_hDatabase, hPlugin);
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
	new iTimeStamp = GetNativeCell(3);
	if (iTimeStamp > 0)
	{
		new iClient = GetNativeCell(4);
		if (iClient == 0 || CheckValidClient(iClient, false))
		{
			char sBuffer[64];
			UTIL_GetTimeFromStamp(sBuffer, sizeof(sBuffer), iTimeStamp, iClient);
			SetNativeString(1, sBuffer, GetNativeCell(2), true);
			return true;
		}
	}
	
	return false;
}

public int Native_AddStringToggleStatus(Handle hPlugin, int iNumParams)
{
	char sFeatureName[FEATURE_NAME_LENGTH];
	GetNativeString(4, sFeatureName, sizeof(sFeatureName));
	if (IsValidFeature(sFeatureName))
	{
		new iClient = GetNativeCell(5);
		if (CheckValidClient(iClient))
		{
			new iSize = GetNativeCell(3);
			char sBuffer[iSize];
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

bool CheckValidClient(const &iClient, bool bCheckVIP = true)
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
		
		return view_as<bool>(g_iClientInfo[iClient] & IS_VIP);
	}
	
	return true;
}
