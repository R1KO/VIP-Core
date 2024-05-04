
void DisplayClientInfo(int iClient, const char[] szEvent)
{
	DBG_Info("DisplayClientInfo: Client: %N (%i) -> '%s'", iClient, iClient, szEvent)

	g_hInfo.Rewind();
	if (!g_hInfo.JumpToKey(szEvent))
		return;

	DBG_Info("KvJumpToKey: %s", szEvent)

	char szServLang[4], szClientLang[4];
	if (!szServLang[0])
	{
		GetLanguageInfo(GetServerLanguage(), SZF(szServLang));
	}

	GetLanguageInfo(GetClientLanguage(iClient), SZF(szClientLang));

	DBG_Info("szServLang = '%s'", szServLang)
	DBG_Info("szClientLang = '%s'", szClientLang)

	DisplayInfo(iClient, szEvent, "chat", szClientLang, szServLang);
	DisplayInfo(iClient, szEvent, "menu", szClientLang, szServLang);
	DisplayInfo(iClient, szEvent, "url", szClientLang, szServLang);
}

void DisplayInfo(int iClient, const char[] szEvent, const char[] szType, const char[] szClientLang, const char[] szDefaultLang)
{
	DBG_Info("DisplayInfo: Client: %N (%i) -> '%s', '%s', '%s', '%s'", iClient, iClient, szEvent, szType, szClientLang, szDefaultLang)
	g_hInfo.Rewind();
	if (!g_hInfo.JumpToKey(szEvent) || !g_hInfo.JumpToKey(szType))
	{
		return;
	}

	KeyValues hKeyValues = new KeyValues(szType);
	KvCopySubkeys(g_hInfo, hKeyValues);
	switch(CreateForward_OnShowClientInfo(iClient, szEvent, szType, hKeyValues))
	{
		case Plugin_Stop, Plugin_Handled:
		{
			return;
		}
	}

	DBG_Info("KvJumpToKey: %s", szType)
	switch (szType[0])
	{
		case 'c':
		{
			DBG_Info("case 'c'")
			DisplayChatInfo(iClient, hKeyValues, szClientLang, szDefaultLang);
		}
		case 'm':
		{
			DBG_Info("case 'm'")
			DisplayMenuInfo(iClient, hKeyValues, szClientLang, szDefaultLang);
		}
		case 'u':
		{
			DBG_Info("case 'u'")
			DisplayUrlInfo(iClient, hKeyValues, szClientLang, szDefaultLang);
		}
	}

	delete hKeyValues;
}

void DisplayChatInfo(int iClient, KeyValues hKeyValues, const char[] szClientLang, const char[] szDefaultLang)
{
	char szBuffer[1024];
	if (!KvGetLangString(hKeyValues, SZF(szBuffer), szClientLang, szDefaultLang))
		return;

	DBG_Info("KvGetLangString: (%s, %s) = '%s'", szClientLang, szDefaultLang, szBuffer)
	ReplaceString(SZF(szBuffer), "{NL}", "\n");
	ReplaceValues(iClient, SZF(szBuffer));
	DBG_Info("ReplaceValues: '%s'", szBuffer)

	VIP_PrintToChatClient(iClient, szBuffer);
}

