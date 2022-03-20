static const int LIST_OFFSET = 60;

void ShowVipPlayersListMenu(int iClient)
{
	g_hClientData[iClient].SetValue(DATA_KEY_MenuListType, MENU_TYPE_ONLINE_LIST);
	g_hClientData[iClient].Remove(DATA_KEY_Search);

	char szUserID[16], szName[128];
	int i, iClientID;
	Menu hMenu = new Menu(MenuHandler_VipPlayersListMenu);

	hMenu.SetTitle("%T:\n ", "MENU_LIST_VIP", iClient);
	hMenu.ExitBackButton = true;

	FormatEx(SZF(szName), "%T\n ", "FIND_PLAYER", iClient);
	hMenu.AddItem("search", szName);

	FormatEx(SZF(szName), "%T\n ", "SHOW_ALL", iClient);
	hMenu.AddItem("show_all", szName);

	szUserID[0] = 0;
	for (i = 1; i <= MaxClients; ++i)
	{
		if (IsClientInGame(i) && IS_CLIENT_VIP(i) && !IsFakeClient(i) && GetClientName(i, SZF(szName)))
		{
			g_hFeatures[i].GetValue(KEY_CID, iClientID);
			FormatEx(SZF(szUserID), "u%d", UID(i));
			if (iClientID == -1)
			{
			//	FormatEx(SZF(szUserID), "u%d", UID(i)); •
				Format(SZF(szName), "*%s", szName);
			}
			/*
			else
			{
				I2S(iClientID, SZF(szUserID));
			}
			*/
			
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

public int MenuHandler_VipPlayersListMenu(Menu hMenu, MenuAction action, int iClient, int Item)
{
	switch (action)
	{
		case MenuAction_End: delete hMenu;
		case MenuAction_Cancel:
		{
			if (Item == MenuCancel_ExitBack) BackToAdminMenu(iClient);
		}
		case MenuAction_Select:
		{
			char szUserID[16];
			hMenu.GetItem(Item, SZF(szUserID));
			
			if (!strcmp(szUserID, "search")) // Найти игрока
			{
				ShowWaitSearchMenu(iClient);

				return 0;
			}

			if (!strcmp(szUserID, "show_all")) // Показать всех
			{
				g_hClientData[iClient].Remove(DATA_KEY_Search);
				ShowVipPlayersFromDBMenu(iClient);
				
				return 0;
			}

			if (!strcmp(szUserID, "more")) // Показать еще
			{
				int iOffset;
				g_hClientData[iClient].GetValue(DATA_KEY_Offset, iOffset);
				ShowVipPlayersFromDBMenu(iClient, iOffset + LIST_OFFSET);

				return 0;
			}

			if (szUserID[0] == 'u')
			{
				int UserID = S2I(szUserID[1]);
				int iTarget = CID(UserID);
				if (iTarget)
				{
					g_hClientData[iClient].SetValue(DATA_KEY_TargetUID, UserID);
					g_hFeatures[iTarget].GetValue(KEY_CID, UserID);
					g_hClientData[iClient].SetValue(DATA_KEY_TargetID, UserID);
					
					if (UserID == -1)
					{
						ShowTemporaryTargetInfo(iClient);
						return 0;
					}

					ShowTargetInfo(iClient);
				}
				else
				{
					VIP_PrintToChatClient(iClient, "%t", "PLAYER_NO_LONGER_AVAILABLE");
				}
				
				return 0;
				
			}

			g_hClientData[iClient].SetValue(DATA_KEY_TargetID, S2I(szUserID));

			ShowTargetInfo(iClient);
		}
	}
	
	return 0;
}

void ShowWaitSearchMenu(int iClient, const char[] szSearch = NULL_STRING)
{
	char szBuffer[128];
	Menu hMenu = new Menu(MenuHandler_SearchPlayersListMenu);
	hMenu.SetTitle("%T \"%T\"\n ", "ENTER_AUTH", iClient, "CONFIRM", iClient);

	FormatEx(SZF(szBuffer), "%T", "CONFIRM", iClient);
	if (szSearch[0])
	{
		//	g_iClientInfo[iClient] &= ~IS_WAIT_CHAT_SEARCH;
		hMenu.AddItem(szSearch, szBuffer);
	}
	else
	{
		g_iClientInfo[iClient] |= IS_WAIT_CHAT_SEARCH;
		hMenu.AddItem(NULL_STRING, szBuffer, ITEMDRAW_DISABLED);
	}
	
	FormatEx(SZF(szBuffer), "%T", "CANCEL", iClient);
	hMenu.AddItem(NULL_STRING, szBuffer);
	
	ReductionMenu(hMenu, 4);
	
	hMenu.Display(iClient, MENU_TIME_FOREVER);
}

public int MenuHandler_SearchPlayersListMenu(Menu hMenu, MenuAction action, int iClient, int Item)
{
	switch (action)
	{
		case MenuAction_End: delete hMenu;
		case MenuAction_Cancel:
		{
			if (Item != MenuCancel_Interrupted)
			{
				g_iClientInfo[iClient] &= ~IS_WAIT_CHAT_SEARCH;
			}
			
			if (Item == MenuCancel_ExitBack)
			{
				ShowVipPlayersListMenu(iClient);
			}
		}
		case MenuAction_Select:
		{
			g_iClientInfo[iClient] &= ~IS_WAIT_CHAT_SEARCH;
			switch (Item)
			{
				case 0:
				{
					char szSearch[32];
					hMenu.GetItem(Item, SZF(szSearch));
					g_hClientData[iClient].SetString(DATA_KEY_Search, szSearch);
					ShowVipPlayersFromDBMenu(iClient);
				}
				case 1:
				{
					ShowVipPlayersListMenu(iClient);
				}
			}
		}
	}

	return 0;
}

void ShowVipPlayersFromDBMenu(int iClient, int iOffset = 0)
{
	LogMessage("ShowVipPlayersFromDBMenu");
	g_hClientData[iClient].SetValue(DATA_KEY_MenuListType, MENU_TYPE_DB_LIST);
	g_hClientData[iClient].SetValue(DATA_KEY_Offset, iOffset);

	char szQuery[1024], szSearch[64], szWhere[128];
	szSearch[0] = 0;
	szWhere[0] = 0;
	if (g_hClientData[iClient].GetString(DATA_KEY_Search, SZF(szSearch)) && szSearch[0])
	{
		int iAccountID = UTIL_GetAccountIDFromSteamID(szSearch);
		if (iAccountID)
		{
			FormatEx(SZF(szWhere), " AND `account_id` = %d", iAccountID);
		}
		else
		{
			FormatEx(SZF(szWhere), " AND `name` LIKE '%%%s%%'", szSearch);
		}
	}

	if (GLOBAL_INFO & IS_MySQL)
	{
		FormatEx(SZF(szQuery), "SELECT `account_id`, \
										`name` \
										FROM `vip_users` \
										WHERE %s%s \ 
										LIMIT %d, %d;",
			g_szSID[5], szWhere, iOffset, LIST_OFFSET);
	}
	else
	{
		if (szWhere[0])
		{
			FormatEx(SZF(szQuery), "SELECT `account_id`, `name` \
									FROM `vip_users` \
									WHERE %s LIMIT %d, %d;", 
			szWhere[5], iOffset, LIST_OFFSET);
		}
		else
		{
			FormatEx(SZF(szQuery), "SELECT `account_id`, `name` \
									FROM `vip_users` LIMIT %d, %d;", 
			iOffset, LIST_OFFSET);
		}
	}

	DBG_SQL_Query(szQuery)

	g_hDatabase.Query(SQL_Callback_SelectVipPlayers, szQuery, UID(iClient));
}

public void SQL_Callback_SelectVipPlayers(Database hOwner, DBResultSet hResult, const char[] szError, any UserID)
{
	DBG_SQL_Response("SQL_Callback_SelectVipPlayers")
	if (hResult == null || szError[0])
	{
		LogError("SQL_Callback_SelectVipPlayers: %s", szError);
		return;
	}

	int iClient = CID(UserID);
	if (iClient)
	{
		char szName[128], szSearch[64];
		Menu hMenu = new Menu(MenuHandler_VipPlayersListMenu);
		hMenu.ExitBackButton = true;
		szSearch[0] = 0;
		g_hClientData[iClient].GetString(DATA_KEY_Search, SZF(szSearch));
		if (szSearch[0])
		{
			hMenu.SetTitle("%T:\n%T:\n ", "MENU_LIST_VIP", iClient, "MENU_SEARCH", iClient, szSearch, hResult.RowCount);
		}
		else
		{
			hMenu.SetTitle("%T:\n ", "MENU_LIST_VIP", iClient);
		}

		DBG_SQL_Response("hResult.RowCount = %d", hResult.RowCount)
		
		if (!hResult.RowCount)
		{
			FormatEx(SZF(szName), "%T", "NO_PLAYERS_AVAILABLE", iClient);
			hMenu.AddItem(NULL_STRING, szName, ITEMDRAW_DISABLED);
			hMenu.Display(iClient, MENU_TIME_FOREVER);
			return;
		}

		char szUserID[16];
		int iClientID;
		while (hResult.FetchRow())
		{
			DBG_SQL_Response("hResult.FetchRow()")
			iClientID = hResult.FetchInt(0);
			IntToString(iClientID, SZF(szUserID));
			hResult.FetchString(1, SZF(szName));
			DBG_SQL_Response("hResult.FetchInt(0) = %d", iClientID)
			DBG_SQL_Response("hResult.FetchString(1) = '%s", szName)
			
			if (UTIL_GetVipClientByAccountID(iClientID))
			{
				Format(SZF(szName), "• %s", szName);
			}
			hMenu.AddItem(szUserID, szName);
		}
		
		if (hResult.RowCount == LIST_OFFSET)
		{
			hMenu.AddItem(NULL_STRING, "ITEMDRAW_SPACER", ITEMDRAW_SPACER);
			hMenu.AddItem("more", "Показать еще");
		}

		hMenu.Display(iClient, MENU_TIME_FOREVER);
	}
}

void ShowTargetInfo(int iClient)
{
	int iClientID;
	g_hClientData[iClient].GetValue(DATA_KEY_TargetID, iClientID);

	char szQuery[512];
	FormatEx(SZF(szQuery), "SELECT `group`, \
									`expires`, \
									`name`, \
									`account_id` \
									FROM `vip_users` \
									WHERE `account_id` = %d%s LIMIT 1;", 
									iClientID, g_szSID);

	DBG_SQL_Query(szQuery)
	g_hDatabase.Query(SQL_Callback_SelectVipClientInfo, szQuery, UID(iClient));
}

public void SQL_Callback_SelectVipClientInfo(Database hOwner, DBResultSet hResult, const char[] szError, any UserID)
{
	DBG_SQL_Response("SQL_Callback_SelectVipClientInfo")
	if (hResult == null || szError[0])
	{
		LogError("SQL_Callback_SelectVipClientInfo: %s", szError);
		return;
	}
	
	int iClient = CID(UserID);
	if (iClient)
	{
		if (!hResult.FetchRow())
		{
			VIP_PrintToChatClient(iClient, "%t", "FAILED_TO_LOAD_PLAYER");
			BackToAdminMenu(iClient);
			return;
		}

		DBG_SQL_Response("hResult.FetchRow()")
	
		char szGroup[64], szName[32];

		hResult.FetchString(0, SZF(szGroup)); // GROUP
		g_hClientData[iClient].SetString(DATA_KEY_Group, szGroup);
		DBG_SQL_Response("hResult.FetchString(0) = '%s", szGroup)

		int iExpires = hResult.FetchInt(1); // Expires
		g_hClientData[iClient].SetValue(DATA_KEY_Time, iExpires);
		DBG_SQL_Response("hResult.FetchInt(1) = %d", iExpires)

		hResult.FetchString(2, SZF(szName)); // Name
		g_hClientData[iClient].SetString(DATA_KEY_Name, szName);
		DBG_SQL_Response("hResult.FetchString(2) = '%s", szName)

		int iAccountID = hResult.FetchInt(3); // Auth
		g_hClientData[iClient].SetValue(DATA_KEY_Auth, iAccountID);
		DBG_SQL_Response("hResult.FetchInt(3) = %d", iAccountID)

		ShowTargetInfoMenu(iClient);
	}
}

void ShowTemporaryTargetInfo(int iClient)
{
	char szGroup[64], szName[32];
	int iTarget;
	g_hClientData[iClient].GetValue(DATA_KEY_TargetUID, iTarget);
	iTarget = CID(iTarget);
	if (!iTarget)
	{
		VIP_PrintToChatClient(iClient, "%t", "PLAYER_NO_LONGER_AVAILABLE");
		ShowVipPlayersListMenu(iClient);
		return;
	}

	g_hFeatures[iTarget].GetString(KEY_GROUP, SZF(szGroup));
	g_hClientData[iClient].SetString(DATA_KEY_Group, szGroup);

	int iExpires, iAccountID;
	g_hFeatures[iTarget].GetValue(KEY_EXPIRES, iExpires);
	g_hClientData[iClient].SetValue(DATA_KEY_Time, iExpires);
	GetClientName(iTarget, SZF(szName));
	iAccountID = GetSteamAccountID(iClient);

	g_hClientData[iClient].SetString(DATA_KEY_Name, szName);
	g_hClientData[iClient].SetValue(DATA_KEY_Auth, iAccountID);

	ShowTargetInfoMenu(iClient);
}

void ShowTargetInfoMenu(int iClient)
{
	char szGroup[64], szName[32], szAuth[32], szBuffer[128];
	g_hClientData[iClient].GetString(DATA_KEY_Group, SZF(szGroup));
	g_hClientData[iClient].GetString(DATA_KEY_Name, SZF(szName));
	int iExpires, iClientID, iAccountID;
	g_hClientData[iClient].GetValue(DATA_KEY_Time, iExpires);
	DebugMessage("GetValue(%s) = %d", DATA_KEY_Time, iExpires)
	g_hClientData[iClient].GetValue(DATA_KEY_TargetID, iClientID);
	g_hClientData[iClient].GetValue(DATA_KEY_Auth, iAccountID);
	UTIL_GetSteamIDFromAccountID(iAccountID, SZF(szAuth));

	if (iExpires > 0)
	{
		int iTime = GetTime();
		if (iExpires > iTime)
		{
			UTIL_GetTimeFromStamp(SZF(szBuffer), iExpires - iTime, iClient);
			Format(SZF(szBuffer), "%T: %s", "EXPIRE", iClient, szBuffer);
		}
		else
		{
			FormatEx(SZF(szBuffer), "%T", "EXPIRED", iClient);
		}
	}
	else
	{
		FormatEx(SZF(szBuffer), "%T", "NEVER", iClient);
	}

	if (iClientID == -1)
	{
		Format(SZF(szBuffer), "%s (%T)", szBuffer, "TEMPORARY", iClient);
	}

	Menu hMenu = new Menu(MenuHandler_VipClientInfoMenu);

	hMenu.ExitBackButton = true;
	hMenu.SetTitle("%T\n ", "MENU_INFO_VIP_PLAYER", iClient, szName, szAuth, szGroup, szBuffer);

	FormatEx(SZF(szBuffer), "%T", "MENU_DEL_VIP", iClient);			//		1. Удалить игрока
	hMenu.AddItem(NULL_STRING, szBuffer);
	FormatEx(SZF(szBuffer), "%T", "MENU_EDIT_TIME", iClient);		//		2. Изменить срок 
	hMenu.AddItem(NULL_STRING, szBuffer, iClientID == -1 ? ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
	FormatEx(SZF(szBuffer), "%T", "MENU_EDIT_GROUP", iClient);		//		3. Изменить группу
	hMenu.AddItem(NULL_STRING, szBuffer);

	ReductionMenu(hMenu, 2);

	hMenu.Display(iClient, MENU_TIME_FOREVER);
}

public int MenuHandler_VipClientInfoMenu(Menu hMenu, MenuAction action, int iClient, int Item)
{
	switch (action)
	{
		case MenuAction_End: delete hMenu;
		case MenuAction_Cancel:
		{
			if (Item == MenuCancel_ExitBack)
			{
				DebugMessage("MenuHandler_VipClientInfoMenu->MenuCancel_ExitBack")
				int iBuffer;
				g_hClientData[iClient].GetValue(DATA_KEY_MenuListType, iBuffer);
				DebugMessage("GetValue(%s) = %d", DATA_KEY_MenuListType, iBuffer)
				switch(iBuffer)
				{
					case MENU_TYPE_ONLINE_LIST:
					{
						ShowVipPlayersListMenu(iClient);
					}
					case MENU_TYPE_DB_LIST:
					{
						int iOffset;
						g_hClientData[iClient].GetValue(DATA_KEY_Offset, iOffset);
						ShowVipPlayersFromDBMenu(iClient, iOffset);
					}
				}
			}
		}
		case MenuAction_Select:
		{
			switch (Item)
			{
				case 0:	ShowConfirmDeleteVipPlayerMenu(iClient);
				case 1:	ShowEditTimeMenu(iClient);
				case 2:
				{
					g_hClientData[iClient].SetValue(DATA_KEY_MenuType, MENU_TYPE_EDIT);
					char szGroup[64];
					g_hClientData[iClient].GetString(DATA_KEY_Group, SZF(szGroup));
					ShowGroupsMenu(iClient, szGroup);
				}
			}
		}
	}

	return 0;
} 
