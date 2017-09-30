#include <sdktools_stringtables>

void ReadDownloads()
{
	char sBuffer[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sBuffer, sizeof(sBuffer), "data/vip/modules/downloadlist.txt");
	File hFile = OpenFile(sBuffer, "r");

	if(hFile != null)
	{
		int iEndPos;
		while (!hFile.EndOfFile() && hFile.ReadLine(SZF(sBuffer)))
		{
			if(sBuffer[0])
			{
				iEndPos = StrContains(sBuffer, "//");
				if(iEndPos != -1)
				{
					sBuffer[iEndPos] = 0;
				}

				if(sBuffer[0] && IsCharAlpha(sBuffer[0]))
				{
					DebugMessage("ReadFileLine: '%s'", sBuffer)
					
					TrimString(sBuffer);

					File_AddToDownloadsTable(sBuffer);
				}
			}
		}

		delete hFile;
	}
}

bool File_AddToDownloadsTable(const char[] sPath)
{
	DebugMessage("File_AddToDownloadsTable: '%s'", sPath)
	
	if(FileExists(sPath))
	{
		DebugMessage("File '%s' Loaded", sPath)
		
		AddFileToDownloadsTable(sPath);
	}
	else if(DirExists(sPath))
	{
		Dir_AddToDownloadsTable(sPath);
	}
}

bool Dir_AddToDownloadsTable(const char[] sPath)
{
	DebugMessage("Dir_AddToDownloadsTable: '%s'", sPath)
	
	if(DirExists(sPath))
	{
		DirectoryListing hDir = OpenDirectory(sPath);
		if(hDir != null)
		{
			char sDirEntry[PLATFORM_MAX_PATH];
			while (hDir.GetNext(SZF(sDirEntry)))
			{
				if ((UTIL_StrCmpEx(sDirEntry, ".") || UTIL_StrCmpEx(sDirEntry, "..")) == false)
				{
					Format(sDirEntry, sizeof(sDirEntry), "%s/%s", sPath, sDirEntry);

					File_AddToDownloadsTable(sDirEntry);
				}
			}
			delete hDir;
		}
	}
}