local data = {}

TriggerEvent("redemrp_inventory:getData",function(call)
	data = call
end)

RegisterServerEvent("cryptos_butcher:giveitem")
AddEventHandler("cryptos_butcher:giveitem", function(item, amount)
	local _source = source
	if Config.Redemrp_Inventory1 == true then
		data.addItem(_source, item, amount)
	elseif Config.Redemrp_Inventory2 == true then
	--	local ItemInfo = data.getItemData(item)
		local ItemData = data.getItem(_source, item)
		--if ItemData.ItemAmount >= ItemInfo.limit then
			--TriggerClientEvent("redemrp_notification:start", _source, "You already have to many "..item, 2, "error")
		--else
			ItemData.AddItem(amount)
		--end
	else
		print('must use redemrp_inventory with redemrp_butcher')	
	end
end)

RegisterServerEvent("cryptos_butcher:reward")
AddEventHandler("cryptos_butcher:reward", function(amount, xp)
	local _source = source
	local _amount = tonumber(string.format("%.2f", amount))
	TriggerEvent('redemrp:getPlayerFromId', _source, function(user)
		user.addMoney(_amount)
		user.addXP(xp)
	end)
end)