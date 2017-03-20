
void CreateCvars()
{
	CreateConVar("sm_vip_core_version", VIP_VERSION, "VIP-CORE VERSION", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_CHEAT|FCVAR_DONTRECORD);

	ConVar hCvar = CreateConVar("sm_vip_admin_flag", "z", "Флаг админа, необходимый чтобы иметь доступ к управлению VIP-игроками.");
	HookConVarChange(hCvar, OnAdminFlagChange);
	g_CVAR_iAdminFlag = UTIL_GetConVarAdminFlag(hCvar);

	#if USE_ADMINMENU 1
	hCvar = CreateConVar("sm_vip_add_item_to_admin_menu", "1", "Добавить пункт \"Управление VIP\" в админ-меню.");
	HookConVarChange(hCvar, OnAddItemToAdminMenuChange);
	g_CVAR_bAddItemToAdminMenu = hCvar.BoolValue;
	#endif

	g_CVAR_hVIPMenu_CMD = CreateConVar("sm_vip_menu_commands", "vip;sm_vip;sm_vipmenu", "Команды для вызова VIP-меню (разделять ;)");

	hCvar = CreateConVar("sm_vip_server_id", "0", "ID сервера при приспользовании MySQL базы данных", _, true, 0.0);
	HookConVarChange(hCvar, OnServerIDChange);
	g_CVAR_iServerID = hCvar.IntValue;

	hCvar = CreateConVar("sm_vip_auto_open_menu", "0", "Автоматически открывать VIP-меню при входе (0 - Выключено, 1 - Включено)", _, true, 0.0, true, 1.0);
	HookConVarChange(hCvar, OnAutoOpenMenuChange);
	g_CVAR_bAutoOpenMenu = hCvar.BoolValue;

	hCvar = CreateConVar("sm_vip_time_mode", "0", "Формат времени (0 - Секунды, 1 - Минуты, 2 - Часы, 3 - Дни)", _, true, 0.0, true, 3.0);
	HookConVarChange(hCvar, OnTimeModeChange);
	g_CVAR_iTimeMode = hCvar.IntValue;

	hCvar = CreateConVar("sm_vip_delete_expired", "1", "Удалять VIP-игроков у которых истек срок (-1 - Не удалять, 0 - Удалять сразу, > 0 - Количество дней, по истечению которых удалять)", _, true, -1.0);
	HookConVarChange(hCvar, OnDeleteExpiredChange);
	g_CVAR_iDeleteExpired = hCvar.IntValue;

	hCvar = CreateConVar("sm_vip_update_name", "1", "Обновлять имена VIP-игроков в базе данных при входе(0 - Выключено, 1 - Включено)", _, true, 0.0, true, 1.0);
	HookConVarChange(hCvar, OnUpdateNameChange);
	g_CVAR_bUpdateName = hCvar.BoolValue;

	hCvar = CreateConVar("sm_vip_spawn_delay", "1.0", "Задержка перед установкой привилегий при возрождении игрока", _, true, 0.1);
	HookConVarChange(hCvar, OnSpawnDelayChange);
	g_CVAR_fSpawnDelay = hCvar.FloatValue;

	hCvar = CreateConVar("sm_vip_hide_no_access_items", "0", "Режим отображения недоступных функций в вип меню (0 - Сделать пункты неактивными, 1 - Скрывать пункты)", _, true, 0.0, true, 1.0);
	HookConVarChange(hCvar, OnHideNoAccessItemsChange);
	g_CVAR_bHideNoAccessItems = hCvar.BoolValue;
	
	hCvar = CreateConVar("sm_vip_logs_enable", "1", "Вести ли лог logs/VIP_Logs.log (0 - Выключено, 1 - Включено)", _, true, 0.0, true, 1.0);
	HookConVarChange(hCvar, OnLogsEnableChange);
	g_CVAR_bLogsEnable = hCvar.BoolValue;

	AutoExecConfig(true, "VIP_Core", "vip");
}

public void OnAdminFlagChange(ConVar hCvar, const char[] oldValue, const char[] newValue)
{
	g_CVAR_iAdminFlag = UTIL_GetConVarAdminFlag(hCvar);

	#if USE_ADMINMENU 1
	if(g_CVAR_bAddItemToAdminMenu)
	{
		if(g_hTopMenu)
		{
			if(VIPAdminMenuObject != INVALID_TOPMENUOBJECT )
			{
				RemoveFromTopMenu(g_hTopMenu, VIPAdminMenuObject);
			}

			AddItemsToTopMenu();
		}
	}
	#endif
}

#if USE_ADMINMENU 1
public void OnAddItemToAdminMenuChange(ConVar hCvar, const char[] oldValue, const char[] newValue)
{
	g_CVAR_bAddItemToAdminMenu = hCvar.BoolValue;
	if(g_CVAR_bAddItemToAdminMenu)
	{
		if(VIPAdminMenuObject != INVALID_TOPMENUOBJECT && g_hTopMenu != null)
		{
			RemoveFromTopMenu(g_hTopMenu, VIPAdminMenuObject);
			VIPAdminMenuObject = INVALID_TOPMENUOBJECT;
		}
	}
	else
	{
		if(g_hTopMenu)
		{
			RemoveFromTopMenu(g_hTopMenu, VIPAdminMenuObject);
			AddItemsToTopMenu();
		}
	}
}

#endif

public void OnServerIDChange(ConVar hCvar, const char[] oldValue, const char[] newValue)
{
	g_CVAR_iServerID = hCvar.IntValue;
}
public void OnAutoOpenMenuChange(ConVar hCvar, const char[] oldValue, const char[] newValue)
{
	g_CVAR_bAutoOpenMenu = hCvar.BoolValue;
}
public void OnTimeModeChange(ConVar hCvar, const char[] oldValue, const char[] newValue)
{
	g_CVAR_iTimeMode = hCvar.IntValue;
}
public void OnDeleteExpiredChange(ConVar hCvar, const char[] oldValue, const char[] newValue)
{
	g_CVAR_iDeleteExpired = hCvar.IntValue;
}
public void OnUpdateNameChange(ConVar hCvar, const char[] oldValue, const char[] newValue)
{
	g_CVAR_bUpdateName = hCvar.BoolValue;
}
public void OnSpawnDelayChange(ConVar hCvar, const char[] oldValue, const char[] newValue)
{
	g_CVAR_fSpawnDelay = hCvar.FloatValue;
}
public void OnHideNoAccessItemsChange(ConVar hCvar, const char[] oldValue, const char[] newValue)
{
	g_CVAR_bHideNoAccessItems = hCvar.BoolValue;
}
public void OnLogsEnableChange(ConVar hCvar, const char[] oldValue, const char[] newValue)
{
	g_CVAR_bLogsEnable = hCvar.BoolValue;
}