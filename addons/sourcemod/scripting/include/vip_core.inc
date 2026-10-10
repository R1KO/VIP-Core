#if defined _vip_core_included
 #endinput
#endif
#define _vip_core_included

#define VIP_CORE_INTERFACE 310

/* VIP feature data types */
enum VIP_ValueType
{
	VIP_NULL	= 0,	// No data
	INT,				// Integer type
	FLOAT,				// Floating-point type
	BOOL,				// Boolean type (1/0)
	STRING				// String type
}

/* VIP feature statuses */
enum VIP_ToggleState
{
	DISABLED = 0,		// Disabled
	ENABLED,			// Enabled
	NO_ACCESS			// No access
}

/* VIP feature types */
enum VIP_FeatureType
{
	TOGGLABLE = 0,		// Toggled on/off in the menu
	SELECTABLE,			// Press only
	HIDE				// Hidden
}

typeset ItemSelectCallback
{
	/**
	 *	Called when a VIP player selects a menu item (for the TOGGLABLE type).
	 *
	 * @param iClient			Client index.
	 * @param szFeature			Unique feature name.
	 * @param eOldStatus		Old status.
	 * @param eNewStatus		New status.
	 *
	 * @return					Plugin_Stop or Plugin_Handled - stops the status change;
	 *							Plugin_Continue - allows the status change as is;
	 *							Plugin_Changed - allows the status change to eNewStatus.
	*/
	function Action (int iClient, const char[] szFeature, VIP_ToggleState eOldStatus, VIP_ToggleState &eNewStatus);

	/**
	 *	Called when a VIP player selects a menu item (for the SELECTABLE type).
	 *
	 * @param iClient			Client index.
	 * @param szFeature			Unique feature name.
	 *
	 * @return					true - reopens the VIP menu for the player;
	 * 							false.
	*/
	function bool (int iClient, const char[] szFeature);
};

/**
 *	Called when a menu item is displayed to a VIP player.
 *
 * @param iClient			Client index.
 * @param szFeature			Unique feature name.
 * @param szDisplay			Buffer.
 * @param iMaxLength		Buffer size.
 *
 * @return					true - display the contents of szDisplay.
 * 							false - display unchanged.
*/
typedef ItemDisplayCallback = function bool (int iClient, const char[] szFeature, char[] szDisplay, int iMaxLength);

/**
 *	Called when the style of a menu item is displayed to a VIP player.
 *
 * @param iClient			Client index.
 * @param szFeature			Unique feature name.
 * @param iStyle			Style.
 *
 * @return					Required style (ITEMDRAW_*).
*/
typedef ItemDrawCallback = function int (int iClient, const char[] szFeature, int iStyle);

/**
 *	Called when a player spawns.
 *
 * @param iClient			Client index.
 * @param iTeam				Player team (2 - T, 3 - CT).
 * @param bIsVIP			Whether the player has VIP status.
 *
 * @noreturn
*/
forward void VIP_OnPlayerSpawn(int iClient, int iTeam, bool bIsVIP);

/**
 *	Called when information is displayed to a player.
 *
 * @param iClient			Client index.
 * @param szEvent			Event name:
 * 								"connect_info_time"	- VIP player joined the server (timed VIP status);
 * 								"connect_info_perm"	- VIP player joined the server (permanent VIP status);
 * 								"no_access_info" 	- Player tried to open the VIP menu;
 * 								"connect_info_time"	- Player's VIP status expired.
 * @param szType			Message type:
 * 								"chat"	- In chat;
 * 								"menu"	- In a menu;
 * 								"url"	- In a MOTD window.
 * @param hKeyValues		KeyValues of the event key.
 *
 * @return					Plugin_Stop or Plugin_Handled  - blocks the notification;
 * 							Plugin_Changed - allows it with changes;
 * 							Plugin_Continue - allows it unchanged.
*/
forward Action VIP_OnShowClientInfo(int iClient, const char[] szEvent, const char[] szType, KeyValues hKeyValues);

/**
 *	Called when a feature status changes for a VIP player.
 *
 * @param iClient			Client index.
 * @param szFeature			Unique feature name.
 * @param eOldStatus		Old status.
 * @param eNewStatus		New status.
 *
 * @return					Plugin_Stop or Plugin_Handled  - stops the status change;
 * 							Plugin_Continue  - allows the status change as is;
 * 							Plugin_Changed - allows the status change to eNewStatus.
*/
forward Action VIP_OnFeatureToggle(int iClient, const char[] szFeature, VIP_ToggleState eOldStatus, VIP_ToggleState &eNewStatus);

