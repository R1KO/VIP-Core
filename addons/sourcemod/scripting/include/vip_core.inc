#if defined _vip_core_included
 #endinput
#endif
#define _vip_core_included

/* Типы данных VIP-функций */
enum VIP_ValueType
{
	VIP_NULL	= 0,	// Нет данных
	INT,				// Целочисленный тип
	FLOAT,				// Числа с плавающей точкой (Дробные)
	BOOL,				// Логический тип (1/0)
	STRING				// Строчный тип
}

/* Статусы VIP-функций */
enum VIP_ToggleState
{
	DISABLED = 0,		// Выключено
	ENABLED,			// Включено
	NO_ACCESS			// Нет доступа
}

/* Типы VIP-функций */
enum VIP_FeatureType
{
	TOGGLABLE = 0,		// Вкл/Выкл в меню
	SELECTABLE,			// Только нажатие
	HIDE				// Скрытый
}

typeset ItemSelectCallback
{
	/**
	 *	Вызывается когда VIP-игрок нажимает на пункт в меню (для типа TOGGLABLE).
	 *	-
	 * @param iClient			Индекс игрока.
	 * @param sFeatureName		Уникальное имя ф-и.
	 * @param OldStatus			Старое значение статуса.
	 * @param NewStatus			Новое значение статуса.
	 *	-
	 * @return	Возврат Plugin_Stop или Plugin_Handled остановит переключение статуса. Возврат Plugin_Continue разрешит переключение статуса без изменений. Возврат Plugin_Changed разрешит переключение статуса на NewStatus.
	*/
	function Action (int iClient, const char[] sFeatureName, VIP_ToggleState OldStatus, VIP_ToggleState &NewStatus);

	/**
	 *	Вызывается когда VIP-игрок нажимает на пункт в меню (для типа SELECTABLE).
	 *	-
	 * @param iClient			Индекс игрока.
	 * @param sFeatureName		Уникальное имя ф-и.
	 *	-
	 * @return	Возврат true снова откроет игроку VIP-меню.
	*/
	function bool (int iClient, const char[] sFeatureName);
};

/**
 *	Вызывается когда VIP-игроку отображается пункт в меню.
 *	-
 * @param iClient			Индекс игрока.
 * @param sFeatureName		Уникальное имя ф-и.
 * @param sDisplay			Буфер.
 * @param iMaxLength		Размер буфера.
 *	-
 * @return	Если вернуть true то будет отображено то что в буфере (sDisplay). Если вернуть false то ничего не будет изменено.
*/
typedef ItemDisplayCallback = function bool (int iClient, const char[] sFeatureName, char[] sDisplay, int iMaxLength);

/**
 *	Вызывается когда VIP-игроку отображается стиль пункта в меню.
 *	-
 * @param iClient			Индекс игрока.
 * @param sFeatureName		Уникальное имя ф-и.
 * @param iStyle			Стиль.
 *	-
 * @return	Нужно вернуть необходимый стиль.
*/
typedef ItemDrawCallback = function int (int iClient, const char[] sFeatureName, int iStyle);

/**
 *	Вызывается когда игрок возрождается.
 *	-
 * @param iClient			Индекс игрока.
 * @param iTeam				Команда игрока (2 - Т, 3- КТ).
 * @param bIsVIP			Имеет ли игрок VIP-статус.
 *	-
 * @noreturn
*/
forward void VIP_OnPlayerSpawn(int iClient, int iTeam, bool bIsVIP);

/**
 *	Вызывается когда у игрока изменяется статус функции (вкл/выкл).
 *	-
 * @param iClient			Индекс игрока.
 * @param sFeatureName		Уникальное имя ф-и.
 * @param OldStatus			Старое значение статуса.
 * @param NewStatus			Новое значение статуса.
 *	-
 * @return	Возврат Plugin_Stop или Plugin_Handled остановит переключение статуса. Возврат Plugin_Continue разрешит переключение статуса без изменений. Возврат Plugin_Changed разрешит переключение статуса на NewStatus.
*/
forward Action VIP_OnFeatureToggle(int iClient, const char[] sFeatureName, VIP_ToggleState OldStatus, VIP_ToggleState &NewStatus);

