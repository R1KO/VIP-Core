void ShowConfirmDeleteVipPlayerMenu(int iClient)
{
	char szBuffer[128];

	Menu hMenu = new Menu(MenuHandler_DeleteVipPlayerMenu);

	g_hClientData[iClient].GetString(DATA_KEY_Name, szBuffer, MAX_NAME_LENGTH);
	hMenu.SetTitle("%T\n%s ?:\n \n", "MENU_DEL_VIP", iClient, szBuffer);
	
	FormatEx(SZF(szBuffer), "%T", "CONFIRM", iClient);
	hMenu.AddItem(NULL_STRING, szBuffer);
	FormatEx(SZF(szBuffer), "%T", "CANCEL", iClient);
	hMenu.AddItem(NULL_STRING, szBuffer);
	
	ReductionMenu(hMenu, 4);
	
	hMenu.Display(iClient, MENU_TIME_FOREVER);
}

public int MenuHandler_DeleteVipPlayerMenu(Menu hMenu, MenuAction action, int iClient, int Item)
{
	switch (action)
	{
		case MenuAction_End: CloseHandle(hMenu);
		case MenuAction_Cancel:
		{
			if (Item == MenuCancel_ExitBack) ShowTargetInfoMenu(iClient);
		}
		case MenuAction_Select:
		{
			switch(Item)
			{
				case 0:
				{
					int iTargetID;
					g_hClientData[iClient].GetValue(DATA_KEY_TargetID, iTargetID);

					int iTarget = 0;
					if (g_hClientData[iClient].GetValue(DATA_KEY_TargetUID, iTarget))
					{
						iTarget = CID(iTarget);
					}
					if (iTarget)
					{
						CallForward_OnVIPClientRemoved(iTarget, "Removed by Admin", iClient);
					}
					Clients_RemoveVipPlayer(iClient, iTarget, iTargetID, true);

					BackToAdminMenu(iClient);
				}
				case 1:
				{
					ShowTargetInfoMenu(iClient);
				}
			}
		}
	}
	
	return 0;
}