/**
 *	Called when the VIP plugin has loaded.
 *
 * @noparams
 *
 * @noreturn
*/
forward void VIP_OnVIPLoaded();

/**
 *	Called when the VIP plugin has loaded its settings (on start and on config reload).
 *
 * @noparams
 *
 * @noreturn
*/
forward void VIP_OnConfigsLoaded();

/**
 *	Called when the player's storage has loaded (VIP_SetClientStorageValue / VIP_GetClientStorageValue).
 *
 * @param iClient			Client index.
 *
 * @noreturn
*/
forward void VIP_OnClientStorageLoaded(int iClient);

/**
 *	Called when a VIP feature has been registered.
 *
 * @param szFeature			Unique feature name.
 *
 * @noreturn
*/
forward void VIP_OnFeatureRegistered(const char[] szFeature);

/**
 *	Called when a VIP feature has been unregistered.
 *
 * @param szFeature			Unique feature name.
 *
 * @noreturn
*/
forward void VIP_OnFeatureUnregistered(const char[] szFeature);

/**
 *	Called before a player is checked for VIP status.
 *
 * @param iClient			Client index.
 *

 * @return					true - continue.
 * 							false - skip the check.
*/
forward bool VIP_OnClientPreLoad(int iClient);

/**
 *	Called when a player has been loaded.
 *
 * @param iClient			Client index.
 * @param bIsVIP			Whether the player has VIP status.
 *
 * @noreturn
*/
forward void VIP_OnClientLoaded(int iClient, bool bIsVIP);

/**
 *	Called when a VIP player has been loaded.
 *
 * @param iClient			Client index.
 *
 * @noreturn
*/
forward void VIP_OnVIPClientLoaded(int iClient);

/**
 *	Called when a player is disconnecting.
 *
 * @param iClient			Client index.
 * @param bIsVIP			Whether the player has VIP status.
 *
 * @noreturn
*/
forward void VIP_OnClientDisconnect(int iClient, bool bIsVIP);

/**
 *	Called when a player receives VIP status.
 *
 * @param iClient			Client index.
 * @param iAdmin			Who gave it: admin index (> 0), 0 - server,
 * 							-1 - admin who left before the database answered,
 * 							-2 - plugin (VIP_GiveClientVIP).
 * 							Check iAdmin > 0 before using it as a client index.
 *
 * @noreturn
*/
forward void VIP_OnVIPClientAdded(int iClient, int iAdmin);

/**
 *	Called when a player loses VIP status.
 *
 * @param iClient			Client index.
 * @param szReason			Reason:
 * 								"Expired" - Expired;
 * 								"Removed by Admin" - Removed by an admin;
 * 								"VIP-Group Changed" - Group changed by an admin;
 * 								"Removed for VIP-status change" - VIP given again via VIP_GiveClientVIP;
 * 								"Removed by <plugin name>" - Removed via VIP_RemoveClientVIP2.
 * @param iAdmin			Who removed it: admin index (> 0), 0 - server (expiry),
 * 							-2 - plugin.
 * 							Check iAdmin > 0 before using it as a client index.
 *
 * @noreturn
*/
forward void VIP_OnVIPClientRemoved(int iClient, const char[] szReason, int iAdmin);

/**
 *	Starts checking a player for VIP rights.
 *
 * @param iClient			Client index.
 * @param bNotify			Whether to notify the player of the check result.
 * @param bForward			Whether to call the VIP_OnClientPreLoad forward before the check.
 *
 * @noreturn
*/
native void VIP_CheckClient(int iClient, bool bNotify = false, bool bForward = true);

/**
 *	Checks whether a player has VIP rights.
 *
 * @param iClient			Client index.
 *
 * @return					true - the player has VIP status.
 * 							false - the player has no VIP status.
*/
native bool VIP_IsClientVIP(int iClient);

/**
 *	Gets the unique ID of a VIP player.
 *
 * @param iClient			Client index.
 *
 * @return					Unique ID, or -1 if temporary.
*/
native int VIP_GetClientID(int iClient);

/**
 *	Gets the expiration time of a player's VIP rights (unix).
 *
 * @param iClient			Client index.
 *
 * @return					Unix timestamp (0 - permanent, -1 on failure).
*/
native int VIP_GetClientAccessTime(int iClient);

