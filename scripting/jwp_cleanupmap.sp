#include <sourcemod>
#include <sdktools>
//#include <csgo_colors>
#include <jwp>

#define DEBUG 0
#define FUNC "cleanupmap"

ConVar 	g_hCounter;
Handle 	hCleanUpMap;
int 	g_iMaxResetCount = -1,
		g_iCurrentResetCount = 0;

public Plugin myinfo =
{
	name = "[JWP] Clean Up Map",
	author = "FIVE",
	version = "1.0.0",
	url = "http://hlmod.ru"
};

public void OnPluginStart()
{
	GameData hGameData = LoadGameConfigFile("CleanUpMap");

	if (!hGameData)
	{
		SetFailState("Failed to load CleanUpMap gamedata.");
		
		return;
	}

	StartPrepSDKCall(SDKCall_GameRules);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CCSGameRules::CleanUpMap");

	hGameData.Close();

	if (!(hCleanUpMap = EndPrepSDKCall()))
	{
		SetFailState("Failed to setup CCSGameRules::CleanUpMap");

		return;
	}

	LoadTranslations("jwp_cleanupmap.phrases");
	HookEvent("round_start", Event_OnRoundStart, EventHookMode_PostNoCopy);

	g_hCounter = CreateConVar("jwp_cleanupmap_count", "-1", "Кол-во перезапусков карты", _);
	g_hCounter.AddChangeHook(OnCvarChange);
	g_iMaxResetCount = g_hCounter.IntValue;

	RegAdminCmd("sm_cleanupmap", cmd_cum, ADMFLAG_ROOT);

	if(JWP_IsStarted()) JWP_Started();
}

public void OnCvarChange(ConVar cvar, const char[] oldValue, const char[] newValue)
{
	g_iMaxResetCount = g_hCounter.IntValue;
}

public void OnPluginEnd()
{
	JWP_RemoveFromMainMenu();
}

public void JWP_Started()
{
	JWP_AddToMainMenu(FUNC, DisplayCallBack, SelectCallBack);
}

public void Event_OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	g_iCurrentResetCount = 0;
}

public bool DisplayCallBack(int iClient, char[] buffer, int maxlength, int style)
{
	GetTitle(buffer, maxlength);
	style = (g_iCurrentResetCount <= g_iMaxResetCount) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED;

	return true;
}

public bool SelectCallBack(int iClient)
{
	SetGlobalTransTarget(iClient);
	if(g_iMaxResetCount == -1 || g_iCurrentResetCount < g_iMaxResetCount)
	{
		ClearUpMap();
		JWP_ActionMsgAll("%t", "CHAT_MSG", iClient);
		g_iCurrentResetCount++;

		char sBuffer[64];
		FormatEx(sBuffer, sizeof(sBuffer), "%t [%i/%i]", "MENU_TITLE", g_iCurrentResetCount, g_iMaxResetCount);
		JWP_RefreshMenuItem(FUNC, sBuffer, (g_iCurrentResetCount <= g_iMaxResetCount) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	}
	else JWP_ActionMsg(iClient, "%t", "CHAT_MSG_FAILED", g_iCurrentResetCount, g_iMaxResetCount);

	JWP_ShowMainMenu(iClient);
	
	return true;
}

void GetTitle(char[] sBuffer, int iMaxLen)
{
	if(g_iMaxResetCount != -1)
	{
		PrintToChatAll("GG");
		FormatEx(sBuffer, iMaxLen, "%t [%i/%i]", "MENU_TITLE", g_iCurrentResetCount, g_iMaxResetCount);
	}
	else FormatEx(sBuffer, iMaxLen, "%t", "MENU_TITLE");
}

Action cmd_cum(int iClient, int iArgs)
{
	ClearUpMap();

	return Plugin_Handled;
}

void ClearUpMap()
{
	#if DEBUG == 1
	PrintToServer("CALL FUNCTION START");
	#endif

	SDKCall(hCleanUpMap);

	#if DEBUG == 1
	PrintToServer("CALL FUNCTION END");
	#endif
}