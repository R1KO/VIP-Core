#include <sdktools_stringtables>

void ReadDownloads()
{
	char szBuffer[PMP];
	BuildPath(Path_SM, SZF(szBuffer), "data/vip/modules/downloadlist.txt");
	File hFile = OpenFile(szBuffer, "r");

	if(!hFile)
		return;

	DBG_Download("OpenFile('%s')", szBuffer);
	int iPos;
	while (!hFile.EndOfFile() && hFile.ReadLine(SZF(szBuffer)))
	{
		DBG_Download("ReadLine = '%s'", szBuffer);

		iPos = StrContains(szBuffer, "//");
		DBG_Download("iPos = %d", iPos);
		if(iPos == 0)
			continue;

		if(iPos != -1)
			szBuffer[iPos] = 0;

		TrimString(szBuffer);

		if(!szBuffer[0] || !IsCharAlpha(szBuffer[0]))
			continue;

		DBG_Download("ReadFileLine: '%s'", szBuffer);

		iPos = strlen(szBuffer) - 1;
		if (szBuffer[iPos] == '/' || szBuffer[iPos] == '\\')
		{
			szBuffer[iPos] = '\0';
		}

		DownloadPath(szBuffer);
	}

	delete hFile;
}

void DownloadPath(const char[] szPath)
{
	DBG_Download("DownloadPath: '%s'", szPath);
	
	if(DownloadFile(szPath))
		return;

	DBG_Download("DirExists: %d", DirExists(szPath));
	if(DirExists(szPath))
	{
		DownloadDirectory(szPath);
	}
}

void DownloadDirectory(const char[] szPath)
{
	DBG_Download("DownloadDirectory: '%s'", szPath);

	DirectoryListing hDir = OpenDirectory(szPath);
	if(!hDir)
		return;

	char szEntry[PMP], szNewPath[PMP];
	FileType type;
	while (hDir.GetNext(SZF(szEntry), type))
	{
		DBG_Download("GetNext: '%s' %d", szEntry, type);
		if (type == FileType_Directory && (!strcmp(szEntry, ".") || !strcmp(szEntry, "..")))
			continue;

		FormatEx(SZF(szNewPath), "%s/%s", szPath, szEntry);
		DBG_Download("szNewPath: '%s'", szNewPath);

		switch (type)
		{
			case FileType_Directory: DownloadDirectory(szNewPath);
			case FileType_File:	DownloadFile(szNewPath);
		}
	}

	delete hDir;
}

bool DownloadFile(const char[] szPath)
{
	DBG_Download("DownloadFile: '%s'", szPath);
	DBG_Download("FileExists: %d", FileExists(szPath));
	if(FileExists(szPath))
	{
		AddFileToDownloadsTable(szPath);

		return true;
	}

	return false;
}
