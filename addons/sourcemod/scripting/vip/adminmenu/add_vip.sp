void ShowAddVIPMenu(int iClient)
{
	char sUserId[12], sName[64];
	Menu hMenu = new Menu(MenuHandler_AddVip_PlayerList);
	hMenu.SetTitle("%T:\n \n", "MENU_ADD_VIP", iClient);
	hMenu.ExitBackButton = true;

	sUserId[0] = 0;

	for (int i = 1, iClientID; i <= MaxClients; ++i)
	{
		if (IsClientInGame(i) && IsFakeClient(i) == false)
		{
			if (g_iClientInfo[i] & IS_VIP)
			{
				g_hFeatures[i].GetValue(KEY_CID, iClientID);
				if (iClientID != -1)
				{
					continue;
				}
			}

			if (GetClientName(i, sName, sizeof(sName)))
			{
				IntToString(UID(i), sUserId, sizeof(sUserId));
				hMenu.AddItem(sUserId, sName);
			}
		}
	}
	
	if (sUserId[0] == 0)
	{
		FormatEx(sName, sizeof(sName), "%T", "NO_PLAYERS_AVAILABLE", iClient);
		hMenu.AddItem("", sName, ITEMDRAW_DISABLED);
	}

	hMenu.Display(iClient, MENU_TIME_FOREVER);
}

public int MenuHandler_AddVip_PlayerList(Menu hMenu, MenuAction action, int iClient, int Item)
{
	switch (action)
	{
		case MenuAction_End:CloseHandle(hMenu);
		case MenuAction_Cancel:
		{
			if (Item == MenuCancel_ExitBack)g_hVIPAdminMenu.Display(iClient, MENU_TIME_FOREVER);
		}
		case MenuAction_Select:
		{
			char sUserID[12]; int UserID;
			hMenu.GetItem(Item, sUserID, sizeof(sUserID));
			UserID = StringToInt(sUserID);
			if (CID(UserID))
			{
				SetArrayCell(g_ClientData[iClient], DATA_TARGET_USER_ID, UserID);
				SetArrayCell(g_ClientData[iClient], DATA_TIME, TIME_SET);
				SetArrayCell(g_ClientData[iClient], DATA_MENU_TYPE, MENU_TYPE_ADD);
				ShowTimeMenu(iClient);
			} else VIP_PrintToChatClient(iClient, "%t", "PLAYER_NO_LONGER_AVAILABLE");
		}
	}
}

void ShowGroupMenu(int iClient)
{
	char sGroup[MAX_NAME_LENGTH];
	Menu hMenu = new Menu(MenuHandler_AddVip_GroupsList);
	hMenu.SetTitle("%T:\n \n", "GROUP", iClient);
	hMenu.ExitBackButton = true;
	sGroup[0] = 0;
	g_hGroups.Rewind();
	if (g_hGroups.GotoFirstSubKey())
	{
		do
		{
			if (g_hGroups.GetSectionName(sGroup, sizeof(sGroup)))
			{
				hMenu.AddItem(sGroup, sGroup);
			}
		} while g_hGroups.GotoNextKey();
	}
	if (sGroup[0] == 0)
	{
		FormatEx(sGroup, sizeof(sGroup), "%T", "NO_GROUPS_AVAILABLE", iClient);
		hMenu.AddItem("", sGroup, ITEMDRAW_DISABLED);
	}

	hMenu.Display(iClient, MENU_TIME_FOREVER);
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
			int iTarget = CID(g_ClientData[iClient].Get(DATA_TARGET_USER_ID));
			if (iTarget)
			{
				char sGroup[MAX_NAME_LENGTH];
				hMenu.GetItem(Item, sGroup, sizeof(sGroup));
				UTIL_ADD_VIP_PLAYER(iClient, iTarget, "", GetArrayCell(g_ClientData[iClient], DATA_TIME), sGroup);
				//CloseHandleEx(g_ClientData[iClient]);
				g_hVIPAdminMenu.Display(iClient, MENU_TIME_FOREVER);
			} else VIP_PrintToChatClient(iClient, "%t", "Player no longer available");
		}
	}
}