/**
 *	Sets the expiration time of a player's VIP rights (unix).
 *
 * @param iClient			Client index.
 * @param iTime				Unix timestamp, 0 if permanent, -1 if temporary.
 * @param bInDB				Whether to update the database.
 *
 * @return					true - on success.
 * 							false - on failure.
*/
native bool VIP_SetClientAccessTime(int iClient, int iTime, bool bInDB = true);

/**
 *	Gets a player's VIP group.
 *
 * @param iClient			Client index.
 * @param szGroup			Buffer to store the result in.
 * @param iMaxLength		Buffer size.
 *
 * @return					true - on success.
 * 							false - on failure.
*/
native bool VIP_GetClientVIPGroup(int iClient, char[] szGroup, int iMaxLength);

/**
 *	Sets a player's VIP group.
 *
 * @param iClient			Client index.
 * @param szGroup			VIP group.
 * @param bInDBB			Whether to update the database.
 *
 * @return					true - on success.
 * 							false - on failure.
*/
native bool VIP_SetClientVIPGroup(int iClient, const char[] szGroup, bool bInDB = true);

/**
 *	Gets the adt trie handle of a VIP player's settings.
 *
 * @param iClient			Client index.
 *
 * @return					StringMap (Handle) adt trie of the VIP player's settings.
*/
native StringMap VIP_GetVIPClientTrie(int iClient);

/**
 *	Checks whether a group exists.
 *
 * @param szGroup			Group name.
 *
 * @return					true - the group exists.
 * 							false - the group does not exist.
*/	
native bool VIP_IsGroupExists(const char[] szGroup);

#pragma deprecated Use VIP_IsGroupExists() instead
native bool VIP_IsValidVIPGroup(const char[] szGroup);

/**
 *	Adds a group (in memory only, groups.ini is not modified).
 *	Groups are reset when configs are reloaded; add them again in VIP_OnConfigsLoaded().
 *
 * @param szGroup			Group name.
 * @param hFeatures			Group parameters (keys from the current position are copied into the group).
 *
 * @return					true - on success.
 * 							false - the group already exists.
*/	
native bool VIP_AddGroup(const char[] szGroup, KeyValues hFeatures);

/**
 *	Removes a group (in memory only, groups.ini is not modified).
 *
 * @param szGroup			Group name.
 *
 * @return					true - on success.
 * 							false - the group does not exist.
*/	
native bool VIP_RemoveGroup(const char[] szGroup);

/**
 *	Saves a value to the player's storage (vip_storage table).
 *	The storage is available for all players (not only VIP) after VIP_OnClientStorageLoaded();
 *	before that, the call is ignored. It is written to the database when the player disconnects.
 *
 * @param iClient			Client index.
 * @param szKey				Key (up to 127 characters).
 * @param szValue			Value (up to 255 characters).
 *
 * @noreturn
*/
native void VIP_SetClientStorageValue(int iClient, const char[] szKey, const char[] szValue);

/**
 *	Gets a value from the player's storage.
 *
 * @param iClient			Client index.
 * @param szKey				Key.
 * @param szValue			Buffer to store the result in (empty string if there is no value).
 * @param iMaxLength		Buffer size.
 *
 * @noreturn
*/
native void VIP_GetClientStorageValue(int iClient, const char[] szKey, char[] szValue, int iMaxLength);

/**
 *	Prints a chat message to a player with a prefix (translation phrase "VIP_CHAT_PREFIX").
 *
 * @param iClient			Client index.
 * @param szMessage			Formatting rules.
 * @param ...				Formatting parameters.
 *
 * @noreturn
*/
native void VIP_PrintToChatClient(int iClient, const char[] szMessage, any ...);

/**
 *	Prints a chat message to all players with a prefix (translation phrase "VIP_CHAT_PREFIX").
 *
 * @param szMessage			Formatting rules.
 * @param ...				Formatting parameters.
 *
 * @noreturn
*/
native void VIP_PrintToChatAll(const char[] szMessage, any ...);

/**
 *	Writes a message to the log.
 *
 * @param szMessage			Formatting rules.
 * @param ...				Formatting parameters.
 *
 * @noreturn
*/
native void VIP_LogMessage(const char[] szMessage, any ...);

