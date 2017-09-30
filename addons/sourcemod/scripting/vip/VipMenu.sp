void VIPMenu_Setup()
{
	g_hVIPMenu = new Menu(Handler_VIPMenu, MenuAction_Start | MenuAction_Display | MenuAction_Cancel | MenuAction_Select | MenuAction_DisplayItem | MenuAction_DrawItem);
	
	g_hVIPMenu.AddItem("NO_FEATURES", "NO_FEATURES", ITEMDRAW_DISABLED);
}

void AddFeatureToVIPMenu(const char[] sFeatureName)
{
	DebugMessage("AddFeatureToVIPMenu: %s", sFeatureName)
	if (g_hSortArray != null)
	{
		ResortFeaturesArray();
		
		g_hVIPMenu.RemoveAllItems();
		
		int i, iSize;
		char sItemInfo[128];
		ArrayList hArray;
		iSize = g_hFeaturesArray.Length;
		for (i = 0; i < iSize; ++i)
		{
			g_hFeaturesArray.GetString(i, SZF(sItemInfo));
			if (GLOBAL_TRIE.GetValue(sItemInfo, hArray) && view_as<VIP_FeatureType>(hArray.Get(FEATURES_ITEM_TYPE)) != HIDE)
			{
				DebugMessage("AddMenuItem: %s", sItemInfo)
				g_hVIPMenu.AddItem(sItemInfo, sItemInfo);
			}
		}
	}
	else
	{
		DebugMessage("AddMenuItem")
		g_hVIPMenu.AddItem(sFeatureName, sFeatureName);
	}
}

void ResortFeaturesArray()
{
	DebugMessage("ResortFeaturesArray\n \n ")
	
	if ((g_hFeaturesArray).Length < 2)
	{
		return;
	}
	
	int i, x, iSize, index; char sItemInfo[128];
	iSize = (g_hSortArray).Length;
	
	#if DEBUG_MODE 1
	PrintArray(g_hSortArray);
	PrintArray(g_hFeaturesArray);
	#endif
	
	x = 0;
	for (i = 0; i < iSize; ++i)
	{
		g_hSortArray.GetString(i, sItemInfo, sizeof(sItemInfo));
		DebugMessage("GetSortArrayString: %s (i: %i, x: %i)", sItemInfo, i, x)
		index = g_hFeaturesArray.FindString(sItemInfo);
		DebugMessage("FindStringInGlobalArray: index: %i", index)
		if (index != -1)
		{
			if (index != x)
			{
				DebugMessage("SwapArrayItems")
				g_hFeaturesArray.SwapAt(index, x);
				#if DEBUG_MODE 1
				PrintArray(g_hFeaturesArray);
				#endif
			}
			
			++x;
		}
	}
}

