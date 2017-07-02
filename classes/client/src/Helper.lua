--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local Helper = class("Helper")

function Helper.getCardSpriteBottom(value)
    local img = cc.Sprite:create(string.format("GameScene/vertical/handmah_%02d.png", value))
    assert(img, tostring(value))
    return img
end 

function Helper.getCardSpriteFlatBottom(value)
    local img = cc.Sprite:create(string.format("GameScene/vertical/mingmah_%02d.png", value))
    assert(img, tostring(value))
    return img
end 

function Helper.getCardSpriteFlatTop(value)
    local img = cc.Sprite:create(string.format("GameScene/vertical/handmah_%02d.png", value))
    assert(img, tostring(value))
    return img
end 

function Helper.getCardSpriteFlatLeft(value)
    local img = cc.Sprite:create(string.format("GameScene/left/mingmah_%02d.png", value))
    assert(img, tostring(value))
    return img
end 

function Helper.getCardSpriteFlatRight(value)
    local img = cc.Sprite:create(string.format("GameScene/right/mingmah_%02d.png", value))
    assert(img, tostring(value))
    return img
end 

function Helper.getCardImgPathOfBottom(value)
    return string.format("GameScene/vertical/handmah_%02d.png", value)
end 

function Helper.getCardImgPathOfFlatTop(value)
    return string.format("GameScene/vertical/handmah_%02d.png", value)
end 

function Helper.getCardImgPathOfFlatBottom(value)
    return string.format("GameScene/vertical/mingmah_%02d.png", value)
end 

function Helper.getCardImgPathOfFlatLeft(value)
    return string.format("GameScene/left/mingmah_%02d.png", value)
end 

function Helper.getCardImgPathOfFlatRight(value)
    return string.format("GameScene/right/mingmah_%02d.png", value)
end 

function Helper.showErrorTip(err)
    if not ErrorDefine[err] then 
        return
    end
    UIManager:showTip(ErrorDefine[err])
end 

function Helper.showError(err)
    local tipmsg = ErrorDefine[err]
    if tipmsg then 
        UIManager:showTip(tipmsg)
    else
        UIManager:showTip("Error unknown")
    end 
end 

function Helper.playHomeBgMusic()
    AudioExt:playBGMusic("backMusic")
end 

function Helper.playGameBgMusic()
    AudioExt:playBGMusic("csmj")
end 

function Helper.playCardSound(gender, cardVal)
    if gender == Define.GENDER_FEMALE then 
        AudioExt:playEffect(string.format("woman%d", cardVal))
    else
        AudioExt:playEffect(string.format("man%d", cardVal))
    end 
end 

function Helper.playSoundHu(gender, ziMo)
    local soundNdx = math.random(0, 2)
    if ziMo then 
        if gender == Define.GENDER_FEMALE then 
            AudioExt:playEffect(string.format("woman_zimo%d", soundNdx))
        else
            AudioExt:playEffect(string.format("man_zimo%d", soundNdx))
        end 
    else 
        if gender == Define.GENDER_FEMALE then 
            AudioExt:playEffect(string.format("woman_hu%d", soundNdx))
        else
            AudioExt:playEffect(string.format("man_hu%d", soundNdx))
        end 
    end 
end 

function Helper.playSoundPeng(gender)
    local soundNdx = math.random(0, 2)
    if gender == Define.GENDER_FEMALE then 
        AudioExt:playEffect(string.format("woman_peng%d", soundNdx))
    else
        AudioExt:playEffect(string.format("man_peng%d", soundNdx))
    end 
end 

function Helper.playSoundGang(gender, isAnGang)
    local soundNdx = math.random(0, 1)
    if isAnGang then 
        if gender == Define.GENDER_FEMALE then 
            AudioExt:playEffect(string.format("woman_anGang%d", soundNdx))
        else
            AudioExt:playEffect(string.format("man_anGang%d", soundNdx))
        end 
    else 
        if gender == Define.GENDER_FEMALE then 
            AudioExt:playEffect(string.format("woman_gang%d", soundNdx))
        else
            AudioExt:playEffect(string.format("man_gang%d", soundNdx))
        end 
    end 
end 

function Helper.playSoundChi(gender)
    local soundNdx = math.random(0, 2)
    if gender == Define.GENDER_FEMALE then 
        AudioExt:playEffect(string.format("woman_chi%d", soundNdx))
    else
        AudioExt:playEffect(string.format("man_chi%d", soundNdx))
    end 
end 

function Helper.playSoundTing(gender)
    local soundNdx = math.random(0, 2)
    if gender == Define.GENDER_FEMALE then 
        AudioExt:playEffect(string.format("ting1"))
    else
        AudioExt:playEffect(string.format("ting2"))
    end 
end 

function Helper.playSoundOutcard()
    AudioExt:playEffect(string.format("out_card"))
end 

function Helper.playSoundFailed()
    AudioExt:playEffect(string.format("loss"))
end 

function Helper.playSoundWin()
    AudioExt:playEffect(string.format("win"))
end 

