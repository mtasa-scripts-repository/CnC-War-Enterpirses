-- Functions --
functions.Save = function()
	if (lSecession.variables['Map']) and not (lSecession.variables['Map'][1] == '') then
		functions.server('saveMap',lSecession.variables['Map'][1])
		functions.sendNotification('Map '..lSecession.variables['Map'][1]..' saved to resource '..lSecession.variables['Map'][1]..'.')
	else
		functions.sendNotification('Please specify "Map" (Under Map Options)','Settings')
	end
end