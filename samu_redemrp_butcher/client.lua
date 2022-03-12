local ButcherPrompt
local hasAlreadyEnteredMarker
local currentZone = nil

local PromptGorup = GetRandomIntInRange(0, 0xffffff)

function SetupButcherPrompt()
    Citizen.CreateThread(function()
        local str = 'Sell Item'
        ButcherPrompt = PromptRegisterBegin()
        PromptSetControlAction(ButcherPrompt, 0xE8342FF2)
        str = CreateVarString(10, 'LITERAL_STRING', str)
        PromptSetText(ButcherPrompt, str)
        PromptSetEnabled(ButcherPrompt, 1)
        PromptSetVisible(ButcherPrompt, 1)
        PromptSetHoldMode(ButcherPrompt, 1)
        PromptSetGroup(ButcherPrompt, PromptGorup)
        PromptRegisterEnd(ButcherPrompt)
    end)
end

local blip = {}

if Config.Blips == true then
    Citizen.CreateThread(function()
        for _, info in pairs(Config.shops) do
            local number = #blip + 1
            blip[number] = N_0x554d9d53f696d002(1664425300, info.coords.x, info.coords.y, info.coords.z)
            SetBlipSprite(blip[number], -1665418949, 1)
            SetBlipScale(blip[number], 0.2)
            Citizen.InvokeNative(0x9CB1A1623062F402, blip[number], 'Butcher')
        end  
    end)
end

Citizen.CreateThread(function()
    SetupButcherPrompt()
	while true do
		Wait(500)
		local isInMarker, tempZone = false
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        for _,v in pairs(Config.shops) do 
            local distance = #(coords - v.coords)
            if distance < 3 then
                local holding = Citizen.InvokeNative(0xD806CD2A4F2C2996, ped)
                local horsepelt = Citizen.InvokeNative(0x0CEEB6F4780B1F2F, horse, 0) -- GETPELTFROMHORSE
                if holding ~= false then
                    isInMarker  = true
                    tempZone = 'butcher'
                elseif not horsepelt then
                    isInMarker = true
                    tempZone = 'butcher'
                end
            end
		end

		if isInMarker and not hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = true
			currentZone = tempZone
		end

		if not isInMarker and hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = false
			currentZone = nil
		end
	end
end)

-- Key Controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

        if currentZone then
            local label  = CreateVarString(10, 'LITERAL_STRING', "Butcher")
            PromptSetActiveGroupThisFrame(PromptGorup, label)
            if PromptHasHoldModeCompleted(ButcherPrompt) then
                Selltobutcher()
				currentZone = nil
			end
        else
			Citizen.Wait(500)
		end
	end
end)

function DeleteThis(holding)
    NetworkRequestControlOfEntity(holding)
    SetEntityAsMissionEntity(holding, true, true)
    Wait(100)
    DeleteEntity(holding)
    Wait(500)
    local entitycheck = Citizen.InvokeNative(0xD806CD2A4F2C2996, PlayerPedId())
    local holdingcheck = GetPedType(entitycheck)
    if holdingcheck == 0 then
        return true
    else
        return false
    end
end

function deletePelt(horsepelt)
    local ped = PlayerPedId()
    local horse = Citizen.InvokeNative(0x4C8B59171957BCF7, ped)
    Wait(100)
    Citizen.InvokeNative(0x627F7F3A0C4C51FF, horse, horsepelt)
    Wait(500)
    local horsepeltcheck = Citizen.InvokeNative(0x0CEEB6F4780B1F2F, horse, 0)
    if not horsepeltcheck then
        return true
    else
        return false
    end
end

