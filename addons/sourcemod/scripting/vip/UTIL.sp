
int GET_UID(int iClient)
{
	return iClient ? UID(iClient):0;
}

int GET_CID(int iClient)
{
	if (iClient)
	{
		iClient = CID(iClient);
	}

	return iClient;
}

void UTIL_CloseHandleEx(Handle &hValue)
{
	if (hValue != null)
	{
		delete hValue;
		hValue = null;
	}
}

stock int UTIL_ReplaceChars(char[] szBuffer, int InChar, int OutChar)
{
	int iNum = 0;
	for (int i = 0, iLen = strlen(szBuffer); i < iLen; ++i)
	{
		if (szBuffer[i] == InChar)
		{
			szBuffer[i] = OutChar;
			iNum++;
		}
	}
	
	return iNum;
}

bool UTIL_StrCmpEx(const char[] szString1, const char[] szString2)
{
	int iLen1 = strlen(szString1), 
	iLen2 = strlen(szString2);

	int MaxLen = (iLen1 > iLen2) ? iLen1:iLen2, i;

	for (i = 0; i < MaxLen; i++)
	{
		if (szString1[i] != szString2[i])
		{
			return false;
		}
	}
	
	return true;
}

int UTIL_TimeToSeconds(int iTime)
{
	switch (g_CVAR_iTimeMode)
	{
		case TIME_MODE_SECONDS:return iTime;
		case TIME_MODE_MINUTES:return iTime * 60;
		case TIME_MODE_HOURS:return iTime * 3600;
		case TIME_MODE_DAYS:return iTime * 86400;
	}
	
	return -1;
}

int UTIL_SecondsToTime(int iTime)
{
	switch (g_CVAR_iTimeMode)
	{
		case TIME_MODE_SECONDS:return iTime;
		case TIME_MODE_MINUTES:return iTime / 60;
		case TIME_MODE_HOURS:return iTime / 3600;
		case TIME_MODE_DAYS:return iTime / 86400;
	}
	
	return -1;
}

void UTIL_GetTimeFromStamp(char[] szBuffer, int iMaxLen, int iTimeStamp, int iClient = LANG_SERVER)
{
	if (iTimeStamp > 31536000)
	{
		int years = iTimeStamp / 31536000;
		int days = iTimeStamp / 86400 % 365;
		if (days > 0)
		{
			FormatEx(szBuffer, iMaxLen, "%d%T %d%T", years, "y.", iClient, days, "d.", iClient);
		}
		else
		{
			FormatEx(szBuffer, iMaxLen, "%d%T", years, "y.", iClient);
		}
		return;
	}
	if (iTimeStamp > 86400)
	{
		int days = iTimeStamp / 86400 % 365;
		int hours = (iTimeStamp / 3600) % 24;
		if (hours > 0)
		{
			FormatEx(szBuffer, iMaxLen, "%d%T %d%T", days, "d.", iClient, hours, "h.", iClient);
		}
		else
		{
			FormatEx(szBuffer, iMaxLen, "%d%T", days, "d.", iClient);
		}
		return;
	}
	else
	{
		int Hours = (iTimeStamp / 3600);
		int Mins = (iTimeStamp / 60) % 60;
		int Secs = iTimeStamp % 60;
		
		if (Hours > 0)
		{
			FormatEx(szBuffer, iMaxLen, "%02d:%02d:%02d", Hours, Mins, Secs);
		}
		else
		{
			FormatEx(szBuffer, iMaxLen, "%02d:%02d", Mins, Secs);
		}
	}
}

void UTIL_LoadVipCmd(ConVar &hCvar, ConCmd Call_CMD)
{
	char szPart[64], szBuffer[128];
	int reloc_idx, iPos;
	hCvar.GetString(SZF(szBuffer));
	reloc_idx = 0;
	while ((iPos = SplitString(szBuffer[reloc_idx], ";", SZF(szPart))))
	{
		if (iPos == -1)
		{
			strcopy(SZF(szPart), szBuffer[reloc_idx]);
		}
		else
		{
			reloc_idx += iPos;
		}
		
		TrimString(szPart);
		
		if (szPart[0])
		{
			RegConsoleCmd(szPart, Call_CMD);
			
			if (iPos == -1)
			{
				return;
			}
		}
	}
}

