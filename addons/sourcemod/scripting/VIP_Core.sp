#pragma semicolon 1

#pragma newdecls required

#include <sourcemod>
#include <vip_core>
#include <clientprefs>

#if !defined VIP_VERSION
#define VIP_VERSION		"3.0.6 R"
#endif

// VIP Colors - 1, Multicolors - 2
#define GAME 1

#define DEBUG_MODE			0	// Режим отладки

#define USE_ADMINMENU		1	// Включение админ-меню для управления VIP

#define USE_MORE_SERVERS	1	// Включить/Отключить режим при котором если ID сервера у игрока 0 - то VIP будет работать на всех серверах


public Plugin myinfo =
{
	name = "[VIP] Core",
	author = "R1KO",
	version = VIP_VERSION,
	url = "https://github.com/R1KO/VIP-Core"
};

#include "vip/Global.sp"
#include "vip/Debug.sp"
#include "vip/Downloads.sp"

#if GAME == 1
#include "vip/Colors.sp"
#else
#include <multicolors>
#endif

#include "vip/UTIL.sp"
#include "vip/Features.sp"
#include "vip/Sounds.sp"
#include "vip/Info.sp"
#include "vip/Database.sp"
#include "vip/Configs.sp"
#include "vip/Cvars.sp"
#if USE_ADMINMENU
#include "vip/AdminMenu.sp"
#include "vip/adminmenu/Add.sp"
#include "vip/adminmenu/List.sp"
#include "vip/adminmenu/Edit.sp"
#include "vip/adminmenu/Del.sp"
#endif
#include "vip/VipMenu.sp"
#include "vip/API.sp"
#include "vip/CMD.sp"
#include "vip/Clients.sp"

public void OnPluginStart()
{
	#if DEBUG_MODE
	BuildPath(Path_SM, SZF(g_szDebugLogFile), "logs/VIP_Debug.log");
	#endif

	BuildPath(Path_SM, SZF(g_szLogFile), "logs/VIP_Logs.log");

	LoadTranslations("vip_core.phrases");
	LoadTranslations("vip_modules.phrases");
	LoadTranslations("common.phrases");
	LoadTranslations("core.phrases");

	g_iMaxPageItems = GetMaxPageItems(GetMenuStyleHandle(MenuStyle_Default));
	g_hFeaturesArray = new ArrayList(ByteCountToCells(FEATURE_NAME_LENGTH));
	GLOBAL_TRIE = new StringMap();

	// Fix DataPack positions in sm 1.10
	DataPack hDataPack = new DataPack();
	hDataPack.WriteCell(0);
	ITEM_DISPLAY = hDataPack.Position;
	hDataPack.WriteCell(0);
	ITEM_DRAW = hDataPack.Position;
	delete hDataPack;

	ReadConfigs();

	VIPMenu_Setup();
	#if USE_ADMINMENU
	AdminMenu_Setup();
	#endif

	Cvars_Setup();
	API_SetupForwards();

	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("round_end", Event_RoundEnd, EventHookMode_PostNoCopy);
	HookEventEx("cs_match_end_restart", Event_MatchEndRestart, EventHookMode_PostNoCopy);

	CMD_Setup();

	g_EngineVersion = GetEngineVersion();
}

public void OnAllPluginsLoaded()
{
	DB_OnPluginStart();
}
