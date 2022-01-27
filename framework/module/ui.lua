--[[
    UI模块
]]

require 'framework.module.timer'
local DzFrameEditBlackBorders = japi.DzFrameEditBlackBorders
local DzLoadToc = japi.DzLoadToc
local DzFrameShow = japi.DzFrameShow
local DzFrameGetMinimapButton = japi.DzFrameGetMinimapButton
local DzFrameGetMinimap = japi.DzFrameGetMinimap
local DzFrameClearAllPoints = japi.DzFrameClearAllPoints
local DzFrameSetPoint = japi.DzFrameSetPoint
local DzFrameSetSize = japi.DzFrameSetSize
local DzFrameGetTooltip = japi.DzFrameGetTooltip
local DzFrameGetChatMessage = japi.DzFrameGetChatMessage
local DzFrameGetUnitMessage = japi.DzFrameGetUnitMessage
local DzFrameGetCommandBarButton = japi.DzFrameGetCommandBarButton
local DzFrameGetItemBarButton = japi.DzFrameGetItemBarButton

--DzFrameHideInterface()
--DzFrameEditBlackBorders( 0, 0 )
DzLoadToc( "UI\\xglist.toc" )

timer:once(0.1,
    function(timer)
        for i = 0,4 do
            DzFrameShow( DzFrameGetMinimapButton(i), false )
            --DzDestroyFrame( DzFrameGetMinimapButton(i) )
        end
    end
)
timer:once(0.01,function(timer)
    local map = DzFrameGetMinimap()
    local i = 0
    DzFrameClearAllPoints( map )
    DzFrameSetPoint( map, 6, xconst.GameUI, 6, 0, 0 )
    DzFrameSetSize( map, 0.13, 0.13 )
    DzFrameShow( map, true )
    map= DzFrameGetTooltip()
    DzFrameClearAllPoints( map )
    --DzFrameSetPoint( map, 6, ui['StatusBar'], 2, -0.07, 0.009 )
    --DzFrameSetSize( map, 0.13, 0.13 )
    DzFrameShow( map, true )

    DzFrameShow( DzFrameGetChatMessage(), true )
    DzFrameShow( DzFrameGetUnitMessage(), true )
    for y=0,3 do
        for x=0,2 do
            map = DzFrameGetCommandBarButton(x, y)
            --DzFrameClearAllPoints( map )
            --DzFrameSetPoint( map, 0, GameUI, 7, 0.038*y-0.001, -0.038*x-0.006 )
            --DzFrameSetSize( map, 0.02, 0.02 )
            DzFrameShow( map, true )
             i=i+1
        end
    end
     for x=0,5 do
        map = DzFrameGetItemBarButton(x)
        DzFrameClearAllPoints( map )
        --DzFrameSetPoint( map, 0, ui['StatusBar'], 2, -0.031*(5-x)-0.032, 0.01)
        --DzFrameSetSize( map, 0.02, 0.02 )
        DzFrameShow( map, true )
    end
end)
