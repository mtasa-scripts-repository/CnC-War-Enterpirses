-- Functions --

functions['Create Light Zone'] = function (x,y,z)
	local zone = exports.CStream:CcreateObject(2996,x,y,z)
	local id = functions.generateElementID('Light Zone')
	setElementData(zone,'mID',id)
	sSecession.Elements[id] = zone
	setElementData(zone,'eType','Light Zone')
	functions['setLightZoneSettings'](zone)
	functions.client(client,'setSelected',zone,_,true)
	functions.sendTableChanges('Elements')
	functions.sendTableChanges('Selected')
end


lSecession.lightZone = {}
lSecession.lightZone.Defaults = {}

lSecession.lightZone.Defaults.lightColor_D = {255,255,255}
lSecession.lightZone.Defaults['Day Enabled'] = true
lSecession.lightZone.Defaults.lightColor_N = {255,255,255}
lSecession.lightZone.Defaults['Night Enabled'] = true
lSecession.lightZone.Defaults.LightSource = 'Sun' -- (Can be 'light','Top','Bottom','Source') (light is defined in the map)
lSecession.lightZone.Defaults['Size'] = 5
lSecession.lightZone.Defaults['Height M'] = 1
lSecession.lightZone.Defaults['Darkness M'] = 1

functions['setLightZoneSettings'] = function (zone)
	for name,data in pairs(lSecession.lightZone.Defaults) do
		setElementData(zone,name,data)
	end
end