/**
 *	Вызывается когда VIP-плагин загрузился.
 *	-
 * @noparams
 *	-
 * @noreturn
*/
forward void VIP_OnVIPLoaded();

/**
 *	Вызывается когда VIP-функция была зарегистрирована.
 *	-
 * @param sFeatureName		Уникальное имя ф-и.
 *	-
 * @noreturn
*/
forward void VIP_OnFeatureRegistered(const char[] sFeatureName);

/**
 *	Вызывается когда VIP-функция была удалена.
 *	-
 * @param sFeatureName		Уникальное имя ф-и.
 *	-
 * @noreturn
*/
forward void VIP_OnFeatureUnregistered(const char[] sFeatureName);

/**
 *	Вызывается когда игрок был загружен.
 *	-
 * @param iClient			Индекс игрока.
 * @param bIsVIP			Имеет ли игрок VIP-статус.
 *	-
 * @noreturn
*/
forward void VIP_OnClientLoaded(int iClient, bool bIsVIP);

/**
 *	Вызывается когда VIP-игрок был загружен.
 *	-
 * @param iClient			Индекс игрока.
 *	-
 * @noreturn
*/
forward void VIP_OnVIPClientLoaded(int iClient);

/**
 *	Вызывается когда игрок получает VIP-статус.
 *	-
 * @param iAdmin			Индекс админа (0 - сервер).
 * @param iClient			Индекс игрока.
 *	-
 * @noreturn
*/
forward void VIP_OnVIPClientAdded(int iAdmin, int iClient);

/**
 *	Вызывается когда игрок лишается VIP-статуса.
 *	-
 * @param iClient			Индекс игрока.
 * @param sReason			Причина:
 * 								"Expired" - Истек
 * 								"Removed by Admin" - Удален админом
 * 								"Removed by native" - Удален плагином.
 *	-
 * @noreturn
*/
forward void VIP_OnVIPClientRemoved(int iClient, const char[] sReason);

/**
 *	Запускает проверку игрока на наличие VIP прав.
 *	-
 * @param iClient			Индекс игрока.
 * @param bNotify			Известить ли игрока о результате проверки.
 *	-
 * @noreturn
*/
native void VIP_CheckClient(int iClient, bool bNotify = false);

/**
 *	Получает наличие VIP прав у игрока.
 *	-
 * @param iClient			Индекс игрока.
 *	-
 * @return	Возвращает true в случае если у игрока имеются VIP права, иначе false.
*/
native bool VIP_IsClientVIP(int iClient);

/**
 *	Получает уникальный ID VIP-игрока.
 *	-
 * @param iClient			Индекс игрока.
 *	-
 * @return	Уникальный ID или -1 если временный.
*/
native int VIP_GetClientID(int iClient);

/**
 *	Получает время окончания VIP-прав у игрока (unix).
 *	-
 * @param iClient			Индекс игрока.
 *	-
 * @return	Дата в unix формате (0 - навсегда, -1 если не удалось получить).
*/
native int VIP_GetClientAccessTime(int iClient);

/**
 *	Устанавливает время окончания VIP-прав у игрока (unix).
 *	-
 * @param iClient			Индекс игрока.
 * @param iTime				Дата в unix формате, 0 если права навсегда, -1 если временный.
 * @param bInDB				Изменять ли в базе данных.
 *	-
 * @return true в случае успеха, иначе false.
*/
native bool VIP_SetClientAccessTime(int iClient, int iTime, bool bInDB = true);