int UTIL_GetConVarAdminFlag(ConVar &hCvar)
{
	char szBuffer[32];
	hCvar.GetString(SZF(szBuffer));
	return ReadFlagString(szBuffer);
}

bool UTIL_CheckValidVIPGroup(const char[] szGroup)
{
	g_hGroups.Rewind();
	return g_hGroups.JumpToKey(szGroup, false);
}

stock int UTIL_SearchCharInString(const char[] szBuffer, int c)
{
	int iNum, i, iLen;
	iNum = 0;
	iLen = strlen(szBuffer);
	for (i = 0; i < iLen; ++i)
	if (szBuffer[i] == c)iNum++;
	
	return iNum;
}

int UTIL_GetAccountIDFromSteamID(const char[] szSteamID)
{
	if (!strncmp(szSteamID, "STEAM_", 6))
	{
		return S2I(szSteamID[10]) << 1 | (szSteamID[8] - 48);
	}

	if (!strncmp(szSteamID, "[U:1:", 5) && szSteamID[strlen(szSteamID)-1] == ']')
	{
		char szBuffer[16];
		strcopy(SZF(szBuffer), szSteamID[5]);
		szBuffer[strlen(szBuffer)-1] = 0;

		return S2I(szBuffer);
	}

	return 0;
}

void UTIL_GetSteamIDFromAccountID(int iAccountID, char[] szSteamID, int iMaxLen)
{
	switch(g_EngineVersion)
	{
		case Engine_CSS, Engine_TF2, Engine_HL2DM, Engine_SourceSDK2007, Engine_BlackMesa:
		{
			FormatEx(szSteamID, iMaxLen, "[U:1:%u]", iAccountID);
		}
		default:
		{
			int iPart = iAccountID % 2;
			iAccountID -= iPart;
			FormatEx(szSteamID, iMaxLen, "STEAM_%d:%d:%d", g_EngineVersion == Engine_CSGO ? 1:0, iPart, iAccountID/2);
		}
		
	}
}

void UTIL_ReloadVIPPlayers(int iClient, bool bNotify)
{
	for (int i = 1; i <= MaxClients; ++i)
	{
		if (IsClientInGame(i))
		{
			Clients_CheckVipAccess(i, false);
		}
	}
	
	if (bNotify)
	{
		ReplyToCommand(iClient, "%t", "VIP_CACHE_REFRESHED");
	}
}
/*
void UTIL_REM_VIP_PLAYER(int iClient = 0, int iTarget = 0, int iAccID = 0, int iClientID, const char[] szReason)
{
	if (g_CVAR_bLogsEnable)
	{
		if(iTarget)
		{
			LogToFile(g_szLogFile, "%T", "REMOVING_PLAYER", LANG_SERVER, iTarget);
		}
	}

	DB_RemoveClientFromID(iClient, iClientID, false);

	ResetClient(iTarget);

	CreateForward_OnVIPClientRemoved(iTarget, szReason);

	DisplayClientInfo(iTarget, "expired_info");
}
*/
void UTIL_ADD_VIP_PLAYER(int iClient = 0, int iTarget = 0, int iAccID = 0, int iTime, const char[] szGroup)
{
	char szQuery[256], szName[MAX_NAME_LENGTH * 2 + 1];
	int iExpires, iAccountID;

	if (iTime)
	{
		iExpires = iTime + GetTime();
	}
	else
	{
		iExpires = iTime;
	}
	
	if (iTarget)
	{
		GetClientName(iTarget, SZF(szQuery));
		g_hDatabase.Escape(szQuery, SZF(szName));
	}
	else
	{
		strcopy(SZF(szName), "unknown");
	}

	if (iTarget)
	{
		iAccountID  = GetSteamAccountID(iTarget);
	}
	else
	{
		iAccountID = iAccID;
	}

	DataPack hDataPack = new DataPack();

	hDataPack.WriteString(szName);
	hDataPack.WriteCell(iAccountID);
	hDataPack.WriteCell(iExpires);	
	hDataPack.WriteString(szGroup);
	hDataPack.WriteCell(iTime);

	hDataPack.WriteCell(GET_UID(iClient));
	hDataPack.WriteCell(GET_UID(iTarget));

	if (GLOBAL_INFO & IS_MySQL)
	{
		FormatEx(SZF(szQuery), "SELECT `id` FROM `vip_users` WHERE `account_id` = %d LIMIT 1;", iAccountID);
		DebugMessage("szQuery: %s", szQuery)
		g_hDatabase.Query(SQL_Callback_CheckVIPClient, szQuery, hDataPack);
		return;
	}

	FormatEx(SZF(szQuery), "INSERT INTO `vip_users` (`account_id`, `name`, `expires`, `group`) VALUES (%d, '%s', %d, '%s');", iAccountID, szName, iExpires, szGroup);
	DebugMessage("szQuery: %s", szQuery)
	g_hDatabase.Query(SQL_Callback_OnVIPClientAdded, szQuery, hDataPack);
}

