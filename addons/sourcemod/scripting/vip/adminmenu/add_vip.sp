void ShowAddVIPMenu(int iClient)
{
	decl Handle:hMenu, char sUserId[12]; char sName[100]; i, iClientID;
	hMenu = CreateMenu(MenuHandler_AddVip_PlayerList);
	SetMenuTitle(hMenu, "%T:\n \n", "MENU_ADD_VIP", iClient);
	SetMenuExitBackButton(hMenu, true);
	
	sUserId[0] = 0;
	for (i = 1; i <= MaxClients; ++i)
	{
		if (IsClientInGame(i))
		{
			if (g_iClientInfo[i] & IS_VIP)
			{
				if (!(g_iClientInfo[i] & IS_AUTHORIZED))
				{
					continue;
				}
				
				GetTrieValue(g_hFeatures[i], KEY_CID, iClientID);
				if (iClientID != -1)
				{
					continue;
				}
			}
			
			if (IsFakeClient(i) == false && GetClientName(i, sName, sizeof(sName)))
			{
				IntToString(UID(i), sUserId, sizeof(sUserId));
				AddMenuItem(hMenu, sUserId, sName);
			}
		}
	}
	
	if (sUserId[0] == 0)
	{
		FormatEx(sName, sizeof(sName), "%T", "NO_PLAYERS_AVAILABLE", iClient);
		AddMenuItem(hMenu, "", sName, ITEMDRAW_DISABLED);
	}
	
	DisplayMenu(hMenu, iClient, MENU_TIME_FOREVER);
}

public int MenuHandler_AddVip_PlayerList(Menu hMenu, MenuAction action, int iClient, int Item)
{
	switch (action)
	{
		case MenuAction_End:CloseHandle(hMenu);
		case MenuAction_Cancel:
		{
			if (Item == MenuCancel_ExitBack)DisplayMenu(g_hVIPAdminMenu, iClient, MENU_TIME_FOREVER);
		}
		case MenuAction_Select:
		{
			char sUserID[12]; UserID;
			GetMenuItem(hMenu, Item, sUserID, sizeof(sUserID));
			UserID = StringToInt(sUserID);
			if (CID(UserID))
			{
				g_ClientData[iClient].Set(DATA_TARGET_USER_ID, UserID);
				ShowAuthTypeMenu(iClient);
			} else VIP_PrintToChatClient(iClient, "%t", "PLAYER_NO_LONGER_AVAILABLE");
		}
	}
}

void ShowAuthTypeMenu(int iClient)
{
	decl Handle:hMenu; char sBuffer[128];
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

public int MenuHandler_AddVip_AuthType(Menu hMenu, MenuAction action, int iClient, int Item)
{
	switch (action)
	{
		case MenuAction_End:CloseHandle(hMenu);
		case MenuAction_Cancel:
		{
			if (Item == MenuCancel_ExitBack)ShowAddVIPMenu(iClient);
		}
		case MenuAction_Select:
		{
			new iTarget = CID(g_ClientData[iClient].Get(DATA_TARGET_USER_ID));
			if (iTarget)
			{
				char sAuthType[5];
				GetMenuItem(hMenu, Item, sAuthType, sizeof(sAuthType));
				g_ClientData[iClient].Set(DATA_AUTH_TYPE, _:StringToInt(sAuthType));
				g_ClientData[iClient].Set(DATA_TIME, TIME_SET);
				g_ClientData[iClient].Set(DATA_MENU_TYPE, MENU_TYPE_ADD);
				ShowTimeMenu(iClient);
			} else VIP_PrintToChatClient(iClient, "%t", "Player no longer available");
		}
	}
}

void ShowGroupMenu(int iClient)
{
	decl Handle:hMenu; char sGroup[MAX_NAME_LENGTH];
	hMenu = CreateMenu(MenuHandler_AddVip_GroupsList);
	SetMenuTitle(hMenu, "%T:\n \n", "GROUP", iClient);
	SetMenuExitBackButton(hMenu, true);
	sGroup[0] = 0;
	KvRewind(g_hGroups);
	if (KvGotoFirstSubKey(g_hGroups))
	{
		do
		{
			if (KvGetSectionName(g_hGroups, sGroup, sizeof(sGroup)))
			{
				AddMenuItem(hMenu, sGroup, sGroup);
			}
		} while KvGotoNextKey(g_hGroups);
	}
	if (sGroup[0] == 0)
	{
		FormatEx(sGroup, sizeof(sGroup), "%T", "NO_GROUPS_AVAILABLE", iClient);
		AddMenuItem(hMenu, "", sGroup, ITEMDRAW_DISABLED);
	}
	
	DisplayMenu(hMenu, iClient, MENU_TIME_FOREVER);
}

public int MenuHandler_AddVip_GroupsList(Menu hMenu, MenuAction action, int iClient, int Item)
{
	switch (action)
	{
		case MenuAction_End:CloseHandle(hMenu);
		case MenuAction_Cancel:
		{
			if (Item == MenuCancel_ExitBack)
			{
				g_ClientData[iClient].Set(DATA_TIME, TIME_SET);
				ShowTimeMenu(iClient);
			}
		}
		case MenuAction_Select:
		{
			new iTarget = CID(g_ClientData[iClient].Get(DATA_TARGET_USER_ID));
			if (iTarget)
			{
				char sGroup[MAX_NAME_LENGTH];
				GetMenuItem(hMenu, Item, sGroup, sizeof(sGroup));
				UTIL_ADD_VIP_PLAYER(iClient, iTarget, "", g_ClientData[iClient].Get(DATA_TIME), VIP_AuthType:g_ClientData[iClient].Get(DATA_AUTH_TYPE), sGroup);
				//CloseHandleEx(g_ClientData[iClient]);
				DisplayMenu(g_hVIPAdminMenu, iClient, MENU_TIME_FOREVER);
			} else VIP_PrintToChatClient(iClient, "%t", "Player no longer available");
		}
	}
}
