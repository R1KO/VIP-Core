enum
{
	DATA_MENU_TYPE = 0,
	DATA_TARGET_USER_ID,
	DATA_TARGET_ID,
	DATA_TIME,
	DATA_NAME,
	DATA_GROUP,
	DATA_OFFSET,
	DATA_SIZE
}

enum
{
	TIME_SET = 0, 
	TIME_ADD, 
	TIME_TAKE
}

enum
{
	MENU_TYPE_ADD = 0, 
	MENU_TYPE_EDIT
}

void InitVIPAdminMenu()
{
	g_hVIPAdminMenu = new Menu(Handler_VIPAdminMenu, MenuAction_Display | MenuAction_Select | MenuAction_DisplayItem);

	g_hVIPAdminMenu.AddItem("", "vip_add");
	g_hVIPAdminMenu.AddItem("", "vip_list", ITEMDRAW_DISABLED);
	g_hVIPAdminMenu.AddItem("", "vip_reload_players");
	g_hVIPAdminMenu.AddItem("", "vip_reload_settings");
}

public int Handler_VIPAdminMenu(Menu hMenu, MenuAction action, int iClient, int Item)
{
	switch (action)
	{
		case MenuAction_Display:
		{
			char sTitle[128];
			FormatEx(sTitle, sizeof(sTitle), "%T: \n ", "VIP_ADMIN_MENU_TITLE", iClient);
			(view_as<Menu>(Item)).SetTitle(sTitle);
		}
		case MenuAction_DisplayItem:
		{
			char sDisplay[128];
			
			switch (Item)
			{
				case 0:FormatEx(sDisplay, sizeof(sDisplay), "%T", "MENU_ADD_VIP", iClient);
				case 1:FormatEx(sDisplay, sizeof(sDisplay), "%T", "MENU_LIST_VIP", iClient);
				case 2:FormatEx(sDisplay, sizeof(sDisplay), "%T", "ADMIN_MENU_RELOAD_VIP_PLAYES", iClient);
				case 3:FormatEx(sDisplay, sizeof(sDisplay), "%T", "ADMIN_MENU_RELOAD_VIP_CFG", iClient);
			}
			
			return RedrawMenuItem(sDisplay);
		}
		
		case MenuAction_Select:
		{
			switch (Item)
			{
				case 0:
				{
					InitiateDataArray(iClient);
					g_ClientData[iClient].Set(DATA_MENU_TYPE, MENU_TYPE_ADD);
					ShowAddVIPMenu(iClient);
				}
				case 1:
				{
					/*
					InitiateDataArray(iClient);
					ShowVipPlayersListMenu(iClient);
					*/
				}
				case 2:
				{
					ReloadVIPPlayers_CMD(iClient, 0);
					
					g_hVIPAdminMenu.Display(iClient, MENU_TIME_FOREVER);
				}
				case 3:
				{
					ReloadVIPCfg_CMD(iClient, 0);
					
					g_hVIPAdminMenu.Display(iClient, MENU_TIME_FOREVER);
				}
			}
		}
	}
	
	return 0;
}

public void OnLibraryAdded(const char[] sLibraryName)
{
	if (strcmp(sLibraryName, "adminmenu") == 0)
	{
		TopMenu hTopMenu = GetAdminTopMenu();
		if (hTopMenu != null)
		{
			OnAdminMenuReady(hTopMenu);
		}
	}
}

public void OnLibraryRemoved(const char[] sLibraryName)
{
	if (strcmp(sLibraryName, "adminmenu") == 0)
	{
		g_hTopMenu = null;
		VIPAdminMenuObject = INVALID_TOPMENUOBJECT;
	}
}

public void OnAdminMenuReady(Handle aTopMenu)
{
	TopMenu hTopMenu = TopMenu.FromHandle(aTopMenu);
	if (g_hTopMenu == hTopMenu)
	{
		return;
	}
	
	g_hTopMenu = hTopMenu;
	
	if (g_CVAR_bAddItemToAdminMenu)
	{
		AddItemsToTopMenu();
	}
}

