#if DEBUG_MODE
char g_szDebugLogFile[PLATFORM_MAX_PATH];

public void DebugMsg(const char[] sMsg, any ...)
{
    static char szBuffer[512];
    VFormat(SZF(szBuffer), sMsg, 2);
    LogToFile(g_szDebugLogFile, szBuffer);
}

// Función alias para DebugMsg
public void DebugMessage(const char[] sMsg, any ...)
{
    DebugMsg(sMsg, ...);
}

// Детальность логов
// #define LOG_DOWNLOADS	// SQL Запросы
// #define LOG_CONFIGS		// Configs
// #define LOG_QUERIES		// SQL Запросы
// #define LOG_RESPONSE		// Ответы SQL запросов
// #define LOG_API			// API
// #define LOG_FEATURES		// FEATURES
// #define LOG_CLIENTS		// CLIENTS
// #define LOG_DB			// DB
// #define LOG_INFO			// INFO

#if defined LOG_DOWNLOADS
public void DBG_Download(const char[] sMsg, any ...)
{
    static char buffer[512];
    Format(buffer, sizeof(buffer), "Download: %s", sMsg);
    DebugMsg(buffer, ...);
}
#else
public void DBG_Download(const char[] sMsg, any ...) {}
#endif

#if defined LOG_CONFIGS
public void DBG_Config(const char[] sMsg, any ...)
{
    static char buffer[512];
    Format(buffer, sizeof(buffer), "Config: %s", sMsg);
    DebugMsg(buffer, ...);
}
#else
public void DBG_Config(const char[] sMsg, any ...) {}
#endif

#if defined LOG_CLIENTS
public void DBG_Clients(const char[] sMsg, any ...)
{
    static char buffer[512];
    Format(buffer, sizeof(buffer), "Clients: %s", sMsg);
    DebugMsg(buffer, ...);
}
#else
public void DBG_Clients(const char[] sMsg, any ...) {}
#endif

#if defined LOG_QUERIES
public void DBG_SQL_Query(const char[] sMsg, any ...)
{
    DebugMsg("SQL_Query: %s", sMsg);
}
#else
public void DBG_SQL_Query(const char[] sMsg, any ...) {}
#endif

#if defined LOG_RESPONSE
public void DBG_SQL_Response(const char[] sMsg, any ...)
{
    static char buffer[512];
    Format(buffer, sizeof(buffer), "SQL_Response: %s", sMsg);
    DebugMsg(buffer, ...);
}
#else
public void DBG_SQL_Response(const char[] sMsg, any ...) {}
#endif

#if defined LOG_API
public void DBG_API(const char[] sMsg, any ...)
{
    static char buffer[512];
    Format(buffer, sizeof(buffer), "API: %s", sMsg);
    DebugMsg(buffer, ...);
}
#else
public void DBG_API(const char[] sMsg, any ...) {}
#endif

#if defined LOG_DB
public void DBG_Database(const char[] sMsg, any ...)
{
    static char buffer[512];
    Format(buffer, sizeof(buffer), "Database: %s", sMsg);
    DebugMsg(buffer, ...);
}
#else
public void DBG_Database(const char[] sMsg, any ...) {}
#endif

#else  // Si DEBUG_MODE no está definido, se generan funciones vacías
public void DebugMessage(const char[] sMsg, any ...) {}
public void DBG_Download(const char[] sMsg, any ...) {}
public void DBG_Config(const char[] sMsg, any ...) {}
public void DBG_Clients(const char[] sMsg, any ...) {}
public void DBG_SQL_Query(const char[] sMsg, any ...) {}
public void DBG_SQL_Response(const char[] sMsg, any ...) {}
public void DBG_API(const char[] sMsg, any ...) {}
public void DBG_Database(const char[] sMsg, any ...) {}
#endif


#if defined LOG_INFO
#define DBG_Info(%0) DebugMsg("Info: " ... %0);
#else
#define DBG_Info(%0)
#endif
