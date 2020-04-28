-- Tables --
lSecession.Modes = {}

-- Basic Settings --
table.insert(menus.right.items['Settings'],{'list','Map Options'})

function reloadMaps ( )
	local maps = exports.cStream:getMaps()
	menus.right['Settings'].lists['Map Options'] = {}
	table.insert(menus.right['Settings'].lists['Map Options'],{'Option','Map',maps})
end

setTimer ( reloadMaps, 1000, 0 )

local maps = exports.cStream:getMaps()

menus.right['Settings'].lists['Map Options'] = {}

vCache['Map'] = true

table.insert(menus.right['Settings'].lists['Map Options'],{'Option','Map',maps})