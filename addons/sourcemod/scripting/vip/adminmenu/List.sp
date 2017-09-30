#define LIST_OFFSET		60

void ShowVipPlayersListMenu(int iClient)
{
	g_hClientData[iClient].SetValue(DATA_KEY_MenuListType, MENU_TYPE_ONLINE_LIST);
	g_hClientData[iClient].Remove(DATA_KEY_Search);

	char sUserID[16], sName[128];
	int i, iClientID;
	Menu hMenu = new Menu(MenuHandler_VipPlayersListMenu);

	hMenu.SetTitle("%T:\n ", "MENU_LIST_VIP", iClient);
	hMenu.ExitBackButton = true;

	hMenu.AddItem("search", "Найти игрока\n ");

	hMenu.AddItem("show_all", "Показать всех\n ");

	sUserID[0] = 0;
	for (i = 1; i <= MaxClients; ++i)
	{
		if (IsClientInGame(i) && (g_iClientInfo[i] & IS_VIP) && !IsFakeClient(i) && GetClientName(i, SZF(sName)))
		{
			g_hFeatures[i].GetValue(KEY_CID, iClientID);
			FormatEx(SZF(sUserID), "u%d", UID(i));
			if (iClientID == -1)
			{
			//	FormatEx(SZF(sUserID), "u%d", UID(i)); •
				Format(SZF(sName), "*%s", sName);
			}
			/*
			else
			{
				I2S(iClientID, SZF(sUserID));
			}
			*/
			
			hMenu.AddItem(sUserID, sName);
		}
	}
	
	if (sUserID[0] == 0)
	{
		FormatEx(SZF(sName), "%T", "NO_PLAYERS_AVAILABLE", iClient);
		hMenu.AddItem(NULL_STRING, sName, ITEMDRAW_DISABLED);
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
			char sUserID[16];
			hMenu.GetItem(Item, SZF(sUserID));
			
			if (!strcmp(sUserID, "search")) // Найти игрока
			{
				ShowWaitSearchMenu(iClient);

				return 0;
			}

			if (!strcmp(sUserID, "show_all")) // Показать всех
			{
				ShowVipPlayersFromDBMenu(iClient);
				
				return 0;
			}

			if (!strcmp(sUserID, "more")) // Показать еще
			{
				int iOffset;
				g_hClientData[iClient].GetValue(DATA_KEY_Offset, iOffset);
				ShowVipPlayersFromDBMenu(iOffset, iOffset + LIST_OFFSET);

				return 0;
			}

			if (sUserID[0] == 'u')
			{
				int UserID = S2I(sUserID[1]);
				int iTarget = CID(UserID);
				if (iTarget)
				{
					g_hClientData[iClient].SetValue(DATA_KEY_TargetUID, UserID);
					g_hFeatures[iTarget].GetValue(KEY_CID, UserID);
					g_hClientData[iClient].SetValue(DATA_KEY_TargetID, UserID);
					
					if(UserID == -1)
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

			g_hClientData[iClient].SetValue(DATA_KEY_TargetID, S2I(sUserID));

			ShowTargetInfo(iClient);
		}
	}
	
	return 0;
}

void ShowWaitSearchMenu(int iClient, const char[] sSearch = NULL_STRING)
{
	char sBuffer[128];
	Menu hMenu = new Menu(MenuHandler_SearchPlayersListMenu);
	hMenu.SetTitle("%T \"%T\"\n ", "ENTER_AUTH", iClient, "CONFIRM", iClient);

	FormatEx(SZF(sBuffer), "%T", "CONFIRM", iClient);
	if (sSearch[0])
	{
		//	g_iClientInfo[iClient] &= ~IS_WAIT_CHAT_SEARCH;
		hMenu.AddItem(sSearch, sBuffer);
	}
	else
	{
		g_iClientInfo[iClient] |= IS_WAIT_CHAT_SEARCH;
		hMenu.AddItem(NULL_STRING, sBuffer, ITEMDRAW_DISABLED);
	}
	
	FormatEx(SZF(sBuffer), "%T", "CANCEL", iClient);
	hMenu.AddItem(NULL_STRING, sBuffer);
	
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
					char sSearch[32];
					hMenu.GetItem(Item, SZF(sSearch));
					g_hClientData[iClient].SetString(DATA_KEY_Search, sSearch);
					ShowVipPlayersFromDBMenu(iClient);
				}
				case 1:
				{
					ShowVipPlayersListMenu(iClient);
				}
			}
		}
	}
}

