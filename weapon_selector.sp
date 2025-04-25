#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <clientprefs>

#define DEBUG

char currentv[32] = "2.0.1";
#if defined DEBUG
	//currentv = StrCat(currentv, sizeof(currentv), "_DEBUG");
#endif

public Plugin myinfo = 
{ 
	name = "Weapon Selector", 
	author = "StShAzzy",
	description = "Allows players to set a preference for weapons after CS:GO inventory services got shut down.", 
	version = currentv,
	url = "https://www.github.com/StShAzzy"
};


bool g_bPrefersR8[MAXPLAYERS + 1] = {false};
bool g_bPrefersUSP[MAXPLAYERS + 1] = {false};
bool g_bPrefersCZ[MAXPLAYERS + 1] = {false};
bool g_bPrefersM4A1S[MAXPLAYERS + 1] = {false};
int g_iPlayerNotified[MAXPLAYERS + 1] = {0};
bool g_bReplaceWep[MAXPLAYERS + 1] = {false};
Handle Weapons_cookie;
int r8Price = 600;
int deaglePrice = 700;
int p2000UspPrice = 200;
int czTecPrice = 500;
int m4a1sPrice = 2900;
int m4a4Price = 3100;

public void OnPluginStart()
{
	RegConsoleCmd("sm_deagle", Command_Deagle);
	RegConsoleCmd("sm_r8", Command_Revolver);
	RegConsoleCmd("sm_revolver", Command_Revolver);

	RegConsoleCmd("sm_usp", Command_USP);
	RegConsoleCmd("sm_p2000", Command_P2000);
	RegConsoleCmd("sm_p2k", Command_P2000);

	RegConsoleCmd("sm_cz", Command_CZ);
	RegConsoleCmd("sm_tec", Command_NotCZ);
	RegConsoleCmd("sm_tec9", Command_NotCZ);
	RegConsoleCmd("sm_fiveseven", Command_NotCZ);
	RegConsoleCmd("sm_57", Command_NotCZ);

	RegConsoleCmd("sm_m4a1s", Command_M4A1S);
	RegConsoleCmd("sm_m4a4", Command_M4A4);
	
	RegConsoleCmd("sm_weaponmenu", Command_CreateMenu);

	HookEvent("player_spawn", Player_Spawn);
}

Action Command_CreateMenu(int client, int args)
{
	Menu menu = new Menu(MenuHandling);
	menu.SetTitle("Preferência de Armas");
	menu.AddItem("deagle", "Deagle");
	menu.AddItem("r8", "R8");
	menu.AddItem("p2000", "P2000");
	menu.AddItem("usp", "USP");
	menu.AddItem("cz", "CZ-75");
	menu.AddItem("tec9", "TEC-9");
	menu.AddItem("fiveseven", "FiveSeven");
	menu.AddItem("m4a4", "M4A4");
	menu.AddItem("m4a1s", "M4A1-S");
	
	menu.Display(client, MENU_TIME_FOREVER);
	
	return Plugin_Handled;
}

public int MenuHandling(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char info[32];
			menu.GetItem(param2, info, sizeof(info));
			if(StrEqual(info, "deagle"))
			{
				Command_Handler("deagle", param1, 0);
			}
			if(StrEqual(info, "r8"))
			{
				Command_Handler("r8", param1, 0);
			}
			if(StrEqual(info, "p2000"))
			{
				Command_Handler("p2000", param1, 0);
			}
			if(StrEqual(info, "usp"))
			{
				Command_Handler("usp", param1, 0);
			}
			if(StrEqual(info, "cz"))
			{
				Command_Handler("cz", param1, 0);
			}
			if(StrEqual(info, "tec9"))
			{
				Command_Handler("tec9", param1, 0);
			}
			if(StrEqual(info, "fiveseven"))
			{
				Command_Handler("tec9", param1, 0);
			}
			if(StrEqual(info, "m4a4"))
			{
				Command_Handler("m4a4", param1, 0);
			}
			if(StrEqual(info, "m4a1s"))
			{
				Command_Handler("m4a1s", param1, 0);
			}
		}
		case MenuAction_End:
		delete menu;
	}
	return -1;
}

public void OnClientConnected(int client)
{
	ResetUserPreference(client);
}

public void OnClientDisconnect(int client)
{
	ResetUserPreference(client);
}

void Player_Spawn(Event event, const char[] name, bool dB)
{
	CreateTimer(0.1, HandleSpawn, event.GetInt("userid"));
}

