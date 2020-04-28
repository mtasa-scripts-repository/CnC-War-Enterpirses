
skins = {}

skins.marineBR = {22,'Marine_B','Red'}
skins.marineCR = {23,'Marine_C','Red'}
skins.marineDR = {24,'Marine_D','Red'}
skins.marineER = {25,'Marine_E','Red'}
skins.marineFR = {26,'Marine_F','Red'}
skins.marineGR = {27,'Marine_G','Red'}
skins.marineHR = {28,'Marine_H','Red'}
skins.marineIR = {29,'Marine_I','Red'}

skins.marineBB = {32,'Marine_B','Blue'}
skins.marineCB = {33,'Marine_C','Blue'}
skins.marineDB = {34,'Marine_D','Blue'}
skins.marineEB = {35,'Marine_E','Blue'}
skins.marineFB = {36,'Marine_F','Blue'}
skins.marineGB = {37,'Marine_G','Blue'}
skins.marineHB = {38,'Marine_H','Blue'}
skins.marineIB = {39,'Marine_I','Blue'}

for index,v in pairs(skins) do
	print('Loading Skin -',index)
	txd = engineLoadTXD ( 'Content/textures/'..v[3]..'.txd' )
	engineImportTXD ( txd, v[1] )
	dff = engineLoadDFF ( 'Content/models/'..v[2]..'.dff' )
	engineReplaceModel ( dff, v[1] )
end


function setSkins ( text )
	for i,v in pairs(getElementsByType('player')) do
		local team = getElementData(v,'Team')
		if team then
			local model = getElementModel(v)
			if team == 'Blue' then
				if model < 30 then
					setElementModel(v,model+10)
				end
			else
				if model > 30 then
					setElementModel(v,model-10)
				end
			end
		end
	end
end

setTimer ( setSkins, 1000, 0)