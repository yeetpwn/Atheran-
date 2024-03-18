#include <a_samp>

#include <YSI\y_ini>




// ============== DEFNINES OF SERVER INFO AND SHORTCUTS ====================== // 
#define SCRIPT_VERSION     					"beta 0.0.1"
#define MODE_BUILD							"beta 10"
#define CLIENT_LANGUAGE						"Atheran"
#define SERVER_WEB                  		"www.atheran-gaming.com"

#define H_TITTLE 							"{4282C0}(A): {FFFFFF}www.atheran-gaming.com"
#define START_DATE 							"{FFFFFF}START DATE {4282C0}| 18.03.2024:"
#define LAST_UPDATE							"{FFFFFF}UPDATE {4282C0}| :00.00.0000."





#define Players_File    "Players/%s.ini"

main() {

	printf("Successfully loaded");

	return 1;
}



#define 	dialog_Register 1
#define 	dialog_Login 2


enum IgracData {

	pPassword,
	pScore,
	pMoney,
	pAdmin,
	pSkin
}
new PlayerInfo[MAX_PLAYERS][IgracData];

forward LoadPlayers(playerid, name[], value[]);
public LoadPlayers( playerid, name[ ], value[ ] ) {

	INI_Int("Password", PlayerInfo[playerid][pPassword]);
	INI_Int("Score", PlayerInfo[playerid][pScore]);
	INI_Int("Money", PlayerInfo[playerid][pMoney]);
	INI_Int("Admin", PlayerInfo[playerid][pAdmin]);
	INI_Int("Skin", PlayerInfo[playerid][pSkin]);

	return 1;
}

udb_hash(buf[]) {
    new length=strlen(buf);
    new s1 = 1;
    new s2 = 0;
    new n;
    for (n=0; n<length; n++)
    {
       s1 = (s1 + buf[n]) % 65521;
       s2 = (s2 + s1)     % 65521;
    }
    return (s2 << 16) + s1;
}

SavePlayer( playerid ) {

	printf("called SavePlayer");

	new INI:File = INI_Open( Players( playerid ) );

	printf("Poceo sa pisanjem");
	INI_SetTag( File, "Informacije" );
	
	INI_WriteInt(File, "Password", PlayerInfo[playerid][pPassword]);
	INI_WriteInt(File, "Score", PlayerInfo[playerid][pScore]);
	INI_WriteInt(File, "Money", PlayerInfo[playerid][pMoney]);
	INI_WriteInt(File, "Admin", PlayerInfo[playerid][pAdmin]);
	INI_WriteInt(File, "Skin", PlayerInfo[playerid][pSkin]);


	printf("Ended");

	INI_Close(File);
	printf("File of Players have been closed");
}

public OnGameModeInit() {

	SetGameModeText(SCRIPT_VERSION" - "MODE_BUILD"");

	return 1;

}

public OnPlayerSpawn(playerid) {

	GivePlayerMoney(playerid, PlayerInfo[playerid][pMoney]);
	SetPlayerScore(playerid, PlayerInfo[playerid][pScore]);

	return 1;
}

SpawnujIgraca(playerid) {

	SetSpawnInfo(playerid, 0, PlayerInfo[playerid][pSkin], -480.4618,-485.2159,25.6220,179.3383, 0, 0, 0, 0, 0, 0);
	SpawnPlayer(playerid);
}

stock Players( playerid ) {
    new string[ 128 ];
    format( string, sizeof( string ), Players_File, ImeIgraca( playerid ) );
    return string;
}

stock ImeIgraca( id ) {
	new ime[ MAX_PLAYER_NAME ];
 	GetPlayerName( id, ime, sizeof ime);
	return ime;
}

public OnPlayerConnect(playerid) {

	if(fexist(Players(playerid))) {

		INI_ParseFile( Players( playerid ), "LoadPlayers", .bExtra = true, .extra = playerid);

		ShowPlayerDialog(playerid, dialog_Login, DIALOG_STYLE_PASSWORD, "Password", "Unesite vasu lozinku", "Potvrdi", "Odustani");

		return 1;
	}
	else {

		ShowPlayerDialog(playerid, dialog_Register, DIALOG_STYLE_PASSWORD, "Register", "Unesite vasu lozinku", "Potvrdi", "Odustani");

		return 1;
	}
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {

	if(dialogid == dialog_Login) {

		if(!response) return Kick(playerid);
		if(response) {

			if(udb_hash(inputtext) == PlayerInfo[playerid][pPassword]) {

				SpawnujIgraca(playerid);

				SendClientMessage(playerid, -1, "Login gotov");
				return 1;
			}
			else return Kick(playerid);
		}
		return 1;
	}

	if(dialogid == dialog_Register) {

		if(!response) return Kick(playerid);
		if(response) {

			PlayerInfo[playerid][pPassword] = udb_hash(inputtext);
			PlayerInfo[playerid][pMoney] = 20000;
			PlayerInfo[playerid][pScore] = 1;
			PlayerInfo[playerid][pAdmin] = 0;
			PlayerInfo[playerid][pSkin] = 33;

			SavePlayer(playerid);

			SpawnujIgraca(playerid);

			SendClientMessage(playerid, -1, "Register gotov!");

			return 1;
		}

		return 1;
	}

	return 1;
}