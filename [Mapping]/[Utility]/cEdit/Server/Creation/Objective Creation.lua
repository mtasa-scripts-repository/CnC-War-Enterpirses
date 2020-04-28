-- Functions --
lSecession.cDefaults.Objective = {}

lSecession.cDefaults.Objective['Team'] = 'Red'
lSecession.cDefaults.Objective['Obj Type'] = 'Marker'
lSecession.cDefaults.Objective['Obj ID'] = 1

functions.createObjective = function (sType,x,y,z)
	local objective = exports.CStream:CcreateObject(2995,x,y,z)
	local id = functions.generateElementID('Objective')

	setElementData(objective,'mID',id)
	sSecession.Elements[id] = objective
	setElementData(objective,'eType','Objective')
	
	for i,v in pairs(lSecession.cDefaults.Objective) do
		setElementData(objective,i,v)
	end
	
	functions.client(client,'setSelected',objective,_,true)
	functions.sendTableChanges('Elements')
	functions.sendTableChanges('Selected')
end