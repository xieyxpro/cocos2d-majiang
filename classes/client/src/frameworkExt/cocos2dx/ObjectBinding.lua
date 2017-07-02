--region ObjectBinding.lua
--Author : Administrator
--Date   : 2014/7/8

--[[--

扩展命名空间，增加动画的支持

]]

-- armature
Armature = ccs.Armature
CCArmature = ccs.Armature
CCArmatureDataManager = ccs.ArmatureDataManager
CCSkin = ccs.Skin

-- actions
CCEaseSineInOut = cc.EaseSineInOut
CCDelayTime = cc.DelayTime
CCCallFunc = cc.CallFunc
CCSequence = cc.Sequence
CCScaleTo = cc.ScaleTo
CCJumpTo = cc.JumpTo
CCJumpBy = cc.JumpBy
CCFadeIn = cc.FadeIn
CCRepeatForever = cc.RepeatForever
CCMoveBy = cc.MoveBy
CCMoveTo = cc.MoveTo
CCSpeed = cc.Speed
CCSpawn = cc.Spawn
CCRotateBy = cc.RotateBy
CCFadeOut = cc.FadeOut
CCFadeTo = cc.FadeTo
CCBezierTo = cc.BezierTo
CCRotateTo = cc.RotateTo
CCEaseSineIn = cc.EaseSineIn
CCEaseSineOut = cc.EaseSineOut

-- 
CCProgressTimer = cc.ProgressTimer
CCProgressFromTo = cc.ProgressFromTo
CCSizeMake = cc.size
CCSpriteFrameCache = cc.SpriteFrameCache
CCSpriteBatchNode = cc.SpriteBatchNode
CCSprite = cc.Sprite
CCUserDefault = cc.UserDefault
CCDirector = cc.Director
CCLabelTTF = cc.LabelTTF
CCFileUtils = cc.FileUtils
CCParallaxNode = cc.ParallaxNode

ccp = cc.p
ccc3 = cc.c3b
ccc4 = cc.c4b
CCSize = cc.size
CCRect = cc.rect


-- UI
GUIReader = ccs.GUIReader
UIHelper = ccui.Helper
Button = ccui.Button
CheckBox = ccui.CheckBox
HBox = ccui.HBox
ImageView = ccui.ImageView
Layout = ccui.Layout
ListView = ccui.ListView
LoadingBar = ccui.LoadingBar
PageView = ccui.PageView
ScrollView = ccui.ScrollView
Slider = ccui.Slider
Text = ccui.Text
TextAtlas = ccui.TextAtlas
TextField = ccui.TextField
VBox = ccui.VBox
Widget = ccui.Widget
LinearLayoutParameter = ccui.LinearLayoutParameter
RichText = ccui.RichText

--endregion
