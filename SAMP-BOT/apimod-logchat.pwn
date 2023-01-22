//---------------------- APIMOD.GG ---------------------//
//
//****** SAMP LOG-CHAT ****[ RELEASE DATE 22.01.2023 ] ****
//
// Github: https://github.com/CourierDeveloper/apimod.gg
//-----------------------------------------------------//
//
//
// Credits:
// Code writted by Courier (https://github.com/CourierDeveloper)
//
//------------------- README ---------------------//
//
//>> [!] Medium - advanced knowledge of Pawn, SQL and use of the discord API is required, please remember to download all our git files 
//in order to make the application functional.

//>> APIMOD.gg is in constant progress so the code may undergo future updates.

//>> APIMOD.gg does not provide support.

//>> APIMOD.gg Discord: https://discord.gg/JAG9XmqPAb
//
//
//---------------------------------------//

//---------- FILES REQUIRED SAMP-BOT [R.1] ---------//

//>> PLUGINS-API

//--CODE--//
#include <a_samp>
#include <discord-connector>

new DCC_Channel:g_Discord_Chat;

public OnFilterScriptInit()
{
	print("\n===================================");
	print("|         APIMOD.GG CONNECTED	    |");
	print("| DISCORD BOT ONLINE ON YOUT SERVER  |");
	print("=====================================\n");
	g_Discord_Chat = DCC_FindChannelById("ID"); // Discord channel ID
    return 1;
}

forward DCC_OnMessageCreate(DCC_Message:message);

public DCC_OnMessageCreate(DCC_Message:message)
{
	new realMsg[100];
    DCC_GetMessageContent(message, realMsg, 100);
    new bool:IsBot;
    new DCC_Channel:channel;
 	DCC_GetMessageChannel(message, channel);
    new DCC_User:author;
	DCC_GetMessageAuthor(message, author);
    DCC_IsUserBot(author, IsBot);
    if(channel == g_Discord_Chat && !IsBot) //!IsBot will block BOT's message in game
    {
        new user_name[32 + 1], str[152];
       	DCC_GetUserName(author, user_name, 32);
        format(str,sizeof(str), "{aa1bb5}[APIMOD-BOT] %s: {ffffff}%s",user_name, realMsg);
        SendClientMessageToAll(-1, str);
    }

    return 1;
}

public OnPlayerText(playerid, text[])
{

    new name[MAX_PLAYER_NAME + 1];
    GetPlayerName(playerid, name, sizeof name);
    new msg[128]; 
    format(msg, sizeof(msg), "```%s: %s```", name, text);
    DCC_SendChannelMessage(g_Discord_Chat, msg);
    return 1;
}



public OnPlayerConnect(playerid)
{
   	new name[MAX_PLAYER_NAME + 1];
    GetPlayerName(playerid, name, sizeof name);

    if (_:g_Discord_Chat == 0)
    g_Discord_Chat = DCC_FindChannelById("ID"); // Discord channel ID

    new string[128];
    format(string, sizeof string, " ```Player %s online```", name);
    DCC_SendChannelMessage(g_Discord_Chat, string);
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    new name[MAX_PLAYER_NAME + 1];
    GetPlayerName(playerid, name, sizeof name);

    if (_:g_Discord_Chat == 0)
    g_Discord_Chat = DCC_FindChannelById("ID"); // Discord channel ID

    new string[128];
    format(string, sizeof string, " ```Player %s disconnected```", name);
    DCC_SendChannelMessage(g_Discord_Chat, string);
    return 1;
}
