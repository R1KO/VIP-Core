
void UTIL_CloseHandleEx(Handle &hValue)
{
	if(hValue != INVALID_HANDLE)
	{
		CloseHandle(hValue);
		hValue = INVALID_HANDLE;
	}
}

stock int UTIL_ReplaceChars(char[] sBuffer, int InChar, int OutChar)
{
	new iNum = 0;
	for (new i = 0, iLen = strlen(sBuffer); i < iLen; ++i)
	{
		if(sBuffer[i] == InChar)
		{
			sBuffer[i] = OutChar;
			iNum++;
		}
	}

	return iNum;
}

bool UTIL_StrCmpEx(const char[] sString1, const char[] sString2)
{
	decl MaxLen, i;

	new iLen1 = strlen(sString1),
		iLen2 = strlen(sString2);

	MaxLen = (iLen1 > iLen2) ? iLen1:iLen2;

	for (i = 0; i < MaxLen; i++)
	{
		if(sString1[i] != sString2[i])
		{
			return false;
		}
	}

	return true;
}

int UTIL_TimeToSeconds(int iTime)
{
	switch(g_CVAR_iTimeMode)
	{
		case TIME_MODE_SECONDS:	return iTime;
		case TIME_MODE_MINUTES:	return iTime*60;
		case TIME_MODE_HOURS:		return iTime*3600;
		case TIME_MODE_DAYS:		return iTime*86400;
	}

	return -1;
}

int UTIL_SecondsToTime(int iTime)
{
	switch(g_CVAR_iTimeMode)
	{
		case TIME_MODE_SECONDS:	return iTime;
		case TIME_MODE_MINUTES:	return iTime/60;
		case TIME_MODE_HOURS:		return iTime/3600;
		case TIME_MODE_DAYS:		return iTime/86400;
	}

	return -1;
}

