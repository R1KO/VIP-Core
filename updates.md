# [VIP] Core 3.0 DEV #41

### Changes:
- Improved SQL query formation for `USE_MORE_SERVERS`.

# [VIP] Core 3.0 DEV #40

### Changes:
- Changed native `VIP_RegisterFeature` (added parameter `bCookie` - whether to register cookies for the feature (only valid for the SELECTABLE type)).

# [VIP] Core 3.0 DEV #39

### Changes:
- Fixed error `SQL_Callback_RemoveClient: no such column: sid` on SQLite.

# [VIP] Core 3.0 DEV #38

### Changes:
- Fixed error `SQL_Callback_ErrorCheck: no such column: sid` on SQLite.

# [VIP] Core 3.0 DEV #37

### Changes:
- Fixed an error where expired VIP players were not being removed.

# [VIP] Core 3.0 DEV #36

### Changes:
- Now properly fixed the `Invalid Handle 0 (error 4)` error (`DB_RemoveClientFromID`).

# [VIP] Core 3.0 DEV #35

### Changes:
- Fixed error `Invalid Handle 0 (error 4)` (`DB_RemoveClientFromID`).

# [VIP] Core 3.0 DEV #34

### Changes:
- Native `VIP_RemoveClientVIP` is marked as deprecated and will be removed in the future.
- Added new native `VIP_RemoveClientVIP2`.
- Fixed error `Client index 0 is invalid` when adding a VIP player via `sm_addvip`.

# [VIP] Core 3.0 DEV #33

### Changes:
- Changed native `VIP_SetClientFeatureStatus`.
- Fixed error `SQL_Callback_SelectExpiredAndOutdated: Unknown column 'iTime' in 'where clause'`.
- Reworked the logging system.

# [VIP] Core 3.0 DEV #32 (thanks to DarklSide for finding the errors)

### Changes:
- Fixed the description of forward `VIP_OnClientPreLoad`.
- Fixed native `VIP_GiveClientFeature`.
- Fixed error `SQL_Callback_SelectExpiredAndOutdated: no such function: UNIX_TIMESTAMP` on SQLite.
- Fixed player nickname updates.
- Fixed DataPack handling on sm 1.10.

# [VIP] Core 3.0 DEV #31

### Changes:
- Added forward `VIP_OnClientPreLoad`.
- Fixed and enabled native `VIP_GiveClientFeature`.
- Added native `VIP_RemoveClientFeature`.
- Changed native `VIP_CheckClient`.
- Changed the default value of `sm_vip_delete_outdated` to `-1`.
- Fixed removal of expired and inactive players.

# [VIP] Core 3.0 DEV #30

### Changes:
- Fixed the VIP players list.

# [VIP] Core 3.0 DEV #29

### Changes:
- Fixed SQL errors.
- Minor optimization.
- Fixed debugging.

# [VIP] Core 3.0 DEV #28

