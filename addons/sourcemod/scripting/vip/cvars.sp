
CreateCvars()
{
	CreateConVar("sm_vip_core_version", VIP_VERSION, "VIP-CORE VERSION", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_CHEAT|FCVAR_DONTRECORD);

	decl Handle:hCvar;

	hCvar = CreateConVar("sm_vip_admin_flag", "z", "Флаг админа, необходимый чтобы иметь доступ к управлению VIP-игроками.");
	HookConVarChange(hCvar, OnAdminFlagChange);
	g_CVAR_iAdminFlag = UTIL_GetConVarAdminFlag(hCvar);

	g_CVAR_hVIPMenu_CMD = CreateConVar("sm_vip_menu_commands", "vip;sm_vip;sm_vipmenu", "Команды для вызова VIP-меню (разделять ;)");

	hCvar = CreateConVar("sm_vip_server_id", "0", "ID сервера при приспользовании MySQL базы данных", _, true, 0.0);
	HookConVarChange(hCvar, OnServerIDChange);
	g_CVAR_iServerID = GetConVarInt(hCvar);

	hCvar = CreateConVar("sm_vip_auto_open_menu", "0", "Автоматически открывать VIP-меню при входе (0 - Выключено, 1 - Включено)", _, true, 0.0, true, 1.0);
	HookConVarChange(hCvar, OnAutoOpenMenuChange);
	g_CVAR_bAutoOpenMenu = GetConVarBool(hCvar);

	hCvar = CreateConVar("sm_vip_time_mode", "0", "Формат времени (0 - Секунды, 1 - Минуты, 2 - Часы, 3 - Дни)", _, true, 0.0, true, 3.0);
	HookConVarChange(hCvar, OnTimeModeChange);
	g_CVAR_iTimeMode = GetConVarInt(hCvar);

	hCvar = CreateConVar("sm_vip_delete_expired", "1", "Удалять VIP-игроков у которых истек срок (-1 - Не удалять, 0 - Удалять сразу, > 0 - Количество дней, по истечению которых удалять)", _, true, -1.0);
	HookConVarChange(hCvar, OnDeleteExpiredChange);
	g_CVAR_iDeleteExpired = GetConVarInt(hCvar);

	hCvar = CreateConVar("sm_vip_update_name", "1", "Обновлять имена VIP-игроков в базе данных при входе(0 - Выключено, 1 - Включено)", _, true, 0.0, true, 1.0);
	HookConVarChange(hCvar, OnUpdateNameChange);
	g_CVAR_bUpdateName = GetConVarBool(hCvar);

	hCvar = CreateConVar("sm_vip_spawn_delay", "1.0", "Задержка перед установкой привилегий при возрождении игрока", _, true, 0.1);
	HookConVarChange(hCvar, OnSpawnDelayChange);
	g_CVAR_fSpawnDelay = GetConVarFloat(hCvar);

	hCvar = CreateConVar("sm_vip_kick_not_authorized", "0", "Выкидывать с сервера игроков, которые имеют VIP-статус, но не ввели пароль (0 - Выключено, 1 - Включено)", _, true, 0.0, true, 1.0);
	HookConVarChange(hCvar, OnKickNotAuthorizedChange);
	g_CVAR_bKickNotAuthorized = GetConVarBool(hCvar);

	hCvar = CreateConVar("sm_vip_hide_no_access_items", "0", "Режим отображения недоступных функций в вип меню (0 - Сделать пункты неактивными, 1 - Скрывать пункты)", _, true, 0.0, true, 1.0);
	HookConVarChange(hCvar, OnHideNoAccessItemsChange);
	g_CVAR_bHideNoAccessItems = GetConVarBool(hCvar);
	
	hCvar = CreateConVar("sm_vip_logs_enable", "1", "Вести ли лог logs/VIP_Logs.log (0 - Выключено, 1 - Включено)", _, true, 0.0, true, 1.0);
	HookConVarChange(hCvar, OnLogsEnableChange);
	g_CVAR_bLogsEnable = GetConVarBool(hCvar);

	AutoExecConfig(true, "VIP_Core", "vip");
}

public OnAdminFlagChange(Handle:hCvar, const String:oldValue[], const String:newValue[])
{
	g_CVAR_iAdminFlag = UTIL_GetConVarAdminFlag(hCvar);
	/*
	if(VIPAdminMenuObject != INVALID_TOPMENUOBJECT && g_hTopMenu != INVALID_HANDLE)
	{
		RemoveFromTopMenu(g_hTopMenu, VIPAdminMenuObject);
		VIPAdminMenuObject = INVALID_TOPMENUOBJECT;
	}

	AddItemsToTopMenu();
	*/
}

public OnServerIDChange(Handle:hCvar, const String:oldValue[], const String:newValue[])					g_CVAR_iServerID = GetConVarInt(hCvar);
public OnAutoOpenMenuChange(Handle:hCvar, const String:oldValue[], const String:newValue[])				g_CVAR_bAutoOpenMenu = GetConVarBool(hCvar);
public OnTimeModeChange(Handle:hCvar, const String:oldValue[], const String:newValue[])					g_CVAR_iTimeMode = GetConVarInt(hCvar);
public OnDeleteExpiredChange(Handle:hCvar, const String:oldValue[], const String:newValue[])			g_CVAR_iDeleteExpired = GetConVarInt(hCvar);
public OnUpdateNameChange(Handle:hCvar, const String:oldValue[], const String:newValue[])				g_CVAR_bUpdateName = GetConVarBool(hCvar);
public OnSpawnDelayChange(Handle:hCvar, const String:oldValue[], const String:newValue[])				g_CVAR_fSpawnDelay = GetConVarFloat(hCvar);
public OnKickNotAuthorizedChange(Handle:hCvar, const String:oldValue[], const String:newValue[])		g_CVAR_bKickNotAuthorized = GetConVarBool(hCvar);
public OnHideNoAccessItemsChange(Handle:hCvar, const String:oldValue[], const String:newValue[])		g_CVAR_bHideNoAccessItems = GetConVarBool(hCvar);
public OnLogsEnableChange(Handle:hCvar, const String:oldValue[], const String:newValue[])				g_CVAR_bLogsEnable = GetConVarBool(hCvar);
