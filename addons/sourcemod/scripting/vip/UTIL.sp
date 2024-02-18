

int GET_UID(int iClient)
{
	return iClient > 0 ? UID(iClient):iClient;
}

int GET_CID(int iClient)
{
	if (iClient > 0)
	{
		iClient = CID(iClient);
		if(!iClient)
		{
			return -1;
		}
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

int UTIL_GetConVarAdminFlag(ConVar hCvar)
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
			FormatEx(szSteamID, iMaxLen, "STEAM_%d:%d:%d", g_EngineVersion == Engine_CSGO ? 1 : 0, iPart, iAccountID/2);
		}
		
	}
}

void UTIL_GetClientInfo(int iClient, char[] szBuffer, int iMaxLen)
{
	char szName[MNL], szAuth[32], szIP[24];
	GetClientName(iClient, SZF(szName));
	GetClientAuthId(iClient, AuthId_Steam2, SZF(szAuth));
	GetClientIP(iClient, SZF(szIP));
	
	FormatEx(szBuffer, iMaxLen, "%s (%s, %s)", szName, szAuth, szIP);
}

void UTIL_ReloadVIPPlayers(int iClient, bool bNotify)
{
	for (int i = 1; i <= MaxClients; ++i)
	{
		if (IsClientInGame(i))
		{
			Clients_CheckVipAccess(i, false, true);
		}
	}
	
	if (bNotify)
	{
		UTIL_Reply(iClient, "%t", "VIP_CACHE_REFRESHED");
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

void UTIL_Reply(int iClient, const char[] szMsg, any ...)
{
	if(iClient < 0)
	{
		return;
	}

	char szMessage[1024];
	SetGlobalTransTarget(iClient);
	VFormat(SZF(szMessage), szMsg, 3);
	if (iClient)
	{
		VIP_PrintToChatClient(iClient, szMessage);
	}
	else
	{
		Colors_RemoveColors(szMessage);
		PrintToServer(szMessage);
	}
}

void UTIL_ADD_VIP_PLAYER(int iAdmin = 0,
						int iTarget = 0,
						int iAccID = 0,
						int iDuration,
						const char[] szGroup,
						const char[] szByWho = NULL_STRING)
{
	char szQuery[PMP*2], szName[MNL*2+1];
	char szAdmin[PMP], szTargetInfo[PMP];
	int iExpires, iAccountID;

	if (iDuration)
	{
		iExpires = iDuration + GetTime();
	}
	else
	{
		iExpires = iDuration;
	}
	
	if (iTarget)
	{
		GetClientName(iTarget, SZF(szQuery));
		g_hDatabase.Escape(szQuery, SZF(szName));
		iAccountID  = GetSteamAccountID(iTarget);
		UTIL_GetClientInfo(iTarget, SZF(szTargetInfo));
	}
	else
	{
		strcopy(SZF(szName), "unknown");
		iAccountID = iAccID;
		UTIL_GetSteamIDFromAccountID(iAccountID, SZF(szQuery));
		FormatEx(SZF(szTargetInfo), "unknown (%s, unknown)", szQuery);
	}

	if (iAccountID == 0)
	{
		UTIL_Reply(iAdmin, "%t", "ADMIN_VIP_ADD_FAILED");
		return;
	}

	DataPack hDataPack = new DataPack();

	// Admin

	switch(iAdmin)
	{
		case REASON_PLUGIN:
		{
			FormatEx(SZF(szAdmin), "%T %s", "BY_PLUGIN", LANG_SERVER, szByWho);
		}
		case 0:
		{
			FormatEx(SZF(szAdmin), "%T", "BY_SERVER", LANG_SERVER);
		}
		default:
		{
			char szAdminInfo[128];
			UTIL_GetClientInfo(iAdmin, SZF(szAdminInfo));
			FormatEx(SZF(szAdmin), "%T %s", "BY_ADMIN", LANG_SERVER, szAdminInfo);
			iAdmin = UID(iAdmin);
		}
	}
	hDataPack.WriteCell(iAdmin);
	hDataPack.WriteString(szAdmin);

	// Target
	hDataPack.WriteCell(GET_UID(iTarget));
	hDataPack.WriteCell(iAccountID);
	hDataPack.WriteString(szTargetInfo);

	// Data
	hDataPack.WriteCell(iDuration);
	hDataPack.WriteCell(iExpires);	
	hDataPack.WriteString(szGroup);

	int iLastVisit = iTarget ? GetTime():0;
	
	if (GLOBAL_INFO & IS_MySQL)
	{
		FormatEx(SZF(szQuery), "INSERT INTO `vip_users` (`account_id`, `sid`, `expires`, `group`, `name`, `lastvisit`) VALUES (%d, %d, %d, '%s', '%s', %d) \
		ON DUPLICATE KEY UPDATE `expires` = %d, `group` = '%s';", iAccountID, g_CVAR_iServerID, iExpires, szGroup, szName, iLastVisit, iExpires, szGroup);
		DBG_SQL_Query(szQuery)
		g_hDatabase.Query(SQL_Callback_OnVIPClientAdded, szQuery, hDataPack);

		return;
	}

	FormatEx(SZF(szQuery), "INSERT OR REPLACE INTO `vip_users` (`account_id`, `name`, `expires`, `group`, `lastvisit`) VALUES (%d, '%s', %d, '%s', %d);", iAccountID, szName, iExpires, szGroup, iLastVisit);
	DBG_SQL_Query(szQuery)
	g_hDatabase.Query(SQL_Callback_OnVIPClientAdded, szQuery, hDataPack);
}

public void SQL_Callback_OnVIPClientAdded(Database hOwner, DBResultSet hResult, const char[] szError, any hPack)
{
	DBG_SQL_Response("SQL_Callback_OnVIPClientAdded")
	DataPack hDataPack = view_as<DataPack>(hPack);
	hDataPack.Reset();

	// Admin
	int iAdmin = GET_CID(hDataPack.ReadCell());

	if (hResult == null || szError[0])
	{
		delete hDataPack;

		if (iAdmin >= 0)
		{
			UTIL_Reply(iAdmin, "%t", "ADMIN_VIP_ADD_FAILED");
		}

		LogError("SQL_Callback_OnVIPClientAdded: %s", szError);
		return;
	}
	
	DBG_SQL_Response("hResult.AffectedRows = %d", hResult.AffectedRows)

	if (!hResult.AffectedRows)
	{
		delete hDataPack;

		if (iAdmin >= 0)
		{
			UTIL_Reply(iAdmin, "%t", "ADMIN_VIP_ADD_FAILED");
		}
		return;
	}

	int iTarget, iDuration, iExpires, iAccountID;
	char szAdmin[PMP], szTargetInfo[PMP], szExpires[64], szDuration[64], szGroup[64];
	
	hDataPack.ReadString(SZF(szAdmin));
	
	// Target
	iTarget = GET_CID(hDataPack.ReadCell());
	iAccountID = hDataPack.ReadCell();
	hDataPack.ReadString(SZF(szTargetInfo));

	// Data
	iDuration = hDataPack.ReadCell();
	iExpires = hDataPack.ReadCell();
	hDataPack.ReadString(SZF(szGroup));

	delete hDataPack;

	if (iTarget > 0)
	{
		Clients_CheckVipAccess(iTarget, true);
		CreateForward_OnVIPClientAdded(iTarget, iAdmin);
	}
	
	char szAuth[32];
	I2S(iAccountID, szAuth);

	if (iAdmin >= 0)
	{
		if (iDuration)
		{
			UTIL_GetTimeFromStamp(SZF(szDuration), iDuration, iAdmin);
			FormatTime(SZF(szExpires), "%d/%m/%Y - %H:%M", iExpires);
		}
		else
		{
			FormatEx(SZF(szDuration), "%T", "PERMANENT", iAdmin);
			FormatEx(SZF(szExpires), "%T", "NEVER", iAdmin);
		}
		UTIL_Reply(iAdmin, "%t", "ADMIN_VIP_ADD_SUCCESS", szTargetInfo, iAccountID);
	}

	if (g_CVAR_bLogsEnable)
	{
		if (iDuration)
		{
			UTIL_GetTimeFromStamp(SZF(szExpires), iDuration, LANG_SERVER);
		}
		else
		{
			FormatEx(SZF(szExpires), "%T", "PERMANENT", LANG_SERVER);
			FormatEx(SZF(szExpires), "%T", "NEVER", LANG_SERVER);
		}
		LogToFile(g_szLogFile, "%T", "LOG_VIP_ADDED", LANG_SERVER, szTargetInfo, iAccountID, szDuration, szExpires, szGroup, szAdmin);
	}
}