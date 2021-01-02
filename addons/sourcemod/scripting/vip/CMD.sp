void CMD_Setup()
{
	RegConsoleCmd("sm_refresh_vips",	ReloadVIPPlayers_CMD);
	RegConsoleCmd("sm_reload_vip_cfg",	ReloadVIPCfg_CMD);
	RegConsoleCmd("sm_addvip",			AddVIP_CMD);
	RegConsoleCmd("sm_delvip",			DelVIP_CMD);

	#if DEBUG_MODE 1
	RegConsoleCmd("sm_vip_dump_features",	DumpFeatures_CMD);
	#endif
}

public void OnConfigsExecuted()
{
	static bool bIsRegistered;
	if (bIsRegistered == false)
	{
		UTIL_LoadVipCmd(g_CVAR_hVIPMenu_CMD, VIPMenu_CMD);
		
		bIsRegistered = true;
	}
}

#define CHECK_ACCESS(%0) if (%0 && !(GetUserFlagBits(%0) & g_CVAR_iAdminFlag)) \
						{ \
							ReplyToCommand(%0, "[VIP] %t", "COMMAND_NO_ACCESS"); \
							return Plugin_Handled; \
						}

#if USE_ADMINMENU 1
public Action VIPAdmin_CMD(int iClient, int iArgs)
{
	if (iClient)
	{
		CHECK_ACCESS(iClient)
		
	//	g_hTopMenu.Display(iClient, TopMenuPosition_Start); //g_hTopMenu.Display(iClient, MENU_TIME_FOREVER);
		g_hVIPAdminMenu.Display(iClient, MENU_TIME_FOREVER);
	}
	
	return Plugin_Handled;
}
#endif

public Action ReloadVIPPlayers_CMD(int iClient, int iArgs)
{
	CHECK_ACCESS(iClient)
	
	UTIL_ReloadVIPPlayers(iClient, true);
	
	return Plugin_Handled;
}

public Action ReloadVIPCfg_CMD(int iClient, int iArgs)
{
	CHECK_ACCESS(iClient)
	
	ReadConfigs();
	UTIL_ReloadVIPPlayers(iClient, false);
	UTIL_Reply(iClient, "%t", "VIP_CFG_REFRESHED");
	
	return Plugin_Handled;
}

public Action AddVIP_CMD(int iClient, int iArgs)
{
	CHECK_ACCESS(iClient)

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

	if((iTargets = ProcessTargetString(
			szBuffer,
			iClient, 
			iTargetList, 
			MaxClients, 
			COMMAND_FILTER_CONNECTED|COMMAND_FILTER_NO_BOTS,
			SZF(szTargetName),
			bIsMulti)) < 1)
	{
		iAccountID = UTIL_GetAccountIDFromSteamID(szBuffer);
		if(!iAccountID)
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

	if(iTargets > 0)
	{
		for(int i = 0; i < iTargets; ++i)
		{
			if(IsClientInGame(iTargetList[i]))
			{
				if (g_iClientInfo[iTargetList[i]] & IS_VIP)
				{
					ReplyToCommand(iClient, "[VIP] %t", "ALREADY_HAS_VIP");
					continue;
				}
				
				UTIL_ADD_VIP_PLAYER(iClient, iTargetList[i], _, UTIL_TimeToSeconds(iTime), szGroup);
			}
		}
	
		return Plugin_Handled;
	}
	
	UTIL_ADD_VIP_PLAYER(iClient, _, iAccountID, UTIL_TimeToSeconds(iTime), szGroup);

	return Plugin_Handled;
}

public Action DelVIP_CMD(int iClient, int iArgs)
{
	CHECK_ACCESS(iClient)

	if (iArgs != 1)
	{
		ReplyToCommand(iClient, "%t!\nSyntax: sm_delvip <identity>", "INCORRECT_USAGE");
		return Plugin_Handled;
	}
	
	char szQuery[512], szAuth[MAX_NAME_LENGTH];
	GetCmdArg(1, SZF(szAuth));
	
	int iAccountID = UTIL_GetAccountIDFromSteamID(szAuth);
	if(!iAccountID)
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
		DBG_SQL_Response("hResult.FetchRow()")
		int iAccountID = hResult.FetchInt(0);
		DBG_SQL_Response("hResult.FetchInt(0) = %d", iAccountID)
		char szName[MNL], szGroup[64];
		hResult.FetchString(1, SZF(szName));
		hResult.FetchString(2, SZF(szGroup));
		DBG_SQL_Response("hResult.FetchString(1) = '%s", szName)
		DB_RemoveClientFromID(iClient, _, iAccountID, true, szName, szGroup);
	}
	else
	{
		ReplyToCommand(iClient, "%t", "FIND_THE_ID_FAIL");
	}
}

#if DEBUG_MODE 1
public Action DumpFeatures_CMD(int iClient, int iArgs)
{
	CHECK_ACCESS(iClient)
	
	int iFeatures = g_hFeaturesArray.Length;
	if(iFeatures != 0)
	{
		char szBuffer[PLATFORM_MAX_PATH];
		BuildPath(Path_SM, SZF(szBuffer), "data/vip/features_dump.txt");
		File hFile = OpenFile(szBuffer, "w");

		if(hFile != null)
		{
			char				szPluginName[64];
			char				szPluginPath[PLATFORM_MAX_PATH];
			char				szPluginVersion[32];
			char				szFeature[FEATURE_NAME_LENGTH];
			char				szFeatureType[32];
			char				szFeatureValType[32];
			ArrayList			hArray;
			Handle				hPlugin;

			for(int i = 0; i < iFeatures; ++i)
			{
				g_hFeaturesArray.GetString(i, SZF(szFeature));
				if(GLOBAL_TRIE.GetValue(szFeature, hArray))
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
	if (iClient)
	{
		if (OnVipMenuFlood(iClient) == false)
		{
			if (g_iClientInfo[iClient] & IS_VIP)
			{
				g_hVIPMenu.Display(iClient, MENU_TIME_FOREVER);
			}
			else
			{
				/*
				PrintToChat(iClient, "%t%t", "VIP_CHAT_PREFIX", "COMMAND_NO_ACCESS");
				*/
				
				PlaySound(iClient, NO_ACCESS_SOUND);
				DisplayClientInfo(iClient, "no_access_info");
			}
		}
	}
	return Plugin_Handled;
}
