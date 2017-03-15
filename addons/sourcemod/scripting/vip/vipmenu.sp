static const char g_sToggleStatus[][] = 
{
	"DISABLED", 
	"ENABLED", 
	"NO_ACCESS"
};

void InitVIPMenu()
{
	g_hVIPMenu = CreateMenu(Handler_VIPMenu, MenuAction_Start | MenuAction_Display | MenuAction_Cancel | MenuAction_Select | MenuAction_DisplayItem | MenuAction_DrawItem);
	
	AddMenuItem(g_hVIPMenu, "NO_FEATURES", "NO_FEATURES", ITEMDRAW_DISABLED);
}

void AddFeatureToVIPMenu(const char[] sFeatureName)
{
	DebugMessage("AddFeatureToVIPMenu: %s", sFeatureName)
	if (g_hSortArray != INVALID_HANDLE)
	{
		ResortFeaturesArray();
		
		RemoveAllMenuItems(g_hVIPMenu);
		
		decl i, iSize; char sItemInfo[128];
		ArrayList hArray;
		iSize = (GLOBAL_ARRAY).Length;
		for (i = 0; i < iSize; ++i)
		{
			GLOBAL_ARRAY.GetString(i, sItemInfo, sizeof(sItemInfo));
			if (GetTrieValue(GLOBAL_TRIE, sItemInfo, hArray) && VIP_FeatureType:hArray.Get(FEATURES_ITEM_TYPE) != HIDE)
			{
				DebugMessage("AddMenuItem: %s", sItemInfo)
				AddMenuItem(g_hVIPMenu, sItemInfo, sItemInfo);
			}
		}
	}
	else
	{
		DebugMessage("AddMenuItem")
		AddMenuItem(g_hVIPMenu, sFeatureName, sFeatureName);
	}
}

void ResortFeaturesArray()
{
	DebugMessage("ResortFeaturesArray\n \n ")
	
	if ((GLOBAL_ARRAY).Length < 2)
	{
		return;
	}
	
	decl i, x, iSize, index; char sItemInfo[128];
	iSize = (g_hSortArray).Length;
	
	#if DEBUG_MODE 1
	PrintArray(g_hSortArray);
	PrintArray(GLOBAL_ARRAY);
	#endif
	
	x = 0;
	for (i = 0; i < iSize; ++i)
	{
		g_hSortArray.GetString(i, sItemInfo, sizeof(sItemInfo));
		DebugMessage("GetSortArrayString: %s (i: %i, x: %i)", sItemInfo, i, x)
		index = GLOBAL_ARRAY.FindString(sItemInfo);
		DebugMessage("FindStringInGlobalArray: index: %i", index)
		if (index != -1)
		{
			if (index != x)
			{
				DebugMessage("SwapArrayItems")
				GLOBAL_ARRAY.SwapAt(index, x);
				#if DEBUG_MODE 1
				PrintArray(GLOBAL_ARRAY);
				#endif
			}
			
			++x;
		}
	}
}

#if DEBUG_MODE 1
stock void PrintArray(Handle &hArray)
{
	DebugMessage("PrintArray")
	decl i, iSize; char sItemInfo[128];
	iSize = (hArray).Length;
	if (iSize)
	{
		for (i = 0; i < iSize; ++i)
		{
			hArray.GetString(i, sItemInfo, sizeof(sItemInfo));
			DebugMessage("%i: %s", i, sItemInfo)
		}
	}
}
#endif

