#define GLOBAL_ARRAY			g_hFeatureStatus[0]
#define GLOBAL_TRIE			g_hFeatures[0]

#define GLOBAL_INFO_KV		g_ClientData[0]

#define GLOBAL_INFO			g_iClientInfo[0]

#define UID(%0) 	GetClientUserId(%0)
#define CID(%0) 	GetClientOfUserId(%0)
#define SZF(%0) 	%0, sizeof(%0)

#define SET_BIT(%0,%1) 	%0 |= %1
#define UNSET_BIT(%0,%1) 	%0 &= ~%1

#define IS_VIP						(1<<0)	// VIP ли игрок
#define IS_AUTHORIZED				(1<<1)	// Авторизирован ли игрок
#define IS_LOADED						(1<<2)	// Загружен ли игрок
#define IS_WAIT_CHAT_PASS			(1<<3)	// Ожидается ввод пароля в чат
#define IS_WAIT_CHAT_SEARCH		(1<<4)	// Ожидается ввод значения для поиска в чат
#define IS_SPAWNED					(1<<5)	// Игрок возродился
#define IS_MENU_OPEN					(1<<6)	// VIP-меню открыто

#define IS_STARTED					(1<<0)
#define IS_MySQL						(1<<1)
#define IS_LOADING					(1<<2)


#define	KEY_CID			"ClientID"
#define	KEY_EXPIRES		"expires"
#define	KEY_GROUP			"vip_group"
#define	KEY_AUTHTYPE		"AuthType"

/*
#define IS_CLIENT_VIP(%1)	(g_bIsClientVIP[%1] && g_bIsClientAuthorized[%1])
*/
enum
{
	FEATURES_PLUGIN = 0,
	FEATURES_VALUE_TYPE,
	FEATURES_COOKIE,
	FEATURES_ITEM_TYPE,
	FEATURES_ITEM_SELECT,
	FEATURES_ITEM_DISPLAY,
	FEATURES_ITEM_DRAW,
	FEATURES_SIZE
}

enum
{
	TIME_MODE_SECONDS = 0,
	TIME_MODE_MINUTES,
	TIME_MODE_HOURS,
	TIME_MODE_DAYS
}

enum
{
	DATA_MENU_TYPE = 0,
	DATA_TARGET_USER_ID,
	DATA_TARGET_ID,
	DATA_AUTH_TYPE,
	DATA_TIME,
	DATA_NAME,
	DATA_GROUP,
	DATA_OFFSET,
	DATA_SIZE
}

enum
{
	TIME_SET = 0,
	TIME_ADD,
	TIME_TAKE
}

enum
{
	MENU_TYPE_ADD = 0,
	MENU_TYPE_EDIT
}

enum GameType
{
	GAME_UNKNOWN = -1,
	GAME_CSS_34,
	GAME_CSS,
	GAME_CSGO
}

#define FEATURE_NAME_LENGTH 64

// new bool:g_bIsVIPLoaded = false;

new const String:g_sLogFile[] = "addons/sourcemod/logs/VIP_Logs.log";

// new bool:g_bDBMySQL;

new Handle:g_hHookPlugins;

new Handle:g_hGroups;
new Handle:g_hDatabase;

/*new Handle:g_hTopMenu;
*/
new Handle:g_hVIPMenu;
new Handle:g_hVIPAdminMenu;
new Handle:g_hSortArray;

new Handle:g_hFeatures[MAXPLAYERS+1];
new Handle:g_hFeatureStatus[MAXPLAYERS+1];

new Handle:g_ClientData[MAXPLAYERS+1];

new g_iClientInfo[MAXPLAYERS+1];

// Cvar`s
new Handle:	g_CVAR_hVIPMenu_CMD;

new 		g_CVAR_iAdminFlag;
new 		g_CVAR_iServerID;
new 		g_CVAR_iTimeMode;
new			g_CVAR_iDeleteExpired;
new Float:	g_CVAR_fSpawnDelay;
new bool:	g_CVAR_bAutoOpenMenu;
new bool:	g_CVAR_bKickNotAuthorized;
new bool:	g_CVAR_bUpdateName;
new bool:	g_CVAR_bHideNoAccessItems;
new bool:	g_CVAR_bLogsEnable;

new GameType:g_GameType;

new Handle:g_hGlobalForward_OnVIPLoaded;
new Handle:g_hGlobalForward_OnClientLoaded;
new Handle:g_hGlobalForward_OnVIPClientLoaded;
new Handle:g_hGlobalForward_OnVIPClientRemoved;
new Handle:g_hGlobalForward_OnPlayerSpawn;
new Handle:g_hPrivateForward_OnPlayerSpawn;
/*
new TopMenuObject:VIPAdminMenuObject = INVALID_TOPMENUOBJECT;
*/
