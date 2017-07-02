--region util_Log.lua
--Date 2015.8.27

Common = {}

--向客户端发送错误码
function Common.SendErr(usrId, errCode)
    local rtn = {err = errCode}
	local rtnData = protobuf.encode("Gamemsg.Err_MS_Err", rtn)
	workthreadlib:SendDataToClient(usrId, CMD_ERR.MAIN, CMD_ERR.SUB_ERR_MS_ERR, rtnData, rtnData:len())
end 

--endregion
