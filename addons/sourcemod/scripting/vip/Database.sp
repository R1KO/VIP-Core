void DB_OnPluginStart()
{
	DB_Connect();
}

void DB_Connect()
{
	//	DebugMessage("DB_Connect: %b", g_bIsVIPLoaded)
	DebugMessage("DB_Connect")
	
	if (GLOBAL_INFO & IS_LOADING)
	{
		return;
	}

	if (g_hDatabase != null)
	{
		UNSET_BIT(GLOBAL_INFO, IS_LOADING);
		return;
	}
	
	SET_BIT(GLOBAL_INFO, IS_LOADING);

	if (SQL_CheckConfig("vip")) // "vip_core"
	{
		Database.Connect(OnDBConnect, "vip", 0);
	}
	else
	{
		KeyValues hKeyValues = new KeyValues(NULL_STRING);
		hKeyValues.SetString("driver", "sqlite");
		hKeyValues.SetString("database", "vip");

		char szError[256];
		g_hDatabase = SQL_ConnectCustom(hKeyValues, SZF(szError), false);

		delete hKeyValues;
	
		OnDBConnect(g_hDatabase, szError, 1);
	}
}

public void OnDBConnect(Database hDatabase, const char[] szError, any data)
{
	if (hDatabase == null || szError[0])
	{
		SetFailState("OnDBConnect %s", szError);
		UNSET_BIT(GLOBAL_INFO, IS_MySQL);
	//	CreateTimer(5.0, Timer_DB_Reconnect);
		return;
	}

	g_hDatabase = hDatabase;
	
	if (data == 1)
	{
		UNSET_BIT(GLOBAL_INFO, IS_MySQL);
	}
	else
	{
		char szDriver[8];
		g_hDatabase.Driver.GetIdentifier(SZF(szDriver));

		if (strcmp(szDriver, "mysql", false) == 0)
		{
			SET_BIT(GLOBAL_INFO, IS_MySQL);
		}
		else
		{
			UNSET_BIT(GLOBAL_INFO, IS_MySQL);
		}
	}
	
	DebugMessage("OnDBConnect %x, %u - > (MySQL: %b)", g_hDatabase, g_hDatabase, GLOBAL_INFO & IS_MySQL)
	
	CreateTables();
}

void CreateTables()
{
	DebugMessage("CreateTables")

	if (GLOBAL_INFO & IS_MySQL)
	{
		Transaction hTxn = new Transaction();
		
		hTxn.AddQuery("CREATE TABLE IF NOT EXISTS `vip_users` (\
					`account_id` INT NOT NULL, \
					`name` VARCHAR(64) NOT NULL default 'unknown', \
					`lastvisit` INT UNSIGNED NOT NULL default 0, \
					PRIMARY KEY (`account_id`) \
					) DEFAULT CHARSET=utf8;");

		hTxn.AddQuery("CREATE TABLE IF NOT EXISTS `vip_overrides` (\
					`uid` INT NOT NULL, \
					`sid` INT UNSIGNED NOT NULL, \
					`group` VARCHAR(64) NOT NULL, \
					`expires` INT UNSIGNED NOT NULL default 0, \
					PRIMARY KEY (`uid`, `sid`) \
					) DEFAULT CHARSET=utf8;");

		g_hDatabase.Execute(hTxn, SQL_OnTxnSuccess, SQL_OnTxnFailure);
	}
	else
	{
		g_hDatabase.Query(SQL_Callback_ErrorCheck,	"CREATE TABLE IF NOT EXISTS `vip_users` (\
				`account_id` INTEGER PRIMARY KEY NOT NULL, \
				`name` VARCHAR(64) NOT NULL default 'unknown', \
				`lastvisit` INTEGER UNSIGNED NOT NULL default 0, \
				`group` VARCHAR(64) NOT NULL, \
				`expires` INTEGER UNSIGNED NOT NULL default 0);");
	}

	UNSET_BIT(GLOBAL_INFO, IS_LOADING);

	OnReadyToStart();
	
	UTIL_ReloadVIPPlayers(0, false);
	
	if (g_CVAR_iDeleteExpired != -1)
	{
		RemoveExpiredPlayers();
	}
}