function Selltobutcher()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    for k = 1, #Config.shops do 
        local distance = #(Config.shops[k]["coords"] - coords)
        if distance < 3.0 then
            
            local horse = Citizen.InvokeNative(0x4C8B59171957BCF7, ped) -- GetLastMount
            local horsepelt = Citizen.InvokeNative(0x0CEEB6F4780B1F2F, horse, 0) -- GETPELTFROMHORSE
            
            local holding = Citizen.InvokeNative(0xD806CD2A4F2C2996, ped)
            local quality = Citizen.InvokeNative(0x31FEF6A20F00B963, holding)
            local model = GetEntityModel(holding)
            local type = GetPedType(holding)
            if holding ~= false then
                for i, row in pairs(Config.Animal) do
                    if type == 28 then
                        if model == Config.Animal[i]["model"] then
                            local reward = Config.shops[k]["gain"] * Config.Animal[i]["reward"]
                            local level = Config.shops[k]["gain"] * Config.Animal[i]["xp"]

                            local deleted = DeleteThis(holding)
            
                            if deleted then
                                TriggerServerEvent("cryptos_butcher:giveitem", Config.Animal[i]["item"], 1)
                                TriggerServerEvent("cryptos_butcher:reward", reward, level)
                               -- TriggerEvent("redemrp_notification:start", "You earned $" .. reward .. ", " .. level .. " xp and " .. Config.Animal[i]["item"] .. ' Meat', 5, "success")
                                TriggerEvent('redem_roleplay:ShowTopNotification', "AVCILIK", "Getirdiğin avdan kazandığın para: "..reward.." $", 5000)
                            else
                                TriggerEvent("redemrp_notification:start", "DELETE ENTITY NATIVE IS SCUFFED - RELOG PLZ", 2, "success")
                            end

                        end
                    end
                    if quality ~= false then
                        if quality == Config.Animal[i]["poor"] then

                            local rewardresult = Config.shops[k]["gain"] * Config.Animal[i]["reward"]
                            local levelresult = Config.shops[k]["gain"] * Config.Animal[i]["xp"]
                            local reward = rewardresult * 0.5
                            local level = levelresult * 0.5

                            local deleted = DeleteThis(holding)
            
                            if deleted then
                                TriggerServerEvent("cryptos_butcher:reward", reward, level)
                               -- TriggerEvent("redemrp_notification:start", "You earned $" .. reward .. " and " .. level .. " xp", 5, "success")
                                TriggerEvent('redem_roleplay:ShowTopNotification', "AVCILIK", "Getirdiğin avdan kazandığın para: "..reward.." $", 5000)
                            else
                                TriggerEvent("redemrp_notification:start", "DELETE ENTITY NATIVE IS SCUFFED - RELOG PLZ", 2, "success")
                            end

                        elseif quality == Config.Animal[i]["good"] then

                            local rewardresult = Config.shops[k]["gain"] * Config.Animal[i]["reward"]
                            local levelresult = Config.shops[k]["gain"] * Config.Animal[i]["xp"]
                            local reward = rewardresult * 0.75
                            local level = levelresult * 0.75

                            local deleted = DeleteThis(holding)
            
                            if deleted then
                                TriggerServerEvent("cryptos_butcher:reward", reward, level)
                               -- TriggerEvent("redemrp_notification:start", "You earned $" .. reward .. " and " .. level .. " xp", 5, "success")
                                TriggerEvent('redem_roleplay:ShowTopNotification', "AVCILIK", "Getirdiğin avdan kazandığın para: "..reward.." $", 5000)

                            else
                                TriggerEvent("redemrp_notification:start", "DELETE ENTITY NATIVE IS SCUFFED - RELOG PLZ", 2, "success")
                            end

                        elseif quality == Config.Animal[i]["perfect"] then

                            local reward = Config.shops[k]["gain"] * Config.Animal[i]["reward"]
                            local level = Config.shops[k]["gain"] * Config.Animal[i]["xp"]

                            local deleted = DeleteThis(holding)
            
                            if deleted then
                                TriggerServerEvent("cryptos_butcher:reward", reward, level)
                                TriggerEvent('redem_roleplay:ShowTopNotification', "AVCILIK", "Getirdiğin avdan kazandığın para: "..reward.." $", 5000)
                               -- TriggerEvent("redemrp_notification:start", "You earned $" .. reward .. " and " .. level .. " xp", 5, "success")
                            else
                                TriggerEvent("redemrp_notification:start", "DELETE ENTITY NATIVE IS SCUFFED - RELOG PLZ", 2, "success")
                            end

                        end
                    end
                end
            elseif not horspelt then
                if horse ~= false then
                    for i, sam in pairs(Config.Animal) do
                        if horsepelt == Config.Animal[i]["poor"] then
                            local rewardresult = Config.shops[k]["gain"] * Config.Animal[i]["reward"]
                            local levelresult = Config.shops[k]["gain"] * Config.Animal[i]["xp"]
                            local reward = rewardresult * 0.5
                            local level = levelresult * 0.5

                            local deleted = deletePelt(horsepelt)

                            if deleted then
                                TriggerServerEvent("cryptos_butcher:reward", reward, level)
                               -- TriggerEvent("redemrp_notification:start", "You earned $" .. reward .. " and " .. level .. " xp", 5, "success")
                                TriggerEvent('redem_roleplay:ShowTopNotification', "AVCILIK", "Getirdiğin deriden kazandığın para: "..reward.." $", 5000)
                            else
                                print("bir sikinti var")
                            end

                        elseif horsepelt == Config.Animal[i]["good"] then
                            local rewardresult = Config.shops[k]["gain"] * Config.Animal[i]["reward"]
                            local levelresult = Config.shops[k]["gain"] * Config.Animal[i]["xp"]
                            local reward = rewardresult * 0.75
                            local level = levelresult * 0.75

                            local deleted = deletePelt(horsepelt)

                            if deleted then
                                TriggerServerEvent("cryptos_butcher:reward", reward, level)
                               -- TriggerEvent("redemrp_notification:start", "You earned $" .. reward .. " and " .. level .. " xp", 5, "success")
                               TriggerEvent('redem_roleplay:ShowTopNotification', "AVCILIK", "Getirdiğin deriden kazandığın para: "..reward.." $", 5000)
                            else
                                print("bir sikinti var")
                            end

                        elseif horsepelt == Config.Animal[i]["perfect"] then
                            local reward = Config.shops[k]["gain"] * Config.Animal[i]["reward"]
                            local level = Config.shops[k]["gain"] * Config.Animal[i]["xp"]

                            local deleted = deletePelt(horsepelt)

                            if deleted then
                                TriggerServerEvent("cryptos_butcher:reward", reward, level)
                              --  TriggerEvent("redemrp_notification:start", "You earned $" .. reward .. " and " .. level .. " xp", 5, "success")
                                TriggerEvent('redem_roleplay:ShowTopNotification', "AVCILIK", "Getirdiğin deriden kazandığın para: "..reward.." $", 5000)
                            else
                                print("bir sikinti var")
                            end

                        end
                    end
                else
                    TriggerEvent('redem_roleplay:ShowSimpleRightText', "Atina binip iner misin tatlim?",  4000)
                end
            else
               -- TriggerEvent('redem_roleplay:ShowTopNotification', "AVCILIK", "Sırtında veya atının arkasında bir şey taşımıyorsun!", 5000)
               -- print("alpy")
               -- TriggerEvent("redemrp_notification:start", "Not Holding Anything", 2, "error")
            end
        end
    end
