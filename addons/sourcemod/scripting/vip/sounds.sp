#define NO_ACCESS_SOUND				"buttons/button11.wav"
#define ERROR_SOUND					"buttons/weapon_cant_buy.wav"
#define ITEM_TOGGLE_SOUND			"ui/buttonclick.wav"

//#define ERROR_SOUND					"buttons/weapon_confirm.wav"

void LoadSounds()
{
	PrecacheSound(NO_ACCESS_SOUND, true);
	PrecacheSound(ERROR_SOUND, true);
	PrecacheSound(ITEM_TOGGLE_SOUND, true);
}
/*
void LoadSounds()
{
	LoadSound(NO_ACCESS_SOUND);
	LoadSound(NO_ACCESS_SOUND2);
	LoadSound(ITEM_TOGGLE_SOUND);
}

void LoadSound(const char[] sSound)
{
	char sBuffer[200];
	FormatEx(sBuffer, sizeof(sBuffer), "sound/%s", sSound);
	if(FileExists(sBuffer))
	{
		AddFileToDownloadsTable(sBuffer);
		PrecacheSound(sSound, true);
	}
}*/

void PlaySound(int iClient, const char[] sSound) ClientCommand(iClient, "playgamesound %s", sSound);