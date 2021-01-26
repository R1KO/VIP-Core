void VIPMenu_Setup()
{
	g_hVIPMenu = new Menu(Handler_VIPMenu, MenuAction_Start | MenuAction_Display | MenuAction_Cancel | MenuAction_Select | MenuAction_DisplayItem | MenuAction_DrawItem);
	
	g_hVIPMenu.AddItem("NO_FEATURES", "NO_FEATURES", ITEMDRAW_DISABLED);
}

void AddFeatureToVIPMenu(const char[] szFeature)
{
	DebugMessage("AddFeatureToVIPMenu: %s", szFeature)
	if (g_hSortArray == null)
	{
		DebugMessage("AddMenuItem")
		g_hVIPMenu.AddItem(szFeature, szFeature);
		return;
	}

	ResortFeaturesArray();

	g_hVIPMenu.RemoveAllItems();

	int i, iSize;
	char szMenuFeature[FEATURE_NAME_LENGTH];
	ArrayList hArray;
	iSize = g_hFeaturesArray.Length;
	for (i = 0; i < iSize; ++i)
	{
		g_hFeaturesArray.GetString(i, SZF(szMenuFeature));
		if (GLOBAL_TRIE.GetValue(szMenuFeature, hArray) && view_as<VIP_FeatureType>(hArray.Get(FEATURES_ITEM_TYPE)) != HIDE)
		{
			DebugMessage("AddMenuItem: %s", szMenuFeature)
			g_hVIPMenu.AddItem(szMenuFeature, szMenuFeature);
		}
	}
}

