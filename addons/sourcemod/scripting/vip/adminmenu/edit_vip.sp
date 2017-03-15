void ShowEditTimeMenu(int iClient)
{
	decl Handle:hMenu; char sBuffer[128];
	hMenu = CreateMenu(MenuHandler_EditTimeMenu);
	
	SetGlobalTransTarget(iClient);
	SetMenuTitle(hMenu, "%t:\n \n", "MENU_EDIT_TIME");
	SetMenuExitBackButton(hMenu, true);
	
	FormatEx(sBuffer, sizeof(sBuffer), "%t", "MENU_TIME_SET");
	AddMenuItem(hMenu, "", sBuffer);
	FormatEx(sBuffer, sizeof(sBuffer), "%t", "MENU_TIME_ADD");
	AddMenuItem(hMenu, "", sBuffer);
	FormatEx(sBuffer, sizeof(sBuffer), "%t", "MENU_TIME_TAKE");
	AddMenuItem(hMenu, "", sBuffer);
	
	ReductionMenu(hMenu, 3);
	
	DisplayMenu(hMenu, iClient, MENU_TIME_FOREVER);
}

public int MenuHandler_EditTimeMenu(Menu hMenu, MenuAction action, int iClient, int Item)
{
	switch (action)
	{
		case MenuAction_End:CloseHandle(hMenu);
		case MenuAction_Cancel:
		{
			if (Item == MenuCancel_ExitBack)ShowTargetInfoMenu(iClient, g_ClientData[iClient].Get(DATA_TARGET_ID));
		}
		case MenuAction_Select:
		{
			g_ClientData[iClient].Set(DATA_MENU_TYPE, MENU_TYPE_EDIT);
			g_ClientData[iClient].Set(DATA_TIME, Item);
			ShowTimeMenu(iClient);
		}
	}
}

void ShowEditPassMenu(int iClient)
{
	char sQuery[512];
	if (GLOBAL_INFO & IS_MySQL)
	{
		FormatEx(sQuery, sizeof(sQuery), "SELECT `u`.`password` \
												FROM `vip_users` AS `u` \
												LEFT JOIN `vip_overrides` AS `o` \
												ON `o`.`user_id` = `u`.`id` \
												WHERE `o`.`server_id` = '%i' \
												AND `u`.`id` = '%i' LIMIT 1;", 
			g_CVAR_iServerID, g_ClientData[iClient].Get(DATA_TARGET_ID));
	}
	else
	{
		FormatEx(sQuery, sizeof(sQuery), "SELECT `password` \
												FROM `vip_users` \
												WHERE `id` = '%i' LIMIT 1;", 
			g_ClientData[iClient].Get(DATA_TARGET_ID));
	}
	
	DebugMessage(sQuery)
	SQL_TQuery(g_hDatabase, SQL_Callback_SelectClientPass, sQuery, UID(iClient));
}


public void SQL_Callback_SelectClientPass(Handle hOwner, Handle hQuery, const char[] sError, any UserID)
{
	if (hQuery == INVALID_HANDLE || sError[0])
	{
		LogError("SQL_Callback_SelectClientPass: %s", sError);
		return;
	}
	
	new iClient = CID(UserID);
	if (iClient)
	{
		if (SQL_FetchRow(hQuery))
		{
			SetGlobalTransTarget(iClient);
			
			decl Handle:hMenu; char sBuffer[128];
			hMenu = CreateMenu(MenuHandler_EditPassMenu);
			SetMenuTitle(hMenu, "%t:\n \n", "MENU_EDIT_PASS");
			SetMenuExitBackButton(hMenu, true);
			SQL_FetchString(hQuery, 0, sBuffer, sizeof(sBuffer));
			if (sBuffer[0])
			{
				FormatEx(sBuffer, sizeof(sBuffer), "%t", "MENU_EDIT_PASS");
				AddMenuItem(hMenu, "edit_pass", sBuffer);
				FormatEx(sBuffer, sizeof(sBuffer), "%t", "MENU_DEL_PASS");
				AddMenuItem(hMenu, "del_pass", sBuffer);
				
				ReductionMenu(hMenu, 4);
			}
			else
			{
				FormatEx(sBuffer, sizeof(sBuffer), "%t", "MENU_ADD_PASS");
				AddMenuItem(hMenu, "add_pass", sBuffer);
				
				ReductionMenu(hMenu, 5);
			}
			
			DisplayMenu(hMenu, iClient, MENU_TIME_FOREVER);
		}
		else
		{
			VIP_PrintToChatClient(iClient, "%t", "FAILED_TO_LOAD_PLAYER");
		}
	}
}

