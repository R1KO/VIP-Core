# [VIP] Core 3.0 DEV #40

### Изменения:
- Изменен натив `VIP_RegisterFeature` (Добавлен параметр `bCookie` - Регистрировать ли куки для ф-и (действительно только для типа SELECTABLE)).

# [VIP] Core 3.0 DEV #39

### Изменения:
- Исправлена ошибка на SQLite `SQL_Callback_RemoveClient: no such column: sid`.

# [VIP] Core 3.0 DEV #38

### Изменения:
- Исправлена ошибка на SQLite `SQL_Callback_ErrorCheck: no such column: sid`.

# [VIP] Core 3.0 DEV #37

### Изменения:
- Исправлена ошибка когда не удалялись истекшие VIP-игроки.

# [VIP] Core 3.0 DEV #36

### Изменения:
- Теперь точно исправлена ошибка `Invalid Handle 0 (error 4)` (`DB_RemoveClientFromID`).

# [VIP] Core 3.0 DEV #35

### Изменения:
- Исправлена ошибка `Invalid Handle 0 (error 4)` (`DB_RemoveClientFromID`).

# [VIP] Core 3.0 DEV #34

### Изменения:
- Натив `VIP_RemoveClientVIP` помечен как устаревший и будет удален в будущем.
- Добавлен новый натив `VIP_RemoveClientVIP2`.
- Исправлена ошибка `Client index 0 is invalid` при добавлении VIP-игрока через `sm_addvip`.

# [VIP] Core 3.0 DEV #33

### Изменения:
- Изменени натив `VIP_SetClientFeatureStatus`.
- Исправлена ошибка `SQL_Callback_SelectExpiredAndOutdated: Unknown column 'iTime' in 'where clause'`.
- Переработана система логов.

# [VIP] Core 3.0 DEV #32 (спасибо DarklSide за обнаруженные ошибок)

### Изменения:
- Исправлено описание форварда `VIP_OnClientPreLoad`.
- Исправлен натив `VIP_GiveClientFeature`.
- Исправлена ошибка `SQL_Callback_SelectExpiredAndOutdated: no such function: UNIX_TIMESTAMP` на SQLite.
- Исправлено обновление ников игроков.
- Исправлена работа DataPack на sm 1.10.

# [VIP] Core 3.0 DEV #31

### Изменения:
- Добавлен форвард `VIP_OnClientPreLoad`.
- Исправлен и включен натив `VIP_GiveClientFeature`.
- Добавлен натив `VIP_RemoveClientFeature`.
- Изменен натив `VIP_CheckClient`.
- Значение по-умолчанию для `sm_vip_delete_outdated` изменено на `-1`.
- Исправлено удаление истекших и не активных игроков.

# [VIP] Core 3.0 DEV #30

### Изменения:
- Исправлена работа списка VIP-игроков.

# [VIP] Core 3.0 DEV #29

### Изменения:
- Исправлены SQL ошибки.
- Небольшая оптимизация.
- Исправлена отладка.

# [VIP] Core 3.0 DEV #28

