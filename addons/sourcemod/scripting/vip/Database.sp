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

	if (SQL_CheckConfig("vip_core")) // "vip_core"
	{
		Database.Connect(OnDBConnect, "vip_core", 0);
	}
	else
	{
		KeyValues hKeyValues = new KeyValues(NULL_STRING);
		hKeyValues.SetString("driver", "sqlite");
		hKeyValues.SetString("database", "vip_core");

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
		g_hDatabase.Query(SQL_Callback_TableCreate,	"CREATE TABLE IF NOT EXISTS `vip_users` (\
					`account_id` INT NOT NULL, \
					`name` VARCHAR(64) NOT NULL default 'unknown', \
					`lastvisit` INT UNSIGNED NOT NULL default 0, \
					`sid` INT UNSIGNED NOT NULL, \
					`group` VARCHAR(64) NOT NULL, \
					`expires` INT UNSIGNED NOT NULL default 0, \
					CONSTRAINT pk_PlayerID PRIMARY KEY (`account_id`, `sid`) \
					) DEFAULT CHARSET=utf8;");
	}
	else
	{
		g_hDatabase.Query(SQL_Callback_TableCreate,	"CREATE TABLE IF NOT EXISTS `vip_users` (\
				`account_id` INTEGER PRIMARY KEY NOT NULL, \
				`name` VARCHAR(64) NOT NULL default 'unknown', \
				`lastvisit` INTEGER UNSIGNED NOT NULL default 0, \
				`group` VARCHAR(64) NOT NULL, \
				`expires` INTEGER UNSIGNED NOT NULL default 0);");
	}
}

public void SQL_Callback_TableCreate(Database hOwner, DBResultSet hResult, const char[] szError, any data)
{
	DBG_SQL_Response("SQL_Callback_TableCreate")

	if (szError[0])
	{
		SetFailState("SQL_Callback_TableCreate: %s", szError);
		return;
	}

	if (GLOBAL_INFO & IS_MySQL)
	{
		g_hDatabase.Query(SQL_Callback_ErrorCheck, "SET NAMES 'utf8'");
		g_hDatabase.Query(SQL_Callback_ErrorCheck, "SET CHARSET 'utf8'");

		g_hDatabase.SetCharset("utf8");
	}

	UNSET_BIT(GLOBAL_INFO, IS_LOADING);

	OnReadyToStart();
	
	UTIL_ReloadVIPPlayers(0, false);
	
	if (g_CVAR_iDeleteExpired != -1 || g_CVAR_iOutdatedExpired != -1)
	{
		RemoveExpAndOutPlayers();
	}
}

public void SQL_Callback_ErrorCheck(Database hOwner, DBResultSet hResult, const char[] szError, any data)
{
	DBG_SQL_Response("SQL_Callback_ErrorCheck")

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

	DBG_SQL_Query(szQuery)
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
			FormatEx(SZF(szQuery), "DELETE FROM `vip_users` WHERE `account_id` = %d AND `sid` = %d;", iClientID, g_CVAR_iServerID);
		}
		else
		{
			FormatEx(SZF(szQuery), "DELETE FROM `vip_users` WHERE `account_id` = %d;", iClientID);
		}
		
		DBG_SQL_Query(szQuery)
		g_hDatabase.Query(SQL_Callback_RemoveClient, szQuery, hDataPack);
		return;
	}

	if (GLOBAL_INFO & IS_MySQL)
	{
		FormatEx(SZF(szQuery), "SELECT `name` FROM `vip_users` WHERE `account_id` = %d AND `sid` = %d;", iClientID, g_CVAR_iServerID);
	}
	else
	{
		FormatEx(SZF(szQuery), "SELECT `name` FROM `vip_users` WHERE `account_id` = %d;", iClientID);
	}

	DBG_SQL_Query(szQuery)
	g_hDatabase.Query(SQL_Callback_SelectRemoveClient, szQuery, hDataPack);
}

