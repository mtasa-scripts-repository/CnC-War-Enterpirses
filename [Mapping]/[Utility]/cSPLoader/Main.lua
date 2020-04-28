debug.sethook(nil)

Items = {}
ItemList = {}
altFunt = {}

addEventHandler ( "onResourceStart", root,
function ( resource )
	if getResourceInfo ( resource, 'cStream') then
		loadMap(resource)
	end
	if resource == getThisResource ( ) then
		for i,v in pairs(getResources ()) do
			if getResourceState ( v ) == 'running' then
				loadMap(v)
			end
		end
	end
end 
)

function toBoolen (input)
	if input == 'true' then
		return true
	elseif input == 'false' then
		return false
	end
end

addEventHandler ( "onResourceStop", root,
	function (resource)
		if resource == getThisResource ( ) then
			for i,v in pairs(Items) do
				if isElement(v) then
					destroyElement(v)
				end
			end
		else
			
			if ItemList[getResourceName(resource)] then
				for iA,vA in pairs(ItemList[getResourceName(resource)]) do
					if isElement(vA) then
						destroyElement(vA)
					end
				end
			end
		end
	end
)

function loadMap (resource)
	local resourceName = getResourceName(resource)
	for i,v in pairs(altFunt) do
		v(resourceName)
	end
end