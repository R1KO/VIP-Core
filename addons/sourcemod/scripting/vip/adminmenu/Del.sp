void ShowDeleteVipPlayerMenu(int iClient)
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

public int MenuHandler_DeleteVipPlayerMenu(Menu hMenu, MenuAction action, int iClient, int iItem)
{
	switch (action)
	{
		case MenuAction_End: CloseHandle(hMenu);
		case MenuAction_Cancel:
		{
			if (iItem == MenuCancel_ExitBack) ShowTargetInfoMenu(iClient);
		}
		case MenuAction_Select:
		{
			switch(iItem)
			{
				case 0:
				{
					int iTargetID;
					g_hClientData[iClient].GetValue(DATA_KEY_TargetID, iTargetID);

					int iTarget = 0;
					if(g_hClientData[iClient].GetValue(DATA_KEY_TargetUID, iTarget))
					{
						iTarget = CID(iTarget);
						if (!iTarget && iTargetID != -1)
						{
							iTarget = IsClientOnline(iTargetID);
						}

						if (iTarget)
						{
							DB_RemoveClientFromID(iClient, iTarget, _, true);
							ResetClient(iTarget);
							CreateForward_OnVIPClientRemoved(iTarget, "Removed by Admin", iClient);
							DisplayClientInfo(iTarget, "expired_info");
							BackToAdminMenu(iClient);
							return 0;
						}
					}

					if(iTargetID != -1)
					{
						char szGroup[64], szName[MAX_NAME_LENGTH];
						g_hClientData[iClient].GetString(DATA_KEY_Name, SZF(szName));
						g_hClientData[iClient].GetString(DATA_KEY_Group, SZF(szGroup));
						DB_RemoveClientFromID(iClient, _, iTargetID, true, szName, szGroup);
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
	
	return 0;
}