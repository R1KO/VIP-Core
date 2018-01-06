
static Handle g_hGlobalForward_OnVIPLoaded;
static Handle g_hGlobalForward_OnClientLoaded;
static Handle g_hGlobalForward_OnVIPClientLoaded;
static Handle g_hGlobalForward_OnVIPClientAdded;
static Handle g_hGlobalForward_OnVIPClientRemoved;
static Handle g_hGlobalForward_OnPlayerSpawn;
static Handle g_hGlobalForward_OnShowClientInfo;
static Handle g_hGlobalForward_OnFeatureToggle;
static Handle g_hGlobalForward_OnFeatureRegistered;
static Handle g_hGlobalForward_OnFeatureUnregistered;

void API_SetupForwards()
{
	// Global Forwards
	g_hGlobalForward_OnVIPLoaded					= CreateGlobalForward("VIP_OnVIPLoaded", ET_Ignore);
	g_hGlobalForward_OnClientLoaded					= CreateGlobalForward("VIP_OnClientLoaded", ET_Ignore, Param_Cell, Param_Cell);
	g_hGlobalForward_OnVIPClientLoaded				= CreateGlobalForward("VIP_OnVIPClientLoaded", ET_Ignore, Param_Cell);
	g_hGlobalForward_OnVIPClientAdded				= CreateGlobalForward("VIP_OnVIPClientAdded", ET_Ignore, Param_Cell, Param_Cell);
	g_hGlobalForward_OnVIPClientRemoved				= CreateGlobalForward("VIP_OnVIPClientRemoved", ET_Ignore, Param_Cell, Param_String, Param_Cell);
	g_hGlobalForward_OnPlayerSpawn					= CreateGlobalForward("VIP_OnPlayerSpawn", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	g_hGlobalForward_OnShowClientInfo				= CreateGlobalForward("VIP_OnShowClientInfo", ET_Hook, Param_Cell, Param_String, Param_String, Param_Cell);
	g_hGlobalForward_OnFeatureToggle				= CreateGlobalForward("VIP_OnFeatureToggle", ET_Ignore, Param_Cell, Param_String, Param_Cell, Param_CellByRef);
	g_hGlobalForward_OnFeatureRegistered			= CreateGlobalForward("VIP_OnFeatureRegistered", ET_Ignore, Param_String);
	g_hGlobalForward_OnFeatureUnregistered			= CreateGlobalForward("VIP_OnFeatureUnregistered", ET_Ignore, Param_String);
}

// Global Forwards
void CreateForward_OnVIPLoaded()
{
	DBG_API("CreateForward_OnVIPLoaded()")
	Call_StartForward(g_hGlobalForward_OnVIPLoaded);
	Call_Finish();
}

void CreateForward_OnClientLoaded(int iClient)
{
	DBG_API("CreateForward_OnClientLoaded(%N (%d), %b)", iClient, iClient, g_iClientInfo[iClient] & IS_VIP)
	Call_StartForward(g_hGlobalForward_OnClientLoaded);
	Call_PushCell(iClient);
	Call_PushCell(g_iClientInfo[iClient] & IS_VIP);
	Call_Finish();
}

void CreateForward_OnVIPClientLoaded(int iClient)
{
	DBG_API("CreateForward_OnVIPClientLoaded(%N (%d))", iClient, iClient)
	Call_StartForward(g_hGlobalForward_OnVIPClientLoaded);
	Call_PushCell(iClient);
	Call_Finish();
}

void CreateForward_OnVIPClientAdded(int iClient, int iAdmin = 0)
{
	DBG_API("CreateForward_OnVIPClientAdded(%N (%d), %d)", iClient, iClient, iAdmin)
	Call_StartForward(g_hGlobalForward_OnVIPClientAdded);
	Call_PushCell(iClient);
	Call_PushCell(iAdmin);
	Call_Finish();
}

void CreateForward_OnVIPClientRemoved(int iClient, const char[] sReason, int iAdmin = 0)
{
	DBG_API("CreateForward_OnVIPClientRemoved(%N (%d), %d, '%s')", iClient, iClient, iAdmin, sReason)
	Call_StartForward(g_hGlobalForward_OnVIPClientRemoved);
	Call_PushCell(iClient);
	Call_PushString(sReason);
	Call_PushCell(iAdmin);
	Call_Finish();
}

void CreateForward_OnPlayerSpawn(int iClient, int iTeam)
{
	DBG_API("CreateForward_OnPlayerSpawn(%N (%d), %d, %b)", iClient, iClient, iTeam, g_iClientInfo[iClient] & IS_VIP)
	Call_StartForward(g_hGlobalForward_OnPlayerSpawn);
	Call_PushCell(iClient);
	Call_PushCell(iTeam);
	Call_PushCell(g_iClientInfo[iClient] & IS_VIP);
	Call_Finish();
}

bool CreateForward_OnShowClientInfo(int iClient, const char[] szEvent, const char[] szType, KeyValues hKeyValues)
{
	DBG_API("CreateForward_OnShowClientInfo(%N (%d), '%s', '%s')", iClient, iClient, szEvent, szType)
	bool bResult = true;
	Call_StartForward(g_hGlobalForward_OnShowClientInfo);
	Call_PushCell(iClient);
	Call_PushString(szEvent);
	Call_PushString(szType);
	Call_PushCell(hKeyValues);
	Call_Finish(bResult);
	DBG_API("CreateForward_OnShowClientInfo = %b", bResult)

	return bResult;
}

VIP_ToggleState CreateForward_OnFeatureToggle(int iClient, const char[] szFeature, VIP_ToggleState eOldStatus, VIP_ToggleState eNewStatus)
{
	DBG_API("CreateForward_OnFeatureToggle(%N (%d), '%s', %d, %d)", iClient, iClient, szFeature, eOldStatus, eNewStatus)
	Action aResult = Plugin_Continue;
	VIP_ToggleState eResultStatus = eNewStatus;

	Call_StartForward(g_hGlobalForward_OnFeatureToggle);
	Call_PushCell(iClient);
	Call_PushString(szFeature);
	Call_PushCell(eOldStatus);
	Call_PushCellRef(eResultStatus);
	Call_Finish(aResult);
	DBG_API("CreateForward_OnShowClientInfo = %b", bResult)

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
	default:
		{
			return eResultStatus;
		}
	}
	
	return eResultStatus;
}

