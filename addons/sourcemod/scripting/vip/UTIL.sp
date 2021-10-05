
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
			++iNum;
		}
	}
	
	return iNum;
}

bool UTIL_StrCmpEx(const char[] szString1, const char[] szString2)
{
	int iLen = strlen(szString1);
	if (iLen != strlen(szString2))
	{
		return false;
	}

	for (int i = 0; i < iLen; ++i)
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
			FormatEx(szSteamID, iMaxLen, "STEAM_%d:%d:%d", g_EngineVersion == Engine_CSGO ? 1:0, iPart, iAccountID/2);
		}
	}
}

void UTIL_GetClientInfo(int iClient, char[] szBuffer, int iMaxLen)
{
	char szName[MNL], szAuth[32], szIP[24];
	GetClientName(iClient, SZF(szName));
	GetClientAuthId(iClient, AuthId_Engine, SZF(szAuth));
	GetClientIP(iClient, SZF(szIP));
	
	FormatEx(szBuffer, iMaxLen, "%s (%s, %s)", szName, szAuth, szIP);
}

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

int UTIL_GetVipClientByAccountID(int iAccountID)
{
	int iClientID;
	for (int i = 1; i <= MaxClients; ++i)
	{
		if (IsClientInGame(i) && g_hFeatures[i] != null && g_hFeatures[i].GetValue(KEY_CID, iClientID) && iClientID == iAccountID) return i;
	}
	return 0;
}