void AddItemsToTopMenu()
{
	if (VIPAdminMenuObject == INVALID_TOPMENUOBJECT)
	{
		VIPAdminMenuObject = g_hTopMenu.AddCategory("vip_admin", Handler_MenuVIPAdmin, "vip_admin", g_CVAR_iAdminFlag);
	}

	g_hTopMenu.AddItem("vip_add",				Handler_MenuVIPAdd,				VIPAdminMenuObject, "vip_add",				g_CVAR_iAdminFlag);
	/*
	g_hTopMenu.AddItem("vip_list",				Handler_MenuVIPList,			VIPAdminMenuObject, "vip_list",				g_CVAR_iAdminFlag);
	*/
	g_hTopMenu.AddItem("vip_reload_players",	Handler_MenuVIPReloadPlayers,	VIPAdminMenuObject, "vip_reload_players",	g_CVAR_iAdminFlag);
	g_hTopMenu.AddItem("vip_reload_settings",	Handler_MenuVIPReloadSettings,	VIPAdminMenuObject, "vip_reload_settings",	g_CVAR_iAdminFlag);
}

public void Handler_MenuVIPAdmin(TopMenu hMenu, TopMenuAction action, TopMenuObject object_id, int iClient, char[] sBuffer, int maxlength)
{
	switch (action)
	{
		case TopMenuAction_DisplayOption:FormatEx(sBuffer, maxlength, "%T", "VIP_ADMIN_MENU_TITLE", iClient);
		case TopMenuAction_DisplayTitle:FormatEx(sBuffer, maxlength, "%T: \n \n", "VIP_ADMIN_MENU_TITLE", iClient);
	}
}

public void Handler_MenuVIPAdd(TopMenu hMenu, TopMenuAction action, TopMenuObject object_id, int iClient, char[] sBuffer, int maxlength)
{
	switch (action)
	{
		case TopMenuAction_DisplayOption:FormatEx(sBuffer, maxlength, "%T", "MENU_ADD_VIP", iClient);
		case TopMenuAction_SelectOption:
		{
			InitiateDataArray(iClient);
			g_ClientData[iClient].Set(DATA_MENU_TYPE, MENU_TYPE_ADD);
			ShowAddVIPMenu(iClient);
		}
	}
}
/*
public void Handler_MenuVIPList(TopMenu hMenu, TopMenuAction action, TopMenuObject object_id, int iClient, char[] sBuffer, int maxlength)
{
	switch (action)
	{
		case TopMenuAction_DisplayOption:FormatEx(sBuffer, maxlength, "%T", "MENU_LIST_VIP", iClient);
		case TopMenuAction_SelectOption:
		{
			InitiateDataArray(iClient);
			ShowVipPlayersListMenu(iClient);
		}
	}
}
*/
public void Handler_MenuVIPReloadPlayers(TopMenu hMenu, TopMenuAction action, TopMenuObject object_id, int iClient, char[] sBuffer, int maxlength)
{
	switch (action)
	{
		case TopMenuAction_DisplayOption:FormatEx(sBuffer, maxlength, "%T", "ADMIN_MENU_RELOAD_VIP_PLAYES", iClient);
		case TopMenuAction_SelectOption:
		{
			ReloadVIPPlayers_CMD(iClient, 0);
			RedisplayAdminMenu(g_hTopMenu, iClient);
		}
	}
}

public void Handler_MenuVIPReloadSettings(TopMenu hMenu, TopMenuAction action, TopMenuObject object_id, int iClient, char[] sBuffer, int maxlength)
{
	switch (action)
	{
		case TopMenuAction_DisplayOption:FormatEx(sBuffer, maxlength, "%T", "ADMIN_MENU_RELOAD_VIP_CFG", iClient);
		case TopMenuAction_SelectOption:
		{
			ReloadVIPCfg_CMD(iClient, 0);
			
			RedisplayAdminMenu(g_hTopMenu, iClient);
		}
	}
}

void InitiateDataArray(int iClient)
{
	if (g_ClientData[iClient] == null)
	{
		g_ClientData[iClient] = new ArrayList(ByteCountToCells(64), DATA_SIZE);
	}
	else
	{
		(g_ClientData[iClient]).Clear();
		g_ClientData[iClient].Resize(DATA_SIZE);
	}
}

int IsClientOnline(int ID)
{
	int iClientID;
	for (int i = 1; i <= MaxClients; ++i)
	{
		if (IsClientInGame(i) && g_hFeatures[i] != null && GetTrieValue(g_hFeatures[i], KEY_CID, iClientID) && iClientID == ID) return i;
	}
	return 0;
}

