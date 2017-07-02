local msgdefines = {}

--添加消息定义
--define: {name = "", mainCmd = 0, subCmd = 0, proto = ""}
local function addMsgDefine(serverName, define)
    msgdefines[serverName] =  msgdefines[serverName] or {}
    msgdefines[serverName][define.mainCmd] = msgdefines[serverName][define.mainCmd] or {}
    assert(msgdefines[serverName][define.mainCmd][define.subCmd] == nil, "duplicate message command defined(mainCmd: %d, subCmd: %d, name = %s)", define.mainCmd, define.subCmd, define.name)
    msgdefines[serverName][define.mainCmd][define.subCmd] = define
    assert(msgdefines[serverName][define.name] == nil, "duplicate message name defined(mainCmd: %d, subCmd: %d, name = %s)", define.mainCmd, define.subCmd, define.name)
    msgdefines[serverName][define.name] = define
end 
--hall
addMsgDefine("home", {name = "ms_disconnect", mainCmd = 1, subCmd = 1, proto = ""})
addMsgDefine("home", {name = "ms_connect", mainCmd = 1, subCmd = 3, proto = ""})
addMsgDefine("home", {name = "Logon_MC_LogonOrRegByUserID", mainCmd = 10, subCmd = 102, proto = "Hallmsg.Logon_MC_LogonOrRegByUserID"})
addMsgDefine("home", {name = "Logon_MC_WechatLogon", mainCmd = 10, subCmd = 103, proto = "Hallmsg.Logon_MC_WechatLogon"})
addMsgDefine("home", {name = "Logon_MS_LogonRes", mainCmd = 10, subCmd = 1001, proto = "Hallmsg.Logon_MS_LogonRes"})
addMsgDefine("home", {name = "ms_room_servers", mainCmd = 10, subCmd = 1002, proto = "Hallmsg.ms_room_servers"})
addMsgDefine("home", {name = "ms_room_session", mainCmd = 10, subCmd = 1003, proto = "Hallmsg.ms_room_session"})
addMsgDefine("home", {name = "ms_logon_finish", mainCmd = 10, subCmd = 1010, proto = ""})

addMsgDefine("home", {name = "mc_roomnum_query", mainCmd = 11, subCmd = 1, proto = "Hallmsg.RoomNum_MC_Query"})
addMsgDefine("home", {name = "ms_roomnum_query_res", mainCmd = 11, subCmd = 101, proto = "Hallmsg.RoomNum_MS_QueryRes"})
addMsgDefine("home", {name = "ms_room_server_reg", mainCmd = 11, subCmd = 1001, proto = "Hallmsg.ms_room_servers"})
addMsgDefine("home", {name = "ms_room_server_unreg", mainCmd = 11, subCmd = 1002, proto = "Hallmsg.ms_room_unreg"})

addMsgDefine("home", {name = "ms_wealth_change", mainCmd = 12, subCmd = 1, proto = "Hallmsg.User_MS_WealthChange"})
--game
addMsgDefine("game", {name = "mc_create_room", mainCmd = 15, subCmd = 1, proto = "Gamemsg.mc_create_room"})
addMsgDefine("game", {name = "ms_create_room", mainCmd = 15, subCmd = 12, proto = "Gamemsg.ms_create_room"})
addMsgDefine("game", {name = "mc_join_room", mainCmd = 15, subCmd = 2, proto = "Gamemsg.mc_join_room"})
addMsgDefine("game", {name = "ms_join_room", mainCmd = 15, subCmd = 13, proto = "Gamemsg.ms_join_room"})
addMsgDefine("game", {name = "ms_room_info", mainCmd = 15, subCmd = 102, proto = "Gamemsg.ms_room_info"})
addMsgDefine("game", {name = "ms_wealth_change", mainCmd = 15, subCmd = 201, proto = "Gamemsg.User_MS_WealthChange"})
addMsgDefine("game", {name = "ms_userstatus_change", mainCmd = 15, subCmd = 202, proto = "Gamemsg.User_MS_StatusChange"})
addMsgDefine("game", {name = "mc_location", mainCmd = 15, subCmd = 3, proto = "Gamemsg.Location_latLng"})

addMsgDefine("game", {name = "ms_disconnect", mainCmd = 200, subCmd = 2, proto = ""})
addMsgDefine("game", {name = "ms_connect", mainCmd = 200, subCmd = 4, proto = ""})
addMsgDefine("game", {name = "Logon_MC_LogonByUserID", mainCmd = 10, subCmd = 101, proto = "Gamemsg.Logon_MC_LogonByUserID"})
addMsgDefine("game", {name = "Logon_MS_LogonRes", mainCmd = 10, subCmd = 1001, proto = "Gamemsg.Logon_MS_LogonRes"})
addMsgDefine("game", {name = "ms_room_logon_finish", mainCmd = 10, subCmd = 1010, proto = ""})

