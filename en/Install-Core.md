# Installing and configuring the core

[<- Back to contents](../index.md)

> Save every file as UTF-8 without BOM, e.g. with [Notepad++](https://notepad-plus-plus.org/downloads/)

### Overview
The plugin is modular: the **core** does the main work and **modules** add the features.
The core manages VIP players, configs and the database and handles commands; modules add the actual features (HP, speed, etc.).
The core works with a local SQLite database or a remote MySQL database.


## Installing the core

1. Download the archive for your SourceMod version from [GitHub Releases](https://github.com/R1KO/VIP-Core/releases) (or [HlMod.net](https://hlmod.net/resources/vip-core.245/), or build it from the [sources](https://github.com/R1KO/VIP-Core/)). SourceMod 1.10 or newer is required.
2. Unpack the archive and copy the files into the matching folders on the server.
3. The modules translation file `vip_modules.phrases.txt` comes with the core; the newest version is also on [HlMod.net](https://hlmod.net/resources/vip-translations-vip-module.938/).
4. To use MySQL, add to `addons/sourcemod/configs/databases.cfg`:
```
  "vip_core"
  {
      "driver"      "mysql"
      "host"        "ip"        // MySQL server address
      "database"    "vip"       // database name
      "user"        "root"      // database user
      "pass"        "pass"      // the user's password
  }
```
Without this entry the core uses SQLite: `addons/sourcemod/data/sqlite/vip_core.sq3`. The tables are created automatically.

5. Start the server and check that the plugin is running and there are no errors in the logs.
6. Adjust `cfg/vip/VIP_Core.cfg` (created automatically on the first start), see [Cvars](#cvars).
7. Install the modules you need: [How to install modules](Install-Modules.md).


## Configuring the core

### Files

- `addons/sourcemod/data/vip/cfg/`
    - `groups.ini` - VIP groups and their features
    - `times.ini` - durations offered in the admin menu
    - `sort_menu.ini` - order of the VIP menu items
    - `info.ini` - info messages (on join, on expiry, etc.)

- `addons/sourcemod/data/vip/modules/`
    - `downloadlist.txt` - files to send to players for download
    - `...` - module configs

- `addons/sourcemod/plugins/`
    - `VIP_Core.smx` - the core
    - `...` - modules

- `addons/sourcemod/translations/`
    - `vip_core.phrases.txt` - core translations
    - `vip_modules.phrases.txt` - module translations
    - `...` - other module translation files

- `cfg/vip/`
    - `VIP_Core.cfg` - core settings
    - `...` - module settings


### Cvars

Cvar | Default | Description
---- | ------- | -----------
`sm_vip_admin_flag` | `z` | Admin flag needed to manage VIP players (commands and admin menu)
`sm_vip_menu_commands` | `vip;sm_vip;sm_vipmenu` | Commands that open the VIP menu, separated by `;`
`sm_vip_server_id` | `0` | Server ID when using MySQL (VIPs are bound to a server)
`sm_vip_storage_id` | `0` | Server group ID for the player data storage when using MySQL
`sm_vip_auto_open_menu` | `0` | Open the VIP menu automatically on join
`sm_vip_time_mode` | `0` | Time units for commands: 0 - seconds, 1 - minutes, 2 - hours, 3 - days
`sm_vip_delete_expired` | `1` | Delete expired VIPs: -1 - never, 0 - immediately, > 0 - days after expiry
`sm_vip_delete_outdated` | `-1` | Delete VIPs who haven't joined for X days: -1 - never, > 0 - days (minimum 3)
`sm_vip_update_name` | `1` | Update VIP names in the database on join
`sm_vip_spawn_delay` | `1.0` | Delay before features are applied after spawn
`sm_vip_hide_no_access_items` | `0` | Unavailable features in the VIP menu: 0 - shown disabled, 1 - hidden
`sm_vip_features_default_status` | `1` | Default status of toggleable features: 0 - off, 1 - on
`sm_vip_logs_enable` | `1` | Write `logs/VIP_Logs.log`


### VIP groups

Every group is a section in `groups.ini` with the parameters of the modules it gets. The parameter names and values are given in each module's description.

```
"VIP_GROUPS"
{
    "vip1"                      // group name
    {
        "HP"            "120"   // HP on spawn
        "Armor"         "100"   // armor on spawn
        "Money"         "16000" // money on spawn
        "QuickDefuse"   "1"     // quick defuse
        "Speed"         "1.3"   // speed (1.0 - normal)
        "RegenHP"       "5"     // HP regenerated per second
        "RegenArmor"    "5"     // armor regenerated per second
    }

    "vip2"
    {
        "HP"            "120"
        "Speed"         "1.3"
    }
}
```

### Group inheritance (extend)

A group can take the parameters of other groups with the `extend` key, so shared parameters are written once. List the groups separated by `;`.

```
"VIP_GROUPS"
{
    "base"
    {
        "HP"        "100"
        "Armor"     "50"
    }

    "silver"
    {
        "extend"    "base"
        "HP"        "150"
        "Speed"     "1.2"
    }

    "gold"
    {
        "extend"    "base;silver"
        "Speed"     ""          // don't inherit Speed
        "Gravity"   "0.8"
    }
}
```
Here `gold` gets `HP 150`, `Armor 50` and `Gravity 0.8`.

Rules:
* the group's own parameters beat inherited ones;
* when the listed groups have the same parameter, the group listed later wins (`base;silver` - `silver` wins);
* an empty value `""` removes an inherited parameter;
* chains work: a group can extend a group that extends another one;
* only plain `"key" "value"` parameters are inherited, nested sections are not;
* group names in `extend` must match exactly (including case); an unknown group or a loop (`a` extends `b`, `b` extends `a`) is written to the SourceMod error log and that entry is skipped;
* `extend` is resolved when the configs load (server start, `sm_reload_vip_cfg`); groups added by modules can't be extended.

### Info messages

Everything is described with examples in `addons/sourcemod/data/vip/cfg/info.ini`.
To turn a message off, delete its section from the file. A line break in a chat message is written as `\n`; every line is sent as a separate chat message.

### VIP menu order
Set in `addons/sourcemod/data/vip/cfg/sort_menu.ini`: list the feature names in the order you want, one per line.
```
HP
Armor
Money
Speed
```
Features not listed come after the sorted ones.

### Admin menu order

To order the VIP items in the admin menu, add to `addons/sourcemod/configs/adminmenu_sorting.txt`:

```
"vip_admin"
{
    "item"        "add_vip"
    "item"        "edit_vip"
    "item"        "del_vip"
    "item"        "list_vip"
    "item"        "reload_vip_players"
    "item"        "reload_vip_cfg"
}
```

### Build options

These are set in `VIP_Core.sp`, after a change the plugin has to be recompiled.

Define | Default | Description
------ | ------- | -----------
`DEBUG_MODE` | `0` | `1` - write a debug log
`USE_ADMINMENU` | `1` | `0` - remove the VIP section from the admin menu (and `sm_vipadmin`)
`USE_MORE_SERVERS` | `1` | `1` - a VIP with server ID `0` is active on every server sharing the database
`USE_CLIENTPREFS` | `0` | Where toggle statuses of features are stored: `0` - the core's `vip_storage` table (statuses saved in cookies by older versions are moved automatically), `1` - clientprefs cookies