void CreateForward_OnFeatureRegistered(const char[] szFeature)
{
	DBG_API("CreateForward_OnFeatureRegistered('%s')", szFeature)
	Call_StartForward(g_hGlobalForward_OnFeatureRegistered);
	Call_PushString(szFeature);
	Call_Finish();
}

void CreateForward_OnFeatureUnregistered(const char[] szFeature)
{
	DBG_API("CreateForward_OnFeatureUnregistered('%s')", szFeature)
	Call_StartForward(g_hGlobalForward_OnFeatureUnregistered);
	Call_PushString(szFeature);
	Call_Finish();
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

	RegNative(GetClientFeatureStatus);
	RegNative(SetClientFeatureStatus);

	RegNative(IsClientFeatureUse);

	RegNative(GetClientFeatureInt);
	RegNative(GetClientFeatureFloat);
	RegNative(GetClientFeatureBool);
	RegNative(GetClientFeatureString);

	//	RegNative(GiveClientFeature);

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

#define VIP_CLIENT(%0)	(g_hFeatures[%0] && (g_iClientInfo[%0] & IS_VIP))

public int Native_CheckClient(Handle hPlugin, int iNumParams)
{
	DBG_API("Native_CheckClient(%d)", iNumParams)
	int iClient = GetNativeCell(1);
	DBG_API("iClient = %d", iClient)
	if (CheckValidClient(iClient, false))
	{
		Clients_CheckVipAccess(iClient, view_as<bool>(GetNativeCell(2)));
	}
}

public int Native_IsClientVIP(Handle hPlugin, int iNumParams)
{
	DBG_API("Native_IsClientVIP(%d)", iNumParams)
	int iClient = GetNativeCell(1);
	DBG_API("iClient = %d", iClient)
	if (CheckValidClient(iClient, false))
	{
		DBG_API("IS_VIP = %b", (g_iClientInfo[iClient] & IS_VIP))
		return view_as<bool>(g_iClientInfo[iClient] & IS_VIP);
	}
	
	return false;
}

public int Native_PrintToChatClient(Handle hPlugin, int iNumParams)
{
	DBG_API("Native_PrintToChatClient(%d)", iNumParams)
	int iClient = GetNativeCell(1);
	DBG_API("iClient = %d", iClient)
	if (CheckValidClient(iClient, false))
	{
		char szMessage[256];
		SetGlobalTransTarget(iClient);
		FormatNativeString(0, 2, 3, sizeof(szMessage), _, szMessage);

		Print(iClient, szMessage);
	}
}

public int Native_PrintToChatAll(Handle hPlugin, int iNumParams)
{
	DBG_API("Native_PrintToChatAll(%d)", iNumParams)
	char szMessage[256];
	
	for (int i = 1; i <= MaxClients; ++i)
	{
		if (IsClientInGame(i) && IsFakeClient(i) == false)
		{
			SetGlobalTransTarget(i);
			FormatNativeString(0, 1, 2, sizeof(szMessage), _, szMessage);
			Print(i, szMessage);
		}
	}
}

void Print(int iClient, const char[] szFormat)
{
	char szMessage[512];
	FormatEx(SZF(szMessage), g_EngineVersion == Engine_CSGO ? " \x01%t %s":"\x01%t %s", "VIP_CHAT_PREFIX", szFormat);
	
	ReplaceString(SZF(szMessage), "\\n", "\n");
	ReplaceString(SZF(szMessage), "{DEFAULT}", "\x01");
	ReplaceString(SZF(szMessage), "{GREEN}", "\x04");
	
	switch (g_EngineVersion)
	{
	case Engine_SourceSDK2006, Engine_Left4Dead, Engine_Left4Dead2:
		{
			ReplaceString(SZF(szMessage), "{LIGHTGREEN}", "\x03");
			int iColor = ReplaceColors(SZF(szMessage));
			switch (iColor)
			{
			case -1:	SayText2(iClient, 0, szMessage);
			case 0:		SayText2(iClient, iClient, szMessage);
			default:
				{
					SayText2(iClient, FindPlayerByTeam(iColor), szMessage);
				}
			}
		}
	case Engine_CSS, Engine_TF2, Engine_DODS, Engine_HL2DM:
		{
			ReplaceString(SZF(szMessage), "#", "\x07");
			if (ReplaceString(SZF(szMessage), "{TEAM}", "\x03"))
			{
				SayText2(iClient, iClient, szMessage);
			}
			else
			{
				ReplaceString(SZF(szMessage), "{LIGHTGREEN}", "\x03");
				SayText2(iClient, 0, szMessage);
			}
		}
	case Engine_CSGO:
		{
			static const char szColorName[][] = 
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
			szColorCode[][] = 
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
			
			for (int i = 0; i < sizeof(szColorName); ++i)
			{
				ReplaceString(SZF(szMessage), szColorName[i], szColorCode[i]);
			}
			
			if (ReplaceString(SZF(szMessage), "{TEAM}", "\x03"))
			{
				SayText2(iClient, iClient, szMessage);
			}
			else
			{
				SayText2(iClient, 0, szMessage);
			}
		}
	default:
		{
			ReplaceString(SZF(szMessage), "{TEAM}", "\x03");
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
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == iTeam)return i;
	}
	
	return 0;
}

void SayText2(int iClient, int iAuthor = 0, const char[] szMessage)
{
	int iClients[1];
	iClients[0] = iClient;
	Handle hBuffer = StartMessage("SayText2", iClients, 1, USERMSG_RELIABLE | USERMSG_BLOCKHOOKS);
	if (GetUserMessageType() == UM_Protobuf)
	{
		Protobuf pbBuffer = UserMessageToProtobuf(hBuffer);
		pbBuffer.SetInt("ent_idx", iAuthor);
		pbBuffer.SetBool("chat", true);
		pbBuffer.SetString("msg_name", szMessage);
		pbBuffer.AddString("params", "");
		pbBuffer.AddString("params", "");
		pbBuffer.AddString("params", "");
		pbBuffer.AddString("params", "");
	}
	else
	{
		BfWrite bfBuffer = UserMessageToBfWrite(hBuffer);
		bfBuffer.WriteByte(iAuthor);
		bfBuffer.WriteByte(true);
		bfBuffer.WriteString(szMessage);
	}
	EndMessage();
}

public int Native_LogMessage(Handle hPlugin, int iNumParams)
{
	DBG_API("Native_LogMessage(%d)", iNumParams)
	if (g_CVAR_bLogsEnable)
	{
		char szMessage[512];
		SetGlobalTransTarget(LANG_SERVER);
		FormatNativeString(0, 1, 2, sizeof(szMessage), _, szMessage);
		
		LogToFile(g_szLogFile, szMessage);
	}
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
	if (CheckValidClient(iClient))
	{
		char szGroup[64];
		GetNativeString(2, SZF(szGroup));
		if (UTIL_CheckValidVIPGroup(szGroup))
		{
			if (g_hFeatures[iClient].SetString(KEY_GROUP, szGroup))
			{
				if (view_as<bool>(GetNativeCell(3)))
				{
					int iClientID;
					if (g_hFeatures[iClient].GetValue(KEY_CID, iClientID) && iClientID != -1)
					{
						char szQuery[256];
						FormatEx(SZF(szQuery), "UPDATE `vip_users` SET `group` = '%s' WHERE `account_id` = %d%s;", szGroup, iClientID, g_szSID);
						DBG_SQL_Query(szQuery)
						g_hDatabase.Query(SQL_Callback_ChangeClientSettings, szQuery, UID(iClient));
					}
				}
				
				return true;
			}
		}
		else
		{
			ThrowNativeError(SP_ERROR_NATIVE, "Invalid group/Некорректная VIP-группа (%s)", szGroup);
		}
	}
	return false;
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
			ThrowNativeError(SP_ERROR_NATIVE, "Invalid time/Некорректное время (%i)", iTime);
			return false;
		}
		
		if (g_hFeatures[iClient].SetValue(KEY_EXPIRES, iTime))
		{
			if (view_as<bool>(GetNativeCell(3)))
			{
				int iClientID;
				if (g_hFeatures[iClient].GetValue(KEY_CID, iClientID) && iClientID != -1)
				{
					char szQuery[256];
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
	if (CheckValidClient(iClient, false) && VIP_CLIENT(iClient))
	{
		return view_as<int>(g_hFeatures[iClient]);
	}

	return 0;
}

public int Native_SendClientVIPMenu(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	if (CheckValidClient(iClient))
	{
		bool bSelection = false;

		if(iNumParams == 2)
		{
			bSelection = view_as<bool>(GetNativeCell(2));
		}
		
		if(bSelection)
		{
			g_hVIPMenu.Display(iClient, MENU_TIME_FOREVER);
			return;
		}
		
		int iItem = 0;
		g_hFeatures[iClient].GetValue(KEY_MENUITEM, iItem);

		g_hVIPMenu.DisplayAt(iClient, iItem, MENU_TIME_FOREVER);
	}
}

public int Native_GiveClientVIP(Handle hPlugin, int iNumParams)
{
	int iAdmin = GetNativeCell(1);
	int iClient = GetNativeCell(2);
	int iTime = GetNativeCell(3);
	bool bAddToDB = GetNativeCell(5);

	char szGroup[64];
	GetNativeString(4, SZF(szGroup));

	return API_GiveClientVIP(iAdmin, iClient, iTime, szGroup, bAddToDB);
}

public int Native_SetClientVIP(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	int iTime = GetNativeCell(2);
	bool bAddToDB = GetNativeCell(5);

	char szGroup[64];
	GetNativeString(4, SZF(szGroup));

	return API_GiveClientVIP(0, iClient, iTime, szGroup, bAddToDB);
}

int API_GiveClientVIP(int iAdmin, int iClient, int iTime, const char[] szGroup, bool bAddToDB)
{
	if (CheckValidClient(iClient, false) && (!iAdmin || CheckValidClient(iAdmin, false)))
	{
		if (g_iClientInfo[iClient] & IS_VIP)
		{
			int iClientID;
			g_hFeatures[iClient].GetValue(KEY_CID, iClientID);
			if (iClientID == -1 && bAddToDB)
			{
				ResetClient(iClient);

				CreateForward_OnVIPClientRemoved(iClient, "Removed for VIP-status change", iAdmin);
			}
			else
			{
				return ThrowNativeError(SP_ERROR_NATIVE, "The player %L is already a VIP/Игрок %L уже является VIP-игроком", iClient, iClient);
			}
		}

		if (!UTIL_CheckValidVIPGroup(szGroup))
		{
			return ThrowNativeError(SP_ERROR_NATIVE, "Invalid VIP-group/Некорректная VIP-группа (%s)", szGroup);
		}
		if (iTime < 0)
		{
			return ThrowNativeError(SP_ERROR_NATIVE, "Invalid time/Некорректное время (%d)", iTime);
		}
		
		if (bAddToDB)
		{
			UTIL_ADD_VIP_PLAYER(iAdmin, iClient, _, iTime, szGroup);
			return 0;
		}
		if (iTime == 0)
		{
			Clients_CreateClientVIPSettings(iClient, iTime);
		}
		else
		{
			int iCurrentTime = GetTime();

			Clients_CreateClientVIPSettings(iClient, iTime+iCurrentTime);
			Clients_CreateExpiredTimer(iClient, iTime+iCurrentTime, iCurrentTime);
		}

		g_hFeatures[iClient].SetString(KEY_GROUP, szGroup);
		g_hFeatures[iClient].SetValue(KEY_CID, -1);
		g_iClientInfo[iClient] |= IS_VIP;
		g_iClientInfo[iClient] |= IS_LOADED;

		Clients_LoadVIPFeatures(iClient);

		DisplayClientInfo(iClient, iTime == 0 ? "connect_info_perm":"connect_info_time");

		//	Clients_OnVIPClientLoaded(iClient);
		if (g_CVAR_bAutoOpenMenu)
		{
			g_hVIPMenu.Display(iClient, MENU_TIME_FOREVER);
		}
	}
	
	return 0;
}
/*
public int Native_GivetClientVIP(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(2);
	if (CheckValidClient(iClient, false))
	{
		int iAdmin = GetNativeCell(1);
		bool bToDB = GetNativeCell(5);
		if (g_iClientInfo[iClient] & IS_VIP)
		{
			int iClientID;
			g_hFeatures[iClient].GetValue(KEY_CID, iClientID);
			if (iClientID == -1 && bToDB)
			{
				ResetClient(iClient);
				
				CreateForward_OnVIPClientRemoved(iClient, "Removed for VIP-status change", iAdmin);
			}
			else
			{
				return ThrowNativeError(SP_ERROR_NATIVE, "The player %L is already a VIP/Игрок %L уже является VIP-игроком", iClient, iClient);
			}
		}
		
		char szGroup[64];
		GetNativeString(4, SZF(szGroup));
		if (UTIL_CheckValidVIPGroup(szGroup))
		{
			int iTime = GetNativeCell(3);
			if (iTime >= 0)
			{
				if (bToDB)
				{
					UTIL_ADD_VIP_PLAYER(iAdmin, iClient, _, iTime, szGroup);
				}
				else
				{
					if (iTime == 0)
					{
						Clients_CreateClientVIPSettings(iClient, iTime);
					}
					else
					{
						int iCurrentTime = GetTime();

						Clients_CreateClientVIPSettings(iClient, iTime+iCurrentTime);
						Clients_CreateExpiredTimer(iClient, iTime+iCurrentTime, iCurrentTime);
					}
					
					g_hFeatures[iClient].SetString(KEY_GROUP, szGroup);
					g_hFeatures[iClient].SetValue(KEY_CID, -1);
					g_iClientInfo[iClient] |= IS_VIP;
					g_iClientInfo[iClient] |= IS_LOADED;
					
					Clients_LoadVIPFeatures(iClient);
					
					//	Clients_OnVIPClientLoaded(iClient);
					if (g_CVAR_bAutoOpenMenu)
					{
						g_hVIPMenu.Display(iClient, MENU_TIME_FOREVER);
					}
					
					DisplayClientInfo(iClient, iTime == 0 ? "connect_info_perm":"connect_info_time");
				}
				
				return 0;
			}
			else
			{
				return ThrowNativeError(SP_ERROR_NATIVE, "Invalid time/Некорректное время (%i)", iTime);
			}
		}
		else
		{
			return ThrowNativeError(SP_ERROR_NATIVE, "Invalid VIP-group/Некорректная VIP-группа (%s)", szGroup);
		}
	}
	
	return 0;
}
*/
/*
public int Native_RemoveClientVIP(Handle hPlugin, int iNumParams)
{
	int index = iNumParams-2;
	int iClient = GetNativeCell(index);
	if (CheckValidClient(iClient))
	{
		int iAdmin = 0;

		if(iNumParams == 4)
		{
			iAdmin = GetNativeCell(1);
			if (iAdmin && CheckValidClient(iAdmin, false))
			{
				return false;
			}
		}

		if (GetNativeCell(index+1))
		{
			int iClientID;
			if (g_hFeatures[iClient].GetValue(KEY_CID, iClientID) && iClientID != -1)
			{
				char szName[MAX_NAME_LENGTH];
				GetClientName(iClient, SZF(szName));
				DB_RemoveClientFromID(0, iClientID, true, szName);
			}
		}

		ResetClient(iClient);

		CreateForward_OnVIPClientRemoved(iClient, "Removed by native", iAdmin);

		if (view_as<bool>(GetNativeCell(index+12)))
		{
			DisplayClientInfo(iClient, "expired_info");
		}

		return true;
	}

	return false;
}
*/

public int Native_RemoveClientVIP(Handle hPlugin, int iNumParams)
{
	int iClient, iAdmin;
	bool bInDB, bNotify;
	if(iNumParams == 3)
	{
		iAdmin = 0;
		iClient = GetNativeCell(1);
		bInDB = GetNativeCell(2);
		bNotify = GetNativeCell(3);
	}
	else if(iNumParams == 4)
	{
		iAdmin = GetNativeCell(1);
		iClient = GetNativeCell(2);
		bInDB = GetNativeCell(3);
		bNotify = GetNativeCell(4);
	}
	else
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid number of arguments/Некорректное количество аргументов");
	}

	if (CheckValidClient(iClient))
	{
		if (!iAdmin || CheckValidClient(iAdmin, false))
		{
			if (bInDB)
			{
				int iClientID;
				if (g_hFeatures[iClient].GetValue(KEY_CID, iClientID) && iClientID != -1)
				{
					char szName[MAX_NAME_LENGTH];
					GetClientName(iClient, SZF(szName));
					DB_RemoveClientFromID(0, iClientID, true, szName);
				}
			}
			
			if(g_iClientInfo[iClient] & IS_MENU_OPEN)
			{
				CancelClientMenu(iClient);
			}

			ResetClient(iClient);

			CreateForward_OnVIPClientRemoved(iClient, "Removed by native", iAdmin);

			if (bNotify)
			{
				DisplayClientInfo(iClient, "expired_info");
			}

			return 1;
		}
	}

	return 0;
}

public int Native_IsValidVIPGroup(Handle hPlugin, int iNumParams)
{
	char szGroup[64];
	GetNativeString(1, SZF(szGroup));
	return UTIL_CheckValidVIPGroup(szGroup);
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
	
	if (IsValidFeature(szFeature) == false)
	{
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
			switch (eType)
			{
			case TOGGLABLE:
				{	
					hArray.Push(RegClientCookie(szFeature, szFeature, CookieAccess_Private));
				}
			case SELECTABLE:
				{
					hArray.Push(INVALID_HANDLE);
				}
			}

			DataPack hDataPack = new DataPack();
			hDataPack.WriteFunction(GetNativeCell(4));
			hDataPack.WriteFunction(GetNativeCell(5));
			hDataPack.WriteFunction(GetNativeCell(6));
			hArray.Push(hDataPack);

			if(eType == TOGGLABLE)
			{
				hArray.Push(iNumParams == 7 ? GetNativeCell(7):NO_ACCESS);
			}

			AddFeatureToVIPMenu(szFeature);
		}

		for (int iClient = 1; iClient <= MaxClients; ++iClient)
		{
			if (IsClientInGame(iClient) && g_iClientInfo[iClient] & IS_VIP)
			{
				Clients_LoadVIPFeaturesPre(iClient, szFeature);
			}
		}

		CreateForward_OnFeatureRegistered(szFeature);
		DebugMessage("Feature \"%s\" registered", szFeature)
	}
	else
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Feature \"%s\" already defined/Функция \"%s\" уже существует", szFeature, szFeature);
	}
}

