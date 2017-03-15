
void DisplayClientInfo(int iClient, const char[] sKey)
{
	DebugMessage("DisplayClientInfo: Client: %N (%i) -> '%s'", iClient, iClient, sKey)
	
	static char sServLang[4];
	if (!sServLang[0])
	{
		GetLanguageInfo(GetServerLanguage(), sServLang, sizeof(sServLang));
	}
	DebugMessage("sServLang = '%s'", sServLang)
	
	KvRewind(GLOBAL_INFO_KV);
	if (KvJumpToKey(GLOBAL_INFO_KV, sKey))
	{
		DebugMessage("KvJumpToKey(%s)", sKey)
		char sBuffer[1028]; char sClientLang[4];
		GetLanguageInfo(GetClientLanguage(iClient), sClientLang, sizeof(sClientLang));
		DebugMessage("sClientLang = '%s'", sClientLang)
		DisplayInfo(iClient, sKey, "chat", sBuffer, sizeof(sBuffer), sClientLang, sServLang);
		DisplayInfo(iClient, sKey, "menu", sBuffer, sizeof(sBuffer), sClientLang, sServLang);
		DisplayInfo(iClient, sKey, "url", sBuffer, sizeof(sBuffer), sClientLang, sServLang);
	}
}

void DisplayInfo(int iClient, const char[] sKey, const char[] sKey2, char[] sBuffer, int iBufLen, char[] sClientLang, char[] sServLang)
{
	DebugMessage("DisplayInfo: Client: %N (%i) -> '%s', '%s', '%s', '%s'", iClient, iClient, sKey, sKey2, sClientLang, sServLang)
	KvRewind(GLOBAL_INFO_KV);
	if (KvJumpToKey(GLOBAL_INFO_KV, sKey) && KvJumpToKey(GLOBAL_INFO_KV, sKey2))
	{
		DebugMessage("KvJumpToKey(%s)", sKey2)
		switch (sKey2[0])
		{
			case 'c':
			{
				DebugMessage("case 'c'")
				if (KvGetLangString(sBuffer, iBufLen, sClientLang, sServLang))
				{
					DebugMessage("KvGetLangString(%s, %s) = '%s'", sClientLang, sServLang, sBuffer)
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
				
				int iTime = KvGetNum(GLOBAL_INFO_KV, "time", 0);
				if (!KvJumpToKey(GLOBAL_INFO_KV, sClientLang))
				{
					if (!KvJumpToKey(GLOBAL_INFO_KV, sServLang))
					{
						if (!KvGotoFirstSubKey(GLOBAL_INFO_KV))
						{
							return;
						}
					}
				}
				
				DebugMessage("KvJumpToKey(%s|%s)", sClientLang, sServLang)
				if (KvGotoFirstSubKey(GLOBAL_INFO_KV, false))
				{
					DebugMessage("KvGotoFirstSubKey")
					new Handle:hPanel = CreatePanel();
					do
					{
						KvGetString(GLOBAL_INFO_KV, NULL_STRING, sBuffer, 128);
						DebugMessage("KvGetString = '%s'", sBuffer)
						if (sBuffer[0])
						{
							if (strcmp(sBuffer, "SPACER") == 0)
							{
								DrawPanelText(hPanel, " \n");
								continue;
							}
							
							if (sKey[0] == 'c')
							{
								ReplaceValues(iClient, sBuffer, iBufLen, (sKey[13] == 't'));
							}
							DrawPanelText(hPanel, sBuffer);
						}
					} while (KvGotoNextKey(GLOBAL_INFO_KV, false));
					
					DrawPanelText(hPanel, " \n");
					
					SetPanelCurrentKey(hPanel, g_EngineVersion == Engine_CSGO ? 9:10);
					
					DrawPanelItem(hPanel, "Выход", ITEMDRAW_CONTROL);
					
					SendPanelToClient(hPanel, iClient, SelectInfoPanel, iTime);
					CloseHandle(hPanel);
				}
			}
			case 'u':
			{
				DebugMessage("case 'u'")
				if (KvGetLangString(sBuffer, iBufLen, sClientLang, sServLang))
				{
					DebugMessage("KvGetLangString(%s, %s) = '%s'", sClientLang, sServLang, sBuffer)
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
	KvGetString(GLOBAL_INFO_KV, sClientLang, sBuffer, iBufLen);
	DebugMessage("KvGetString (%s) = '%s'", sClientLang, sBuffer)
	if (!sBuffer[0])
	{
		KvGetString(GLOBAL_INFO_KV, sServLang, sBuffer, iBufLen);
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
	GetClientName(iClient, sName, sizeof(sName));
	ReplaceString(sBuffer, iBufLen, "{NAME}", sName);
	g_hFeatures[iClient].GetString(KEY_GROUP, sGroup, sizeof(sGroup));
	ReplaceString(sBuffer, iBufLen, "{GROUP}", sGroup);
	if (bExt)
	{
		char sExpires[64]; iExpires;
		g_hFeatures[iClient].GetValue(KEY_EXPIRES, iExpires);
		FormatTime(sExpires, sizeof(sExpires), "%d/%m/%Y - %H:%M", iExpires);
		ReplaceString(sBuffer, iBufLen, "{EXPIRES}", sExpires);
		UTIL_GetTimeFromStamp(sExpires, sizeof(sExpires), iExpires - GetTime(), iClient);
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