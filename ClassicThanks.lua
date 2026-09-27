local addonName = ...
local messages = {
    "Ayyy, that is nice! Appreciate you and your buffs!",
    "Much appreciated! You are a buffing legend.",
    "Ayy, thank you! That buff is going to help a lot.",
    "Thanks for the buff! I owe you one.",
    "Nice! Appreciate you looking out for me.",
    "Thank you kindly for the buff!",
    "You are awesome - thanks for the buff!",
    "Ayyy, appreciate the buffs! You rock.",
    "That buff is the bee's knees! Cheers, mate!",
    "You're a diamond geezer - cheers for the buff!",
    "That buff's proper mint. Nice one!",
    "Cheers, my china plate! Lovely buff.",
    "That's a bit of all right! Ta for the buff!",
    "Respect, fam - appreciate the buff!",
    "Big up yourself! Thanks for looking out.",
    "That buff's fire, no cap. Appreciate you!",
    "You're a real one. Thanks for the buff!",
    "Buff game on point! Much love!",
    "Now we're cooking! Thanks for the sweet buff!",
    "That's smooth, cool cat. Thanks for the buff!",
    "Right on! That buff's got me grooving.",
    "Groovy stuff! Appreciate the magical hookup!",
    "Cheers, legend! That buff's a beaut.",
    "Good on ya, mate! Thanks for the buff!",
    "Sweet as! Chur for the buff!",
    "Shot, bru! That's a lekker buff!",
    "That's class! Cheers a million for the buff!",
    "Beauty, eh? Thanks a bunch for the buff!",
}
local frame = CreateFrame("Frame")
local sayDraft
local db, ready, lastMessage
local pending, lastSent = {}, {}
local generation, lastAttempt, sent, errors = 0, -math.huge, 0, 0
local function Print(text) print("|cff66ddffClassicThanks:|r " .. text) end
local function PrepareSay(text)
    if db.channel ~= "SAY" or (IsInInstance and IsInInstance()) then return false end
    sayDraft = {text = text, expires = GetTime() + 30}
    Print("Thanks ready. Type /ct send, then press Enter to say it (expires in 30s).")
    return true
end
local function OpenSay()
    if not sayDraft or GetTime() > sayDraft.expires then
        sayDraft = nil; Print("No recent thanks waiting."); return
    end
    if not db.enabled or db.channel ~= "SAY" or (InCombatLockdown and InCombatLockdown()) then
        Print("Cannot prepare say right now. Leave combat and keep channel set to say."); return
    end
    local open = ChatFrameUtil and ChatFrameUtil.OpenChat or ChatFrame_OpenChat
    if not open then Print("Chat editor unavailable."); return end
    local draft = sayDraft
    -- Slash-command processing clears the editor on return. Open next frame.
    -- This only prepares text; the player must still press Enter to send.
    C_Timer.After(0, function()
        if sayDraft ~= draft or not db.enabled or db.channel ~= "SAY"
            or GetTime() > draft.expires or (InCombatLockdown and InCombatLockdown()) then return end
        local ok = pcall(open, "/say " .. draft.text)
        if ok then sayDraft = nil else Print("Chat editor blocked by client.") end
    end)
