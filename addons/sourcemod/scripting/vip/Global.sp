#define GLOBAL_INFO			g_iClientInfo[0]

#define UID(%0) 			GetClientUserId(%0)
#define CID(%0) 			GetClientOfUserId(%0)
#define SZF(%0) 			%0, sizeof(%0)
#define SZFA(%0,%1)         %0[%1], sizeof(%0[])


#define I2S(%0,%1) 			IntToString(%0, SZF(%1))
//#define I2S(%0,%1,%2) 		IntToString(%0,%1,%2)
#define S2I(%0) 			StringToInt(%0)


#define PMP                 PLATFORM_MAX_PATH
#define MNL                	MAX_NAME_LENGTH
#define MPL                 MAXPLAYERS
#define MCL                 MaxClients

#define SET_BIT(%0,%1) 		%0 |= %1
#define UNSET_BIT(%0,%1) 	%0 &= ~%1

#define IS_VIP						(1<<0)	// Player is a VIP
#define IS_LOADED					(1<<1)	// Player is loaded
#define IS_WAIT_CHAT_PASS			(1<<2)	// Waiting for a password in chat
#define IS_WAIT_CHAT_SEARCH			(1<<3)	// Waiting for a search value in chat
#define IS_SPAWNED					(1<<4)	// Player has spawned
#define IS_MENU_OPEN				(1<<5)	// VIP menu is open

#define IS_STARTED					(1<<0)
#define IS_MySQL					(1<<1)
#define IS_LOADING					(1<<2)

#define REASON_PLUGIN	-2
#define REASON_EXPIRED	-3
#define REASON_OUTDATED	-4

stock const char KEY_CID[]		= "Core->ClientID";
stock const char KEY_EXPIRES[]	= "Core->Expires";
stock const char KEY_GROUP[]	= "Core->Group";
stock const char KEY_MENUITEM[]	= "Core->SelectionItem";

enum struct Feature
{
	Handle			hPlugin;
	VIP_ValueType	eValType;
	VIP_FeatureType	eType;
	VIP_ToggleState	eDefStatus;
	Cookie			hCookie;		// TOGGLABLE, or SELECTABLE registered with bCookie; null otherwise
	Function		fnSelect;
	Function		fnDisplay;
	Function		fnDraw;
}

enum
{
	TIME_MODE_SECONDS = 0,
	TIME_MODE_MINUTES,
	TIME_MODE_HOURS,
	TIME_MODE_DAYS
}

stock const char g_szValueType[][] = {
	"VIP_NULL",
	"INT",
	"FLOAT",
	"BOOL",
	"STRING"
};

stock const char g_szFeatureType[][] = {
	"TOGGLABLE",
	"SELECTABLE",
	"HIDE"
};

stock const char g_szToggleState[][] = {
	"DISABLED",
	"ENABLED",
	"NO_ACCESS"
};

#define FEATURE_NAME_LENGTH 64

char		g_szLogFile[PMP];

KeyValues	g_hGroups;
KeyValues	g_hInfo;

Database	g_hDatabase;

Menu		g_hVIPMenu;

ArrayList	g_hFeaturesArray;		// Feature names in registration order
StringMap	g_hFeatureRegistry;		// Feature name -> Feature
ArrayList	g_hSortArray;

StringMap	g_hFeatures[MAXPLAYERS+1];
StringMap	g_hFeatureStatus[MAXPLAYERS+1];

StringMap	g_hClientData[MAXPLAYERS+1];

int			g_iClientInfo[MAXPLAYERS+1];

int			g_iMaxPageItems;

// Cvar`s
ConVar		g_CVAR_hVIPMenu_CMD;

int 		g_CVAR_iAdminFlag;
int 		g_CVAR_iServerID;
int 		g_CVAR_iStorageID;
int 		g_CVAR_iTimeMode;
int			g_CVAR_iDeleteExpired;
int			g_CVAR_iOutdatedExpired;
float		g_CVAR_fSpawnDelay;
bool		g_CVAR_bAutoOpenMenu;
bool		g_CVAR_bUpdateName;
bool		g_CVAR_bHideNoAccessItems;
bool		g_CVAR_bDefaultStatus;
bool		g_CVAR_bLogsEnable;

EngineVersion	g_EngineVersion;

char		g_szSID[64];
