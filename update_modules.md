# Мануал по обновлению модулей

Обновление позволяет решить такие проблемы:
1. Адекватная загрузка/выгрузка модуля средствами SourceMod (`sm plugins load/reload/unload`)
2. Исправление события возрождения игрока:
	- Фатальная ошибка при запуске модуля: `Native "VIP_HookClientSpawn" was not found`
	- Предупреждение при компиляции модуля: `warning 234: symbol "VIP_HookClientSpawn" is marked as deprecated: Use VIP_OnPlayerSpawn`
	- Фатальная ошибка при компиляции модуля: ` error 017: undefined symbol "VIP_HookClientSpawn"`

Для примера будет использован следующий код:
```cpp
// Это уникальное имя ф-и. Оно разное в каждом модуле
#define VIP_MODULE		"module1"
// Может выглядеть так
new const String:g_sFeature[] = "module1";

public OnPluginStart() 
{
	// код
}

public VIP_OnVIPLoaded()
{
	VIP_RegisterFeature(VIP_MODULE,		BOOL);
}
```
1. Если уникальное имя ф-и выглядит так:
```cpp
#define VIP_MODULE		"module1"
```
То меняем на
```cpp
new const String:g_sFeature[] = "module1";
```
Или для нового синтаксиса
```cpp
static const char g_sFeature[] = "module1";
```
2. Затем заменяем все `VIP_MODULE` (может быть другим) на `g_sFeature`
3. Ищем функцию
```cpp
public OnPluginStart() 
{
	// код
}
```
И добавляем в её конце
```cpp
if(VIP_IsVIPLoaded())
{
	VIP_OnVIPLoaded();
}
```
Должно получиться так:
```cpp
public OnPluginStart() 
{
	// код
	if(VIP_IsVIPLoaded())
	{
		VIP_OnVIPLoaded();
	}
}
```
Если же функции `OnPluginStart()` нет то дописываем её:
```cpp
public OnPluginStart() 
{
	if(VIP_IsVIPLoaded())
	{
		VIP_OnVIPLoaded();
	}
}
```
4. Дальше ищем функцию
```cpp
public OnPluginEnd() 
{
	// код
}
```
Чаще всего её нет. Поэтом добавляем её:
```cpp
public OnPluginEnd() 
{
	// код (если он был)
	if(CanTestFeatures() && GetFeatureStatus(FeatureType_Native, "VIP_UnregisterFeature") == FeatureStatus_Available)
	{
		VIP_UnregisterFeature(g_sFeature);
	}
}
```

После этого проблема `#1` будет решена.

Еще 1 пример для модулей с 2-я функциями (на подобии скинов, трейлов и т.д.):
- Функция вкл/выкл
- Функция настройки

Выглядят они примерно так:
```cpp
#define VIP_SKINS		"Skins"
#define VIP_SKINS_MENU		"Skins_Menu"

public VIP_OnVIPLoaded()
{
	VIP_RegisterFeature(VIP_SKINS, STRING, _, OnToggleItem);
	VIP_RegisterFeature(VIP_SKINS_MENU, _, SELECTABLE, OnSelectItem, _, OnDrawItem);
}
```
Для обновления такого типа модулей делаем так:
1. Заменяем объявление ф-й
```cpp
#define VIP_SKINS		"Skins"
#define VIP_SKINS_MENU		"Skins_Menu"
```
на
```cpp
static const String:g_sFeature[][] = {"Skins", "Skins_Menu"};
```
Или для нового синтаксиса
```cpp
static const char g_sFeature[][] = {"Skins", "Skins_Menu"};
```
2. Заменяем все `VIP_SKINS` на `g_sFeature[0]` и `VIP_SKINS_MENU` на `g_sFeature[1]`
3. Изменяем/добавляем `OnPluginStart()`
```cpp
public OnPluginStart() 
{
	// Код если был
	if(VIP_IsVIPLoaded())
	{
		VIP_OnVIPLoaded();
	}
}
```
4. Изменяем/добавляем `OnPluginEnd()`
```cpp
public OnPluginEnd() 
{
	// код (если он был)
	if(CanTestFeatures() && GetFeatureStatus(FeatureType_Native, "VIP_UnregisterFeature") == FeatureStatus_Available)
	{
		VIP_UnregisterFeature(g_sFeature[0]);
		VIP_UnregisterFeature(g_sFeature[1]);
	}
}
```

Главное соблюдать закономерность:
>Для каждой ```VIP_RegisterFeature``` в ```VIP_OnVIPLoaded()``` должна быть ```VIP_UnregisterFeature``` в ```OnPluginEnd()```

Больше примеров можете посмотреть в уже обновлённых модулях.

Для решения проблемы `#2`:
1. В `OnPluginStart()` ищем `VIP_HookClientSpawn(OnPlayerSpawn);`
2. Удаляем эту строку
3. Далее ищем:
```cpp
public OnPlayerSpawn(iClient, iTeam, bool:bIsVIP)
```
и заменяем на
```cpp
public VIP_OnPlayerSpawn(iClient, iTeam, bool:bIsVIP)
```

