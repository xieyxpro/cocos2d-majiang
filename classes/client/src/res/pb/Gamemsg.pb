
ê/
Gamemsg.protoGamemsg"ó
Location_latLng
jingdu (:1000
weidu (:1000
permissiondenied (
userid (
city (	
district (	
address (	"©
Logon_MC_LogonByUserID
userid (
password (	B
pwdtype (2).Gamemsg.Logon_MC_LogonByUserID.enPwdType:NORMAL")
	enPwdType

NORMAL
WECHAT_TOKEN"5
Logon_MS_LogonRes
err (
tableid (:-1"S
User_MS_WealthChange
roomcardchangenum (
typecode (
params (	"\
User_MS_StatusChange
userid (

userstatus (
tableid (
chairid ("

Err_MS_Err
err ("

ms_standup
userid ("

mc_dismiss
agree ("R
ms_dismiss_confirm
calleruserid (
agreeuserids (
lefttime (")
ms_dismiss_fail
notagreeuserid (";

mc_ms_talk
userid (
talkurl (	
time ("}
	room_info
roomID (
roomCreaterUserID (
rolls (
people (
createParams (	
rollsCnt ("E
mc_create_room
createParams (	
rolls (
people ("
ms_create_room
err ("
mc_join_room
roomID ("
ms_join_room
err ("4
ms_room_info$
roomInfo (2.Gamemsg.room_info"
mc_leave_room"
ms_leave_room
userid ("€
room_player_info
userid (
nickname (	

playerIcon (	
playerIP (	
playerScore (
chairID (
status (*
location (2.Gamemsg.Location_latLng
gender	 (
score
 ("B
ms_room_players_info*
players (2.Gamemsg.room_player_info"@
ms_room_player_join)
player (2.Gamemsg.room_player_info"
ms_game_scene_free"C
	ming_card
cardVal (
mingType (
subMingType ("—
roll_player_data
userid (
	handCards (%
	mingCards (2.Gamemsg.ming_card
uselessCards (
huType (
isInTingMode (
handCardsNum (
score (

isDelegate	 (",
out_card
chairID (
cardVal ("∫
ms_game_scene_play
zhuangID (
cardsRemainCnt (
whosTurnChairID (*
players (2.Gamemsg.roll_player_data$
	watchCard (2.Gamemsg.out_card
actions (
laiZiCardVal (
laiZiPiCardVal	 (

shaiZi1Val
 (

shaiZi2Val (
baoZiVal (
actionWaitTime ("ã
ms_game_start
zhuangID (
cardsRemainCnt (*
players (2.Gamemsg.roll_player_data$
	watchCard (2.Gamemsg.out_card
laiZiCardVal (
laiZiPiCardVal	 (

shaiZi1Val
 (

shaiZi2Val (
baoZiVal (
actionWaitTime ("–
balance_player
userid (
	handCards (%
	mingCards (2.Gamemsg.ming_card
huType (
	huCardVal (
fans (
score	 (

scoreTypes
 (
baoHu (
	isSponsor ("ë
ms_game_over
err (
result ((
players (2.Gamemsg.balance_player6
statPlayers (2!.Gamemsg.ms_game_over.stat_player+
stat
statType (
	statValue (H
stat_player
userid ()
stats (2.Gamemsg.ms_game_over.stat
	statistic""
ms_player_online
userid ("#
ms_player_offline
userid ("
mc_player_ready"!
ms_player_ready
userid ("Ñ
ms_system_dispatch_card
whosTurnChairID (
cardVal (
actions (
cardsRemainCnt (
actionWaitTime ("o
ms_haidilao/
cards (2 .Gamemsg.ms_haidilao.player_card/
player_card
chairID (
cardVal ("
mc_out_card
cardVal (";
ms_out_card
err (
userid (
cardVal ("
mc_action_guo",
ms_action_guo
err (
userid ("!
mc_action_peng
cardVal ("U
ms_action_peng
err (
userid (
cardVal (
sponsorUserID ("
mc_action_hu"S
ms_action_hu
err (
userid (
huType (
sponsorChairID ("H
mc_action_gang
cardVal (
mingType (
subMingType ("|
ms_action_gang
err (
userid (
cardVal (
mingType (
subMingType (
sponsorUserID ("1
mc_action_chi
cardVal (
chiType ("e
ms_action_chi
err (
userid (
cardVal (
chiType (
sponsorUserID ("
mc_player_ting" 
ms_player_ting
userid ("Ö
record_room
roomID (
people (
roomCreaterUserID (
	startTime (4
playersInfo (2.Gamemsg.record_room.playerInfor

playerInfo
userid (
nickname (	

playerIcon (	
gender (
chairID (
score ("‚
record_base
result (
	startTime (-

statistics (2.Gamemsg.record_base.stat'
winner (2.Gamemsg.balance_player0
rollInfo (2.Gamemsg.record_base.roll_info
loserUserID (
sponsorUserID (%
stat
userid (
score (S
	roll_info
laiZiCardVal (
laiZiPiCardVal (
hongZhongCardVal ("¬
record_detail
zhuangChairID (
laiZiCardVal (
laiZiPiCardVal (.
players (2.Gamemsg.record_detail.player3

actionsQue (2.Gamemsg.record_detail.play_act

shaiZi1Val (

shaiZi2Val (<
player
userid (
chairID (
	handCards (†
play_act
chairID (
act (6
data (2(.Gamemsg.record_detail.play_act.act_dataΩ
act_data
cardVal (
mingType (
subMingType (
whosTurnChairID (
actions (
chiType (
cardsRemainCnt (
huType (
actionWaitTime	 ("
mc_game_record"º
ms_game_record0

statistics (2.Gamemsg.ms_game_record.stat*
	roll_stat
rollNO (
score (L
stat
userid (4
	rollStats (2!.Gamemsg.ms_game_record.roll_stat"”
ms_prev_dismiss
err (9
statPlayers (2$.Gamemsg.ms_prev_dismiss.stat_player+
stat
statType (
	statValue (K
stat_player
userid (,
stats (2.Gamemsg.ms_prev_dismiss.stat"$
mc_game_delegate
delegate ("A
ms_game_delegate
err (
delegate (
userid ("'
mc_chat
typ (
content (	"D
ms_chat
err (
userid (
typ (
content (	