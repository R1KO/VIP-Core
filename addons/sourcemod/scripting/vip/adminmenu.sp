
enum
{
	DATA_MENU_TYPE = 0,
	DATA_TARGET_USER_ID,
	DATA_TARGET_ID,
	DATA_AUTH_TYPE,
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
	g_hVIPAdminMenu = CreateMenu(Handler_VIPAdminMenu, MenuAction_Display|MenuAction_Select|MenuAction_DisplayItem);

	AddMenuItem(g_hVIPAdminMenu, "", "vip_add");
	AddMenuItem(g_hVIPAdminMenu, "", "vip_list");
	AddMenuItem(g_hVIPAdminMenu, "", "vip_reload_players");
	AddMenuItem(g_hVIPAdminMenu, "", "vip_reload_settings");
}

public Handler_VIPAdminMenu(Handle:hMenu, MenuAction:action, iClient, iOption)
{
	switch(action)
	{
		case MenuAction_Display:
		{
			char sTitle[128];
			FormatEx(sTitle, sizeof(sTitle), "%T: \n ", "VIP_ADMIN_MENU_TITLE", iClient);
			SetPanelTitle(Handle:iOption, sTitle);
		}
		case MenuAction_DisplayItem:
		{
			char sDisplay[128];
			
			switch(iOption)
			{
				case 0:	FormatEx(sDisplay, sizeof(sDisplay), "%T", "MENU_ADD_VIP", iClient);
				case 1:	FormatEx(sDisplay, sizeof(sDisplay), "%T", "MENU_LIST_VIP", iClient);
				case 2:	FormatEx(sDisplay, sizeof(sDisplay), "%T", "ADMIN_MENU_RELOAD_VIP_PLAYES", iClient);
				case 3:	FormatEx(sDisplay, sizeof(sDisplay), "%T", "ADMIN_MENU_RELOAD_VIP_CFG", iClient);
			}

			return RedrawMenuItem(sDisplay);
		}
		
		case MenuAction_Select:
		{
			switch(iOption)
			{
				case 0:
				{
					InitiateDataArray(iClient);
					SetArrayCell(g_ClientData[iClient], DATA_MENU_TYPE, MENU_TYPE_ADD);
					ShowAddVIPMenu(iClient);
				}
				case 1:
				{
					InitiateDataArray(iClient);
					ShowVipPlayersListMenu(iClient);
				}
				case 2:
				{
					ReloadVIPPlayers_CMD(iClient, 0);

					DisplayMenu(g_hVIPAdminMenu, iClient, MENU_TIME_FOREVER);
				}
				case 3:
				{
					ReloadVIPCfg_CMD(iClient, 0);

					DisplayMenu(g_hVIPAdminMenu, iClient, MENU_TIME_FOREVER);
				}
			}
		}
	}

	return 0;
}

public OnLibraryAdded(const char[] sLibraryName)
{
	if (strcmp(sLibraryName, "adminmenu") == 0) 
	{
		decl Handle:hTopMenu;
		if((hTopMenu = GetAdminTopMenu()))
		{
			OnAdminMenuReady(hTopMenu);
		}
	}
}

public OnLibraryRemoved(const char[] sLibraryName)
{
	if (strcmp(sLibraryName, "adminmenu") == 0) 
	{
		g_hTopMenu = INVALID_HANDLE;
		VIPAdminMenuObject = INVALID_TOPMENUOBJECT;
	}
}

public OnAdminMenuReady(Handle:hTopMenu)
{
	if (g_hTopMenu == hTopMenu)
	{
		return;
	}

	g_hTopMenu = hTopMenu;

	if(g_CVAR_bAddItemToAdminMenu)
	{
		AddItemsToTopMenu();
	}
}

