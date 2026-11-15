include("shared.lua")

function ENT:Initialize()
    local flarePos = self:GetPos()
    local playerPos = LocalPlayer():GetPos()

    local dist = flarePos:Distance(playerPos)

    local sound = "arcraiders/raiderflare/close.wav"
    if dist >= 800 then
        sound = "arcraiders/raiderflare/far.wav"
    end

    -- play it at most 250 units from the player
    local dir = (playerPos - flarePos):GetNormalized()
    local soundPos = playerPos + (dir * math.min(250, dist))

    EmitSound(sound, soundPos, 0, CHAN_AUTO, 1, SNDLVL_180dB)
end

function ENT:Draw()
    self:DrawModel()
end

