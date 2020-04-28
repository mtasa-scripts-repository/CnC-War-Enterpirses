-- Tables --
lSecession.language = 'nil'
lSecession.DFade = {}
lSecession.last = {1,1}

-- Function --


functions.loadDescription = function (names)
	for i,v in ipairs(names) do
		if not lSecession.Descriptions[v] then
			functions.server('retreiveDescription',v,lSecession.language)
		end
	end
	
	for i,v in ipairs(names) do
		if lSecession.Descriptions[v] then
			return lSecession.Descriptions[v],v
		end
	end
end

functions.retreiveDescription = function (name,description)
	lSecession.Descriptions[name] = description
end

lRender.drawDescription = function ()
	if lSecession.description or (lSecession.DFade[lSecession.last[2]] or 0) > 0 then
		local Sdescription = lSecession.description or {}
		local description,name = functions.loadDescription(Sdescription)
		if description and name then
			local current = toJSON(lSecession.last)
			lSecession.last = {description, functions.fetchTranslation(name) or name}
			if not(toJSON(lSecession.last) == current) then
				lSecession.DFade = {}
			end
		end
		
		if (description and name) or ((lSecession.DFade[lSecession.last[2]] or 0) > 0) then
			if description then
				lSecession.DFade[lSecession.last[2]] = math.min((lSecession.DFade[lSecession.last[2]] or 0)+8,150)
			else
				lSecession.DFade[lSecession.last[2]] = math.max((lSecession.DFade[lSecession.last[2]] or 0)-8,0)
			end
		
			
			local x,w = (xSize - ((menus.settings.boarder+menus.settings.width)*s)),(menus.settings.width*s)
			local str = lSecession.last[1]
			local _,count = str:gsub('\n', '\n')
			local count = (count + 1)
			local height = dxGetFontHeight ( 1.2*s, 'default-bold' )+(dxGetFontHeight ( 1*s, 'default-bold' )*count)+(25*s)
			dxDrawRectangle (x,rHeight+(20*s),w,(29*s), tocolor ( 45, 45, 45, lSecession.DFade[lSecession.last[2]] ),true )	
			dxDrawRectangle (x,rHeight+(50*s),w,height-(30*s), tocolor ( 0, 0, 0, lSecession.DFade[lSecession.last[2]] ),true )

			dxDrawText ( lSecession.last[2] or '',x+(15*s),rHeight+(20*s),w+x,rHeight+(50*s),tocolor(255, 255, 255, lSecession.DFade[lSecession.last[2]]+50 ), 1.2*s, "default-bold", "left", "center", false, false, true, false, false )
			dxDrawText ( lSecession.last[1] or '',x,rHeight+(57*s),w+x,rHeight+(170*s),tocolor(255, 255, 255, lSecession.DFade[lSecession.last[2]]+10 ), 1.00*s, "default-bold", "center", "top", false, false, true, false, false )
		end
	end
end