public void SQL_Callback_CheckVIPClient(Database hOwner, DBResultSet hResult, const char[] szError, any hPack)
{
	DataPack hDataPack = view_as<DataPack>(hPack);

	if (hResult == null || szError[0])
	{
		delete hDataPack;
		LogError("SQL_Callback_CheckVIPClient: %s", szError);
		return;
	}

	hDataPack.Reset();

	if (hResult.FetchRow())
	{
		char szGroup[64];
		hDataPack.ReadString(SZF(szGroup));	// szName
		hDataPack.ReadCell();							// iAccountID
		int iExpires = hDataPack.ReadCell();			// iExpires
		hDataPack.ReadString(SZF(szGroup));	// szGroup
		hDataPack.ReadCell();		// iTime
		hDataPack.ReadCell();		// iClient
		hDataPack.ReadCell();		// iTarget
		int iClientID = hResult.FetchInt(0);
	
		DebugMessage("SQL_Callback_CheckVIPClient: id - %d", iClientID)
		hDataPack.WriteCell(iClientID);
		SetClientOverrides(hPack, iClientID, iExpires, szGroup);
	}
	else
	{
		SQL_FastQuery(g_hDatabase, "SET NAMES 'utf8'");

		char szQuery[256], szName[MAX_NAME_LENGTH * 2 + 1];
		hDataPack.ReadString(SZF(szName));
		int iAccountID = hDataPack.ReadCell();
		FormatEx(SZF(szQuery), "INSERT INTO `vip_users` (`account_id`, `name`) VALUES (%d, '%s');", iAccountID, szName);
		DebugMessage("szQuery: %s", szQuery)
		g_hDatabase.Query(SQL_Callback_CreateVIPClient, szQuery, hPack);
	}
}

public void SQL_Callback_CreateVIPClient(Database hOwner, DBResultSet hResult, const char[] szError, any hPack)
{
	DataPack hDataPack = view_as<DataPack>(hPack);

	if (hResult == null || szError[0])
	{
		delete hDataPack;
		LogError("SQL_Callback_CreateVIPClient: %s", szError);
		return;
	}
	
	if (hResult.AffectedRows)
	{
		int iClientID = hResult.InsertId;
		DebugMessage("SQL_Callback_CreateVIPClient: %d", iClientID)
		hDataPack.Reset();

		char szGroup[64];
		hDataPack.ReadString(SZF(szGroup));	// szName
		hDataPack.ReadCell();	// iAccountID
		int iExpires = hDataPack.ReadCell();				// iExpires
		hDataPack.ReadString(SZF(szGroup));	// szGroup
		hDataPack.ReadCell();		// iTime
		hDataPack.ReadCell();		// iClient
		hDataPack.ReadCell();		// iTarget
		hDataPack.WriteCell(iClientID);

		SetClientOverrides(hPack, iClientID, iExpires, szGroup);
		return;
	}

	delete hDataPack;
}

