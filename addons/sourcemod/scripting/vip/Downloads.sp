#include <sdktools_stringtables>

void ReadDownloads()
{
	char szBuffer[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, SZF(szBuffer), "data/vip/modules/downloadlist.txt");
	File hFile = OpenFile(szBuffer, "r");

	if (hFile == null)
	{
		return;
	}
	DBG_Download("OpenFile('%s')", szBuffer)
	int iEndPos;
	while (!hFile.EndOfFile() && hFile.ReadLine(SZF(szBuffer)))
	{
		DBG_Download("ReadLine = '%s'", szBuffer)
		if (!szBuffer[0])
		{
			continue;
		}
		iEndPos = StrContains(szBuffer, "//");
		DBG_Download("iEndPos = %d", iEndPos)
		if (iEndPos != -1)
		{
			szBuffer[iEndPos] = 0;
		}

		if (szBuffer[0] && IsCharAlpha(szBuffer[0]))
		{
			DBG_Download("ReadFileLine: '%s'", szBuffer)
			
			TrimString(szBuffer);

			File_AddToDownloadsTable(szBuffer);
		}
	}

	delete hFile;
}

void File_AddToDownloadsTable(const char[] szPath)
{
	DBG_Download("File_AddToDownloadsTable: '%s'", szPath)
	
	if (FileExists(szPath))
	{
		DBG_Download("File '%s' Loaded", szPath)
		
		AddFileToDownloadsTable(szPath);
		return;
	}

	if (DirExists(szPath))
	{
		Dir_AddToDownloadsTable(szPath);
	}
}

void Dir_AddToDownloadsTable(const char[] szPath)
{
	DBG_Download("Dir_AddToDownloadsTable: '%s'", szPath)
	
	if (!DirExists(szPath))
	{
		return;
	}
	
	DirectoryListing hDir = OpenDirectory(szPath);
	if (hDir == null)
	{
		return;
	}

	char szDirEntry[PMP];
	while (hDir.GetNext(SZF(szDirEntry)))
	{
		if (
			UTIL_StrCmpEx(szDirEntry, ".") || 
			UTIL_StrCmpEx(szDirEntry, "..") || 
			UTIL_StrCmpEx(szDirEntry[strlen(szDirEntry)-4], ".bz2"))
		{
			continue;
		}

		Format(SZF(szDirEntry), "%s/%s", szPath, szDirEntry);
		File_AddToDownloadsTable(szDirEntry);
	}

	delete hDir;
}
