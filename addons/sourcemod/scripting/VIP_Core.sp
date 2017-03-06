#pragma semicolon 1

#include <sourcemod>
#include <vip_core>
#include <clientprefs>

#define VIP_VERSION	"3.0 DEV #0"

#define DEBUG_MODE 		0	// Режим отладки

#define USE_ADMINMENU	1	// Включение админ-меню для управления VIP

#if USE_ADMINMENU 1
#undef REQUIRE_PLUGIN
#include <adminmenu>
#define REQUIRE_PLUGIN
#endif

public Plugin:myinfo =
{
	name = "[VIP] Core",
	author = "R1KO (skype: vova.andrienko1)",
	version = VIP_VERSION,
	url = "http://hlmod.ru"
};


#if DEBUG_MODE 1
new String:g_sDebugLogFile[PLATFORM_MAX_PATH];

stock DebugMsg(const String:sMsg[], any:...)
{
	decl String:sBuffer[250];
	VFormat(sBuffer, sizeof(sBuffer), sMsg, 2);
	LogToFile(g_sDebugLogFile, sBuffer);
}
#define DebugMessage(%0) DebugMsg(%0);
#else
#define DebugMessage(%0)
#endif

#include "vip/downloads.sp"
#include "vip/vars.sp"
#include "vip/utils.sp"
#include "vip/features.sp"
#include "vip/sounds.sp"
#include "vip/info.sp"
#include "vip/db.sp"
#include "vip/initialization.sp"
#include "vip/cvars.sp"
#if USE_ADMINMENU 1
#include "vip/adminmenu.sp"
#endif
#include "vip/vipmenu.sp"
#include "vip/api.sp"
#include "vip/cmds.sp"
#include "vip/clients.sp"

public OnPluginStart()
{
	#if DEBUG_MODE 1
	BuildPath(Path_SM, g_sDebugLogFile, sizeof(g_sDebugLogFile), "logs/VIP_Debug.log");
	#endif

	LoadTranslations("vip_core.phrases");
	LoadTranslations("vip_modules.phrases");
	LoadTranslations("common.phrases");

	GLOBAL_ARRAY	= CreateArray(ByteCountToCells(FEATURE_NAME_LENGTH));
	GLOBAL_TRIE	= CreateTrie();
	ReadConfigs();
	
	InitVIPMenu();
	#if USE_ADMINMENU 1
	InitVIPAdminMenu();
	#endif

	CreateCvars();
	CreateForwards();

	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("round_end", Event_RoundEnd, EventHookMode_PostNoCopy);
	HookEventEx("cs_match_end_restart", Event_MatchEndRestart, EventHookMode_PostNoCopy);

	RegConsoleCmd("sm_refresh_vips",	ReloadVIPPlayers_CMD);
	RegConsoleCmd("sm_reload_vip_cfg",	ReloadVIPCfg_CMD);
	RegConsoleCmd("sm_addvip",			AddVIP_CMD);
	RegConsoleCmd("sm_delvip",			DelVIP_CMD);

	g_EngineVersion = GetEngineVersion();

	#if USE_ADMINMENU 1
	RegConsoleCmd("sm_vipadmin",		VIPAdmin_CMD);

	if(LibraryExists("adminmenu"))
	{
		decl Handle:hTopMenu;
		if((hTopMenu = GetAdminTopMenu()))
		{
			OnAdminMenuReady(hTopMenu);
		}
	}
	#endif
}

public OnAllPluginsLoaded()
{
	DB_OnPluginStart();
}

#if USE_ADMINMENU 1
public Action:OnClientSayCommand(iClient, const String:sCommand[], const String:sArgs[])
{
	if(iClient > 0 && iClient <= MaxClients && sArgs[0])
	{
		if(g_iClientInfo[iClient] & IS_WAIT_CHAT_PASS || g_iClientInfo[iClient] & IS_WAIT_CHAT_SEARCH)
		{
			if(g_iClientInfo[iClient] & IS_WAIT_CHAT_PASS)
			{
				ShowWaitPassMenu(iClient, sArgs, true);
			}
			else if(g_iClientInfo[iClient] & IS_WAIT_CHAT_SEARCH)
			{
				ShowWaitSearchMenu(iClient, sArgs, true);
			}

			return Plugin_Handled;
		}
	}

	return Plugin_Continue;
}
#endif
