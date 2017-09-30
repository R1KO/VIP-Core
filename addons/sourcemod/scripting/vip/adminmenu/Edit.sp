void ShowEditTimeMenu(int iClient)
{
	char sBuffer[128];
	Menu hMenu = new Menu(MenuHandler_EditTimeMenu);

	hMenu.SetTitle("%T:\n ", "MENU_EDIT_TIME", iClient);
	hMenu.ExitBackButton = true;

	FormatEx(SZF(sBuffer), "%T", "MENU_TIME_SET", iClient);
	hMenu.AddItem(NULL_STRING, sBuffer);
	FormatEx(SZF(sBuffer), "%T", "MENU_TIME_ADD", iClient);
	hMenu.AddItem(NULL_STRING, sBuffer);
	FormatEx(SZF(sBuffer), "%T", "MENU_TIME_TAKE", iClient);
	hMenu.AddItem(NULL_STRING, sBuffer);
	
	ReductionMenu(hMenu, 3);

	hMenu.Display(iClient, MENU_TIME_FOREVER);
}

public int MenuHandler_EditTimeMenu(Menu hMenu, MenuAction action, int iClient, int Item)
{
	switch(action)
	{
		case MenuAction_End: delete hMenu;
		case MenuAction_Cancel:
		{
			if(Item == MenuCancel_ExitBack)
			{
				ShowTargetInfoMenu(iClient);
			}
		}
		case MenuAction_Select:
		{
			g_hClientData[iClient].SetValue(DATA_KEY_TimeType, Item);
			g_hClientData[iClient].SetValue(DATA_KEY_MenuType, MENU_TYPE_EDIT);
			ShowTimeMenu(iClient);
		}
	}
	return 0;
}
/*
void ShowEditGroupMenu(int iClient)
{
	Menu hMenu = CreateMenu(MenuHandler_EditVip_GroupsList);
	hMenu.SetTitle("%T:\n ", "GROUP", iClient);
	hMenu.ExitBackButton = true;

	g_hGroups.Rewind();
	if(g_hGroups.GotoFirstSubKey())
	{
		char sTagetGroup[64], sGroup[64];
		g_hClientData[iClient].GetString(DATA_KEY_Group, SZF(sTagetGroup));

		do
		{
			if (g_hGroups.GetSectionName(SZF(sGroup)))
			{
				if(!strcmp(sTagetGroup, sGroup, true))
				{	
					Format(SZF(sGroup), "%s [X]", sGroup);
					hMenu.AddItem(sGroup, sGroup, ITEMDRAW_DISABLED);
					continue;
				}
				
				hMenu.AddItem(sGroup, sGroup);
			}
		} while (g_hGroups.GotoNextKey());
	}

	if(!hMenu.ItemCount)
	{
		char sBuffer[128];
		FormatEx(SZF(sBuffer), "%T", "NO_GROUPS_AVAILABLE", iClient);
		hMenu.AddItem(NULL_STRING, sBuffer, ITEMDRAW_DISABLED);
	}
	hMenu.Display(iClient, MENU_TIME_FOREVER);
}

public int MenuHandler_EditVip_GroupsList(Menu hMenu, MenuAction action, int iClient, int Item)
{
	switch(action)
	{
		case MenuAction_End: delete hMenu;
		case MenuAction_Cancel:
		{
			if(Item == MenuCancel_ExitBack)
			{
				ShowTargetInfoMenu(iClient);
			}
		}
		case MenuAction_Select:
		{
			char sQuery[256], sName[MAX_NAME_LENGTH], sGroup[MAX_NAME_LENGTH];
			hMenu.GetItem(Item, SZF(sGroup));
			g_hClientData[iClient].GetString(DATA_KEY_Name, SZF(sName));

			int iTarget;
			g_hFeatures[iClient].GetValue(DATA_KEY_TargetID, iTarget);

			if (GLOBAL_INFO & IS_MySQL)
			{
				FormatEx(SZF(sQuery), "UPDATE `vip_overrides` SET `group` = '%s' WHERE `user_id` = '%i' AND `server_id` = '%i';", sGroup, iTarget, g_CVAR_iServerID);
			}
			else
			{
				FormatEx(SZF(sQuery), "UPDATE `vip_users` SET `group` = '%s' WHERE `id` = '%i';", sGroup, iTarget);
			}
			
			g_hDatabase.Query(SQL_Callback_ErrorCheck, sQuery);
			
			ShowTargetInfo(iClient);
			
			iTarget = IsClientOnline(iTarget);
			if(iTarget)
			{
				CreateForward_OnVIPClientRemoved(iTarget, "VIP-Group Changed");
				Clients_CheckVipAccess(iTarget, false);
			}

			VIP_PrintToChatClient(iClient, "%t", "ADMIN_SET_GROUP", sName, sGroup);
			if(g_CVAR_bLogsEnable) LogToFile(g_sLogFile, "%T", "LOG_ADMIN_SET_GROUP", LANG_SERVER, iClient, sName, sGroup);
		}
	}

	return 0;
}
*/