//---------------------- APIMOD.GG ---------------------//
//
//****** SAMP VOICE / WHITELISTED + DISCORD ****[ RELEASE DATE 22.01.2023 ] ****
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

//---------- FILES REQUIRED SAMP-VOICE-WHITELISTED [R.1] ---------//

//>> PLUGINS-API
//>> DATABASE SQL

#include <a_samp>
#include <discord-connector>
#include <discord-cmd>

// Enums
	pDiscordName[16],
	pDiscordTag[8],
	pVoiceChat,

//------------ REQUIRED --- MYSQL -------//
//
    #if defined DISCORD
	forward DiscordSet(username[], discord[], tag[]);
	public DiscordSet(username[], discord[], tag[])
	{
		if(!cache_get_row_count(connectionID))
		{
			DCC_SendChannelMessage(DCC_FindChannelById(TADMIN), "The player specified doesn't exist.");
		}
		else
		{
			mysql_format(connectionID, queryBuffer, sizeof(queryBuffer), "UPDATE users SET discordname = '%s', discordtag = '%s' WHERE username = '%e'", discord, tag, username);
			mysql_tquery(connectionID, queryBuffer);

			SAM(COLOR_LIGHTRED, "AdmCmd: "SERVER_BOT" has set %s's discord account.", username);

			new string[128];
			format(string, sizeof(string), "AdmCmd: "SERVER_BOT" has set %s's discord account.", username);
			DCC_SendChannelMessage(DCC_FindChannelById(TADMIN), string);
		}
	}

	forward DOnAdminLockAccount(username[]);
	public DOnAdminLockAccount(username[])
	{
		if(!cache_get_row_count(connectionID))
		{
			DCC_SendChannelMessage(DCC_FindChannelById(TADMIN), "The player specified doesn't exist.");
		}
		else
		{
			mysql_format(connectionID, queryBuffer, sizeof(queryBuffer), "UPDATE users SET locked = 1 WHERE username = '%e'", username);
			mysql_tquery(connectionID, queryBuffer);

			SAM(COLOR_LIGHTRED, "AdmCmd: "SERVER_BOT" has whitelist %s's account.", username);

			new string[128];
			format(string, sizeof(string), "AdmCmd: "SERVER_BOT" has whitelist %s's account.", username);
			DCC_SendChannelMessage(DCC_FindChannelById(TADMIN), string);
		}
	}
#endif

// get_file SQL
			cache_get_field_content(0, "discordtag", PlayerInfo[extraid][pDiscordTag], connectionID, 8);
			cache_get_field_content(0, "discordname", PlayerInfo[extraid][pDiscordName], connectionID, 16);

// Server Commands

