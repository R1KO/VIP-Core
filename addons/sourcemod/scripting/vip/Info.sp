#if FIX_CSGO_MOTD 1

#define DOMAIN_1	"kruzefag"
#define DOMAIN_2	"crazyhackgut"

#define FORMAT_URL	"https://%s.ru/valve/csgo_hiddenmotd/%s"

bool	g_bUsedFirst[MAXPLAYERS+1];
#endif

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
		switch(CreateForward_OnShowClientInfo(iClient, szEvent, szType, hKeyValues))
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
						g_hInfo.GetString(NULL_STRING, szBuffer, 128);
						DebugMessage("KvGetString = '%s'", szBuffer)
						if (szBuffer[0])
						{
							if (strcmp(szBuffer, "SPACER") == 0)
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
				if (KvGetLangString(szBuffer, iBufLen, szClientLang, szServLang))
				{
					DebugMessage("KvGetLangString: (%s, %s) = '%s'", szClientLang, szServLang, szBuffer)
					if (strncmp(szBuffer, "http://", 7, true) != 0)
					{
						Format(szBuffer, 256, "http://%s", szBuffer);
					}
					
				//	ShowMOTDPanel(iClient, "VIP_INFO", szBuffer, MOTDPANEL_TYPE_URL);
					
					#if FIX_CSGO_MOTD 1
					if (g_EngineVersion == Engine_CSGO)
					{
						char szPreparedURL[256];
						EncodeBase64(SZF(szPreparedURL), szBuffer);
						Format(szBuffer, iBufLen, FORMAT_URL, g_bUsedFirst[iClient] ? DOMAIN_1 : DOMAIN_2, szPreparedURL);
						g_bUsedFirst[iClient] = !g_bUsedFirst[iClient];
					}
					#endif
					
					KeyValues hVGUIKv = new KeyValues("data");
					hVGUIKv.SetString("title", "VIP_INFO");
					hVGUIKv.SetString("type", "2");
					hVGUIKv.SetString("msg", szBuffer);
					ShowVGUIPanel(iClient, "info", hVGUIKv);
					delete hVGUIKv;
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

#if FIX_CSGO_MOTD 1
static const char sBase64Table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
static const int cFillChar = '=';

int EncodeBase64(char[] szResult, int iMaxLen, const char[] szSource, int iSourceLen = 0)
{
	int iLength = (iSourceLen > 0) ? iSourceLen:strlen(szSource), iResPos, cCode, iPos;

	for (iPos = 0; iPos < iLength; ++iPos)
	{
		cCode = (szSource[iPos] >> 2) & 0x3f;

		iResPos += FormatEx(szResult[iResPos], iMaxLen - iResPos, "%c", sBase64Table[cCode]);

		cCode = (szSource[iPos] << 4) & 0x3f;
		if(++iPos < iLength)
		{
			cCode |= (szSource[iPos] >> 4) & 0x0f;
		}

		iResPos += FormatEx(szResult[iResPos], iMaxLen - iResPos, "%c", sBase64Table[cCode]);

		if (iPos < iLength)
		{
			cCode = (szSource[iPos] << 2) & 0x3f;
			if(++iPos < iLength)
			cCode |= (szSource[iPos] >> 6) & 0x03;

			iResPos += FormatEx(szResult[iResPos], iMaxLen - iResPos, "%c", sBase64Table[cCode]);
		}
		else
		{
			iPos++;
			iResPos += FormatEx(szResult[iResPos], iMaxLen - iResPos, "%c", cFillChar);
		}

		if(iPos < iLength)
		{
			cCode = szSource[iPos] & 0x3f;
			iResPos += FormatEx(szResult[iResPos], iMaxLen - iResPos, "%c", sBase64Table[cCode]);
		}
		else
		{
			iResPos += FormatEx(szResult[iResPos], iMaxLen - iResPos, "%c", cFillChar);
		}
	}

	return iResPos;
}
#endif

/*
- Открыть ссылку в MOTD:
  https://%param1%.ru/valve/csgo_hiddenmotd/%param2%
  - Параметры:
    - param1 - один из доменов: kruzefag или crazyhackgut. Для адекватной работы надо чередовать домены.
    - param2 - загнанная в base64 ссылка
  Пример использования:
  https://kruzefag.ru/valve/csgo_hiddemotd/aHR0cDovL2hsbW9kLnJ1Lw==
  Откроет хлмод в скрытом мотд

- Открыть ссылку в окне игры
  https://%param1%.ru/valve/csgo_normalmotd/%param2%/%param3%/%param4%/%param5%
  Параметры:
    - param1 - один из доменов: kruzefag или crazyhackgut. Для адекватной работы надо чередовать домены.
    - param2 - загнанная в base64 ссылка
    - param3 - на весь экран? 1 - да, 0 - нет
    - param4 - ширина окна, если не на весь экран
    - param5 - высота окна, если не на весь экран
  Если Вам нужно просто открыть окно на весь экран, параметры 4 и 5 можно не передавать:
  https://%param1%.ru/valve/csgo_normalmotd/%param2%/%param3%
  Если устраивает стандартный размер окна (640х480), то можно так же опустить %param3%:
  https://%param1%.ru/valve/csgo_normalmotd/%param2%

  Пример использования:
    - https://kruzefag.ru/valve/csgo_normalmotd/aHR0cDovL2hsbW9kLnJ1Lw==/1
      Откроет хлмод на весь экран
    - https://kruzefag.ru/valve/csgo_normalmotd/aHR0cDovL2hsbW9kLnJ1Lw==/0/1024/768
      Откроет хлмод в небольшом окне размером 1024х768
*/