/**
 *	Получает VIP-группу игрока.
 *	-
 * @param iClient			Индекс игрока.
 * @param sGroup			Буфер, в который будет помещен результат.
 * @param iMaxLength		Размер буфера.
 *	-
 * @return true в случае успеха, иначе false.
*/
native bool VIP_GetClientVIPGroup(int iClient, char[] sGroup, int iMaxLength);

/**
 *	Устанавливает игроку VIP-группу.
 *	-
 * @param iClient			Индекс игрока.
 * @param sGroup			VIP-группа.
 * @param bInDBB			Изменять ли в базе данных.
 *	-
 * @return true в случае успеха, иначе false.
*/
native bool VIP_SetClientVIPGroup(int iClient, const char[] sGroup, bool bInDB = true);

/**
 *	Получает Handle adt trie настроек VIP-игрока.
 *	-
 * @param iClient			Индекс игрока.
 *	-
 * @return	Handle adt trie.
*/
native StringMap VIP_GetVIPClientTrie(int iClient);

/**
 *	Проверяет наличие VIP-группы.
 *	-
 * @param sGroup			Имя VIP-группы.
 *	-
 * @return true если группа существует, иначе false.
*/	
native bool VIP_IsValidVIPGroup(const char[] sGroup);

/**
 *	Выводит игроку сообщение в чат с приставкой (фраза в переводе "VIP_CHAT_PREFIX").
 *	-
 * @param iClient			Индекс игрока.
 * @param sMessage			Правила форматирования сообщение.
 * @param ...				Параметры форматирования.
 *	-
 * @noreturn
*/
native void VIP_PrintToChatClient(int iClient, const char[] sMessage, any ...);

/**
 *	Выводит всем игрокам сообщение в чат с приставкой (фраза в переводе "VIP_CHAT_PREFIX").
 *	-
 * @param sMessage			Правила форматирования сообщение.
 * @param ...				Параметры форматирования.
 *	-
 * @noreturn
*/
native void VIP_PrintToChatAll(const char[] sMessage, any ...);

/**
 *	Записывает сообщение в лог.
 *	-
 * @param sMessage			Правила форматирования сообщение.
 * @param ...				Параметры форматирования.
 *	-
 * @noreturn
*/
native void VIP_LogMessage(const char[] sMessage, any ...);

/**
 *	Отправляет игроку VIP-меню.
 *	-
 * @param iClient			Индекс игрока.
 * @param bSelection		Режим открытия (true - на первой странице, false - на странице последнего выбранного пункта).
 *	-
 * @noreturn
*/
native void VIP_SendClientVIPMenu(int iClient, bool bSelection = false);

/**
 *	Выдает игроку VIP-права.
 *	-
 * @param iAdmin			Индекс админа (0 - сервер).
 * @param iClient			Индекс игрока.
 * @param iTime				Время в секундах.
 * @param sGroup			Имя VIP-группы.
 * @param bAddToDB			Добавлять ли в базу данных.
 *	-
 * @noreturn
*/
native void VIP_SetClientVIP(int iAdmin = 0, int iClient, int iTime, const char[] sGroup, bool bAddToDB = true);

/**
 *	Отнимает у игрока VIP-права.
 *	-
 * @param iClient			Индекс игрока.
 * @param bInDB				Удалять ли тз базы данных.
 * @param bNotify			Уведомление игрока (true - уведомить/false - не уведомлять).
 *	-
 * @return true в случае успеха, иначе false.
*/
native bool VIP_RemoveClientVIP(int iClient, bool bInDB, bool bNotify);

/**
 *	Проверка что ядро загружено и готово к регистрации функций.
 *	-
 * @noparams
 *	-
 * @return true если готово, иначе false.
*/
native bool VIP_IsVIPLoaded();

