--[[
    UI基础库
]]
local mt = {
    --重载 +  所支持的key都填进来
    __add__ = {
        --base
        'absPoint',
        'x',
        'y',
        'width',
        'height',
        'enable',
        'visible',
        'point',
        'template',
        'id',
        'obj',
        'parentcolor',
        --text
        'value',
        'font',
        'textsize',
        'align',
        --drop
        'image',
        'flag',
        --button
        'contour',
    }
}
local __obj = { } --存储UI控件的对象 
local GetLocalPlayer = cj.GetLocalPlayer
local GetPlayerId = cj.GetPlayerId

local DzFrameSetPoint = japi.DzFrameSetPoint
local DzFrameClearAllPoints = japi.DzFrameClearAllPoints
local DzFrameSetAbsolutePoint = japi.DzFrameSetAbsolutePoint
local DzFrameClearAllPoints = japi.DzFrameClearAllPoints
local DzFrameSetSize = japi.DzFrameSetSize
local DzFrameSetEnable = japi.DzFrameSetEnable
local DzFrameShow = japi.DzFrameShow
local DzFrameSetParent = japi.DzFrameSetParent
local DzFrameSetVertexColor = japi.DzFrameSetVertexColor
local DzGetColor = japi.DzGetColor
local DzGetTriggerUIEventFrame = japi.DzGetTriggerUIEventFrame
local DzFrameSetScriptByCode = japi.DzFrameSetScriptByCode
local DzGetTriggerUIEventPlayer = japi.DzGetTriggerUIEventPlayer


function mt:new()
    local t = {}
    local data = {
        type = 'XGUI',
        
        --控件默认基础属性
        frame = 0,
        name = "",
        enable = true, --控件启用
        visible = true, --控件可视
        parent = xconst.GameUI, --父控件
        template = 'template', --模板
        id = 0, --控件id 默认0
        
        -- -- -- -- -- -- -- --控件基础值-- -- -- -- -- -- -- -- -- -- -- -
        absPoint = 0, --设置绝对位置所参照的点
        x = 0,
        y = 0,
        width = 0,
        height = 0,
        color = {R=255,G=255,B=255,A=255},
        
        -- -- -- -- -- -- --控件预设通用系统变量-- -- -- -- -- -- -- -
        point = 0,
        obj = 0, --应是个表（控件）
        __event__ = { }, --用于存储事件
        __point__ = { },
        
        
    }
    t = setmetatable({},{
        __index = function(t,k) return mt[k] or data[k] end,
        __newindex = function(t,k,v)
                        if k == 'absPoint' then
                            japi.DzFrameClearAllPoints(data.frame)
                            japi.DzFrameSetAbsolutePoint( data.frame , v, data.x, data.y )
                            data.absPoint = v
                        elseif k == 'point' then -- point = { POINT_LT , frame, POINT_LT, x, y } 将点附着在指定frame的点上
                            --一旦设置相对锚点 则 x y属性 不能使用
                            --point = nil 清除所有锚点
                            if not v then 
                                DzFrameClearAllPoints(data.frame)
                                data.__point__ = { }
                            else
                                data.__point__ [ v[1] ] = { v[2], v[3], v[4] or 0, v[5] or 0 }
                                DzFrameSetPoint(t.frame, v[1], v[2], v[3], v[4], v[5] )
                            end
                        elseif k == 'x' then
                            DzFrameSetAbsolutePoint( data.frame , data.absPoint, v, data.y )
                            data.x = v
                        elseif k == 'y' then
                            DzFrameSetAbsolutePoint( data.frame , data.absPoint, data.x, v )
                            data.y = v
                        elseif k == 'width' then
                            DzFrameSetSize( data.frame , v, data.height )
                            data.width = v
                        elseif k == 'height' then
                            DzFrameSetSize( data.frame , data.width, v )
                            data.height = v
                        elseif k == 'enable' then
                            DzFrameSetEnable( data.frame , v )
                            data.enable = v
                        elseif k == 'visible' then
                            DzFrameShow( data.frame , v )
                            data.visible = v
                        elseif k == 'frame' then
                            if data.frame == 0 then
                                data.frame = v
                            end
                        elseif k == 'obj' then
                            __obj [ data.frame ] = v
                        elseif k == 'parent' then
                            DzFrameSetParent(data.frame, v)
                            data.parent = v
                        elseif k == 'color' then
                            if type(v) ~= 'table' then
                                v = {R=255,G=255,B=255,A=255}
                            else
                                v = {R=v.R or 255,G=v.G or 255,B=v.B or 255,A=v.A or 255}
                            end
                            DzFrameSetVertexColor( data.frame, DzGetColor( v.R, v.G, v.B, v.A))
                        end
        end
    })
    return t
