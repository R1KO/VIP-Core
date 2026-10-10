// Per-player key/value storage (table `vip_storage`), ported from 3.1-dev.
// Loaded on connect for every player with a valid Steam account, saved on disconnect.

#define STORAGE_KEY_LENGTH		128
#define STORAGE_VALUE_LENGTH	256

static StringMap	g_hStorage[MAXPLAYERS+1];
static int			g_iStorageAccountID[MAXPLAYERS+1];
static bool			g_bStorageChanged[MAXPLAYERS+1];

bool Storage_IsClientLoaded(int iClient)
{
	return g_hStorage[iClient] != null;
}

void Storage_SetClientValue(int iClient, const char[] szKey, const char[] szValue)
{
	if (Storage_IsClientLoaded(iClient))
	{
		g_hStorage[iClient].SetString(szKey, szValue);
		g_bStorageChanged[iClient] = true;
	}
}

bool Storage_GetClientValue(int iClient, const char[] szKey, char[] szValue, int iMaxLength)
{
	szValue[0] = 0;
	return Storage_IsClientLoaded(iClient) && g_hStorage[iClient].GetString(szKey, szValue, iMaxLength);
}

void Storage_LoadClient(int iClient)
{
	if (!g_hDatabase || !(GLOBAL_INFO & IS_STARTED) || Storage_IsClientLoaded(iClient))
	{
		return;
	}

	// Not authorized yet: retried from OnClientAuthorized, never stored under account 0
	int iAccountID = GetSteamAccountID(iClient);
	if (!iAccountID)
	{
		return;
	}

	char szFilter[64], szQuery[256];
	Storage_GetServerFilter(SZF(szFilter));
	FormatEx(SZF(szQuery), "SELECT `key`, `value` FROM `vip_storage` WHERE `account_id` = %d%s;", iAccountID, szFilter);

	DataPack hDataPack = new DataPack();
	hDataPack.WriteCell(UID(iClient));
	hDataPack.WriteCell(iAccountID);

	DBG_SQL_Query(szQuery);
	g_hDatabase.Query(SQL_Callback_OnClientLoadStorage, szQuery, hDataPack);
}

public void SQL_Callback_OnClientLoadStorage(Database hOwner, DBResultSet hResult, const char[] szError, any hPack)
{
	DBG_SQL_Response("SQL_Callback_OnClientLoadStorage");

	DataPack hDataPack = view_as<DataPack>(hPack);
	hDataPack.Reset();
	int iClient = CID(hDataPack.ReadCell());
	int iAccountID = hDataPack.ReadCell();
	delete hDataPack;

	if (hResult == null || szError[0])
	{
		LogError("SQL_Callback_OnClientLoadStorage: %s", szError);
		return;
	}

	if (!iClient || !IsClientInGame(iClient) || Storage_IsClientLoaded(iClient))
	{
		return;
	}

	g_hStorage[iClient] = new StringMap();
	g_iStorageAccountID[iClient] = iAccountID;
	g_bStorageChanged[iClient] = false;

	char szKey[STORAGE_KEY_LENGTH], szValue[STORAGE_VALUE_LENGTH];
	while (hResult.FetchRow())
	{
		hResult.FetchString(0, SZF(szKey));
		hResult.FetchString(1, SZF(szValue));
		g_hStorage[iClient].SetString(szKey, szValue);
	}

	CreateForward_OnClientStorageLoaded(iClient);
}

// bSync: write right away (plugin unload, where async queries may never run)
void Storage_SaveClient(int iClient, bool bSync = false)
{
	if (!Storage_IsClientLoaded(iClient) || !g_bStorageChanged[iClient] || !g_hDatabase)
	{
		return;
	}

	bool bMySQL = view_as<bool>(GLOBAL_INFO & IS_MySQL);
	int iUpdated = GetTime();
	char szKey[STORAGE_KEY_LENGTH], szValue[STORAGE_VALUE_LENGTH], szQuery[1024];

	Transaction hTxn = null;
	if (bSync)
	{
		SQL_LockDatabase(g_hDatabase);
	}
	else
	{
		hTxn = new Transaction();
	}

	StringMapSnapshot hSnapshot = g_hStorage[iClient].Snapshot();
	for (int i = 0, iSize = hSnapshot.Length; i < iSize; ++i)
	{
		hSnapshot.GetKey(i, SZF(szKey));
		g_hStorage[iClient].GetString(szKey, SZF(szValue));

		// Database.Format escapes %s
		if (bMySQL)
		{
			g_hDatabase.Format(SZF(szQuery), "INSERT INTO `vip_storage` (`account_id`, `sid`, `key`, `value`, `updated`) \
				VALUES (%d, %d, '%s', '%s', %d) \
				ON DUPLICATE KEY UPDATE `value` = VALUES(`value`), `updated` = VALUES(`updated`);",
				g_iStorageAccountID[iClient], g_CVAR_iStorageID, szKey, szValue, iUpdated);
		}
		else
		{
			g_hDatabase.Format(SZF(szQuery), "INSERT OR REPLACE INTO `vip_storage` (`account_id`, `key`, `value`, `updated`) \
				VALUES (%d, '%s', '%s', %d);",
				g_iStorageAccountID[iClient], szKey, szValue, iUpdated);
		}

		DBG_SQL_Query(szQuery);
		if (bSync)
		{
			if (!SQL_FastQuery(g_hDatabase, szQuery))
			{
				SQL_GetError(g_hDatabase, SZF(szQuery));
				LogError("Storage_SaveClient: %s", szQuery);
			}
		}
		else
		{
			hTxn.AddQuery(szQuery);
		}
	}
	delete hSnapshot;

	if (bSync)
	{
		SQL_UnlockDatabase(g_hDatabase);
	}
	else
	{
		g_hDatabase.Execute(hTxn, _, SQL_TxnCallback_SaveStorageFailure);
	}
	g_bStorageChanged[iClient] = false;
}

public void SQL_TxnCallback_SaveStorageFailure(Database hDatabase, any data, int iNumQueries, const char[] szError, int iFailIndex, any[] queryData)
{
	LogError("SQL_TxnCallback_SaveStorageFailure (%d/%d): %s", iFailIndex, iNumQueries, szError);
}

public void OnPluginEnd()
{
	for (int iClient = 1; iClient <= MaxClients; ++iClient)
	{
		Storage_SaveClient(iClient, true);
	}
}

void Storage_ResetClient(int iClient)
{
	delete g_hStorage[iClient];
	g_iStorageAccountID[iClient] = 0;
	g_bStorageChanged[iClient] = false;
}

static void Storage_GetServerFilter(char[] szFilter, int iMaxLength)
{
	szFilter[0] = 0;
	if (GLOBAL_INFO & IS_MySQL)
	{
		FormatEx(szFilter, iMaxLength, " AND `sid` = %d", g_CVAR_iStorageID);
	}
}
