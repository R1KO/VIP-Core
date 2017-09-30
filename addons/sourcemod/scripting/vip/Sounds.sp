#define NO_ACCESS_SOUND				"buttons/button11.wav"
#define ERROR_SOUND					"buttons/weapon_cant_buy.wav"
#define ITEM_TOGGLE_SOUND			"ui/buttonclick.wav"

void LoadSounds()
{
	PrecacheSound(NO_ACCESS_SOUND, true);
	PrecacheSound(ERROR_SOUND, true);
	PrecacheSound(ITEM_TOGGLE_SOUND, true);
}

void PlaySound(int iClient, const char[] sSound)
{
	ClientCommand(iClient, "playgamesound %s", sSound);
} 