public int MenuHandler_EditPassMenu(Menu hMenu, MenuAction action, int iClient, int Item)
{
	switch (action)
	{
		case MenuAction_End:CloseHandle(hMenu);
		case MenuAction_Cancel:
		{
			if (Item == MenuCancel_ExitBack)ShowTargetInfoMenu(iClient, g_ClientData[iClient].Get(DATA_TARGET_ID));
		}
		case MenuAction_Select:
		{
			char sInfo[4];
			GetMenuItem(hMenu, Item, sInfo, sizeof(sInfo));
			switch (sInfo[0])
			{
				case 'a', 'e':ShowWaitPassMenu(iClient);
				case 'd':ShowDelPassMenu(iClient);
			}
		}
	}
}

void ShowDelPassMenu(int iClient)
{
	SetGlobalTransTarget(iClient);
	
	decl Handle:hMenu; char sBuffer[128];
	hMenu = CreateMenu(MenuHandler_DelPassMenu);
	SetMenuTitle(hMenu, "%t:\n \n", "MENU_DEL_PASS");
	SetMenuExitBackButton(hMenu, true);
	
	FormatEx(sBuffer, sizeof(sBuffer), "%t", "CONFIRM");
	AddMenuItem(hMenu, "", sBuffer);
	FormatEx(sBuffer, sizeof(sBuffer), "%t", "CANCEL");
	AddMenuItem(hMenu, "", sBuffer);
	
	ReductionMenu(hMenu, 4);
	
	DisplayMenu(hMenu, iClient, MENU_TIME_FOREVER);
}

public int MenuHandler_DelPassMenu(Menu hMenu, MenuAction action, int iClient, int Item)
{
	switch (action)
	{
		case MenuAction_End:CloseHandle(hMenu);
		case MenuAction_Cancel:
		{
			if (Item == MenuCancel_ExitBack)ShowEditPassMenu(iClient);
		}
		case MenuAction_Select:
		{
			char sQuery[256]; iTarget; char sBuffer[MAX_NAME_LENGTH];
			
			iTarget = g_ClientData[iClient].Get(DATA_TARGET_ID);
			FormatEx(sQuery, sizeof(sQuery), "UPDATE `vip_users` SET `password` = NULL WHERE `id` = '%i';", iTarget);
			SQL_TQuery(g_hDatabase, SQL_Callback_ErrorCheck, sQuery);
			
			g_ClientData[iClient].GetString(DATA_NAME, sBuffer, sizeof(sBuffer));
			
			VIP_PrintToChatClient(iClient, "%t", "ADMIN_PASSWORD_REMOVED");
			if (g_CVAR_bLogsEnable)LogToFile(g_sLogFile, "%T", "LOG_ADMIN_PASSWORD_REMOVED", iClient, iClient, sBuffer);
			
			ShowTargetInfoMenu(iClient, iTarget);
		}
	}
}

void ShowWaitPassMenu(int iClient, const char[] sPass = "", const bool bIsValid = false)
{
	SetGlobalTransTarget(iClient);
	
	decl Handle:hMenu; char sBuffer[128];
	
	hMenu = CreateMenu(MenuHandler_EditVip_WaitPassMenu);
	SetMenuTitle(hMenu, "%t \"%t\"\n \n", "ENTER_PASS", "CONFIRM");
	
	FormatEx(sBuffer, sizeof(sBuffer), "%t", "CONFIRM");
	if (bIsValid)
	{
		AddMenuItem(hMenu, sPass, sBuffer);
		//	g_iClientInfo[iClient] &= ~IS_WAIT_CHAT_PASS;
	}
	else
	{
		AddMenuItem(hMenu, sPass, sBuffer, ITEMDRAW_DISABLED);
		g_iClientInfo[iClient] |= IS_WAIT_CHAT_PASS;
	}
	
	FormatEx(sBuffer, sizeof(sBuffer), "%t", "CANCEL");
	AddMenuItem(hMenu, "", sBuffer);
	
	ReductionMenu(hMenu, 4);
	
	DisplayMenu(hMenu, iClient, MENU_TIME_FOREVER);
}

