AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local _GRAVITY = Vector(0, 0, -1)
local _INITIAL_VEL_Z = 1500
local _LIFETIME = 15.0

local MAX_DIST = (function()
    local dt = engine.TickInterval()
    local maxTicks = math.floor(_LIFETIME / dt)
    local vz = _INITIAL_VEL_Z
    local dist = 0

    for _ = 1, maxTicks do
        vz = (vz * (1 - dt)) + _GRAVITY.z
        if vz <= 0 then break end
        dist = dist + (vz * dt)
    end

    return dist
end)()


function ENT:Initialize()
    self:SetModel("models/props_junk/flare.mdl")

    ---@diagnostic disable-next-line: undefined-field
    self._velocity = Vector(math.Rand(-150, 150), math.Rand(-150, 150), _INITIAL_VEL_Z)

    self._flare = ents.Create("env_flare")
    self:_UpdateFlare()
    self._flare:SetParent(self)
    self._flare:SetModelScale(0) -- hides only the ugly flare model
    self._flare:Spawn()
end

function ENT:Think()
    if self:_ShouldDie() then
        self:Remove()
        return false
    end

    local frameTime = FrameTime()

    self._velocity = LerpVector(frameTime, self._velocity, vector_origin) + _GRAVITY

    local step = self._velocity * frameTime
    if step.z > 0 then
        local ceilingDist = self:_GetCeilingDist()
        if step.z >= ceilingDist then
            step.z = ceilingDist
            self._velocity.z = 0
        end
    end

    self:SetPos(self:GetPos() + step)

    self:_UpdateFlare()

    self:NextThink(CurTime())
    return true
end

function SpawnRaiderFlare(pos)
    local flare = ents.Create("raiderflare")
    flare:SetPos(pos)
    flare:Spawn()

    return flare
end

function ENT:_GetCeilingDist()
    local tr = util.TraceLine({
        start = self:GetPos(),
        endpos = self:GetPos() + (vector_up * MAX_DIST),
        filter = {self, self._flare}
    })
    return tr.Fraction * MAX_DIST
end

function ENT:_UpdateFlare()
    local scale = math.min(0.5, 1.0 - ((CurTime() - self:GetCreationTime()) / _LIFETIME))

    self._flare:SetPos(self:GetPos())
    self._flare:SetKeyValue("scale", scale * 30.0)
end

function ENT:_ShouldDie()
    return (CurTime() - self:GetCreationTime()) > _LIFETIME
end

hook.Add("PlayerDeath", "PlayerDeathARCRaidersFlare", function(ply)
    SpawnRaiderFlare(ply:GetPos())
end)
