void VIPMenu_Setup()
{
	g_hVIPMenu = new Menu(Handler_VIPMenu, MenuAction_Start | MenuAction_Display | MenuAction_Cancel | MenuAction_Select | MenuAction_DisplayItem | MenuAction_DrawItem);
	
	g_hVIPMenu.AddItem("NO_FEATURES", "NO_FEATURES", ITEMDRAW_DISABLED);
}

void AddFeatureToVIPMenu(const char[] szFeature)
{
	DebugMessage("AddFeatureToVIPMenu: %s", szFeature)
	if (g_hSortArray != null)
	{
		ResortFeaturesArray();
		
		g_hVIPMenu.RemoveAllItems();
		
		int i, iSize;
		char szItemInfo[128];
		ArrayList hArray;
		iSize = g_hFeaturesArray.Length;
		for (i = 0; i < iSize; ++i)
		{
			g_hFeaturesArray.GetString(i, SZF(szItemInfo));
			if (GLOBAL_TRIE.GetValue(szItemInfo, hArray) && view_as<VIP_FeatureType>(hArray.Get(FEATURES_ITEM_TYPE)) != HIDE)
			{
				DebugMessage("AddMenuItem: %s", szItemInfo)
				g_hVIPMenu.AddItem(szItemInfo, szItemInfo);
			}
		}
	}
	else
	{
		DebugMessage("AddMenuItem")
		g_hVIPMenu.AddItem(szFeature, szFeature);
	}
}