public Action HandleSpawn(Handle timer, any userId)
{
	int client = GetClientOfUserId(view_as<int>(userId));
	if (!client) {
		return Plugin_Stop;}

	if (GetClientTeam(client) <= CS_TEAM_SPECTATOR)
		return Plugin_Stop;

	if (g_iPlayerNotified[client] <= 0)
	{
		PrintToChat(client, "Use \x04!weaponmenu\x01 at any time to set your preference.");

		if (g_bPrefersR8[client])
			PrintToChat(client, "Current preference: \x04R8 Revolver");
		else
			PrintToChat(client, "Current preference: \x04Desert Eagle");

		if (g_bPrefersUSP[client])
			PrintToChat(client, "Current preference: \x04USP-S");
		else
			PrintToChat(client, "Current preference: \x04P2000");

		if (g_bPrefersCZ[client])
			PrintToChat(client, "Current preference: \x04CZ75-Auto");
		else
			PrintToChat(client, "Current preference: \x04Tec-9/Five-Seven");

		if (g_bPrefersM4A1S[client])
			PrintToChat(client, "Current preference: \x04M4A1-S");
		else
			PrintToChat(client, "Current preference: \x04M4A4");

		g_iPlayerNotified[client]++;
	}
	int clientTeam = GetClientTeam(client);
	char clientWeapon[32]
	GetClientWeapon(client, clientWeapon, sizeof(clientWeapon));
	if(g_bPrefersUSP[client] && clientTeam == CS_TEAM_CT && StrEqual("weapon_hkp2000", clientWeapon, false))
	{
		#if defined DEBUG
			PrintToConsoleAll("Attempted to Give USP-S to %d", client);
		#endif
		DropSecondary(client);
		GivePlayerItem(client, "weapon_usp_silencer");
	}

	return Plugin_Stop;
}

public Action Command_Deagle(int client, int args)
{
	return Command_Handler("deagle", client, args);
}

public Action Command_Revolver(int client, int args)
{
	return Command_Handler("r8", client, args);
}

public Action Command_USP(int client, int args)
{
	return Command_Handler("usp", client, args);
}

public Action Command_P2000(int client, int args)
{
	return Command_Handler("p2000", client, args);
}

public Action Command_CZ(int client, int args)
{
	return Command_Handler("cz", client, args);
}

public Action Command_NotCZ(int client, int args)
{
	return Command_Handler("tec9", client, args);
}

public Action Command_M4A1S(int client, int args)
{
	return Command_Handler("m4a1s", client, args);
}

public Action Command_M4A4(int client, int args)
{
	return Command_Handler("m4a4", client, args);
}

public Action Command_Handler(const char[] command, int client, int args)
{
	if (args > 1)
	{
		char com[128] = "Usage: !";
		StrCat(com, sizeof(com), command);
		
		ReplyToCommand(client, com);
		return Plugin_Handled;
	}
	
	char weapon[32] = "";

	if (StrEqual(command, "deagle"))
	{
		g_bPrefersR8[client] = false;
		weapon = "Desert Eagle";
	}
	else if (StrEqual(command, "r8"))
	{
		g_bPrefersR8[client] = true;
		weapon = "R8 Revolver";
	}
	else if (StrEqual(command, "p2000"))
	{
		g_bPrefersUSP[client] = false;
		weapon = "P2000";
	}
	else if (StrEqual(command, "usp"))
	{
		g_bPrefersUSP[client] = true;
		weapon = "USP-S";
	}
	else if (StrEqual(command, "m4a1s"))
	{
		g_bPrefersM4A1S[client] = true;
		weapon = "M4A1-S";
	}
	else if (StrEqual(command, "m4a4"))
	{
		g_bPrefersM4A1S[client] = false;
		weapon = "M4A4";
	}
	else if (StrEqual(command, "cz"))
	{
		g_bPrefersCZ[client] = true;
		weapon = "CZ75-Auto";
	}
	else
	{
		g_bPrefersCZ[client] = false;
		weapon = "Tec-9/Five-Seven";
	}

	char com[128] = "Current preference: \x04";
	StrCat(com, sizeof(com), weapon);
	ReplyToCommand(client, com);

	return Plugin_Handled;
}

