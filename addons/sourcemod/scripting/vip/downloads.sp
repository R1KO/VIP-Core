#include <sdktools>

void ReadDownloads()
{
	char sBuffer[PLATFORM_MAX_PATH]; Handle:hFile;
	BuildPath(Path_SM, sBuffer, sizeof(sBuffer), "data/vip/modules/downloadlist.txt");
	hFile = OpenFile(sBuffer, "r");
	
	if (hFile != INVALID_HANDLE)
	{
		while (IsEndOfFile(hFile) == false && ReadFileLine(hFile, sBuffer, sizeof(sBuffer)))
		{
			if (sBuffer[0] && IsCharAlpha(sBuffer[0]) && StrContains(sBuffer, "//") == -1)
			{
				DebugMessage("ReadFileLine: '%s'", sBuffer)
				
				TrimString(sBuffer);
				//	UTIL_ReplaceChars(sBuffer, '\\', '/');
				//  92, 47);
				File_AddToDownloadsTable(sBuffer);
			}
		}
		
		CloseHandle(hFile);
	}
}

bool File_AddToDownloadsTable(const char[] sPath)
{
	DebugMessage("File_AddToDownloadsTable: '%s'", sPath)
	
	if (FileExists(sPath))
	{
		DebugMessage("File '%s' Loaded", sPath)
		
		AddFileToDownloadsTable(sPath);
	}
	else if (DirExists(sPath))
	{
		Dir_AddToDownloadsTable(sPath);
	}
}

bool Dir_AddToDownloadsTable(const char[] sPath)
{
	DebugMessage("Dir_AddToDownloadsTable: '%s'", sPath)
	
	if (DirExists(sPath))
	{
		decl Handle:hDir;
		hDir = OpenDirectory(sPath);
		if (hDir != INVALID_HANDLE)
		{
			char dirEntry[PLATFORM_MAX_PATH];
			while (ReadDirEntry(hDir, dirEntry, sizeof(dirEntry)))
			{
				if ((UTIL_StrCmpEx(dirEntry, ".") || UTIL_StrCmpEx(dirEntry, "..")) == false)
				{
					Format(dirEntry, sizeof(dirEntry), "%s/%s", sPath, dirEntry);
					
					File_AddToDownloadsTable(dirEntry);
				}
			}
			CloseHandle(hDir);
		}
	}
} 