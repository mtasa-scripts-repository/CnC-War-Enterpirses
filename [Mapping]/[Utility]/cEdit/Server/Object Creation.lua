-- Functions --
functions.createObject = function (name,id,x,y,z)
	if getResourceFromName('CStream') then
		if getResourceState ( getResourceFromName('CStream') ) == 'loaded'  then
			startResource(getResourceFromName('CStream'),true)
		end
		-- With CStream Support --
		local object = exports.CStream:CcreateObject(name,x,y,z)
		local id = functions.generateElementID('Object')
		setElementData(object,'mID',id)
		sSecession.Elements[id] = object
		functions.client(client,'setSelected',object)
		functions.sendTableChanges('Elements')
	else
		-- Without CStream Support --
		local object = createObject(id,x,y,z)
		local id = functions.generateElementID('Object')
		setElementData(object,'mID',id)
		sSecession.Elements[id] = object
		functions.client(client,'setSelected',object)
		functions.sendTableChanges('Elements')
	end
end