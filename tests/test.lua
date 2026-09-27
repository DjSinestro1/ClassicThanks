local function eq(a,b) assert(a==b,tostring(a).." ~= "..tostring(b)) end
local function make(saved, legacy)
    local h={now=0,timers={},sent={},duration=3600}
    local e=setmetatable({ClassicThanksDB=saved,SlashCmdList={}}, {__index=_G})
    e.print=function() end
    e.GetTime=function() return h.now end
    e.IsInInstance=function() return not h.outdoors end
    e.ChatFrameUtil={OpenChat=function(text) h.draft=text end}
    e.IsInGroup=function() return false end
    e.UnitGUID=function() return "Player-Self" end
    e.CreateFrame=function() return {RegisterEvent=function() end,SetScript=function(_,_,f) h.handler=f end} end
    e.C_Timer={After=function(delay,f) h.timers[#h.timers+1]={h.now+delay,f} end}
    local function send(text,channel,_,target) h.sent[#h.sent+1]={text=text,channel=channel,target=target} end
    if legacy then
        e.SendChatMessage=send
        e.UnitBuff=function(_,i) if i==1 then return "Fortitude",nil,0,nil,h.duration,10000,nil,false,false,1243 end end
    else
        e.C_ChatInfo={SendChatMessage=send}
        e.C_UnitAuras={GetAuraDataByIndex=function(_,i) if i==1 then return {name="Fortitude",spellId=1243,duration=h.duration} end end}
    end
    e.CombatLogGetCurrentEventInfo=function()
        return h.now,h.kind or "SPELL_AURA_APPLIED",false,h.guid or "Player-Friend","Friend-Realm",0,0,
            h.dest or "Player-Self","Self",0,0,1243,"Fortitude",2,h.auraType or "BUFF"
    end
    function h:event(event,arg) self.handler(nil,event,arg) end
    function h:advance(dt)
        self.now=self.now+dt; local tasks=self.timers; self.timers={}
        for _,t in ipairs(tasks) do if t[1]<=self.now then t[2]() else self.timers[#self.timers+1]=t end end
    end
    function h:buff() self:event("COMBAT_LOG_EVENT_UNFILTERED"); self:advance(0.2); self:advance(1.1) end
    function h:cmd(text) e.SlashCmdList.CLASSICTHANKS(text) end
    local chunk=assert(loadfile("ClassicThanks.lua")); setfenv(chunk,e); chunk("ClassicThanks")
    h:event("ADDON_LOADED","ClassicThanks"); h:event("PLAYER_ENTERING_WORLD"); h:advance(2.1)
    h.env=e; return h
end
for _,legacy in ipairs({false,true}) do
    local h=make(nil,legacy); h:buff(); eq(#h.sent,1); eq(h.sent[1].channel,"SAY"); eq(h.sent[1].target,nil)
    h:cmd("channel whisper"); h:buff(); eq(#h.sent,1); h:advance(61); h:buff()
    eq(h.sent[2].channel,"WHISPER"); eq(h.sent[2].target,"Friend-Realm")
    assert(h.sent[1].text~=h.sent[2].text)
    h:cmd("channel raid"); eq(h.env.ClassicThanksDB.channel,"WHISPER")
    local r=make(h.env.ClassicThanksDB,legacy); r:buff(); eq(r.sent[1].channel,"WHISPER")
    r:cmd("channel SAY"); eq(r.env.ClassicThanksDB.channel,"SAY")
    for _,d in ipairs({0,15,120,121}) do
        h=make(nil,legacy); h.duration=d; h:buff(); eq(#h.sent,d>120 and 1 or 0)
    end
    for _,guid in ipairs({"Player-Self","Creature-123"}) do h=make(nil,legacy); h.guid=guid; h:buff(); eq(#h.sent,0) end
    h=make(nil,legacy); h.auraType="DEBUFF"; h:buff(); eq(#h.sent,0)
    h=make(nil,legacy); h.dest="Player-Other"; h:buff(); eq(#h.sent,0)
    h=make(nil,legacy); h:cmd("off"); h:buff(); eq(#h.sent,0)
    h=make(nil,legacy); h:event("COMBAT_LOG_EVENT_UNFILTERED"); h:event("COMBAT_LOG_EVENT_UNFILTERED"); h:advance(0.2); h:advance(1.1); eq(#h.sent,1)
    h=make(nil,legacy); h:event("COMBAT_LOG_EVENT_UNFILTERED"); h:advance(0.2); h:event("PLAYER_LEAVING_WORLD"); h:advance(2); eq(#h.sent,0)
    h=make(nil,legacy); h:cmd("message Thanks for %s!"); h:buff(); eq(h.sent[1].text,"Thanks for Fortitude!")
    h=make(nil,legacy); h.kind="SPELL_AURA_REFRESH"; h:buff(); eq(#h.sent,1)
    h=make(nil,legacy); h:event("PLAYER_ENTERING_WORLD"); h:buff(); eq(#h.sent,0)
    h=make(nil,legacy); h:cmd("preview"); eq(#h.sent,0)
    local replies={}; for i=1,400 do h:advance(61); h:buff(); replies[h.sent[#h.sent].text]=true end
    local count=0; for _ in pairs(replies) do count=count+1 end; eq(count,28)
    print("PASS ClassicThanks channel/filter/cooldown/reload/message tests (legacy="..tostring(legacy)..")")
    h=make(nil,legacy); h.outdoors=true; h:buff(); eq(#h.sent,0); h:cmd("send"); eq(h.draft,nil); h:advance(0); assert(h.draft:find("/say ",1,true)==1)
    h=make(nil,legacy); h.outdoors=true; h:buff(); h:advance(31); h:cmd("send"); eq(h.draft,nil)
    h=make(nil,legacy); h.outdoors=true; h:buff(); h:cmd("off"); h:cmd("send"); eq(h.draft,nil)
    h=make({channel="WHISPER"},legacy); h.outdoors=true; h:buff(); eq(h.sent[1].channel,"WHISPER")
    print("PASS ClassicThanks outdoor hardware-event handling")
end
