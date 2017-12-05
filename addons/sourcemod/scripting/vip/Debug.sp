
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
#define LOG_QUERIES              // SQL Запросы
#define LOG_API                  // API
#define LOG_FEATURES             // API
#define LOG_CLIENTS              // API
#define LOG_DB                   // API

/*
#if defined LOG_QUERIES
...
#endif
*/

#else
#define DebugMessage(%0)
#endif