public int MenuHandler_EditVip_WaitPassMenu(Menu hMenu, MenuAction action, int iClient, int Item)
{
	switch (action)
	{
		case MenuAction_End:CloseHandle(hMenu);
		case MenuAction_Cancel:
		{
			if (Item != MenuCancel_Interrupted)
			{
				g_iClientInfo[iClient] &= ~IS_WAIT_CHAT_PASS;
			}
			
			if (Item == MenuCancel_ExitBack)
			{
				ShowEditPassMenu(iClient);
			}
		}
		case MenuAction_Select:
		{
			g_iClientInfo[iClient] &= ~IS_WAIT_CHAT_PASS;
			switch (Item)
			{
				case 0:
				{
					decl iTarget, char sQuery[256]; char sPass[64]; char sBuffer[MAX_NAME_LENGTH];
					iTarget = g_ClientData[iClient].Get(DATA_TARGET_ID);
					GetMenuItem(hMenu, Item, sPass, sizeof(sPass));
					FormatEx(sQuery, sizeof(sQuery), "UPDATE `vip_users` SET `password` = '%s' WHERE `id` = '%i';", sPass, iTarget);
					SQL_TQuery(g_hDatabase, SQL_Callback_ErrorCheck, sQuery);
					
					g_ClientData[iClient].GetString(DATA_NAME, sBuffer, sizeof(sBuffer));
					
					VIP_PrintToChatClient(iClient, "%t", "ADMIN_SET_PASSWORD");
					if (g_CVAR_bLogsEnable)LogToFile(g_sLogFile, "%T", "LOG_ADMIN_SET_PASSWORD", iClient, iClient, sBuffer, sPass);
					ShowTargetInfoMenu(iClient, iTarget);
				}
				case 1:
				{
					ShowEditPassMenu(iClient);
				}
			}
		}
	}
}

void ShowEditGroupMenu(int iClient)
{
	SetGlobalTransTarget(iClient);
	
	decl Handle:hMenu; char sGroup[64];
	hMenu = CreateMenu(MenuHandler_EditVip_GroupsList);
	SetMenuTitle(hMenu, "%t:\n \n", "GROUP");
	SetMenuExitBackButton(hMenu, true);
	
	sGroup[0] = 0;
	
	KvRewind(g_hGroups);
	if (KvGotoFirstSubKey(g_hGroups))
	{
		char sTagetGroup[64]; char sGroupName[128];
		g_ClientData[iClient].GetString(DATA_GROUP, sTagetGroup, sizeof(sTagetGroup));
		if (strcmp(sTagetGroup, "none") == 0)
		{
			sTagetGroup[0] = '\0';
		}
		do
		{
			if (KvGetSectionName(g_hGroups, sGroup, sizeof(sGroup)))
			{
				if (sTagetGroup[0] && strcmp(sTagetGroup, sGroup, true) == 0)
				{
					FormatEx(sGroupName, sizeof(sGroupName), "%s (%t)", sGroup, "CURRENT");
					AddMenuItem(hMenu, sGroup, sGroupName, ITEMDRAW_DISABLED);
				}
				else
				{
					AddMenuItem(hMenu, sGroup, sGroup);
				}
			}
		} while KvGotoNextKey(g_hGroups);
	}
	if (sGroup[0] == 0)
	{
		FormatEx(sGroup, sizeof(sGroup), "%t", "NO_GROUPS_AVAILABLE");
		AddMenuItem(hMenu, "", sGroup, ITEMDRAW_DISABLED);
	}
	DisplayMenu(hMenu, iClient, MENU_TIME_FOREVER);
}

public int MenuHandler_EditVip_GroupsList(Menu hMenu, MenuAction action, int iClient, int Item)
{
	switch (action)
	{
		case MenuAction_End:CloseHandle(hMenu);
		case MenuAction_Cancel:
		{
			if (Item == MenuCancel_ExitBack)ShowTargetInfoMenu(iClient, g_ClientData[iClient].Get(DATA_TARGET_ID));
		}
		case MenuAction_Select:
		{
			char sQuery[256]; char sBuffer[MAX_NAME_LENGTH]; iTarget; char sGroup[MAX_NAME_LENGTH];
			GetMenuItem(hMenu, Item, sGroup, sizeof(sGroup));
			g_ClientData[iClient].GetString(DATA_NAME, sBuffer, sizeof(sBuffer));
			iTarget = g_ClientData[iClient].Get(DATA_TARGET_ID);
			
			if (GLOBAL_INFO & IS_MySQL)
			{
				FormatEx(sQuery, sizeof(sQuery), "UPDATE `vip_overrides` SET `group` = '%s' WHERE `user_id` = '%i' AND `server_id` = '%i';", sGroup, iTarget, g_CVAR_iServerID);
			}
			else
			{
				FormatEx(sQuery, sizeof(sQuery), "UPDATE `vip_users` SET `group` = '%s' WHERE `id` = '%i';", sGroup, iTarget);
			}
			
			SQL_TQuery(g_hDatabase, SQL_Callback_ErrorCheck, sQuery);
			
			ShowTargetInfoMenu(iClient, iTarget);
			
			iTarget = IsClientOnline(iTarget);
			if (iTarget)
			{
				CreateForward_OnVIPClientRemoved(iTarget, "VIP-Group Changed");
				Clients_CheckVipAccess(iTarget, false);
			}
			
			VIP_PrintToChatClient(iClient, "%t", "ADMIN_SET_GROUP", sBuffer, sGroup);
			if (g_CVAR_bLogsEnable)LogToFile(g_sLogFile, "%T", "LOG_ADMIN_SET_GROUP", iClient, iClient, sBuffer, sGroup);
		}
	}
} 