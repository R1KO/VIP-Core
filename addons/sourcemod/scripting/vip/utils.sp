
void UTIL_CloseHandleEx(Handle &hValue)
{
	if (hValue != null)
	{
		CloseHandle(hValue);
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
			FormatEx(sBuffer, maxlength, "%d%T", years, "y.");
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
	char sPart[64]; char sBuffer[128]; int reloc_idx, iPos;
	hCvar.GetString(sBuffer, sizeof(sBuffer));
	reloc_idx = 0;
	while ((iPos = SplitString(sBuffer[reloc_idx], ";", sPart, sizeof(sPart))))
	{
		if (iPos == -1)
		{
			strcopy(sPart, sizeof(sPart), sBuffer[reloc_idx]);
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
	hCvar.GetString(sBuffer, sizeof(sBuffer));
	return ReadFlagString(sBuffer);
}

bool UTIL_CheckValidVIPGroup(const char[] sGroup)
{
	(g_hGroups).Rewind();
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

void UTIL_ADD_VIP_PLAYER(int iClient = 0, int iTarget = 0, const char[] sIdentity = "", int iTime, const char[] sGroup)
{
	char sQuery[256], sAuth[32], sName[MAX_NAME_LENGTH * 2 + 1];
	int iExpires;

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
		GetClientName(iTarget, sQuery, sizeof(sQuery));
		g_hDatabase.Escape(sQuery, sName, sizeof(sName));
	}
	else
	{
		strcopy(sName, sizeof(sName), "unknown");
	}

	if (iTarget)
	{
		GetClientAuthId(iTarget, AuthId_Engine, sAuth, sizeof(sAuth));
	}
	else
	{
		strcopy(sAuth, sizeof(sAuth), sIdentity);
	}

	DataPack hDataPack = new DataPack();

	hDataPack.WriteString(sName);
	hDataPack.WriteString(sAuth);
	hDataPack.WriteCell(iExpires);	
	hDataPack.WriteString(sGroup);
	hDataPack.WriteCell(iTime);

	WritePackClient(hDataPack, iClient);
	WritePackClient(hDataPack, iTarget);

	if (GLOBAL_INFO & IS_MySQL)
	{
		FormatEx(sQuery, sizeof(sQuery), "SELECT `id` FROM `vip_users` WHERE `auth` = '%s' LIMIT 1;", sAuth);
		DebugMessage("sQuery: %s", sQuery)
		g_hDatabase.Query(SQL_Callback_CheckVIPClient, sQuery, hDataPack);
		return;
	}

	FormatEx(sQuery, sizeof(sQuery), "INSERT OR REPLACE INTO `vip_users` (`auth`, `name`, `expires`, `group`) VALUES ('%s', '%s', '%i', '%s');", sAuth, sName, iExpires, sGroup);
	g_hDatabase.Query(SQL_Callback_OnVIPClientAdded, sQuery, hDataPack);
}

void WritePackClient(DataPack &hDataPack, int iClient)
{
	if (iClient)
	{
		hDataPack.WriteCell(UID(iClient));
	}
	else
	{
		hDataPack.WriteCell(0);
	}
}

int ReadPackClient(DataPack &hDataPack)
{
	int iClient = hDataPack.ReadCell();		
	if (iClient)
	{
		iClient = CID(iClient);
	}
	
	return iClient;
}

public void SQL_Callback_CheckVIPClient(Database hOwner, DBResultSet hQuery, const char[] sError, any hPack)
{
	if (hQuery == null || sError[0])
	{
		CloseHandle(hPack);
		LogError("SQL_Callback_CheckVIPClient: %s", sError);
		return;
	}
	
	DataPack hDataPack = view_as<DataPack>(hPack);

	hDataPack.Reset();

	if ((hQuery).FetchRow())
	{
		char sGroup[64];
		hDataPack.ReadString(sGroup, sizeof(sGroup));	// sName
		hDataPack.ReadString(sGroup, sizeof(sGroup));	// sAuth
		int iExpires = hDataPack.ReadCell();					// iExpires
		hDataPack.ReadString(sGroup, sizeof(sGroup));	// sGroup
		
		DebugMessage("SQL_Callback_CheckVIPClient: id - %i", hQuery.FetchInt(0))
		SetClientOverrides(hPack, hQuery.FetchInt(0), iExpires, sGroup);
	}
	else
	{
		SQL_FastQuery(g_hDatabase, "SET NAMES 'utf8'");

		char sQuery[256], sAuth[32], sName[MAX_NAME_LENGTH * 2 + 1];
		hDataPack.ReadString(sName, sizeof(sName));
		hDataPack.ReadString(sAuth, sizeof(sAuth));
		FormatEx(sQuery, sizeof(sQuery), "INSERT INTO `vip_users` (`auth`, `name`) VALUES ('%s', '%s');", sAuth, sName);
		DebugMessage("sQuery: %s", sQuery)
		g_hDatabase.Query(SQL_Callback_CreateVIPClient, sQuery, hPack);
	}
}

public void SQL_Callback_CreateVIPClient(Database hOwner, DBResultSet hQuery, const char[] sError, any hPack)
{
	if (hQuery == null || sError[0])
	{
		CloseHandle(hPack);
		LogError("SQL_Callback_CreateVIPClient: %s", sError);
		return;
	}
	
	if (g_hDatabase.AffectedRows)
	{
		DebugMessage("SQL_Callback_CreateVIPClient")
		DataPack hDataPack = view_as<DataPack>(hPack);

		hDataPack.Reset();
		int iClientID = g_hDatabase.InsertId;
		hDataPack.WriteCell(iClientID);
		char sGroup[64]; int iExpires;
		
		hDataPack.ReadString(sGroup, sizeof(sGroup));	// sName
		hDataPack.ReadString(sGroup, sizeof(sGroup));	// sAuth
		iExpires = hDataPack.ReadCell();					// iExpires
		hDataPack.ReadString(sGroup, sizeof(sGroup));	// sGroup
		
		SetClientOverrides(hPack, iClientID, iExpires, sGroup);
	}
	else
	{
		CloseHandle(hPack);
	}
}

void SetClientOverrides(any hPack, int iClientID, int iExpires, const char[] sGroup)
{
	char sQuery[512];
	//	FormatEx(sQuery, sizeof(sQuery), "INSERT INTO `vip_overrides` (`user_id`, `server_id`, `expires`, `group`) VALUES ('%i', '%i', '%i', '%s');", iClientID, g_CVAR_iServerID, iExpires, sGroup);
	FormatEx(sQuery, sizeof(sQuery), "INSERT INTO `vip_overrides` (`user_id`, `server_id`, `expires`, `group`) VALUES ('%i', '%i', '%i', '%s') \
		ON DUPLICATE KEY UPDATE `expires` = '%i', `group` = '%s';", iClientID, g_CVAR_iServerID, iExpires, sGroup, iExpires, sGroup);
	DebugMessage("sQuery: %s", sQuery)
	g_hDatabase.Query(SQL_Callback_OnVIPClientAdded, sQuery, hPack);
}

public void SQL_Callback_OnVIPClientAdded(Database hOwner, DBResultSet hQuery, const char[] sError, any hPack)
{
	if (hQuery == null || sError[0])
	{
		CloseHandle(hPack);
		LogError("SQL_Callback_OnVIPClientAdded: %s", sError);
		return;
	}
	
	if (g_hDatabase.AffectedRows)
	{
		DataPack hDataPack = view_as<DataPack>(hPack);

		hDataPack.Reset();

		int iClientID;
		if (GLOBAL_INFO & IS_MySQL)
		{
			iClientID = hDataPack.ReadCell();
		}
		else
		{
			hDataPack.Position = view_as<DataPackPos>(9);
			iClientID = g_hDatabase.InsertId;
		}
	
		int iClient, iTarget, iTime, iExpires;
		char sExpires[64], sName[MAX_NAME_LENGTH], sTime[64], sAuth[32], sGroup[64];
		hDataPack.ReadString(sName, sizeof(sName));
		hDataPack.ReadString(sAuth, sizeof(sAuth));
		iExpires = hDataPack.ReadCell();
		hDataPack.ReadString(sGroup, sizeof(sGroup));
		if (sGroup[0] == '\0')
		{
			FormatEx(sGroup, sizeof(sGroup), "%T", "NONE", iClient);
		}
		iTime = hDataPack.ReadCell();
		if (iTime)
		{
			UTIL_GetTimeFromStamp(sExpires, sizeof(sExpires), iTime, iClient);
			FormatTime(sTime, sizeof(sTime), "%d/%m/%Y - %H:%M", iExpires);
		}
		else
		{
			FormatEx(sExpires, sizeof(sExpires), "%T", "PERMANENT", iClient);
			FormatEx(sTime, sizeof(sTime), "%T", "NEVER", iClient);
		}
		
		iClient = ReadPackClient(hDataPack);
		iTarget = ReadPackClient(hDataPack);
		
		CloseHandle(hPack);

		if (iTarget)
		{
			Clients_CheckVipAccess(iTarget, true);
			CreateForward_OnVIPClientAdded(iClient, iTarget);
		}
		
		if (iClient)
		{
			VIP_PrintToChatClient(iClient, "%t", "ADMIN_ADD_VIP_PLAYER_SUCCESSFULLY", sName, sAuth, iClientID);
		}
		else
		{
			PrintToServer("%T", "ADMIN_ADD_VIP_PLAYER_SUCCESSFULLY", LANG_SERVER, sName, sAuth, iClientID);
		}

		if (g_CVAR_bLogsEnable)
		{
			LogToFile(g_sLogFile, "%T", "LOG_ADMIN_ADD_VIP_IDENTITY_SUCCESSFULLY", iClient, iClient, sName, sAuth, iClientID, sExpires, sTime, sGroup);
		}
	}
} 