public Action CS_OnBuyCommand(int client, const char [] szWeapon)
{
	if(!IsClientInGame(client) || !IsPlayerAlive(client) || GetEntProp(client, Prop_Send, "m_bInBuyZone") == 0)
		return Plugin_Continue;
	
	if(GetClientTeam(client) <= CS_TEAM_SPECTATOR)
		return Plugin_Continue;
	
	char str[128] = "weapon_";
	StrCat(str, sizeof(str), szWeapon);

	if (StrEqual(str, "weapon_deagle"))
		return HandleBuyEvent(client, "weapon_revolver", r8Price, g_bPrefersR8[client]);
	else if (StrEqual(str, "weapon_revolver"))
		return HandleBuyEvent(client, "weapon_deagle", deaglePrice, !g_bPrefersR8[client]);
	else if (StrEqual(str, "weapon_hkp2000"))
		return HandleBuyEvent(client, "weapon_usp_silencer", p2000UspPrice, g_bPrefersUSP[client]);
	else if (StrEqual(str, "weapon_usp_silencer"))
		return HandleBuyEvent(client, "weapon_hkp2000", p2000UspPrice, !g_bPrefersUSP[client]);
	else if (StrEqual(str, "weapon_m4a1")){
		#if defined DEBUG
		PrintToConsoleAll("Attempted to give M4A1-S to %d", client);
		#endif
		return HandleBuyEvent(client, "weapon_m4a1_silencer", m4a1sPrice, g_bPrefersM4A1S[client]);}
	else if (StrEqual(str, "weapon_m4a1_silencer")){
		#if defined DEBUG
		PrintToConsoleAll("Attempted to give M4A4 to %d", client);
		#endif
		return HandleBuyEvent(client, "weapon_m4a1", m4a4Price, !g_bPrefersM4A1S[client]);}
	else if (StrEqual(str, "weapon_tec9") || StrEqual(str, "weapon_fiveseven"))
		return HandleBuyEvent(client, "weapon_cz75a", czTecPrice, g_bPrefersCZ[client]);
	else if (StrEqual(str, "weapon_cz75a"))
	{
		if (GetClientTeam(client) != CS_TEAM_T)
			return HandleBuyEvent(client, "weapon_tec9", czTecPrice, !g_bPrefersCZ[client]);
		else
			return HandleBuyEvent(client, "weapon_fiveseven", czTecPrice, !g_bPrefersCZ[client]);
	}
	else
		return Plugin_Continue;
}

public Action CS_OnGetWeaponPrice(int client, const char[] weapon, int& price)
{
	// only deagle and r8 differ in price
	if (StrEqual(weapon, "weapon_deagle") || StrEqual(weapon, "weapon_revolver"))
	{
		price = g_bPrefersR8[client] ? r8Price : deaglePrice;
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

public Action HandleBuyEvent(int client, char weapon_replace[32], int price_replace, bool prefers)
{
	#if defined DEBUG
		PrintToConsoleAll("[DEBUG]: client=%d weapon_replace=%s prefers=%b",client, weapon_replace, prefers);
	#endif
	if (!prefers)
		return Plugin_Continue;

	// can we afford the weapon?
	int money = GetClientMoney(client);
	if (money < price_replace){
		return Plugin_Handled;}
	
	if(StrEqual(weapon_replace, "weapon_m4a1", false) || StrEqual(weapon_replace, "weapon_m4a1_silencer", false))
	{
		if (HasPlayerWeapon(client, weapon_replace))
			return Plugin_Handled;
		else
		{
			DropPrimary(client);
			SetClientMoney(client, money - price_replace);
			GivePlayerItem(client, weapon_replace);

			return Plugin_Handled;
		}		
	}
	else
	{
		if (HasPlayerWeapon(client, weapon_replace))
			return Plugin_Handled;
		else
		{
			DropSecondary(client);
			SetClientMoney(client, money - price_replace);
			GivePlayerItem(client, weapon_replace);

			return Plugin_Handled;
		}		
	}
}

public bool HasPlayerWeapon(int client, const char[] weapon)
{
	int m_hMyWeapons = FindSendPropInfo("CBasePlayer", "m_hMyWeapons");
	if(m_hMyWeapons == -1)
		return false;

	for(int offset = 0; offset < 128; offset += 4)
	{
		int weap = GetEntDataEnt2(client, m_hMyWeapons+offset);

		if(IsValidEdict(weap))
		{
			char classname[32];
			GetWeaponClassname(weap, -1, classname, 32);

			if(StrEqual(classname, weapon))
				return true;
		}
	}

	return false;
}

public void DropPrimary(int client)
{
	int slot1 = GetPlayerWeaponSlot(client, 0);

	if (slot1 != -1)
	{
		CS_DropWeapon(client, slot1, false);
	}
}

public void DropSecondary(int client)
{
	int slot2 = GetPlayerWeaponSlot(client, 1);

	if (slot2 != -1)
	{
		CS_DropWeapon(client, slot2, false);
	}
}

public int GetClientMoney(int client)
{
	return GetEntProp(client, Prop_Send, "m_iAccount");
}

public void SetClientMoney(int client, int money)
{
	SetEntProp(client, Prop_Send, "m_iAccount", money);
}

public void OnMapStart()
{
	for (int i = 1; i <= MaxClients; i++)
		ResetUserPreference(i);
}

void ResetUserPreference(int client)
{
	g_bPrefersR8[client] = false;
	g_bPrefersUSP[client] = false;
	g_bPrefersCZ[client] = false;
	g_bPrefersM4A1S[client] = false;
	g_iPlayerNotified[client] = false;	
}

stock void GetWeaponClassname(int weapon, int index = -1, char[] classname, int maxLen)
{
	GetEdictClassname(weapon, classname, maxLen);

	if(index == -1)
		index = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");

	switch(index)
	{
		case 60: strcopy(classname, maxLen, "weapon_m4a1_silencer");
		case 61: strcopy(classname, maxLen, "weapon_usp_silencer");
		case 63: strcopy(classname, maxLen, "weapon_cz75a");
		case 64: strcopy(classname, maxLen, "weapon_revolver");
	}
}