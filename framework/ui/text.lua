--[[
    文本 - 底层控件 经常被其他控件包含 例如 进度条的文本 可通过获取进度条文本控件来执行TEXT控件库函数
]]
local mt = {}
local base = require 'Framework.UI.Base'
local __add = base.__add__

local DzCreateFrameByTagName = japi.DzCreateFrameByTagName
local DzFrameSetFont = japi.DzFrameSetFont
local DzFrameSetTextAlignment = japi.DzFrameSetTextAlignment
local DzFrameSetText = japi.DzFrameSetText
function mt:del()
    self:Event_Remove()
    
    setmetatable(self,nil)
    
    --清除表内容
    self.__data = nil
    self.__base = nil
    self.name = nil
    self.class = nil
    
    self.value = nil
    self.font = nil
    self.textsize = nil
end
function mt:new (parm)
    local base = base:new()
    local data = {}
    data = {
            --定制 预留接口
            __data = data,
            __base = base,
            
            --常量
            class = 'text', --类型
            
            --控件变量
            value = '', --文本内容
            font = 'Fonts\\dfst-m3u.ttf', --魔兽默认字体
            textsize = 0.00,
            align = 0,
        }
        
    setmetatable(data, 
        {
            __index = base,
            __newindex = function(t,k,v)
                    if base[k]~=nil and v ~= nil then
                            base[k] = v
                    else
                            rawset(t, k, v) -- 不能直接使用赋值，因为会出现死循环，要使用rawset
                    end
            end,
        }
    )
    local t = {}
    t = setmetatable({},
        {
            __index = function (t,k)
                    return mt[k] or data[k]
            end,
            __newindex = function (t,k,v)
                    if k == 'value' then
                        DzFrameSetText( data.frame , v )
                        data.value = v
                    elseif k == 'font' then
                        if v == '' then
                            data.font = 'Fonts\\dfst-m3u.ttf'
                        else
                            data.font = v
                        end
                        DzFrameSetFont( data.frame, data.font, data.textsize, 0)
                    elseif k == 'textsize' then
                        data.textsize = v
                        DzFrameSetFont( data.frame, data.font, data.textsize, 0)
                    elseif k == 'align' then
                        data.align = v
                        DzFrameSetTextAlignment(data.frame, 100)
                        DzFrameSetTextAlignment(data.frame, v)
                    else
                        
                        data[k] = v
                        
                    end
                    
            end,
            __add = function(t,nt) -- example: text:Create() + { x = 0.2, y = 0.1 } 
                    if type(nt) ~= 'table' then return t end
                    for k,v in ipairs(__add) do
                        if nt[ v ] then
                            t [ v ] = nt [ v ]
                        end
                    end
                    return t
            end,
        }
    )
    if type(parm) ~= 'table' then
        parm = {}
    end
    parm.name = parm.name or NewName()
    
    t.frame = DzCreateFrameByTagName( "TEXT", t.name, t.parent, t.template, t.id )
    t.obj = t
    
    t = t + parm
    
    return t
end
--UI注册事件 同步事件必须同步注册
function mt:Event( event, sync ,func )
    self.__base:Event(event, sync, func)
end
return mt