public void SQL_OnTxnFailure(Database hDb, any data, int numQueries, const char[] szError, int failIndex, any[] queryData)
{
	if (szError[0])
	{
		LogError("SQL_OnTxnFailure: %s", szError);
	}
}

public void SQL_OnTxnSuccess(Database hDb, any data, int numQueries, DBResultSet[] results, any[] queryData)
{
	g_hDatabase.Query(SQL_Callback_ErrorCheck, "SET NAMES 'utf8'");
	g_hDatabase.Query(SQL_Callback_ErrorCheck, "SET CHARSET 'utf8'");

	g_hDatabase.SetCharset("utf8");

	UNSET_BIT(GLOBAL_INFO, IS_LOADING);

	OnReadyToStart();
	
	UTIL_ReloadVIPPlayers(0, false);
	
	if (g_CVAR_iDeleteExpired != -1)
	{
		RemoveExpiredPlayers();
	}
}

public void SQL_Callback_ErrorCheck(Database hDB, DBResultSet hResult, const char[] szError, any data)
{
	if (szError[0])
	{
		LogError("SQL_Callback_ErrorCheck: %s", szError);
	}
}

void DB_UpdateClient(int iClient)
{
	int iClientID;
	g_hFeatures[iClient].GetValue(KEY_CID, iClientID);

	char szQuery[256];
	if (g_CVAR_bUpdateName)
	{
		char szName[MNL*2+1];
		GetClientName(iClient, szQuery, MNL);
		g_hDatabase.Escape(szQuery, SZF(szName));
		FormatEx(SZF(szQuery), "UPDATE `vip_users` SET `name` = '%s', `lastvisit` = %d WHERE `account_id` = %d LIMIT 1;", szName, GetTime(), iClientID);
	}
	else
	{
		FormatEx(SZF(szQuery), "UPDATE `vip_users` SET `lastvisit` = %d WHERE `account_id` = %d LIMIT 1;", GetTime(), iClientID);
	}

	DebugMessage(szQuery)
	g_hDatabase.Query(SQL_Callback_ErrorCheck, szQuery);
}

void DB_RemoveClientFromID(int iClient = 0, int iClientID, bool bNotify, const char[] szName = NULL_STRING)
{
	DebugMessage("DB_RemoveClientFromID %N (%d): - > iClientID: %d, : bNotify: %b", iClient, iClient, iClientID, bNotify)
	char szQuery[256];
	DataPack hDataPack = new DataPack();
	hDataPack.WriteCell(iClientID);
	hDataPack.WriteCell(bNotify);
	hDataPack.WriteCell(GET_UID(iClient));
	if(szName[0])
	{
		hDataPack.WriteString(szName);
		
		if (GLOBAL_INFO & IS_MySQL)
		{
			FormatEx(SZF(szQuery), "DELETE FROM `vip_overrides` WHERE `uid` = %d AND `sid` = %d;", iClientID, g_CVAR_iServerID);
		}
		else
		{
			FormatEx(SZF(szQuery), "DELETE FROM `vip_users` WHERE `account_id` = %d;", iClientID);
		}
		
		DebugMessage(szQuery)
		g_hDatabase.Query(SQL_Callback_RemoveClient, szQuery, hDataPack);
		return;
	}

	FormatEx(SZF(szQuery), "SELECT `name` FROM `vip_users` WHERE `account_id` = %d;", iClientID);
	DebugMessage(szQuery)
	g_hDatabase.Query(SQL_Callback_SelectRemoveClient, szQuery, hDataPack);
}

public void SQL_Callback_SelectRemoveClient(Database hDB, DBResultSet hResult, const char[] szError, any hPack)
{
	DataPack hDataPack = view_as<DataPack>(hPack);
	
	if (szError[0])
	{
		delete hDataPack;
		LogError("SQL_Callback_SelectRemoveClient: %s", szError);
		return;
	}
	
	if (hResult.FetchRow())
	{
		hDataPack.Reset();
		int iClientID = hDataPack.ReadCell();
		bool bNotify = view_as<bool>(hDataPack.ReadCell());
		int iClient = GET_CID(hDataPack.ReadCell());
		char szName[MAX_NAME_LENGTH*2+1];
		hResult.FetchString(0, SZF(szName));

		DB_RemoveClientFromID(iClient, iClientID, bNotify, szName);
	}

	delete hDataPack;
}

