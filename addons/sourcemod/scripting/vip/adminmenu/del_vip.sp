void ShowDeleteVipPlayerMenu(int iClient)
{
	decl Handle:hMenu; char sBuffer[128];
	
	hMenu = CreateMenu(MenuHandler_DeleteVipPlayerMenu);
	
	SetGlobalTransTarget(iClient);
	
	g_ClientData[iClient].GetString(DATA_NAME, sBuffer, sizeof(sBuffer));
	SetMenuTitle(hMenu, "%t\n%s ?:\n \n", "MENU_DEL_VIP", sBuffer);
	
	FormatEx(sBuffer, sizeof(sBuffer), "%t", "CONFIRM");
	AddMenuItem(hMenu, "", sBuffer);
	FormatEx(sBuffer, sizeof(sBuffer), "%t", "CANCEL");
	AddMenuItem(hMenu, "", sBuffer);
	
	ReductionMenu(hMenu, 4);
	
	DisplayMenu(hMenu, iClient, MENU_TIME_FOREVER);
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
			DisplayMenu(g_hVIPAdminMenu, iClient, MENU_TIME_FOREVER);
		}
	}
}