end
local function Message(spell)
    if db.message then return (db.message:gsub("%%s", function() return spell end)) end
    local index = math.random(#messages - (lastMessage and 1 or 0))
    if lastMessage and index >= lastMessage then index = index + 1 end
    lastMessage = index
    return messages[index]
end
local function Cancel()
    sayDraft = nil
    generation = generation + 1
    pending = {}
end
local function BuffDuration(spellID)
    for i = 1, 255 do
        local name, duration, id
        if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
            local a = C_UnitAuras.GetAuraDataByIndex("player", i, "HELPFUL")
            if not a then return end
            name, duration, id = a.name, a.duration, a.spellId
        elseif UnitBuff then
            local icon, count, dispel, expires, source, stealable, personal
            name, icon, count, dispel, duration, expires, source, stealable, personal, id = UnitBuff("player", i)
        end
        if not name then return end
        if id == spellID then return duration end
    end
end
local function Queue(guid, name, spellID, spell)
    local now = GetTime()
    if not db.enabled or pending[guid] or (not db.groups and IsInGroup()) then return end
    if lastSent[guid] and now - lastSent[guid] < db.cooldown then return end
    local ticket = generation
    -- Briefly allow the player's aura list to catch up with the combat log.
    C_Timer.After(0.1, function()
        if ticket ~= generation or not ready or not db.enabled then return end
        local ok, duration = pcall(BuffDuration, spellID)
        if not ok or type(duration) ~= "number" or duration <= 120 then return end
        if pending[guid] then return end
        pending[guid] = true
        C_Timer.After(1, function()
            if ticket ~= generation then return end
            pending[guid] = nil
            if not db.enabled or not ready or (not db.groups and IsInGroup()) then return end
            local time = GetTime()
            if time - lastAttempt < 3 or (lastSent[guid] and time - lastSent[guid] < db.cooldown) then return end
            local text = Message(spell)
            if #text > 255 then Print("Message too long; shorten /ct message."); return end
            local send = C_ChatInfo and C_ChatInfo.SendChatMessage or SendChatMessage
            if not send then return end
            local target = db.channel == "WHISPER" and name or nil
            lastAttempt, lastSent[guid] = time, time
            if PrepareSay(text) then return end
            if pcall(send, text, db.channel, nil, target) then sent = sent + 1
            else errors = errors + 1; Print("Chat blocked by client. /ct status for diagnostics.") end
            for key, when in pairs(lastSent) do
                if time - when > db.cooldown then lastSent[key] = nil end
            end
        end)
    end)
end
frame:SetScript("OnEvent", function(_, event, arg)
    if event == "ADDON_LOADED" and arg == addonName then
        if type(ClassicThanksDB) ~= "table" then ClassicThanksDB = {} end
        db = ClassicThanksDB
        if type(db.enabled) ~= "boolean" then db.enabled = true end
        if type(db.groups) ~= "boolean" then db.groups = true end
        if db.channel ~= "SAY" and db.channel ~= "WHISPER" then db.channel = "SAY" end
        if type(db.cooldown) ~= "number" or db.cooldown ~= db.cooldown then db.cooldown = 60 end
        db.cooldown = math.max(30, math.min(3600, db.cooldown))
        if type(db.message) ~= "string" or db.message == "" or #db.message > 200 then db.message = nil end
        Print("0.1.0-beta.2 loaded. /ct help; default channel: say.")
    elseif event == "PLAYER_ENTERING_WORLD" then
        Cancel(); ready = false
        local ticket = generation
        C_Timer.After(2, function() if generation == ticket then ready = true end end)
    elseif event == "PLAYER_LEAVING_WORLD" then
        ready = false; Cancel()
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" and ready and db and CombatLogGetCurrentEventInfo then
        local _, kind, _, guid, name, _, _, dest, _, _, _, spellID, spell, _, auraType = CombatLogGetCurrentEventInfo()
        if (kind == "SPELL_AURA_APPLIED" or kind == "SPELL_AURA_REFRESH") and auraType == "BUFF"
            and dest == UnitGUID("player") and type(guid) == "string" and guid:match("^Player%-")
            and guid ~= dest and type(name) == "string" and name ~= "" and type(spellID) == "number" then
            Queue(guid, name, spellID, spell or "the buff")
        end
    end
end)
for _, event in ipairs({"ADDON_LOADED", "PLAYER_ENTERING_WORLD", "PLAYER_LEAVING_WORLD", "COMBAT_LOG_EVENT_UNFILTERED"}) do
    frame:RegisterEvent(event)
end
SLASH_CLASSICTHANKS1 = "/ct"
SLASH_CLASSICTHANKS2 = "/classicthanks"
SlashCmdList.CLASSICTHANKS = function(input)
    if not db then return end
    local cmd, rest = input:match("^%s*(%S*)%s*(.-)%s*$"); cmd = cmd:lower()
    if cmd == "send" then OpenSay()
    elseif cmd == "on" or cmd == "off" then
        db.enabled = cmd == "on"; Cancel(); Print(db.enabled and "Enabled." or "Disabled.")
    elseif cmd == "channel" then
        local channel = rest:upper()
        if channel == "SAY" or channel == "WHISPER" then db.channel = channel; sayDraft = nil; Print("Channel: " .. channel:lower())
        else Print("Use /ct channel say | whisper") end
    elseif cmd == "groups" and (rest == "on" or rest == "off") then
        db.groups = rest == "on"; Cancel(); Print("Thanks while grouped: " .. rest)
    elseif cmd == "cooldown" then
        local seconds = tonumber(rest)
        if seconds and seconds >= 30 and seconds <= 3600 then db.cooldown = math.floor(seconds); Print("Cooldown: " .. db.cooldown .. "s")
        else Print("Use /ct cooldown 30-3600 (default 60).") end
    elseif cmd == "message" then
        if rest == "random" or rest == "default" then db.message = nil; Print("28 rotating messages enabled.")
        elseif rest ~= "" and #rest <= 200 and not rest:find("[\r\n|]") then db.message = rest; Print("Custom message saved.")
        else Print("Use /ct message <text> or /ct message random; %s inserts the buff name.") end
    elseif cmd == "preview" then Print("Preview only (not sent): " .. Message("Power Word: Fortitude"))
    elseif cmd == "status" or cmd == "" then
        Print((db.enabled and "Enabled" or "Disabled") .. "; channel " .. db.channel:lower() .. "; cooldown " .. db.cooldown .. "s.")
        Print("This login: chat requests=" .. sent .. ", errors=" .. errors .. ". Buff duration must be >120s.")
    else
        Print("/ct on | off | status | preview ; /ct channel say | whisper")
        Print("/ct send - open a pending outdoor say reply; press Enter to send.")
        Print("/ct groups on|off ; /ct cooldown 60 ; /ct message <text>|random")
    end
end
