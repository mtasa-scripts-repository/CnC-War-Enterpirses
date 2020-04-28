-- main variables
local root = getRootElement()
local resourceRoot = getResourceRootElement(getThisResource())
local screenWidth, screenHeight = guiGetScreenSize()

-- settings
local blurStrength = 6

-- functional variables
local myScreenSource = dxCreateScreenSource(screenWidth, screenHeight)

addEventHandler("onClientResourceStart", resourceRoot,
function()
	blurShader, blurTec = dxCreateShader("shaders/BlurShader.fx")
end)

blurLevel = {}
blurLevel['Low'] = 0.8
blurLevel['Medium'] = 1.2
blurLevel['High'] = 1.5

addEventHandler("onClientHUDRender", root,
function()
	if not ((getElementData(localPlayer,'Blur Enabled') or 'On') == 'Off') then

		local blur1 = math.max((tonumber(getElementData(localPlayer,'Blur')) or 0),0)*(blurLevel[(getElementData(localPlayer,'Blur Enabled') or 'Medium')] or blurLevel['Medium'])
		local blur2 = math.max((tonumber(getElementData(localPlayer,'Blur2')) or 0)/10,0)
		
		if (blurShader) and ((blur1+blur2) > 0) then

			dxUpdateScreenSource(myScreenSource)
			
			dxSetShaderValue(blurShader, "ScreenSource", myScreenSource);
			dxSetShaderValue(blurShader, "BlurStrength", (tonumber(blur1+blur2)));
			dxSetShaderValue(blurShader, "UVSize", screenWidth, screenHeight);
			dxDrawImage(0, 0, screenWidth, screenHeight, blurShader)
			
			local r,g,b = unpack(getElementData(localPlayer,'Blur Color') or {255,255,255})
			setElementData(localPlayer,'Blur Color',{math.min(r+1,255),math.min(g+1,255),math.min(b+1,255)})
	  
			
			if not ((r == 255) and (g == 255) and (b == 255)) then
				dxDrawRectangle ( 0, 0, screenWidth, screenHeight, tocolor(r,g,b,15) )
			end
		else
			setElementData(localPlayer,'Blur Color',{255,255,255})
		end
	end
end)

addEventHandler("onClientResourceStop", resourceRoot,
function()
	if (blurShader) then
		destroyElement(blurShader)
		blurShader = nil
	end
end)