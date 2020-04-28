-- Functions --
lSecession.cDefaults.Spawn = {}

lSecession.cDefaults.Spawn['Allow Respawn'] = true
lSecession.cDefaults.Spawn['Allow Spawn'] = true
lSecession.cDefaults.Spawn['Team'] = 'Red'

functions.createSpawn = function (sType,x,y,z)
	local spawn = exports.CStream:CcreateObject(2995,x,y,z)
	local id = functions.generateElementID('Spawn Point')

	setElementData(spawn,'mID',id)
	sSecession.Elements[id] = spawn
	setElementData(spawn,'eType','Spawn Point')
	
	for i,v in pairs(lSecession.cDefaults.Spawn) do
		setElementData(spawn,i,v)
	end
	
	functions.client(client,'setSelected',spawn,_,true)
	functions.sendTableChanges('Elements')
	functions.sendTableChanges('Selected')
end