end
local i = 0
NewName = function ()
    i = i + 1
    return table.concat( { 'ui_' , i } )
end
function Frame2Obj (frame)
    return __obj [ frame ]
end
local sync_func = { [0] = 0 }
sync:callback("ui_evt", function()
    local d = sync:load()
    local fid = tonumber( d [ 4 ] )
    local func = sync_func[fid]
    if type(func) == "function" then
        func()
    end
end)
function mt:Event_Remove()
    local evt = require "UI.Event"
    evt:Event_Remove(self.frame)
end
local function Event_callback(frame,event,player)
        local obj = Frame2Obj(frame)
        for k,v in ipairs( obj.__event__[event] ) do
                if v.sync then
                        local d = sync:new()
                        d:Add( frame, event, GetPlayerId(player),v.fid )
                        d:Send("ui_evt")
                else
                            v.func()
                end
            
        end
end
local function EVENT_MOUSE_CLICK_callback(frame)
    Event_callback(
        frame,
        xconst.EVENT_MOUSE_CLICK,
        GetLocalPlayer()
    )
end
local function EVENT_MOUSE_UP_callback(frame)
    Event_callback(
        frame,
        xconst.EVENT_MOUSE_UP,
        GetLocalPlayer()
    )
end
local function EVENT_MOUSE_DOWN_callback(frame)
    Event_callback(
        frame,
        xconst.EVENT_MOUSE_DOWN,
        GetLocalPlayer()
    )
end
local function EVENT_MOUSE_ENTER_callback(frame)
    Event_callback(
        frame,
        xconst.EVENT_MOUSE_ENTER,
        GetLocalPlayer()
    )
end
local function EVENT_MOUSE_LEAVE_callback(frame)
    Event_callback(
        frame,
        xconst.EVENT_MOUSE_LEAVE,
        GetLocalPlayer()
    )
end
local function EVENT_MOUSE_WHEEL_callback()
    Event_callback(
        DzGetTriggerUIEventFrame(),
        xconst.EVENT_MOUSE_WHEEL,
        DzGetTriggerUIEventPlayer()
    )
end
local function EVENT_MOUSE_DOUBLECLICK_callback()
    Event_callback(
        DzGetTriggerUIEventFrame(),
        xconst.EVENT_MOUSE_DOUBLECLICK,
        DzGetTriggerUIEventPlayer()
    )
end
--UI注册事件 必须同步注册
function mt:Event(event, sync, func)
                local t = {func = func,sync = sync}
                if t.sync then
                    sync_func [ 0 ] = sync_func [ 0 ] + 1
                    sync_func [ sync_func [ 0 ] ] = func
                    t.fid = sync_func [ 0 ] 
                end
                if not self.__event__[event] then --第一次注册事件
                    self.__event__[event]= { t }
                else
                    table.insert( self.__event__[event], t )
                end
                if not self.__event__[event].reg then
                        local evt = require 'UI.Event'
                        if event == xconst.EVENT_MOUSE_CLICK then
                            evt:Event(self.frame, event, EVENT_MOUSE_CLICK_callback)
                            --DzFrameSetScriptByCode( self.frame, event, EVENT_MOUSE_CLICK_callback, false )
                        elseif event == xconst.EVENT_MOUSE_UP then
                            evt:Event(self.frame, event, EVENT_MOUSE_UP_callback)
                            --DzFrameSetScriptByCode( self.frame, event, EVENT_MOUSE_UP_callback, false )
                        elseif event == xconst.EVENT_MOUSE_DOWN then
                            evt:Event(self.frame, event, EVENT_MOUSE_DOWN_callback)
                            --DzFrameSetScriptByCode( self.frame, event, EVENT_MOUSE_DOWN_callback, false )
                        elseif event == xconst.EVENT_MOUSE_ENTER then
                            evt:Event(self.frame, event, EVENT_MOUSE_ENTER_callback)
                            --DzFrameSetScriptByCode( self.frame, event, EVENT_MOUSE_ENTER_callback, false )
                        elseif event == xconst.EVENT_MOUSE_LEAVE then
                            evt:Event(self.frame, event, EVENT_MOUSE_LEAVE_callback)
                            --DzFrameSetScriptByCode( self.frame, event, EVENT_MOUSE_LEAVE_callback, false )
                        elseif event == xconst.EVENT_MOUSE_WHEEL then
                            DzFrameSetScriptByCode( self.frame, event, EVENT_MOUSE_WHEEL_callback, false )
                        elseif event == xconst.EVENT_MOUSE_DOUBLECLICK then
                            DzFrameSetScriptByCode( self.frame, event, EVENT_MOUSE_DOUBLECLICK_callback, false )
                        end
                        self.__event__[event].reg = true
            end
end
return mt
