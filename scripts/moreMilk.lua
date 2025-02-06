-- Author: westor
-- Contact: westor7 @ Discord
--
-- Copyright (c) 2025 westor

moreMilk = {}
moreMilk.settings = {}
moreMilk.name = g_currentModName or "FS25_moreMilk"
moreMilk.version = "1.0.1.0"
moreMilk.dir = g_currentModDirectory
moreMilk.init = false

function moreMilk.prerequisitesPresent(specializations)
	return true
end

function moreMilk:loadMap()
	if g_dedicatedServer or g_currentMission.missionDynamicInfo.isMultiplayer or not g_server or not g_currentMission:getIsServer() then
		Logging.error("[%s]: Error, Cannot use this mod because this mod is working only for singleplayer!", moreMilk.name)

		return
	end

	InGameMenu.onMenuOpened = Utils.appendedFunction(InGameMenu.onMenuOpened, moreMilk.initUi)

	FSBaseMission.saveSavegame = Utils.appendedFunction(FSBaseMission.saveSavegame, moreMilk.saveSettings)
end

function moreMilk:defSettings()
	moreMilk.settings.Multiplier = 2
	moreMilk.settings.Multiplier_OLD = 2
end

function moreMilk:saveSettings()
	Logging.info("[%s]: Trying to save settings..", moreMilk.name)

	local modSettingsDir = getUserProfileAppPath() .. "modSettings"
	local createXmlFile = modSettingsDir .. "/" .. "moreMilk.xml"

	local xmlFile = createXMLFile("moreMilk", createXmlFile, "moreMilk")
	
	setXMLFloat(xmlFile, "moreMilk.milk#Multiplier",moreMilk.settings.Multiplier)
	
	saveXMLFile(xmlFile)
	delete(xmlFile)
	
	Logging.info("[%s]: Settings have been saved.", moreMilk.name)
end

function moreMilk:loadSettings()
	Logging.info("[%s]: Trying to load settings..", moreMilk.name)
	
	local modSettingsDir = getUserProfileAppPath() .. "modSettings"
	local fileNamePath = modSettingsDir .. "/" .. "moreMilk.xml"
	
	if fileExists(fileNamePath) then
		Logging.info("[%s]: File founded, loading now the settings..", moreMilk.name)
		
		local xmlFile = loadXMLFile("moreMilk", fileNamePath)
		
		if xmlFile == 0 then
			Logging.warning("[%s]: Could not read the data from XML file, maybe the XML file is empty or corrupted, using the default!", moreMilk.name)
			
			moreMilk:defSettings()
			
			Logging.info("[%s]: Settings have been loaded.", moreMilk.name)
			
			return
		end

		local Multiplier = getXMLFloat(xmlFile, "moreMilk.milk#Multiplier")

		if Multiplier == nil or Multiplier == 0 then
			Logging.warning("[%s]: Could not parse the correct 'Multiplier' value from the XML file, maybe it is corrupted, using the default!", moreMilk.name)
			
			Multiplier = 2
		end

		if Multiplier < 1.5 then
			Logging.warning("[%s]: Could not retrieve the correct 'Multiplier' digital number value because it is lower than '1.5' from the XML file or it is corrupted, using the default!", moreMilk.name)
			
			Multiplier = 2
		end
		
		if Multiplier > 100 then
			Logging.warning("[%s]: Could not retrieve the correct 'Multiplier' digital number value because it is higher than '100' from the XML file or it is corrupted, using the default!", moreMilk.name)
			
			Multiplier = 2
		end
		
		moreMilk.settings.Multiplier = Multiplier
		moreMilk.settings.Multiplier_OLD = Multiplier
		
		delete(xmlFile)
					
		Logging.info("[%s]: Settings have been loaded.", moreMilk.name)
	else
		moreMilk:defSettings()

		Logging.info("[%s]: NOT any File founded!, using the default settings.", moreMilk.name)
	end
end

function moreMilk:initUi()
	if not moreMilk.init then
		local uiSettingsmoreMilk = moreMilkUI.new(moreMilk.settings)
		
		uiSettingsmoreMilk:registerSettings()
		
		moreMilk.init = true
	end
end

function moreMilk:loadAnimals()
	if not self.isServer then return end

	Logging.info("[%s]: Initializing mod v%s (c) 2025 by westor.", moreMilk.name, moreMilk.version)

	moreMilk:loadSettings()
	moreMilk:initAllAnimals()
	
	Logging.info("[%s]: End of mod initalization.", moreMilk.name)
end

function moreMilk:initAllAnimals()
	local types = { 
		"COW_SWISS_BROWN", 
		"COW_HOLSTEIN", 
		"COW_WATERBUFFALO",
		
		"GOAT"
	}
	
	moreMilk.updated = 0
	
	Logging.info("[%s]: Start of animals milk updates. - Total: %s", moreMilk.name, table.getn(types))

	moreMilk:initCows()
	moreMilk:initGoats()
	
	Logging.info("[%s]: End of animals milk updates. - Updated: %s - Total: %s", moreMilk.name, moreMilk.updated, table.getn(types))
end

function moreMilk:initCows()
	for _1, subTypeIndex in ipairs(g_currentMission.animalSystem.nameToType["COW"].subTypes) do
		local subType = g_currentMission.animalSystem.subTypes[subTypeIndex]

		if subType.output.milk then
			local fillType = subType.output.milk.fillType
			local fillTypeName = g_fillTypeManager:getFillTypeNameByIndex(fillType)
			local animalType = subType.name
			
			if fillType ~= nil and fillTypeName == "MILK" or fillTypeName == "BUFFALOMILK" then
			
				moreMilk.updated = moreMilk.updated + 1

				for _2, output in ipairs(subType.output.milk.curve.keyframes) do
					local amount = output[1]
					local age = output.time

					if amount ~= nil and amount ~= 0 and age ~= 0 then
						local newAmount = amount * moreMilk.settings.Multiplier

						output[1] = newAmount
						
						Logging.info("[%s]: Cow animal milk amount has been updated. - Animal Type: %s - Age: %s - Old Value: %s - New Value: %s - Multiplier: %s", moreMilk.name, animalType, age, amount, newAmount, moreMilk.settings.Multiplier)
					end
					
				end
				
			end
			
		end
		
	end
end

function moreMilk:initGoats()
	for _1, subTypeIndex in ipairs(g_currentMission.animalSystem.nameToType["SHEEP"].subTypes) do
		local subType = g_currentMission.animalSystem.subTypes[subTypeIndex]

		if subType.output.pallets then
			local fillType = subType.output.pallets.fillType
			local fillTypeName = g_fillTypeManager:getFillTypeNameByIndex(fillType)
			local animalType = subType.name
			
			if fillType ~= nil and fillTypeName == "GOATMILK" then
			
				moreMilk.updated = moreMilk.updated + 1
			
				for _2, output in ipairs(subType.output.pallets.curve.keyframes) do
					local amount = output[1]
					local age = output.time

					if amount ~= nil and amount ~= 0 and age ~= 0 then
						local newAmount = amount * moreMilk.settings.Multiplier

						output[1] = newAmount
						
						Logging.info("[%s]: Goat animal milk amount has been updated. - Animal Type: %s - Age: %s - Old Value: %s - New Value: %s - Multiplier: %s", moreMilk.name, animalType, age, amount, newAmount, moreMilk.settings.Multiplier)
					end
					
				end
				
			end
			
		end
		
	end
end

AnimalSystem.loadAnimals = Utils.appendedFunction(AnimalSystem.loadAnimals, moreMilk.loadAnimals)

addModEventListener(moreMilk)