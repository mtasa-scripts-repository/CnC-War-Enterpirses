exports.base_env:setSunPosition ( 576.102,-120.126,855.044)

exports.base_env:setSunColor ( 210,195,175)
exports.base_env:setNightLimit ( 0.2)



local startR = exports.cStream:CcreateObject(2996,4.006,-26.601,-17.512+250,0,0,0,'BeaverCreek')
setElementAlpha(startR,0)
setElementCollisionsEnabled(startR,false)
setElementData(startR,'Water Start',true)
setElementData(startR,'ID',1)

local endR = exports.cStream:CcreateObject(2996,-0.293,32.706,-17.512+250,0,0,0,'BeaverCreek')
setElementAlpha(endR,0)
setElementCollisionsEnabled(endR,false)
setElementData(endR,'Water End',true)
setElementData(endR,'ID',1)



addEventHandler( "onClientResourceStop", resourceRoot,
    function ( stoppedRes )
		if isElement(startR) then
			destroyElement(startR)
			destroyElement(endR)
		end
    end
);

