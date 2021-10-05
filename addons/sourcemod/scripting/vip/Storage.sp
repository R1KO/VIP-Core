
#define IS_CLIENT_CACHE_LOADED(%0)	g_bIsCacheLoaded[%0]

static bool g_bIsCacheLoaded[MPL+1];

bool Storage_IsClientLoaded(int iClient)
{
	DBG_STORAGE("Storage_IsClientLoaded: %N (%d): %b", iClient, iClient, IS_CLIENT_CACHE_LOADED(iClient) && g_hCache[iClient])
	return IS_CLIENT_CACHE_LOADED(iClient) && g_hCache[iClient];
}

void Storage_SetClientValue(int iClient, const char[] szKey, const char[] szValue)
{
	if (Storage_IsClientLoaded(iClient))
	{
		g_hCache[iClient].SetString(szKey, szValue);
	}
}

void Storage_GetClientValue(int iClient, const char[] szKey, char[] szValue, int iMaxLength)
{
	if (Storage_IsClientLoaded(iClient))
	{
		g_hCache[iClient].GetString(szKey, szValue, iMaxLength);
	}
}

void Storage_LoadClient(int iClient)
{
	char szQuery[256];

	int iAccountID = GetSteamAccountID(iClient);
	DBG_STORAGE("Storage_LoadClient: %N (%d): %d", iClient, iClient, iAccountID)

	FormatEx(SZF(szQuery), "SELECT `key`, `value` \
										FROM `vip_storage` \
										WHERE `account_id` = %d%s;",
										iAccountID, g_szSID);

	DBG_SQL_Query(szQuery)
	g_hDatabase.Query(SQL_Callback_OnClientLoadStorage, szQuery, UID(iClient));
}

public void SQL_Callback_OnClientLoadStorage(Database hOwner, DBResultSet hResult, const char[] szError, any iUserID)
{
	DBG_SQL_Response("SQL_Callback_OnClientLoadStorage")
	if (hResult == null || szError[0])
	{
		LogError("SQL_Callback_OnClientLoadStorage: %s", szError);
		return;
	}
	
	int iClient = CID(iUserID);
	if (!iClient || !IsClientInGame(iClient))
	{
		return;
	}

	g_hCache[iClient] = new StringMap();

	DBG_STORAGE("SQL_Callback_OnClientLoadStorage: %N (%d)", iClient, iClient)
	DBG_STORAGE("RowCount: %d", hResult.RowCount)
	if (!hResult.RowCount)
	{
		Storage_OnClientLoaded(iClient);
		return;
	}

	char szKey[128], szValue[256];

	while (hResult.FetchRow())
	{
		hResult.FetchString(0, SZF(szKey));
		hResult.FetchString(1, SZF(szValue));
		DBG_STORAGE("SetString: '%s' -> '%s'", szKey, szValue)

		g_hCache[iClient].SetString(szKey, szValue);
	}

	Storage_OnClientLoaded(iClient);
}

void Storage_OnClientLoaded(int iClient)
{
	g_bIsCacheLoaded[iClient] = true;

	CallForward_OnClientStorageLoaded(iClient);
}

void Storage_ResetClient(int iClient)
{
	DBG_STORAGE("Storage_ResetClient: %N (%d)", iClient, iClient)

	if (g_hCache[iClient])
	{
		delete g_hCache[iClient];
		g_hCache[iClient] = null;
	}

	g_bIsCacheLoaded[iClient] = false;
}

void Storage_SaveClient(int iClient)
{
	DBG_STORAGE("Storage_SaveClient: %N (%d)", iClient, iClient)

	if (!Storage_IsClientLoaded(iClient) || !g_hCache[iClient])
	{
		return;
	}
	int iAccountID = GetSteamAccountID(iClient);
	int iUpdated = GetTime();

	StringMapSnapshot hStorageSnapshot = g_hCache[iClient].Snapshot();

	char szKey[128], szValue[256];

	for(int i = 0, iSize = hStorageSnapshot.Length; i < iSize; ++i)
	{
		hStorageSnapshot.GetKey(i, SZF(szKey));
		g_hCache[iClient].GetString(szKey, SZF(szValue));
		DBG_STORAGE("GetString: '%s' -> '%s'", szKey, szValue)


		Storage_SaveClientValue(iAccountID, szKey, szValue, iUpdated);
	}

	delete hStorageSnapshot;
}

void Storage_SaveClientValue(int iAccountID, const char[] szKey, const char[] szValue, int iUpdated)
{
	char szQuery[512];
	if (GLOBAL_INFO & IS_MySQL)
	{
		g_hDatabase.Format(SZF(szQuery), "INSERT INTO `vip_storage` (`account_id`, `sid`, `key`, `value`, `updated`) \
			VALUES (%d, %d, \"%s\", \"%s\", %d)	\
			ON DUPLICATE KEY UPDATE \
			`value` = \"%s\", `updated` = %d;",
			iAccountID, g_CVAR_iServerID, szKey, szValue, iUpdated, szValue, iUpdated);
	}
	else
	{
		g_hDatabase.Format(SZF(szQuery), "INSERT OR REPLACE INTO `vip_storage` (`account_id`, `key`, `value`, `updated`) \
			VALUES (%d, \"%s\", \"%s\", %d);",
			iAccountID, szKey, szValue, iUpdated);
	}

	DBG_SQL_Query(szQuery)
	g_hDatabase.Query(SQL_Callback_OnClientSaveStorage, szQuery);
}

public void SQL_Callback_OnClientSaveStorage(Database hOwner, DBResultSet hResult, const char[] szError, any iData)
{
	DBG_SQL_Response("SQL_Callback_OnClientSaveStorage")
	if (hResult == null || szError[0])
	{
		LogError("SQL_Callback_OnClientSaveStorage: %s", szError);
		return;
	}
}

// TODO: add clear outdated

