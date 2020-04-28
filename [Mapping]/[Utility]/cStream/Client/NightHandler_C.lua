-- Tables --
off = {}
nightElements = {}

-- Functions --
function isNightElement(object)
	local id = (getElementID(object) or getElementData(object,'ID'))
	
	if type(data.defintions[id]) == 'table' then
		if tonumber(data.defintions[id].on) then
			nightElements[id] = nightElements[id] or {}
			nightElements[id][(#nightElements[id])+1] = object
			if getLowLODElement(object) then
				nightElements[id][(#nightElements[id])+1] = getLowLODElement(object)
			end
		end
	end
end

function nightElementReload()
	nightElements = {}
	off = {}
	for i,v in pairs(getElementsByType('object',resourceRoot)) do
		isNightElement(v)
	end
	fadeNightElements()
end

function reloadElements()
	if isTimer(timer) then
		killTimer(timer)
		timer = setTimer ( reloadStuff, 2000, 1 )
	end
end


function isWithinTimeRange(start,stop)
	hour = getTime()

	if start > stop then
		return (hour < start and hour > stop)
	else
		return (not (hour < stop and hour > start))
	end
end

function fadeNightElements()
	for i,v in pairs(nightElements) do
		if not tonumber(data.defintions[i].on) then
			NightReload()
		else
			if isWithinTimeRange(tonumber(data.defintions[i].on),tonumber(data.defintions[i].off)) then
				if not (off[i] == 1) then
					off[i] = 1
					for ia,va in pairs(v) do
						if isElement(va) then
							setObjectScale(va,0)
						end
					end
				end
			else
				if not (off[i] == 2) then
					off[i] = 2
					for ia,va in pairs(v) do
						if isElement(va) then
							setObjectScale(va,1)
						end
					end
				end
			end
		end
	end
end

setTimer(fadeNightElements,1000,0)



