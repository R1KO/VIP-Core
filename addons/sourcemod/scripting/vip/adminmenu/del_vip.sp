void ShowDeleteVipPlayerMenu(int iClient)
{
	char sBuffer[128];

	Menu hMenu = new Menu(MenuHandler_DeleteVipPlayerMenu);

	SetGlobalTransTarget(iClient);
	
	g_ClientData[iClient].GetString(DATA_NAME, sBuffer, sizeof(sBuffer));
	hMenu.SetTitle("%t\n%s ?:\n \n", "MENU_DEL_VIP", sBuffer);
	
	FormatEx(sBuffer, sizeof(sBuffer), "%t", "CONFIRM");
	hMenu.AddItem("", sBuffer);
	FormatEx(sBuffer, sizeof(sBuffer), "%t", "CANCEL");
	hMenu.AddItem("", sBuffer);
	
	ReductionMenu(hMenu, 4);
	
	hMenu.Display(iClient, MENU_TIME_FOREVER);
}

public int MenuHandler_DeleteVipPlayerMenu(Menu hMenu, MenuAction action, int iClient, int Item)
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
			if (Item == 0)
			{
				char sBuffer[MAX_NAME_LENGTH]; iTarget;
				g_ClientData[iClient].GetString(DATA_NAME, sBuffer, sizeof(sBuffer));
				iTarget = g_ClientData[iClient].Get(DATA_TARGET_ID);
				DB_RemoveClientFromID(iClient, iTarget, true);
				
				iTarget = IsClientOnline(iTarget);
				if (iTarget)
				{
					ResetClient(iTarget);
					CreateForward_OnVIPClientRemoved(iTarget, "Removed by Admin");
					DisplayClientInfo(iTarget, "expired_info");
				}
				
				ReplyToCommand(iClient, "%t", "ADMIN_VIP_IDENTITY_DELETED", sBuffer);
				if (g_CVAR_bLogsEnable)LogToFile(g_sLogFile, "%T", "LOG_ADMIN_VIP_IDENTITY_DELETED", iClient, iClient, sBuffer);
			}
			g_hVIPAdminMenu.Display(g_hVIPAdminMenu, iClient, MENU_TIME_FOREVER);
		}
	}
}