public int Native_UnregisterFeature(Handle hPlugin, int iNumParams)
{
	char szFeature[FEATURE_NAME_LENGTH];
	GetNativeString(1, SZF(szFeature));
	
	if (IsValidFeature(szFeature))
	{
		ArrayList hArray;
		if (GLOBAL_TRIE.GetValue(szFeature, hArray) && view_as<Handle>(hArray.Get(FEATURES_PLUGIN)) == hPlugin)
		{
			VIP_FeatureType eType = view_as<VIP_FeatureType>(hArray.Get(FEATURES_ITEM_TYPE));
			if (eType == TOGGLABLE)
			{
				delete view_as<Handle>(hArray.Get(FEATURES_COOKIE));
			}
			
			if (eType != HIDE)
			{
				DataPack hDataPack = view_as<DataPack>(hArray.Get(FEATURES_MENU_CALLBACKS));
				delete hDataPack;
			}
			
			delete hArray;
			
			GLOBAL_TRIE.Remove(szFeature);
			
			int i = g_hFeaturesArray.FindString(szFeature);
			if (i != -1)
			{
				g_hFeaturesArray.Erase(i);
			}
			
			if (eType != HIDE)
			{
				char szItemInfo[FEATURE_NAME_LENGTH];
				int iSize;
				iSize = (g_hVIPMenu).ItemCount;
				for (i = 0; i < iSize; ++i)
				{
					g_hVIPMenu.GetItem(i, SZF(szItemInfo));
					if (!strcmp(szItemInfo, szFeature, true))
					{
						g_hVIPMenu.RemoveItem(i);
						break;
					}
				}
				
				if (g_hVIPMenu.ItemCount == 0)
				{
					g_hVIPMenu.AddItem("NO_FEATURES", "NO_FEATURES", ITEMDRAW_DISABLED);
				}
			}
			
			for (i = 1; i <= MaxClients; ++i)
			{
				if (IsClientInGame(i))
				{
					if (g_iClientInfo[i] & IS_VIP)
					{
						g_hFeatures[i].Remove(szFeature);
						g_hFeatureStatus[i].Remove(szFeature);
					}
				}
			}
		}

		CreateForward_OnFeatureUnregistered(szFeature);
		DebugMessage("Feature \"%s\" unregistered", szFeature)
	}
	else
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Feature \"%s\" is invalid/Функция \"%s\" не существует", szFeature, szFeature);
	}
}

