local function TryCraft(check)
    for recname, rec in pairs(GLOBAL.AllRecipes) do
        if GLOBAL.IsRecipeValid(recname) and rec.placer == nil and rec.sg_state ==
            nil and GLOBAL.ThePlayer.replica.builder:KnowsRecipe(recname) and
            GLOBAL.ThePlayer.replica.builder:CanBuild(recname) then
            if check then return true end
            GLOBAL.SendRPCToServer(GLOBAL.RPC.MakeRecipeFromMenu, rec.rpc_id)
            return rec
        end
    end
end

local function BeefaloCancel(inst)
    local beefalo = inst.replica.rider.classified ~= nil and inst.replica.rider.classified.ridermount:value()
    local wx, _, wz = beefalo.Transform:GetWorldPosition()
    TryCraft()
    GLOBAL.ThePlayer:DoTaskInTime(0.1,function()
        GLOBAL.TheNet:SendRPCToServer(GLOBAL.RPC.LeftClick, GLOBAL.ACTIONS.WALKTO.code, wx+1,wz+1)
            GLOBAL.ThePlayer:DoTaskInTime(0.08,function()
            GLOBAL.TheNet:SendRPCToServer(GLOBAL.RPC.RightClick, GLOBAL.ACTIONS.MOUNT.code, wx, wz, beefalo)
        end)
    end)
end

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
