void Features_TurnOffAll(int iClient)
{
	DebugMessage("Features_TurnOffAll %N (%i)", iClient, iClient);
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
		GetArrayString(g_hFeaturesArray, i, SZF(szFeature));
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
	SetTrieValue(g_hFeatureStatus[iClient], szFeature, eStatus);
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