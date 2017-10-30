#include <sdktools_stringtables>

void ReadDownloads()
{
	char szBuffer[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, SZF(szBuffer), "data/vip/modules/downloadlist.txt");
	File hFile = OpenFile(szBuffer, "r");

	if(hFile != null)
	{
		int iEndPos;
		while (!hFile.EndOfFile() && hFile.ReadLine(SZF(szBuffer)))
		{
			if(szBuffer[0])
			{
				iEndPos = StrContains(szBuffer, "//");
				if(iEndPos != -1)
				{
					szBuffer[iEndPos] = 0;
				}

				if(szBuffer[0] && IsCharAlpha(szBuffer[0]))
				{
					DebugMessage("ReadFileLine: '%s'", szBuffer)
					
					TrimString(szBuffer);

					File_AddToDownloadsTable(szBuffer);
				}
			}
		}

		delete hFile;
	}
}

bool File_AddToDownloadsTable(const char[] szPath)
{
	DebugMessage("File_AddToDownloadsTable: '%s'", szPath)
	
	if(FileExists(szPath))
	{
		DebugMessage("File '%s' Loaded", szPath)
		
		AddFileToDownloadsTable(szPath);
	}
	else if(DirExists(szPath))
	{
		Dir_AddToDownloadsTable(szPath);
	}
}

bool Dir_AddToDownloadsTable(const char[] szPath)
{
	DebugMessage("Dir_AddToDownloadsTable: '%s'", szPath)
	
	if(DirExists(szPath))
	{
		DirectoryListing hDir = OpenDirectory(szPath);
		if(hDir != null)
		{
			char szDirEntry[PLATFORM_MAX_PATH];
			while (hDir.GetNext(SZF(szDirEntry)))
			{
				if ((UTIL_StrCmpEx(szDirEntry, ".") || UTIL_StrCmpEx(szDirEntry, "..")) == false)
				{
					Format(SZF(szDirEntry), "%s/%s", szPath, szDirEntry);

					File_AddToDownloadsTable(szDirEntry);
				}
			}
			delete hDir;
		}
	}
}