char	DATA_KEY_MenuType[]		= "MenuType";
char	DATA_KEY_MenuListType[]		= "MenuListType";
char	DATA_KEY_ThrowMenuType[]	= "ThrowMenuType";
char	DATA_KEY_TargetID[]		= "TargetID";
char	DATA_KEY_TargetUID[]	= "TargetUID";
char	DATA_KEY_TimeType[]		= "TimeType";
char	DATA_KEY_Time[]			= "Time";
char	DATA_KEY_Name[]			= "Name";
char	DATA_KEY_Group[]		= "Group";
char	DATA_KEY_Auth[]			= "Auth";
char	DATA_KEY_Offset[]		= "Offset";
char	DATA_KEY_Search[]		= "Search";

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
	TOP_ADMIN_MENU = 0, 
	ADMIN_MENU
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
	MENU_TYPE_EDIT,
	MENU_TYPE_ONLINE_LIST,
	MENU_TYPE_DB_LIST
}

void BackToAdminMenu(int iClient)
{
	int iThrowMenuType;
	g_hClientData[iClient].GetValue(DATA_KEY_ThrowMenuType, iThrowMenuType);
	switch (iThrowMenuType)
	{
		case TOP_ADMIN_MENU:	g_hTopMenu.Display(iClient, TopMenuPosition_LastCategory);
		case ADMIN_MENU:		g_hVIPAdminMenu.Display(iClient, MENU_TIME_FOREVER);
	}
}

void InitiateDataMap(int iClient)
{
	if (g_hClientData[iClient] == null)
	{
		g_hClientData[iClient] = new StringMap();
	}
	else
	{
		g_hClientData[iClient].Clear();
	}
}

int IsClientOnline(int ID)
{
	int iClientID;
	for (int i = 1; i <= MaxClients; ++i)
	{
		if (IsClientInGame(i) && g_hFeatures[i] != null && g_hFeatures[i].GetValue(KEY_CID, iClientID) && iClientID == ID) return i;
	}
	return 0;
}

// ************************ ADMIN_MENU ************************
void VIPAdminMenu_Setup()
{
	g_hVIPAdminMenu = new Menu(Handler_VIPAdminMenu, MenuAction_Display | MenuAction_Select | MenuAction_DisplayItem);

	g_hVIPAdminMenu.AddItem(NULL_STRING, "vip_add");
	g_hVIPAdminMenu.AddItem(NULL_STRING, "vip_list");
	g_hVIPAdminMenu.AddItem(NULL_STRING, "vip_reload_players");
	g_hVIPAdminMenu.AddItem(NULL_STRING, "vip_reload_settings");
}

