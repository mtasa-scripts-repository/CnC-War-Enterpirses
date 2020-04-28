--
-- c_switch.lua
--

----------------------------------------------------------------
----------------------------------------------------------------
-- Effect switching on and off
--
--	To switch on:
--			triggerEvent( "switchDR_renderTarget", root, true )
--
--	To switch off:
--			triggerEvent( "switchDR_renderTarget", root, false )
--
----------------------------------------------------------------
----------------------------------------------------------------

--------------------------------
-- onClientResourceStart/Stop
--------------------------------
addEventHandler( "onClientResourceStart", getResourceRootElement( getThisResource()), function()
	if not isFXSupported then 
		outputChatBox( 'dr_renderTarget: Effects not supported', 255, 0, 0 )
		return
	end
	startDR()
	--addCommandHandler( "deftest", function()
		--triggerEvent( "switchDR_renderTarget", resourceRoot, not isDREnabled )
	--end)
end)

addEventHandler( "onClientResourceStop", getResourceRootElement( getThisResource()), function()
	stopDR()
end)

--------------------------------
-- Switch effect on or off
--------------------------------
function switchDR_renderTarget( blOn )
	outputDebugString( "switchDR_renderTarget: " .. tostring(blOn) )
	if blOn then
		switchDROn()
	else
		switchDROff()
	end
end

addEvent( "switchDR_renderTarget", true )
addEventHandler( "switchDR_renderTarget", resourceRoot, switchDR_renderTarget )