#if DEBUG_MODE 1
stock void PrintArray(ArrayList &hArray)
{
	DebugMessage("PrintArray")
	int i, iSize; char sItemInfo[128];
	iSize = hArray.Length;
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
	static char sItemInfo[FEATURE_NAME_LENGTH];
	ArrayList hBuffer;
	Function fCallback;
	Handle hPlugin;
	/*
	switch (action)
	{
		case MenuAction_Display, MenuAction_DrawItem, MenuAction_DisplayItem, MenuAction_Select:
		{
			if (!(g_iClientInfo[iClient] & IS_VIP))
			{
				(g_hVIPMenu).Cancel();
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
			
			g_hFeatures[iClient].Remove(KEY_MENUITEM);

			DebugMessage("MenuAction_Display: Client: %i", iClient)
			char sTitle[256]; int iExp;
			if (g_hFeatures[iClient].GetValue(KEY_EXPIRES, iExp) && iExp > 0)
			{
				int iTime;
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
			
			(view_as<Panel>(iOption)).SetTitle(sTitle);
		}
		
		case MenuAction_DrawItem:
		{
			int iStyle;
			g_hVIPMenu.GetItem(iOption, sItemInfo, sizeof(sItemInfo), iStyle);
			
			DebugMessage("MenuAction_DrawItem: Client: %i, Feature: %s, iStyle: %i", iClient, sItemInfo, iStyle)
			
			if (GLOBAL_TRIE.GetValue(sItemInfo, hBuffer))
			{
				if (view_as<VIP_ValueType>(hBuffer.Get(FEATURES_VALUE_TYPE)) != VIP_NULL && Features_GetStatus(iClient, sItemInfo) == NO_ACCESS)
				{
					iStyle = g_CVAR_bHideNoAccessItems ? ITEMDRAW_RAWLINE:ITEMDRAW_DISABLED;
					DebugMessage("NO_ACCESS -> iStyle: %i", iStyle)
				}
				
				DataPack hDataPack = hBuffer.Get(FEATURES_MENU_CALLBACKS);
				hDataPack.Position = ITEM_DRAW;
				fCallback = hDataPack.ReadFunction();
				if (fCallback != INVALID_FUNCTION)
				{
					hPlugin = view_as<Handle>(hBuffer.Get(FEATURES_PLUGIN));
					Call_StartFunction(hPlugin, fCallback);
					Call_PushCell(iClient);
					Call_PushString(sItemInfo);
					Call_PushCell(iStyle);
					Call_Finish(iStyle);
					DebugMessage("Function_Draw -> iStyle: %i", iStyle)
				}
			}
			
			DebugMessage("return iStyle: %i", iStyle)
			
			return iStyle;
		}
		
		case MenuAction_DisplayItem:
		{
			g_hVIPMenu.GetItem(iOption, sItemInfo, sizeof(sItemInfo));
			
			DebugMessage("MenuAction_DisplayItem: Client: %i, Feature: %s", iClient, sItemInfo)
			
			char sDisplay[128];
			
			if (GLOBAL_TRIE.GetValue(sItemInfo, hBuffer))
			{
				DataPack hDataPack = view_as<DataPack>(hBuffer.Get(FEATURES_MENU_CALLBACKS));
				hDataPack.Position = ITEM_DISPLAY;
				fCallback = hDataPack.ReadFunction();
				if (fCallback != INVALID_FUNCTION)
				{
					hPlugin = view_as<Handle>(hBuffer.Get(FEATURES_PLUGIN));

					sDisplay[0] = 0;
					bool bResult;
					Call_StartFunction(hPlugin, fCallback);
					Call_PushCell(iClient);
					Call_PushString(sItemInfo);
					Call_PushStringEx(sDisplay, sizeof(sDisplay), SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
					Call_PushCell(sizeof(sDisplay));
					Call_Finish(bResult);
					
					DebugMessage("Function_Display: bResult: %b", bResult)
					
					if (bResult)
					{
						return RedrawMenuItem(sDisplay);
					}
				}
				
				if (view_as<VIP_FeatureType>(hBuffer.Get(FEATURES_ITEM_TYPE)) == TOGGLABLE)
				{
					FormatEx(sDisplay, sizeof(sDisplay), "%T [%T]", sItemInfo, iClient, g_sToggleStatus[view_as<int>(Features_GetStatus(iClient, sItemInfo))], iClient);
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
			g_hVIPMenu.GetItem(iOption, sItemInfo, sizeof(sItemInfo));
			
			if (GLOBAL_TRIE.GetValue(sItemInfo, hBuffer))
			{
				PlaySound(iClient, ITEM_TOGGLE_SOUND);
				DebugMessage("MenuAction_Select: Client: %i, Feature: %s", iClient, sItemInfo)
				
				DataPack hDataPack = view_as<DataPack>(hBuffer.Get(FEATURES_MENU_CALLBACKS));
				hDataPack.Position = ITEM_SELECT;
				fCallback = hDataPack.ReadFunction();
				hPlugin = view_as<Handle>(hBuffer.Get(FEATURES_PLUGIN));
				if (view_as<VIP_FeatureType>(hBuffer.Get(FEATURES_ITEM_TYPE)) == TOGGLABLE)
				{
					char sBuffer[4];
					VIP_ToggleState OldStatus, NewStatus;

					OldStatus = Features_GetStatus(iClient, sItemInfo);
					NewStatus = (OldStatus == ENABLED) ? DISABLED:ENABLED;
					if (fCallback != INVALID_FUNCTION)
					{
						NewStatus = Function_OnItemToggle(hPlugin, fCallback, iClient, sItemInfo, OldStatus, NewStatus);
					}

					if (NewStatus != OldStatus)
					{
						NewStatus = CreateForward_OnFeatureToggle(iClient, sItemInfo, OldStatus, NewStatus);
						if (NewStatus != OldStatus)
						{
							Features_SetStatus(iClient, sItemInfo, NewStatus);
							IntToString(view_as<int>(NewStatus), sBuffer, sizeof(sBuffer));
							SetClientCookie(iClient, view_as<Handle>(GetArrayCell(hBuffer, FEATURES_COOKIE)), sBuffer);
						}
					}

					hMenu.DisplayAt(iClient, hMenu.Selection, MENU_TIME_FOREVER);
					return 0;
				}
				
				g_hFeatures[iClient].SetValue(KEY_MENUITEM, hMenu.Selection);
				if (Function_OnItemSelect(hPlugin, fCallback, iClient, sItemInfo))
				{
					hMenu.DisplayAt(iClient, hMenu.Selection, MENU_TIME_FOREVER);
				}
			}
		}
	}
	
	return 0;
}

VIP_ToggleState Function_OnItemToggle(Handle hPlugin, Function ToggleFunction, int iClient, const char[] sFeatureName, const VIP_ToggleState OldStatus, const VIP_ToggleState NewStatus)
{
	VIP_ToggleState ResultStatus = NewStatus;
	Action aResult;
	Call_StartFunction(hPlugin, ToggleFunction);
	Call_PushCell(iClient);
	Call_PushString(sFeatureName);
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

bool Function_OnItemSelect(Handle hPlugin, Function SelectFunction, int iClient, const char[] sFeatureName)
{
	bool bResult;
	Call_StartFunction(hPlugin, SelectFunction);
	Call_PushCell(iClient);
	Call_PushString(sFeatureName);
	Call_Finish(bResult);
	
	return bResult;
}

bool IsValidFeature(const char[] sFeatureName)
{
	DebugMessage("IsValidFeature:: FindStringInArray -> %i", g_hFeaturesArray.FindString(sFeatureName))
	return (g_hFeaturesArray.FindString(sFeatureName) != -1);
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