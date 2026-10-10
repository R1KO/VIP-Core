void Features_TurnOffAll(int iClient)
{
	DebugMessage("Features_TurnOffAll %N (%i)", iClient, iClient);
	if(!(g_iClientInfo[iClient] & IS_VIP))
		return;

	int iFeatures = g_hFeaturesArray.Length;
	if(iFeatures == 0)
		return;

	char szFeature[FEATURE_NAME_LENGTH];
	VIP_ToggleState eOldStatus;
	Function Function_Toggle;
	ArrayList hArray;
	DataPack hDataPack;

	for(int i = 0; i < iFeatures; ++i)
	{
		g_hFeaturesArray.GetString(i, SZF(szFeature));
		if(!GLOBAL_TRIE.GetValue(szFeature, hArray))
			continue;

		if(view_as<VIP_FeatureType>(hArray.Get(FEATURES_ITEM_TYPE)) != TOGGLABLE)
			continue;

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

void Features_TurnOnAll(int iClient)
{
	DebugMessage("Features_TurnOnAll %N (%i)", iClient, iClient);

	int iFeatures = g_hFeaturesArray.Length;
	if(iFeatures == 0)
		return;

	char szFeature[FEATURE_NAME_LENGTH];
	VIP_ToggleState eNewStatus;
	Function Function_Toggle;
	ArrayList hArray;
	DataPack hDataPack;

	for(int i = 0; i < iFeatures; ++i)
	{
		g_hFeaturesArray.GetString(i, SZF(szFeature));
		if(!GLOBAL_TRIE.GetValue(szFeature, hArray))
			continue;

		if(view_as<VIP_FeatureType>(hArray.Get(FEATURES_ITEM_TYPE)) != TOGGLABLE)
			continue;

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

void Features_SetStatus(int iClient, const char[] szFeature, VIP_ToggleState eStatus)
{
	DebugMessage("Features_SetStatus: %N (%i) -> Feature: %s, eStatus: %i", iClient, iClient, szFeature, eStatus);
	g_hFeatureStatus[iClient].SetValue(szFeature, eStatus);
}

VIP_ToggleState Features_GetStatus(const int &iClient, const char[] szFeature)
{
	static VIP_ToggleState eStatus;
	if(g_hFeatureStatus[iClient].GetValue(szFeature, eStatus))
	{
		DebugMessage("Features_GetStatus: %N (%i) -> Feature: %s, eStatus: %i", iClient, iClient, szFeature, eStatus);
		return eStatus;
	}
	
	DebugMessage("Features_GetStatus: %N (%i) -> Feature: %s, eStatus: %i", iClient, iClient, szFeature, NO_ACCESS);
	return NO_ACCESS;
}
// Toggle statuses persist in clientprefs cookies (USE_CLIENTPREFS 1) or in the VIP storage (USE_CLIENTPREFS 0).
// In storage mode cookies are still read once to migrate statuses saved by older versions.
bool Features_IsStatusStoreReady(int iClient)
{
	#if USE_CLIENTPREFS
	return AreClientCookiesCached(iClient);
	#else
	return Storage_IsClientLoaded(iClient) && AreClientCookiesCached(iClient);
	#endif
}

void Features_GetSavedStatus(int iClient, const char[] szFeature, ArrayList hArray, char[] szValue, int iMaxLength)
{
	Cookie hCookie = view_as<Cookie>(hArray.Get(FEATURES_COOKIE));

	#if USE_CLIENTPREFS
	#pragma unused szFeature
	hCookie.Get(iClient, szValue, iMaxLength);
	#else
	char szKey[STORAGE_KEY_LENGTH];
	Features_GetStorageKey(szFeature, SZF(szKey));
	if (!Storage_GetClientValue(iClient, szKey, szValue, iMaxLength) && hCookie && AreClientCookiesCached(iClient))
	{
		hCookie.Get(iClient, szValue, iMaxLength);
		if (szValue[0])
		{
			Storage_SetClientValue(iClient, szKey, szValue);
		}
	}
	#endif
}

void Features_SaveStatus(int iClient, const char[] szFeature, ArrayList hArray, VIP_ToggleState eStatus)
{
	char szValue[4];
	IntToString(view_as<int>(eStatus), SZF(szValue));

	#if USE_CLIENTPREFS
	#pragma unused szFeature
	view_as<Cookie>(hArray.Get(FEATURES_COOKIE)).Set(iClient, szValue);
	#else
	#pragma unused hArray
	char szKey[STORAGE_KEY_LENGTH];
	Features_GetStorageKey(szFeature, SZF(szKey));
	Storage_SetClientValue(iClient, szKey, szValue);
	#endif
}

#if !USE_CLIENTPREFS
// Same key format as 3.1-dev, so statuses saved there are picked up
void Features_GetStorageKey(const char[] szFeature, char[] szKey, int iMaxLength)
{
	FormatEx(szKey, iMaxLength, "FeatureStatus-%s", szFeature);
}
#endif