void ResortFeaturesArray()
{
	DebugMessage("ResortFeaturesArray\n \n ")
	
	if ((g_hFeaturesArray).Length < 2)
	{
		return;
	}
	
	int i, x, iSize, index;
	iSize = g_hSortArray.Length;
	
	/*#if DEBUG_MODE 1
	PrintArray(g_hSortArray);
	PrintArray(g_hFeaturesArray);
	#endif*/
	
	x = 0;
	char szItemInfo[128];
	for (i = 0; i < iSize; ++i)
	{
		g_hSortArray.GetString(i, SZF(szItemInfo));
		DebugMessage("GetSortArrayString: %s (i: %i, x: %i)", szItemInfo, i, x)
		index = g_hFeaturesArray.FindString(szItemInfo);
		DebugMessage("FindStringInGlobalArray: index: %i", index)
		if (index != -1)
		{
			if (index != x)
			{
				DebugMessage("SwapArrayItems")
				g_hFeaturesArray.SwapAt(index, x);
				/*#if DEBUG_MODE 1
				PrintArray(g_hFeaturesArray);
				#endif*/
			}
			
			++x;
		}
	}
}
/*
#if DEBUG_MODE 1
stock void PrintArray(ArrayList &hArray)
{
	DebugMessage("PrintArray")
	int i, iSize;
	iSize = hArray.Length;
	if (iSize)
	{
		char szItemInfo[128];
		for (i = 0; i < iSize; ++i)
		{
			hArray.GetString(i, SZF(szItemInfo));
			DebugMessage("%i: %s", i, szItemInfo)
		}
	}
}
#endif
*/
public int Handler_VIPMenu(Menu hMenu, MenuAction action, int iClient, int iOption)
{
	if(action == MenuAction_Display ||
		action == MenuAction_DisplayItem ||
		action == MenuAction_DrawItem ||
		action == MenuAction_Select)
	{
		if(!(g_iClientInfo[iClient] & IS_VIP) || !g_hFeatures[iClient])
		{
			return 0;
		}
	}
	static char szItemInfo[FEATURE_NAME_LENGTH];
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
			char szTitle[256];
			int iExp;
			if (g_hFeatures[iClient].GetValue(KEY_EXPIRES, iExp) && iExp > 0)
			{
				int iTime;
				if ((iTime = GetTime()) < iExp)
				{
					char szExpires[64];
					UTIL_GetTimeFromStamp(SZF(szExpires), iExp - iTime, iClient);
					FormatEx(SZF(szTitle), "%T\n \n%T: %s\n \n", "VIP_MENU_TITLE", iClient, "EXPIRES_IN", iClient, szExpires);
				}
				else
				{
					//	FakeClientCommand(iClient, "menuselect 0");
				//	DisplayClientInfo(iClient, "expired_info");
					Clients_ExpiredClient(iClient);
					return 0;
				}
			}
			else
			{
				FormatEx(SZF(szTitle), "%T\n \n", "VIP_MENU_TITLE", iClient);
			}
			
			(view_as<Panel>(iOption)).SetTitle(szTitle);
		}
		
		case MenuAction_DrawItem:
		{
			int iStyle;
			g_hVIPMenu.GetItem(iOption, SZF(szItemInfo), iStyle);
			
			DebugMessage("MenuAction_DrawItem: Client: %i, Feature: %s, iStyle: %i", iClient, szItemInfo, iStyle)
			
			if (GLOBAL_TRIE.GetValue(szItemInfo, hBuffer))
			{
				if (view_as<VIP_ValueType>(hBuffer.Get(FEATURES_VALUE_TYPE)) != VIP_NULL && Features_GetStatus(iClient, szItemInfo) == NO_ACCESS)
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
					Call_PushString(szItemInfo);
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
			g_hVIPMenu.GetItem(iOption, SZF(szItemInfo));
			
			DebugMessage("MenuAction_DisplayItem: Client: %i, Feature: %s", iClient, szItemInfo)
			
			char szDisplay[128];
			
			if (GLOBAL_TRIE.GetValue(szItemInfo, hBuffer))
			{
				DataPack hDataPack = view_as<DataPack>(hBuffer.Get(FEATURES_MENU_CALLBACKS));
				hDataPack.Position = ITEM_DISPLAY;
				fCallback = hDataPack.ReadFunction();
				if (fCallback != INVALID_FUNCTION)
				{
					hPlugin = view_as<Handle>(hBuffer.Get(FEATURES_PLUGIN));

					szDisplay[0] = 0;
					bool bResult;
					Call_StartFunction(hPlugin, fCallback);
					Call_PushCell(iClient);
					Call_PushString(szItemInfo);
					Call_PushStringEx(SZF(szDisplay), SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
					Call_PushCell(sizeof(szDisplay));
					Call_Finish(bResult);
					
					DebugMessage("Function_Display: bResult: %b", bResult)
					
					if (bResult)
					{
						return RedrawMenuItem(szDisplay);
					}
				}
				
				if (view_as<VIP_FeatureType>(hBuffer.Get(FEATURES_ITEM_TYPE)) == TOGGLABLE)
				{
					if(CanTestFeatures() && GetFeatureStatus(FeatureType_Native, "TranslationPhraseExists") == FeatureStatus_Available)
					{
						if(!TranslationPhraseExists(szItemInfo))
						{
							FormatEx(SZF(szDisplay), "%s [%T]", szItemInfo, g_szToggleStatus[view_as<int>(Features_GetStatus(iClient, szItemInfo))], iClient);
							return RedrawMenuItem(szDisplay);
						}
					}
					FormatEx(SZF(szDisplay), "%T [%T]", szItemInfo, iClient, g_szToggleStatus[view_as<int>(Features_GetStatus(iClient, szItemInfo))], iClient);
					return RedrawMenuItem(szDisplay);
				}
				
				if(CanTestFeatures() && GetFeatureStatus(FeatureType_Native, "TranslationPhraseExists") == FeatureStatus_Available)
				{
					if(!TranslationPhraseExists(szItemInfo))
					{
						strcopy(SZF(szDisplay), szItemInfo);
						return RedrawMenuItem(szDisplay);
					}
				}
				FormatEx(SZF(szDisplay), "%T", szItemInfo, iClient);

				return RedrawMenuItem(szDisplay);
			}
			if (strcmp(szItemInfo, "NO_FEATURES") == 0)
			{
				FormatEx(SZF(szItemInfo), "%T", "NO_FEATURES", iClient);
			}
			
			return RedrawMenuItem(szItemInfo);
		}
		
		case MenuAction_Select:
		{
			g_hVIPMenu.GetItem(iOption, SZF(szItemInfo));
			
			if (GLOBAL_TRIE.GetValue(szItemInfo, hBuffer))
			{
				PlaySound(iClient, ITEM_TOGGLE_SOUND);
				DebugMessage("MenuAction_Select: Client: %i, Feature: %s", iClient, szItemInfo)
				
				DataPack hDataPack = view_as<DataPack>(hBuffer.Get(FEATURES_MENU_CALLBACKS));
				hDataPack.Position = ITEM_SELECT;
				fCallback = hDataPack.ReadFunction();
				hPlugin = view_as<Handle>(hBuffer.Get(FEATURES_PLUGIN));
				if (view_as<VIP_FeatureType>(hBuffer.Get(FEATURES_ITEM_TYPE)) == TOGGLABLE)
				{
					char szBuffer[4];
					VIP_ToggleState eOldStatus, eNewStatus;

					eOldStatus = Features_GetStatus(iClient, szItemInfo);
					eNewStatus = (eOldStatus == ENABLED) ? DISABLED:ENABLED;
					if (fCallback != INVALID_FUNCTION)
					{
						eNewStatus = Function_OnItemToggle(hPlugin, fCallback, iClient, szItemInfo, eOldStatus, eNewStatus);
					}

					if (eNewStatus != eOldStatus)
					{
						eNewStatus = CreateForward_OnFeatureToggle(iClient, szItemInfo, eOldStatus, eNewStatus);
						if (eNewStatus != eOldStatus)
						{
							Features_SetStatus(iClient, szItemInfo, eNewStatus);
							IntToString(view_as<int>(eNewStatus), SZF(szBuffer));
							SetClientCookie(iClient, view_as<Handle>(GetArrayCell(hBuffer, FEATURES_COOKIE)), szBuffer);
						}
					}

					hMenu.DisplayAt(iClient, hMenu.Selection, MENU_TIME_FOREVER);
					return 0;
				}
				
				g_hFeatures[iClient].SetValue(KEY_MENUITEM, hMenu.Selection);
				if (Function_OnItemSelect(hPlugin, fCallback, iClient, szItemInfo))
				{
					hMenu.DisplayAt(iClient, hMenu.Selection, MENU_TIME_FOREVER);
				}
			}
		}
	}
	
	return 0;
}

bool IsValidFeature(const char[] szFeature)
{
	DebugMessage("IsValidFeature:: FindStringInArray -> %i", g_hFeaturesArray.FindString(szFeature))
	return (g_hFeaturesArray.FindString(szFeature) != -1);
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