#if defined DISCORD
	CMD:setdiscord(playerid, params[]) {
		new targetid, name[16], id[8];

		if(PlayerInfo[playerid][pAdmin] < 1)
		{
			return SCM(playerid, COLOR_SYNTAX, "You are not authorized to use this command.");
		}
		if(sscanf(params, "us[16]s[8]", targetid, name, id))
		{
			SCM(playerid, COLOR_GREY2, "Usage: /setdiscord [playerid] [discordname] [tag] (ex. /setdiscord Jose 9885)");
			return 1;
		}
		PlayerInfo[targetid][pDiscordName] = name;
		PlayerInfo[targetid][pDiscordTag] = id;
		PlayerInfo[targetid][pVoiceChat] = 1;
		SM(targetid, COLOR_GREY2, "** You set your discord tag in-game to %s#%s. Type /vc to join voice chat.", name, id);
		mysql_format(connectionID, queryBuffer, sizeof(queryBuffer), "UPDATE users SET voicechat = 1, discordname = '%s', discordtag = '%s' WHERE uid = %i", name, id, PlayerInfo[targetid][pID]);
		mysql_tquery(connectionID, queryBuffer);
		return 1;
	}

	CMD:vc(playerid, params[]) {
		new option[24];
		if(PlayerInfo[playerid][pVoiceChat] == 0) {
			return SCM(playerid,COLOR_GREY2,"You need to set your discord first. Ask administrators.");
		}
		if(sscanf(params, "s[24]", option))
		{
			SCM(playerid, COLOR_GREY2, "Usage: /vc [channel]");
			SCM(playerid, COLOR_GREY2, "Channel: waiting, rp1, rp2, rp3, rp4, rp5");
			SCM(playerid, COLOR_GREY2, "Robbery: rob1, rob2");
			switch(FactionInfo[PlayerInfo[playerid][pFaction]][fType])
			{
				case FACTION_POLICE, FACTION_FEDERAL:
				{
					SCM(playerid, COLOR_GREY2, "Radio: pnp, dep");
				}
				case FACTION_MEDIC:
				{
					SCM(playerid, COLOR_GREY2, "Radio: doh, dep");
				}
				case FACTION_GOVERNMENT:
				{
					SCM(playerid, COLOR_GREY2, "Radio: gov, dep");
				}
			}

			UpdateDynamic3DTextLabelText(PlayerLabel[playerid], COLOR_REALRED, "");
			DCC_SetGuildMemberVoiceChannel(DCC_FindGuildById(GUILDSVR), DCC_FindUserByName(PlayerInfo[playerid][pDiscordName], PlayerInfo[playerid][pDiscordTag]), DCC_FindChannelById(VCLOBBY)); // waiting
			return 1;
		}
		if(!strcmp(option, "waiting", true)) {
			UpdateDynamic3DTextLabelText(PlayerLabel[playerid], COLOR_REALRED, "");
			DCC_SetGuildMemberVoiceChannel(DCC_FindGuildById(GUILDSVR), DCC_FindUserByName(PlayerInfo[playerid][pDiscordName], PlayerInfo[playerid][pDiscordTag]), DCC_FindChannelById(VCLOBBY)); // waiting
		}
		else if(!strcmp(option, "rp1", true)) {
			UpdateDynamic3DTextLabelText(PlayerLabel[playerid], COLOR_REALRED, "(( Connected to RP1 ))");
			DCC_SetGuildMemberVoiceChannel(DCC_FindGuildById(GUILDSVR), DCC_FindUserByName(PlayerInfo[playerid][pDiscordName], PlayerInfo[playerid][pDiscordTag]), DCC_FindChannelById(VCRP1));
		}
		else if(!strcmp(option, "rp2", true)) {
			UpdateDynamic3DTextLabelText(PlayerLabel[playerid], COLOR_REALRED, "(( Connected to RP2 ))");
			DCC_SetGuildMemberVoiceChannel(DCC_FindGuildById(GUILDSVR), DCC_FindUserByName(PlayerInfo[playerid][pDiscordName], PlayerInfo[playerid][pDiscordTag]), DCC_FindChannelById(VCRP2));
		}
		else if(!strcmp(option, "rp3", true)) {
			UpdateDynamic3DTextLabelText(PlayerLabel[playerid], COLOR_REALRED, "(( Connected to RP3 ))");
			DCC_SetGuildMemberVoiceChannel(DCC_FindGuildById(GUILDSVR), DCC_FindUserByName(PlayerInfo[playerid][pDiscordName], PlayerInfo[playerid][pDiscordTag]), DCC_FindChannelById(VCRP3));
		}
		else if(!strcmp(option, "rp4", true)) {
			UpdateDynamic3DTextLabelText(PlayerLabel[playerid], COLOR_REALRED, "(( Connected to RP4 ))");
			DCC_SetGuildMemberVoiceChannel(DCC_FindGuildById(GUILDSVR), DCC_FindUserByName(PlayerInfo[playerid][pDiscordName], PlayerInfo[playerid][pDiscordTag]), DCC_FindChannelById(VCRP4));
		}
		else if(!strcmp(option, "rp5", true)) {
			UpdateDynamic3DTextLabelText(PlayerLabel[playerid], COLOR_REALRED, "(( Connected to RP5 ))");
			DCC_SetGuildMemberVoiceChannel(DCC_FindGuildById(GUILDSVR), DCC_FindUserByName(PlayerInfo[playerid][pDiscordName], PlayerInfo[playerid][pDiscordTag]), DCC_FindChannelById(VCRP5));
		}
		else if(!strcmp(option, "rob1", true)) {
			UpdateDynamic3DTextLabelText(PlayerLabel[playerid], COLOR_REALRED, "(( Connected to ROB1 ))");
			DCC_SetGuildMemberVoiceChannel(DCC_FindGuildById(GUILDSVR), DCC_FindUserByName(PlayerInfo[playerid][pDiscordName], PlayerInfo[playerid][pDiscordTag]), DCC_FindChannelById(VCROB1));
		}
		else if(!strcmp(option, "rob2", true)) {
			UpdateDynamic3DTextLabelText(PlayerLabel[playerid], COLOR_REALRED, "(( Connected to ROB2 ))");
			DCC_SetGuildMemberVoiceChannel(DCC_FindGuildById(GUILDSVR), DCC_FindUserByName(PlayerInfo[playerid][pDiscordName], PlayerInfo[playerid][pDiscordTag]), DCC_FindChannelById(VCROB2));
		}

		else if(!strcmp(option, "pnp", true)) {
			if(!IsLawEnforcement(playerid)) {
				SCM(playerid, COLOR_GREY2, "** You are not police enforcer to use this radio.");
			}
			UpdateDynamic3DTextLabelText(PlayerLabel[playerid], COLOR_REALRED, "(( Connected to PNP ))");
			DCC_SetGuildMemberVoiceChannel(DCC_FindGuildById(GUILDSVR), DCC_FindUserByName(PlayerInfo[playerid][pDiscordName], PlayerInfo[playerid][pDiscordTag]), DCC_FindChannelById(VCPNP));
		}
		else if(!strcmp(option, "doh", true)) {
			if(GetFactionType(playerid) != FACTION_MEDIC)
			{
				return SCM(playerid, COLOR_GREY2, "You can't use this radio as you aren't a part of medic.");
			}
			UpdateDynamic3DTextLabelText(PlayerLabel[playerid], COLOR_REALRED, "(( Connected to DOH ))");
			DCC_SetGuildMemberVoiceChannel(DCC_FindGuildById(GUILDSVR), DCC_FindUserByName(PlayerInfo[playerid][pDiscordName], PlayerInfo[playerid][pDiscordTag]), DCC_FindChannelById(VCDOH));
		}
		else if(!strcmp(option, "gov", true)) {
			if(GetFactionType(playerid) != FACTION_GOVERNMENT)
			{
				return SCM(playerid, COLOR_GREY2, "You can't use this radio as you aren't a part of government.");
			}
			UpdateDynamic3DTextLabelText(PlayerLabel[playerid], COLOR_REALRED, "(( Connected to GOV ))");
			DCC_SetGuildMemberVoiceChannel(DCC_FindGuildById(GUILDSVR), DCC_FindUserByName(PlayerInfo[playerid][pDiscordName], PlayerInfo[playerid][pDiscordTag]), DCC_FindChannelById(VCGOV));
		}
		else if(!strcmp(option, "dep", true)) {
			if(PlayerInfo[playerid][pFaction] == -1)
			{
				return SCM(playerid, COLOR_GREY2, "You are not a part of any faction to use this radio.");
			}
			UpdateDynamic3DTextLabelText(PlayerLabel[playerid], COLOR_REALRED, "(( Connected to DEP ))");
			DCC_SetGuildMemberVoiceChannel(DCC_FindGuildById(GUILDSVR), DCC_FindUserByName(PlayerInfo[playerid][pDiscordName], PlayerInfo[playerid][pDiscordTag]), DCC_FindChannelById(VCDEP));
		}
		return 1;
	}

