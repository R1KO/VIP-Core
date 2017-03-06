ShowAddVIPMenu(iClient)
{
	decl Handle:hMenu, String:sUserId[12], String:sName[100], i, iClientID;
	hMenu = CreateMenu(MenuHandler_AddVip_PlayerList);
	SetMenuTitle(hMenu, "%T:\n \n", "MENU_ADD_VIP", iClient);
	SetMenuExitBackButton(hMenu, true);

	sUserId[0] = 0;
	for (i = 1; i <= MaxClients; ++i)
	{
		if (IsClientInGame(i))
		{
			if(g_iClientInfo[i] & IS_VIP)
			{
				if(!(g_iClientInfo[i] & IS_AUTHORIZED))
				{
					continue;
				}

				GetTrieValue(g_hFeatures[i], KEY_CID, iClientID);
				if(iClientID != -1)
				{
					continue;
				}
			}
			
			if(IsFakeClient(i) == false && GetClientName(i, sName, sizeof(sName)))
			{
				IntToString(UID(i), sUserId, sizeof(sUserId));
				AddMenuItem(hMenu, sUserId, sName);
			}
		}
	}

	if(sUserId[0] == 0)
	{
		FormatEx(sName, sizeof(sName), "%T", "NO_PLAYERS_AVAILABLE", iClient);
		AddMenuItem(hMenu, "", sName, ITEMDRAW_DISABLED);
	}

	DisplayMenu(hMenu, iClient, MENU_TIME_FOREVER);
}

public MenuHandler_AddVip_PlayerList(Handle:hMenu, MenuAction:action, iClient, Item)
{
	switch(action)
	{
		case MenuAction_End: CloseHandle(hMenu);
		case MenuAction_Cancel:
		{
			if(Item == MenuCancel_ExitBack) DisplayMenu(g_hVIPAdminMenu, iClient, MENU_TIME_FOREVER);
		}
		case MenuAction_Select:
		{
			decl String:sUserID[12], UserID;
			GetMenuItem(hMenu, Item, sUserID, sizeof(sUserID));
			UserID = StringToInt(sUserID);
			if(CID(UserID))
			{
				SetArrayCell(g_ClientData[iClient], DATA_TARGET_USER_ID, UserID);
				ShowAuthTypeMenu(iClient);
			} else VIP_PrintToChatClient(iClient, "%t", "PLAYER_NO_LONGER_AVAILABLE");
		}
	}
}

ShowAuthTypeMenu(iClient)
{
	decl Handle:hMenu, String:sBuffer[128];
	hMenu = CreateMenu(MenuHandler_AddVip_AuthType);
	SetMenuTitle(hMenu, "%T:\n \n", "IDENTIFICATION_TYPE", iClient);
	SetMenuExitBackButton(hMenu, true);

	FormatEx(sBuffer, sizeof(sBuffer), "%T", "STEAM_ID", iClient);
	AddMenuItem(hMenu, "0", sBuffer);
	FormatEx(sBuffer, sizeof(sBuffer), "%T", "IP", iClient);
	AddMenuItem(hMenu, "1", sBuffer);
	FormatEx(sBuffer, sizeof(sBuffer), "%T", "NAME", iClient);
	AddMenuItem(hMenu, "2", sBuffer);
	
	ReductionMenu(hMenu, 3);

	DisplayMenu(hMenu, iClient, MENU_TIME_FOREVER);
}

public MenuHandler_AddVip_AuthType(Handle:hMenu, MenuAction:action, iClient, Item)
{
	switch(action)
	{
		case MenuAction_End: CloseHandle(hMenu);
		case MenuAction_Cancel:
		{
			if(Item == MenuCancel_ExitBack) ShowAddVIPMenu(iClient);
		}
		case MenuAction_Select:
		{
			new iTarget = CID(GetArrayCell(g_ClientData[iClient], DATA_TARGET_USER_ID));
			if (iTarget)
			{
				decl String:sAuthType[5];
				GetMenuItem(hMenu, Item, sAuthType, sizeof(sAuthType));
				SetArrayCell(g_ClientData[iClient], DATA_AUTH_TYPE, _:StringToInt(sAuthType));
				SetArrayCell(g_ClientData[iClient], DATA_TIME, TIME_SET);
				SetArrayCell(g_ClientData[iClient], DATA_MENU_TYPE, MENU_TYPE_ADD);
				ShowTimeMenu(iClient);
			} else VIP_PrintToChatClient(iClient, "%t", "Player no longer available");
		}
	}
}

ShowGroupMenu(iClient)
{
	decl Handle:hMenu, String:sGroup[MAX_NAME_LENGTH];
	hMenu = CreateMenu(MenuHandler_AddVip_GroupsList);
	SetMenuTitle(hMenu, "%T:\n \n", "GROUP", iClient);
	SetMenuExitBackButton(hMenu, true);
	sGroup[0] = 0; 
	KvRewind(g_hGroups);
	if(KvGotoFirstSubKey(g_hGroups))
	{
		do
		{
			if (KvGetSectionName(g_hGroups, sGroup, sizeof(sGroup)))
			{
				AddMenuItem(hMenu, sGroup, sGroup);
			}
		} while KvGotoNextKey(g_hGroups);
	}
	if(sGroup[0] == 0)
	{
		FormatEx(sGroup, sizeof(sGroup), "%T", "NO_GROUPS_AVAILABLE", iClient);
		AddMenuItem(hMenu, "", sGroup, ITEMDRAW_DISABLED);
	}

	DisplayMenu(hMenu, iClient, MENU_TIME_FOREVER);
}

public MenuHandler_AddVip_GroupsList(Handle:hMenu, MenuAction:action, iClient, Item)
{
	switch(action)
	{
		case MenuAction_End: CloseHandle(hMenu);
		case MenuAction_Cancel:
		{
			if(Item == MenuCancel_ExitBack)
			{
				SetArrayCell(g_ClientData[iClient], DATA_TIME, TIME_SET);
				ShowTimeMenu(iClient);
			}
		}
		case MenuAction_Select:
		{
			new iTarget = CID(GetArrayCell(g_ClientData[iClient], DATA_TARGET_USER_ID));
			if (iTarget)
			{
				decl String:sGroup[MAX_NAME_LENGTH];
				GetMenuItem(hMenu, Item, sGroup, sizeof(sGroup));
				UTIL_ADD_VIP_PLAYER(iClient, iTarget, "", GetArrayCell(g_ClientData[iClient], DATA_TIME), VIP_AuthType:GetArrayCell(g_ClientData[iClient], DATA_AUTH_TYPE), sGroup);
				//CloseHandleEx(g_ClientData[iClient]);
				DisplayMenu(g_hVIPAdminMenu, iClient, MENU_TIME_FOREVER);
			} else VIP_PrintToChatClient(iClient, "%t", "Player no longer available");
		}
	}
}
