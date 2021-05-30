
bool IsValidFeature(const char[] szFeature)
{
	DebugMessage("IsValidFeature:: FindStringInArray -> %i", g_hFeaturesArray.FindString(szFeature))
	return (g_hFeaturesArray.FindString(szFeature) != -1);
}

void Features_TurnOffAll(int iClient)
{
	DebugMessage("Features_TurnOffAll %N (%i)", iClient, iClient)
	int iFeaturesCount = g_hFeaturesArray.Length;
	if(!iFeaturesCount)
	{
		return;
	}
	char				szFeature[FEATURE_NAME_LENGTH];
	VIP_ToggleState		eOldStatus;
	Function			Function_Toggle;
	ArrayList			hArray;
	DataPack			hDataPack;

	for(int i = 0; i < iFeaturesCount; ++i)
	{
		g_hFeaturesArray.GetString(i, SZF(szFeature));
		if(GLOBAL_TRIE.GetValue(szFeature, hArray))
		{
			if(view_as<VIP_FeatureType>(hArray.Get(FEATURES_ITEM_TYPE)) == TOGGLABLE)
			{
				eOldStatus = Features_GetStatus(iClient, szFeature);
				hDataPack = view_as<DataPack>(hArray.Get(FEATURES_MENU_CALLBACKS));
				hDataPack.Position = ITEM_SELECT;
				Function_Toggle = hDataPack.ReadFunction();
				if(Function_Toggle != INVALID_FUNCTION)
				{
					Function_OnItemToggle(view_as<Handle>(hArray.Get(FEATURES_PLUGIN)), Function_Toggle, iClient, szFeature, eOldStatus, NO_ACCESS);
				}
			}
		}
	}
}

void Features_TurnOnAll(int iClient)
{
	DebugMessage("Features_TurnOnAll %N (%i)", iClient, iClient)

	int iFeaturesCount = g_hFeaturesArray.Length;
	if(iFeaturesCount != 0)
	{
		char				szFeature[FEATURE_NAME_LENGTH];
		VIP_ToggleState		eNewStatus;
		Function			Function_Toggle;
		ArrayList			hArray;
		DataPack			hDataPack;

		for(int i = 0; i < iFeaturesCount; ++i)
		{
			GetArrayString(g_hFeaturesArray, i, SZF(szFeature));
			if(GetTrieValue(GLOBAL_TRIE, szFeature, hArray))
			{
				if(view_as<VIP_FeatureType>(hArray.Get(FEATURES_ITEM_TYPE)) == TOGGLABLE)
				{
					hDataPack = view_as<DataPack>(hArray.Get(FEATURES_MENU_CALLBACKS));
					hDataPack.Position = ITEM_SELECT;
					Function_Toggle = hDataPack.ReadFunction();
					if(Function_Toggle != INVALID_FUNCTION)
					{
						eNewStatus = Features_GetStatus(iClient, szFeature);
						if(eNewStatus != NO_ACCESS)
						{
							Function_OnItemToggle(view_as<Handle>(hArray.Get(FEATURES_PLUGIN)), Function_Toggle, iClient, szFeature, NO_ACCESS, eNewStatus);
						}
					}
				}
			}
		}
	}
}

void Features_SetStatus(int iClient, const char[] szFeature, VIP_ToggleState eStatus)
{
	DebugMessage("Features_SetStatus: %N (%i) -> Feature: %s, eStatus: %i", iClient, iClient, szFeature, eStatus)
	SetTrieValue(g_hFeatureStatus[iClient], szFeature, eStatus);
}

VIP_ToggleState Features_GetStatus(const int &iClient, const char[] szFeature)
{
	static VIP_ToggleState eStatus;
	if(g_hFeatureStatus[iClient].GetValue(szFeature, eStatus))
	{
		DebugMessage("Features_GetStatus: %N (%i) -> Feature: %s, eStatus: %i", iClient, iClient, szFeature, eStatus)
		return eStatus;
	}
	
	DebugMessage("Features_GetStatus: %N (%i) -> Feature: %s, eStatus: %i", iClient, iClient, szFeature, NO_ACCESS)

	return NO_ACCESS;
}


#if USE_CLIENTPREFS == 0
void Features_GetStorageKeyName(const char[] szFeature, char[] szValue, int iMaxLength)
{
	FormatEx(szValue, iMaxLength, "FeatureStatus-%s", szFeature);
}
#endif

void Features_GetValueFromStorage(int iClient, const char[] szFeature, ArrayList hArray, char[] szValue, int iMaxLength)
{
	#if USE_CLIENTPREFS 1
	Handle hCookie = view_as<Handle>(hArray.Get(FEATURES_COOKIE));
	GetClientCookie(iClient, hCookie, szValue, iMaxLength);
	#else
	char szKey[128];
	Features_GetStorageKeyName(szFeature, SZF(szKey));
	Storage_GetClientValue(iClient, szKey, szValue, iMaxLength);
	#endif

}

void Features_SetValueToStorage(int iClient, const char[] szFeature, ArrayList hArray, const char[] szValue)
{
	#if USE_CLIENTPREFS 1
	SetClientCookie(iClient, szValue);
	#else
	char szKey[128];
	Features_GetStorageKeyName(szFeature, SZF(szKey));
	Storage_SetClientValue(iClient, szKey, szValue);
	#endif
}

VIP_ToggleState Features_GetStatusFromStorage(int iClient, const char[] szFeature, ArrayList hArray)
{
	char szValue[4];
	Features_GetValueFromStorage(iClient, szFeature, hArray, SZF(szValue));
	VIP_ToggleState eStatus = view_as<VIP_ToggleState>(StringToInt(szValue));
	if (szValue[0] == '\0' || (view_as<int>(eStatus) > 2 || view_as<int>(eStatus) < 0))
	{
		switch(hArray.Get(FEATURES_DEF_STATUS))
		{
			case NO_ACCESS:		eStatus = g_CVAR_bDefaultStatus ? ENABLED:DISABLED;
			case ENABLED:		eStatus = ENABLED;
			case DISABLED:		eStatus = DISABLED;
		}
	}

	return eStatus;
}

void Features_SetStatusToStorage(int iClient, const char[] szFeature, ArrayList hArray, VIP_ToggleState eStatus)
{
	char szValue[4];
	IntToString(view_as<int>(eStatus), SZF(szValue));
	Features_SetValueToStorage(iClient, szFeature, hArray, szValue);
}
