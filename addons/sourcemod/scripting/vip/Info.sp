void DisplayClientInfo(int iClient, const char[] szEvent)
{
	DebugMessage("DisplayClientInfo: Client: %N (%i) -> '%s'", iClient, iClient, szEvent)
	
	static char szServLang[4];
	if (!szServLang[0])
	{
		GetLanguageInfo(GetServerLanguage(), SZF(szServLang));
	}
	DebugMessage("szServLang = '%s'", szServLang)
	
	g_hInfo.Rewind();
	if (g_hInfo.JumpToKey(szEvent))
	{
		DebugMessage("KvJumpToKey: %s", szEvent)
		static char szClientLang[4], szBuffer[1028];
		GetLanguageInfo(GetClientLanguage(iClient), SZF(szClientLang));
		DebugMessage("szClientLang = '%s'", szClientLang)
		DisplayInfo(iClient, szEvent, "chat", SZF(szBuffer), szClientLang, szServLang);
		DisplayInfo(iClient, szEvent, "menu", SZF(szBuffer), szClientLang, szServLang);
		DisplayInfo(iClient, szEvent, "url", SZF(szBuffer), szClientLang, szServLang);
	}
}

void DisplayInfo(int iClient, const char[] szEvent, const char[] szType, char[] szBuffer, int iBufLen, char[] szClientLang, char[] szServLang)
{
	DebugMessage("DisplayInfo: Client: %N (%i) -> '%s', '%s', '%s', '%s'", iClient, iClient, szEvent, szType, szClientLang, szServLang)
	g_hInfo.Rewind();
	if (g_hInfo.JumpToKey(szEvent) && g_hInfo.JumpToKey(szType))
	{
		KeyValues hKeyValues = new KeyValues(szType);
		KvCopySubkeys(g_hInfo, hKeyValues);
		switch(CallForward_OnShowClientInfo(iClient, szEvent, szType, hKeyValues))
		{
			case Plugin_Stop, Plugin_Handled:
			{
				return;
			}
			case Plugin_Continue:
			{
				delete hKeyValues;
				hKeyValues = g_hInfo;
			}
		}

		DebugMessage("KvJumpToKey: %s", szType)
		switch (szType[0])
		{
			case 'c':
			{
				DebugMessage("case 'c'")
				if (KvGetLangString(szBuffer, iBufLen, szClientLang, szServLang))
				{
					DebugMessage("KvGetLangString: (%s, %s) = '%s'", szClientLang, szServLang, szBuffer)
					ReplaceString(szBuffer, iBufLen, "\\n", " \n");
					if (szEvent[0] == 'c')
					{
						ReplaceValues(iClient, szBuffer, iBufLen, (szEvent[13] == 't'));
					}
					VIP_PrintToChatClient(iClient, szBuffer);
				}
			}
			case 'm':
			{
				DebugMessage("case 'm'")
				
				int iTime = g_hInfo.GetNum("time", 0);
				if (!g_hInfo.JumpToKey(szClientLang))
				{
					if (!g_hInfo.JumpToKey(szServLang))
					{
						if (!g_hInfo.GotoFirstSubKey())
						{
							if(hKeyValues != g_hInfo)
							{
								delete hKeyValues;
							}
							return;
						}
					}
				}
				
				DebugMessage("KvJumpToKey: (%s|%s)", szClientLang, szServLang)
				if (g_hInfo.GotoFirstSubKey(false))
				{
					DebugMessage("KvGotoFirstSubKey")
					Panel hPanel = new Panel();
					do
					{
						g_hInfo.GetSectionName(szBuffer, 32);
						if (strcmp(szBuffer, "item"))
						{
							continue;
						}

						g_hInfo.GetString(NULL_STRING, szBuffer, 128);
						DebugMessage("KvGetString = '%s'", szBuffer)
						if (szBuffer[0])
						{
							if (!strcmp(szBuffer, "SPACER"))
							{
								hPanel.DrawText(" \n");
								continue;
							}
							
							if (szEvent[0] == 'c')
							{
								ReplaceValues(iClient, szBuffer, iBufLen, (szEvent[13] == 't'));
							}
							hPanel.DrawText(szBuffer);
						}
					} while (g_hInfo.GotoNextKey(false));
					
					g_hInfo.GoBack();
					
					hPanel.DrawText(" \n");
					
					hPanel.CurrentKey = g_hInfo.GetNum("exit_button", g_iMaxPageItems);
					
					FormatEx(szBuffer, 128, "%T", "Exit", iClient);
					hPanel.DrawItem(szBuffer, ITEMDRAW_CONTROL);

					hPanel.Send(iClient, SelectInfoPanel, iTime);
					delete hPanel;
				}
			}
			case 'u':
			{
				DebugMessage("case 'u'")
				if (g_EngineVersion != Engine_CSGO)	
				{
					if (KvGetLangString(szBuffer, iBufLen, szClientLang, szServLang))
					{
						DebugMessage("KvGetLangString: (%s, %s) = '%s'", szClientLang, szServLang, szBuffer)
						if (strncmp(szBuffer, "http://", 7, true) != 0)
						{
							Format(szBuffer, 256, "http://%s", szBuffer);
						}

						ShowMOTDPanel(iClient, "VIP_INFO", szBuffer, MOTDPANEL_TYPE_URL);
					}
				}
			}
		}
		
		if(hKeyValues != g_hInfo)
		{
			delete hKeyValues;
		}
	}
}

bool KvGetLangString(char[] szBuffer, int iBufLen, char[] szClientLang, char[] szServLang)
{
	DebugMessage("KvGetLangString: '%s', '%s'", szClientLang, szServLang)
	g_hInfo.GetString(szClientLang, szBuffer, iBufLen);
	DebugMessage("KvGetString (%s) = '%s'", szClientLang, szBuffer)
	if (!szBuffer[0])
	{
		g_hInfo.GetString(szServLang, szBuffer, iBufLen);
		DebugMessage("KvGetString (%s) = '%s'", szServLang, szBuffer)
		if (!szBuffer[0])
		{
			return false;
		}
	}
	return true;
}

void ReplaceValues(int iClient, char[] szBuffer, int iBufLen, bool bExt)
{
	char szName[MAX_NAME_LENGTH]; char szGroup[64];
	GetClientName(iClient, SZF(szName));
	ReplaceString(szBuffer, iBufLen, "{NAME}", szName);
	g_hFeatures[iClient].GetString(KEY_GROUP, SZF(szGroup));
	ReplaceString(szBuffer, iBufLen, "{GROUP}", szGroup);
	if (bExt)
	{
		int iExpires;
		g_hFeatures[iClient].GetValue(KEY_EXPIRES, iExpires);
		DebugMessage("GetValue(%s) = %d", KEY_EXPIRES, iExpires)
		DebugMessage("GetTime() = %d", GetTime())
		DebugMessage("TIMELEFT = %d", iExpires - GetTime())
		char szExpires[64];
		FormatTime(SZF(szExpires), "%d/%m/%Y - %H:%M", iExpires);
		ReplaceString(szBuffer, iBufLen, "{EXPIRES}", szExpires);
		UTIL_GetTimeFromStamp(SZF(szExpires), iExpires - GetTime(), iClient);
		ReplaceString(szBuffer, iBufLen, "{TIMELEFT}", szExpires);
	}
	//	{NAME}	- Ник игрока
	//	{GROUP}	- Группа игрока
	//	{TIMELEFT}	- Через сколько истекает VIP-статус
	//	{EXPIRES}	- Когда истекает VIP-статус
}

public int SelectInfoPanel(Menu hPanel, MenuAction action, int iClient, int iOption)
{
	
}