### Изменения:
- Исправлена ошибка из-за которой плагин не запускался `Fatal error creating dynamic native!/unexpected error 23 in AskPluginLoad callback`.
- Изменено имя базы данных с `"vip"` на `"vip_core"` (еще в версии 3.0 DEV #25, просто забыл упомянуть).
- Исправлена попытка установки кодировки для SQLite базы.

# [VIP] Core 3.0 DEV #27

### Изменения:
- Активирована работа квара `sm_vip_delete_outdated`.
- Полный переход на новую структуру базы данных.

# [VIP] Core 3.0 DEV #26

### Изменения:
- Вернул прежний вид натива VIP_SetClientVIP и пометил как устаревший.
- Добавлен новый натив `VIP_GiveClientVIP`, как замена устаревшему `VIP_SetClientVIP`.
- Добавлена обратная совместимость натива `VIP_RemoveClientVIP`.
- Изменента структура таблиц (MySQL).

# [VIP] Core 3.0 DEV #25

### Изменения:
- Добавлено использование `TranslationPhraseExists` для предовтращения ошибок (При отсутствии фразы модуля в переводе).
- Начал переводить отладку более расширенный и гибкий вид.
- Добавлен квар `sm_vip_delete_outdated` (пока не функционирует).

# [VIP] Core 3.0 DEV #24

### Изменения:
- Исправлены SQL ошибки.

# [VIP] Core 3.0 DEV #23

### Изменения:
- Удален столбец `id` из базы данных.
- Исправлена ошибка `SQL_Callback_SelectVipClientInfo` .
- Исправлена ошибка `SQL_Callback_ChangeTime: Unknown column 'user_id' in 'where clause'`.

# [VIP] Core 3.0 DEV #22

### Изменения:
- Попытка исправления ошибки `Invalid Handle 0 (error 4)`.
- Исправлена ошибка когда у no-steam игроков значение `account_id` в базе данных становилось равным 0.

# [VIP] Core 3.0 DEV #21

### Изменения:
- Исправлена ошибка `SQL_Callback_SelectVipPlayers: near ")": syntax error`.

# [VIP] Core 3.0 DEV #20

### Изменения:
- Исправлена ошибка когда значение `name` в базе данных становилось равным 0.

# [VIP] Core 3.0 DEV #19

### Изменения:
- Добавлена мультиязычность кнопки `"Выход"` в инфо-меню.

# [VIP] Core 3.0 DEV #18

### Изменения:
- Исправлена ошибка `SQL_Callback_SelectVipPlayers: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near '0, 60' at line 1`.

# [VIP] Core 3.0 DEV #17

### Изменения:
- Добавлено сохранение последнего входа игрока на сервер.

# [VIP] Core 3.0 DEV #16

### Изменения:
- Теперь игроки хранятся в базе по AccountID.
- Исправлена работа команды `sm_addvip`:
	- Теперь она может принимать: SteamID2, SteamID3 и ник.
	- Исправлена выдача VIP-статуса оффлайн.

# [VIP] Core 3.0 DEV #15

### Изменения:
- Добавлено исправление работы MOTD окна на CS:GO.
- Добавлена директива FIX_CSGO_MOTD, которая позволяет компилировать ядро с фиксом MOTD и без.

# [VIP] Core 3.0 DEV #14

### Изменения:
- Обновлено API:
	- Добавлен форвард `VIP_OnShowClientInfo`.
	- Изменен натив `VIP_RemoveClientVIP`.
	- Доработано и исправлено описание всех нативов и форвадов.
- Обновлен файл `addons/sourcemod/data/vip/cfg/info.ini` (Исправлено описание и опечатки, добавлен английский перевод).

# [VIP] Core 3.0 DEV #13

### Изменения:
- Исправлена логическая ошибка в работе `VIP_UnregisterFeature` когда добавлялись лишние пункты в VIP-меню.
- Изменен натив `VIP_RegisterFeature` для устранения конфликта с `sm_vip_features_default_status`.
- Добавлен натив `VIP_UnregisterMe()`.

# [VIP] Core 3.0 DEV #12

### Изменения:
- Исправлена ошибка `Invalid data pack handle 1f4 (error 1)`.

# [VIP] Core 3.0 DEV #11

### Изменения:
- Удален натив `VIP_SetFeatureDefStatus`.
- Добавлен параметр в натив `VIP_RegisterFeature`:
```
@param bDefStatus			Значение по-умолчанию (true - Включена, false - Выключена).
```
- Исправлена ошибка работы натива `VIP_SetClientFeatureStatus`.
- Исправлена ошибка при отправке rcon команд для работы с вип от имени сервера.

# [VIP] Core 3.0 DEV #10

### Изменения:
- Исправлена ошибка `DataPack operation is out of bounds`.

# [VIP] Core 3.0 DEV #9

### Изменения:
- Исправлены ошибки компиляции.

# [VIP] Core 3.0 DEV #8

### Изменения:
- Добавлен параметр в натив `VIP_SetClientFeatureStatus`:
```
@param bCallback			Вызывать ли toggle каллбэк.
```

# [VIP] Core 3.0 DEV #7

### Изменения:
- Доработано меню управления VIP-игроками.
- Добавлены форварды:
```
forward void VIP_OnFeatureRegistered(const char[] sFeatureName);
forward void VIP_OnFeatureUnregistered(const char[] sFeatureName);
```
- Теперь `VIP_OnVIPClientLoaded` вызывается когда игрок уже полностью был загружен.
- Изменены нативы:
```
native void VIP_GetClientID(int iClient);
// На
native int VIP_GetClientID(int iClient);

native void VIP_SendClientVIPMenu(int iClient);
// На
native void VIP_SendClientVIPMenu(int iClient, bool bSelection = false);
```
- Добавлены нативы:
```
native VIP_FeatureType VIP_GetFeatureType(const char[] sFeatureName);
native VIP_ValueType VIP_GetFeatureValueType(const char[] sFeatureName);
native void VIP_SetFeatureDefStatus(const char[] sFeatureName, bool bStatus);
native int VIP_FillArrayByFeatures(ArrayList hArray);
```

# [VIP] Core 3.0 DEV #6

### Изменения:
- Исправлены ошибки.

# [VIP] Core 3.0 DEV #5

### Изменения:
- Исправлены ошибки.

# [VIP] Core 3.0 DEV #4

### Изменения:
- Полный перевод на новый синтаксис (`newdecls required`)
- VIP_OnVIPClientLoaded теперь вызывается когда полностью загружены настройки игрока.
- Изменен натив `VIP_SetClientVIP`.
- Удалены лишние фразы из файла перевода.


# [VIP] Core 3.0 DEV #3

### Изменения:
- Удалены все типы авторизации кроме AUTH_STEAM.
- Изменена команда sm_addvip.
- Временно отключены все функции админ-меню, кроме добавления VIP-игроков.


# [VIP] Core 3.0 DEV #2

### Изменения:
- Перевод на новый синтаксис файла vars.sp и частичный перевод других.
- Удалены пароли (из базы, запросов, api, cvars).

# [VIP] Core 3.0 DEV #1

### Изменения:
- Корректная компиляция на см >= 1.7.
- Добавлена переменная time в информационных сообщениях типа меню. Отвечает за время отображения меню игроку.
- Исправлен сброс настроек при перезаходе в случае когда куки не успели загрузится.

# [VIP] Core 3.0 DEV

### Что изменено:
- Добавлена директива USE_ADMINMENU, которая позволяет компилировать ядро с админкой vip и без неё.
- Добавлен квар sm_vip_add_item_to_admin_menu - Добавить пункт "Управление VIP" в админ-меню.
- Добавлено отдельно меню администрирования VIP, команда для открытия sm_vipadmin, !vipadmin, /vipadmin.
- Удален частный форвард спавна игрока (и нативы хука/анхука).
- Теперь для работы требуется SM 1.5.0 или выше.