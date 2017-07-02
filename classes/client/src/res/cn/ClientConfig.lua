local ClientConfig = {}
local preDir = "app.res.cn.client_config."
package.loaded[preDir..".t_dirs"] = nil
ClientConfig.t_dirs = require(preDir.."t_dirs")
ClientConfig.preDir = ""
ClientConfig.t_ = {
    __index = function(t,key)
        return nil
    end
}
setmetatable(ClientConfig,ClientConfig.t_)

return ClientConfig