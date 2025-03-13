#if DEBUG_MODE
char g_szDebugLogFile[PLATFORM_MAX_PATH];


#define LOG_DOWNLOADS   1   // SQL Queries
#define LOG_CONFIGS     1   // Configs
#define LOG_QUERIES     1   // SQL Queries
#define LOG_RESPONSE    1   // SQL Query Responses
#define LOG_API         1   // API
#define LOG_FEATURES    1   // FEATURES
#define LOG_CLIENTS     1   // CLIENTS
#define LOG_DB          1   // DB

public void DebugMessage(const char[] szMsg, any ...)
{
    static char szBuffer[512];
    VFormat(szBuffer, sizeof(szBuffer), szMsg, 2);
    LogToFile(g_szDebugLogFile, szBuffer);
}

#if defined LOG_DOWNLOADS
public void DBG_Download(const char[] szMsg, any ...)
{
    static char szBuffer[512];
    Format(szBuffer, sizeof(szBuffer), "Download: %s", szMsg);
    VFormat(szBuffer, sizeof(szBuffer), szMsg, 2);
    LogToFile(g_szDebugLogFile, szBuffer);
}
#else
public void DBG_Download(const char[] szMsg, any ...) {}
#endif

#if defined LOG_CONFIGS
public void DBG_Config(const char[] szMsg, any ...)
{
    static char szBuffer[512];
    Format(szBuffer, sizeof(szBuffer), "Config: %s", szMsg);
    VFormat(szBuffer, sizeof(szBuffer), szMsg, 2);
    LogToFile(g_szDebugLogFile, szBuffer);
}
#else
public void DBG_Config(const char[] szMsg, any ...) {}
#endif

#if defined LOG_CLIENTS
public void DBG_Clients(const char[] szMsg, any ...)
{
    static char szBuffer[512];
    Format(szBuffer, sizeof(szBuffer), "Clients: %s", szMsg);
    VFormat(szBuffer, sizeof(szBuffer), szMsg, 2);
    LogToFile(g_szDebugLogFile, szBuffer);
}
#else
public void DBG_Clients(const char[] szMsg, any ...) {}
#endif

#if defined LOG_QUERIES
public void DBG_SQL_Query(const char[] szMsg, any ...)
{
    static char szBuffer[512];
    Format(szBuffer, sizeof(szBuffer), "SQL_Query: %s", szMsg);
    VFormat(szBuffer, sizeof(szBuffer), szMsg, 2);
    LogToFile(g_szDebugLogFile, szBuffer);
}
#else
public void DBG_SQL_Query(const char[] szMsg, any ...) {}
#endif

#if defined LOG_RESPONSE
public void DBG_SQL_Response(const char[] szMsg, any ...)
{
    static char szBuffer[512];
    Format(szBuffer, sizeof(szBuffer), "SQL_Response: %s", szMsg);
    VFormat(szBuffer, sizeof(szBuffer), szMsg, 2);
    LogToFile(g_szDebugLogFile, szBuffer);
}
#else
public void DBG_SQL_Response(const char[] szMsg, any ...) {}
#endif

#if defined LOG_API
public void DBG_API(const char[] szMsg, any ...)
{
    static char szBuffer[512];
    Format(szBuffer, sizeof(szBuffer), "API: %s", szMsg);
    VFormat(szBuffer, sizeof(szBuffer), szMsg, 2);
    LogToFile(g_szDebugLogFile, szBuffer);
}
#else
public void DBG_API(const char[] szMsg, any ...) {}
#endif

#if defined LOG_DB
public void DBG_Database(const char[] szMsg, any ...)
{
    static char szBuffer[512];
    Format(szBuffer, sizeof(szBuffer), "Database: %s", szMsg);
    VFormat(szBuffer, sizeof(szBuffer), szMsg, 2);
    LogToFile(g_szDebugLogFile, szBuffer);
}
#else
public void DBG_Database(const char[] szMsg, any ...) {}
#endif

#else
public void DebugMessage(const char[] szMsg, any ...) {}
public void DBG_Download(const char[] szMsg, any ...) {}
public void DBG_Config(const char[] szMsg, any ...) {}
public void DBG_Clients(const char[] szMsg, any ...) {}
public void DBG_SQL_Query(const char[] szMsg, any ...) {}
public void DBG_SQL_Response(const char[] szMsg, any ...) {}
public void DBG_API(const char[] szMsg, any ...) {}
public void DBG_Database(const char[] szMsg, any ...) {}
#endif

char szValueType[][] = {
	"VIP_NULL",
	"INT",
	"FLOAT",
	"BOOL",
	"STRING"
};

char szFeatureType[][] = {
	"TOGGLABLE",
	"SELECTABLE",
	"HIDE"
};

char szToggleState[][] = {
	"DISABLED",
	"ENABLED",
	"NO_ACCESS"
};
