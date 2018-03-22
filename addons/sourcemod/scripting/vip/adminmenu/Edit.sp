void ShowEditTimeMenu(int iClient)
{
	char szBuffer[128];
	Menu hMenu = new Menu(MenuHandler_EditTimeMenu);

	hMenu.SetTitle("%T:\n ", "MENU_EDIT_TIME", iClient);
	hMenu.ExitBackButton = true;

	FormatEx(SZF(szBuffer), "%T", "MENU_TIME_SET", iClient);
	hMenu.AddItem(NULL_STRING, szBuffer);
	FormatEx(SZF(szBuffer), "%T", "MENU_TIME_ADD", iClient);
	hMenu.AddItem(NULL_STRING, szBuffer);
	FormatEx(SZF(szBuffer), "%T", "MENU_TIME_TAKE", iClient);
	hMenu.AddItem(NULL_STRING, szBuffer);
	
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