void ShowVipPlayersFromDBMenu(int iClient, int iOffset = 0)
{
	g_hClientData[iClient].SetValue(DATA_KEY_MenuListType, MENU_TYPE_DB_LIST);
	g_hClientData[iClient].SetValue(DATA_KEY_Offset, iOffset);

	char sQuery[512], sSearch[64];
	sSearch[0] = 0;
	g_hClientData[iClient].GetString(DATA_KEY_Search, SZF(sSearch));

	if (GLOBAL_INFO & IS_MySQL)
	{
		if(sSearch[0])
		{
			FormatEx(SZF(sQuery), "SELECT `u`.`id`, \
													`u`.`name` \
													FROM `vip_users` AS `u` \
													LEFT JOIN `vip_overrides` AS `o` \
													ON `o`.`user_id` = `u`.`id` \
													WHERE `o`.`server_id` = %d \
													AND (`u`.`auth` LIKE '%%%s%%' OR `u`.`name` LIKE '%%%s%%') LIMIT %d, %d;", 
				g_CVAR_iServerID, sSearch, sSearch, iOffset, LIST_OFFSET);
		}
		else
		{
			FormatEx(SZF(sQuery), "SELECT `u`.`id`, \
												`u`.`name` \
												FROM `vip_users` AS `u` \
												LEFT JOIN `vip_overrides` AS `o` \
												ON `o`.`user_id` = `u`.`id` \
												WHERE `o`.`server_id` = %d LIMIT %d, %d;", 
			g_CVAR_iServerID, iOffset, LIST_OFFSET);
		}
	}
	else
	{
		if(sSearch[0])
		{
			FormatEx(SZF(sQuery), "SELECT `id`, `name` \
											FROM `vip_users` \
											WHERE (`auth` LIKE '%%%s%%' OR `name` LIKE '%%%s%%') LIMIT %d, %d;", 
			sSearch, sSearch, iOffset, LIST_OFFSET);
		}
		else
		{
			FormatEx(SZF(sQuery), "SELECT `id`, `name` \
											FROM `vip_users` LIMIT %d, %d;", 
			iOffset, LIST_OFFSET);
		}
	}
	
	DebugMessage(sQuery)
	g_hDatabase.Query(SQL_Callback_SelectVipPlayers, sQuery, UID(iClient));
}

