enum
{
	INFO_NO_ACCESS = 0,
	INFO_EXPIRED
}

ParseInfo()
{
	new iSize = GetArraySize(GLOBAL_INFO_ARRAY);
	if(iSize)
	{
		decl Handle:hArray, i;
		for(i = 0; i < iSize; ++i)
		{
			hArray = GetArrayCell(GLOBAL_INFO_ARRAY, i);
			UTIL_CloseHandleEx(hArray);
		}
	}

	ClearArray(GLOBAL_INFO_ARRAY);

	ReadFileToArray("data/vip/info/no_access_info.txt", INFO_NO_ACCESS);
	ReadFileToArray("data/vip/info/expired_info.txt", INFO_EXPIRED);
}

ReadFileToArray(const String:sPath[], index)
{
	decl String:sBuffer[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sBuffer, sizeof(sBuffer), sPath);
	if(FileExists(sBuffer))
	{
		decl Handle:hFile;
		hFile = OpenFile(sBuffer, "r");
		if (hFile != INVALID_HANDLE)
		{
			new Handle:hArray = CreateArray(ByteCountToCells(PLATFORM_MAX_PATH));
			if(GetArraySize(GLOBAL_INFO_ARRAY) <= index)
			{
				ResizeArray(GLOBAL_INFO_ARRAY, index+1);
			}
			
			while (IsEndOfFile(hFile) == false && ReadFileLine(hFile, sBuffer, sizeof(sBuffer)))
			{
				TrimString(sBuffer);
				
				if(strncmp(sBuffer, "//", 2, true) != 0)
				{
					ReplaceString(sBuffer, sizeof(sBuffer), "\\n", "\n", false);
					ReplaceString(sBuffer, sizeof(sBuffer), "#", "\x07", false);

					ReplaceString(sBuffer, sizeof(sBuffer), "{DEFAULT}", "\x01", false);
					ReplaceString(sBuffer, sizeof(sBuffer), "{GREEN}", "\x04", false);

					ReplaceString(sBuffer, sizeof(sBuffer), "{LIGHTGREEN}", "\x03", false);

					PushArrayString(hArray, sBuffer);
				}
			}
			
			if(GetArraySize(hArray) != 0)
			{
				SetArrayCell(GLOBAL_INFO_ARRAY, index, hArray);
			}
			else
			{
				CloseHandle(hArray);
				SetArrayCell(GLOBAL_INFO_ARRAY, index, INVALID_HANDLE);
			}
			
			CloseHandle(hFile);
		}
	}
}

ShowClientInfo(iClient, index)
{
	if(GetArraySize(GLOBAL_INFO_ARRAY))
	{
		new Handle:hArray = GetArrayCell(GLOBAL_INFO_ARRAY, index);
		if(hArray != INVALID_HANDLE)
		{
			decl String:sBuffer[PLATFORM_MAX_PATH];

			switch(g_CVAR_iInfoShowMode)
			{
				case 0:
				{
					decl i, iSize;
					iSize = GetArraySize(hArray);
					for(i = 0; i < iSize; ++i)
					{
						GetArrayString(hArray, i, sBuffer, sizeof(sBuffer));
						VIP_PrintToChatClient(iClient, sBuffer);
					}
				}
				case 1:
				{
					decl Handle:hPanel, iSize, i;

					iSize = GetArraySize(hArray);
					if(iSize > 9) iSize = 9;
					
					hPanel = CreatePanel();

					for(i = 0; i < iSize; ++i)
					{
						GetArrayString(hArray, i, sBuffer, sizeof(sBuffer));
						DrawPanelText(hPanel, sBuffer);
					}

					DrawPanelText(hPanel, " \n");
					if(g_GameType == GAME_CSGO)
					{
						SetPanelCurrentKey(hPanel, 9);
					}
					else
					{
						SetPanelCurrentKey(hPanel, 10);
					}

					DrawPanelItem(hPanel, "Выход", ITEMDRAW_CONTROL);
					
					SendPanelToClient(hPanel, iClient, SelectInfoPanel, 30);
					CloseHandle(hPanel);
				}
				case 2:
				{
					GetArrayString(hArray, 0, sBuffer, sizeof(sBuffer));
					if(strncmp(sBuffer, "http://", 7, true) != 0)
					{
						Format(sBuffer, sizeof(sBuffer), "http://%s", sBuffer);
					}

					ShowMOTDPanel(iClient, "VIP_INFO", sBuffer, MOTDPANEL_TYPE_URL);
				}
			}
		}
	}
}

public SelectInfoPanel(Handle:hPanel, MenuAction:action, iClient, iOption)
{
	
}