void DisplayMenuInfo(int iClient, KeyValues hKeyValues, const char[] szClientLang, const char[] szDefaultLang)
{
	int iTime = hKeyValues.GetNum("time", 0);
	if (!hKeyValues.JumpToKey(szClientLang) && !hKeyValues.JumpToKey(szDefaultLang))
		return;

	DBG_Info("KvJumpToKey: (%s|%s)", szClientLang, szDefaultLang)
	if (!hKeyValues.GotoFirstSubKey(false))
		return;

	DBG_Info("KvGotoFirstSubKey")
	Panel hPanel = new Panel();
	char szBuffer[PMP];
	do
	{
		hKeyValues.GetSectionName(SZF(szBuffer));
		if (strcmp(szBuffer, "item"))
			continue;

		hKeyValues.GetString(NULL_STRING, SZF(szBuffer));
		DBG_Info("KvGetString = '%s'", szBuffer)
		if (!szBuffer[0])
			continue;

		if (!strcmp(szBuffer, "SPACER"))
		{
			hPanel.DrawText(" \n");
			continue;
		}

		ReplaceValues(iClient, SZF(szBuffer));
		hPanel.DrawText(szBuffer);
	} while (hKeyValues.GotoNextKey(false));

	hPanel.DrawText(" \n ");

	hPanel.CurrentKey = g_hInfo.GetNum("exit_button", g_iMaxPageItems);

	FormatEx(szBuffer, 128, "%T", "Exit", iClient);
	hPanel.DrawItem(szBuffer, ITEMDRAW_CONTROL);

	hPanel.Send(iClient, SelectInfoPanel, iTime);
	delete hPanel;
}

void DisplayUrlInfo(int iClient, KeyValues hKeyValues, const char[] szClientLang, const char[] szDefaultLang)
{
	if (g_EngineVersion == Engine_CSGO)
		return;

	char szBuffer[PMP];
	if (!KvGetLangString(hKeyValues, SZF(szBuffer), szClientLang, szDefaultLang))
		return;

	DBG_Info("KvGetLangString: (%s, %s) = '%s'", szClientLang, szDefaultLang, szBuffer)
	if (strncmp(szBuffer, "http://", 7, true) != 0 && strncmp(szBuffer, "https://", 7, true) != 0)
	{
		Format(SZF(szBuffer), "http://%s", szBuffer);
	}

	ShowMOTDPanel(iClient, "VIP_INFO", szBuffer, MOTDPANEL_TYPE_URL);
}

bool KvGetLangString(KeyValues hKeyValues, char[] szBuffer, int iBufLen, const char[] szClientLang, const char[] szDefaultLang)
{
	DBG_Info("KvGetLangString: '%s', '%s'", szClientLang, szDefaultLang)
	hKeyValues.GetString(szClientLang, szBuffer, iBufLen);
	DBG_Info("KvGetString (%s) = '%s'", szClientLang, szBuffer)
	if (szBuffer[0])
		return true;

	hKeyValues.GetString(szDefaultLang, szBuffer, iBufLen);
	DBG_Info("KvGetString (%s) = '%s'", szDefaultLang, szBuffer)

	if (szBuffer[0])
		return true;

	return false;
}

void ReplaceValues(int iClient, char[] szBuffer, int iBufLen)
{
	if (FindCharInString(szBuffer, '{') == -1)
		return;

	char szName[MAX_NAME_LENGTH], szGroup[64];
	GetClientName(iClient, SZF(szName));
	ReplaceString(szBuffer, iBufLen, "{NAME}", szName);
	g_hFeatures[iClient].GetString(KEY_GROUP, SZF(szGroup));
	ReplaceString(szBuffer, iBufLen, "{GROUP}", szGroup);

	int iExpires;
	g_hFeatures[iClient].GetValue(KEY_EXPIRES, iExpires);
	DBG_Info("GetValue(%s) = %d", KEY_EXPIRES, iExpires)
	DBG_Info("GetTime() = %d", GetTime())
	DBG_Info("TIMELEFT = %d", iExpires - GetTime())
	char szExpires[64];
	FormatTime(SZF(szExpires), "%d/%m/%Y - %H:%M", iExpires);
	ReplaceString(szBuffer, iBufLen, "{EXPIRES}", szExpires);
	UTIL_GetTimeFromStamp(SZF(szExpires), iExpires - GetTime(), iClient);
	ReplaceString(szBuffer, iBufLen, "{TIMELEFT}", szExpires);

	//	{NAME}	- Ник игрока
	//	{GROUP}	- Группа игрока
	//	{TIMELEFT}	- Через сколько истекает VIP-статус
	//	{EXPIRES}	- Когда истекает VIP-статус
}

public int SelectInfoPanel(Menu hPanel, MenuAction action, int iClient, int iOption)
{
	return 0;
}
