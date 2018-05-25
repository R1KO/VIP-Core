stock const char NO_ACCESS_SOUND[] = 	"buttons/button11.wav";
stock const char ERROR_SOUND[] = 		"buttons/weapon_cant_buy.wav";
stock const char ITEM_TOGGLE_SOUND[] = 	"ui/buttonclick.wav";

void LoadSounds()
{
	PrecacheSound(NO_ACCESS_SOUND, true);
	PrecacheSound(ERROR_SOUND, true);
	PrecacheSound(ITEM_TOGGLE_SOUND, true);
}

void PlaySound(int iClient, const char[] szSound)
{
	ClientCommand(iClient, "playgamesound %s", szSound);
} 