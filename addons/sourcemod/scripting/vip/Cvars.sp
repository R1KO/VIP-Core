
void Cvars_Setup()
{
	CreateConVar("sm_vip_core_version", VIP_CORE_VERSION, "VIP-CORE VERSION", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_CHEAT|FCVAR_DONTRECORD);

	ConVar hCvar = CreateConVar("sm_vip_admin_flag", "z", "Флаг админа, необходимый чтобы иметь доступ к управлению VIP-игроками.");
	hCvar.AddChangeHook(OnAdminFlagChange);
	g_CVAR_iAdminFlag = UTIL_GetConVarAdminFlag(hCvar);

	g_CVAR_hVIPMenu_CMD = CreateConVar("sm_vip_menu_commands", "vip;sm_vip;sm_vipmenu", "Команды для вызова VIP-меню (разделять ;)");

	hCvar = CreateConVar("sm_vip_server_id", "0", "ID сервера при приспользовании MySQL базы данных", _, true, 0.0);
	hCvar.AddChangeHook(OnServerIDChange);
	g_CVAR_iServerID = hCvar.IntValue;
	SetupServerID();

	hCvar = CreateConVar("sm_vip_auto_open_menu", "0", "Автоматически открывать VIP-меню при входе (0 - Выключено, 1 - Включено)", _, true, 0.0, true, 1.0);
	hCvar.AddChangeHook(OnAutoOpenMenuChange);
	g_CVAR_bAutoOpenMenu = hCvar.BoolValue;

	hCvar = CreateConVar("sm_vip_time_mode", "0", "Формат времени (0 - Секунды, 1 - Минуты, 2 - Часы, 3 - Дни)", _, true, 0.0, true, 3.0);
	hCvar.AddChangeHook(OnTimeModeChange);
	g_CVAR_iTimeMode = hCvar.IntValue;

	hCvar = CreateConVar("sm_vip_delete_expired", "1", "Удалять VIP-игроков у которых истек срок и они не заходили на сервер (-1 - Не удалять, 0 - Удалять сразу, > 0 - Количество дней, по истечению которых удалять)", _, true, -1.0, true, 365.0);
	hCvar.AddChangeHook(OnDeleteExpiredChange);
	g_CVAR_iDeleteExpired = hCvar.IntValue;

	hCvar = CreateConVar("sm_vip_delete_outdated", "-1", "Удалять VIP-игроков которые не заходили на сервер X дней (-1 или 0 - Не удалять, > 0 - Количество дней, по истечению которых удалять (минимум 3 суток))", _, true, -1.0, true, 365.0);
	hCvar.AddChangeHook(OnDeleteOutdatedChange);
	g_CVAR_iOutdatedExpired = hCvar.IntValue;

	hCvar = CreateConVar("sm_vip_update_name", "1", "Обновлять имена VIP-игроков в базе данных при входе(0 - Выключено, 1 - Включено)", _, true, 0.0, true, 1.0);
	hCvar.AddChangeHook(OnUpdateNameChange);
	g_CVAR_bUpdateName = hCvar.BoolValue;

	hCvar = CreateConVar("sm_vip_spawn_delay", "1.0", "Задержка перед установкой привилегий при возрождении игрока", _, true, 0.1, true, 60.0);
	hCvar.AddChangeHook(OnSpawnDelayChange);
	g_CVAR_fSpawnDelay = hCvar.FloatValue;

	hCvar = CreateConVar("sm_vip_hide_no_access_items", "0", "Режим отображения недоступных функций в вип меню (0 - Сделать пункты неактивными, 1 - Скрывать пункты)", _, true, 0.0, true, 1.0);
	hCvar.AddChangeHook(OnHideNoAccessItemsChange);
	g_CVAR_bHideNoAccessItems = hCvar.BoolValue;

	hCvar = CreateConVar("sm_vip_features_default_status", "1", "Статус функций по-умолчанию (0 - Выключены, 1 - Включены)", _, true, 0.0, true, 1.0);
	hCvar.AddChangeHook(OnDefaultStatusChange);
	g_CVAR_bDefaultStatus = hCvar.BoolValue;

	AutoExecConfig(true, "VIP_Core", "vip");
}

public void OnAdminFlagChange(ConVar hCvar, const char[] szOldValue, const char[] szNewValue)
{
	g_CVAR_iAdminFlag = UTIL_GetConVarAdminFlag(hCvar);

	#if USE_ADMINMENU 1
	if (g_hTopMenu)
	{
		if (VIPAdminMenuObject != INVALID_TOPMENUOBJECT)
		{
			RemoveFromTopMenu(g_hTopMenu, VIPAdminMenuObject);
		}

		AddItemsToTopMenu();
	}
	#endif
}

public void OnServerIDChange(ConVar hCvar, const char[] szOldValue, const char[] szNewValue)
{
	g_CVAR_iServerID = hCvar.IntValue;
	SetupServerID();
}

void SetupServerID()
{
	if (GLOBAL_INFO & IS_MySQL)
	{
		#if USE_MORE_SERVERS 1
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
	if (g_CVAR_iDeleteExpired < -1)
	{
		g_CVAR_iDeleteExpired = -1;
	}
}

public void OnDeleteOutdatedChange(ConVar hCvar, const char[] szOldValue, const char[] szNewValue)
{
	g_CVAR_iOutdatedExpired = hCvar.IntValue;
	if (g_CVAR_iOutdatedExpired != -1)
	{
		if (g_CVAR_iOutdatedExpired < 1)
		{
			g_CVAR_iOutdatedExpired = -1;
			return;
		}

		if (g_CVAR_iOutdatedExpired < 3)
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
