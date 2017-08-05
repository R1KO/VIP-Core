
void DisplayClientInfo(int iClient, const char[] sKey)
{
	DebugMessage("DisplayClientInfo: Client: %N (%i) -> '%s'", iClient, iClient, sKey)
	
	static char sServLang[4];
	if (!sServLang[0])
	{
		GetLanguageInfo(GetServerLanguage(), SZF(sServLang));
	}
	DebugMessage("sServLang = '%s'", sServLang)
	
	g_hInfo.Rewind();
	if (g_hInfo.JumpToKey(sKey))
	{
		DebugMessage("KvJumpToKey: %s", sKey)
		char sClientLang[4];
		GetLanguageInfo(GetClientLanguage(iClient), SZF(sClientLang));
		DebugMessage("sClientLang = '%s'", sClientLang)
		char sBuffer[1028];
		DisplayInfo(iClient, sKey, "chat", SZF(sBuffer), sClientLang, sServLang);
		DisplayInfo(iClient, sKey, "menu", SZF(sBuffer), sClientLang, sServLang);
		DisplayInfo(iClient, sKey, "url", SZF(sBuffer), sClientLang, sServLang);
	}
}

void DisplayInfo(int iClient, const char[] sKey, const char[] sKey2, char[] sBuffer, int iBufLen, char[] sClientLang, char[] sServLang)
{
	DebugMessage("DisplayInfo: Client: %N (%i) -> '%s', '%s', '%s', '%s'", iClient, iClient, sKey, sKey2, sClientLang, sServLang)
	g_hInfo.Rewind();
	if (g_hInfo.JumpToKey(sKey) && g_hInfo.JumpToKey(sKey2))
	{
		DebugMessage("KvJumpToKey: %s", sKey2)
		switch (sKey2[0])
		{
			case 'c':
			{
				DebugMessage("case 'c'")
				if (KvGetLangString(sBuffer, iBufLen, sClientLang, sServLang))
				{
					DebugMessage("KvGetLangString: (%s, %s) = '%s'", sClientLang, sServLang, sBuffer)
					ReplaceString(sBuffer, iBufLen, "\\n", " \n");
					if (sKey[0] == 'c')
					{
						ReplaceValues(iClient, sBuffer, iBufLen, (sKey[13] == 't'));
					}
					VIP_PrintToChatClient(iClient, sBuffer);
				}
			}
			case 'm':
			{
				DebugMessage("case 'm'")
				
				int iTime = g_hInfo.GetNum("time", 0);
				if (!g_hInfo.JumpToKey(sClientLang))
				{
					if (!g_hInfo.JumpToKey(sServLang))
					{
						if (!g_hInfo.GotoFirstSubKey())
						{
							return;
						}
					}
				}
				
				DebugMessage("KvJumpToKey: (%s|%s)", sClientLang, sServLang)
				if (g_hInfo.GotoFirstSubKey(false))
				{
					DebugMessage("KvGotoFirstSubKey")
					Panel hPanel = new Panel();
					do
					{
						g_hInfo.GetString(NULL_STRING, sBuffer, 128);
						DebugMessage("KvGetString = '%s'", sBuffer)
						if (sBuffer[0])
						{
							if (strcmp(sBuffer, "SPACER") == 0)
							{
								hPanel.DrawText(" \n");
								continue;
							}
							
							if (sKey[0] == 'c')
							{
								ReplaceValues(iClient, sBuffer, iBufLen, (sKey[13] == 't'));
							}
							hPanel.DrawText(sBuffer);
						}
					} while (g_hInfo.GotoNextKey(false));
					
					hPanel.DrawText(" \n");
					
					hPanel.CurrentKey = g_iMaxPageItems;
					
					hPanel.DrawItem("Выход", ITEMDRAW_CONTROL);
					
					hPanel.Send(iClient, SelectInfoPanel, iTime);
					delete hPanel;
				}
			}
			case 'u':
			{
				DebugMessage("case 'u'")
				if (KvGetLangString(sBuffer, iBufLen, sClientLang, sServLang))
				{
					DebugMessage("KvGetLangString: (%s, %s) = '%s'", sClientLang, sServLang, sBuffer)
					if (strncmp(sBuffer, "http://", 7, true) != 0)
					{
						Format(sBuffer, 256, "http://%s", sBuffer);
					}
					
					ShowMOTDPanel(iClient, "VIP_INFO", sBuffer, MOTDPANEL_TYPE_URL);
				}
			}
		}
	}
}

bool KvGetLangString(char[] sBuffer, int iBufLen, char[] sClientLang, char[] sServLang)
{
	DebugMessage("KvGetLangString: '%s', '%s'", sClientLang, sServLang)
	g_hInfo.GetString(sClientLang, sBuffer, iBufLen);
	DebugMessage("KvGetString (%s) = '%s'", sClientLang, sBuffer)
	if (!sBuffer[0])
	{
		g_hInfo.GetString(sServLang, sBuffer, iBufLen);
		DebugMessage("KvGetString (%s) = '%s'", sServLang, sBuffer)
		if (!sBuffer[0])
		{
			return false;
		}
	}
	return true;
}

void ReplaceValues(int iClient, char[] sBuffer, int iBufLen, bool bExt)
{
	char sName[MAX_NAME_LENGTH]; char sGroup[64];
	GetClientName(iClient, SZF(sName));
	ReplaceString(sBuffer, iBufLen, "{NAME}", sName);
	g_hFeatures[iClient].GetString(KEY_GROUP, SZF(sGroup));
	ReplaceString(sBuffer, iBufLen, "{GROUP}", sGroup);
	if (bExt)
	{
		int iExpires;
		g_hFeatures[iClient].GetValue(KEY_EXPIRES, iExpires);
		DebugMessage("GetValue(%s) = %d", KEY_EXPIRES, iExpires)
		DebugMessage("GetTime() = %d", GetTime())
		DebugMessage("TIMELEFT = %d", iExpires - GetTime())
		char sExpires[64];
		FormatTime(SZF(sExpires), "%d/%m/%Y - %H:%M", iExpires);
		ReplaceString(sBuffer, iBufLen, "{EXPIRES}", sExpires);
		UTIL_GetTimeFromStamp(SZF(sExpires), iExpires - GetTime(), iClient);
		ReplaceString(sBuffer, iBufLen, "{TIMELEFT}", sExpires);
	}
	//	{NAME}	- Ник игрока
	//	{GROUP}	- Группа игрока
	//	{TIMELEFT}	- Через сколько истекает VIP-статус
	//	{EXPIRES}	- Когда истекает VIP-статус
}

public int SelectInfoPanel(Menu hPanel, MenuAction action, int iClient, int iOption)
{
	
}