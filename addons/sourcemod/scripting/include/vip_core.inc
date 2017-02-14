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
	STRING			// Строчный тип
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
	TOGGLABLE = 0,	// Вкл/Выкл в меню
	SELECTABLE,		// Только нажатие
	HIDE				// Скрытый
}

/* Типы авторизации */
enum VIP_AuthType
{
	AUTH_STEAM = 0,	// Авторизация по SteamID
	AUTH_GROUP,		// Авторизация по Админ-группе
	AUTH_FLAGS		// Авторизация по Админ-флагу
}

funcenum ItemSelectCallback
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
	Action:public(iClient, const String:sFeatureName[], VIP_ToggleState:OldStatus, &VIP_ToggleState:NewStatus),

	/**
	 *	Вызывается когда VIP-игрок нажимает на пункт в меню (для типа SELECTABLE).
	 *	-
	 * @param iClient			Индекс игрока.
	 * @param sFeatureName		Уникальное имя ф-и.
	 *	-
	 * @return	Возврат true снова откроет игроку VIP-меню.
	*/
	bool:public(iClient, const String:sFeatureName[])
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
functag public bool:ItemDisplayCallback(iClient, const String:sFeatureName[], String:sDisplay[], iMaxLength);

/**
 *	Вызывается когда VIP-игроку отображается стиль пункта в меню.
 *	-
 * @param iClient			Индекс игрока.
 * @param sFeatureName		Уникальное имя ф-и.
 * @param iStyle			Стиль.
 *	-
 * @return	Нужно вернуть необходимый стиль.
*/
functag public ItemDrawCallback(iClient, const String:sFeatureName[], iStyle);

/**
 *	Вызывается когда игрок возрождается.
 *	-
 * @param iClient			Индекс игрока.
 * @param iTeam				Команда игрока (2 - Т, 3- КТ).
 * @param bIsVIP			Имеет ли игрок VIP-статус.
 *	-
 * @noreturn
*/
forward VIP_OnPlayerSpawn(iClient, iTeam, bool:bIsVIP);

/**
 *	Вызывается когда VIP-плагин загрузился.
 *	-
 * @noparams
 *	-
 * @noreturn
*/
forward VIP_OnVIPLoaded();

/**
 *	Вызывается когда игрок был загружен.
 *	-
 * @param iClient			Индекс игрока.
 * @param bIsVIP			Имеет ли игрок VIP-статус.
 *	-
 * @noreturn
*/
forward VIP_OnClientLoaded(iClient, bool:bIsVIP);

/**
 *	Вызывается VIP-когда игрок был загружен.
 *	-
 * @param iClient			Индекс игрока.
 *	-
 * @noreturn
*/
forward VIP_OnVIPClientLoaded(iClient);

/**
 *	Вызывается когда игрок лишается VIP-статуса.
 *	-
 * @param iClient			Индекс игрока.
 * @param sReason			Причина:
 * 								"Expired" - Истек
 * 								"Removed by Admin" - Удален админом
 * 								"Removed by native" - Удален плагином.
 *	-
*/
forward VIP_OnVIPClientRemoved(iClient, const String:sReason[]);

/**
 *	Запускает проверку игрока на наличие VIP прав.
 *	-
 * @param iClient			Индекс игрока.
 * @param bNotify			Известить ли игрока о результате проверки.
 *	-
 * @return	Возвращает true в случае если у игрока имеются VIP права, иначе false.
*/
native bool:VIP_CheckClient(iClient, bool:bNotify = false);

/**
 *	Получает наличие VIP прав у игрока.
 *	-
 * @param iClient			Индекс игрока.
 *	-
 * @return	Возвращает true в случае если у игрока имеются VIP права, иначе false.
*/
native bool:VIP_IsClientVIP(iClient);

/**
 *	Получает уникальный ID VIP-игрока.
 *	-
 * @param iClient			Индекс игрока.
 *	-
 * @return	Уникальный ID или -1 если временный.
*/
native VIP_GetClientID(iClient);

/**
 *	Получает время окончания VIP-прав у игрока (unix).
 *	-
 * @param iClient			Индекс игрока.
 *	-
 * @return	Дата в unix формате (0 - навсегда, -1 если не удалось получить).
*/
native VIP_GetClientAccessTime(iClient);