public int Native_UnregisterMe(Handle hPlugin, int iNumParams)
{
	DebugMessage("FeaturesArraySize: %d", g_hFeaturesArray.Length)
	if (g_hFeaturesArray.Length > 0)
	{
		char szFeature[FEATURE_NAME_LENGTH];
		ArrayList hArray;
		VIP_FeatureType eType;
		int i, j;

		for (i = 0; i < g_hFeaturesArray.Length; ++i)
		{
			g_hFeaturesArray.GetString(i, SZF(szFeature));

			if (GLOBAL_TRIE.GetValue(szFeature, hArray))
			{
				eType = view_as<VIP_FeatureType>(hArray.Get(FEATURES_ITEM_TYPE));
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
				
				g_hFeaturesArray.Erase(i);
				--i;

				if (eType != HIDE)
				{
					char szItemInfo[FEATURE_NAME_LENGTH];
					int iSize;
					iSize = (g_hVIPMenu).ItemCount;
					for (j = 0; j < iSize; ++j)
					{
						g_hVIPMenu.GetItem(j, SZF(szItemInfo));
						if (strcmp(szItemInfo, szFeature, true) == 0)
						{
							g_hVIPMenu.RemoveItem(j);
							break;
						}
					}
					
					if (g_hVIPMenu.ItemCount == 0)
					{
						g_hVIPMenu.AddItem("NO_FEATURES", "NO_FEATURES", ITEMDRAW_DISABLED);
					}
				}
				
				for (j = 1; j <= MaxClients; ++j)
				{
					if (IsClientInGame(j))
					{
						if (g_iClientInfo[j] & IS_VIP)
						{
							g_hFeatures[j].Remove(szFeature);
							g_hFeatureStatus[j].Remove(szFeature);
						}
					}
				}
			}

			CreateForward_OnFeatureUnregistered(szFeature);
			DebugMessage("Feature \"%s\" unregistered", szFeature)
		}
	}
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

	return ThrowNativeError(SP_ERROR_NATIVE, "Feature \"%s\" is invalid/Функция \"%s\" не существует", szFeature, szFeature);
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

	return ThrowNativeError(SP_ERROR_NATIVE, "Feature \"%s\" is invalid/Функция \"%s\" не существует", szFeature, szFeature);
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
				if(iNumParams == 4 && GetNativeCell(4))
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
		char szFeature[64], szBuffer[256];
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

/*
public int Native_GiveClientFeature(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	if (CheckValidClient(iClient))
	{
		char szFeature[64]; ArrayList hArray; char sFeatureValue[256];
		if (GLOBAL_TRIE.GetValue(szFeature, hArray))
		{
			char sFeatureValue[256];
			GetNativeString(3, SZF(sFeatureValue));
			
			if (!(g_iClientInfo[iClient] & IS_VIP))
			{
				Clients_CreateClientVIPSettings(iClient, 0);
				g_hFeatures[iClient].SetValue(KEY_CID, -1);
				g_iClientInfo[iClient] |= IS_VIP;
				g_iClientInfo[iClient] |= IS_LOADED;
				g_iClientInfo[iClient] |= IS_AUTHORIZED;
			}

			switch (view_as<VIP_ValueType>(hArray.Get(FEATURES_VALUE_TYPE)))
			{
				case BOOL:
				{
					g_hFeatures[iClient].SetValue(szFeature, view_as<bool>(StringToInt(sFeatureValue)));
				}
				case INT:
				{
					g_hFeatures[iClient].SetValue(szFeature, StringToInt(sFeatureValue));
				}
				case FLOAT:
				{
					g_hFeatures[iClient].SetValue(szFeature, StringToFloat(sFeatureValue));
				}
				case STRING:
				{
					g_hFeatures[iClient].SetString(szFeature, sFeatureValue);
				}
				default:
				{
					ResetClient(iClient);
					ThrowNativeError(SP_ERROR_NATIVE, "Invalid feature value (%s). The feature is of type VIP_NULL", sFeatureValue);
					return false;
				}
			}

			Features_SetStatus(iClient, szFeature, ENABLED);
			
			if (view_as<VIP_FeatureType>(hArray.Get(FEATURES_ITEM_TYPE)) == TOGGLABLE)
			{
				Function Function_Select = view_as<Function>(hArray.Get(FEATURES_ITEM_SELECT));
				
				if (Function_Select != INVALID_FUNCTION)
				{
					eNewStatus = Function_OnItemToggle(view_as<Handle>(hArray.Get(FEATURES_PLUGIN)), Function_Select, iClient, szFeature, NO_ACCESS, ENABLED);
				}
			}

			return true;
		}

		ThrowNativeError(SP_ERROR_NATIVE, "Invalid feature (%s)", szFeature);
	}

	
	return false;
}
*/

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
		if (iClient == 0 || CheckValidClient(iClient, false))
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
	if (IsValidFeature(szFeature))
	{
		int iClient = GetNativeCell(5);
		if (CheckValidClient(iClient))
		{
			int iSize = GetNativeCell(3);
			char[] szBuffer = new char[iSize]; // char szBuffer[iSize];
			GetNativeString(1, szBuffer, iSize);
			Format(szBuffer, iSize, "%s [%T]", szBuffer, g_szToggleStatus[view_as<int>(Features_GetStatus(iClient, szFeature))], iClient);
			SetNativeString(2, szBuffer, iSize, true);
		}
	}
	else
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Feature \"%s\" is invalid/Функция \"%s\" не существует", szFeature, szFeature);
	}
}

bool CheckValidClient(const int &iClient, bool bCheckVIP = true)
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