function Helper.playSoundClick()
    AudioExt:playEffect(string.format("ui_click"))
end 

function Helper.playSoundSelect()
    --TODO 这个音乐文件有问题
--    AudioExt:playEffect(string.format("select"))
end 

function Helper.validateID(id)
    if not id or id:len() ~= 18 then 
        return false
    end 
    --[[ 
信息来源：http://baike.baidu.com/link?url=3G6jzbR2EC31d5_DoQwR1aMP89F8VwvCpx3G1wTD5rCnAnc-EmJXBiIVXC6718xEYxYZI0FatCnl0pDqzy-qXfqUuOwhDhY7W9OgNS0XIQRVP3urvm91PEOXpnWoKMrNQSkcsXN9tq-5Bk3nx5bsdCUbpWxYoCuyjV_WuDqZXXA5Zu3AGVBuKQ4pehuW_jzmoWzcQPPBDasd80NLMiVzdnaWGzkzPSUkSFKxMkdq85rNJmQXz_Z3YMOpVzcihkIA
地址码：
    华北地区： 北京市|110000，天津市|120000，河北省|130000，山西省|140000，内蒙古自治区|150000，
    东北地区： 辽宁省|210000，吉林省|220000，黑龙江省|230000，
    华东地区： 上海市|310000，江苏省|320000，浙江省|330000，安徽省|340000，福建省|350000，江西省|360000，山东省|370000，
    华中地区： 河南省|410000，湖北省|420000，湖南省|430000，
    华南地区： 广东省|440000，广西壮族自治区|450000，海南省|460000，
    西南地区： 四川省|510000，贵州省|520000，云南省|530000，西藏自治区|540000，重庆市|500000，
    西北地区： 陕西省|610000，甘肃省|620000，青海省|630000，宁夏回族自治区|640000，新疆维吾尔自治区|650000，
    特别地区：台湾地区(886)|710000，香港特别行政区（852)|810000，澳门特别行政区（853)|820000
--]]
    local dicLocation = {
        ["11"] = "11",
        ["12"] = "12",
        ["13"] = "13",
        ["14"] = "14",
        ["15"] = "15",

        ["21"] = "21",
        ["22"] = "22",
        ["23"] = "23",

        ["31"] = "31",
        ["32"] = "32",
        ["33"] = "33",
        ["34"] = "34",
        ["35"] = "35",
        ["36"] = "36",
        ["37"] = "37",

        ["41"] = "41",
        ["42"] = "42",
        ["43"] = "43",
        ["44"] = "44",
        ["45"] = "45",
        ["46"] = "46",

        ["50"] = "50",
        ["51"] = "51",
        ["52"] = "52",
        ["53"] = "53",
        ["54"] = "54",

        ["61"] = "61",
        ["62"] = "62",
        ["63"] = "63",
        ["64"] = "64",
        ["65"] = "65",

        ["71"] = "71",
        ["81"] = "81",
        ["82"] = "82",
    }
    local locateNO = string.sub(id, 1, 2)
    local detailLocateNO = tonumber(string.sub(id, 3, 6))
    local year = tonumber(string.sub(id, 7, 10))
    local month = tonumber(string.sub(id, 11, 12))
    local day = tonumber(string.sub(id, 13, 14))
    local seq = tonumber(string.sub(id, 15, 17))
    local check = string.sub(id, 18, 18)
    if not dicLocation[locateNO] then 
        return false
    end 
    if not detailLocateNO or 
        not year or 
        not month or 
        not day or 
        not seq then 
        return false
    end 
    if year < 1900 or year > 2100 then 
        return false 
    end 
    if month < 1 or month > 12 then 
        return false 
    end 
    if day < 1 and day > 31 then 
        return false 
    end 
    local checkBit = ""
    local factors = {7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2}
    local checkBits = {1, 0, "X" , 9, 8, 7, 6, 5, 4, 3, 2}
    local sum = 0
    for i = 1, 17, 1 do 
        local n = tonumber(string.sub(id, i, i))
        sum = sum + factors[i] * n
    end 
    local remainder = sum % 11
    checkBit = tostring(checkBits[remainder + 1])
    if check ~= checkBit then 
        return false
    end 
    return true
end

--[Comment]
--新建一个http请求
--callback: function({err = {code = ?, msg = ?}, data = ?}) end 
function Helper.request(url, callback, method)
    local http = cc.XMLHttpRequest:new()
    http.responseType = cc.XMLHTTPREQUEST_RESPONSE_BLOB
    http:open(method or "POST", url)
    local function onReadyStateChange()
        if http.status ~= 200 then 
            if callback then 
                callback({
                    err = {
                        code = http.status,
                        msg = http.statusText,
                    },
                })
            end 
            return 
        end 
        if callback then 
            callback({
                data = http.response,
            })
        end 
    end 
    http:registerScriptHandler(onReadyStateChange)
    http:send()
end 

function Helper.cutNameWithAvaiLen(name)
    if name:len() <= 12 then 
        return name
    else
        return string.sub_utf8(name, 1, 5) .. "..."
    end 
end 

return Helper
--endregion
