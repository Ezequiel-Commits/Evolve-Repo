-- A module containing the bulk of the code used in the GameLogic script
local module = {}

function module.SelectMap(Maps)
	local MapTable = {}
	
	-- convert the given dictionary into a table 
	for i, MapId in pairs(Maps) do
		table.insert(MapTable, MapId)
	end

	-- return a random MapId using the new table 
	local RandomIndex = math.random(1, #MapTable)
	local RandomMapValue = MapTable[RandomIndex]

	return RandomMapValue
end

return module 