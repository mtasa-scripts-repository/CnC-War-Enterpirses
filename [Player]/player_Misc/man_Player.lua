
presets = {'Kills','Deaths','Score'}
teams = {'Red','Blue','Green'}

function getTeam()
	local minimal = {100,'Blue'}
	local counts = {}
	for i,v in pairs(teams) do
		counts[v] = 0
		for ia,va in pairs(getElementsByType('player')) do
			if getElementData(va,'Team') == v then
				counts[v] = counts[v] + 1
			end
		end
		if counts[v] < minimal[1] then
			minimal = {counts[v],v}
		end
	end
	return minimal[2]
end

for i,v in pairs(getElementsByType('player')) do
	setElementData(v,'Team',getTeam())
end