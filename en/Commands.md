# Console commands

[<- Back to contents](../index.md)

The admin commands need the admin flag from `sm_vip_admin_flag` (default `z`, root).

* `sm_refresh_vips` - reloads the VIP players.
* `sm_reload_vip_cfg` - reloads the VIP configs (groups, info messages, menu sorting) and then the VIP players.
* `sm_addvip <#steam_id|#name|#userid> <group> <time>` - adds a VIP player.
* `sm_delvip <steam_id>` - removes a VIP player.
* `sm_vipadmin` - opens the VIP admin menu (if the core is built with `USE_ADMINMENU 1`).
* `sm_vip`, `vip`, `sm_vipmenu` - open the VIP menu for VIP players. The list is set by `sm_vip_menu_commands`.

Parameters:
* `<#steam_id|#name|#userid>` - the player's SteamID (`STEAM_1:0:123` or `[U:1:246]`), or a name / `#userid` if the player is on the server.
* `<group>` - a VIP group from `groups.ini`.
* `<time>` - the duration in the units set by `sm_vip_time_mode` in `cfg/vip/VIP_Core.cfg`; `0` - permanent.

Put every parameter in quotes: `"parameter"`.

### Notation
* `<parameter>` - required parameter
* `[parameter]` - optional parameter
