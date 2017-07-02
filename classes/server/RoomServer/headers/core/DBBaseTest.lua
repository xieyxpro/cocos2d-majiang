--region DBBaseTest.lua
--Date 2015.8.27
--DB模块的基类测试

local dbconn_gamedb = dbconn_gamedb or nil
local dbthreadlib = dbthreadlib or nil

local DBBaseTest = {
}

DBBaseTest = Util:newClass(DBBaseTest,DBBase)

--endregion

function DBBaseTest:OnServiceStart(dbthreadlib_global, dbconn_accountdb_global, dbconn_gamedb_global, dbconn_statdb_global)
    dbconn_gamedb = dbconn_gamedb_global
    dbthreadlib = dbthreadlib_global
end

function DBBaseTest:handler_dbr_request_test(pDataBuffer, wDataSize)
    --代码示例

    --region 解码
    --方法一:
    --local pbDBReq = protobuf.decode("DBRMsg.xxxxx", pDataBuffer, wDataSize)
    --方法二(推荐):
    --local pbDBReq = dbthreadlib:decode("DBRMsg.xxxxx", pDataBuffer, wDataSize)
    --endregion

    --region db操作
    --dbconn_gamedb:SetSPName("GSP_GS_XXXXX",1)
    --dbconn_gamedb:setUInt(1, pbDBReq.dwUserID)
    --dbconn_gamedb:ExecuteCommand(true)
    --ReqRes = {}
    --ReqRes.xx = dbconn_gamedb:getUInt("xxxx")
    --endregion

    --region 返回给逻辑服务
    --方法一:
    --pReqRes = protobuf.encode("DBRMsg.xxx", ReqRes)
    --dbthreadlib:PostDataBaseEvent(DBR_DB2W.DBR_TEST, pReqRes, pReqRes:len())
    --方法二(推荐):
    --dbthreadlib.PostDataBaseEventMsg(DBR_DB2W.DBR_TEST,"DBRMsg.xxx", ReqRes)
    --endregion
end

--注册启动事件(获取回调钩子)
dbModules[#dbModules + 1] = DBBaseTest
--注册DB事件
workdbeventHandler[DBR_W2DB.DBR_TEST] = DBBaseTest.handler_dbr_request_test