void ResortFeaturesArray()
{
	DebugMessage("ResortFeaturesArray\n \n ")
	
	if (g_hFeaturesArray.Length < 2)
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
	char szFeature[128];
	for (i = 0; i < iSize; ++i)
	{
		g_hSortArray.GetString(i, SZF(szFeature));
		DebugMessage("GetSortArrayString: %s (i: %i, x: %i)", szFeature, i, x)
		index = g_hFeaturesArray.FindString(szFeature);
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
		char szFeature[128];
		for (i = 0; i < iSize; ++i)
		{
			hArray.GetString(i, SZF(szFeature));
			DebugMessage("%i: %s", i, szFeature)
		}
	}
}
#endif
*/
public int Handler_VIPMenu(Menu hMenu, MenuAction action, int iClient, int iOption)
{
	if((action == MenuAction_Display ||
		action == MenuAction_DisplayItem ||
		action == MenuAction_DrawItem ||
		action == MenuAction_Select) && 
		(!(g_iClientInfo[iClient] & IS_VIP) || !g_hFeatures[iClient]))
		{
		return 0;
	}

	static char szFeature[FEATURE_NAME_LENGTH];
	static ArrayList hBuffer;
	static Function fCallback;
	static Handle hPlugin;

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
				int iTime = GetTime();
				if (iTime < iExp)
				{
					char szExpires[64];
					UTIL_GetTimeFromStamp(SZF(szExpires), iExp - iTime, iClient);
					FormatEx(SZF(szTitle), "%T\n \n%T: %s\n \n", "VIP_MENU_TITLE", iClient, "EXPIRES_IN", iClient, szExpires);
				}
				else
				{
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
			g_hVIPMenu.GetItem(iOption, SZF(szFeature), iStyle);
			
			DebugMessage("MenuAction_DrawItem: Client: %i, Feature: %s, iStyle: %i", iClient, szFeature, iStyle)
			
			if (GLOBAL_TRIE.GetValue(szFeature, hBuffer))
			{
				if (view_as<VIP_ValueType>(hBuffer.Get(FEATURES_VALUE_TYPE)) != VIP_NULL && Features_GetStatus(iClient, szFeature) == NO_ACCESS)
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
					Call_PushString(szFeature);
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
			g_hVIPMenu.GetItem(iOption, SZF(szFeature));
			
			DebugMessage("MenuAction_DisplayItem: Client: %i, Feature: %s", iClient, szFeature)

			static char szDisplay[128];
			if (strcmp(szFeature, "NO_FEATURES") == 0)
			{
				FormatEx(SZF(szDisplay), "%T", "NO_FEATURES", iClient);
				return RedrawMenuItem(szDisplay);
			}

			if (GLOBAL_TRIE.GetValue(szFeature, hBuffer))
			{
				DataPack hDataPack = view_as<DataPack>(hBuffer.Get(FEATURES_MENU_CALLBACKS));
				hDataPack.Position = ITEM_DISPLAY;
				fCallback = hDataPack.ReadFunction();
				if (fCallback != INVALID_FUNCTION)
				{
					hPlugin = view_as<Handle>(hBuffer.Get(FEATURES_PLUGIN));

					bool bResult;
					Call_StartFunction(hPlugin, fCallback);
					Call_PushCell(iClient);
					Call_PushString(szFeature);
					Call_PushStringEx(SZF(szDisplay), SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
					Call_PushCell(sizeof(szDisplay));
					Call_Finish(bResult);
					
					DebugMessage("Function_Display: bResult: %b", bResult)
					
					if (bResult)
					{
						return RedrawMenuItem(szDisplay);
					}
				}

				if(IsTranslationPhraseExists(szFeature))
				{
					FormatEx(SZF(szDisplay), "%T", szFeature, iClient);
				}
				else
				{
					strcopy(SZF(szDisplay), szFeature);
				}

				if (view_as<VIP_FeatureType>(hBuffer.Get(FEATURES_ITEM_TYPE)) == TOGGLABLE)
				{
					FormatEx(SZF(szDisplay), "%s [%T]", szDisplay, g_szToggleStatus[view_as<int>(Features_GetStatus(iClient, szFeature))], iClient);
				}
				
				return RedrawMenuItem(szDisplay);
			}
		}
		
		case MenuAction_Select:
		{
			g_hVIPMenu.GetItem(iOption, SZF(szFeature));
			
			if (GLOBAL_TRIE.GetValue(szFeature, hBuffer))
			{
				PlaySound(iClient, ITEM_TOGGLE_SOUND);
				DebugMessage("MenuAction_Select: Client: %i, Feature: %s", iClient, szFeature)
				
				DataPack hDataPack = view_as<DataPack>(hBuffer.Get(FEATURES_MENU_CALLBACKS));
				hDataPack.Position = ITEM_SELECT;
				fCallback = hDataPack.ReadFunction();
				hPlugin = view_as<Handle>(hBuffer.Get(FEATURES_PLUGIN));
				if (view_as<VIP_FeatureType>(hBuffer.Get(FEATURES_ITEM_TYPE)) == TOGGLABLE)
				{
					char szBuffer[4];
					VIP_ToggleState eOldStatus, eNewStatus;

					eOldStatus = Features_GetStatus(iClient, szFeature);
					eNewStatus = (eOldStatus == ENABLED) ? DISABLED:ENABLED;
					if (fCallback != INVALID_FUNCTION)
					{
						eNewStatus = Function_OnItemToggle(hPlugin, fCallback, iClient, szFeature, eOldStatus, eNewStatus);
					}

					if (eNewStatus != eOldStatus)
					{
						eNewStatus = CreateForward_OnFeatureToggle(iClient, szFeature, eOldStatus, eNewStatus);
						if (eNewStatus != eOldStatus)
						{
							Features_SetStatus(iClient, szFeature, eNewStatus);
							IntToString(view_as<int>(eNewStatus), SZF(szBuffer));
							SetClientCookie(iClient, view_as<Handle>(GetArrayCell(hBuffer, FEATURES_COOKIE)), szBuffer);
						}
					}

					hMenu.DisplayAt(iClient, hMenu.Selection, MENU_TIME_FOREVER);
					return 0;
				}

				g_hFeatures[iClient].SetValue(KEY_MENUITEM, hMenu.Selection);
				if (Function_OnItemSelect(hPlugin, fCallback, iClient, szFeature))
				{
					hMenu.DisplayAt(iClient, hMenu.Selection, MENU_TIME_FOREVER);
				}
			}
		}
	}
	
	return 0;
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

bool IsTranslationPhraseExists(const char[] szPhrase)
{
	if (g_bIsTranslationPhraseExistsAvailable)
	{
		return TranslationPhraseExists(szPhrase);
	}

	return true;
}