void ShowTimeMenu(int iClient)
{
	SetGlobalTransTarget(iClient);

	KeyValues hKv; int iMenuType;
	Menu hMenu = new Menu(MenuHandler_TimeMenu);
	
	hMenu.SetTitle("%t:\n \n", "MENU_TIME_SET");
	/*
	iMenuType = g_ClientData[iClient].Get(DATA_TIME);
	switch (iMenuType)
	{
		case TIME_SET: 	hMenu.SetTitle("%t:\n \n", "MENU_TIME_SET");
		case TIME_ADD:	hMenu.SetTitle("%t:\n \n", "MENU_TIME_ADD");
		case TIME_TAKE:	hMenu.SetTitle("%t:\n \n", "MENU_TIME_TAKE");
	}
	*/

	hMenu.ExitBackButton = true;

	hKv = CreateConfig("data/vip/cfg/times.ini", "TIMES");
	
	if (hKv.GotoFirstSubKey())
	{
		char sBuffer[128]; char sTime[32]; char sClientLang[3]; char sServerLang[3];
		GetLanguageInfo(GetServerLanguage(), sServerLang, sizeof(sServerLang));
		GetLanguageInfo(GetClientLanguage(iClient), sClientLang, sizeof(sClientLang));
		
		do
		{
			hKv.GetSectionName(sTime, sizeof(sTime));

			if (iMenuType != TIME_SET && sTime[0] == '0') continue;

			hKv.GetString(sClientLang, sBuffer, sizeof(sBuffer), "LangError");
			if (!sBuffer[0])
			{
				hKv.GetString(sServerLang, sBuffer, sizeof(sBuffer), "LangError");
			}

			hMenu.AddItem(sTime, sBuffer);

		}
		while (hKv.GotoNextKey(false));
	}
	
	CloseHandle(hKv);

	hMenu.Display(iClient, MENU_TIME_FOREVER);
}