public void SQL_Callback_SelectVipPlayers(Database hOwner, DBResultSet hResult, const char[] sError, any UserID)
{
	if (hResult == null || sError[0])
	{
		LogError("SQL_Callback_SelectVipPlayers: %s", sError);
		return;
	}

	int iClient = CID(UserID);
	if (iClient)
	{
		char sName[128], sSearch[64];
		Menu hMenu = new Menu(MenuHandler_VipPlayersListMenu);
		hMenu.ExitBackButton = true;
		sSearch[0] = 0;
		g_hClientData[iClient].GetString(DATA_KEY_Search, SZF(sSearch));
		if(sSearch[0])
		{
			hMenu.SetTitle("%T:\n%T:\n ", "MENU_LIST_VIP", iClient, "MENU_SEARCH", iClient, sSearch, hResult.RowCount);
		}
		else
		{
			hMenu.SetTitle("%T:\n ", "MENU_LIST_VIP", iClient);
		}
		
		if (!hResult.RowCount)
		{
			FormatEx(SZF(sName), "%T", "NO_PLAYERS_AVAILABLE", iClient);
			hMenu.AddItem(NULL_STRING, sName, ITEMDRAW_DISABLED);
			hMenu.Display(iClient, MENU_TIME_FOREVER);
			return;
		}

		char sUserID[16];
		int iClientID;
		while (hResult.FetchRow())
		{
			iClientID = hResult.FetchInt(0);
			IntToString(iClientID, SZF(sUserID));
			hResult.FetchString(1, SZF(sName));
			
			if(IsClientOnline(iClientID))
			{
				Format(SZF(sName), "• %s", sName);
			}
			hMenu.AddItem(sUserID, sName);
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

	char sQuery[512];
	if (GLOBAL_INFO & IS_MySQL)
	{
		FormatEx(SZF(sQuery), "SELECT `o`.`group`, \
												`o`.`expires`, \
												`u`.`name`, \
												`u`.`auth`, \
												`u`.`id` \
												FROM `vip_users` AS `u` \
												LEFT JOIN `vip_overrides` AS `o` \
												ON `o`.`user_id` = `u`.`id` \
												WHERE `o`.`server_id` = %d \
												AND `u`.`id` = %d LIMIT 1;", 
			g_CVAR_iServerID, iClientID);
	}
	else
	{
		FormatEx(SZF(sQuery), "SELECT `group`, \
												`expires`, \
												`name`, \
												`auth`, \
												`id` \
												FROM `vip_users` \
												WHERE `id` = %d LIMIT 1;", 
			iClientID);
	}

	DebugMessage(sQuery)
	g_hDatabase.Query(SQL_Callback_SelectVipClientInfo, sQuery, UID(iClient));
}

public void SQL_Callback_SelectVipClientInfo(Database hOwner, DBResultSet hResult, const char[] sError, any UserID)
{
	if (hResult == null || sError[0])
	{
		LogError("SQL_Callback_SelectVipClientInfo: %s", sError);
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
	
		char sGroup[64], sName[32], sAuth[32];

		hResult.FetchString(0, SZF(sGroup)); // GROUP
		g_hClientData[iClient].SetString(DATA_KEY_Group, sGroup);

		int iExpires = hResult.FetchInt(1); // Expires
		g_hClientData[iClient].SetValue(DATA_KEY_Time, iExpires);
		DebugMessage("SetValue(%s) = %d", DATA_KEY_Time, iExpires)

		hResult.FetchString(2, SZF(sName)); // Name
		g_hClientData[iClient].SetString(DATA_KEY_Name, sName);

		hResult.FetchString(3, SZF(sAuth)); // Auth
		g_hClientData[iClient].SetString(DATA_KEY_Auth, sAuth);

		ShowTargetInfoMenu(iClient);
	}
}

void ShowTemporaryTargetInfo(int iClient)
{
	char sGroup[64], sName[32], sAuth[32];
	int iTarget;
	g_hClientData[iClient].GetValue(DATA_KEY_TargetUID, iTarget);
	iTarget = CID(iTarget);
	if(!iTarget)
	{
		VIP_PrintToChatClient(iClient, "%t", "PLAYER_NO_LONGER_AVAILABLE");
		ShowVipPlayersListMenu(iClient);
		return;
	}

	g_hFeatures[iTarget].GetString(KEY_GROUP, SZF(sGroup));
	g_hClientData[iClient].SetString(DATA_KEY_Group, sGroup);

	int iExpires;
	g_hFeatures[iTarget].GetValue(KEY_EXPIRES, iExpires);
	g_hClientData[iClient].SetValue(DATA_KEY_Time, iExpires);
	GetClientName(iTarget, SZF(sName));
	GetClientAuthId(iTarget, AuthId_Engine, SZF(sAuth));

	g_hClientData[iClient].SetString(DATA_KEY_Name, sName);
	g_hClientData[iClient].SetString(DATA_KEY_Auth, sAuth);

	ShowTargetInfoMenu(iClient);
}

void ShowTargetInfoMenu(int iClient)
{
	char sGroup[64], sName[32], sAuth[32], sBuffer[128];
	g_hClientData[iClient].GetString(DATA_KEY_Group, SZF(sGroup));
	g_hClientData[iClient].GetString(DATA_KEY_Name, SZF(sName));
	g_hClientData[iClient].GetString(DATA_KEY_Auth, SZF(sAuth));
	int iExpires, iClientID;
	g_hClientData[iClient].GetValue(DATA_KEY_Time, iExpires);
	DebugMessage("GetValue(%s) = %d", DATA_KEY_Time, iExpires)
	g_hClientData[iClient].GetValue(DATA_KEY_TargetID, iClientID);

	if (iExpires > 0)
	{
		int iTime = GetTime();
		if (iExpires > iTime)
		{
			UTIL_GetTimeFromStamp(SZF(sBuffer), iExpires - iTime, iClient);
			Format(SZF(sBuffer), "%T: %s", "EXPIRE", iClient, sBuffer);
		}
		else
		{
			FormatEx(SZF(sBuffer), "%T", "EXPIRED", iClient);
		}
	}
	else
	{
		FormatEx(SZF(sBuffer), "%T", "NEVER", iClient);
	}
	
	if(iClientID == -1)
	{
		Format(SZF(sBuffer), "%s (%T)", sBuffer, "TEMPORARY", iClient);
	}

	Menu hMenu = new Menu(MenuHandler_VipClientInfoMenu);

	hMenu.ExitBackButton = true;
	hMenu.SetTitle("%T\n ", "MENU_INFO_VIP_PLAYER", iClient, sName, sAuth, sGroup, sBuffer);

	FormatEx(SZF(sBuffer), "%T", "MENU_DEL_VIP", iClient);			//		1. Удалить игрока
	hMenu.AddItem(NULL_STRING, sBuffer);
	FormatEx(SZF(sBuffer), "%T", "MENU_EDIT_TIME", iClient);		//		2. Изменить срок 
	hMenu.AddItem(NULL_STRING, sBuffer, iClientID == -1 ? ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
	FormatEx(SZF(sBuffer), "%T", "MENU_EDIT_GROUP", iClient);		//		3. Изменить группу
	hMenu.AddItem(NULL_STRING, sBuffer);

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
				case 0:	ShowDeleteVipPlayerMenu(iClient);
				case 1:	ShowEditTimeMenu(iClient);
				case 2:
				{
					g_hClientData[iClient].SetValue(DATA_KEY_MenuType, MENU_TYPE_EDIT);
					char sGroup[64];
					g_hClientData[iClient].GetString(DATA_KEY_Group, SZF(sGroup));
					ShowGroupsMenu(iClient, sGroup);
				}
			}
		}
	}
} 