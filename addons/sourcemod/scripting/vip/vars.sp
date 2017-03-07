#define GLOBAL_ARRAY		g_hFeatureStatus[0]
#define GLOBAL_TRIE			g_hFeatures[0]

#define GLOBAL_INFO_KV		g_ClientData[0]

#define GLOBAL_INFO			g_iClientInfo[0]

#define UID(%0) 	GetClientUserId(%0)
#define CID(%0) 	GetClientOfUserId(%0)
#define SZF(%0) 	%0, sizeof(%0)

#define SET_BIT(%0,%1) 		%0 |= %1
#define UNSET_BIT(%0,%1) 	%0 &= ~%1

#define IS_VIP						(1<<0)	// VIP ли игрок
#define IS_AUTHORIZED				(1<<1)	// Авторизирован ли игрок
#define IS_LOADED					(1<<2)	// Загружен ли игрок
#define IS_WAIT_CHAT_PASS			(1<<3)	// Ожидается ввод пароля в чат
#define IS_WAIT_CHAT_SEARCH			(1<<4)	// Ожидается ввод значения для поиска в чат
#define IS_SPAWNED					(1<<5)	// Игрок возродился
#define IS_MENU_OPEN				(1<<6)	// VIP-меню открыто

#define IS_STARTED					(1<<0)
#define IS_MySQL					(1<<1)
#define IS_LOADING					(1<<2)


#define	KEY_CID			"ClientID"
#define	KEY_EXPIRES		"expires"
#define	KEY_GROUP		"vip_group"
#define	KEY_AUTHTYPE	"AuthType"

enum
{
	FEATURES_PLUGIN = 0, 
	FEATURES_VALUE_TYPE, 
	FEATURES_COOKIE, 
	FEATURES_ITEM_TYPE, 
	FEATURES_MENU_CALLBACKS
}

DataPackPos ITEM_SELECT = view_as<DataPackPos>(0);
DataPackPos ITEM_DISPLAY = view_as<DataPackPos>(9);
DataPackPos ITEM_DRAW = view_as<DataPackPos>(18);

enum
{
	TIME_MODE_SECONDS = 0, 
	TIME_MODE_MINUTES, 
	TIME_MODE_HOURS, 
	TIME_MODE_DAYS
}

enum GameType
{
	GAME_UNKNOWN = -1, 
	GAME_CSS_34, 
	GAME_CSS, 
	GAME_CSGO
}

#define FEATURE_NAME_LENGTH 64

static const char g_sLogFile[] = "addons/sourcemod/logs/VIP_Logs.log";

new Handle:g_hGroups;
new Handle:g_hDatabase;

#if USE_ADMINMENU 1
new Handle:g_hTopMenu;
new Handle:g_hVIPAdminMenu;
#endif

new Handle:g_hVIPMenu;

new Handle:g_hSortArray;

new Handle:g_hFeatures[MAXPLAYERS + 1];
new Handle:g_hFeatureStatus[MAXPLAYERS + 1];

new Handle:g_ClientData[MAXPLAYERS + 1];

new g_iClientInfo[MAXPLAYERS + 1];

// Cvar`s
new Handle:g_CVAR_hVIPMenu_CMD;

new g_CVAR_iAdminFlag;
new g_CVAR_iServerID;
new g_CVAR_iTimeMode;
new g_CVAR_iDeleteExpired;
float g_CVAR_fSpawnDelay;
bool g_CVAR_bAutoOpenMenu;
#if USE_ADMINMENU 1
bool g_CVAR_bAddItemToAdminMenu;
#endif
bool g_CVAR_bKickNotAuthorized;
bool g_CVAR_bUpdateName;
bool g_CVAR_bHideNoAccessItems;
bool g_CVAR_bLogsEnable;

new EngineVersion:g_EngineVersion;

new Handle:g_hGlobalForward_OnVIPLoaded;
new Handle:g_hGlobalForward_OnClientLoaded;
new Handle:g_hGlobalForward_OnVIPClientLoaded;
new Handle:g_hGlobalForward_OnVIPClientAdded;
new Handle:g_hGlobalForward_OnVIPClientRemoved;
new Handle:g_hGlobalForward_OnPlayerSpawn;

#if USE_ADMINMENU 1
new TopMenuObject:VIPAdminMenuObject = INVALID_TOPMENUOBJECT;
#endif
