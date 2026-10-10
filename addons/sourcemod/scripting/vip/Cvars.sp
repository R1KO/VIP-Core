void Cvars_Setup()
{
	CreateConVar("sm_vip_core_version", VIP_VERSION, "VIP-CORE VERSION", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_CHEAT|FCVAR_DONTRECORD);

	ConVar hCvar = CreateConVar("sm_vip_admin_flag", "z", "Admin flag required to manage VIP players.");
	hCvar.AddChangeHook(OnAdminFlagChange);
	OnAdminFlagChange(hCvar, NULL_STRING, NULL_STRING);

	g_CVAR_hVIPMenu_CMD = CreateConVar("sm_vip_menu_commands", "vip;sm_vip;sm_vipmenu", "Commands that open the VIP menu (separated by ;)");

	hCvar = CreateConVar("sm_vip_server_id", "0", "Server ID when using a MySQL database", _, true, 0.0);
	hCvar.AddChangeHook(OnServerIDChange);
	OnServerIDChange(hCvar, NULL_STRING, NULL_STRING);

	hCvar = CreateConVar("sm_vip_storage_id", "0", "Server group ID for the player data storage when using a MySQL database", _, true, 0.0);
	hCvar.AddChangeHook(OnStorageIDChange);
	g_CVAR_iStorageID = hCvar.IntValue;

	hCvar = CreateConVar("sm_vip_auto_open_menu", "0", "Open the VIP menu automatically on join (0 - Disabled, 1 - Enabled)", _, true, 0.0, true, 1.0);
	hCvar.AddChangeHook(OnAutoOpenMenuChange);
	g_CVAR_bAutoOpenMenu = hCvar.BoolValue;

	hCvar = CreateConVar("sm_vip_time_mode", "0", "Time format (0 - Seconds, 1 - Minutes, 2 - Hours, 3 - Days)", _, true, 0.0, true, 3.0);
	hCvar.AddChangeHook(OnTimeModeChange);
	g_CVAR_iTimeMode = hCvar.IntValue;

	hCvar = CreateConVar("sm_vip_delete_expired", "1", "Delete expired VIP players (-1 - Never, 0 - Immediately, > 0 - Days after expiry)", _, true, -1.0, true, 365.0);
	hCvar.AddChangeHook(OnDeleteExpiredChange);
	g_CVAR_iDeleteExpired = hCvar.IntValue;

	hCvar = CreateConVar("sm_vip_delete_outdated", "-1", "Delete VIP players who have not joined for X days (-1 - Never, > 0 - Number of days (minimum 3))", _, true, -1.0, true, 365.0);
	hCvar.AddChangeHook(OnDeleteOutdatedChange);
	g_CVAR_iOutdatedExpired = hCvar.IntValue;

	hCvar = CreateConVar("sm_vip_update_name", "1", "Update VIP player names in the database on join (0 - Disabled, 1 - Enabled)", _, true, 0.0, true, 1.0);
	hCvar.AddChangeHook(OnUpdateNameChange);
	g_CVAR_bUpdateName = hCvar.BoolValue;

	hCvar = CreateConVar("sm_vip_spawn_delay", "1.0", "Delay before applying privileges after the player spawns", _, true, 0.1, true, 60.0);
	hCvar.AddChangeHook(OnSpawnDelayChange);
	g_CVAR_fSpawnDelay = hCvar.FloatValue;

	hCvar = CreateConVar("sm_vip_hide_no_access_items", "0", "How unavailable features are shown in the VIP menu (0 - Disabled items, 1 - Hidden)", _, true, 0.0, true, 1.0);
	hCvar.AddChangeHook(OnHideNoAccessItemsChange);
	g_CVAR_bHideNoAccessItems = hCvar.BoolValue;

	hCvar = CreateConVar("sm_vip_features_default_status", "1", "Default feature status (0 - Disabled, 1 - Enabled)", _, true, 0.0, true, 1.0);
	hCvar.AddChangeHook(OnDefaultStatusChange);
	g_CVAR_bDefaultStatus = hCvar.BoolValue;
	
	hCvar = CreateConVar("sm_vip_logs_enable", "1", "Write logs/VIP_Logs.log (0 - Disabled, 1 - Enabled)", _, true, 0.0, true, 1.0);
	hCvar.AddChangeHook(OnLogsEnableChange);
	g_CVAR_bLogsEnable = hCvar.BoolValue;

	AutoExecConfig(true, "VIP_Core", "vip");
}

