lSecession = {}
functions = {}

vehicles = {}

vehicles.warthog = {573,'warthog','warthog',true}
vehicles.mongoose = {471,'mongoose','mongoose'}


for index,v in pairs(vehicles) do
	print('Loading Vehicle -',index)
	txd = engineLoadTXD ( 'Content/textures/'..v[3]..'.txd' )
	engineImportTXD ( txd, v[1] )
	dff = engineLoadDFF ( 'Content/models/'..v[2]..'.dff' )
	engineReplaceModel ( dff, v[1] )
end

lSecession.varients = {}

for i,v in pairs(vehicles) do
	if v[4] then
		local File =  fileOpen('Varients/'..v[2]..'.list')   
		local Data =  fileRead(File, fileGetSize(File))
		local Proccessed = split(Data,10)
		fileClose (File)
		lSecession.varients[v[1]] = {}
		for iA,vA in pairs(Proccessed) do
			local Ssplit = split(vA,',')
			lSecession.varients[v[1]][Ssplit[1]] = Ssplit
		end
	end
end

functions.varientController = function()
	for index,vehicle in pairs(getElementsByType('vehicle')) do
		if isElementStreamedIn(vehicle) then
			local varient = getElementData(vehicle,'vVarient') 
			if (not (varient == getElementData(vehicle,'cVarient')))  then
				local varientList = lSecession.varients[getElementModel(vehicle)]
				if varientList then
					for i,v in pairs(varientList) do
						for ia,va in pairs(v) do
							setVehicleComponentVisible(vehicle,va,false)
						end
					end
					for i,v in pairs(varientList) do
						for ia,va in pairs(v) do
							if (i == varient) then
								setVehicleComponentVisible(vehicle,va,true)
							end
						end
					end
				end
			end
		end
		setElementData(vehicle,'cVarient',varient)
	end
end

addEventHandler ( "onClientRender", root, functions.varientController )

