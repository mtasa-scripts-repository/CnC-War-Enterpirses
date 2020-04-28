
attached = {}

function syncTurrent()
	for i,v in pairs(getElementsByType('player')) do
		if isElement(getElementData(v,'turrent')) then
			if not attached[v] then
				if getElementData(v,'turrentPos') then
					local xa,ya,za = unpack(getElementData(v,'turrentPos'))
					attachElements(v,getElementData(v,'turrent'),xa,ya-0.5,za+1)
					attached[v] = true
				end
			end
		else
			if attached[v] then
				detachElements(v)
				attached[v] = nil
			end
		end
	end
end

setTimer ( syncTurrent, 500, 0 )