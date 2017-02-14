#define NO_ACCESS_SOUND				"buttons/button11.wav"
#define ERROR_SOUND					"buttons/weapon_cant_buy.wav"
#define ITEM_TOGGLE_SOUND			"ui/buttonclick.wav"

//#define ERROR_SOUND					"buttons/weapon_confirm.wav"

LoadSounds()
{
	PrecacheSound(NO_ACCESS_SOUND, true);
	PrecacheSound(ERROR_SOUND, true);
	PrecacheSound(ITEM_TOGGLE_SOUND, true);
}
/*
LoadSounds()
{
	LoadSound(NO_ACCESS_SOUND);
	LoadSound(NO_ACCESS_SOUND2);
	LoadSound(ITEM_TOGGLE_SOUND);
}

LoadSound(const String:sSound[])
{
	decl String:sBuffer[200];
	FormatEx(sBuffer, sizeof(sBuffer), "sound/%s", sSound);
	if(FileExists(sBuffer))
	{
		AddFileToDownloadsTable(sBuffer);
		PrecacheSound(sSound, true);
	}
}*/

PlaySound(iClient, const String:sSound[]) ClientCommand(iClient, "playgamesound %s", sSound);