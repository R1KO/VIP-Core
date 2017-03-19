#define GLOBAL_TRIE			g_hFeatures[0]
#define GLOBAL_INFO			g_iClientInfo[0]

#define UID(%0) 	GetClientUserId(%0)
#define CID(%0) 	GetClientOfUserId(%0)
#define SZF(%0) 	%0, sizeof(%0)

#define SET_BIT(%0,%1) 		%0 |= %1
#define UNSET_BIT(%0,%1) 	%0 &= ~%1

#define IS_VIP						(1<<0)	// VIP ли игрок
#define IS_LOADED					(1<<1)	// Загружен ли игрок
#define IS_WAIT_CHAT_PASS			(1<<2)	// Ожидается ввод пароля в чат
#define IS_WAIT_CHAT_SEARCH			(1<<3)	// Ожидается ввод значения для поиска в чат
#define IS_SPAWNED					(1<<4)	// Игрок возродился
#define IS_MENU_OPEN				(1<<5)	// VIP-меню открыто

#define IS_STARTED					(1<<0)
#define IS_MySQL					(1<<1)
#define IS_LOADING					(1<<2)

/*
#define	KEY_CID			"Core->ClientID"
#define	KEY_EXPIRES		"Core->Expires"
#define	KEY_GROUP		"Core->Group"
#define	KEY_AUTHTYPE	"Core->AuthType"
*/

char	KEY_CID[]		= "Core->ClientID";
char	KEY_EXPIRES[]	= "Core->Expires";
char	KEY_GROUP[]		= "Core->Group";
char	KEY_AUTHTYPE[]	= "Core->AuthType";

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

char g_sToggleStatus[][] =
{
	"DISABLED",
	"ENABLED",
	"NO_ACCESS"
};

#define FEATURE_NAME_LENGTH 64

static const char g_sLogFile[] = "addons/sourcemod/logs/VIP_Logs.log";

KeyValues	g_hGroups;
KeyValues	g_hInfo;

Database	g_hDatabase;

#if USE_ADMINMENU 1
TopMenu		g_hTopMenu;
Menu		g_hVIPAdminMenu;
#endif

Menu		g_hVIPMenu;

ArrayList	g_hFeaturesArray;
ArrayList	g_hSortArray;

StringMap	g_hFeatures[MAXPLAYERS + 1];
StringMap	g_hFeatureStatus[MAXPLAYERS + 1];

ArrayList	g_ClientData[MAXPLAYERS + 1];

int			g_iClientInfo[MAXPLAYERS + 1];

// Cvar`s
ConVar		g_CVAR_hVIPMenu_CMD;

int 		g_CVAR_iAdminFlag;
int 		g_CVAR_iServerID;
int 		g_CVAR_iTimeMode;
int			g_CVAR_iDeleteExpired;
float		g_CVAR_fSpawnDelay;
bool		g_CVAR_bAutoOpenMenu;
#if USE_ADMINMENU 1
bool		g_CVAR_bAddItemToAdminMenu;
#endif
bool		g_CVAR_bUpdateName;
bool		g_CVAR_bHideNoAccessItems;
bool		g_CVAR_bLogsEnable;

Handle		g_hGlobalForward_OnVIPLoaded;
Handle		g_hGlobalForward_OnClientLoaded;
Handle		g_hGlobalForward_OnVIPClientLoaded;
Handle		g_hGlobalForward_OnVIPClientAdded;
Handle		g_hGlobalForward_OnVIPClientRemoved;
Handle		g_hGlobalForward_OnPlayerSpawn;
Handle		g_hGlobalForward_OnFeatureToggle;

EngineVersion	g_EngineVersion;

#if USE_ADMINMENU 1
TopMenuObject	VIPAdminMenuObject = INVALID_TOPMENUOBJECT;
#endif
