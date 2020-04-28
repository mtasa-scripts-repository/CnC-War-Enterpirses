--
-- c_main.lua
--

scx, scy = guiGetScreenSize()

----------------------------------------------------------------
-- onClientResourceStart
----------------------------------------------------------------


function enableShader()
	myShader, tec = DxShader("Shaders/lut.fx")
	myTexture = DxTexture("Media/lut.png")
	myScreenSource = DxScreenSource(scx , scy)
		
	bAllValid = myShader and myScreenSource and myTexture

	if not bAllValid then
		disableShader()
	else

		myShader:setValue("sColorTex", myScreenSource)
		myShader:setValue("sLutTex", myTexture )
			
		myShader:setValue("fLUT_AmountChroma", 1.00) -- Intensity of color/chroma change of the LUT.

		myShader:setValue("fLUT_AmountLuma", 1.00) -- Intensity of luma change of the LUT.
	end
end


addEventHandler("onClientResourceStart", resourceRoot,
	function()
		enableShader()
	end
)

function disableShader()
	if isElement(myShader) then
		destroyElement(myShader)
	end
	if isElement(myTexture) then
		destroyElement(myTexture)
	end
	if isElement(myScreenSource) then
		destroyElement(myScreenSource)
	end
	bAllValid = nil
end




function changeSetting(setting)
	if setting == 'Off' then
		disableShader()
	else
		enableShader()
	end
end

addEvent ( "Color Correction", true )
addEventHandler ( "Color Correction", root, changeSetting )

-----------------------------------------------------------------------------------
-- onClientHUDRender
-----------------------------------------------------------------------------------
addEventHandler("onClientHUDRender", root,
    function()
		if not bAllValid then return end
		
		local hour, minute = getTime ()
			
		if hour >= 19 then
			Intensity = math.min(((22-hour)-(minute/60))/7.4,1)
		elseif hour <= 7 then
			Intensity = math.max(((hour-1)+(minute/60))/8,0.01)
		else
			Intensity = 1
		end
		
		myShader:setValue("fLUT_AmountChroma", Intensity*0.9)
		myShader:setValue("fLUT_AmountLuma", Intensity*0.9)
		
		myScreenSource:update(true)
		dxDrawImage(0, 0, scx, scy, myShader)
    end
, true, "high")