/**
 *	Opens the VIP menu for a player.
 *
 * @param iClient			Client index.
 * @param bSelection		Open mode:
 * 							true - on the first page;
 * 							false - on the page of the last selected item.
 *
 * @noreturn
*/
native void VIP_SendClientVIPMenu(int iClient, bool bSelection = false);

/**
 *	Gives VIP rights to a player.
 *
 * @param iAdmin			Admin index, 0 - server, -1 or any negative - plugin (default).
 * 							Logged as "by server" / "by plugin <name>" / "by admin <name>".
 * @param iClient			Client index.
 * @param iTime				Time in seconds.
 * @param szGroup			VIP group name.
 * @param bAddToDB			Whether to add to the database.
 *
 * @noreturn
*/
native void VIP_GiveClientVIP(int iAdmin = -1, int iClient, int iTime, const char[] szGroup, bool bAddToDB = true);

#pragma deprecated Use VIP_GiveClientVIP() instead
native bool VIP_SetClientVIP(int iClient, int iTime, any AuthType, const char[] szGroup, bool bAddToDB = true);

/**
 *	Removes VIP rights from a player.
 *
 * @param iAdmin			Admin index, 0 - server, -1 or any negative - plugin (default).
 * 							Logged as "by server" / "by plugin <name>" / "by admin <name>".
 * @param iClient			Client index.
 * @param bInDB				Whether to remove from the database.
 * @param bNotify			Player notification (true - notify / false - do not notify).
 *
 * @return					true - on success.
 * 							false - on failure.
*/
native bool VIP_RemoveClientVIP2(int iAdmin = -1, int iClient, bool bInDB, bool bNotify);

#pragma deprecated Use VIP_RemoveClientVIP2() instead
native bool VIP_RemoveClientVIP(int iClient, bool bInDB, bool bNotify);

/**
 *	Checks that the core is loaded and ready for feature registration.
 *
 * @noparams
 *
 * @return					true - the core is loaded.
 * 							false - the core is not loaded.
*/
native bool VIP_IsVIPLoaded();

/**
 *	Registers a new VIP feature.
 *
 * @param szFeature				Unique feature name.
 * @param ValType				Feature data type.
 * @param FeatureType			Feature type.
 * @param Item_select_callback	Callback for a feature status change.
 * @param Item_display_callback	Callback for displaying the feature menu item.
 * @param Item_draw_callback	Callback for displaying the feature menu item style.
 * @param eDefStatus			Default status:
 * 									ENABLED - Enabled
 * 									DISABLED - Disabled
 * 									NO_ACCESS - Not set (depends on sm_vip_features_default_status)
 * @param bCookie				Whether to register a cookie for the feature (valid only for the SELECTABLE type).
 *
 * @noreturn
*/

native void VIP_RegisterFeature(const char[]			szFeature,
								VIP_ValueType			eValType				= VIP_NULL,
								VIP_FeatureType			eType					= TOGGLABLE,
								ItemSelectCallback		Item_select_callback	= INVALID_FUNCTION,
								ItemDisplayCallback		Item_display_callback	= INVALID_FUNCTION,
								ItemDrawCallback		Item_draw_callback		= INVALID_FUNCTION,
								VIP_ToggleState			eDefStatus				= NO_ACCESS,
								bool					bCookie					= false);

/**
 *	Unregisters a VIP feature.
 *
 * @param szFeature				Unique feature name.
 *
 * @noreturn
*/
native void VIP_UnregisterFeature(const char[] szFeature);

/**
 *	Unregisters all VIP features registered by the plugin (call in OnPluginEnd()).
 *
 * @noparams
 *
 * @noreturn
*/
native void VIP_UnregisterMe();

/**
 *	Checks whether a feature exists.
 *
 * @param szFeature			Unique feature name.
 *
 * @return					true - the VIP feature exists.
 * 							false -  the VIP feature does not exist.
*/
native bool VIP_IsValidFeature(const char[] szFeature);

/**
 *	Gets the feature type.
 *
 * @param szFeature			Unique feature name.
 *
 * @return					A VIP_FeatureType value.
*/
native VIP_FeatureType VIP_GetFeatureType(const char[] szFeature);

/**
 *	Gets the feature value type.
 *
 * @param szFeature			Unique feature name.
 *
 * @return					A VIP_ValueType value.
*/
native VIP_ValueType VIP_GetFeatureValueType(const char[] szFeature);

