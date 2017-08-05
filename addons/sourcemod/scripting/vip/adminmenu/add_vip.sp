void ShowAddVIPMenu(int iClient)
{
	char sUserId[12], sName[64];
	Menu hMenu = new Menu(MenuHandler_AddVip_PlayerList);
	hMenu.SetTitle("%T:\n ", "MENU_ADD_VIP", iClient);
	hMenu.ExitBackButton = true;

	sUserId[0] = 0;

	for (int i = 1, iClientID; i <= MaxClients; ++i)
	{
		if (IsClientInGame(i) && IsFakeClient(i) == false && GetClientName(i, SZF(sName)))
		{
			if (g_iClientInfo[i] & IS_VIP)
			{
				g_hFeatures[i].GetValue(KEY_CID, iClientID);
				if (iClientID != -1)
				{
					continue;
				}

				Format(SZF(sName), "* %s", sName);
			}

			IntToString(UID(i), SZF(sUserId));
			hMenu.AddItem(sUserId, sName);
		}
	}
	
	if (sUserId[0] == 0)
	{
		FormatEx(SZF(sName), "%T", "NO_PLAYERS_AVAILABLE", iClient);
		hMenu.AddItem(NULL_STRING, sName, ITEMDRAW_DISABLED);
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
			if (Item == MenuCancel_ExitBack) BackToAdminMenu(iClient);
		}
		case MenuAction_Select:
		{
			char sUserID[16];
			int UserID;
			hMenu.GetItem(Item, SZF(sUserID));
			UserID = StringToInt(sUserID);
			if (CID(UserID))
			{
				g_hClientData[iClient].SetValue(DATA_KEY_TargetUID, UserID);
				g_hClientData[iClient].SetValue(DATA_KEY_TimeType, TIME_SET);
				g_hClientData[iClient].SetValue(DATA_KEY_MenuType, MENU_TYPE_ADD);
				ShowTimeMenu(iClient);
			} else VIP_PrintToChatClient(iClient, "%t", "PLAYER_NO_LONGER_AVAILABLE");
		}
	}
}
