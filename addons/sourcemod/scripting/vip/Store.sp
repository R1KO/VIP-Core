
StringMap g_hClientStoreCache[MPL+1];

void Store_InitClient(int iClient)
{
	g_hClientStoreCache[iClient] = new StringMap();
}

void Store_LoadClient(int iClient)
{
	char szQuery[PMP];
	int iAccountID = GetSteamAccountID(iClient);
	FormatEx(SZF(szQuery), "SELECT `key`, `value` FROM `vip_users_store` WHERE `account_id` = %d%s;", iAccountID, g_szSID);
	DBG_SQL_Query(szQuery)
	g_hDatabase.Query(SQL_Callback_OnClientLoadStore, szQuery, UID(iClient));
}

public void SQL_Callback_OnClientLoadStore(Database hOwner, DBResultSet hResult, const char[] szError, any iUserId)
{
	DBG_SQL_Response("SQL_Callback_OnClientLoadStore")
	if (hResult == null || szError[0])
	{
		LogError("SQL_Callback_OnClientLoadStore: %s", szError);
		return;
	}

	int iClient = CID(iUserId);

	if (!iClient || !IsClientInGame(iClient))
	{
		return;
	}

	Store_InitClient(iClient);

	if (hResult.RowCount)
	{

		char szKey[64], szValue[256];
		while (hResult.FetchRow())
		{
			hResult.FetchString(0, SZF(szKey));
			hResult.FetchString(1, SZF(szValue));
			g_hClientStoreCache[iClient].SetString(szKey, szValue);
		}
	}

	Clients_LoadVIPFeatures(iClient);
}

void Store_ClearClient(int iClient)
{
	if(g_hClientStoreCache[iClient])
	{
		delete g_hClientStoreCache[iClient];
		g_hClientStoreCache[iClient] = null;
	}
}

void Store_SaveClient(int iClient, bool bClearAfter = true)
{
	char szQuery[PMP*2];
	int iAccountID = GetSteamAccountID(iClient);

	StringMapSnapshot hTrieSnapshot = g_hClientStoreCache[iClient].Snapshot();
    int i, iSize;
    char szKey[32], szValue[256];
    iSize = hTrieSnapshot.Length;

    for(i = 0; i < iSize; ++i)
    {
        hTrieSnapshot.GetKey(i, SZF(szKey));
        hTrie.GetString(szKey, SZF(szValue));

		if (GLOBAL_INFO & IS_MySQL)
		{
			FormatEx(SZF(szQuery), "INSERT INTO `vip_users_store` (`account_id`, `key`, `value`, `sid`) VALUES (%d, '%s', '%s', %d) \
				 ON DUPLICATE KEY UPDATE `value` = '%s';", iAccountID, szKey, szValue, g_CVAR_iServerID, szValue);
		}
		else
		{
			FormatEx(SZF(szQuery), "INSERT OR REPLACE INTO `vip_users_store` (`account_id`, `key`, `value`) VALUES (%d, '%s', '%s');", iAccountID, szKey, szValue);
		}

		DBG_SQL_Query(szQuery)

		g_hDatabase.Query(SQL_Callback_ErrorCheck, szQuery);
    }

    if (bClearAfter)
    {
    	Store_ClearClient(iClient);
    }
}

void Store_SetClientValueString(const int &iClient, const char[] szKey, const char[] szValue)
{
	g_hClientStoreCache[iClient].SetString(szKey, szValue);
}

bool Store_GetClientValueString(const int &iClient, const char[] szKey, char[] szValue, const int &iMaxLen)
{
	return g_hClientStoreCache[iClient].GetString(szKey, szValue, iMaxLen);
}

void Store_SetClientValue(const int &iClient, const char[] szKey, const any &iValue)
{
	static char szValue[256];
	I2S(iValue, SZF(szValue));
	g_hClientStoreCache[iClient].GetString(szKey, SZF(szValue));
}

bool Store_GetClientValue(const int &iClient, const char[] szKey, any &iValue)
{
	static char szValue[256];
	if (!g_hClientStoreCache[iClient].GetString(szKey, SZF(szValue)))
	{
		return false;
	}

	StrintToIntEx(szValue, iValue);
	return true;
}

/*
Store_LoadClientValue


Store_SaveClientValues
Store_GetClientValues
Store_LoadClientValues
*/