void SetClientOverrides(DataPack hPack, int iClientID, int iExpires, const char[] szGroup)
{
	char szQuery[512];
	//	FormatEx(SZF(szQuery), "INSERT INTO `vip_overrides` (`user_id`, `server_id`, `expires`, `group`) VALUES (%d, %d, %d, '%s');", iClientID, g_CVAR_iServerID, iExpires, szGroup);
	FormatEx(SZF(szQuery), "INSERT INTO `vip_overrides` (`user_id`, `server_id`, `expires`, `group`) VALUES (%d, %d, %d, '%s') \
		ON DUPLICATE KEY UPDATE `expires` = %d, `group` = '%s';", iClientID, g_CVAR_iServerID, iExpires, szGroup, iExpires, szGroup);
	DebugMessage("szQuery: %s", szQuery)
	g_hDatabase.Query(SQL_Callback_OnVIPClientAdded, szQuery, hPack);
}

public void SQL_Callback_OnVIPClientAdded(Database hOwner, DBResultSet hResult, const char[] szError, any hPack)
{
	DataPack hDataPack = view_as<DataPack>(hPack);

	if (hResult == null || szError[0])
	{
		delete hDataPack;
		LogError("SQL_Callback_OnVIPClientAdded: %s", szError);
		return;
	}
	
	if (hResult.AffectedRows)
	{
		hDataPack.Reset();
	
		int iClient, iTarget, iTime, iExpires, iAccountID;
		char szExpires[64], szName[MAX_NAME_LENGTH], sTime[64], szGroup[64];
		hDataPack.ReadString(SZF(szName));
		iAccountID = hDataPack.ReadCell();
		iExpires = hDataPack.ReadCell();
		hDataPack.ReadString(SZF(szGroup));
		if (szGroup[0] == '\0')
		{
			FormatEx(SZF(szGroup), "%T", "NONE", iClient);
		}
		iTime = hDataPack.ReadCell();
		if (iTime)
		{
			UTIL_GetTimeFromStamp(SZF(szExpires), iTime, iClient);
			FormatTime(SZF(sTime), "%d/%m/%Y - %H:%M", iExpires);
		}
		else
		{
			FormatEx(SZF(szExpires), "%T", "PERMANENT", iClient);
			FormatEx(SZF(sTime), "%T", "NEVER", iClient);
		}
		
		iClient = GET_CID(hDataPack.ReadCell());
		iTarget = GET_CID(hDataPack.ReadCell());

		int iClientID;
		if (GLOBAL_INFO & IS_MySQL)
		{
			iClientID = hDataPack.ReadCell();
		}
		else
		{
		//	hDataPack.Position = view_as<DataPackPos>(9);
			iClientID = hResult.InsertId;
		}

		if (iTarget)
		{
			Clients_CheckVipAccess(iTarget, true);
			CreateForward_OnVIPClientAdded(iTarget, iClient);
		}
		
		char szAuth[32];
		I2S(iAccountID, szAuth);

		if (iClient)
		{
			VIP_PrintToChatClient(iClient, "%t", "ADMIN_ADD_VIP_PLAYER_SUCCESSFULLY", szName, szAuth, iClientID);
		}
		else
		{
			PrintToServer("%T", "ADMIN_ADD_VIP_PLAYER_SUCCESSFULLY", LANG_SERVER, szName, szAuth, iClientID);
		}

		if (g_CVAR_bLogsEnable)
		{
			LogToFile(g_szLogFile, "%T", "LOG_ADMIN_ADD_VIP_IDENTITY_SUCCESSFULLY", LANG_SERVER, iClient, szName, szAuth, iClientID, szExpires, sTime, szGroup);
		}
	}

	delete hDataPack;
} 