# cocos2d麻将

## 视频展示
[游戏视频By B站](https://www.bilibili.com/video/av14109165/)

## 界面截图
 1. 开始界面
 
 ![image](https://github.com/xieyxpro/cocos2d-majiang/blob/master/Screenshots/1.png)
 
 2. 大厅界面
 
 ![image](https://github.com/xieyxpro/cocos2d-majiang/blob/master/Screenshots/2.png)
 
 3. 游戏界面
 
 ![image](https://github.com/xieyxpro/cocos2d-majiang/blob/master/Screenshots/3.png)
 
 4. 结算界面
 
 ![image](https://github.com/xieyxpro/cocos2d-majiang/blob/master/Screenshots/4.png)
 
## 客户端使用说明

### 1. 消息处理

消息的处理一律实行按需注册，不再使用后反注册的观察者模式。

#### 1.1 网络消息
网络消息的注册: function Network:registerMsgProc(serverName, msgName, caller, callerFuncOrName)
ServerName: 服务器分为大厅服务器（Define.SERVER_HOME）和游戏服务器（Define.SERVER_GAME）
msgName: 需要注册处理的消息名称
caller: 消息处理函数的调用者
callerFuncOrName: 消息处理方法名称
示例代码：
```
local xxxCache = class("xxxCache")

function xxxCache:ctor()
  Network:registerMsgProc(Define.SERVER_GAME, "ms_dismiss", self, "ms_dismiss")
end 

function xxxCache:ms_dismiss(data)
  --TODO 处理消息
end 

return xxxCache
```
在如上代码中，当cache在创建了之后，便注册了对ms_dismiss服务器消息的监听，当有消息ms_dismiss收到之后，方法function xxxCache:ms_dismiss(data)将会被自动调用，参数data为lua的table
PS: 网络消息的处理一般由Cache来负责接收，在Cache接收完并处理好之后，Cache将派发一个通知，相应的UI界面在收到通知后进行UI的更新。
![image](https://github.com/xieyxpro/cocos2d-majiang/blob/master/Screenshots/5.png)

#### 1.2 普通消息
消息注册：function Event.register(eventName, caller, funcOrFuncName)
消息反注册：function Event.unregister(eventName, caller, funcOrFuncName)
消息广播：function Event.dispatch(eventName, ...)
eventName: 消息名称
caller: 消息处理方法的调用者
funcOrFuncName: 消息处理函数名称或者函数地址
示例代码：
```
local ui = class("ui", cc.Layer)
function ui:ctor()
  self:enableNodeEvents()
end 

function ui:onEnter()
  Event.register("xxx", self, "xxx")
end 

function ui:onExit()
  Event.unregister("xxx", self, "xxx")
End

function ui:xxx(data)
  --do implementation
end

return ui
```
在如上代码中，我们在ui创建之后，在onEnter时对消息xxx进行监听，并定义了相应的处理函数xxx, 当收到有xxx消息广播时，xxx方法就会被自动调用，而当ui退出之后，我们不需要再继续对这个消息进行监听处理，所以就用了反注册unregister。

### 2 网络消息定义
网络消息的定义在msgdefine.lua文件中进行。
function addMsgDefine(serverName, define)
serverName: 指明消息所属服务器
define: 消息的具体定义参数，遵循格式：{name = "", mainCmd = 0, subCmd = 0, proto = ""}
name: 消息名称
mainCmd: 消息主码
subCmd: 消息子码
proto: 所使用的proto, 如果这个消息不使用proto， 请置为空字符串
比如要增加一个胡牌的消息，代码如下：
addMsgDefine("game", {name = "mc_action_hu", mainCmd = 200, subCmd = 124, proto = "Gamemsg.mc_action_hu"})

### 3. 网络消息发送
function Network:send(serverName, msgName, data)
	serverName: 发送服务器类型，如game（游戏或房间服务器）或者home(大厅服务器)
	msgName: 消息名称，如mc_dismiss
	data: 需要发送的数据table
 
### 4. 网络消息接收
网络消息接收见“消息处理”

### 5. 牌局
牌局流程如下图所示，关于各个消息中消息协议的定义，请参考protobuf文件。
![image](https://github.com/xieyxpro/cocos2d-majiang/blob/master/Screenshots/6.png)

#### 5.1 登录房间服务器
HomeCache:loginGame()

#### 5.2 登录房间成功
在登录房间成功后将会收到服务器如下消息：
function HomeCache:ms_room_logon_finish(data)
在这个方法中，如果有什么登录信息需要保存和检测，请在这个方法中处理

#### 5.3 请求创建房间或进入房间
a. 请求创建房间
在收到玩家登录房间成功后，客户端开始申请创建或者进入房间，发送如下消息创建房间：
```
Network:send(Define.SERVER_GAME, "mc_create_room", data)
```
b. 请求进入房间
```
Network:send(Define.SERVER_GAME, "mc_join_room", {
  roomID = tonumber(roomID),
})
```

#### 5.4 创建或者进入房间成功
客户端将会受到如下消息，如果服务器校验未能通过，相应的错误信息会随着消息返回。
ms_join_room

#### 5.5 接收房间信息
ms_room_info

#### 5.6 通知服务器客户端已准备完成
当客户端准备完成之后（比如资源加载），需要告知服务器以便于服务器做下一步的操作
Network:send(Define.SERVER_GAME, "mc_gamescene_load_finish",nil)

#### 5.7 玩家坐下
任意玩家如果加入了该房间，并且做下，相应的在这个房间的其他玩家也会收到这个玩家在这个房间中坐下的消息通知。
ms_sit_down

#### 5.8 玩家准备
如果玩家做下之后呈现准备状态（目前服务器将针对进入房间的玩家自动准备），客户端将会受到这个消息的通知
ms_player_ready

#### 5.9 接收房间的其他玩家信息
如果玩家加入到房间时已经有其他玩家进入了该房间，那么其他玩家的信息将会通过这个消息发送给客户端。
ms_room_players_info

#### 5.10 进入房间
a. 玩家在收完其他玩家信息后，就正式进入房间，如果这个时候房间是还在准备阶段（即人数未满或者等待其他玩家准备而导致牌局没有开始），进入房间的玩家将会收到如下消息：
ms_game_scene_free
b. 如果玩家原本就在房间之中，某些时候可能由于强制退出客户端或者网络断线等导致玩家重新登录了房间服务器，这个时候玩家将会收到如下消息：
ms_game_scene_play

#### 5.11 开始游戏
当所有玩家在房间准备阶段都准备好之后，游戏将会自动开始，所有客户端将收到服务器推送的开始游戏消息，从而游戏正式开始：
ms_game_start

#### 5.12 玩家操作
开始游戏之后，游戏中的各个玩家对游戏进行操作，具体操作请求服务器返回消息将根据游戏的不同而不同，此处介绍麻将游戏的基本操作：

操作 | 客户端请求消息 | 服务器返回消息
----|------|----
系统发牌 |  无  | ms_system_dispatch_card
吃 | mc_action_chi |	ms_action_chi
碰	| mc_action_peng	| ms_action_peng
杠	| mc_action_gang	| ms_action_gang
过	| mc_action_guo	| ms_action_guo
胡	| mc_action_hu	| ms_action_hu
出牌	| mc_out_card	| ms_out_card

#### 5.13 游戏结束
游戏结束后客户端将会收到如下消息，表明当前牌局结束：
ms_game_over

#### 5.14 房间解散
当玩家在这个房间玩满固定的局数或者请求解散后，房间将会被释放，而客户端也会收到房间解散的通知。
ms_dismiss


### 6 常用方法说明
a.	function UIManager:getCurrentScene()
获取当前游戏最上层UI所在的场景

b.	function UIManager:clearAllAndGoTo(sceneName, uilayerRequireName, uiType, params, closePrevious)
清除所有UI节点堆栈，并实现跳转

c.	function UIManager:goTo(sceneName, uilayerRequireName, uiType, params, closePrevious)
跳转去到某个UI层

d.	function UIManager:goBack(sceneName, uilayerRequireName, uiType, params)
返回上一层UI节点

e.	function UIManager:showTip(text)
显示飘字提示

f.	function UIManager:replaceCurrent(sceneName, uilayerRequireName, uiType, params)
替换当前显示的最上层UI界面

g.	function UIManager:show(uilayerRequireName, params)
显示UI层

h.	function UIManager:close(node)
关闭节点，一般是关闭某个由UIManager:show函数显示的UI层

i.	function UIManager:block(delayDspTime)
阻塞当前的所有Ui操作，可以用于发送请求到服务器，而服务器还没有应答返回的这个阶段阻塞玩家的所有操作。

j.	function UIManager:unblock()
接触UI阻塞

k.	function UIManager:showMsgBox(params)
显示对话框，用于需要玩家确认的操作。
参数说明：
![image](https://github.com/xieyxpro/cocos2d-majiang/blob/master/Screenshots/7.png)

l.	function Network:send(serverName, msgName, data)
想服务器发送消息请求

### 7 代码目录结构说明
框架说明:

![image](https://github.com/xieyxpro/cocos2d-majiang/blob/master/Screenshots/8.png)

游戏主要逻辑说明:

![image](https://github.com/xieyxpro/cocos2d-majiang/blob/master/Screenshots/9.png)