/**
 *	Устанавливает время окончания VIP-прав у игрока (unix).
 *	-
 * @param iClient			Индекс игрока.
 * @param iTime				Дата в unix формате, 0 если права навсегда, -1 если временный.
 * @param bInDB				Изменять ли в базе данных.
 *	-
 * @return true в случае успеха, иначе false.
*/
native bool:VIP_SetClientAccessTime(iClient, iTime, bool:bInDB);

/**
 *	Получает VIP-группу игрока.
 *	-
 * @param iClient			Индекс игрока.
 * @param sGroup			Буфер, в который будет помещен результат.
 * @param iMaxLength		Размер буфера.
 *	-
 * @return true в случае успеха, иначе false.
*/
native bool:VIP_GetClientVIPGroup(iClient, String:sGroup[], iMaxLength);

/**
 *	Устанавливает игроку VIP-группу.
 *	-
 * @param iClient			Индекс игрока.
 * @param sGroup			VIP-группа.
 * @param bInDBB			Изменять ли в базе данных.
 *	-
 * @return true в случае успеха, иначе false.
*/
native bool:VIP_SetClientVIPGroup(iClient, const String:sGroup[], bool:bInDB);

/**
 *	Получает тип авторизации VIP-игрока.
 *	-
 * @param iClient			Индекс игрока.
 *	-
 * @return	Значение класса VIP_AuthType.
*/
native VIP_AuthType:VIP_GetClientAuthType(iClient);

/**
 *	Получает Handle adt trie настроек VIP-игрока.
 *	-
 * @param iClient			Индекс игрока.
 *	-
 * @return	Handle adt trie.
*/
native Handle:VIP_GetVIPClientTrie(iClient);

/**
 *	Проверяет наличие VIP-группы.
 *	-
 * @param sGroup			Имя VIP-группы.
 *	-
 * @return true если группа существует, иначе false.
*/	
native bool:VIP_IsValidVIPGroup(const String:sGroup[]);

/**
 *	Выводит игроку сообщение в чат с приставкой (фраза в переводе "VIP_CHAT_PREFIX").
 *	-
 * @param iClient			Индекс игрока.
 * @param sMessage			Правила форматирования сообщение.
 * @param ...				Параметры форматирования.
 *	-
 * @noreturn
*/
native VIP_PrintToChatClient(iClient, const String:sMessage[], any:...);

/**
 *	Выводит всем игрокам сообщение в чат с приставкой (фраза в переводе "VIP_CHAT_PREFIX").
 *	-
 * @param sMessage			Правила форматирования сообщение.
 * @param ...				Параметры форматирования.
 *	-
 * @noreturn
*/
native VIP_PrintToChatAll(const String:sMessage[], any:...);

/**
 *	Записывает сообщение в лог.
 *	-
 * @param sMessage			Правила форматирования сообщение.
 * @param ...				Параметры форматирования.
 *	-
 * @noreturn
*/
native VIP_LogMessage(const String:sMessage[], any:...);

/**
 *	Отправляет игроку VIP-меню.
 *	-
 * @param iClient			Индекс игрока.
 *	-
 * @noreturn
*/
native VIP_SendClientVIPMenu(iClient);

/**
 *	Выдает игроку VIP-права.
 *	-
 * @param iAdmin			Индекс админа (0 - сервер, -1 - нет инициатора).
 * @param iClient			Индекс игрока.
 * @param sAuth				Стим игрока (Оставить пустым если передается iClient).
 * @param sName				Имя игрока (Оставить пустым если передается iClient).
 * @param iTime				Время в секундах.
 * @param sGroup			Имя VIP-группы.
 * @param bAddToDB			Добавлять ли в базу данных (false доступно только если передается iClient).
 *	-
 * @return true в случае успеха, иначе false.
*/
native bool:VIP_SetClientVIP(iAdmin = -1,
								iClient = 0,
								const String:sAuth[] = "",
								const String:sName[] = "",
								iTime,
								const String:sGroup[] = "",
								bool:bAddToDB);

/**
 *	Отнимает у игрока VIP-права.
 *	-
 * @param iClient			Индекс игрока.
 * @param bInDB				Удалять ли тз базы данных.
 * @param bNotify			Уведомление игрока (true - уведомить/false - не уведомлять).
 *	-
 * @return true в случае успеха, иначе false.
*/
native bool:VIP_RemoveClientVIP(iClient, bool:bInDB, bool:bNotify);

