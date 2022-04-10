void CMD_Setup()
{
	RegAdminCmd("sm_refresh_vips", ReloadVIPPlayers_CMD, ADMFLAG_ROOT);
	RegAdminCmd("sm_reload_vip_cfg", ReloadVIPCfg_CMD, ADMFLAG_ROOT);
	RegAdminCmd("sm_addvip", AddVIP_CMD, ADMFLAG_ROOT);
	RegAdminCmd("sm_delvip", DelVIP_CMD, ADMFLAG_ROOT);

	#if USE_ADMINMENU 1
	RegAdminCmd("sm_vipadmin", VIPAdmin_CMD, ADMFLAG_ROOT);
	#endif

	#if DEBUG_MODE 1
	RegAdminCmd("sm_vip_dump_features", DumpFeatures_CMD, ADMFLAG_ROOT);
	#endif
}

public void CMD_Register()
{
	static bool bIsRegistered;
	if (bIsRegistered == false)
	{
		UTIL_LoadVipCmd(g_CVAR_hVIPMenu_CMD, VIPMenu_CMD);

		bIsRegistered = true;
	}
}

#if USE_ADMINMENU 1
public Action VIPAdmin_CMD(int iClient, int iArgs)
{
	if (iClient)
	{
		DisplayAdminMenu(iClient);
	}
	
	return Plugin_Handled;
}
#endif

public Action ReloadVIPPlayers_CMD(int iClient, int iArgs)
{
	Clients_ReloadVipPlayers(iClient, true);
	
	return Plugin_Handled;
}

public Action ReloadVIPCfg_CMD(int iClient, int iArgs)
{
	ReadConfigs();
	Clients_ReloadVipPlayers(iClient, false);
	UTIL_Reply(iClient, "%t", "VIP_CFG_REFRESHED");
	
	return Plugin_Handled;
}

public Action AddVIP_CMD(int iClient, int iArgs)
{
	if (iArgs != 3)
	{
		ReplyToCommand(iClient, "[VIP] %t!\nSyntax: sm_addvip <#steam_id|#name|#userid> <group> <time>", "INCORRECT_USAGE");
		return Plugin_Handled;
	}
	
	char szBuffer[64], szTargetName[MAX_TARGET_LENGTH];
	GetCmdArg(1, SZF(szBuffer));

	int[] iTargetList = new int[MaxClients];
	bool bIsMulti;
	int iTargets, iAccountID = 0;

	if ((iTargets = ProcessTargetString(
			szBuffer,
			iClient, 
			iTargetList, 
			MaxClients, 
			COMMAND_FILTER_CONNECTED|COMMAND_FILTER_NO_BOTS,
			SZF(szTargetName),
			bIsMulti)) < 1)
	{
		iAccountID = UTIL_GetAccountIDFromSteamID(szBuffer);
		if (!iAccountID)
		{
			ReplyToTargetError(iClient, iTargets);
			return Plugin_Handled;
		}
	}

	char szGroup[64];
	GetCmdArg(3, SZF(szGroup));
	int iTime = StringToInt(szGroup);
	if (iTime < 0)
	{
		ReplyToCommand(iClient, "[VIP] %t", "INCORRECT_TIME");
		return Plugin_Handled;
	}

	szGroup[0] = 0;
	GetCmdArg(2, SZF(szGroup));
	if (!szGroup[0] || !UTIL_CheckValidVIPGroup(szGroup))
	{
		ReplyToCommand(iClient, "%t", "VIP_GROUP_DOES_NOT_EXIST");
		return Plugin_Handled;
	}

	if (iTargets > 0)
	{
		for(int i = 0; i < iTargets; ++i)
		{
			if (IsClientInGame(iTargetList[i]))
			{
				if (IS_CLIENT_VIP(iTargetList[i]))
				{
					ReplyToCommand(iClient, "[VIP] %t", "ALREADY_HAS_VIP");
					continue;
				}
				
				Clients_AddVipPlayer(iClient, iTargetList[i], _, UTIL_TimeToSeconds(iTime), szGroup);
			}
		}
	
		return Plugin_Handled;
	}
	
	Clients_AddVipPlayer(iClient, _, iAccountID, UTIL_TimeToSeconds(iTime), szGroup);

	return Plugin_Handled;
}

public Action DelVIP_CMD(int iClient, int iArgs)
{
	if (iArgs != 1)
	{
		ReplyToCommand(iClient, "%t!\nSyntax: sm_delvip <identity>", "INCORRECT_USAGE");
		return Plugin_Handled;
	}
	
	char szQuery[512], szAuth[MAX_NAME_LENGTH];
	GetCmdArg(1, SZF(szAuth));
	
	int iAccountID = UTIL_GetAccountIDFromSteamID(szAuth);
	if (!iAccountID)
	{
		ReplyToTargetError(iClient, COMMAND_TARGET_NONE);
		return Plugin_Handled;
	}

	FormatEx(SZF(szQuery), "SELECT `account_id`, `name`, `group` \
									FROM `vip_users` \
									WHERE `account_id` = %d%s LIMIT 1;", iAccountID, g_szSID);

	DebugMessage(szQuery)
	if (iClient)
	{
		iClient = UID(iClient);
	}

	DBG_SQL_Query(szQuery)
	g_hDatabase.Query(SQL_Callback_OnSelectRemoveClient, szQuery, iClient);

	return Plugin_Handled;
}

