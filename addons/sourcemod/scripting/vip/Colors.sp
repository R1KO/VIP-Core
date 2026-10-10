void Colors_Print(int iClient, const char[] szFormat)
{
	char szMessage[1024];
	FormatEx(SZF(szMessage), g_EngineVersion == Engine_CSGO ? " \x01%t %s":"\x01%t %s", "VIP_CHAT_PREFIX", szFormat);

	ReplaceString(SZF(szMessage), "\\n", "\n");
	ReplaceString(SZF(szMessage), "{DEFAULT}", "\x01");
	ReplaceString(SZF(szMessage), "{GREEN}", "\x04");
	
	switch (g_EngineVersion)
	{
	case Engine_SourceSDK2006, Engine_Left4Dead, Engine_Left4Dead2:
		{
			ReplaceString(SZF(szMessage), "{LIGHTGREEN}", "\x03");
			int iColor = Colors_ReplaceColors(SZF(szMessage));
			switch (iColor)
			{
			case -1:	Colors_SayText2(iClient, 0, szMessage);
			case 0:		Colors_SayText2(iClient, iClient, szMessage);
			default:
				{
					Colors_SayText2(iClient, Colors_FindPlayerByTeam(iColor), szMessage);
				}
			}
		}
	case Engine_CSS, Engine_TF2, Engine_DODS, Engine_HL2DM:
		{
			ReplaceString(SZF(szMessage), "#", "\x07");
			if (ReplaceString(SZF(szMessage), "{TEAM}", "\x03"))
			{
				Colors_SayText2(iClient, iClient, szMessage);
			}
			else
			{
				ReplaceString(SZF(szMessage), "{LIGHTGREEN}", "\x03");
				Colors_SayText2(iClient, 0, szMessage);
			}
		}
	case Engine_CSGO:
		{
			static const char szColorName[][] = 
			{
				"{RED}", 
				"{LIME}", 
				"{LIGHTGREEN}", 
				"{LIGHTRED}", 
				"{GRAY}", 
				"{LIGHTOLIVE}", 
				"{OLIVE}", 
				"{LIGHTBLUE}", 
				"{BLUE}", 
				"{PURPLE}"
			}, 
			szColorCode[][] = 
			{
				"\x02", 
				"\x05", 
				"\x06", 
				"\x07", 
				"\x08", 
				"\x09", 
				"\x10", 
				"\x0B", 
				"\x0C", 
				"\x0E"
			};
			
			for (int i = 0; i < sizeof(szColorName); ++i)
			{
				ReplaceString(SZF(szMessage), szColorName[i], szColorCode[i]);
			}
			
			if (ReplaceString(SZF(szMessage), "{TEAM}", "\x03"))
			{
				Colors_SayText2(iClient, iClient, szMessage);
			}
			else
			{
				Colors_SayText2(iClient, 0, szMessage);
			}
		}
	default:
		{
			ReplaceString(SZF(szMessage), "{TEAM}", "\x03");
		}
	}
}

int Colors_ReplaceColors(char[] sMsg, int MaxLength)
{
	if (ReplaceString(sMsg, MaxLength, "{TEAM}", "\x03"))
	{
		return 0;
	}
	
	if (ReplaceString(sMsg, MaxLength, "{BLUE}", "\x03"))
	{
		return 3;
	}
	if (ReplaceString(sMsg, MaxLength, "{RED}", "\x03"))
	{
		return 2;
	}
	if (ReplaceString(sMsg, MaxLength, "{GRAY}", "\x03"))
	{
		return 1;
	}
	
	return -1;
}

int Colors_FindPlayerByTeam(int iTeam)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == iTeam)
		{
			return i;
		}
	}
	
	return 0;
}

// One SayText2 holds at most 255 bytes and CS:GO drops colors after '\n', so every line goes as its own message
void Colors_SayText2(int iClient, int iAuthor = 0, const char[] szMessage)
{
	// 255 bytes minus the author and chat flag bytes
	char szLine[253];
	int iStart = 0;
	for (int i = 0; ; ++i)
	{
		if (szMessage[i] != '\n' && szMessage[i])
		{
			continue;
		}

		if (i > iStart)
		{
			// CS:GO ignores a color code at the very start of a message
			int iOffset = (iStart > 0 && g_EngineVersion == Engine_CSGO) ? 1 : 0;
			szLine[0] = ' ';
			int iLength = i - iStart + 1;
			if (iLength > sizeof(szLine) - iOffset)
			{
				iLength = sizeof(szLine) - iOffset;
			}
			strcopy(szLine[iOffset], iLength, szMessage[iStart]);
			Colors_SendSayText2(iClient, iAuthor, szLine);
		}

		if (!szMessage[i])
		{
			break;
		}
		iStart = i + 1;
	}
}

static void Colors_SendSayText2(int iClient, int iAuthor, const char[] szMessage)
{
	int iClients[1];
	iClients[0] = iClient;
	Handle hBuffer = StartMessage("SayText2", iClients, 1, USERMSG_RELIABLE | USERMSG_BLOCKHOOKS);
	if (GetUserMessageType() == UM_Protobuf)
	{
		Protobuf pbBuffer = UserMessageToProtobuf(hBuffer);
		pbBuffer.SetInt("ent_idx", iAuthor);
		pbBuffer.SetBool("chat", true);
		pbBuffer.SetString("msg_name", szMessage);
		pbBuffer.AddString("params", "");
		pbBuffer.AddString("params", "");
		pbBuffer.AddString("params", "");
		pbBuffer.AddString("params", "");
	}
	else
	{
		BfWrite bfBuffer = UserMessageToBfWrite(hBuffer);
		bfBuffer.WriteByte(iAuthor);
		bfBuffer.WriteByte(true);
		bfBuffer.WriteString(szMessage);
	}
	EndMessage();
}

void Colors_RemoveColors(char[] szBuffer)
{
    int iLen = strlen(szBuffer), i = 0, j = 0;
    char[] szTemp = new char[iLen+1];
    strcopy(szTemp, iLen+1, szBuffer);
    bool bIgnore = false;

    for(; i < iLen; ++i)
    {
        if(bIgnore)
        {
            if(szTemp[i] == '}')
            {
                bIgnore = false;
            }
            continue;
        }

        if(szTemp[i] == '{')
        {
            bIgnore = true;
            continue;
        }

        szBuffer[j++] = szTemp[i];
    }

    szBuffer[j] = 0;
}