/**
 *	Проверка что ядро загружено и готово к регистрации функций.
 *	-
 * @noparams
 *	-
 * @return true если готово, иначе false.
*/
native bool:VIP_IsVIPLoaded();

/**
 *	Добавляет новую VIP-функцию.
 *	-
 * @param sFeatureName			Уникальное имя ф-и.
 * @param ValType				Тип данных ф-и.
 * @param FeatureType			Тип ф-и.
 * @param Item_select_callback	Обратный вызов при смене статуса ф-и.
 * @param Item_display_callback	Обратный вызов при отображении пункта ф-и .
 * @param Item_draw_callback	Обратный вызов при отображении стиля пункта ф-и.
 *	-
 * @noreturn
*/
native VIP_RegisterFeature(const String:sFeatureName[],
								VIP_ValueType:			ValType					= VIP_NULL,
								VIP_FeatureType:		FeatureType				= TOGGLABLE,
								ItemSelectCallback:	Item_select_callback	= ItemSelectCallback:	INVALID_FUNCTION,
								ItemDisplayCallback:	Item_display_callback	= ItemDisplayCallback:	INVALID_FUNCTION,
								ItemDrawCallback:		Item_draw_callback		= ItemDrawCallback:		INVALID_FUNCTION);

/**
 *	Удаляет VIP-функцию.
 *	-
 * @param sFeatureName			Уникальное имя ф-и.
 *	-
 * @noreturn
*/
native VIP_UnregisterFeature(const String:sFeatureName[]);

/**
 *	Проверяет существование функции.
 *	-
 * @param sFeatureName			Уникальное имя ф-и.
 *	-
 * @return	Возвращает true в случае если функция существует, иначе false.
*/
native bool:VIP_IsValidFeature(const String:sFeatureName[]);

/**
 *	Возвращает статус VIP-функции у игрока.
 *	-
 * @param iClient			Индекс игрока.
 * @param sFeatureName		Уникальное имя ф-и.
 *	-
 * @return	Возвращает DISABLED если выключена, ENABLED если включена и NO_ACCESS если у игрока нет доступа.
*/
native VIP_ToggleState:VIP_GetClientFeatureStatus(iClient, const String:sFeatureName[]);

/**
 *	Устанавливает статус VIP-функции игроку.
 *	-
 * @param iClient			Индекс игрока.
 * @param sFeatureName		Уникальное имя ф-и.
 * @param Status			Статус VIP-функции.
 *	-
 * @return true в случае успеха, иначе false.
*/
native bool:VIP_SetClientFeatureStatus(iClient, const String:sFeatureName[], VIP_ToggleState:Status);

/**
 *	Возвращает статус VIP-функции у игрока.
 *	-
 * @param iClient			Индекс игрока.
 * @param sFeatureName		Уникальное имя ф-и.
 *	-
 * @return	Возвращает true если выключена, false если включена или если у игрока нет доступа.
*/
native bool:VIP_IsClientFeatureUse(iClient, const String:sFeatureName[]);

/**
 *	Получает целочисленное значение параметра VIP-функции у игрока.
 *	-
 * @param iClient			Индекс игрока.
 * @param sFeatureName		Уникальное имя ф-и.
 *	-
 * @return	Возвращает целочисленное значение параметра VIP-функции у игрока.
*/
native VIP_GetClientFeatureInt(iClient, const String:sFeatureName[]);

/**
 *	Получает дробное значение параметра VIP-функции у игрока.
 *	-
 * @param iClient			Индекс игрока.
 * @param sFeatureName		Уникальное имя ф-и.
 *	-
 * @return	Возвращает дробное значение параметра VIP-функции у игрока.
*/
native Float:VIP_GetClientFeatureFloat(iClient, const String:sFeatureName[]);

/**
 *	Получает логическое значение параметра VIP-функции у игрока.
 *	-
 * @param iClient			Индекс игрока.
 * @param sFeatureName		Уникальное имя ф-и.
 *	-
 * @return	Возвращает true или false.
*/
native bool:VIP_GetClientFeatureBool(iClient, const String:sFeatureName[]);

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
native VIP_GetClientFeatureString(iClient, const String:sFeatureName[], String:sBuffer[], iMaxLength);