public int Handler_VIPAdminMenu(Menu hMenu, MenuAction action, int iClient, int Item)
{
	switch (action)
	{
		case MenuAction_Display:
		{
			char sTitle[128];
			FormatEx(SZF(sTitle), "%T: \n ", "VIP_ADMIN_MENU_TITLE", iClient);
			(view_as<Panel>(Item)).SetTitle(sTitle);
		}
		case MenuAction_DisplayItem:
		{
			char sDisplay[128];
			
			switch (Item)
			{
				case 0:	FormatEx(SZF(sDisplay), "%T", "MENU_ADD_VIP", iClient);
				case 1:	FormatEx(SZF(sDisplay), "%T", "MENU_LIST_VIP", iClient);
				case 2:	FormatEx(SZF(sDisplay), "%T", "ADMIN_MENU_RELOAD_VIP_PLAYES", iClient);
				case 3:	FormatEx(SZF(sDisplay), "%T", "ADMIN_MENU_RELOAD_VIP_CFG", iClient);
			}
			
			return RedrawMenuItem(sDisplay);
		}
		
		case MenuAction_Select:
		{
			switch (Item)
			{
				case 0:
				{
					InitiateDataMap(iClient);
					g_hClientData[iClient].SetValue(DATA_KEY_MenuType, MENU_TYPE_ADD);
					g_hClientData[iClient].SetValue(DATA_KEY_ThrowMenuType, ADMIN_MENU);
					ShowAddVIPMenu(iClient);
				}
				case 1:
				{
					InitiateDataMap(iClient);
					g_hClientData[iClient].SetValue(DATA_KEY_ThrowMenuType, ADMIN_MENU);
					ShowVipPlayersListMenu(iClient);
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

// ************************ TOP_ADMIN_MENU ************************
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
	
	/*if (g_CVAR_bAddItemToAdminMenu)
	{
		AddItemsToTopMenu();
	}
	*/
	AddItemsToTopMenu();
}
// g_CVAR_iAdminFlag
void AddItemsToTopMenu()
{
	if (VIPAdminMenuObject == INVALID_TOPMENUOBJECT)
	{
		VIPAdminMenuObject = g_hTopMenu.AddCategory("vip_admin", Handler_MenuVIPAdmin, "vip_admin", ADMFLAG_ROOT);
	}

	g_hTopMenu.AddItem("vip_add",				Handler_MenuVIPAdd,				VIPAdminMenuObject, "vip_add",				ADMFLAG_ROOT);
	g_hTopMenu.AddItem("vip_list",				Handler_MenuVIPList,			VIPAdminMenuObject, "vip_list",				ADMFLAG_ROOT);
	g_hTopMenu.AddItem("vip_reload_players",	Handler_MenuVIPReloadPlayers,	VIPAdminMenuObject, "vip_reload_players",	ADMFLAG_ROOT);
	g_hTopMenu.AddItem("vip_reload_settings",	Handler_MenuVIPReloadSettings,	VIPAdminMenuObject, "vip_reload_settings",	ADMFLAG_ROOT);
}

public void Handler_MenuVIPAdmin(TopMenu hMenu, TopMenuAction action, TopMenuObject object_id, int iClient, char[] sBuffer, int maxlength)
{
	switch (action)
	{
		case TopMenuAction_DisplayOption:	FormatEx(sBuffer, maxlength, "%T", "VIP_ADMIN_MENU_TITLE", iClient);
		case TopMenuAction_DisplayTitle:	FormatEx(sBuffer, maxlength, "%T: \n ", "VIP_ADMIN_MENU_TITLE", iClient);
	}
}

// ************************ ADD_VIP ************************
public void Handler_MenuVIPAdd(TopMenu hMenu, TopMenuAction action, TopMenuObject object_id, int iClient, char[] sBuffer, int maxlength)
{
	switch (action)
	{
		case TopMenuAction_DisplayOption:	FormatEx(sBuffer, maxlength, "%T", "MENU_ADD_VIP", iClient);
		case TopMenuAction_SelectOption:
		{
			InitiateDataMap(iClient);
			g_hClientData[iClient].SetValue(DATA_KEY_MenuType, MENU_TYPE_ADD);
			g_hClientData[iClient].SetValue(DATA_KEY_ThrowMenuType, TOP_ADMIN_MENU);
			ShowAddVIPMenu(iClient);
		}
	}
}

// ************************ LIST_VIP ************************

public void Handler_MenuVIPList(TopMenu hMenu, TopMenuAction action, TopMenuObject object_id, int iClient, char[] sBuffer, int maxlength)
{
	switch (action)
	{
		case TopMenuAction_DisplayOption:	FormatEx(sBuffer, maxlength, "%T", "MENU_LIST_VIP", iClient);
		case TopMenuAction_SelectOption:
		{
			InitiateDataMap(iClient);
			g_hClientData[iClient].SetValue(DATA_KEY_ThrowMenuType, TOP_ADMIN_MENU);
			ShowVipPlayersListMenu(iClient);
		}
	}
}

// ************************ RELOAD_VIP_PLAYES ************************
public void Handler_MenuVIPReloadPlayers(TopMenu hMenu, TopMenuAction action, TopMenuObject object_id, int iClient, char[] sBuffer, int maxlength)
{
	switch (action)
	{
		case TopMenuAction_DisplayOption:	FormatEx(sBuffer, maxlength, "%T", "ADMIN_MENU_RELOAD_VIP_PLAYES", iClient);
		case TopMenuAction_SelectOption:
		{
			ReloadVIPPlayers_CMD(iClient, 0);
			RedisplayAdminMenu(g_hTopMenu, iClient);
		}
	}
}

// ************************ RELOAD_VIP_CFG ************************
public void Handler_MenuVIPReloadSettings(TopMenu hMenu, TopMenuAction action, TopMenuObject object_id, int iClient, char[] sBuffer, int maxlength)
{
	switch (action)
	{
		case TopMenuAction_DisplayOption:	FormatEx(sBuffer, maxlength, "%T", "ADMIN_MENU_RELOAD_VIP_CFG", iClient);
		case TopMenuAction_SelectOption:
		{
			ReloadVIPCfg_CMD(iClient, 0);
			
			RedisplayAdminMenu(g_hTopMenu, iClient);
		}
	}
}

void ShowTimeMenu(int iClient)
{
	Menu hMenu = new Menu(MenuHandler_TimeMenu);

	int iMenuType;
	g_hClientData[iClient].GetValue(DATA_KEY_TimeType, iMenuType);

	switch (iMenuType)
	{
		case TIME_SET: 	hMenu.SetTitle("%T:\n ", "MENU_TIME_SET", iClient);
		case TIME_ADD:	hMenu.SetTitle("%T:\n ", "MENU_TIME_ADD", iClient);
		case TIME_TAKE:	hMenu.SetTitle("%T:\n ", "MENU_TIME_TAKE", iClient);
	}

	hMenu.ExitBackButton = true;

	KeyValues hKv = CreateConfig("data/vip/cfg/times.ini", "TIMES");
	
	if (hKv.GotoFirstSubKey())
	{
		char sBuffer[128], sTime[32], sClientLang[4], sServerLang[4];
		GetLanguageInfo(GetServerLanguage(), SZF(sServerLang));
		GetLanguageInfo(GetClientLanguage(iClient), SZF(sClientLang));
		
		do
		{
			hKv.GetSectionName(SZF(sTime));

			if (iMenuType != TIME_SET && sTime[0] == '0') continue;

			hKv.GetString(sClientLang, SZF(sBuffer), "LangError");
			if (!sBuffer[0])
			{
				hKv.GetString(sServerLang, SZF(sBuffer), "LangError");
			}

			hMenu.AddItem(sTime, sBuffer);

		}
		while (hKv.GotoNextKey(false));
	}
	
	delete hKv;

	hMenu.Display(iClient, MENU_TIME_FOREVER);
}

public int MenuHandler_TimeMenu(Menu hMenu, MenuAction action, int iClient, int Item)
{
	switch (action)
	{
		case MenuAction_End: delete hMenu;
		case MenuAction_Cancel:
		{
			if (Item == MenuCancel_ExitBack)
			{
				int iMenuType;
				g_hClientData[iClient].GetValue(DATA_KEY_MenuType, iMenuType);

				switch (iMenuType)
				{
					case MENU_TYPE_ADD: 	ShowAddVIPMenu(iClient);
					case MENU_TYPE_EDIT:	ShowEditTimeMenu(iClient);
				}
			}
		}
		case MenuAction_Select:
		{
			char sName[64];
			hMenu.GetItem(Item, SZF(sName));
			int iMenuType, iTime, iTarget;
			iTime = S2I(sName);
			g_hClientData[iClient].GetValue(DATA_KEY_MenuType, iMenuType);
			
			if (iMenuType == MENU_TYPE_ADD)
			{
				g_hClientData[iClient].GetValue(DATA_KEY_TargetUID, iTarget);
				if ((iTarget = GetClientOfUserId(iTarget)))
				{
					char sBuffer[64];
					hMenu.GetItem(Item, SZF(sBuffer));
					g_hClientData[iClient].SetValue(DATA_KEY_Time, S2I(sBuffer));
					ShowGroupsMenu(iClient);
				}
				else
				{
					VIP_PrintToChatClient(iClient, "%t", "PLAYER_NO_LONGER_AVAILABLE");
					BackToAdminMenu(iClient);
				}
				return 0;
			}

			char sTime[64];
			int iExpires;
			g_hClientData[iClient].GetString(DATA_KEY_Name, SZF(sName));

			g_hClientData[iClient].GetValue(DATA_KEY_TimeType, iMenuType);
			switch(iMenuType)
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

					FormatTime(SZF(sTime), "%d/%m/%Y - %H:%M", iExpires);
					VIP_PrintToChatClient(iClient, "%t", "ADMIN_SET_EXPIRATION", sName, sTime);
					
					if (g_CVAR_bLogsEnable)
					{
						LogToFile(g_sLogFile, "%T", "LOG_ADMIN_SET_EXPIRATION", LANG_SERVER, iClient, sName, sTime);
					}
				}
				case TIME_ADD:
				{
					g_hClientData[iClient].GetValue(DATA_KEY_Time, iExpires);
					if (iExpires <= 0)
					{
						VIP_PrintToChatClient(iClient, "%t", "UNABLE_TO_EXTENDED");
						ShowTimeMenu(iClient);
						return 0;
					}

					iExpires += iTime;

					UTIL_GetTimeFromStamp(SZF(sTime), iTime, iClient);
					VIP_PrintToChatClient(iClient, "%t", "ADMIN_EXTENDED", sName, sTime);

					if (g_CVAR_bLogsEnable)
					{
						LogToFile(g_sLogFile, "%T", "LOG_ADMIN_EXTENDED", LANG_SERVER, iClient, sName, sTime);
					}
				}
				case TIME_TAKE:
				{
					g_hClientData[iClient].GetValue(DATA_KEY_Time, iExpires);
					if (iExpires <= 0)
					{
						VIP_PrintToChatClient(iClient, "%t", "UNABLE_TO_REDUCE");
						ShowTimeMenu(iClient);
						return 0;
					}

					iExpires -= iTime;
					
					if (iExpires <= GetTime())
					{
						VIP_PrintToChatClient(iClient, "%t", "INCORRECT_TIME");
						ShowTimeMenu(iClient);
						return 0;
					}
					
					UTIL_GetTimeFromStamp(SZF(sTime), iTime, iClient);

					VIP_PrintToChatClient(iClient, "%t", "ADMIN_REDUCED", sName, sTime);
					
					if (g_CVAR_bLogsEnable)
					{
						LogToFile(g_sLogFile, "%T", "LOG_ADMIN_REDUCED", LANG_SERVER, iClient, sName, sTime);
					}
				}
			}

			g_hClientData[iClient].GetValue(DATA_KEY_TargetID, iTarget);
			g_hClientData[iClient].SetValue(DATA_KEY_Time, iExpires);

			char sQuery[512];
			if (GLOBAL_INFO & IS_MySQL)
			{
				FormatEx(sQuery, sizeof(sQuery), "UPDATE `vip_overrides` SET `expires` = '%d' WHERE `user_id` = '%d' AND `server_id` = '%d';", iExpires, iTarget, g_CVAR_iServerID);
			}
			else
			{
				FormatEx(sQuery, sizeof(sQuery), "UPDATE `vip_users` SET `expires` = '%d' WHERE `id` = '%d';", iExpires, iTarget);
			}

			g_hDatabase.Query(SQL_Callback_ChangeTime, sQuery, UID(iClient));

			ShowTargetInfoMenu(iClient);
		}
	}

	return 0;
}

void ShowGroupsMenu(int iClient, const char[] sTargetGroup = NULL_STRING)
{
	char sGroup[MAX_NAME_LENGTH];
	Menu hMenu = new Menu(MenuHandler_GroupsList);
	hMenu.SetTitle("%T:\n ", "GROUP", iClient);
	hMenu.ExitBackButton = true;
	sGroup[0] = 0;
	g_hGroups.Rewind();
	if (g_hGroups.GotoFirstSubKey())
	{
		do
		{
			if (g_hGroups.GetSectionName(SZF(sGroup)))
			{
				if(sTargetGroup[0] && !strcmp(sTargetGroup, sGroup))
				{
					Format(SZF(sGroup), "%s [X]", sGroup);
					hMenu.AddItem(sGroup, sGroup, ITEMDRAW_DISABLED);
					continue;
				}

				hMenu.AddItem(sGroup, sGroup);
			}
		} while g_hGroups.GotoNextKey();
	}
	if (!sGroup[0])
	{
		FormatEx(SZF(sGroup), "%T", "NO_GROUPS_AVAILABLE", iClient);
		hMenu.AddItem(NULL_STRING, sGroup, ITEMDRAW_DISABLED);
	}

	hMenu.Display(iClient, MENU_TIME_FOREVER);
}

public int MenuHandler_GroupsList(Menu hMenu, MenuAction action, int iClient, int Item)
{
	switch (action)
	{
		case MenuAction_End:delete hMenu;
		case MenuAction_Cancel:
		{
			if (Item == MenuCancel_ExitBack)
			{
				int iBuffer;
				g_hClientData[iClient].GetValue(DATA_KEY_MenuType, iBuffer);
				switch(iBuffer)
				{
					case MENU_TYPE_ADD:
					{
						ShowTimeMenu(iClient);
					}
					case MENU_TYPE_EDIT:
					{
						ShowTargetInfoMenu(iClient);
					}
				}
			}
		}
		case MenuAction_Select:
		{
			char sGroup[64];
			hMenu.GetItem(Item, SZF(sGroup));
			int iBuffer;
			g_hClientData[iClient].GetValue(DATA_KEY_MenuType, iBuffer);
			switch(iBuffer)
			{
				case MENU_TYPE_ADD:
				{
					int iTarget;
					g_hClientData[iClient].GetValue(DATA_KEY_TargetUID, iTarget);
					iTarget = CID(iTarget);
					if (iTarget)
					{
						g_hClientData[iClient].GetValue(DATA_KEY_Time, iBuffer);
						g_hClientData[iClient].Clear();
						UTIL_ADD_VIP_PLAYER(iClient, iTarget, _, iBuffer, sGroup);
					}
					else
					{
						VIP_PrintToChatClient(iClient, "%t", "Player no longer available");
					}

					BackToAdminMenu(iClient);
				}
				case MENU_TYPE_EDIT:
				{
					char sQuery[256], sName[MAX_NAME_LENGTH];
					hMenu.GetItem(Item, SZF(sGroup));
					int iTargetID;
					g_hClientData[iClient].GetValue(DATA_KEY_TargetID, iTargetID);
					g_hClientData[iClient].GetString(DATA_KEY_Name, SZF(sName));

					if (GLOBAL_INFO & IS_MySQL)
					{
						FormatEx(SZF(sQuery), "UPDATE `vip_overrides` SET `group` = '%s' WHERE `user_id` = %d AND `server_id` = %d;", sGroup, iTargetID, g_CVAR_iServerID);
					}
					else
					{
						FormatEx(SZF(sQuery), "UPDATE `vip_users` SET `group` = '%s' WHERE `id` = %d;", sGroup, iTargetID);
					}

					g_hDatabase.Query(SQL_Callback_ErrorCheck, sQuery);

					int iTarget = 0;
					g_hClientData[iClient].GetValue(DATA_KEY_TargetUID, iTarget);
					iTarget = CID(iTarget);
					if (!iTarget)
					{
						iTarget = IsClientOnline(iTargetID);
					}

					if (iTarget)
					{
						ResetClient(iTarget);
						CreateForward_OnVIPClientRemoved(iTarget, "VIP-Group Changed", iClient);
						Clients_CheckVipAccess(iTarget, false);
					}

					ShowTargetInfo(iClient);
	
					VIP_PrintToChatClient(iClient, "%t", "ADMIN_SET_GROUP", sName, sGroup);
					if (g_CVAR_bLogsEnable) LogToFile(g_sLogFile, "%T", "LOG_ADMIN_SET_GROUP", iClient, iClient, sName, sGroup);
				}
			}
		}
	}
}

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
			int iTarget;
			g_hClientData[iClient].GetValue(DATA_KEY_TargetUID, iTarget);
			iTarget = CID(iTarget);
			if(!iTarget)
			{
				g_hClientData[iClient].GetValue(DATA_KEY_TargetID, iTarget);
				iTarget = IsClientOnline(iTarget);
			}

			if (iTarget)
			{
				Clients_CheckVipAccess(iTarget, true);
			}
		}
	}
}

void ReductionMenu(Menu &hMenu, int iNum)
{
	for (int i = 0; i < iNum; ++i)
	{
		hMenu.AddItem(NULL_STRING, NULL_STRING, ITEMDRAW_NOTEXT);
	}
}

#include "vip/AdminMenu/Add.sp"
#include "vip/AdminMenu/List.sp"
#include "vip/AdminMenu/Edit.sp"
#include "vip/AdminMenu/Del.sp"
