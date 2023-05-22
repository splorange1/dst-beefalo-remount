local function BeefaloCancel(inst)
    local beefalo = inst.replica.rider.classified ~= nil and inst.replica.rider.classified.ridermount:value()
    local wx, _, wz = beefalo.Transform:GetWorldPosition()
    GLOBAL.TheNet:SendRPCToServer(GLOBAL.RPC.MakeRecipeFromMenu, 144) -- torch
    GLOBAL.ThePlayer:DoTaskInTime(0.1,function()
        GLOBAL.TheNet:SendRPCToServer(GLOBAL.RPC.LeftClick, GLOBAL.ACTIONS.WALKTO.code, wx+1,wz+1)
            GLOBAL.ThePlayer:DoTaskInTime(0.08,function()
            GLOBAL.TheNet:SendRPCToServer(GLOBAL.RPC.RightClick, GLOBAL.ACTIONS.MOUNT.code, wx, wz, beefalo)
        end)
    end)
end

--[[AddPlayerPostInit(function(inst)
	inst:ListenForEvent("isridingdirty", function(inst)
		if inst ~= GLOBAL.ThePlayer then return end
        if inst.AnimState:IsCurrentAnimation("buck") or inst.AnimState:IsCurrentAnimation("buck_pst") then
            BeefaloCancel(inst)
        end
    end)
end)]]--

AddPlayerPostInit(function(inst)
	inst:ListenForEvent("isridingdirty", function(inst)
		if inst ~= GLOBAL.ThePlayer then return end
        local beefremounttask
        if inst.replica.rider._isriding:value() then
            beefremounttask = GLOBAL.ThePlayer:DoPeriodicTask(GLOBAL.FRAMES, function()
                if inst.AnimState:IsCurrentAnimation("buck") or inst.AnimState:IsCurrentAnimation("buck_pst") then
                    BeefaloCancel(inst)
                    beefremounttask:Cancel()
                end
                if inst.AnimState:IsCurrentAnimation("dismount") then
                    beefremounttask:Cancel()
                end
            end)
        end
    end)
end)