/**
 *	Выдает игроку VIP-функцию и устанавливает её значение.
 *	-
 * @param iClient			Индекс игрока.
 * @param sFeatureName		Уникальное имя ф-и.
 * @param sFeatureValue		Значение.
 *	-
 * @return true в случае успеха, иначе false.
*/
native bool:VIP_GiveClientFeature(iClient, const String:sFeatureName[], const String:sFeatureValue[]);

/**
 *	Получает Handle базы данных. После работы необходимо закрыть с помощью CloseHandle()
 *	-
 *	@noparams
 *	-
 *	@return	Handle базы данных
*/
native Handle:VIP_GetDatabase();
/**
 *	Получает тип базы данных.
 *	-
 *	@noparams
 *	-
 *	@return	true если MySQL, false если SQLite
*/
native bool:VIP_GetDatabaseType();

/**
 *	Получает время в секундах в зависимости от sm_vip_time_mode.
 *	-
 * @param iTime				Время.
 *	-
 * @return	Возвращает количество секунд в зависимости от sm_vip_time_mode.
*/
native VIP_TimeToSeconds(iTime);

/**
 *	Получает время в зависимости от sm_vip_time_mode.
 *	-
 * @param iTime				Количество секунд.
 *	-
 * @return	Возвращает время в зависимости от sm_vip_time_mode.
*/
native VIP_SecondsToTime(iTime);

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
native bool:VIP_GetTimeFromStamp(String:sBuffer[], iMaxLength, iTimeStamp, iClient = LANG_SERVER);

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
native VIP_AddStringToggleStatus(const String:sInput[], String:sBuffer[], iMaxLength, const String:sFeatureName[], iClient);

public SharedPlugin:__pl_vip_core= 
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
public __pl_vip_SetNTVOptional()
{
	MarkNativeAsOptional("VIP_CheckClient");
	MarkNativeAsOptional("VIP_IsClientVIP");
	MarkNativeAsOptional("VIP_PrintToChatClient");
	MarkNativeAsOptional("VIP_PrintToChatAll");
	MarkNativeAsOptional("VIP_LogMessage");
	MarkNativeAsOptional("VIP_GetClientID");
	MarkNativeAsOptional("VIP_GetClientVIPGroup");
	MarkNativeAsOptional("VIP_SetClientVIPGroup");
	MarkNativeAsOptional("VIP_GetClientAccessTime");
	MarkNativeAsOptional("VIP_SetClientAccessTime");
	MarkNativeAsOptional("VIP_GetVIPClientTrie");
	MarkNativeAsOptional("VIP_GetClientAuthType");
	MarkNativeAsOptional("VIP_SendClientVIPMenu");
	MarkNativeAsOptional("VIP_SetClientVIP");
	MarkNativeAsOptional("VIP_RemoveClientVIP");
	MarkNativeAsOptional("VIP_IsValidVIPGroup");
	MarkNativeAsOptional("VIP_IsVIPLoaded");
	MarkNativeAsOptional("VIP_RegisterFeature");
	MarkNativeAsOptional("VIP_UnregisterFeature");
	MarkNativeAsOptional("VIP_IsValidFeature");
	MarkNativeAsOptional("VIP_GetClientFeatureStatus");
	MarkNativeAsOptional("VIP_SetClientFeatureStatus");
	MarkNativeAsOptional("VIP_IsClientFeatureUse");
	MarkNativeAsOptional("VIP_GetClientFeatureInt");
	MarkNativeAsOptional("VIP_GetClientFeatureFloat");
	MarkNativeAsOptional("VIP_GetClientFeatureBool");
	MarkNativeAsOptional("VIP_GetClientFeatureString");
	MarkNativeAsOptional("VIP_GiveClientFeature");
	MarkNativeAsOptional("VIP_GetDatabase");
	MarkNativeAsOptional("VIP_GetDatabaseType");
	MarkNativeAsOptional("VIP_TimeToSeconds");
	MarkNativeAsOptional("VIP_SecondsToTime");
	MarkNativeAsOptional("VIP_GetTimeFromStamp");
	MarkNativeAsOptional("VIP_AddStringToggleStatus");
}
#endif