public void SQL_Callback_SelectRemoveClient(Database hOwner, DBResultSet hResult, const char[] szError, any hPack)
{
	DBG_SQL_Response("SQL_Callback_SelectRemoveClient")

	DataPack hDataPack = view_as<DataPack>(hPack);
	
	if (szError[0])
	{
		delete hDataPack;
		LogError("SQL_Callback_SelectRemoveClient: %s", szError);
		return;
	}
	
	if (hResult.FetchRow())
	{
		DBG_SQL_Response("hResult.FetchRow()")
		hDataPack.Reset();
		int iClientID = hDataPack.ReadCell();
		bool bNotify = view_as<bool>(hDataPack.ReadCell());
		int iClient = GET_CID(hDataPack.ReadCell());
		char szName[MAX_NAME_LENGTH*2+1];
		hResult.FetchString(0, SZF(szName));
		DBG_SQL_Response("hResult.FetchString(0) = '%s", szName)

		DB_RemoveClientFromID(iClient, iClientID, bNotify, szName);
	}

	delete hDataPack;
}

public void SQL_Callback_RemoveClient(Database hOwner, DBResultSet hResult, const char[] szError, any hPack)
{
	DBG_SQL_Response("SQL_Callback_SelectRemoveClient")

	DataPack hDataPack = view_as<DataPack>(hPack);

	if (szError[0])
	{
		delete hDataPack;
		LogError("SQL_Callback_RemoveClient: %s", szError);
		return;
	}

	DBG_SQL_Response("hResult.AffectedRows = %d", hResult.AffectedRows)

	if (hResult.AffectedRows)
	{
		hDataPack.Reset();
		
		int iClientID = hDataPack.ReadCell();
		bool bNotify = view_as<bool>(hDataPack.ReadCell());
		int iClient = GET_CID(hDataPack.ReadCell());
		char szName[MAX_NAME_LENGTH*2+1];
		hDataPack.ReadString(SZF(szName));

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

void RemoveExpAndOutPlayers()
{
	char szQuery[512];
	
	if (GLOBAL_INFO & IS_MySQL)
	{
		FormatEx(SZF(szQuery), "SELECT `account_id`, `expires`, `lastvisit` FROM `vip_users` WHERE `sid` = %d;", g_CVAR_iServerID);
	}
	else
	{
		FormatEx(SZF(szQuery), "SELECT `account_id`, `expires`, `lastvisit` FROM `vip_users`;");
	}
	
	DBG_SQL_Query(szQuery)
	g_hDatabase.Query(SQL_Callback_RemoveExpAndOutPlayers, szQuery);
}

public void SQL_Callback_RemoveExpAndOutPlayers(Database hOwner, DBResultSet hResult, const char[] szError, any iData)
{
	DBG_SQL_Response("SQL_Callback_RemoveExpAndOutPlayers")

	if (szError[0])
	{
		LogError("SQL_Callback_RemoveExpAndOutPlayers: %s", szError);
		return;
	}
	
	DBG_SQL_Response("hResult.RowCount = %d", hResult.RowCount)
	// if (g_CVAR_iDeleteExpired != -1 || g_CVAR_iOutdatedExpired != -1)

	if (hResult.RowCount)
	{
		int iExpires, iTime, iLastVisit, iClientID, iOutDated;
		iTime = GetTime();
		if (g_CVAR_iOutdatedExpired != -1)
		{
			iOutDated = iTime-(g_CVAR_iOutdatedExpired*86400);
		}
		while (hResult.FetchRow())
		{
			DBG_SQL_Response("hResult.FetchRow()")
			iClientID = hResult.FetchInt(0);
			DBG_SQL_Response("hResult.FetchInt(0) = %d", iClientID)
			if (g_CVAR_iDeleteExpired != -1)
			{
				iExpires = hResult.FetchInt(1);
				DBG_SQL_Response("hResult.FetchInt(1) = %d", iExpires)
				if (iExpires && iTime > iExpires)
				{
					if (g_CVAR_iDeleteExpired == 0 || iTime >= ((g_CVAR_iDeleteExpired * 86400) + iExpires))
					{
						DB_RemoveClientFromID(0, iClientID, false);
						continue;
					}
				}
			}
			if (g_CVAR_iOutdatedExpired != -1)
			{
				iLastVisit = hResult.FetchInt(2);
				DBG_SQL_Response("hResult.FetchInt(2) = %d", iLastVisit)
				if (iLastVisit && iOutDated > iLastVisit)
				{
					DB_RemoveClientFromID(0, iClientID, false);
				}
			}

			
		}
	}
}