
--------------------------------
-- Switch effect on or off
--------------------------------
function switchfxAA( aaOn )
	local aaVal = tonumber( aaOn )
	if (aaVal~=nil and aaVal>0) then
		enablefxAA(aaVal)
	else
		disablefxAA()
	end
end

addEvent( "switchfxAA", true )
addEventHandler( "switchfxAA", resourceRoot, switchfxAA )

function changeSetting(setting)
	-- "Off", "x1", "x2", "x3", "x4"
	if setting == 'Off' then
		disablefxAA()
	elseif setting == 'x1' then
		disablefxAA()
		enablefxAA(1)
	elseif setting == 'x2' then
		disablefxAA()
		enablefxAA(2)
	elseif setting == 'x3' then
		disablefxAA()
		enablefxAA(3)
	elseif setting == 'x4' then
		disablefxAA()
		enablefxAA(4)
	end
end

addEvent ( "FXAA", true )
addEventHandler ( "FXAA", root, changeSetting )
