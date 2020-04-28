-- Tables --
table.insert(menus.right.items['New Element'],{'list','Placed Elements'})
menus.right['New Element'].lists['Placed Elements'] = {}


-- Functions --
mRender['Placed Elements'] = function()
	menus.right['New Element'].lists['Placed Elements'] = {}

	for i,v in pairs(functions.getAllElements()) do
		table.insert(menus.right['New Element'].lists['Placed Elements'],{'Placed Element',getElementType(v),v})
	end
end


functions['Placed Element'] = function(arguments,x,y,w,h,side,_,_,fadePercent)
	local fadePercent = tonumber(fadePercent) or 1
	local width = h/2
	
	if isElement(arguments[3]) then
		local name,image = functions.getElementDescription(arguments[3])
		
		local hover = functions.isCursorOnElement(x,y,w,h,'Placed Element Select','Select '..getElementType(arguments[3]),arguments[3] )
		
		if image then		
			if (lSecession.highLightedElement == arguments[3]) and getElementData(arguments[3],'Selected') then
				dxDrawImage(x+(h/5),y,h,h,image, 0, 0, 0, tocolor(100, 100, 255, (200-(hover*50))*fadePercent), true)
			elseif getElementData(arguments[3],'Selected') then
				dxDrawImage(x+(h/5),y,h,h,image, 0, 0, 0, tocolor(255, 100, 100, (200-(hover*50))*fadePercent), true)
			elseif (lSecession.highLightedElement == arguments[3]) then
				dxDrawImage(x+(h/5),y,h,h,image, 0, 0, 0, tocolor(255, 200, 100, (200-(hover*50))*fadePercent), true)
			else
				dxDrawImage(x+(h/5),y,h,h,image, 0, 0, 0, tocolor(255,255,255, (200-(hover*50))*fadePercent),true)	
			end
		end	
		dxDrawText(name, x+(10*s)+(h*1.2),y,x+w,y+h, tocolor(255, 255, 255, 220*fadePercent), 1.00*s, "default-bold", "left", "center", false, false, true, false, false)
	end
end


functions['Placed Element Select'] = function(element)
	functions.setSelected(element)
end
