if Config.KeyBinding then
local binds = {}

-----------------------------------------------------------------------------------------------------
-- Commands / Events --------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------

Citizen.CreateThread(function()
    
    binds = json.decode(GetResourceKvpString('emoteBinds'))
    
    if not binds then
        DebugPrint('[^2dpemotes^0] Creating binds cache')
        binds = {}
        SetResourceKvp('emoteBinds', json.encode(binds))
    else
        DebugPrint('[^2dpemotes^0] Found cached binds!')
    end

    for k, v in pairs(binds) do
        DebugPrint('[^2dpemotes^0] registering cached bind '..k)
        RegisterKeyMapping(k, '(Anim) Anim slot /'..k, 'keyboard', '')
        RegisterCommand(k, function()
            if not IsPedSittingInAnyVehicle(PlayerPedId()) then
                EmoteCommandStart(nil,{v, 0})
            end
        end)
        TriggerEvent('chat:removeSuggestion', '/'..k)
    end
end)

RegisterCommand('emotebind', function(src, args)
    if args[1] == '' or args[2] == '' then EmoteChatMessage(Config.Languages[lang]['invalidargs']) return end

    local command = args[1]
    local anim = args[2]

    local registeredCommands = GetRegisteredCommands()
    local exist = false

    for k, v in pairs(registeredCommands) do
        if v.name == command then
            exist = true
        end
    end

    if exist then EmoteChatMessage(Config.Languages[lang]['alreadyexist']) return end

    if DP.Emotes[anim] or DP.Dances[anim] or DP.PropEmotes[anim] then
        binds[command] = anim
        SetResourceKvp('emoteBinds', json.encode(binds))


        RegisterKeyMapping(command, '(Anim) Anim slot /'..command, 'keyboard', '')
        RegisterCommand(command, function()
            if not IsPedSittingInAnyVehicle(PlayerPedId()) then
                EmoteCommandStart(nil,{anim, 0})
            end
        end)
        TriggerEvent('chat:removeSuggestion', '/'..command)
    else
        EmoteChatMessage("'"..anim.."' "..Config.Languages[lang]['notvalidemote'].."")
    end
end)

RegisterCommand('emoteunbind', function(src, args)
    if binds[args[1]] then
        binds[args[1]] = nil
        SetResourceKvp('emoteBinds', json.encode(binds))
        RegisterKeyMapping(args[1], 'Deleted command', 'keyboard', '')
        RegisterCommand(args[1], function() return end)
        TriggerEvent('chat:removeSuggestion', '/'..args[1])
    else
        EmoteChatMessage(Config.Languages[lang]['nocommand'])
    end
end)

-----------------------------------------------------------------------------------------------------
------ Functions and stuff --------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------

function EmoteBindsStart()
    local string = ''
    for k, v in pairs(binds) do
        string = string..Config.Languages[lang]['binds']..' ^1/'..k..'^0 - Anim ^2'..v..'^0\n'
    end

    TriggerEvent('chat:addMessage', {
        color = {0,0,0},
        multiline = true,
        args = {"^5"..Config.Languages[lang]['binds'].."^0", string ~= '' and '\n'..string or ' '..Config.Languages[lang]['binds']}
    })
end

end
