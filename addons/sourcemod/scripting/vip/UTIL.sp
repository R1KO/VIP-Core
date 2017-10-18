
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

stock int UTIL_ReplaceChars(char[] sBuffer, int InChar, int OutChar)
{
	int iNum = 0;
	for (int i = 0, iLen = strlen(sBuffer); i < iLen; ++i)
	{
		if (sBuffer[i] == InChar)
		{
			sBuffer[i] = OutChar;
			iNum++;
		}
	}
	
	return iNum;
}

bool UTIL_StrCmpEx(const char[] sString1, const char[] sString2)
{
	int MaxLen, i;
	
	int iLen1 = strlen(sString1), 
	iLen2 = strlen(sString2);
	
	MaxLen = (iLen1 > iLen2) ? iLen1:iLen2;
	
	for (i = 0; i < MaxLen; i++)
	{
		if (sString1[i] != sString2[i])
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

void UTIL_GetTimeFromStamp(char[] sBuffer, int maxlength, int iTimeStamp, int iClient = LANG_SERVER)
{
	if (iTimeStamp > 31536000)
	{
		int years = iTimeStamp / 31536000;
		int days = iTimeStamp / 86400 % 365;
		if (days > 0)
		{
			FormatEx(sBuffer, maxlength, "%d%T %d%T", years, "y.", iClient, days, "d.", iClient);
		}
		else
		{
			FormatEx(sBuffer, maxlength, "%d%T", years, "y.", iClient);
		}
		return;
	}
	if (iTimeStamp > 86400)
	{
		int days = iTimeStamp / 86400 % 365;
		int hours = (iTimeStamp / 3600) % 24;
		if (hours > 0)
		{
			FormatEx(sBuffer, maxlength, "%d%T %d%T", days, "d.", iClient, hours, "h.", iClient);
		}
		else
		{
			FormatEx(sBuffer, maxlength, "%d%T", days, "d.", iClient);
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
			FormatEx(sBuffer, maxlength, "%02d:%02d:%02d", Hours, Mins, Secs);
		}
		else
		{
			FormatEx(sBuffer, maxlength, "%02d:%02d", Mins, Secs);
		}
	}
}

void UTIL_LoadVipCmd(ConVar &hCvar, ConCmd Call_CMD)
{
	char sPart[64], sBuffer[128];
	int reloc_idx, iPos;
	hCvar.GetString(SZF(sBuffer));
	reloc_idx = 0;
	while ((iPos = SplitString(sBuffer[reloc_idx], ";", SZF(sPart))))
	{
		if (iPos == -1)
		{
			strcopy(SZF(sPart), sBuffer[reloc_idx]);
		}
		else
		{
			reloc_idx += iPos;
		}
		
		TrimString(sPart);
		
		if (sPart[0])
		{
			RegConsoleCmd(sPart, Call_CMD);
			
			if (iPos == -1)
			{
				return;
			}
		}
	}
}

int UTIL_GetConVarAdminFlag(ConVar &hCvar)
{
	char sBuffer[32];
	hCvar.GetString(SZF(sBuffer));
	return ReadFlagString(sBuffer);
}

bool UTIL_CheckValidVIPGroup(const char[] sGroup)
{
	g_hGroups.Rewind();
	return g_hGroups.JumpToKey(sGroup, false);
}

stock int UTIL_SearchCharInString(const char[] sBuffer, int c)
{
	int iNum, i, iLen;
	iNum = 0;
	iLen = strlen(sBuffer);
	for (i = 0; i < iLen; ++i)
	if (sBuffer[i] == c)iNum++;
	
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

void UTIL_ADD_VIP_PLAYER(int iClient = 0, int iTarget = 0, int iAccID = 0, int iTime, const char[] sGroup)
{
	char sQuery[256], sName[MAX_NAME_LENGTH * 2 + 1];
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
		GetClientName(iTarget, SZF(sQuery));
		g_hDatabase.Escape(sQuery, SZF(sName));
	}
	else
	{
		strcopy(SZF(sName), "unknown");
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

	hDataPack.WriteString(sName);
	hDataPack.WriteCell(iAccountID);
	hDataPack.WriteCell(iExpires);	
	hDataPack.WriteString(sGroup);
	hDataPack.WriteCell(iTime);

	hDataPack.WriteCell(GET_UID(iClient));
	hDataPack.WriteCell(GET_UID(iTarget));

	if (GLOBAL_INFO & IS_MySQL)
	{
		FormatEx(SZF(sQuery), "SELECT `id` FROM `vip_users` WHERE `account_id` = %d LIMIT 1;", iAccountID);
		DebugMessage("sQuery: %s", sQuery)
		g_hDatabase.Query(SQL_Callback_CheckVIPClient, sQuery, hDataPack);
		return;
	}

	FormatEx(SZF(sQuery), "INSERT INTO `vip_users` (`account_id`, `name`, `expires`, `group`) VALUES (%d, '%s', %d, '%s');", iAccountID, sName, iExpires, sGroup);
	g_hDatabase.Query(SQL_Callback_OnVIPClientAdded, sQuery, hDataPack);
}

public void SQL_Callback_CheckVIPClient(Database hOwner, DBResultSet hResult, const char[] sError, any hPack)
{
	DataPack hDataPack = view_as<DataPack>(hPack);

	if (hResult == null || sError[0])
	{
		delete hDataPack;
		LogError("SQL_Callback_CheckVIPClient: %s", sError);
		return;
	}

	hDataPack.Reset();

	if (hResult.FetchRow())
	{
		char sGroup[64];
		hDataPack.ReadString(SZF(sGroup));	// sName
		hDataPack.ReadCell();							// iAccountID
		int iExpires = hDataPack.ReadCell();			// iExpires
		hDataPack.ReadString(SZF(sGroup));	// sGroup
		hDataPack.ReadCell();		// iTime
		hDataPack.ReadCell();		// iClient
		hDataPack.ReadCell();		// iTarget
		int iClientID = hResult.FetchInt(0);
	
		DebugMessage("SQL_Callback_CheckVIPClient: id - %d", iClientID)
		hDataPack.WriteCell(iClientID);
		SetClientOverrides(hPack, iClientID, iExpires, sGroup);
	}
	else
	{
		SQL_FastQuery(g_hDatabase, "SET NAMES 'utf8'");

		char sQuery[256], sName[MAX_NAME_LENGTH * 2 + 1];
		hDataPack.ReadString(SZF(sName));
		int iAccountID = hDataPack.ReadCell();
		FormatEx(SZF(sQuery), "INSERT INTO `vip_users` (`account_id`, `name`) VALUES (%d, '%s');", iAccountID, sName);
		DebugMessage("sQuery: %s", sQuery)
		g_hDatabase.Query(SQL_Callback_CreateVIPClient, sQuery, hPack);
	}
}

public void SQL_Callback_CreateVIPClient(Database hOwner, DBResultSet hResult, const char[] sError, any hPack)
{
	DataPack hDataPack = view_as<DataPack>(hPack);

	if (hResult == null || sError[0])
	{
		delete hDataPack;
		LogError("SQL_Callback_CreateVIPClient: %s", sError);
		return;
	}
	
	if (hResult.AffectedRows)
	{
		int iClientID = hResult.InsertId;
		DebugMessage("SQL_Callback_CreateVIPClient: %d", iClientID)
		hDataPack.Reset();

		char sGroup[64];
		hDataPack.ReadString(SZF(sGroup));	// sName
		hDataPack.ReadCell();	// iAccountID
		int iExpires = hDataPack.ReadCell();				// iExpires
		hDataPack.ReadString(SZF(sGroup));	// sGroup
		hDataPack.ReadCell();		// iTime
		hDataPack.ReadCell();		// iClient
		hDataPack.ReadCell();		// iTarget
		hDataPack.WriteCell(iClientID);

		SetClientOverrides(hPack, iClientID, iExpires, sGroup);
		return;
	}

	delete hDataPack;
}

void SetClientOverrides(DataPack hPack, int iClientID, int iExpires, const char[] sGroup)
{
	char sQuery[512];
	//	FormatEx(SZF(sQuery), "INSERT INTO `vip_overrides` (`user_id`, `server_id`, `expires`, `group`) VALUES (%d, %d, %d, '%s');", iClientID, g_CVAR_iServerID, iExpires, sGroup);
	FormatEx(SZF(sQuery), "INSERT INTO `vip_overrides` (`user_id`, `server_id`, `expires`, `group`) VALUES (%d, %d, %d, '%s') \
		ON DUPLICATE KEY UPDATE `expires` = %d, `group` = '%s';", iClientID, g_CVAR_iServerID, iExpires, sGroup, iExpires, sGroup);
	DebugMessage("sQuery: %s", sQuery)
	g_hDatabase.Query(SQL_Callback_OnVIPClientAdded, sQuery, hPack);
}

public void SQL_Callback_OnVIPClientAdded(Database hOwner, DBResultSet hResult, const char[] sError, any hPack)
{
	DataPack hDataPack = view_as<DataPack>(hPack);

	if (hResult == null || sError[0])
	{
		delete hDataPack;
		LogError("SQL_Callback_OnVIPClientAdded: %s", sError);
		return;
	}
	
	if (hResult.AffectedRows)
	{
		hDataPack.Reset();
	
		int iClient, iTarget, iTime, iExpires, iAccountID;
		char sExpires[64], sName[MAX_NAME_LENGTH], sTime[64], sGroup[64];
		hDataPack.ReadString(SZF(sName));
		iAccountID = hDataPack.ReadCell();
		iExpires = hDataPack.ReadCell();
		hDataPack.ReadString(SZF(sGroup));
		if (sGroup[0] == '\0')
		{
			FormatEx(SZF(sGroup), "%T", "NONE", iClient);
		}
		iTime = hDataPack.ReadCell();
		if (iTime)
		{
			UTIL_GetTimeFromStamp(SZF(sExpires), iTime, iClient);
			FormatTime(SZF(sTime), "%d/%m/%Y - %H:%M", iExpires);
		}
		else
		{
			FormatEx(SZF(sExpires), "%T", "PERMANENT", iClient);
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
			VIP_PrintToChatClient(iClient, "%t", "ADMIN_ADD_VIP_PLAYER_SUCCESSFULLY", sName, szAuth, iClientID);
		}
		else
		{
			PrintToServer("%T", "ADMIN_ADD_VIP_PLAYER_SUCCESSFULLY", LANG_SERVER, sName, szAuth, iClientID);
		}

		if (g_CVAR_bLogsEnable)
		{
			LogToFile(g_sLogFile, "%T", "LOG_ADMIN_ADD_VIP_IDENTITY_SUCCESSFULLY", LANG_SERVER, iClient, sName, szAuth, iClientID, sExpires, sTime, sGroup);
		}
	}

	delete hDataPack;
} 