/**
 *	Добавляет новую VIP-функцию.
 *	-
 * @param sFeatureName			Уникальное имя ф-и.
 * @param ValType				Тип данных ф-и.
 * @param FeatureType			Тип ф-и.
 * @param Item_select_callback	Обратный вызов при смене статуса ф-и.
 * @param Item_display_callback	Обратный вызов при отображении пункта ф-и .
 * @param Item_draw_callback	Обратный вызов при отображении стиля пункта ф-и.
 * @param bDefStatus			Значение по-умолчанию (true - Включена, false - Выключена).
 *	-
 * @noreturn
*/

native void VIP_RegisterFeature(const char[]			sFeatureName,
								VIP_ValueType			eValType				= VIP_NULL,
								VIP_FeatureType			eType					= TOGGLABLE,
								ItemSelectCallback		Item_select_callback	= INVALID_FUNCTION,
								ItemDisplayCallback		Item_display_callback	= INVALID_FUNCTION,
								ItemDrawCallback		Item_draw_callback		= INVALID_FUNCTION,
								VIP_ToggleState			eDefStatus				= NO_ACCESS);

/**
 *	Удаляет VIP-функцию.
 *	-
 * @param sFeatureName			Уникальное имя ф-и.
 *	-
 * @noreturn
*/
native void VIP_UnregisterFeature(const char[] sFeatureName);

/**
 *	Удаляет все VIP-функции зарегистрированные плагином (вызывать в OnPluginEnd()).
 *	-
 * @noparams
 *	-
 * @noreturn
*/
native void VIP_UnregisterMe();

/**
 *	Проверяет существование функции.
 *	-
 * @param sFeatureName			Уникальное имя ф-и.
 *	-
 * @return	Возвращает true в случае если функция существует, иначе false.
*/
native bool VIP_IsValidFeature(const char[] sFeatureName);

/**
 *	Получает тип функции.
 *	-
 * @param sFeatureName			Уникальное имя ф-и.
 *	-
 * @return	Возвращает элемент списка VIP_FeatureType.
*/
native VIP_FeatureType VIP_GetFeatureType(const char[] sFeatureName);

/**
 *	Получает тип значения функции.
 *	-
 * @param sFeatureName			Уникальное имя ф-и.
 *	-
 * @return	Возвращает элемент списка VIP_ValueType.
*/
native VIP_ValueType VIP_GetFeatureValueType(const char[] sFeatureName);

/**
 *	Заполняет adt массив ф-ями.
 *	-
 * @param hArray			Массив типа ArrayList.
 *	-
 * @return	Количество добавленных элементов.
*/
native int VIP_FillArrayByFeatures(ArrayList hArray);

/**
 *	Возвращает статус VIP-функции у игрока.
 *	-
 * @param iClient			Индекс игрока.
 * @param sFeatureName		Уникальное имя ф-и.
 *	-
 * @return	Возвращает DISABLED если выключена, ENABLED если включена и NO_ACCESS если у игрока нет доступа.
*/
native VIP_ToggleState VIP_GetClientFeatureStatus(int iClient, const char[] sFeatureName);

/**
 *	Устанавливает статус VIP-функции игроку.
 *	-
 * @param iClient			Индекс игрока.
 * @param sFeatureName		Уникальное имя ф-и.
 * @param Status			Статус VIP-функции.
 * @param bCallback			Вызывать ли toggle каллбэк.
 *	-
 * @return true в случае успеха, иначе false.
*/
native bool VIP_SetClientFeatureStatus(int iClient, const char[] sFeatureName, VIP_ToggleState Status, bool bCallback = true);

/**
 *	Возвращает статус VIP-функции у игрока.
 *	-
 * @param iClient			Индекс игрока.
 * @param sFeatureName		Уникальное имя ф-и.
 *	-
 * @return	Возвращает true если выключена, false если включена или если у игрока нет доступа.
*/
native bool VIP_IsClientFeatureUse(int iClient, const char[] sFeatureName);