/**
 *	Fills an adt array with feature names.
 *
 * @param hArray			ArrayList array.
 *
 * @return					Number of added elements.
*/
native int VIP_FillArrayByFeatures(ArrayList hArray);

/**
 *	Gets a player's VIP feature status.
 *
 * @param iClient			Client index.
 * @param szFeature			Unique feature name.
 *
 * @return					A VIP_ToggleState value.
*/
native VIP_ToggleState VIP_GetClientFeatureStatus(int iClient, const char[] szFeature);

/**
 *	Sets a player's VIP feature status.
 *
 * @param iClient			Client index.
 * @param szFeature			Unique feature name.
 * @param eStatus			VIP feature status.
 * @param bCallback			Whether to call the toggle callback.
 * @param bSave				Whether to save to the cookie.
 *
 * @return					true - on success.
 * 							false - on failure.
*/
native bool VIP_SetClientFeatureStatus(int iClient, const char[] szFeature, VIP_ToggleState eStatus, bool bCallback = true, bool bSave = false);

/**
 *	Checks whether a player's VIP feature is enabled.
 *
 * @param iClient			Client index.
 * @param szFeature			Unique feature name.
 *
 * @return					true - the VIP feature is enabled.
 * 							false - the VIP feature is disabled or the player has no access.
*/
native bool VIP_IsClientFeatureUse(int iClient, const char[] szFeature);

/**
 *	Gets the integer value of a player's VIP feature parameter.
 *
 * @param iClient			Client index.
 * @param szFeature			Unique feature name.
 *
 * @return					Integer value of the player's VIP feature parameter.
*/
native int VIP_GetClientFeatureInt(int iClient, const char[] szFeature);

/**
 *	Gets the float value of a player's VIP feature parameter.
 *
 * @param iClient			Client index.
 * @param szFeature			Unique feature name.
 *
 * @return					Float value of the player's VIP feature parameter.
*/
native float VIP_GetClientFeatureFloat(int iClient, const char[] szFeature);

/**
 *	Gets the boolean value of a player's VIP feature parameter.
 *
 * @param iClient			Client index.
 * @param szFeature			Unique feature name.
 *
 * @return					Boolean value of the player's VIP feature parameter (true/false).
*/
native bool VIP_GetClientFeatureBool(int iClient, const char[] szFeature);

/**
 *	Gets the string value of a player's VIP feature parameter.
 *
 * @param iClient			Client index.
 * @param szFeature			Unique feature name.
 * @param szBuffer			Buffer to store the result in.
 * @param iMaxLength		Buffer size.
 *
 * @noreturn
*/
native void VIP_GetClientFeatureString(int iClient, const char[] szFeature, char[] szBuffer, int iMaxLength);

/**
 *	Gives a VIP feature to a player and sets its value (for the session).
 *
 * @param iClient			Client index.
 * @param szFeature			Unique feature name.
 * @param szValue			Value (automatically converted to the feature type).
 *
 * @return					true - on success.
 * 							false - on failure.
*/
native bool VIP_GiveClientFeature(int iClient, const char[] szFeature, const char[] szValue);

/**
 *	Removes a VIP feature from a VIP player (for the session).
 *
 * @param iClient			Client index.
 * @param szFeature			Unique feature name.
 *
 * @return					true - on success.
 * 							false - on failure.
*/
native bool VIP_RemoveClientFeature(int iClient, const char[] szFeature);

/**
 *	Gets the database handle. After use, it must be closed with CloseHandle() or delete
 *
 *	@noparams
 *
 *	@return					Database (Handle), or null if the core has not connected to the database yet (before VIP_OnVIPLoaded)
*/
native Database VIP_GetDatabase();

/**
 *	Gets the database type.
 *
 *	@noparams
 *
 * @return					true - MySQL.
 * 							false - SQLite.
*/
native bool VIP_GetDatabaseType();

/**
 *	Converts a time value to seconds according to sm_vip_time_mode.
 *
 * @param iTime				Time.
 *
 * @return					Number of seconds according to sm_vip_time_mode.
 * 							-1 - unknown sm_vip_time_mode, or the result does not fit into an int.
*/
native int VIP_TimeToSeconds(int iTime);

/**
 *	Converts seconds to a time value according to sm_vip_time_mode.
 *
 * @param iTime				Number of seconds.
 *
 * @return					Time value according to sm_vip_time_mode.
*/
native int VIP_SecondsToTime(int iTime);