void UTIL_GetTimeFromStamp(char[] sBuffer, int maxlength, int iTimeStamp, int iClient = LANG_SERVER)
{
	if (iTimeStamp > 31536000)
	{
		new years = iTimeStamp / 31536000;
		new days = iTimeStamp / 86400 % 365;
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
		new days = iTimeStamp / 86400 % 365;
		new hours = (iTimeStamp / 3600) % 24;
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
		new Hours = (iTimeStamp / 3600);
		new Mins = (iTimeStamp / 60) % 60;
		new Secs = iTimeStamp % 60;
		
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

void UTIL_LoadVipCmd(Handle &hCvar, ConCmd Call_CMD)
{
	char sPart[64]; char sBuffer[128]; reloc_idx, iPos;
	GetConVarString(hCvar, sBuffer, sizeof(sBuffer));
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

int UTIL_GetConVarAdminFlag(Handle &hCvar)
{
	char sBuffer[32];
	GetConVarString(hCvar, sBuffer, sizeof(sBuffer));
	return ReadFlagString(sBuffer);
}

bool UTIL_CheckValidVIPGroup(const char[] sGroup)
{
	KvRewind(g_hGroups);
	return KvJumpToKey(g_hGroups, sGroup, false);
}

stock int UTIL_SearchCharInString(const char[] sBuffer, int c)
{
	decl iNum, i, iLen;
	iNum = 0;
	iLen = strlen(sBuffer);
	for (i = 0; i < iLen; ++i)
		if(sBuffer[i] == c) iNum++;
	
	return iNum;
}

void UTIL_ReloadVIPPlayers(int iClient, bool bNotify)
{
	for(new i = 1; i <= MaxClients; ++i)
	{
		if (IsClientInGame(i))
		{
			Clients_CheckVipAccess(i, false);
		}
	}

	if(bNotify)
	{
		ReplyToCommand(iClient, "%t", "VIP_CACHE_REFRESHED");
	}
}

void UTIL_ADD_VIP_PLAYER(const int iClient = 0, const int iTarget = 0, const char[] sIdentity = "", const int iTime, VIP_AuthType AuthType, const char[] sGroup = "")
{
	char sQuery[256]; char sAuth[32]; char sName[MAX_NAME_LENGTH*2+1]; iExpires, Handle:hDataPack;

	if(iTime)
	{
		iExpires = iTime + GetTime();
	}
	else
	{
		iExpires = iTime;
	}

	if(iTarget)
	{
		GetClientName(iTarget, sQuery, sizeof(sQuery));
		SQL_EscapeString(g_hDatabase, sQuery, sName, sizeof(sName));
	}
	else
	{
		strcopy(sName, sizeof(sName), "unknown");
	}

	switch(AuthType)
	{
		case AUTH_STEAM:
		{
			if(iTarget)
			{
				GetClientAuthId(iTarget, AuthId_Engine, sAuth, sizeof(sAuth));
			}
			else
			{
				strcopy(sAuth, sizeof(sAuth), sIdentity);
			}
		}
		case AUTH_IP:
		{
			if(iTarget)
			{
				GetClientIP(iTarget, sAuth, sizeof(sAuth));
			}
			else
			{
				strcopy(sAuth, sizeof(sAuth), sIdentity);
			}
		}
		case AUTH_NAME:
		{
			if(iTarget)
			{
				strcopy(sAuth, sizeof(sAuth), sName);
			}
			else
			{
				SQL_EscapeString(g_hDatabase, sIdentity, sAuth, sizeof(sAuth));
				strcopy(sName, sizeof(sName), sAuth);
			}
		}
	}

	if (GLOBAL_INFO & IS_MySQL)
	{
		hDataPack = CreateDataPack();
		WritePackString(hDataPack, sName);
		WritePackCell(hDataPack, AuthType);
		WritePackString(hDataPack, sAuth);
		WritePackCell(hDataPack, iExpires);
		WritePackString(hDataPack, sGroup);
		WritePackCell(hDataPack, iTime);

		WritePackClient(hDataPack, iClient);
		WritePackClient(hDataPack, iTarget);

		FormatEx(sQuery, sizeof(sQuery), "SELECT `id` FROM `vip_users` WHERE `auth` = '%s' AND `auth_type` = '%i' LIMIT 1;", sAuth, AuthType);
		DebugMessage("sQuery: %s", sQuery)
		SQL_TQuery(g_hDatabase, SQL_Callback_CheckVIPClient, sQuery, hDataPack);
		return;
	}

//	FormatEx(sQuery, sizeof(sQuery), "INSERT INTO `vip_users` (`auth`, `auth_type`, `name`) VALUES ('%s', '%i', '%s');", sAuth, AuthType, sName);

	FormatEx(sQuery, sizeof(sQuery), "INSERT OR REPLACE INTO `vip_users` (`auth`, `auth_type`, `name`, `expires`, `group`) VALUES ('%s', '%i', '%s', '%i', '%s');", sAuth, AuthType, sName, iExpires, sGroup);
//	LogMessage("sQuery: '%s'", sQuery);

	hDataPack = CreateDataPack();
	WritePackString(hDataPack, sAuth);
	WritePackCell(hDataPack, iExpires);	
	WritePackString(hDataPack, sGroup);
	WritePackCell(hDataPack, iTime);

	WritePackClient(hDataPack, iClient);
	WritePackClient(hDataPack, iTarget);
	
	SQL_TQuery(g_hDatabase, SQL_Callback_OnVIPClientAdded, sQuery, hDataPack);
}

void WritePackClient(Handle &hDataPack, int iClient)
{
	if(iClient)
	{
		WritePackCell(hDataPack, UID(iClient));
	}
	else
	{
		WritePackCell(hDataPack, 0);
	}
}

int ReadPackClient(Handle &hDataPack)
{
	new iClient = ReadPackCell(hDataPack);		
	if (iClient)
	{
		iClient = CID(iClient);
	}

	return iClient;
}

public void SQL_Callback_CheckVIPClient(Handle hOwner, Handle hQuery, const char[] sError, any hDataPack)
{
	if (hQuery == INVALID_HANDLE || sError[0])
	{
		LogError("SQL_Callback_CheckVIPClient: %s", sError);
		return;
	}

	if(SQL_FetchRow(hQuery))
	{
		ResetPack(hDataPack);
		char sGroup[64]; iExpires;
		
		ReadPackString(hDataPack, sGroup, sizeof(sGroup));	// sName
		iExpires = ReadPackCell(hDataPack);						// AuthType
		ReadPackString(hDataPack, sGroup, sizeof(sGroup));	// sAuth
		iExpires = ReadPackCell(hDataPack);						// iExpires
		ReadPackString(hDataPack, sGroup, sizeof(sGroup));	// sGroup
		
		DebugMessage("SQL_Callback_CheckVIPClient: id - %i", SQL_FetchInt(hQuery, 0))
		SetClientOverrides(hDataPack, SQL_FetchInt(hQuery, 0), iExpires, sGroup);
	}
	else
	{
		SQL_FastQuery(g_hDatabase, "SET NAMES 'utf8'");

		ResetPack(hDataPack);
		char sQuery[256]; char sAuth[32]; char sName[MAX_NAME_LENGTH*2+1]; AuthType;
		ReadPackString(hDataPack, sName, sizeof(sName));
		AuthType = ReadPackCell(hDataPack);
		ReadPackString(hDataPack, sAuth, sizeof(sAuth));
		FormatEx(sQuery, sizeof(sQuery), "INSERT INTO `vip_users` (`auth`, `auth_type`, `name`) VALUES ('%s', '%i', '%s');", sAuth, AuthType, sName);
		DebugMessage("sQuery: %s", sQuery)
		SQL_TQuery(g_hDatabase, SQL_Callback_CreateVIPClient, sQuery, hDataPack);
	}
}

public void SQL_Callback_CreateVIPClient(Handle hOwner, Handle hQuery, const char[] sError, any hDataPack)
{
	if (hQuery == INVALID_HANDLE || sError[0])
	{
		LogError("SQL_Callback_CreateVIPClient: %s", sError);
		return;
	}

	if(SQL_GetAffectedRows(g_hDatabase))
	{
		DebugMessage("SQL_Callback_CreateVIPClient")
		ResetPack(hDataPack);
		char sGroup[64]; iExpires;
		
		ReadPackString(hDataPack, sGroup, sizeof(sGroup));	// sName
		iExpires = ReadPackCell(hDataPack);						// AuthType
		ReadPackString(hDataPack, sGroup, sizeof(sGroup));	// sAuth
		iExpires = ReadPackCell(hDataPack);						// iExpires
		ReadPackString(hDataPack, sGroup, sizeof(sGroup));	// sGroup
		
		SetClientOverrides(hDataPack, SQL_GetInsertId(g_hDatabase), iExpires, sGroup);
	}
}

void SetClientOverrides(Handle &hDataPack, int iClientID, int iExpires, const char[] sGroup)
{
	char sQuery[512];
//	FormatEx(sQuery, sizeof(sQuery), "INSERT INTO `vip_overrides` (`user_id`, `server_id`, `expires`, `group`) VALUES ('%i', '%i', '%i', '%s');", iClientID, g_CVAR_iServerID, iExpires, sGroup);
	FormatEx(sQuery, sizeof(sQuery), "INSERT INTO `vip_overrides` (`user_id`, `server_id`, `expires`, `group`) VALUES ('%i', '%i', '%i', '%s') \
		ON DUPLICATE KEY UPDATE `expires` = '%i', `group` = '%s';", iClientID, g_CVAR_iServerID, iExpires, sGroup, iExpires, sGroup);
	DebugMessage("sQuery: %s", sQuery)
	SQL_TQuery(g_hDatabase, SQL_Callback_OnVIPClientAdded, sQuery, hDataPack);
}

public void SQL_Callback_OnVIPClientAdded(Handle hOwner, Handle hQuery, const char[] sError, any hDataPack)
{
	if (hQuery == INVALID_HANDLE || sError[0])
	{
		LogError("SQL_Callback_OnVIPClientAdded: %s", sError);
		return;
	}

	if(SQL_GetAffectedRows(g_hDatabase))
	{
		ResetPack(hDataPack);
	
		decl iClient, iTarget, iTime, iExpires, char sExpires[64]; char sTime[64]; char sAuth[32]; char sGroup[64];
		if (GLOBAL_INFO & IS_MySQL)
		{
			ReadPackString(hDataPack, sGroup, sizeof(sGroup));
			iExpires = ReadPackCell(hDataPack);
		}
		
		ReadPackString(hDataPack, sAuth, sizeof(sAuth));
		iExpires = ReadPackCell(hDataPack);
		ReadPackString(hDataPack, sGroup, sizeof(sGroup));
		if(sGroup[0] == '\0')
		{
			FormatEx(sGroup, sizeof(sGroup), "%T", "NONE", iClient);
		}
		iTime = ReadPackCell(hDataPack);
		if(iTime)
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

		if(iTarget)
		{
			Clients_CheckVipAccess(iTarget, true);
			CreateForward_OnVIPClientAdded(iClient, iTarget);
		}

		if (iClient)
		{
			VIP_PrintToChatClient(iClient, "%t", "ADMIN_ADD_VIP_IDENTITY_SUCCESSFULLY");
		}
		else
		{
			PrintToServer("%T", "ADMIN_ADD_VIP_IDENTITY_SUCCESSFULLY", LANG_SERVER);
		}
		if(g_CVAR_bLogsEnable) LogToFile(g_sLogFile, "%T", "LOG_ADMIN_ADD_VIP_IDENTITY_SUCCESSFULLY", iClient, iClient, sAuth, sExpires, sTime, sGroup);
	}
}