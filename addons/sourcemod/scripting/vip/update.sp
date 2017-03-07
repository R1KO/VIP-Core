#include <socket> 

#define SITE			"dfb3806t.bget.ru/vip_update" 
#define SCRIPT		"check_version.php"
#define PLUGIN_URL	"dfb3806t.bget.ru/vip_update/VIP_Core.smx"
#define PLUGIN_URL	"dfb3806t.bget.ru/vip_update/VIP_Core.smx"
#define PLUGIN_PATH	"plugins/vip/VIP_Core.smx"

Protect_OnPluginStart() 
{ 
	new Handle:hSocket = SocketCreate(SOCKET_TCP, OnSocketError); 
	SocketConnect(hSocket, OnSocketConnected, OnSocketReceive, OnSocketDisconnected, SITE, 80); 
} 

public OnSocketConnected(Handle:hSocket, any:arg)  
{ 
	char sVersion[10]; char sRequest[128]; 

	GetPluginInfo(GetMyHandle(), PlInfo_Version, sVersion, sizeof(sVersion));
	FormatEx(sRequest, sizeof(sRequest), "GET /%s?version=%s HTTP/1.0\r\nHost: %s\r\nConnection: close\r\n\r\n", SCRIPT, sVersion, SITE); 
	SocketSend(hSocket, sRequest); 
} 

public OnSocketReceive(Handle:hSocket, char[] receiveData, const dataSize, any:arg)  
{ 
	if(dataSize > 0 && StrContains(receiveData, "true", false) != -1)
	{
		LogMessage("[VIP UPDATE] Обнаружена новая версия плагина. Обновление...");
		Download_Socket();
	}
} 

public OnSocketDisconnected(Handle:hSocket, any:arg) CloseHandle(hSocket); 

public OnSocketError(Handle:hSocket, const errorType, const errorNum, any:arg)  
{ 
	LogError("[VIP UPDATE] Socket error %d (error num %d)", errorType, errorNum);
	CloseHandle(hSocket); 
}

Download_Socket()
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), PLUGIN_PATH);
	DeleteFile(sPath);

	new Handle:file = OpenFile(sPath, "wb");
	if (file == INVALID_HANDLE)
	{
		char error[PLATFORM_MAX_PATH];
		FormatEx(error, sizeof(error), "Unable to write data in \"%s\"", sPath);
	}

	char hostname[64]; char location[128]; char filename[64]; char request[MAX_URL_LENGTH+128];
	ParseURL(url, hostname, sizeof(hostname), location, sizeof(location), filename, sizeof(filename));
	FormatEx(request, sizeof(request), "GET %s HTTP/1.0\r\nHost: %s\r\nUser-agent: plugin\r\nConnection: close\r\nPragma: no-cache\r\nCache-Control: no-cache\r\n\r\n", PLUGIN_URL, SITE);

	new Handle:hDLPack = CreateDataPack();
	WritePackCell(hDLPack, 0);
	WritePackCell(hDLPack, _:file);
	WritePackString(hDLPack, request);

	new Handle:socket = SocketCreate(SOCKET_TCP, OnSocketError);
	SocketSetArg(socket, hDLPack);
	SocketSetOption(socket, ConcatenateCallbacks, 4096);
	SocketConnect(socket, OnSocketConnected, OnSocketReceive, OnSocketDisconnected, hostname, 80);
}

ParseURL(const char[] url, char[] host, maxHost, char[] location, maxLoc, char[] filename, maxName)
{
	new idx = StrContains(url, "://");
	idx = (idx != -1) ? idx + 3 : 0;

	char dirs[16][64];
	new total = ExplodeString(url[idx], "/", dirs, sizeof(dirs), sizeof(dirs[]));

	FormatEx(host, maxHost, "%s", dirs[0]);

	location[0] = '\0';
	for (new i = 1; i < total - 1; i++)
	{
		FormatEx(location, maxLoc, "%s/%s", location, dirs[i]);
	}

	FormatEx(filename, maxName, "%s", dirs[total-1]);
}

public OnSocketConnected(Handle:socket, any:hDLPack)
{
	char request[MAX_URL_LENGTH+128];
	SetPackPosition(hDLPack, 16);
	ReadPackString(hDLPack, request, sizeof(request));

	SocketSend(socket, request);
}

public OnSocketReceive(Handle:socket, char[] data, const size, any:hDLPack)
{
	new idx = 0;

	SetPackPosition(hDLPack, 0);
	new bool:bParsedHeader = bool:ReadPackCell(hDLPack);

	if (!bParsedHeader)
	{
		if ((idx = StrContains(data, "\r\n\r\n")) == -1)
			idx = 0;
		else
			idx += 4;

		SetPackPosition(hDLPack, 0);
		WritePackCell(hDLPack, 1);
	}

	SetPackPosition(hDLPack, 8);
	new Handle:file = Handle:ReadPackCell(hDLPack);

	while (idx < size)
	{
		WriteFileCell(file, data[idx++], 1);
	}
}

public OnSocketDisconnected(Handle:socket, any:hDLPack)
{
	SetPackPosition(hDLPack, 8);
	CloseHandle(Handle:ReadPackCell(hDLPack));
	CloseHandle(hDLPack);
	CloseHandle(socket);
}

public OnSocketError(Handle:socket, const errorType, const errorNum, any:hDLPack)
{
	SetPackPosition(hDLPack, 8);
	CloseHandle(Handle:ReadPackCell(hDLPack));
	CloseHandle(hDLPack);
	CloseHandle(socket);

	char error[256];
	FormatEx(error, sizeof(error), "Socket error: %d (Error code %d)", errorType, errorNum);
}
