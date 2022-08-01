local lastVehicle
local modLivery
local menu = {
	id = 'ox_commands:carMenu',
	title = 'Vehicle Mods',
	onChange = function(selected, scrollIndex)
		print('onChange', selected, scrollIndex)

		if scrollIndex then
			if selected == 48 and not modLivery then
				return SetVehicleLivery(lastVehicle, scrollIndex - 1)
			end

			SetVehicleMod(lastVehicle, selected, scrollIndex - 1)
		end
	end,
	options = {}
}

-- https://docs.fivem.net/natives/?_0x6AF0636DDEDCB6DD
local vehicleModType = {
	VMT_SPOILER = 0,
	VMT_BUMPER_F = 1,
	VMT_BUMPER_R = 2,
	VMT_SKIRT = 3,
	VMT_EXHAUST = 4,
	VMT_CHASSIS = 5,
	VMT_GRILL = 6,
	VMT_BONNET = 7,
	VMT_WING_L = 8,
	VMT_WING_R = 9,
	VMT_ROOF = 10,
	VMT_ENGINE = 11,
	VMT_BRAKES = 12,
	VMT_GEARBOX = 13,
	VMT_HORN = 14,
	VMT_SUSPENSION = 15,
	VMT_ARMOUR = 16,
	VMT_NITROUS = 17,
	VMT_TURBO = 18,
	VMT_SUBWOOFER = 19,
	VMT_TYRE_SMOKE = 20,
	VMT_HYDRAULICS = 21,
	VMT_XENON_LIGHTS = 22,
	VMT_WHEELS = 23,
	VMT_WHEELS_REAR_OR_HYDRAULICS = 24,
	VMT_PLTHOLDER = 25,
	VMT_PLTVANITY = 26,
	VMT_INTERIOR1 = 27,
	VMT_INTERIOR2 = 28,
	VMT_INTERIOR3 = 29,
	VMT_INTERIOR4 = 30,
	VMT_INTERIOR5 = 31,
	VMT_SEATS = 32,
	VMT_STEERING = 33,
	VMT_KNOB = 34,
	VMT_PLAQUE = 35,
	VMT_ICE = 36,
	VMT_TRUNK = 37,
	VMT_HYDRO = 38,
	VMT_ENGINEBAY1 = 39,
	VMT_ENGINEBAY2 = 40,
	VMT_ENGINEBAY3 = 41,
	VMT_CHASSIS2 = 42,
	VMT_CHASSIS3 = 43,
	VMT_CHASSIS4 = 44,
	VMT_CHASSIS5 = 45,
	VMT_DOOR_L = 46,
	VMT_DOOR_R = 47,
	VMT_LIVERY_MOD = 48,
	VMT_LIGHTBAR = 49,
}

do
	local arr = {}

	for k, v in pairs(vehicleModType) do
		arr[v] = k
	end

	vehicleModType = arr
end

local GetLabelText = GetLabelText

local function createModEntry(index, vehicle, modCount, getLabel)
	local entries = table.create(modCount, 0)

	for j = -1, modCount - 1 do
		local label = getLabel(vehicle, index, j)
		entries[j + 2] = label and GetLabelText(label) or 'Stock'
	end

	local modType = vehicleModType[index]

	return { label = modType, description = ('Change the current %s'):format(modType), values = entries }
end

local SetVehicleModKit = SetVehicleModKit
local GetNumVehicleMods = GetNumVehicleMods
local GetVehicleLiveryCount = GetVehicleLiveryCount
local GetLiveryName = GetLiveryName
local GetModTextLabel = GetModTextLabel

local function setupVehicleMods(vehicle)
	if vehicle == lastVehicle then return menu end
	SetVehicleModKit(vehicle, 0)

	modLivery = true
	local options = {}

	for i = 0, 49 do
		local entry = i + 1
		local modCount = GetNumVehicleMods(vehicle, i)

		if i == 48 and modCount == 0 then
			modCount = GetVehicleLiveryCount(vehicle)

			if modCount ~= 0 then
				modLivery = false
			end
		end

		if modCount ~= 0 then
			options[entry] = createModEntry(i, vehicle, modCount, (i == 48 and not modLivery) and GetLiveryName or GetModTextLabel)
		else
			options[entry] = {}
		end
	end

	menu.options = options
	lib.registerMenu(menu)
	lastVehicle = vehicle

	return true
end

RegisterCommand('carmenu', function()
	if not cache.vehicle then return end

	if setupVehicleMods(cache.vehicle) then
		lib.showMenu('ox_commands:carMenu')
	end
end)
