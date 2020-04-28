-- Functions --
lSecession.cDefaults.Weapon= {}

lSecession.cDefaults.Weapon['Wep Type'] = 'Weapon Spawn'
lSecession.cDefaults.Weapon['Weapon'] = 'AR'
lSecession.cDefaults.Weapon['Ammo Count'] = 36
lSecession.cDefaults.Weapon['wep_Respawn'] = 25


functions.createWeapon = function (sType,x,y,z)
	local weapon = exports.CStream:CcreateObject(2995,x,y,z)
	local id = functions.generateElementID('Weapon')

	setElementData(weapon,'mID',id)
	sSecession.Elements[id] = weapon
	setElementData(weapon,'eType','Weapon')
	
	for i,v in pairs(lSecession.cDefaults.Weapon) do
		setElementData(weapon,i,v)
	end
	
	functions.client(client,'setSelected',weapon,_,true)
	functions.sendTableChanges('Elements')
	functions.sendTableChanges('Selected')
end