void AddItemsToTopMenu()
{
	if(VIPAdminMenuObject == INVALID_TOPMENUOBJECT)
	{
		VIPAdminMenuObject = AddToTopMenu(g_hTopMenu, "vip_admin", TopMenuObject_Category, Handler_MenuVIPAdmin, INVALID_TOPMENUOBJECT, "vip_admin", ADMFLAG_ROOT);
		
	}

	AddToTopMenu(g_hTopMenu, "vip_add",				TopMenuObject_Item, Handler_MenuVIPAdd,				VIPAdminMenuObject, "vip_add",				ADMFLAG_ROOT);
	AddToTopMenu(g_hTopMenu, "vip_list",				TopMenuObject_Item, Handler_MenuVIPList,				VIPAdminMenuObject, "vip_list",			ADMFLAG_ROOT);
	AddToTopMenu(g_hTopMenu, "vip_reload_players",	TopMenuObject_Item, Handler_MenuVIPReloadPlayers,	VIPAdminMenuObject, "vip_reload_players",	ADMFLAG_ROOT);
	AddToTopMenu(g_hTopMenu, "vip_reload_settings",	TopMenuObject_Item, Handler_MenuVIPReloadSettings,	VIPAdminMenuObject, "vip_reload_settings",	ADMFLAG_ROOT);
}

public Handler_MenuVIPAdmin(Handle:hMenu, TopMenuAction:action, TopMenuObject:object_id, iClient, char[] sBuffer, maxlength)
{
	switch(action)
	{
		case TopMenuAction_DisplayOption:	FormatEx(sBuffer, maxlength, "%T", "VIP_ADMIN_MENU_TITLE", iClient);
		case TopMenuAction_DisplayTitle:	FormatEx(sBuffer, maxlength, "%T: \n \n", "VIP_ADMIN_MENU_TITLE", iClient);
	}
}

public Handler_MenuVIPAdd(Handle:hMenu, TopMenuAction:action, TopMenuObject:object_id, iClient, char[] sBuffer, maxlength)
{
	switch(action)
	{
		case TopMenuAction_DisplayOption:	FormatEx(sBuffer, maxlength, "%T", "MENU_ADD_VIP", iClient);
		case TopMenuAction_SelectOption:
		{
			InitiateDataArray(iClient);
			SetArrayCell(g_ClientData[iClient], DATA_MENU_TYPE, MENU_TYPE_ADD);
			ShowAddVIPMenu(iClient);
		}
	}
}

public Handler_MenuVIPList(Handle:hMenu, TopMenuAction:action, TopMenuObject:object_id, iClient, char[] sBuffer, maxlength)
{
	switch(action)
	{
		case TopMenuAction_DisplayOption:	FormatEx(sBuffer, maxlength, "%T", "MENU_LIST_VIP", iClient);
		case TopMenuAction_SelectOption:
		{
			InitiateDataArray(iClient);
			ShowVipPlayersListMenu(iClient);
		}
	}
}

public Handler_MenuVIPReloadPlayers(Handle:hMenu, TopMenuAction:action, TopMenuObject:object_id, iClient, char[] sBuffer, maxlength)
{
	switch(action)
	{
		case TopMenuAction_DisplayOption:	FormatEx(sBuffer, maxlength, "%T", "ADMIN_MENU_RELOAD_VIP_PLAYES", iClient);
		case TopMenuAction_SelectOption:
		{
			ReloadVIPPlayers_CMD(iClient, 0);
			RedisplayAdminMenu(g_hTopMenu, iClient);
		}
	}
}

public Handler_MenuVIPReloadSettings(Handle:hMenu, TopMenuAction:action, TopMenuObject:object_id, iClient, char[] sBuffer, maxlength)
{
	switch(action)
	{
		case TopMenuAction_DisplayOption:	FormatEx(sBuffer, maxlength, "%T", "ADMIN_MENU_RELOAD_VIP_CFG", iClient);
		case TopMenuAction_SelectOption:
		{
			ReloadVIPCfg_CMD(iClient, 0);

			RedisplayAdminMenu(g_hTopMenu, iClient);
		}
	}
}

void InitiateDataArray(int iClient)
{
	if(g_ClientData[iClient] == INVALID_HANDLE)
	{
		g_ClientData[iClient] = CreateArray(ByteCountToCells(64), DATA_SIZE);
	}
	else
	{
		ClearArray(g_ClientData[iClient]);
		ResizeArray(g_ClientData[iClient], DATA_SIZE);
	}
}

