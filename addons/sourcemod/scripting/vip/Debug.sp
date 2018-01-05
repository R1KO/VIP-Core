
#if DEBUG_MODE 1
char g_szDebugLogFile[PLATFORM_MAX_PATH];

void DebugMsg(const char[] sMsg, any ...)
{
	static char szBuffer[512];
	VFormat(SZF(szBuffer), sMsg, 2);
	LogToFile(g_szDebugLogFile, szBuffer);
}
#define DebugMessage(%0) DebugMsg(%0);

// Детальность логов
#define LOG_QUERIES				// SQL Запросы
#define LOG_RESPONSE			// Ответы SQL запросов
#define LOG_API					// API
#define LOG_FEATURES			// API
#define LOG_CLIENTS				// API
#define LOG_DB					// API

#else
#define DebugMessage(%0)
#endif

#if defined LOG_QUERIES
#define DBG_SQL_Query(%0) DebugMsg("SQL_Query: " ... %0);
#else
#define DBG_SQL_Query(%0)
#endif

#if defined LOG_RESPONSE
#define DBG_SQL_Response(%0) DebugMsg("SQL_Response: " ... %0);
#else
#define DBG_SQL_Response(%0)
#endif

#if defined LOG_API
#define DBG_API(%0) DebugMsg("API: " ... %0);
#else
#define DBG_API(%0)
#endif
