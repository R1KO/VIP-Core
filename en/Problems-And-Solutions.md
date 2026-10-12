# Common problems, solutions and useful links

[<- Back to contents](../index.md)

## Useful links

* [Suggestions for VIP and ideas for modules](https://hlmod.ru/threads/predlozhenija-po-uluchsheniju-vip-i-idei-dlja-modulej.26407/)
* Want to help translate into other languages? [[VIP] Core](http://translator.mitchdempsey.com/sourcemod_plugins/265), [[VIP] Modules](http://translator.mitchdempsey.com/sourcemod_plugins/272)
* [Updating a module for the latest core](https://github.com/R1KO/VIP-Core/blob/master/docs/update_modules.md)
* [Upgrading from VIP Core 2.x to 3.0](https://hlmod.ru/threads/vip-core.37613/page-46#post-368144)
* [Newest module translations](https://hlmod.ru/resources/vip-translations-vip-module.938/)

## Common problems

No. | Problem | Solution
--- | ------- | --------
1 | "No groups available" in the admin menu when giving VIP status | Save `groups.ini` as `UTF-8 (without BOM)` and check that all braces and quotes are opened and closed: `{}`, `"val"`
2 | "No available features" in the VIP menu | No modules are installed, or see No. 1
3 | "No access" in the VIP menu | The module's parameter is missing from the group in `groups.ini`, or see No. 1
4 | `Native "FormatEx" reported: Language phrase "Phrase name" not found` | A phrase is missing from the translations. Add `"Phrase name"` to the modules translation file
5 | The VIP menu behaves oddly, items disappear or shift | See No. 4
6 | `[SM] Exception reported: Plugin handle 550055 is invalid (error 3)` in the log | You reload/unload/load an outdated module; check the reloaded modules for updates
7 | `Native "VIP_RegisterFeature" reported: Feature "Module name" already exists` | The module is installed more than once (several versions, or in different folders)
8 | `Native "VIP_SetClientVIP" reported: Invalid VIP group (test_vip)` | Wrong group in `cfg/vip/vip_test.cfg`: set a group that exists in `groups.ini`, or create it
9 | `KeyValues Error: RecursiveLoadFromBuffer: got } in key in file addons/sourcemod/data/vip/cfg/groups.ini` | A brace is missing in `groups.ini`; check that no quotes or braces are missing or extra, see No. 1
10 | The admin menu behaves oddly, the wrong items open | [Solution](#solution-for-no-10)
11 | `groups.ini: group "..." extends unknown group "..."` or `... which leads back to itself` in the error log | A group in `extend` doesn't exist (names must match exactly, including case), or the groups extend each other in a loop. See [Group inheritance](Install-Core.md#group-inheritance-extend)


### Solution for No. 10
Add to `addons/sourcemod/configs/adminmenu_sorting.txt`:
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
