#include <sourcemod>
#include <sdktools>
//#include <csgo_colors>
#include <jwp>

#define DEBUG 0
#define FUNC "cleanupmap"

Handle hCleanUpMap;

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

	RegAdminCmd("sm_cleanupmap", cmd_cum, ADMFLAG_ROOT);

	if(JWP_IsStarted()) JWP_Started();
}

public void OnPluginEnd()
{
	JWP_RemoveFromMainMenu();
}

public void JWP_Started()
{
	JWP_AddToMainMenu(FUNC, DisplayCallBack, SelectCallBack);
}

bool DisplayCallBack(int iClient, char[] buffer, int maxlength, int style)
{
	SetGlobalTransTarget(iClient);
	FormatEx(buffer, maxlength, "%t", "MENU_TITLE");
	style = ITEMDRAW_DEFAULT;
	return true;
}

bool SelectCallBack(int iClient)
{
	ClearUpMap();
	JWP_ActionMsgAll("%t", "CHAT_MSG", iClient);
	return true;
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