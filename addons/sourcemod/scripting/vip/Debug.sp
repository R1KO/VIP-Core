#if DEBUG_MODE
char g_szDebugLogFile[PLATFORM_MAX_PATH];


#define LOG_DOWNLOADS   1   // SQL Запросы
#define LOG_CONFIGS     1   // Configs
#define LOG_QUERIES     1   // SQL Запросы
#define LOG_RESPONSE    1   // Ответы SQL запросов
#define LOG_API         1   // API
#define LOG_FEATURES    1   // FEATURES
#define LOG_CLIENTS     1   // CLIENTS
#define LOG_DB          1   // DB

public void DebugMessage(const char[] sMsg, any ...)
{
    static char sBuffer[512];
    VFormat(sBuffer, sizeof(sBuffer), sMsg, 2);
    LogToFile(g_szDebugLogFile, sBuffer);
}

#if defined LOG_DOWNLOADS
public void DBG_Download(const char[] sMsg, any ...)
{
    static char szBuffer[512];
    Format(szBuffer, sizeof(szBuffer), "Download: %s", sMsg);
    VFormat(szBuffer, sizeof(szBuffer), sMsg, 2);
    LogToFile(g_szDebugLogFile, szBuffer);
}
#else
public void DBG_Download(const char[] sMsg, any ...) {}
#endif

#if defined LOG_CONFIGS
public void DBG_Config(const char[] sMsg, any ...)
{
    static char szBuffer[512];
    Format(szBuffer, sizeof(szBuffer), "Config: %s", sMsg);
    VFormat(szBuffer, sizeof(szBuffer), sMsg, 2);
    LogToFile(g_szDebugLogFile, szBuffer);
}
#else
public void DBG_Config(const char[] sMsg, any ...) {}
#endif

#if defined LOG_CLIENTS
public void DBG_Clients(const char[] sMsg, any ...)
{
    static char szBuffer[512];
    Format(szBuffer, sizeof(szBuffer), "Clients: %s", sMsg);
    VFormat(szBuffer, sizeof(szBuffer), sMsg, 2);
    LogToFile(g_szDebugLogFile, szBuffer);
}
#else
public void DBG_Clients(const char[] sMsg, any ...) {}
#endif

#if defined LOG_QUERIES
public void DBG_SQL_Query(const char[] sMsg, any ...)
{
    static char szBuffer[512];
    Format(szBuffer, sizeof(szBuffer), "SQL_Query: %s", sMsg);
    VFormat(szBuffer, sizeof(szBuffer), sMsg, 2);
    LogToFile(g_szDebugLogFile, szBuffer);
}
#else
public void DBG_SQL_Query(const char[] sMsg, any ...) {}
#endif

#if defined LOG_RESPONSE
public void DBG_SQL_Response(const char[] sMsg, any ...)
{
    static char szBuffer[512];
    Format(szBuffer, sizeof(szBuffer), "SQL_Response: %s", sMsg);
    VFormat(szBuffer, sizeof(szBuffer), sMsg, 2);
    LogToFile(g_szDebugLogFile, szBuffer);
}
#else
public void DBG_SQL_Response(const char[] sMsg, any ...) {}
#endif

#if defined LOG_API
public void DBG_API(const char[] sMsg, any ...)
{
    static char szBuffer[512];
    Format(szBuffer, sizeof(szBuffer), "API: %s", sMsg);
    VFormat(szBuffer, sizeof(szBuffer), sMsg, 2);
    LogToFile(g_szDebugLogFile, szBuffer);
}
#else
public void DBG_API(const char[] sMsg, any ...) {}
#endif

#if defined LOG_DB
public void DBG_Database(const char[] sMsg, any ...)
{
    static char szBuffer[512];
    Format(szBuffer, sizeof(szBuffer), "Database: %s", sMsg);
    VFormat(szBuffer, sizeof(szBuffer), sMsg, 2);
    LogToFile(g_szDebugLogFile, szBuffer);
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
