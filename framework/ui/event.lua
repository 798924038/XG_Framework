--[[
    UI事件库
    
]]
local mt ={}
mt.__index = mt

local DzGetTriggerKey = japi.DzGetTriggerKey
local DzTriggerRegisterMouseMoveEventByCode = japi.DzTriggerRegisterMouseMoveEventByCode
local DzGetMouseXRelative = japi.DzGetMouseXRelative
local DzGetMouseYRelative = japi.DzGetMouseYRelative
local DzGetMouseFocus = japi.DzGetMouseFocus
local DzTriggerRegisterMouseEventByCode = japi.DzTriggerRegisterMouseEventByCode

local event_move_enter = {}
local event_move_leave = {}
local event_mouse_click = {}
local event_mouse_press = {}
local event_mouse_release = {}
function Event_Remove(frame)
    event_move_enter[frame] = nil
    event_move_leave[frame] = nil
    event_mouse_click[frame] = nil
    event_mouse_press[frame] = nil
    event_mouse_release[frame] = nil
end
local __key = 0
local __click = 0
local __frame = 0
local function Event_Mouse_Callback(status)
    local key = DzGetTriggerKey()
    local frame = DzGetMouseFocus()
    
    if frame ~= 0 then
            
            --调用frame按下放开回调
            if status == xconst.MOUSE_PRESS then
                        if event_mouse_press [ frame ] then 
                                        __frame = 0
                                        for k,v in ipairs( event_mouse_press[ frame ] ) do
                                            v (frame,key)
                                        end
                                        
                        end
            else
                        if event_mouse_release [ frame ] then 
                                        for k,v in ipairs( event_mouse_release[ frame ] ) do
                                            v (frame,key)
                                        end
                                        
                        end
            end
            
     end
    if status == xconst.MOUSE_PRESS then
            if __key == key then
                --同一个鼠标按键按两次？
            elseif __key == 0 then
                --之前还未按下 现在按下
                __key = key
                __click = frame
            else
                --按键不同 例如 按下左键后 发现按错了 可以按下右键 来取消按键事件 反之亦可
                __key = 0
                __click = 0
            end
    else
        if __key == key then --按下和放开的是同一个按键 
            __key = 0 -- 复位
            local of = __click
            __click = 0
            --调用Frame点击回调
            if frame ~= 0 then
                        if frame == of then
                                
                                if event_mouse_click [ frame ] then 
                                            for k,v in ipairs( event_mouse_click[ frame ] ) do
                                                v (frame,key)
                                            end
                                            
                            end
                    end
            end
        else
            __key = 0
            __click = 0
        end
    end
    
    
end
local function Event_Mouse_Press()
    Event_Mouse_Callback( xconst.MOUSE_PRESS )
end
local function Event_Mouse_Release()
    Event_Mouse_Callback( xconst.MOUSE_RELEASE )
end
DzTriggerRegisterMouseEventByCode( nil, xconst.MOUSE_LEFT, xconst.MOUSE_PRESS, false, Event_Mouse_Press)
DzTriggerRegisterMouseEventByCode( nil, xconst.MOUSE_LEFT, xconst.MOUSE_RELEASE, false, Event_Mouse_Release)
DzTriggerRegisterMouseEventByCode( nil, xconst.MOUSE_RIGHT, xconst.MOUSE_PRESS, false, Event_Mouse_Press)
DzTriggerRegisterMouseEventByCode( nil, xconst.MOUSE_RIGHT, xconst.MOUSE_RELEASE, false, Event_Mouse_Release)

local function Event_Mouse_Move()
    local x = DzGetMouseXRelative() --相对游戏窗口x
    local y = DzGetMouseYRelative()
    local frame = DzGetMouseFocus()
    local index
       --因为移动事件回调频率很高，所以最好多分层 逐级判断 优化效率
     if __frame ~= 0 then 
            index = __frame
             if event_move_leave [ index ] then 
                            __frame = 0
                            for k,v in ipairs( event_move_leave[ index ] ) do
                                v (index)
                            end
                            
            end
    end
    
    if frame ~= 0 then --鼠标进入控件
            index = frame
            if event_move_enter [ index ] then 
                            __frame = index
                            for k,v in ipairs( event_move_enter[ index ] ) do
                                v (index)
                            end
                            
            end
    end
   
    --Event_Mouse_Callback( MOUSE_RELEASE )
end
function mt:Event(frame,evt,func)
    if evt == xconst.EVENT_MOUSE_ENTER then
            if not event_move_enter[frame] then
                event_move_enter[frame] = {}
            end
            table.insert( event_move_enter[frame], func )
    elseif evt == xconst.EVENT_MOUSE_LEAVE then
            if not event_move_leave[frame] then
                event_move_leave[frame] = {}
            end
            table.insert( event_move_leave[frame], func )
    elseif evt == xconst.EVENT_MOUSE_CLICK then
            if not event_mouse_click[frame] then
                event_mouse_click[frame] = {}
            end
            table.insert( event_mouse_click[frame], func )
    elseif evt == xconst.EVENT_MOUSE_PRESS then
            if not event_mouse_press[frame] then
                event_mouse_press[frame] = {}
            end
            table.insert( event_mouse_press[frame], func )
    elseif evt == xconst.EVENT_MOUSE_RELEASE then
            if not event_mouse_release[frame] then
                event_mouse_release[frame] = {}
            end
            table.insert( event_mouse_release[frame], func )
    end
end

DzTriggerRegisterMouseMoveEventByCode(nil, false, Event_Mouse_Move)

return mt
