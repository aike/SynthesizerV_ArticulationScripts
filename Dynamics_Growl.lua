--[[

  Synthesizer V Articulation Scripts
  Dynamics:Growl

  MIT License
  Copyright 2024, aike (@aike1000)

  Special Thanks: @ELPTinySymphony and early vocaloid community

  https://github.com/aike/SynthesizerV_ArticulationScripts

--]]

-- 乱数パラメータ value = rndBase + rndRange * math.random()
local rndBase = 0.3
local rndRange = 0.7

function getClientInfo()
  return {
    name = SV:T("Dynamics:Growl"),
    author = "aike",
    versionNumber = 1,
    minEditorVersion = 65540
  }
end

function getTranslations(langCode)
  if langCode == "ja-jp" then
    return {
      {"Dynamics:Growl", "ダイナミクス：グロウル"},
      {"Growl", "グロウル"},
      {"Depth", "深さ"},
      {"Length", "長さ"},
      {"Eighth", "8分音符"},
      {"Quarter", "4分音符"},
      {"Dotted Quarter", "付点4分音符"},
      {"Half", "2分音符"},
      {"Note Length", "音符の長さ"},
      {"Crescendo", "クレッシェンド"}
    }
  end
  return {}
end

function getNoteGroupReference(noteGroup)
  local ref
  local track = SV:getMainEditor():getCurrentTrack()
  for i = 1, track:getNumGroups() do
    ref = track:getGroupReference(i)
    if ref:getTarget():getUUID() == noteGroup:getUUID() then
      break
    end
  end
  return ref
end

function sec2blick(sec)
  return SV:getProject():getTimeAxis():getBlickFromSeconds(sec)
end

function blick2sec(blick)
  return SV:getProject():getTimeAxis():getSecondsFromBlick(blick)
end

function main()
  local form = {
    title = SV:T("Growl"),
    message = "",
    buttons = "OkCancel",
    widgets = {
      {
        name = "sDepth", type = "Slider",
        label = SV:T("Depth"),
        format = "%4.2f",
        minValue = 0,
        maxValue = 1.0,
        interval = 0.01,
        default = 0.7
      },
      {
        name = "cbLength", type = "ComboBox",
        label = SV:T("Length"),
        choices = {SV:T("Eighth"), SV:T("Quarter"), SV:T("Dotted Quarter"), SV:T("Half"), SV:T("Note Length")},
        default = 4
      },
      {
        name = "ckCrescendo", type = "CheckBox",
        text = SV:T("Crescendo"),
        default = false
      }
    }
  }

  local result = SV:showCustomDialog(form)
  if not result.status then
    SV:finish()
    return
  end

  local depth = result.answers.sDepth
  local depthLongNote = result.answers.sDepthLongNote

  local selection = SV:getMainEditor():getSelection()
  local selectedNotes = selection:getSelectedNotes()
  if #selectedNotes == 0 then
    return
  end
  local scope = SV:getMainEditor():getCurrentGroup()
  local group = scope:getTarget()
  local automation = group:getParameter("pitchDelta")
  
  for i = 1, #selectedNotes do
    local note = selectedNotes[i]
    local noteParam = note:getAttributes()
    local startpoint = note:getOnset()

    local endpoint
    if result.answers.cbLength == 0 then
      endpoint = startpoint + SV.QUARTER / 2              -- 8分音符の長さ
    elseif result.answers.cbLength == 1 then
      endpoint = startpoint + SV.QUARTER                  -- 4分音符の長さ
    elseif result.answers.cbLength == 2 then
      endpoint = startpoint + SV.QUARTER + SV.QUARTER / 2 -- 付点4分音符の長さ
    elseif result.answers.cbLength == 3 then
      endpoint = startpoint + SV.QUARTER * 2              -- 2分音符の長さ
    else 
      endpoint = note:getEnd()                            -- 音符の終端
    end

    automation:remove(startpoint, endpoint)

    if depth > 0 then
      startpoint = startpoint + sec2blick(pStart)

      local pointInterval = 4 / 1000  -- 4msec
      local intervalBlicksBase = sec2blick(pointInterval)
      local intervalBlicksRange = sec2blick(pointInterval) * 2

      local cres = 1
      local sgn = 1
      local p = startpoint
      while p <= endpoint do
        if result.answers.ckCrescendo then
          cres = (p - startpoint) / (endpoint - startpoint)
        end
        automation:add(p, sgn * (rndBase + rndRange * math.random()) * depth * cres * 400)
        sgn = -sgn
        p = p + intervalBlicksBase + intervalBlicksRange * math.random()
      end
      automation:add(startpoint, 0)
      automation:add(endpoint, 0)
    end
  end

  SV:finish()
end