public int MenuHandler_TimeMenu(Menu hMenu, MenuAction action, int iClient, int Item)
{
	switch (action)
	{
		case MenuAction_End: CloseHandle(hMenu);
		case MenuAction_Cancel:
		{
			if (Item == MenuCancel_ExitBack)
			{
				ShowAddVIPMenu(iClient);
			}
		}
		case MenuAction_Select:
		{
			int iTarget = GetClientOfUserId(g_ClientData[iClient].Get(DATA_TARGET_USER_ID));
			if (iTarget)
			{
				char sBuffer[64]; //int iType, iTime;
				hMenu.GetItem(Item, sBuffer, sizeof(sBuffer));
				g_ClientData[iClient].Set(DATA_TIME, StringToInt(sBuffer));
				ShowGroupMenu(iClient);
			}
			else
			{
				VIP_PrintToChatClient(iClient, "%t", "PLAYER_NO_LONGER_AVAILABLE");
				g_hVIPAdminMenu.Display(iClient, MENU_TIME_FOREVER);
			}
		}
	
	}
	
	return 0;
}
/*
public int MenuHandler_TimeMenu(Menu hMenu, MenuAction action, int iClient, int Item)
{
	switch (action)
	{
		case MenuAction_End:CloseHandle(hMenu);
		case MenuAction_Cancel:
		{
			if (Item == MenuCancel_ExitBack)
			{
				if (g_ClientData[iClient].Get(DATA_MENU_TYPE) == MENU_TYPE_ADD)
				{
					ShowAddVIPMenu(iClient);
				}
				else
				{
					ShowEditTimeMenu(iClient);
				}
			}
		}
		case MenuAction_Select:
		{
			char sBuffer[64]; int iType, iTime;
			hMenu.GetItem(Item, sBuffer, sizeof(sBuffer));
			iTime = StringToInt(sBuffer);
			iType = g_ClientData[iClient].Get(DATA_TIME);
			
			if (g_ClientData[iClient].Get(DATA_MENU_TYPE) == MENU_TYPE_ADD)
			{
				int iTarget = GetClientOfUserId(g_ClientData[iClient].Get(DATA_TARGET_USER_ID));
				if (iTarget)
				{
					g_ClientData[iClient].Set(DATA_TIME, iTime);
					ShowGroupMenu(iClient);
				}
				else
				{
					VIP_PrintToChatClient(iClient, "%t", "PLAYER_NO_LONGER_AVAILABLE");
					g_hVIPAdminMenu.Display(iClient, MENU_TIME_FOREVER);
				}
				
			}
			else
			{
				char sTime[64]; iExpires;
				g_ClientData[iClient].GetString(DATA_NAME, sBuffer, sizeof(sBuffer));
				
				switch (iType)
				{
					case TIME_SET:
					{
						if (iTime == 0)
						{
							iExpires = 0;
						}
						else
						{
							iExpires = GetTime() + iTime;
						}
						
						
						FormatTime(sTime, sizeof(sTime), "%d/%m/%Y - %H:%M", iExpires);
						VIP_PrintToChatClient(iClient, "%t", "ADMIN_SET_EXPIRATION", sBuffer, sTime);
						
						if (g_CVAR_bLogsEnable)LogToFile(g_sLogFile, "%T", "LOG_ADMIN_SET_EXPIRATION", iClient, iClient, sBuffer, sTime);
					}
					case TIME_ADD:
					{
						iExpires = g_ClientData[iClient].Get(DATA_AUTH_TYPE);
						if (iExpires > 0)
						{
							iExpires += iTime;
							
							UTIL_GetTimeFromStamp(sTime, sizeof(sTime), iTime, iClient);
							VIP_PrintToChatClient(iClient, "%t", "ADMIN_EXTENDED", sBuffer, sTime);
							
							if (g_CVAR_bLogsEnable)LogToFile(g_sLogFile, "%T", "LOG_ADMIN_EXTENDED", iClient, iClient, sBuffer, sTime);
						}
						else
						{
							VIP_PrintToChatClient(iClient, "%t", "UNABLE_TO_EXTENDED");
							g_ClientData[iClient].Set(DATA_TIME, TIME_ADD);
							ShowTimeMenu(iClient);
							return 0;
						}
					}
					case TIME_TAKE:
					{
						iExpires = g_ClientData[iClient].Get(DATA_AUTH_TYPE);
						if (iExpires > 0)
						{
							iExpires -= iTime;
							
							if (iExpires > GetTime())
							{
								UTIL_GetTimeFromStamp(sTime, sizeof(sTime), iTime, iClient);
								
								VIP_PrintToChatClient(iClient, "%t", "ADMIN_REDUCED", sBuffer, sTime);
								
								if (g_CVAR_bLogsEnable)LogToFile(g_sLogFile, "%T", "LOG_ADMIN_REDUCED", iClient, iClient, sBuffer, sTime);
							}
							else
							{
								VIP_PrintToChatClient(iClient, "%t", "INCORRECT_TIME");
								g_ClientData[iClient].Set(DATA_TIME, TIME_TAKE);
								ShowTimeMenu(iClient);
								return 0;
							}
						}
						else
						{
							VIP_PrintToChatClient(iClient, "%t", "UNABLE_TO_REDUCE");
							ShowTimeMenu(iClient);
							return 0;
						}
					}
				}
				
				int iClientID; char sQuery[512];
				iClientID = g_ClientData[iClient].Get(DATA_TARGET_ID);
				if (GLOBAL_INFO & IS_MySQL)
				{
					FormatEx(sQuery, sizeof(sQuery), "UPDATE `vip_overrides` SET `expires` = '%i' WHERE `user_id` = '%i' AND `server_id` = '%i';", iExpires, iClientID, g_CVAR_iServerID);
				}
				else
				{
					FormatEx(sQuery, sizeof(sQuery), "UPDATE `vip_users` SET `expires` = '%i' WHERE `id` = '%i';", iExpires, iClientID);
				}

				g_hDatabase.Query(SQL_Callback_ChangeTime, sQuery, UID(iClient));

				ShowTargetInfoMenu(iClient, iClientID);
			}
		}
		
	}
	
	return 0;
}
*/
public void SQL_Callback_ChangeTime(Database hOwner, DBResultSet hResult, const char[] sError, any UserID)
{
	if (sError[0])
	{
		LogError("SQL_Callback_ChangeTime: %s", sError);
		return;
	}
	
	if (hResult.AffectedRows)
	{
		int iClient = CID(UserID);
		if (iClient)
		{
			int iTarget = IsClientOnline(g_ClientData[iClient].Get(DATA_TARGET_ID));
			if (iTarget)
			{
				Clients_CheckVipAccess(iTarget, true);
			}
		}
	}
}

stock void ReductionMenu(Handle &hMenu, int iNum)
{
	for (int i = 0; i < iNum; ++i)
	{
		hMenu.AddItem("", "", ITEMDRAW_NOTEXT);
	}
}

#include "vip/adminmenu/add_vip.sp"
/*
#include "vip/adminmenu/edit_vip.sp"
#include "vip/adminmenu/del_vip.sp"
#include "vip/adminmenu/list_vip.sp"
*/

/*
void AddMenuTranslatedItem(Menu hMenu, int iClient, const char[] sItem)
{
	char sBuffer[128];
	FormatEx(sBuffer, sizeof(sBuffer), "%T", sItem, iClient);
	hMenu.AddItem(sItem, sBuffer);
}
*/