end

-- SAMU PUT AND SELL EDIT

RegisterCommand('put', function()
    putPelt()
end)

function putPelt()
    local ped = PlayerPedId()
    local horse = Citizen.InvokeNative(0x4C8B59171957BCF7, ped) -- GetLastMount
    local lastpelt = Citizen.InvokeNative(0xD806CD2A4F2C2996, ped) -- GetFirstEntityPedIsCarrying
    local model = GetEntityModel(lastpelt)
    local carriedEntityHash = Citizen.InvokeNative(0x31FEF6A20F00B963, lastpelt) -- GetCarriableFromEntity


    if horse ~= false then
        if model ~= 0 then
            local horsepelt = Citizen.InvokeNative(0x0CEEB6F4780B1F2F, horse, 0) -- GETPELTFROMHORSE

            if not horsepelt then
                Citizen.InvokeNative(0xa73f50e8796150d5, horse, carriedEntityHash)
                checkPelt()
            else
                TriggerEvent('redem_roleplay:ShowSimpleRightText', "Atın arkasına birden fazla deri koyamazsın!",  4000)
            end
        else
            TriggerEvent('redem_roleplay:ShowSimpleRightText', "Bu komutla atın arkasına yalnızca deri koyabilirsin!",  4000)
        end
    else
        TriggerEvent('redem_roleplay:ShowSimpleRightText', "Atina binip iner misin tatlim?",  4000)
    end
end

function checkPelt()
    local ped = PlayerPedId()
    local horse = Citizen.InvokeNative(0x4C8B59171957BCF7, ped)
    local horsepelt = Citizen.InvokeNative(0x0CEEB6F4780B1F2F, horse, 0)
    local lastpelt = Citizen.InvokeNative(0xD806CD2A4F2C2996, ped)

    if not horsepelt then
        TriggerEvent('redem_roleplay:ShowSimpleRightText', "Bu komutla atın arkasına yalnızca deri koyabilirsin!",  4000)
    else
        DeleteEntity(lastpelt)
        TriggerEvent('redem_roleplay:ShowSimpleRightText', "BAŞARILI",  4000)
    end
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        PromptSetEnabled(ButcherPrompt, false)
        PromptSetVisible(ButcherPrompt, false)
        for k,v in pairs(blip) do
            RemoveBlip(blip[k])
        end
    end
end)
