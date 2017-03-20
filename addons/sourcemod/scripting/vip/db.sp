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

	if (SQL_CheckConfig("vip_core"))
	{
		Database.Connect(OnDBConnect, "vip_core", 0);
	}
	else
	{
		KeyValues hKeyValues = new KeyValues("");
		hKeyValues.SetString("driver", "sqlite");
		hKeyValues.SetString("database", "vip_core");

		char sError[256];
		g_hDatabase = SQL_ConnectCustom(hKeyValues, SZF(sError), false);

		delete hKeyValues;
	
		OnDBConnect(g_hDatabase, sError, 1);
	}
}

public void OnDBConnect(Database hDatabase, const char[] sError, any data)
{
	if (hDatabase == null || sError[0])
	{
		SetFailState("OnDBConnect %s", sError);
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
		char sDriver[8];
		g_hDatabase.Driver.GetIdentifier(SZF(sDriver));

		if (strcmp(sDriver, "mysql", false) == 0)
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
	SQL_LockDatabase(g_hDatabase);
	if (GLOBAL_INFO & IS_MySQL)
	{
		g_hDatabase.Query(SQL_Callback_ErrorCheck,	"CREATE TABLE IF NOT EXISTS `vip_users` (\
																		`id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT, \
																		`auth` VARCHAR(64) UNIQUE NOT NULL, \
																		`name` VARCHAR(64) NOT NULL default 'unknown', \
																		PRIMARY KEY (`id`), \
																		UNIQUE KEY `auth_id` (`auth`)) DEFAULT CHARSET=utf8 AUTO_INCREMENT=1;");

		g_hDatabase.Query(SQL_Callback_ErrorCheck,	"CREATE TABLE IF NOT EXISTS `vip_overrides` (\
																		`user_id` INT(10) UNSIGNED NOT NULL, \
																		`server_id` INT(10) UNSIGNED NOT NULL, \
																		`group` VARCHAR(64) default NULL, \
																		`expires` INT(10) UNSIGNED NOT NULL default '0', \
																		PRIMARY KEY (`user_id`, `server_id`), \
																		UNIQUE KEY `user_id` (`user_id`, `server_id`), \
																		CONSTRAINT `vip_overrides_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `vip_users` (`id`)  ON DELETE CASCADE ON UPDATE CASCADE\
																		) DEFAULT CHARSET=utf8;");

		SQL_FastQuery(g_hDatabase, "SET NAMES 'utf8'");
		SQL_FastQuery(g_hDatabase, "SET CHARSET 'utf8'");

		g_hDatabase.SetCharset("utf8");
	}
	else
	{
		g_hDatabase.Query(SQL_Callback_ErrorCheck,	"CREATE TABLE IF NOT EXISTS `vip_users` (\
																		`id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, \
																		`auth` VARCHAR(32) UNIQUE NOT NULL, \
																		`name` VARCHAR(64) NOT NULL default 'unknown', \
																		`group` VARCHAR(64) default NULL, \
																		`expires` INTEGER NOT NULL default '0');");
	}
	
	SQL_UnlockDatabase(g_hDatabase);
	
	UNSET_BIT(GLOBAL_INFO, IS_LOADING);

	OnReadyToStart();
	
	UTIL_ReloadVIPPlayers(0, false);
	
	if (g_CVAR_iDeleteExpired != -1)
	{
		RemoveExpiredPlayers();
	}
}

public void SQL_Callback_ErrorCheck(Handle hOwner, Handle hResult, const char[] sError, any data)
{
	if (sError[0])
	{
		LogError("SQL_Callback_ErrorCheck: %s", sError);
	}
}

void DB_UpdateClientName(int iClient)
{
//	SQL_FastQuery(g_hDatabase, "SET NAMES 'utf8'");

	char sQuery[256], sName[MAX_NAME_LENGTH*2+1];
	int iClientID;
	g_hFeatures[iClient].GetValue(KEY_CID, iClientID);
	GetClientName(iClient, sQuery, MAX_NAME_LENGTH);
	g_hDatabase.Escape(sQuery, SZF(sName));
	FormatEx(SZF(sQuery), "UPDATE `vip_users` SET `name` = '%s' WHERE `id` = '%i';", sName, iClientID);
	g_hDatabase.Query(SQL_Callback_ErrorCheck, sQuery);
}

void DB_RemoveClientFromID(int iClient = 0, int iClientID, bool bNotify)
{
	DebugMessage("DB_RemoveClientFromID %N (%i): - > iClientID: %i, : bNotify: %b", iClient, iClient, iClientID, bNotify)
	char sQuery[256];
	DataPack hDataPack = new DataPack();
	hDataPack.WriteCell(iClientID);
	hDataPack.WriteCell(bNotify);
	if (iClient)
	{
		hDataPack.WriteCell(UID(iClient));
	}
	else
	{
		hDataPack.WriteCell(0);
	}
	
	if (GLOBAL_INFO & IS_MySQL)
	{
		FormatEx(sQuery, sizeof(sQuery), "DELETE FROM `vip_overrides` WHERE `user_id` = '%i' AND `server_id` = '%i';", iClientID, g_CVAR_iServerID);
	}
	else
	{
		FormatEx(sQuery, sizeof(sQuery), "DELETE FROM `vip_users` WHERE `id` = '%i';", iClientID);
	}
	
	DebugMessage(sQuery)
	g_hDatabase.Query(SQL_Callback_RemoveClient, sQuery, hDataPack);
}

public void SQL_Callback_RemoveClient(Database hOwner, DBResultSet hResult, const char[] sError, any hPack)
{
	if (sError[0])
	{
		LogError("SQL_Callback_RemoveClient: %s", sError);
		return;
	}
	
	if (hResult.AffectedRows)
	{
		DataPack hDataPack = view_as<DataPack>(hPack);
		hDataPack.Reset();
		
		int iClientID = (view_as<DataPack>(hDataPack)).ReadCell();
		
		if (g_CVAR_bLogsEnable)
		{
			LogToFile(g_sLogFile, "%T", "ADMIN_VIP_PLAYER_DELETED", LANG_SERVER, iClientID);
			//	LogToFile(g_sLogFile, "%T", "ADMIN_VIP_PLAYER_DELETED", LANG_SERVER, iClient, iClientID);
		}
		
		if (GLOBAL_INFO & IS_MySQL)
		{
			char sQuery[256];
			FormatEx(sQuery, sizeof(sQuery), "SELECT COUNT(*) AS vip_count FROM `vip_overrides` WHERE `user_id` = '%i';", iClientID);
			g_hDatabase.Query(SQL_Callback_RemoveClient2, sQuery, iClientID);
		}
		
		if (hDataPack.ReadCell())
		{
			int iClient = (hDataPack).ReadCell();
			
			if (iClient)
			{
				iClient = CID(iClient);
				if (iClient == 0)
				{
					return;
				}
			}
			
			ReplyToCommand(iClient, "%t", "ADMIN_VIP_PLAYER_DELETED", iClientID);
		}
	}
}

public void SQL_Callback_RemoveClient2(Database hOwner, DBResultSet hResult, const char[] sError, any iClientID)
{
	if (sError[0])
	{
		LogError("SQL_Callback_RemoveClient: %s", sError);
		return;
	}
	
	if ((hResult).FetchRow() && hResult.FetchInt(0) == 0)
	{
		char sQuery[256];
		FormatEx(sQuery, sizeof(sQuery), "DELETE FROM `vip_users` WHERE `id` = '%i';", iClientID);

		g_hDatabase.Query(SQL_Callback_ErrorCheck, sQuery, iClientID);
	}
}

void RemoveExpiredPlayers()
{
	char sQuery[512];
	
	if (GLOBAL_INFO & IS_MySQL)
	{
		FormatEx(sQuery, sizeof(sQuery), "SELECT `user_id`, \
												`expires` \
												FROM `vip_overrides` \
												WHERE `server_id` = '%i';", 
			g_CVAR_iServerID);
	}
	else
	{
		FormatEx(sQuery, sizeof(sQuery), "SELECT `id`, `expires`, `group` FROM `vip_users`;");
	}
	
	DebugMessage(sQuery)
	g_hDatabase.Query(SQL_Callback_RemoveExpiredPlayers, sQuery);
}

public void SQL_Callback_RemoveExpiredPlayers(Database hOwner, DBResultSet hResult, const char[] sError, any iData)
{
	if (sError[0])
	{
		LogError("SQL_Callback_RemoveExpiredPlayers: %s", sError);
		return;
	}
	
	DebugMessage("SQL_Callback_RemoveExpiredPlayers: %i", (hResult).RowCount)
	if ((hResult).RowCount)
	{
		int iExpires, iTime, iClientID;
		iTime = GetTime();
		while ((hResult).FetchRow())
		{
			iExpires = hResult.FetchInt(1);
			if (iExpires && iTime > iExpires)
			{
				if (g_CVAR_iDeleteExpired == 0 || iTime >= ((g_CVAR_iDeleteExpired * 86400) + iExpires))
				{
					iClientID = hResult.FetchInt(0);
					DebugMessage("RemoveExpiredPlayers iClientID: %i", iClientID)
					
					DB_RemoveClientFromID(0, iClientID, false);
				}
			}
		}
	}
} 