/**
 *	Converts seconds to a human-readable string.
 *
 * @param szBuffer			Buffer to store the result in.
 * @param iMaxLength		Buffer size.
 * @param iTimeStamp		Number of seconds.
 * @param iClient			Client index or LANG_SERVER.
 *
 * @return					true - on success.
 * 							false - on failure.
*/
native bool VIP_GetTimeFromStamp(char[] szBuffer, int iMaxLength, int iTimeStamp, int iClient = LANG_SERVER);

/**
 *	Appends the feature status to a string.
 *
 * @param szInput			Source string.
 * @param szBuffer			Buffer to store the result in.
 * @param iMaxLength		Buffer size.
 * @param szFeature			Unique feature name.
 * @param iClient			Client index.
 *
 * @noreturn
*/
native void VIP_AddStringToggleStatus(const char[] szInput, char[] szBuffer, int iMaxLength, const char[] szFeature, int iClient);

public SharedPlugin __pl_vip_core= 
{
	name = "vip_core",
	file = "VIP_Core.smx",
#if defined REQUIRE_PLUGIN
	required = 1
#else
	required = 0
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_vip_core_SetNTVOptional()
{
	MarkNativeAsOptional("VIP_IsVIPLoaded");
	MarkNativeAsOptional("VIP_GetDatabase");
	MarkNativeAsOptional("VIP_GetDatabaseType");
	MarkNativeAsOptional("VIP_RegisterFeature");
	MarkNativeAsOptional("VIP_UnregisterFeature");
	MarkNativeAsOptional("VIP_IsValidFeature");
	MarkNativeAsOptional("VIP_GetFeatureType");
	MarkNativeAsOptional("VIP_GetFeatureValueType");
	MarkNativeAsOptional("VIP_SetFeatureDefStatus");
	MarkNativeAsOptional("VIP_FillArrayByFeatures");
	MarkNativeAsOptional("VIP_SetClientVIP");
	MarkNativeAsOptional("VIP_RemoveClientVIP");
	MarkNativeAsOptional("VIP_RemoveClientVIP2");
	MarkNativeAsOptional("VIP_CheckClient");
	MarkNativeAsOptional("VIP_IsClientVIP");
	MarkNativeAsOptional("VIP_GetClientID");
	MarkNativeAsOptional("VIP_GetClientVIPGroup");
	MarkNativeAsOptional("VIP_SetClientVIPGroup");
	MarkNativeAsOptional("VIP_GetClientAccessTime");
	MarkNativeAsOptional("VIP_SetClientAccessTime");
	MarkNativeAsOptional("VIP_GetVIPClientTrie");
	MarkNativeAsOptional("VIP_SendClientVIPMenu");
	MarkNativeAsOptional("VIP_IsValidVIPGroup");
	MarkNativeAsOptional("VIP_IsGroupExists");
	MarkNativeAsOptional("VIP_AddGroup");
	MarkNativeAsOptional("VIP_RemoveGroup");
	MarkNativeAsOptional("VIP_SetClientStorageValue");
	MarkNativeAsOptional("VIP_GetClientStorageValue");
	MarkNativeAsOptional("VIP_GetClientFeatureStatus");
	MarkNativeAsOptional("VIP_SetClientFeatureStatus");
	MarkNativeAsOptional("VIP_IsClientFeatureUse");
	MarkNativeAsOptional("VIP_GetClientFeatureInt");
	MarkNativeAsOptional("VIP_GetClientFeatureFloat");
	MarkNativeAsOptional("VIP_GetClientFeatureBool");
	MarkNativeAsOptional("VIP_GetClientFeatureString");
	MarkNativeAsOptional("VIP_PrintToChatClient");
	MarkNativeAsOptional("VIP_PrintToChatAll");
	MarkNativeAsOptional("VIP_LogMessage");
	MarkNativeAsOptional("VIP_TimeToSeconds");
	MarkNativeAsOptional("VIP_SecondsToTime");
	MarkNativeAsOptional("VIP_GetTimeFromStamp");
	MarkNativeAsOptional("VIP_AddStringToggleStatus");
	MarkNativeAsOptional("VIP_GiveClientVIP");
	MarkNativeAsOptional("VIP_UnregisterMe");
	MarkNativeAsOptional("VIP_GiveClientFeature");
	MarkNativeAsOptional("VIP_RemoveClientFeature");
}
#endif
