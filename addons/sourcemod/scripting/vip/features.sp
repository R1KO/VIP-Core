
void Features_TurnOffAll(int iClient)
{
	DebugMessage("Features_TurnOffAll %N (%i)", iClient, iClient)
	new iFeatures = GetArraySize(GLOBAL_ARRAY);
	if(iFeatures != 0)
	{
		char sFeatureName[FEATURE_NAME_LENGTH]; i,
			VIP_ToggleState:OldStatus,
			Function:Function_Toggle;
		
		ArrayList hArray;
		DataPack hDataPack;

		for(i=0; i < iFeatures; ++i)
		{
			GetArrayString(GLOBAL_ARRAY, i, sFeatureName, sizeof(sFeatureName));
			if(GetTrieValue(GLOBAL_TRIE, sFeatureName, hArray))
			{
				if(VIP_FeatureType:hArray.Get(FEATURES_ITEM_TYPE) == TOGGLABLE)
				{
					OldStatus = Features_GetStatus(iClient, sFeatureName);
					hDataPack = view_as<DataPack>(hArray.Get(FEATURES_MENU_CALLBACKS));
					hDataPack.Position = ITEM_SELECT;
					Function_Toggle = hDataPack.ReadFunction();
					if(Function_Toggle != INVALID_FUNCTION)
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

	new iFeatures = GetArraySize(GLOBAL_ARRAY);
	if(iFeatures != 0)
	{
		char sFeatureName[FEATURE_NAME_LENGTH]; i,
			Function:Function_Toggle,
			VIP_ToggleState:Status;
		
		ArrayList hArray;
		DataPack hDataPack;
	
		for(i=0; i < iFeatures; ++i)
		{
			GetArrayString(GLOBAL_ARRAY, i, sFeatureName, sizeof(sFeatureName));
			if(GetTrieValue(GLOBAL_TRIE, sFeatureName, hArray))
			{
				if(VIP_FeatureType:hArray.Get(FEATURES_ITEM_TYPE) == TOGGLABLE)
				{
					hDataPack = view_as<DataPack>(hArray.Get(FEATURES_MENU_CALLBACKS));
					hDataPack.Position = ITEM_SELECT;
					Function_Toggle = hDataPack.ReadFunction();
					if(Function_Toggle != INVALID_FUNCTION)
					{
						Status = Features_GetStatus(iClient, sFeatureName);
						if(Status != NO_ACCESS)
						{
							Function_OnItemToggle(view_as<Handle>(hArray.Get(FEATURES_PLUGIN)), Function_Toggle, iClient, sFeatureName, NO_ACCESS, Status);
						}
					}
				}
			}
		}
	}
}

void Features_SetStatus(int iClient, const char[] sFeatureName, const VIP_ToggleState Status)
{
	DebugMessage("Features_SetStatus: %N (%i) -> Feature: %s, Status: %i", iClient, iClient, sFeatureName, Status)
	SetTrieValue(g_hFeatureStatus[iClient], sFeatureName, Status);
}

VIP_ToggleState Features_GetStatus(int iClient, const char[] sFeatureName)
{
	static VIP_ToggleState:Status;
	if(GetTrieValue(g_hFeatureStatus[iClient], sFeatureName, Status))
	{
		DebugMessage("Features_GetStatus: %N (%i) -> Feature: %s, Status: %i", iClient, iClient, sFeatureName, Status)
		return Status;
	}
	
	DebugMessage("Features_GetStatus: %N (%i) -> Feature: %s, Status: %i", iClient, iClient, sFeatureName, NO_ACCESS)

	return NO_ACCESS;
}