/**
 *	Получает целочисленное значение параметра VIP-функции у игрока.
 *	-
 * @param iClient			Индекс игрока.
 * @param sFeatureName		Уникальное имя ф-и.
 *	-
 * @return	Возвращает целочисленное значение параметра VIP-функции у игрока.
*/
native int VIP_GetClientFeatureInt(int iClient, const char[] sFeatureName);

/**
 *	Получает дробное значение параметра VIP-функции у игрока.
 *	-
 * @param iClient			Индекс игрока.
 * @param sFeatureName		Уникальное имя ф-и.
 *	-
 * @return	Возвращает дробное значение параметра VIP-функции у игрока.
*/
native float VIP_GetClientFeatureFloat(int iClient, const char[] sFeatureName);

/**
 *	Получает логическое значение параметра VIP-функции у игрока.
 *	-
 * @param iClient			Индекс игрока.
 * @param sFeatureName		Уникальное имя ф-и.
 *	-
 * @return	Возвращает true или false.
*/
native bool VIP_GetClientFeatureBool(int iClient, const char[] sFeatureName);

/**
 *	Получает строчное значение параметра VIP-функции у игрока.
 *	-
 * @param iClient			Индекс игрока.
 * @param sFeatureName		Уникальное имя ф-и.
 * @param sBuffer			Буфер, в который будет помещен результат.
 * @param iMaxLength		Размер буфера.
 *	-
 * @noreturn
*/
native void VIP_GetClientFeatureString(int iClient, const char[] sFeatureName, char[] sBuffer, int iMaxLength);

/**
 *	Выдает игроку VIP-функцию и устанавливает её значение.
 *	-
 * @param iClient			Индекс игрока.
 * @param sFeatureName		Уникальное имя ф-и.
 * @param sFeatureValue		Значение.
 *	-
 * @return true в случае успеха, иначе false.
*/
native bool VIP_GiveClientFeature(int iClient, const char[] sFeatureName, const char[] sFeatureValue);

/**
 *	Получает Handle базы данных. После работы необходимо закрыть с помощью CloseHandle()
 *	-
 *	@noparams
 *	-
 *	@return	Handle базы данных
*/
native Database VIP_GetDatabase();
/**
 *	Получает тип базы данных.
 *	-
 *	@noparams
 *	-
 *	@return	true если MySQL, false если SQLite
*/
native bool VIP_GetDatabaseType();

/**
 *	Получает время в секундах в зависимости от sm_vip_time_mode.
 *	-
 * @param iTime				Время.
 *	-
 * @return	Возвращает количество секунд в зависимости от sm_vip_time_mode.
*/
native int VIP_TimeToSeconds(int iTime);

/**
 *	Получает время в зависимости от sm_vip_time_mode.
 *	-
 * @param iTime				Количество секунд.
 *	-
 * @return	Возвращает время в зависимости от sm_vip_time_mode.
*/
native int VIP_SecondsToTime(int iTime);

/**
 *	Переводит секунды в человекопонятный вид.
 *	-
 * @param sBuffer		Буфер, в который будет помещен результат.
 * @param iMaxLength	Размер буфера.
 * @param iTimeStamp	Кол-во секунд.
 * @param iClient		Индекс игрока или LANG_SERVER.
 *	-
 * @return true в случае успеха, иначе false.
*/
native bool VIP_GetTimeFromStamp(char[] sBuffer, int iMaxLength, int iTimeStamp, int iClient = LANG_SERVER);

/**
 *	Добавляет к строке статус ф-и.
 *	-
 * @param sInput		Исходная строка.
 * @param sBuffer		Буфер, в который будет помещен результат.
 * @param iMaxLength	Размер буфера.
 * @param sFeatureName	Уникальное имя ф-и.
 * @param iClient		Индекс игрока.
 *	-
 * @noreturn
*/
native void VIP_AddStringToggleStatus(const char[] sInput, char[] sBuffer, int iMaxLength, const char[] sFeatureName, int iClient);

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
}
#endif

	

