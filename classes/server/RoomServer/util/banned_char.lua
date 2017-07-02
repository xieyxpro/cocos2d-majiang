--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local bannedChars = 
{
	' ',
	',',
	'`',
	'\'',
	'\\',
	'\"',
	'\t',
	'\r',
	'\n',
	'	',
    '/',
    '[',
    ']',
}

local banned_char = {}

function banned_char:initData()
	self.m_banned = {}
	for _,v in pairs(bannedChars) do
		self.m_banned[string.byte(v)] = true
	end
end

function banned_char:Check(str)
	for k,_ in pairs(self.m_banned) do
		if Util:utfstr_check_char(str, k) then
			return false
		end
	end
	return true
end

banned_char:initData()

g_banned_char = banned_char
return g_banned_char


--endregion
