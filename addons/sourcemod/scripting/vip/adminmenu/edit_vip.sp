void ShowEditTimeMenu(int iClient)
{
	char sBuffer[128];
	Menu hMenu = new Menu(MenuHandler_EditTimeMenu);

	SetGlobalTransTarget(iClient);
	hMenu.SetTitle("%t:\n \n", "MENU_EDIT_TIME");
	hMenu.ExitBackButton = true;
	
	FormatEx(sBuffer, sizeof(sBuffer), "%t", "MENU_TIME_SET");
	hMenu.AddItem("", sBuffer);
	FormatEx(sBuffer, sizeof(sBuffer), "%t", "MENU_TIME_ADD");
	hMenu.AddItem("", sBuffer);
	FormatEx(sBuffer, sizeof(sBuffer), "%t", "MENU_TIME_TAKE");
	hMenu.AddItem("", sBuffer);
	
	ReductionMenu(hMenu, 3);
	
	hMenu.Display(iClient, MENU_TIME_FOREVER);
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

void ShowEditGroupMenu(int iClient)
{
	SetGlobalTransTarget(iClient);
	
	char sGroup[64];
	Menu hMenu = new Menu(MenuHandler_EditVip_GroupsList);
	hMenu.SetTitle("%t:\n \n", "GROUP");
	hMenu.ExitBackButton = true;
	
	sGroup[0] = 0;
	
	(g_hGroups).Rewind();
	if (g_hGroups.GotoFirstSubKey())
	{
		char sTagetGroup[64]; char sGroupName[128];
		g_ClientData[iClient].GetString(DATA_GROUP, sTagetGroup, sizeof(sTagetGroup));
		if (strcmp(sTagetGroup, "none") == 0)
		{
			sTagetGroup[0] = '\0';
		}
		do
		{
			if (g_hGroups.GetSectionName(sGroup, sizeof(sGroup)))
			{
				if (sTagetGroup[0] && strcmp(sTagetGroup, sGroup, true) == 0)
				{
					FormatEx(sGroupName, sizeof(sGroupName), "%s (%t)", sGroup, "CURRENT");
					hMenu.AddItem(sGroup, sGroupName, ITEMDRAW_DISABLED);
				}
				else
				{
					hMenu.AddItem(sGroup, sGroup);
				}
			}
		} while KvGotoNextKey(g_hGroups);
	}
	if (sGroup[0] == 0)
	{
		FormatEx(sGroup, sizeof(sGroup), "%t", "NO_GROUPS_AVAILABLE");
		hMenu.AddItem("", sGroup, ITEMDRAW_DISABLED);
	}
	hMenu.Display(iClient, MENU_TIME_FOREVER);
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
			char sQuery[256], sBuffer[MAX_NAME_LENGTH], sGroup[MAX_NAME_LENGTH]; int iTarget;
			hMenu.GetItem(Item, sGroup, sizeof(sGroup));
			g_ClientData[iClient].GetString(DATA_NAME, sBuffer, sizeof(sBuffer));
			iTarget = GetArrayCell(g_ClientData[iClient], DATA_TARGET_ID);

			if (GLOBAL_INFO & IS_MySQL)
			{
				FormatEx(sQuery, sizeof(sQuery), "UPDATE `vip_overrides` SET `group` = '%s' WHERE `user_id` = '%i' AND `server_id` = '%i';", sGroup, iTarget, g_CVAR_iServerID);
			}
			else
			{
				FormatEx(sQuery, sizeof(sQuery), "UPDATE `vip_users` SET `group` = '%s' WHERE `id` = '%i';", sGroup, iTarget);
			}
			
			g_hDatabase.Query(SQL_Callback_ErrorCheck, sQuery);
			
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