/*
SetClientFeatureStatus(iClient, const String:sFeatureName[], VIP_ToggleState:Status = NO_ACCESS)
{
	SetTrieValue(g_hFeatureStatus[iClient], sFeatureName, VIP_ToggleState:Status);
}

VIP_ToggleState:GetClientFeatureStatus(iClient, const String:sFeatureName[])
{
	decl VIP_ToggleState:Status;
	return GetTrieValue(g_hFeatureStatus[iClient], sFeatureName, Status) ? Status:NO_ACCESS;
}


Features_ToggleFunctionAll(iClient, const VIP_ToggleState:OldStatus)
{
	new iFeatures = GetArraySize(GLOBAL_ARRAY);
	if(iFeatures != 0)
	{
		decl String:sFeatureName[FEATURE_NAME_LENGTH],
			i,
			Handle:hArray,
			Function:Function_Toggle;
			VIP_ToggleState:Status;
		
		for(i=0; i < iFeatures; ++i)
		{
			GetArrayString(GLOBAL_ARRAY, i, sFeatureName, sizeof(sFeatureName));
			if(GetTrieValue(GLOBAL_TRIE, sFeatureName, hArray))
			{
				if(VIP_FeatureType:GetArrayCell(hArray, FEATURES_ITEM_TYPE) == TOGGLABLE)
				{
					Function_Toggle = Function:GetArrayCell(hArray, FEATURES_ITEM_SELECT);
					if(Function_Toggle != INVALID_FUNCTION)
					{
						Status = Features_GetStatus(iClient, sFeatureName);
						if(Status != OldStatus)
						{
							Function_OnItemToggle(Handle:GetArrayCell(hArray, FEATURES_PLUGIN), Function_Toggle, iClient, sFeatureName, OldStatus, Status);
						}
					}
				}
			}
		}
	}
}
*/
Features_TurnOffAll(iClient)
{
	DebugMessage("Features_TurnOffAll %N (%i)", iClient, iClient)
	new iFeatures = GetArraySize(GLOBAL_ARRAY);
	if(iFeatures != 0)
	{
		decl String:sFeatureName[FEATURE_NAME_LENGTH],
			Handle:hArray,
			i,
			VIP_ToggleState:OldStatus,
			Function:Function_Toggle;
		
		for(i=0; i < iFeatures; ++i)
		{
			GetArrayString(GLOBAL_ARRAY, i, sFeatureName, sizeof(sFeatureName));
			if(GetTrieValue(GLOBAL_TRIE, sFeatureName, hArray))
			{
				if(VIP_FeatureType:GetArrayCell(hArray, FEATURES_ITEM_TYPE) == TOGGLABLE)
				{
					OldStatus = Features_GetStatus(iClient, sFeatureName);
				//	Features_SetStatus(iClient, sFeatureName, NO_ACCESS);
					Function_Toggle = Function:GetArrayCell(hArray, FEATURES_ITEM_SELECT);
					if(Function_Toggle != INVALID_FUNCTION)
					{
						Function_OnItemToggle(Handle:GetArrayCell(hArray, FEATURES_PLUGIN), Function_Toggle, iClient, sFeatureName, OldStatus, NO_ACCESS);
					}
				}
			}
		}
	}
}


Features_TurnOnAll(iClient)
{
	DebugMessage("Features_TurnOnAll %N (%i)", iClient, iClient)

	new iFeatures = GetArraySize(GLOBAL_ARRAY);
	if(iFeatures != 0)
	{
		decl String:sFeatureName[FEATURE_NAME_LENGTH],
			i,
			Handle:hArray,
			Function:Function_Toggle,
			VIP_ToggleState:Status;
		
		for(i=0; i < iFeatures; ++i)
		{
			GetArrayString(GLOBAL_ARRAY, i, sFeatureName, sizeof(sFeatureName));
			if(GetTrieValue(GLOBAL_TRIE, sFeatureName, hArray))
			{
				if(VIP_FeatureType:GetArrayCell(hArray, FEATURES_ITEM_TYPE) == TOGGLABLE)
				{
					Function_Toggle = Function:GetArrayCell(hArray, FEATURES_ITEM_SELECT);
					if(Function_Toggle != INVALID_FUNCTION)
					{
						Status = Features_GetStatus(iClient, sFeatureName);
						if(Status != NO_ACCESS)
						{
							Function_OnItemToggle(Handle:GetArrayCell(hArray, FEATURES_PLUGIN), Function_Toggle, iClient, sFeatureName, NO_ACCESS, Status);
						}
					}
				}
			}
		}
	}
}

Features_SetStatus(iClient, const String:sFeatureName[], const VIP_ToggleState:Status)
{
	DebugMessage("Features_SetStatus: %N (%i) -> Feature: %s, Status: %i", iClient, iClient, sFeatureName, Status)
	SetTrieValue(g_hFeatureStatus[iClient], sFeatureName, Status);
}

VIP_ToggleState:Features_GetStatus(iClient, const String:sFeatureName[])
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
/*
Features_SaveStatus(iClient, const String:sFeatureName[], Handle:hCookie, const VIP_ToggleState:Status)
{
	decl String:sStatus[4];
	IntToString(_:Status, sStatus, sizeof(sStatus));
	SetClientCookie(iClient, hCookie, sStatus);
}


VIP_ToggleState:ChangeToggleStatus(iClient, const String:sFeatureName[])
{
	new VIP_ToggleState:NewStatus = GetClientFeatureStatus(iClient, sFeatureName) == ENABLED ? DISABLED:ENABLED;

	return StartFunctionToggleFeature(iClient, sFeatureName, NewStatus);
}

VIP_ToggleState:StartFunctionToggleFeature(iClient, const String:sFeatureName[], VIP_ToggleState:NewStatus)
{
	decl Handle:hArray, VIP_ToggleState:ResultStatus;
	ResultStatus = NewStatus;
	if(GetTrieValue(GLOBAL_TRIE, sFeatureName, hArray))
	{
		decl any:DATA[FEATURES_SIZE];
		GetArrayArray(hArray, FEATURES_MAIN, DATA);
		if(bool:DATA[FEATURES_ITEM_TOGGLED] == true)
		{
			if (Function:DATA[FEATURES_ITEM_TOGGLE] != INVALID_FUNCTION)
			{
				Function_OnItemToggle(Handle:DATA[FEATURES_PLUGIN], Function:DATA[FEATURES_ITEM_TOGGLE], iClient, sFeatureName, NewStatus, ResultStatus);
			}

			SetClientFeatureStatus(iClient, sFeatureName, ResultStatus);
		} else LogError("Feature \"%s\" can't be switched!", sFeatureName);
	}
	return ResultStatus;
}


VIP_ToggleState:Function_OnItemToggle(Handle:hPlugin, Function:ItemToggle, iClient, const String:sFeatureName[], VIP_ToggleState:NewStatus)
{
	new VIP_ToggleState:ResultStatus = NewStatus; 
	Call_StartFunction(hPlugin, ItemToggle);
	Call_PushCell(iClient);
	Call_PushString(sFeatureName);
	Call_PushCell(NewStatus);
	Call_Finish(ResultStatus);
	
	return ResultStatus;
}*/