DISCORD:dsetdiscord(DCC_Channel: channel, DCC_User: author, params[])
	{
		new username[MAX_PLAYER_NAME], discord[16],tag[8];
		if(channel != DCC_FindChannelById(TADMIN))
			return 1;

		if(sscanf(params, "s[24]s[16]s[8]", username,discord,tag))
		{
			return DCC_SendChannelMessage(channel, "Usage: /dsetdiscord [username] [discord] [tag]");
		}

		mysql_format(connectionID, queryBuffer, sizeof(queryBuffer), "SELECT voicechat FROM users WHERE username = '%e'", username);
		mysql_tquery(connectionID, queryBuffer, "DiscordSet", "sss", username, discord, tag);
		return 1;
	}

	DISCORD:dwhitelist(DCC_Channel: channel, DCC_User: author, params[])
	{
		new username[MAX_PLAYER_NAME];
		if(channel != DCC_FindChannelById(TADMIN))
			return 1;

		if(sscanf(params, "s[24]", username))
		{
			return DCC_SendChannelMessage(channel, "Usage: /dwhitelist [username]");
		}

		mysql_format(connectionID, queryBuffer, sizeof(queryBuffer), "SELECT locked FROM users WHERE username = '%e'", username);
		mysql_tquery(connectionID, queryBuffer, "DOnAdminLockAccount", "s", username);
		return 1;

	}

	DISCORD:nowhitelisted(DCC_Channel: channel, DCC_User: author, params[])
	{
		DCC_SendChannelMessage(channel, "No whitelisted!");
		return 1;
	}

	DISCORD:dip(DCC_Channel: channel, DCC_User: author, params[])
	{
		DCC_SendChannelMessage(channel, "Whitelisted!, IP-SERVER:7777!");
		return 1;
	}

	DISCORD:dooc(DCC_Channel: channel, DCC_User: author, params[])
	{
		if(channel != DCC_FindChannelById(TADMIN))
			return 1;

		if(isnull(params))
		{
			return DCC_SendChannelMessage(channel, "Usage: /dooc [text]");
		}

		SMA(COLOR_WHITE, "(( Discord "SERVER_BOT": %s ))", params);

		new string[128];
		format(string, sizeof(string), "(( Discord "SERVER_BOT": %s ))", params);
		DCC_SendChannelMessage(channel, string);
		return 1;
	}
#endif