int IsClientOnline(int ID)
{
	decl i, iClientID;
	for (i = 1; i <= MaxClients; ++i)
	{
		if (IsClientInGame(i) && g_hFeatures[i] != INVALID_HANDLE && GetTrieValue(g_hFeatures[i], KEY_CID, iClientID) && iClientID == ID) return i;
	}
	return 0;
}

void ShowTimeMenu(int iClient)
{
	SetGlobalTransTarget(iClient);

	decl Handle:hMenu, Handle:hKv, iMenuType;
	hMenu = CreateMenu(MenuHandler_TimeMenu);
	
	iMenuType = GetArrayCell(g_ClientData[iClient], DATA_TIME);
	switch(iMenuType)
	{
		case TIME_SET: 	SetMenuTitle(hMenu, "%t:\n \n", "MENU_TIME_SET");
		case TIME_ADD:	SetMenuTitle(hMenu, "%t:\n \n", "MENU_TIME_ADD");
		case TIME_TAKE:	SetMenuTitle(hMenu, "%t:\n \n", "MENU_TIME_TAKE");
	}

	SetMenuExitBackButton(hMenu, true);

	hKv = CreateConfig("data/vip/cfg/times.ini", "TIMES");

	if (KvGotoFirstSubKey(hKv))
	{
		char sBuffer[128]; char sTime[32]; char sClientLang[3]; char sServerLang[3];
		GetLanguageInfo(GetServerLanguage(), sServerLang, sizeof(sServerLang));
		GetLanguageInfo(GetClientLanguage(iClient), sClientLang, sizeof(sClientLang));

		do
		{
			KvGetSectionName(hKv, sTime, sizeof(sTime));

			if(iMenuType != TIME_SET && sTime[0] == '0') continue;

			KvGetString(hKv, sClientLang, sBuffer, sizeof(sBuffer), "LangError");
			if(strcmp(sBuffer, "LangError") == 0) KvGetString(hKv, sServerLang, sBuffer, sizeof(sBuffer), "LangError");

			AddMenuItem(hMenu, sTime, sBuffer);

		}
		while (KvGotoNextKey(hKv, false));
	}

	CloseHandle(hKv);

	DisplayMenu(hMenu, iClient, MENU_TIME_FOREVER);
}