public void OnAdminFlagChange(ConVar hCvar, const char[] szOldValue, const char[] szNewValue)
{
	g_CVAR_iAdminFlag = UTIL_GetConVarAdminFlag(hCvar);

	AddCommandOverride("sm_refresh_vips", Override_Command, g_CVAR_iAdminFlag);
	AddCommandOverride("sm_reload_vip_cfg", Override_Command, g_CVAR_iAdminFlag);
	AddCommandOverride("sm_addvip", Override_Command, g_CVAR_iAdminFlag);
	AddCommandOverride("sm_delvip", Override_Command, g_CVAR_iAdminFlag);

	#if USE_ADMINMENU
	AddCommandOverride("sm_vipadmin", Override_Command, g_CVAR_iAdminFlag);
	#endif
}

public void OnServerIDChange(ConVar hCvar, const char[] szOldValue, const char[] szNewValue)
{
	g_CVAR_iServerID = hCvar.IntValue;
	if (GLOBAL_INFO & IS_MySQL)
	{
		#if USE_MORE_SERVERS
		FormatEx(SZF(g_szSID), " AND (`sid` = %d OR `sid` = 0)", g_CVAR_iServerID);
		#else
		FormatEx(SZF(g_szSID), " AND `sid` = %d", g_CVAR_iServerID);
		#endif
	}
	else
	{
		g_szSID[0] = 0;
	}
}

public void OnStorageIDChange(ConVar hCvar, const char[] szOldValue, const char[] szNewValue)
{
	g_CVAR_iStorageID = hCvar.IntValue;
}

public void OnAutoOpenMenuChange(ConVar hCvar, const char[] szOldValue, const char[] szNewValue)
{
	g_CVAR_bAutoOpenMenu = hCvar.BoolValue;
}

public void OnTimeModeChange(ConVar hCvar, const char[] szOldValue, const char[] szNewValue)
{
	g_CVAR_iTimeMode = hCvar.IntValue;
}

public void OnDeleteExpiredChange(ConVar hCvar, const char[] szOldValue, const char[] szNewValue)
{
	g_CVAR_iDeleteExpired = hCvar.IntValue;
	if(g_CVAR_iDeleteExpired < -1)
	{
		g_CVAR_iDeleteExpired = -1;
		return;
	}
}

public void OnDeleteOutdatedChange(ConVar hCvar, const char[] szOldValue, const char[] szNewValue)
{
	g_CVAR_iOutdatedExpired = hCvar.IntValue;
	if(g_CVAR_iOutdatedExpired != -1)
	{
		if(g_CVAR_iOutdatedExpired < 1)
		{
			g_CVAR_iOutdatedExpired = -1;
			return;
		}

		if(g_CVAR_iOutdatedExpired < 3)
		{
			g_CVAR_iOutdatedExpired = 3;
		}
	}
}

public void OnUpdateNameChange(ConVar hCvar, const char[] szOldValue, const char[] szNewValue)
{
	g_CVAR_bUpdateName = hCvar.BoolValue;
}

public void OnSpawnDelayChange(ConVar hCvar, const char[] szOldValue, const char[] szNewValue)
{
	g_CVAR_fSpawnDelay = hCvar.FloatValue;
}

public void OnHideNoAccessItemsChange(ConVar hCvar, const char[] szOldValue, const char[] szNewValue)
{
	g_CVAR_bHideNoAccessItems = hCvar.BoolValue;
}

public void OnDefaultStatusChange(ConVar hCvar, const char[] szOldValue, const char[] szNewValue)
{
	g_CVAR_bDefaultStatus = hCvar.BoolValue;
}

public void OnLogsEnableChange(ConVar hCvar, const char[] szOldValue, const char[] szNewValue)
{
	g_CVAR_bLogsEnable = hCvar.BoolValue;
}
