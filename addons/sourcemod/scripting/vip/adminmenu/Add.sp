void ShowAddVIPMenu(int iClient)
{
	char szUserID[12], szName[64];
	Menu hMenu = new Menu(MenuHandler_AddVip_PlayerList);
	hMenu.SetTitle("%T:\n ", "MENU_ADD_VIP", iClient);
	hMenu.ExitBackButton = true;

	szUserID[0] = 0;

	for (int i = 1, iClientID; i <= MaxClients; ++i)
	{
		if (IsClientInGame(i) && IsFakeClient(i) == false && GetClientName(i, SZF(szName)))
		{
			if (IS_CLIENT_VIP(i))
			{
				g_hFeatures[i].GetValue(KEY_CID, iClientID);
				if (iClientID != -1)
				{
					continue;
				}

				Format(SZF(szName), "* %s", szName);
			}

			IntToString(UID(i), SZF(szUserID));
			hMenu.AddItem(szUserID, szName);
		}
	}
	
	if (szUserID[0] == 0)
	{
		FormatEx(SZF(szName), "%T", "NO_PLAYERS_AVAILABLE", iClient);
		hMenu.AddItem(NULL_STRING, szName, ITEMDRAW_DISABLED);
	}

	hMenu.Display(iClient, MENU_TIME_FOREVER);
}

public int MenuHandler_AddVip_PlayerList(Menu hMenu, MenuAction action, int iClient, int Item)
{
	switch (action)
	{
		case MenuAction_End:delete hMenu;
		case MenuAction_Cancel:
		{
			if (Item == MenuCancel_ExitBack)
			{
				BackToAdminMenu(iClient);
			}
		}
		case MenuAction_Select:
		{
			char szUserID[16];
			hMenu.GetItem(Item, SZF(szUserID));
			int UserID = StringToInt(szUserID);
			if (!CID(UserID))
			{
				VIP_PrintToChatClient(iClient, "%t", "PLAYER_NO_LONGER_AVAILABLE");
				return 0;
			}

			g_hClientData[iClient].SetValue(DATA_KEY_TargetUID, UserID);
			g_hClientData[iClient].SetValue(DATA_KEY_TimeType, TIME_SET);
			g_hClientData[iClient].SetValue(DATA_KEY_MenuType, MENU_TYPE_ADD);
			ShowTimeMenu(iClient);
		}
	}

	return 0;
}
