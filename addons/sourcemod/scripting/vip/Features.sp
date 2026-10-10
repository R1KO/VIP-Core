bool Features_Get(const char[] szFeature, Feature eFeature)
{
	return g_hFeatureRegistry.GetArray(szFeature, eFeature, sizeof(eFeature));
}

void Features_TurnOffAll(int iClient)
{
	DebugMessage("Features_TurnOffAll %N (%i)", iClient, iClient);
	if (!g_ePlayer[iClient].bVIP)
	{
		return;
	}

	int iFeatures = g_hFeaturesArray.Length;
	if (iFeatures == 0)
	{
		return;
	}

	char szFeature[FEATURE_NAME_LENGTH];
	Feature eFeature;

	for(int i = 0; i < iFeatures; ++i)
	{
		g_hFeaturesArray.GetString(i, SZF(szFeature));
		if (!Features_Get(szFeature, eFeature) || eFeature.eType != TOGGLABLE)
		{
			continue;
		}

		if (eFeature.fnSelect != INVALID_FUNCTION)
		{
			Function_OnItemToggle(eFeature.hPlugin, eFeature.fnSelect, iClient, szFeature, Features_GetStatus(iClient, szFeature), NO_ACCESS);
		}
	}
}

void Features_TurnOnAll(int iClient)
{
	DebugMessage("Features_TurnOnAll %N (%i)", iClient, iClient);

	int iFeatures = g_hFeaturesArray.Length;
	if (iFeatures == 0)
	{
		return;
	}

	char szFeature[FEATURE_NAME_LENGTH];
	Feature eFeature;
	VIP_ToggleState eNewStatus;

	for(int i = 0; i < iFeatures; ++i)
	{
		g_hFeaturesArray.GetString(i, SZF(szFeature));
		if (!Features_Get(szFeature, eFeature) || eFeature.eType != TOGGLABLE || eFeature.fnSelect == INVALID_FUNCTION)
		{
			continue;
		}

		eNewStatus = Features_GetStatus(iClient, szFeature);
		if (eNewStatus != NO_ACCESS)
		{
			Function_OnItemToggle(eFeature.hPlugin, eFeature.fnSelect, iClient, szFeature, NO_ACCESS, eNewStatus);
		}
	}
}

void Features_SetStatus(int iClient, const char[] szFeature, VIP_ToggleState eStatus)
{
	DebugMessage("Features_SetStatus: %N (%i) -> Feature: %s, eStatus: %i", iClient, iClient, szFeature, eStatus);
	g_ePlayer[iClient].hFeatureStatus.SetValue(szFeature, eStatus);
}

VIP_ToggleState Features_GetStatus(const int &iClient, const char[] szFeature)
{
	static VIP_ToggleState eStatus;
	if (g_ePlayer[iClient].hFeatureStatus.GetValue(szFeature, eStatus))
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

void Features_GetSavedStatus(int iClient, const char[] szFeature, Cookie hCookie, char[] szValue, int iMaxLength)
{
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

void Features_SaveStatus(int iClient, const char[] szFeature, Cookie hCookie, VIP_ToggleState eStatus)
{
	char szValue[4];
	IntToString(view_as<int>(eStatus), SZF(szValue));

	#if USE_CLIENTPREFS
	#pragma unused szFeature
	hCookie.Set(iClient, szValue);
	#else
	#pragma unused hCookie
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