public MenuHandler_TimeMenu(Handle:hMenu, MenuAction:action, iClient, Item)
{
	switch(action)
	{
		case MenuAction_End: CloseHandle(hMenu);
		case MenuAction_Cancel:
		{
			if(Item == MenuCancel_ExitBack)
			{
				if(GetArrayCell(g_ClientData[iClient], DATA_MENU_TYPE) == MENU_TYPE_ADD)
				{
					ShowAuthTypeMenu(iClient);
				}
				else
				{
					ShowEditTimeMenu(iClient);
				}
			}
		}
		case MenuAction_Select:
		{
			char sBuffer[64]; iType, iTime;
			GetMenuItem(hMenu, Item, sBuffer, sizeof(sBuffer));
			iTime = StringToInt(sBuffer);
			iType = GetArrayCell(g_ClientData[iClient], DATA_TIME);

			if(GetArrayCell(g_ClientData[iClient], DATA_MENU_TYPE) == MENU_TYPE_ADD)
			{
				new iTarget = GetClientOfUserId(GetArrayCell(g_ClientData[iClient], DATA_TARGET_USER_ID));
				if (iTarget)
				{
					SetArrayCell(g_ClientData[iClient], DATA_TIME, iTime);
					ShowGroupMenu(iClient);
				}
				else
				{
					VIP_PrintToChatClient(iClient, "%t", "PLAYER_NO_LONGER_AVAILABLE");
					DisplayMenu(g_hVIPAdminMenu, iClient, MENU_TIME_FOREVER);
				}
				
			}
			else
			{
				char sTime[64]; iExpires;
				GetArrayString(g_ClientData[iClient], DATA_NAME, sBuffer, sizeof(sBuffer));
				
				switch(iType)
				{
					case TIME_SET:
					{
						if(iTime == 0)
						{
							iExpires = 0;
						}
						else
						{
							iExpires = GetTime()+iTime;
						}
						
						
						FormatTime(sTime, sizeof(sTime), "%d/%m/%Y - %H:%M", iExpires);
						VIP_PrintToChatClient(iClient, "%t", "ADMIN_SET_EXPIRATION", sBuffer, sTime);

						if(g_CVAR_bLogsEnable) LogToFile(g_sLogFile, "%T", "LOG_ADMIN_SET_EXPIRATION", iClient, iClient, sBuffer, sTime);
					}
					case TIME_ADD:
					{
						iExpires = GetArrayCell(g_ClientData[iClient], DATA_AUTH_TYPE);
						if(iExpires > 0)
						{
							iExpires += iTime;

							UTIL_GetTimeFromStamp(sTime, sizeof(sTime), iTime, iClient);
							VIP_PrintToChatClient(iClient, "%t", "ADMIN_EXTENDED", sBuffer, sTime);

							if(g_CVAR_bLogsEnable) LogToFile(g_sLogFile, "%T", "LOG_ADMIN_EXTENDED", iClient, iClient, sBuffer, sTime);
						}
						else
						{
							VIP_PrintToChatClient(iClient, "%t", "UNABLE_TO_EXTENDED");
							SetArrayCell(g_ClientData[iClient], DATA_TIME, TIME_ADD);
							ShowTimeMenu(iClient);
							return 0;
						}
					}
					case TIME_TAKE:
					{
						iExpires = GetArrayCell(g_ClientData[iClient], DATA_AUTH_TYPE);
						if(iExpires > 0)
						{
							iExpires -= iTime;
					
							if(iExpires > GetTime())
							{
								UTIL_GetTimeFromStamp(sTime, sizeof(sTime), iTime, iClient);

								VIP_PrintToChatClient(iClient, "%t", "ADMIN_REDUCED", sBuffer, sTime);

								if(g_CVAR_bLogsEnable) LogToFile(g_sLogFile, "%T", "LOG_ADMIN_REDUCED", iClient, iClient, sBuffer, sTime);
							}
							else
							{
								VIP_PrintToChatClient(iClient, "%t", "INCORRECT_TIME");
								SetArrayCell(g_ClientData[iClient], DATA_TIME, TIME_TAKE);
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

				decl iClientID; char sQuery[512];
				iClientID = GetArrayCell(g_ClientData[iClient], DATA_TARGET_ID);
				if (GLOBAL_INFO & IS_MySQL)
				{
					FormatEx(sQuery, sizeof(sQuery), "UPDATE `vip_overrides` SET `expires` = '%i' WHERE `user_id` = '%i' AND `server_id` = '%i';", iExpires, iClientID, g_CVAR_iServerID);
				}
				else
				{
					FormatEx(sQuery, sizeof(sQuery), "UPDATE `vip_users` SET `expires` = '%i' WHERE `id` = '%i';", iExpires, iClientID);
				}

				SQL_TQuery(g_hDatabase, SQL_Callback_ChangeTime, sQuery, UID(iClient));

				ShowTargetInfoMenu(iClient, iClientID);
			}
		}
	
	}
	
	return 0;
}

public SQL_Callback_ChangeTime(Handle:hOwner, Handle:hQuery, const char[] sError, any UserID)
{
	if (sError[0])
	{
		LogError("SQL_Callback_ChangeTime: %s", sError);
		return;
	}
	
	if(SQL_GetAffectedRows(hOwner))
	{
		new iClient = CID(UserID);
		if(iClient)
		{
			new iTarget = IsClientOnline(GetArrayCell(g_ClientData[iClient], DATA_TARGET_ID));
			if(iTarget)
			{
				Clients_CheckVipAccess(iTarget, true);
			}
		}
	}
}

void ReductionMenu(Handle &hMenu, int iNum)
{
	for(new i = 0; i < iNum; ++i) AddMenuItem(hMenu, "", "", ITEMDRAW_NOTEXT);
}

#include "vip/adminmenu/add_vip.sp"
#include "vip/adminmenu/edit_vip.sp"
#include "vip/adminmenu/del_vip.sp"
#include "vip/adminmenu/list_vip.sp"


/*
void AddMenuTranslatedItem(Handle:hMenu, iClient, const char[] sItem)
{
	char sBuffer[128];
	FormatEx(sBuffer, sizeof(sBuffer), "%T", sItem, iClient);
	AddMenuItem(hMenu, sItem, sBuffer);
}
*/