addMsgDefine("game", {name = "mc_gamescene_load_finish", mainCmd = 100, subCmd = 1, proto = ""})
addMsgDefine("game", {name = "mc_ms_talk", mainCmd = 100, subCmd = 11, proto = "Gamemsg.mc_ms_talk"})
addMsgDefine("game", {name = "ms_location", mainCmd = 100, subCmd = 105, proto = "Gamemsg.Location_latLng"})
addMsgDefine("game", {name = "ms_cheaters_confirm", mainCmd = 100, subCmd = 106, proto = ""})
addMsgDefine("game", {name = "ms_user_offline", mainCmd = 100, subCmd = 114, proto = "Gamemsg.ms_player_offline"}) --user offline
addMsgDefine("game", {name = "ms_user_reconnect", mainCmd = 100, subCmd = 115, proto = "Gamemsg.ms_player_online"}) --user reconnect
addMsgDefine("game", {name = "ms_sit_down", mainCmd = 100, subCmd = 111, proto = "Gamemsg.ms_room_player_join"}) --sit down
addMsgDefine("game", {name = "mc_player_ready", mainCmd = 100, subCmd = 2, proto = "Gamemsg.mc_player_ready"})
addMsgDefine("game", {name = "ms_player_ready", mainCmd = 100, subCmd = 112, proto = "Gamemsg.ms_player_ready"})
addMsgDefine("game", {name = "mc_stand_up", mainCmd = 100, subCmd = 3, proto = ""})
addMsgDefine("game", {name = "ms_stand_up", mainCmd = 100, subCmd = 113, proto = "Gamemsg.ms_standup"})
addMsgDefine("game", {name = "mc_dismiss", mainCmd = 100, subCmd = 4, proto = "Gamemsg.mc_dismiss"})
addMsgDefine("game", {name = "ms_dismiss", mainCmd = 100, subCmd = 101, proto = ""})
addMsgDefine("game", {name = "ms_dismiss_confirm", mainCmd = 100, subCmd = 102, proto = "Gamemsg.ms_dismiss_confirm"})
addMsgDefine("game", {name = "ms_dismiss_fail", mainCmd = 100, subCmd = 103, proto = "Gamemsg.ms_dismiss_fail"})


addMsgDefine("game", {name = "ms_game_start", mainCmd = 200, subCmd = 1001, proto = "Gamemsg.ms_game_start"})
addMsgDefine("game", {name = "ms_game_over", mainCmd = 200, subCmd = 1002, proto = "Gamemsg.ms_game_over"})
addMsgDefine("game", {name = "ms_system_dispatch_card", mainCmd = 200, subCmd = 1003, proto = "Gamemsg.ms_system_dispatch_card"})
addMsgDefine("game", {name = "ms_room_players_info", mainCmd = 200, subCmd = 1004, proto = "Gamemsg.ms_room_players_info"})
addMsgDefine("game", {name = "ms_game_scene_free", mainCmd = 200, subCmd = 1006, proto = "Gamemsg.ms_game_scene_free"})
addMsgDefine("game", {name = "ms_game_scene_play", mainCmd = 200, subCmd = 1007, proto = "Gamemsg.ms_game_scene_play"})
addMsgDefine("game", {name = "ms_prev_dismiss", mainCmd = 200, subCmd = 1012, proto = "Gamemsg.ms_prev_dismiss"})

addMsgDefine("game", {name = "ms_haidilao", mainCmd = 200, subCmd = 1011, proto = "Gamemsg.ms_haidilao"})

addMsgDefine("game", {name = "mc_out_card", mainCmd = 200, subCmd = 121, proto = "Gamemsg.mc_out_card"})
addMsgDefine("game", {name = "ms_out_card", mainCmd = 200, subCmd = 1211, proto = "Gamemsg.ms_out_card"})

addMsgDefine("game", {name = "mc_action_guo", mainCmd = 200, subCmd = 122, proto = "Gamemsg.mc_action_guo"})
addMsgDefine("game", {name = "ms_action_guo", mainCmd = 200, subCmd = 1221, proto = "Gamemsg.ms_action_guo"})

addMsgDefine("game", {name = "mc_action_peng", mainCmd = 200, subCmd = 123, proto = "Gamemsg.mc_action_peng"})
addMsgDefine("game", {name = "ms_action_peng", mainCmd = 200, subCmd = 1231, proto = "Gamemsg.ms_action_peng"})

addMsgDefine("game", {name = "mc_action_hu", mainCmd = 200, subCmd = 124, proto = "Gamemsg.mc_action_hu"})
addMsgDefine("game", {name = "ms_action_hu", mainCmd = 200, subCmd = 1241, proto = "Gamemsg.ms_action_hu"})

addMsgDefine("game", {name = "mc_action_gang", mainCmd = 200, subCmd = 125, proto = "Gamemsg.mc_action_gang"})
addMsgDefine("game", {name = "ms_action_gang", mainCmd = 200, subCmd = 1251, proto = "Gamemsg.ms_action_gang"})

addMsgDefine("game", {name = "mc_action_chi", mainCmd = 200, subCmd = 126, proto = "Gamemsg.mc_action_chi"})
addMsgDefine("game", {name = "ms_action_chi", mainCmd = 200, subCmd = 1261, proto = "Gamemsg.ms_action_chi"})

--addMsgDefine("game", {name = "mc_leave_room", mainCmd = 200, subCmd = 127, proto = "Gamemsg.mc_leave_room"})
--addMsgDefine("game", {name = "ms_leave_room", mainCmd = 200, subCmd = 1271, proto = "Gamemsg.ms_leave_room"})

addMsgDefine("game", {name = "mc_player_ting", mainCmd = 200, subCmd = 129, proto = "Gamemsg.mc_player_ting"})
addMsgDefine("game", {name = "ms_player_ting", mainCmd = 200, subCmd = 1291, proto = "Gamemsg.ms_player_ting"})

addMsgDefine("game", {name = "mc_game_record", mainCmd = 200, subCmd = 130, proto = "Gamemsg.mc_game_record"})
addMsgDefine("game", {name = "ms_game_record", mainCmd = 200, subCmd = 1301, proto = "Gamemsg.ms_game_record"})

addMsgDefine("game", {name = "mc_game_delegate", mainCmd = 200, subCmd = 131, proto = "Gamemsg.mc_game_delegate"})
addMsgDefine("game", {name = "ms_game_delegate", mainCmd = 200, subCmd = 1311, proto = "Gamemsg.ms_game_delegate"})

return msgdefines