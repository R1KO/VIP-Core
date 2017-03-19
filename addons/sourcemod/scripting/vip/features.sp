
void Features_TurnOffAll(int iClient)
{
	DebugMessage("Features_TurnOffAll %N (%i)", iClient, iClient)
	int iFeatures = g_hFeaturesArray.Length;
	if (iFeatures != 0)
	{
		char				sFeatureName[FEATURE_NAME_LENGTH];
		VIP_ToggleState		OldStatus;
		Function			Function_Toggle;
		ArrayList			hArray;
		DataPack			hDataPack;

		for (int i = 0; i < iFeatures; ++i)
		{
			g_hFeaturesArray.GetString(i, sFeatureName, sizeof(sFeatureName));
			if(GLOBAL_TRIE.GetValue(sFeatureName, hArray))
			{
				if(view_as<VIP_FeatureType>(hArray.Get(FEATURES_ITEM_TYPE)) == TOGGLABLE)
				{
					OldStatus = Features_GetStatus(iClient, sFeatureName);
					hDataPack = view_as<DataPack>(hArray.Get(FEATURES_MENU_CALLBACKS));
					hDataPack.Position = ITEM_SELECT;
					Function_Toggle = hDataPack.ReadFunction();
					if (Function_Toggle != INVALID_FUNCTION)
					{
						Function_OnItemToggle(view_as<Handle>(hArray.Get(FEATURES_PLUGIN)), Function_Toggle, iClient, sFeatureName, OldStatus, NO_ACCESS);
					}
				}
			}
		}
	}
}

void Features_TurnOnAll(int iClient)
{
	DebugMessage("Features_TurnOnAll %N (%i)", iClient, iClient)

	int iFeatures = g_hFeaturesArray.Length;
	if (iFeatures != 0)
	{
		char				sFeatureName[FEATURE_NAME_LENGTH];
		VIP_ToggleState		OldStatus;
		Function			Function_Toggle;
		ArrayList			hArray;
		DataPack			hDataPack;

		for (int i = 0; i < iFeatures; ++i)
		{
			g_hFeaturesArray.GetString(i, sFeatureName, sizeof(sFeatureName));
			if (GLOBAL_TRIE.GetValue(sFeatureName, hArray))
			{
				if(view_as<VIP_FeatureType>(hArray.Get(FEATURES_ITEM_TYPE)) == TOGGLABLE)
				{
					hDataPack = view_as<DataPack>(hArray.Get(FEATURES_MENU_CALLBACKS));
					hDataPack.Position = ITEM_SELECT;
					Function_Toggle = hDataPack.ReadFunction();
					if (Function_Toggle != INVALID_FUNCTION)
					{
						OldStatus = Features_GetStatus(iClient, sFeatureName);
						if(OldStatus != NO_ACCESS)
						{
							Function_OnItemToggle(view_as<Handle>(hArray.Get(FEATURES_PLUGIN)), Function_Toggle, iClient, sFeatureName, NO_ACCESS, OldStatus);
						}
					}
				}
			}
		}
	}
}

void Features_SetStatus(int iClient, const char[] sFeatureName, VIP_ToggleState Status)
{
	DebugMessage("Features_SetStatus: %N (%i) -> Feature: %s, Status: %i", iClient, iClient, sFeatureName, Status)
	g_hFeatureStatus[iClient].SetValue(sFeatureName, Status);
}

VIP_ToggleState Features_GetStatus(int iClient, const char[] sFeatureName)
{
	static VIP_ToggleState Status;
	if(g_hFeatureStatus[iClient].GetValue(sFeatureName, Status))
	{
		DebugMessage("Features_GetStatus: %N (%i) -> Feature: %s, Status: %i", iClient, iClient, sFeatureName, Status)
		return Status;
	}
	
	DebugMessage("Features_GetStatus: %N (%i) -> Feature: %s, Status: %i", iClient, iClient, sFeatureName, NO_ACCESS)
	
	return NO_ACCESS;
} 