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
		char szError[256];
		g_hDatabase = SQLite_UseDatabase("vip_core", SZF(szError));
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
		#if USE_MORE_SERVERS 1
		FormatEx(SZF(g_szSID), " AND (`sid` = %d OR `sid` = 0)", g_CVAR_iServerID);
		#else
		FormatEx(SZF(g_szSID), " AND `sid` = %d", g_CVAR_iServerID);
		#endif
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
		g_szSID[0] = 0;
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

void RemoveExpAndOutPlayers()
{
	if (g_CVAR_iDeleteExpired >= 0)
	{
		char szQuery[256];
		FormatEx(SZF(szQuery), "SELECT `account_id`, `name`, `group` FROM `vip_users` WHERE `expires` > 0 AND `expires` < %d%s;", GetTime() - (g_CVAR_iDeleteExpired == 0 ? 1:g_CVAR_iDeleteExpired)*86400, g_szSID);

		DBG_SQL_Query(szQuery)
		g_hDatabase.Query(SQL_Callback_SelectExpiredAndOutdated, szQuery, REASON_EXPIRED);
	}

	if (g_CVAR_iOutdatedExpired > 0)
	{
		char szQuery[256];
		FormatEx(SZF(szQuery), "SELECT `account_id`, `name`, `group` FROM `vip_users` WHERE `lastvisit` > 0 AND `lastvisit` < %d%s;", (GetTime() - g_CVAR_iOutdatedExpired*86400), g_szSID);

		DBG_SQL_Query(szQuery)
		g_hDatabase.Query(SQL_Callback_SelectExpiredAndOutdated, szQuery, REASON_OUTDATED);
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

void DB_UpdateClient(int iClient, const char[] szDbName = NULL_STRING)
{
	int iClientID;
	g_hFeatures[iClient].GetValue(KEY_CID, iClientID);

	char szQuery[256];

	if (g_CVAR_bUpdateName || !strcmp(szDbName, "unknown"))
	{
		char szName[MNL*2+1];
		GetClientName(iClient, szQuery, MNL);
		g_hDatabase.Escape(szQuery, SZF(szName));
		FormatEx(SZF(szQuery), "UPDATE `vip_users` SET `name` = '%s', `lastvisit` = %d WHERE `account_id` = %d%s;", szName, GetTime(), iClientID, g_szSID);
	}
	else
	{
		FormatEx(SZF(szQuery), "UPDATE `vip_users` SET `lastvisit` = %d WHERE `account_id` = %d%s;", GetTime(), iClientID, g_szSID);
	}

	DBG_SQL_Query(szQuery)
	g_hDatabase.Query(SQL_Callback_ErrorCheck, szQuery);
}

void DB_RemoveClientFromID(int iAdmin = 0,
							int iClient = 0,
							int iClientID = 0,
							bool bNotify,
							const char[] szSourceName = NULL_STRING,
							const char[] szSourceGroup = NULL_STRING,
							const char[] szByWho = NULL_STRING)
{
	DebugMessage("DB_RemoveClientFromID %N (%d): - > iClientID: %d, : bNotify: %b", iClient, iClient, iClientID, bNotify)
	char szQuery[256], szName[MNL], szGroup[64];
	DataPack hDataPack = new DataPack();

	if(iClient)
	{
		if(szSourceName[0])
		{
			strcopy(SZF(szName), szSourceName);
		}
		else
		{
			GetClientName(iClient, SZF(szName));
		}

		if(szSourceGroup[0])
		{
			strcopy(SZF(szGroup), szSourceGroup);
		}
		else if(g_hFeatures[iClient])
		{
			g_hFeatures[iClient].GetString(KEY_GROUP, SZF(szGroup));

			if(!iClientID)
			{
				g_hFeatures[iClient].GetValue(KEY_CID, iClientID);
			}
		}
	}
	hDataPack.WriteCell(iClientID);
	hDataPack.WriteCell(GET_UID(iAdmin));
	hDataPack.WriteCell(bNotify);

	char szAdmin[PMP];
	switch(iAdmin)
	{
		case REASON_EXPIRED:
		{
			FormatEx(SZF(szAdmin), "%T", "REASON_EXPIRED", LANG_SERVER);
		}
		case REASON_OUTDATED:
		{
			FormatEx(SZF(szAdmin), "%T", "REASON_INACTIVITY", LANG_SERVER);
		}
		case REASON_PLUGIN:
		{
			FormatEx(SZF(szAdmin), "%T %s", "BY_PLUGIN", LANG_SERVER, szByWho);
		}
		case 0:
		{
			FormatEx(SZF(szAdmin), "%T", "BY_SERVER", LANG_SERVER);
		}
		default:
		{
			char szAdminInfo[128];
			UTIL_GetClientInfo(iAdmin, SZF(szAdminInfo));
			FormatEx(SZF(szAdmin), "%T %s", "BY_ADMIN", LANG_SERVER, szAdminInfo);
		}
	}

	hDataPack.WriteString(szAdmin);

	if(szName[0] && szGroup[0])
	{
		hDataPack.WriteString(szName);
		hDataPack.WriteString(szGroup);
		DB_RemoveClient(hDataPack, iClientID);
		return;
	}

	FormatEx(SZF(szQuery), "SELECT `name`, `group` FROM `vip_users` WHERE `account_id` = %d%s;", iClientID, g_szSID);

	DBG_SQL_Query(szQuery)
	g_hDatabase.Query(SQL_Callback_SelectRemoveClient, szQuery, hDataPack);
}

public void SQL_Callback_SelectRemoveClient(Database hOwner, DBResultSet hResult, const char[] szError, DataPack hPack)
{
	DBG_SQL_Response("SQL_Callback_SelectRemoveClient")

	if (szError[0])
	{
		delete hPack;
		LogError("SQL_Callback_SelectRemoveClient: %s", szError);
		return;
	}

	if (hResult.FetchRow())
	{
		DBG_SQL_Response("hResult.FetchRow()")
		hPack.Reset();
		int iClientID = hPack.ReadCell();
		hPack.ReadCell();
		hPack.ReadCell();
		char szName[MAX_NAME_LENGTH*2+1];
		hPack.ReadString(SZF(szName));
		hResult.FetchString(0, SZF(szName));
		DBG_SQL_Response("hResult.FetchString(0) = '%s", szName)
		hPack.WriteString(szName);
		hResult.FetchString(1, SZF(szName));
		DBG_SQL_Response("hResult.FetchString(1) = '%s", szName)
		hPack.WriteString(szName);

		DB_RemoveClient(hPack, iClientID);
	}
}

void DB_RemoveClient(DataPack hDataPack, int iClientID)
{
	char szQuery[256];
	FormatEx(SZF(szQuery), "DELETE FROM `vip_users` WHERE `account_id` = %d%s;", iClientID, g_szSID);

	DBG_SQL_Query(szQuery)
	g_hDatabase.Query(SQL_Callback_RemoveClient, szQuery, hDataPack);
}

public void SQL_Callback_RemoveClient(Database hOwner, DBResultSet hResult, const char[] szError, DataPack hPack)
{
	DBG_SQL_Response("SQL_Callback_SelectRemoveClient")

	if (szError[0])
	{
		delete hPack;
		LogError("SQL_Callback_RemoveClient: %s", szError);
		return;
	}

	DBG_SQL_Response("hResult.AffectedRows = %d", hResult.AffectedRows)

	if (hResult.AffectedRows)
	{
		hPack.Reset();
		
		int iClientID = hPack.ReadCell();
		int iAdmin = GET_CID(hPack.ReadCell());
		bool bNotify = view_as<bool>(hPack.ReadCell());
		char szAdmin[128], szName[MNL], szGroup[64];
		hPack.ReadString(SZF(szAdmin));
		hPack.ReadString(SZF(szName));
		hPack.ReadString(SZF(szGroup));

		if(iAdmin == -1)
		{
			return;
		}

		if (g_CVAR_bLogsEnable)
		{
			LogToFile(g_szLogFile, "%T", "LOG_VIP_DELETED", LANG_SERVER, szName, iClientID, szGroup, szAdmin);
		}

		if (bNotify && iAdmin > 0)
		{
			ReplyToCommand(iAdmin, "%t", "ADMIN_VIP_PLAYER_DELETED", szName, iClientID);
		}
	}

	delete hPack;
}

public void SQL_Callback_SelectExpiredAndOutdated(Database hOwner, DBResultSet hResult, const char[] szError, int iReason)
{
	DBG_SQL_Response("SQL_Callback_SelectExpiredAndOutdated")

	if (szError[0])
	{
		LogError("SQL_Callback_SelectExpiredAndOutdated: %s", szError);
		return;
	}
	
	DBG_SQL_Response("hResult.RowCount = %d", hResult.RowCount)

	if (hResult.RowCount)
	{
		int iClientID;
		char szName[MNL*2], szGroup[64];
		while (hResult.FetchRow())
		{
			DBG_SQL_Response("hResult.FetchRow()")
			iClientID = hResult.FetchInt(0);
			DBG_SQL_Response("hResult.FetchInt(0) = %d", iClientID)
			hResult.FetchString(1, SZF(szName));
			DBG_SQL_Response("hResult.FetchString(1) = '%s'", szName)
			hResult.FetchString(2, SZF(szGroup));
			DBG_SQL_Response("hResult.FetchString(2) = '%s'", szGroup)
			DB_RemoveClientFromID(iReason, _, iClientID, false, szName, szGroup);
		}
	}
}