public void SQL_Callback_RemoveClient(Database hDB, DBResultSet hResult, const char[] szError, any hPack)
{
	DataPack hDataPack = view_as<DataPack>(hPack);

	if (szError[0])
	{
		delete hDataPack;
		LogError("SQL_Callback_RemoveClient: %s", szError);
		return;
	}

	if (hResult.AffectedRows)
	{
		hDataPack.Reset();
		
		int iClientID = hDataPack.ReadCell();
		bool bNotify = view_as<bool>(hDataPack.ReadCell());
		int iClient = GET_CID(hDataPack.ReadCell());
		char szName[MAX_NAME_LENGTH*2+1];
		hDataPack.ReadString(SZF(szName));
		
		if (GLOBAL_INFO & IS_MySQL)
		{
			char szQuery[256];
			FormatEx(SZF(szQuery), "SELECT COUNT(*) AS vip_count FROM `vip_overrides` WHERE `uid` = %d;", iClientID);
			g_hDatabase.Query(SQL_Callback_RemoveClient2, szQuery, iClientID);
		}
		
		if (g_CVAR_bLogsEnable)
		{
			LogToFile(g_szLogFile, "%T", "LOG_ADMIN_VIP_IDENTITY_DELETED", LANG_SERVER, iClient, szName, iClientID);
		}

		if (bNotify)
		{
			ReplyToCommand(iClient, "%t", "ADMIN_VIP_PLAYER_DELETED", szName, iClientID);
		}
	}
}

public void SQL_Callback_RemoveClient2(Database hDB, DBResultSet hResult, const char[] szError, any iClientID)
{
	if (szError[0])
	{
		LogError("SQL_Callback_RemoveClient: %s", szError);
		return;
	}
	
	if (hResult.FetchRow() && hResult.FetchInt(0) == 0)
	{
		char szQuery[256];
		FormatEx(SZF(szQuery), "DELETE FROM `vip_users` WHERE `account_id` = %d;", iClientID);

		g_hDatabase.Query(SQL_Callback_ErrorCheck, szQuery, iClientID);
	}
}

void RemoveExpiredPlayers()
{
	char szQuery[512];
	
	if (GLOBAL_INFO & IS_MySQL)
	{
		FormatEx(SZF(szQuery), "SELECT `uid`, `expires` FROM `vip_overrides` WHERE `sid` = %d;", 
			g_CVAR_iServerID);
	}
	else
	{
		FormatEx(SZF(szQuery), "SELECT `account_id`, `expires`, `group` FROM `vip_users`;");
	}
	
	DebugMessage(szQuery)
	g_hDatabase.Query(SQL_Callback_RemoveExpiredPlayers, szQuery);
}

public void SQL_Callback_RemoveExpiredPlayers(Database hDB, DBResultSet hResult, const char[] szError, any iData)
{
	if (szError[0])
	{
		LogError("SQL_Callback_RemoveExpiredPlayers: %s", szError);
		return;
	}
	
	DebugMessage("SQL_Callback_RemoveExpiredPlayers: %d", hResult.RowCount)
	if (hResult.RowCount)
	{
		int iExpires, iTime, iClientID;
		iTime = GetTime();
		while (hResult.FetchRow())
		{
			iExpires = hResult.FetchInt(1);
			if (iExpires && iTime > iExpires)
			{
				if (g_CVAR_iDeleteExpired == 0 || iTime >= ((g_CVAR_iDeleteExpired * 86400) + iExpires))
				{
					iClientID = hResult.FetchInt(0);
					DebugMessage("RemoveExpiredPlayers iClientID: %d", iClientID)
					
					DB_RemoveClientFromID(0, iClientID, false);
				}
			}
		}
	}
} 