public int Handler_VIPMenu(Menu hMenu, MenuAction action, int iClient, int iOption)
{
	static char sItemInfo[FEATURE_NAME_LENGTH]; Handle:hBuffer, Function:Function_Call, Handle:hPlugin;
	/*
	switch(action)
	{
		case MenuAction_Display, MenuAction_DrawItem, MenuAction_DisplayItem, MenuAction_Select:
		{
			if(!(g_iClientInfo[iClient] & IS_VIP))
			{
				CancelMenu(g_hVIPMenu);
				DisplayClientInfo(iClient, "expired_info");
				return 0;
			}
		}
	}
	*/
	switch (action)
	{
		case MenuAction_Cancel:
		{
			UNSET_BIT(g_iClientInfo[iClient], IS_MENU_OPEN);
		}
		case MenuAction_Display:
		{
			SET_BIT(g_iClientInfo[iClient], IS_MENU_OPEN);
			
			DebugMessage("MenuAction_Display: Client: %i", iClient)
			char sTitle[256]; iExp;
			if (GetTrieValue(g_hFeatures[iClient], KEY_EXPIRES, iExp) && iExp > 0)
			{
				decl iTime;
				if ((iTime = GetTime()) < iExp)
				{
					char sExpires[64];
					UTIL_GetTimeFromStamp(sExpires, sizeof(sExpires), iExp - iTime, iClient);
					FormatEx(sTitle, sizeof(sTitle), "%T\n \n%T: %s\n \n", "VIP_MENU_TITLE", iClient, "EXPIRES_IN", iClient, sExpires);
				}
				else
				{
					//	FakeClientCommand(iClient, "menuselect 0");
					DisplayClientInfo(iClient, "expired_info");
					Clients_ExpiredClient(iClient);
					return 0;
				}
			}
			else
			{
				FormatEx(sTitle, sizeof(sTitle), "%T\n \n", "VIP_MENU_TITLE", iClient);
			}
			
			SetPanelTitle(Handle:iOption, sTitle);
		}
		
		case MenuAction_DrawItem:
		{
			decl iStyle;
			GetMenuItem(g_hVIPMenu, iOption, sItemInfo, sizeof(sItemInfo), iStyle);
			
			DebugMessage("MenuAction_DrawItem: Client: %i, Feature: %s, iStyle: %i", iClient, sItemInfo, iStyle)
			
			if (GetTrieValue(GLOBAL_TRIE, sItemInfo, hBuffer))
			{
				if (VIP_ValueType:hBuffer.Get(FEATURES_VALUE_TYPE) != VIP_NULL && Features_GetStatus(iClient, sItemInfo) == NO_ACCESS)
				{
					iStyle = g_CVAR_bHideNoAccessItems ? ITEMDRAW_RAWLINE:ITEMDRAW_DISABLED;
					DebugMessage("NO_ACCESS -> iStyle: %i", iStyle)
				}
				
				DataPack hDataPack = view_as<DataPack>(hBuffer.Get(FEATURES_MENU_CALLBACKS));
				hDataPack.Position = ITEM_DRAW;
				Function_Call = hDataPack.ReadFunction();
				if (Function_Call != INVALID_FUNCTION)
				{
					hPlugin = view_as<Handle>(hBuffer.Get(FEATURES_PLUGIN));
					DebugMessage("GetPluginStatus = %i", GetPluginStatus(hPlugin))
					if (GetPluginStatus(hPlugin) == Plugin_Running)
					{
						Call_StartFunction(hPlugin, Function_Call);
						Call_PushCell(iClient);
						Call_PushString(sItemInfo);
						Call_PushCell(iStyle);
						Call_Finish(iStyle);
						DebugMessage("Function_Draw -> iStyle: %i", iStyle)
					}
				}
			}
			
			DebugMessage("return iStyle: %i", iStyle)
			
			return iStyle;
		}
		
		case MenuAction_DisplayItem:
		{
			GetMenuItem(g_hVIPMenu, iOption, sItemInfo, sizeof(sItemInfo));
			
			DebugMessage("MenuAction_DisplayItem: Client: %i, Feature: %s", iClient, sItemInfo)
			
			char sDisplay[128];
			
			if (GetTrieValue(GLOBAL_TRIE, sItemInfo, hBuffer))
			{
				DataPack hDataPack = view_as<DataPack>(hBuffer.Get(FEATURES_MENU_CALLBACKS));
				hDataPack.Position = ITEM_DISPLAY;
				Function_Call = hDataPack.ReadFunction();
				if (Function_Call != INVALID_FUNCTION)
				{
					hPlugin = view_as<Handle>(hBuffer.Get(FEATURES_PLUGIN));
					DebugMessage("GetPluginStatus = %i", GetPluginStatus(hPlugin))
					if (GetPluginStatus(hPlugin) == Plugin_Running)
					{
						sDisplay[0] = 0;
						bool bResult;
						Call_StartFunction(hPlugin, Function_Call);
						Call_PushCell(iClient);
						Call_PushString(sItemInfo);
						Call_PushStringEx(sDisplay, sizeof(sDisplay), SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
						Call_PushCell(sizeof(sDisplay));
						Call_Finish(bResult);
						
						DebugMessage("Function_Display: bResult: %b", bResult)
						
						if (bResult == true)
						{
							return RedrawMenuItem(sDisplay);
						}
					}
				}
				
				if (VIP_FeatureType:hBuffer.Get(FEATURES_ITEM_TYPE) == TOGGLABLE)
				{
					FormatEx(sDisplay, sizeof(sDisplay), "%T [%T]", sItemInfo, iClient, g_sToggleStatus[_:Features_GetStatus(iClient, sItemInfo)], iClient);
					return RedrawMenuItem(sDisplay);
				}
				
				FormatEx(sDisplay, sizeof(sDisplay), "%T", sItemInfo, iClient);
				
				return RedrawMenuItem(sDisplay);
			}
			else if (strcmp(sItemInfo, "NO_FEATURES") == 0)
			{
				FormatEx(sItemInfo, sizeof(sItemInfo), "%T", "NO_FEATURES", iClient);
			}
			
			return RedrawMenuItem(sItemInfo);
		}
		
		case MenuAction_Select:
		{
			GetMenuItem(g_hVIPMenu, iOption, sItemInfo, sizeof(sItemInfo));
			
			if (GetTrieValue(GLOBAL_TRIE, sItemInfo, hBuffer))
			{
				DebugMessage("MenuAction_Select: Client: %i, Feature: %s", iClient, sItemInfo)
				
				DataPack hDataPack = view_as<DataPack>(hBuffer.Get(FEATURES_MENU_CALLBACKS));
				hDataPack.Position = ITEM_SELECT;
				Function_Call = hDataPack.ReadFunction();
				hPlugin = view_as<Handle>(hBuffer.Get(FEATURES_PLUGIN));
				DebugMessage("GetPluginStatus = %i", GetPluginStatus(hPlugin))
				if (VIP_FeatureType:hBuffer.Get(FEATURES_ITEM_TYPE) == TOGGLABLE)
				{
					char sBuffer[4]; VIP_ToggleState:OldStatus, VIP_ToggleState:NewStatus;
					OldStatus = Features_GetStatus(iClient, sItemInfo);
					NewStatus = (OldStatus == ENABLED) ? DISABLED:ENABLED;
					if (Function_Call != INVALID_FUNCTION && GetPluginStatus(hPlugin) == Plugin_Running)
					{
						NewStatus = Function_OnItemToggle(hPlugin, Function_Call, iClient, sItemInfo, OldStatus, NewStatus);
					}
					Features_SetStatus(iClient, sItemInfo, NewStatus);
					IntToString(_:NewStatus, sBuffer, sizeof(sBuffer));
					SetClientCookie(iClient, Handle:hBuffer.Get(FEATURES_COOKIE), sBuffer);
				}
				else
				{
					if (Function_Call != INVALID_FUNCTION && GetPluginStatus(hPlugin) == Plugin_Running && Function_OnItemSelect(hPlugin, Function_Call, iClient, sItemInfo) == false)
					{
						return 0;
					}
				}
				
				DisplayMenuAtItem(hMenu, iClient, GetMenuSelectionPosition(), MENU_TIME_FOREVER);
				PlaySound(iClient, ITEM_TOGGLE_SOUND);
			}
		}
	}
	
	return 0;
}

VIP_ToggleState Function_OnItemToggle(Handle hPlugin, Function ToggleFunction, int iClient, const char[] sItemInfo, const VIP_ToggleState OldStatus, const VIP_ToggleState NewStatus)
{
	decl VIP_ToggleState:ResultStatus, Action:aResult;
	ResultStatus = NewStatus;
	Call_StartFunction(hPlugin, ToggleFunction);
	Call_PushCell(iClient);
	Call_PushString(sItemInfo);
	Call_PushCell(OldStatus);
	Call_PushCellRef(ResultStatus);
	Call_Finish(aResult);
	
	switch (aResult)
	{
		case Plugin_Continue:
		{
			return NewStatus;
		}
		case Plugin_Changed:
		{
			return ResultStatus;
		}
		case Plugin_Handled, Plugin_Stop:
		{
			return OldStatus;
		}
		default:
		{
			return ResultStatus;
		}
	}
	
	return ResultStatus;
}

bool Function_OnItemSelect(Handle hPlugin, Function SelectFunction, int iClient, const char[] sItemInfo)
{
	bool bResult;
	Call_StartFunction(hPlugin, SelectFunction);
	Call_PushCell(iClient);
	Call_PushString(sItemInfo);
	Call_Finish(bResult);
	
	return bResult;
}

bool IsValidFeature(const char[] sFeatureName)
{
	DebugMessage("IsValidFeature:: FindStringInArray -> %i", GLOBAL_ARRAY.FindString(sFeatureName))
	return (GLOBAL_ARRAY.FindString(sFeatureName) != -1);
}

bool OnVipMenuFlood(int iClient)
{
	static float fLastTime[MAXPLAYERS + 1];
	if (fLastTime[iClient] > 0.0)
	{
		float fSec = GetGameTime();
		if ((fSec - fLastTime[iClient]) < 3.0)return true;
		fLastTime[iClient] = fSec;
	}
	return false;
} 