public void SQL_Callback_OnSelectRemoveClient(Database hOwner, DBResultSet hResult, const char[] szError, any iClient)
{
	DBG_SQL_Response("SQL_Callback_OnSelectRemoveClient")

	if (hResult == null || szError[0])
	{
		LogError("SQL_Callback_OnSelectRemoveClient: %s", szError);
	}
	
	if (iClient)
	{
		iClient = CID(iClient);
	}
	
	if (hResult.FetchRow())
	{
		int iAccountID;
		char szName[MNL*2], szGroup[64], szAdminInfo[128], szTargetInfo[128], szAuth[32];
		UTIL_GetClientInfo(iClient, SZF(szTargetInfo));
		FormatEx(SZF(szAdminInfo), "%T %s", "BY_ADMIN", LANG_SERVER, szTargetInfo);

		iAccountID = hResult.FetchInt(0);
		hResult.FetchString(1, SZF(szName));
		hResult.FetchString(2, SZF(szGroup));

		DBG_SQL_Response("hResult.FetchInt(0) = %d", iAccountID)
		DBG_SQL_Response("hResult.FetchString(1) = '%s'", szName)
		DBG_SQL_Response("hResult.FetchString(2) = '%s'", szGroup)

		UTIL_GetSteamIDFromAccountID(iAccountID, SZF(szAuth));
		FormatEx(SZF(szTargetInfo), "%s (%s, unknown)", szName, szAuth);

		DB_RemoveVipPlayerByData(
			iClient,
			szAdminInfo,
			0,
			iAccountID,
			szTargetInfo,
			szGroup,
			true
		);
	}
	else
	{
		ReplyToCommand(iClient, "%t", "FIND_THE_ID_FAIL");
	}
}

#if DEBUG_MODE 1
public Action DumpFeatures_CMD(int iClient, int iArgs)
{
	int iFeatures = g_hFeaturesArray.Length;
	if (iFeatures != 0)
	{
		char szBuffer[PLATFORM_MAX_PATH];
		BuildPath(Path_SM, SZF(szBuffer), "data/vip/features_dump.txt");
		File hFile = OpenFile(szBuffer, "w");

		if (hFile != null)
		{
			char szPluginName[64];
			char szPluginPath[PLATFORM_MAX_PATH];
			char szPluginVersion[32];
			char szFeature[FEATURE_NAME_LENGTH];
			char szFeatureType[32];
			char szFeatureValType[32];
			ArrayList hArray;
			Handle hPlugin;

			for(int i = 0; i < iFeatures; ++i)
			{
				g_hFeaturesArray.GetString(i, SZF(szFeature));
				if (GLOBAL_TRIE.GetValue(szFeature, hArray))
				{
					hPlugin = view_as<Handle>(hArray.Get(FEATURES_PLUGIN));
					GetPluginInfo(hPlugin, PlInfo_Name, SZF(szPluginName));
					GetPluginInfo(hPlugin, PlInfo_Version, SZF(szPluginVersion));
					GetPluginFilename(hPlugin, SZF(szPluginPath));
					
					switch(view_as<VIP_FeatureType>(hArray.Get(FEATURES_ITEM_TYPE)))
					{
						case TOGGLABLE:		strcopy(SZF(szFeatureType), "TOGGLABLE");
						case SELECTABLE:	strcopy(SZF(szFeatureType), "SELECTABLE");
						case HIDE:			strcopy(SZF(szFeatureType), "HIDE");
					}
					
					switch(view_as<VIP_ValueType>(hArray.Get(FEATURES_VALUE_TYPE)))
					{
						case VIP_NULL:		strcopy(SZF(szFeatureValType), "VIP_NULL");
						case INT:			strcopy(SZF(szFeatureValType), "INT");
						case FLOAT:			strcopy(SZF(szFeatureValType), "FLOAT");
						case BOOL:			strcopy(SZF(szFeatureValType), "BOOL");
						case STRING:		strcopy(SZF(szFeatureValType), "STRING");
					}
					
					hFile.WriteLine("%d. %-32s %-16s %-16s %-64s %-32s %-256s", i, szFeature, szFeatureType, szFeatureValType, szPluginName, szPluginVersion, szPluginPath);
				}
			}
		}

		delete hFile;
	}
	
	return Plugin_Handled;
}
#endif

public Action VIPMenu_CMD(int iClient, int iArgs)
{
	if (iClient && !IsVipMenuFlood(iClient))
	{
		if (!IS_CLIENT_VIP(iClient))
		{
			PlaySound(iClient, NO_ACCESS_SOUND);
			DisplayClientInfo(iClient, "no_access_info");
			return Plugin_Handled;
		}

		DisplayVipMenu(iClient);
	}

	return Plugin_Handled;
}
