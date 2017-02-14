#pragma semicolon 1

#include <sourcemod>
#include <vip_core>
#include <clientprefs>

#undef REQUIRE_PLUGIN
#include <adminmenu>
#define REQUIRE_PLUGIN
/*
#undef REQUIRE_PLUGIN
#tryinclude <updater>
#define REQUIRE_PLUGIN

#define UPDATE_URL	"http://rikoshop.smoke-project.ru/plugins_update/vip_core/update.txt"

#if defined _updater_included
public OnLibraryAdded(const String:name[])
{
	if (StrEqual(name, "updater", false))
	{
		Updater_AddPlugin(UPDATE_URL);
	}
}
#endif
*/

/*
#undef REQUIRE_EXTENSIONS
#tryinclude <morecolors>
#tryinclude <colors>
#tryinclude <csgo_colors>
*/

#define DEBUG_MODE 0

#define VIP_VERSION	"2.1.1 R"

public Plugin:myinfo =
{
	name = "[VIP] Core",
	author = "R1KO (skype: vova.andrienko1)",
	version = VIP_VERSION,
	url = "http://hlmod.ru"
};

#if DEBUG_MODE 0

new const String:g_sDebugLogFile[] = "addons/sourcemod/logs/VIP_Debug.log";

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
#include "vip/sounds.sp"
#include "vip/info.sp"
#include "vip/db.sp"
#include "vip/initialization.sp"
#include "vip/cvars.sp"
#include "vip/adminmenu.sp"
#include "vip/vipmenu.sp"
#include "vip/forwards.sp"
#include "vip/natives.sp"
#include "vip/cmds.sp"
#include "vip/features.sp"
#include "vip/clients.sp"

public OnPluginStart()
{
//	LogMessage("OnPluginStart");
//	g_bIsVIPLoaded = false;

	LoadTranslations("vip_core.phrases");
	LoadTranslations("vip_modules.phrases");
	LoadTranslations("common.phrases");

	g_hHookPlugins = CreateArray();
	GLOBAL_ARRAY	= CreateArray(ByteCountToCells(FEATURE_NAME_LENGTH));
	GLOBAL_TRIE	= CreateTrie();
	GLOBAL_INFO_ARRAY = CreateArray();
	ReadConfigs();

	g_hVIPMenu = CreateMenu(Handler_VIPMenu, MenuAction_Start|MenuAction_Display|MenuAction_Select|MenuAction_DisplayItem|MenuAction_DrawItem);

	AddMenuItem(g_hVIPMenu, "NO_FEATURES", "NO_FEATURES", ITEMDRAW_DISABLED);

	CreateCvars();
	CreateForwards();

	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("round_end", Event_RoundEnd, EventHookMode_PostNoCopy);
	HookEventEx("cs_match_end_restart", Event_MatchEndRestart, EventHookMode_PostNoCopy);

	AddCommandListener(Command_Say, "say");
	AddCommandListener(Command_Say, "say_team");
	
	RegConsoleCmd("sm_refresh_vips",	ReloadVIPPlayers_CMD);
	RegConsoleCmd("sm_reload_vip_cfg",	ReloadVIPCfg_CMD);
	RegConsoleCmd("sm_addvip",			AddVIP_CMD);
	RegConsoleCmd("sm_delvip",			DelVIP_CMD);

	g_GameType = UTIL_GetGameType();

	if(LibraryExists("adminmenu"))
	{
		decl Handle:hTopMenu;
		hTopMenu = GetAdminTopMenu();
		if(hTopMenu != INVALID_HANDLE)
		{
			OnAdminMenuReady(hTopMenu);
		}
	}
	
//	DB_OnPluginStart();
}

public OnAllPluginsLoaded()
{
//	LogMessage("OnAllPluginsLoaded");
	DB_OnPluginStart();
	
	/*
	#if defined _updater_included
	if (LibraryExists("updater"))
	{
		Updater_AddPlugin(UPDATE_URL);
	}
	#endif
	*/
}

public Action:Command_Say(iClient, const String:sCommand[], iArgs)
{
	if(iClient > 0 && iClient <= MaxClients && iArgs)
	{
		if(g_iClientInfo[iClient] & IS_WAIT_CHAT_PASS || g_iClientInfo[iClient] & IS_WAIT_CHAT_SEARCH)
		{
			decl String:sText[192];
			GetCmdArgString(sText, sizeof(sText));
			TrimString(sText);
			StripQuotes(sText);

			if(sText[0])
			{
				if(g_iClientInfo[iClient] & IS_WAIT_CHAT_PASS)
				{
					ShowWaitPassMenu(iClient, sText, true);
				}
				else if(g_iClientInfo[iClient] & IS_WAIT_CHAT_SEARCH)
				{
					ShowWaitSearchMenu(iClient, sText, true);
				}
			}

			return Plugin_Handled;
		}

		/*
		if(strcmp(sText, "vip", false) == 0 ||
		strcmp(sText, "vipmenu", false) == 0 ||
		strcmp(sText, "вип", false) == 0)
		{
			VIPMenu_CMD(iClient, 0);
		}
		*/
	}

	return Plugin_Continue;
}

/*
public OnRebuildAdminCache(AdminCachePart:part)
{
	for (new iClient = 1; iClient <= MaxClients; ++iClient)
	{
		if (IsClientInGame(iClient) && !IsFakeClient(iClient))
		{
			if(CheckCommandAccess(iClient, "vip_admin", g_CVAR_iAdminFlag) == false) CloseHandleEx(g_ClientData[iClient]);
		}
	}
}
*/