### Changes:
- Fixed the error that prevented the plugin from starting: `Fatal error creating dynamic native!/unexpected error 23 in AskPluginLoad callback`.
- Changed the database name from `"vip"` to `"vip_core"` (already in version 3.0 DEV #25, just forgot to mention it).
- Fixed an attempt to set the encoding for the SQLite database.

# [VIP] Core 3.0 DEV #27

### Changes:
- Enabled the `sm_vip_delete_outdated` cvar.
- Full transition to the new database structure.

# [VIP] Core 3.0 DEV #26

### Changes:
- Restored the previous form of native VIP_SetClientVIP and marked it as deprecated.
- Added new native `VIP_GiveClientVIP` as a replacement for the deprecated `VIP_SetClientVIP`.
- Added backward compatibility for native `VIP_RemoveClientVIP`.
- Changed the table structure (MySQL).

# [VIP] Core 3.0 DEV #25

### Changes:
- Added use of `TranslationPhraseExists` to prevent errors (when a module's phrase is missing from the translation).
- Started reworking debugging into a more extended and flexible form.
- Added cvar `sm_vip_delete_outdated` (not functional yet).

# [VIP] Core 3.0 DEV #24

### Changes:
- Fixed SQL errors.

# [VIP] Core 3.0 DEV #23

### Changes:
- Removed the `id` column from the database.
- Fixed error `SQL_Callback_SelectVipClientInfo` .
- Fixed error `SQL_Callback_ChangeTime: Unknown column 'user_id' in 'where clause'`.

# [VIP] Core 3.0 DEV #22

### Changes:
- Attempt to fix error `Invalid Handle 0 (error 4)`.
- Fixed an error where the `account_id` value in the database became 0 for no-steam players.

# [VIP] Core 3.0 DEV #21

### Changes:
- Fixed error `SQL_Callback_SelectVipPlayers: near ")": syntax error`.

# [VIP] Core 3.0 DEV #20

### Changes:
- Fixed an error where the `name` value in the database became 0.

# [VIP] Core 3.0 DEV #19

### Changes:
- Added multilanguage support for the `"Exit"` button in the info menu.

# [VIP] Core 3.0 DEV #18

### Changes:
- Fixed error `SQL_Callback_SelectVipPlayers: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near '0, 60' at line 1`.

# [VIP] Core 3.0 DEV #17

### Changes:
- Added saving of the player's last server login.

# [VIP] Core 3.0 DEV #16

### Changes:
- Players are now stored in the database by AccountID.
- Fixed the `sm_addvip` command:
	- It can now accept: SteamID2, SteamID3 and a nickname.
	- Fixed granting VIP status to offline players.

# [VIP] Core 3.0 DEV #15

### Changes:
- Added a fix for the MOTD window on CS:GO.
- Added the FIX_CSGO_MOTD directive, which allows compiling the core with or without the MOTD fix.

# [VIP] Core 3.0 DEV #14

### Changes:
- Updated the API:
	- Added forward `VIP_OnShowClientInfo`.
	- Changed native `VIP_RemoveClientVIP`.
	- Improved and fixed the descriptions of all natives and forwards.
- Updated file `addons/sourcemod/data/vip/cfg/info.ini` (fixed the description and typos, added English translation).

# [VIP] Core 3.0 DEV #13

### Changes:
- Fixed a logic error in `VIP_UnregisterFeature` that caused extra items to be added to the VIP menu.
- Changed native `VIP_RegisterFeature` to resolve a conflict with `sm_vip_features_default_status`.
- Added native `VIP_UnregisterMe()`.

# [VIP] Core 3.0 DEV #12

### Changes:
- Fixed error `Invalid data pack handle 1f4 (error 1)`.

# [VIP] Core 3.0 DEV #11

### Changes:
- Removed native `VIP_SetFeatureDefStatus`.
- Added a parameter to native `VIP_RegisterFeature`:
```
@param bDefStatus			Default value (true - enabled, false - disabled).
```
- Fixed native `VIP_SetClientFeatureStatus`.
- Fixed an error when sending rcon commands for VIP management on behalf of the server.

# [VIP] Core 3.0 DEV #10

### Changes:
- Fixed error `DataPack operation is out of bounds`.

# [VIP] Core 3.0 DEV #9

### Changes:
- Fixed compilation errors.

# [VIP] Core 3.0 DEV #8

### Changes:
- Added a parameter to native `VIP_SetClientFeatureStatus`:
```
@param bCallback			Whether to call the toggle callback.
```

# [VIP] Core 3.0 DEV #7

### Changes:
- Improved the VIP player management menu.
- Added forwards:
```
forward void VIP_OnFeatureRegistered(const char[] sFeatureName);
forward void VIP_OnFeatureUnregistered(const char[] sFeatureName);
```
- `VIP_OnVIPClientLoaded` is now called when the player has been fully loaded.
- Changed natives:
```
native void VIP_GetClientID(int iClient);
// To
native int VIP_GetClientID(int iClient);

native void VIP_SendClientVIPMenu(int iClient);
// To
native void VIP_SendClientVIPMenu(int iClient, bool bSelection = false);
```
- Added natives:
```
native VIP_FeatureType VIP_GetFeatureType(const char[] sFeatureName);
native VIP_ValueType VIP_GetFeatureValueType(const char[] sFeatureName);
native void VIP_SetFeatureDefStatus(const char[] sFeatureName, bool bStatus);
native int VIP_FillArrayByFeatures(ArrayList hArray);
```

# [VIP] Core 3.0 DEV #6

### Changes:
- Fixed errors.

# [VIP] Core 3.0 DEV #5

### Changes:
- Fixed errors.

# [VIP] Core 3.0 DEV #4

### Changes:
- Full transition to the new syntax (`newdecls required`)
- VIP_OnVIPClientLoaded is now called when the player's settings are fully loaded.
- Changed native `VIP_SetClientVIP`.
- Removed unused phrases from the translation file.


# [VIP] Core 3.0 DEV #3

### Changes:
- Removed all authorization types except AUTH_STEAM.
- Changed the sm_addvip command.
- Temporarily disabled all admin menu functions except adding VIP players.


# [VIP] Core 3.0 DEV #2

### Changes:
- Ported the vars.sp file to the new syntax and partially ported others.
- Removed passwords (from the database, queries, api, cvars).

# [VIP] Core 3.0 DEV #1

### Changes:
- Correct compilation on sm >= 1.7.
- Added a time variable to menu-type info messages. It sets how long the menu is shown to the player.
- Fixed settings being reset on rejoin when cookies had not finished loading.

# [VIP] Core 3.0 DEV

### Changes:
- Added the USE_ADMINMENU directive, which allows compiling the core with or without the VIP admin menu.
- Added cvar sm_vip_add_item_to_admin_menu - add the "VIP Management" item to the admin menu.
- Added a separate VIP administration menu, opened with the command sm_vipadmin, !vipadmin, /vipadmin.
- Removed the private player spawn forward (and the hook/unhook natives).
- SM 1.5.0 or higher is now required to work.
