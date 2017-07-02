local LaunchScene = {}

function LaunchScene.runWithScene()
    if cc.Director:getInstance():getRunningScene() ~= nil then 
        local scene = display.newScene("launch")
        require("updater.LaunchLayer"):create():addTo(scene)
        cc.Director:getInstance():replaceScene(scene)
    else 
        local scene = display.newScene("launch")
        require("updater.LaunchLayer"):create():addTo(scene)
        cc.Director:getInstance():runWithScene(scene)
    end 
end 

return LaunchScene
