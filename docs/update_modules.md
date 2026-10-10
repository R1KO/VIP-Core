# Module update guide

The update solves the following problems:
1. Proper loading/unloading of a module with SourceMod tools (`sm plugins load/reload/unload`)
2. Fixing the player spawn event:
	- Fatal error when starting the module: `Native "VIP_HookClientSpawn" was not found`
	- Warning when compiling the module: `warning 234: symbol "VIP_HookClientSpawn" is marked as deprecated: Use VIP_OnPlayerSpawn`
	- Fatal error when compiling the module: ` error 017: undefined symbol "VIP_HookClientSpawn"`

The following code is used as an example:
```cpp
// This is the unique feature name. It is different in every module
#define VIP_MODULE		"module1"
// It may also look like this
new const String:g_sFeature[] = "module1";

public OnPluginStart() 
{
	// code
}

public VIP_OnVIPLoaded()
{
	VIP_RegisterFeature(VIP_MODULE,		BOOL);
}
```
1. If the unique feature name looks like this:
```cpp
#define VIP_MODULE		"module1"
```
Change it to
```cpp
new const String:g_sFeature[] = "module1";
```
Or, for the new syntax
```cpp
static const char g_sFeature[] = "module1";
```
2. Then replace every `VIP_MODULE` (it may be named differently) with `g_sFeature`
3. Find the function
```cpp
public OnPluginStart() 
{
	// code
}
```
And add the following at its end
```cpp
if(VIP_IsVIPLoaded())
{
	VIP_OnVIPLoaded();
}
```
It should look like this:
```cpp
public OnPluginStart() 
{
	// code
	if(VIP_IsVIPLoaded())
	{
		VIP_OnVIPLoaded();
	}
}
```
If there is no `OnPluginStart()` function, add it:
```cpp
public OnPluginStart() 
{
	if(VIP_IsVIPLoaded())
	{
		VIP_OnVIPLoaded();
	}
}
```
4. Next, find the function
```cpp
public OnPluginEnd() 
{
	// code
}
```
Most often it does not exist, so add it:
```cpp
public OnPluginEnd() 
{
	// code (if there was any)
	if(CanTestFeatures() && GetFeatureStatus(FeatureType_Native, "VIP_UnregisterFeature") == FeatureStatus_Available)
	{
		VIP_UnregisterFeature(g_sFeature);
	}
}
```

After this, problem `#1` is solved.

One more example, for modules with 2 features (like skins, trails, etc.):
- A toggle (on/off) feature
- A settings feature

They look roughly like this:
```cpp
#define VIP_SKINS		"Skins"
#define VIP_SKINS_MENU		"Skins_Menu"

public VIP_OnVIPLoaded()
{
	VIP_RegisterFeature(VIP_SKINS, STRING, _, OnToggleItem);
	VIP_RegisterFeature(VIP_SKINS_MENU, _, SELECTABLE, OnSelectItem, _, OnDrawItem);
}
```
To update this type of module, do the following:
1. Replace the feature declarations
```cpp
#define VIP_SKINS		"Skins"
#define VIP_SKINS_MENU		"Skins_Menu"
```
with
```cpp
static const String:g_sFeature[][] = {"Skins", "Skins_Menu"};
```
Or, for the new syntax
```cpp
static const char g_sFeature[][] = {"Skins", "Skins_Menu"};
```
2. Replace every `VIP_SKINS` with `g_sFeature[0]` and `VIP_SKINS_MENU` with `g_sFeature[1]`
3. Modify/add `OnPluginStart()`
```cpp
public OnPluginStart() 
{
	// Code, if there was any
	if(VIP_IsVIPLoaded())
	{
		VIP_OnVIPLoaded();
	}
}
```
4. Modify/add `OnPluginEnd()`
```cpp
public OnPluginEnd() 
{
	// code (if there was any)
	if(CanTestFeatures() && GetFeatureStatus(FeatureType_Native, "VIP_UnregisterFeature") == FeatureStatus_Available)
	{
		VIP_UnregisterFeature(g_sFeature[0]);
		VIP_UnregisterFeature(g_sFeature[1]);
	}
}
```

The main thing is to follow this rule:
>Every ```VIP_RegisterFeature``` in ```VIP_OnVIPLoaded()``` must have a matching ```VIP_UnregisterFeature``` in ```OnPluginEnd()```

You can find more examples in the modules that have already been updated.

To solve problem `#2`:
1. In `OnPluginStart()` find `VIP_HookClientSpawn(OnPlayerSpawn);`
2. Delete this line
3. Then find:
```cpp
public OnPlayerSpawn(iClient, iTeam, bool:bIsVIP)
```
and replace it with
```cpp
public VIP_OnPlayerSpawn(iClient, iTeam, bool:bIsVIP)
```

