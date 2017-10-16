void ShowDeleteVipPlayerMenu(int iClient)
{
	char sBuffer[128];

	Menu hMenu = new Menu(MenuHandler_DeleteVipPlayerMenu);

	g_hClientData[iClient].GetString(DATA_KEY_Name, sBuffer, MAX_NAME_LENGTH);
	hMenu.SetTitle("%T\n%s ?:\n \n", "MENU_DEL_VIP", iClient, sBuffer);
	
	FormatEx(SZF(sBuffer), "%T", "CONFIRM", iClient);
	hMenu.AddItem(NULL_STRING, sBuffer);
	FormatEx(SZF(sBuffer), "%T", "CANCEL", iClient);
	hMenu.AddItem(NULL_STRING, sBuffer);
	
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
					char sName[MAX_NAME_LENGTH];
					g_hClientData[iClient].GetString(DATA_KEY_Name, SZF(sName));
					int iTargetID;
					g_hClientData[iClient].GetValue(DATA_KEY_TargetID, iTargetID);
					if(iTargetID != -1)
					{
						DB_RemoveClientFromID(iClient, iTargetID, true, sName);
					}

					int iTarget = 0;
					if(g_hClientData[iClient].GetValue(DATA_KEY_TargetUID, iTarget))
					{
						iTarget = CID(iTarget);
						if (!iTarget)
						{
							iTarget = IsClientOnline(iTargetID);
						}

						if (iTarget)
						{
							ResetClient(iTarget);
							CreateForward_OnVIPClientRemoved(iTarget, "Removed by Admin", iClient);
							DisplayClientInfo(iTarget, "expired_info");
						}
					}

					BackToAdminMenu(iClient);
				}
				case 1:
				{
					ShowTargetInfoMenu(iClient);
				}
			}
		}
	}
}