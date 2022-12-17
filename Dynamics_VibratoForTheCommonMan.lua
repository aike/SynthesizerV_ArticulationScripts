--[[

  Synthesizer V Articulation Scripts
  Dynamics:Vibrato for the Common Man

  MIT License
  Copyright 2022, aike (@aike1000)

  https://github.com/aike/SynthesizerV_ArticulationScripts

--]]

local pointInterval = 20 / 1000  -- 20msec

function getClientInfo()
  return {
    name = SV:T("Dynamics:Vibrato for the Common Man"),
    author = "aike",
    versionNumber = 1,
    minEditorVersion = 65540
  }
end

function getTranslations(langCode)
  if langCode == "ja-jp" then
    return {
      {"Dynamics:Vibrato for the Common Man", "ダイナミクス：庶民のビブラート"},
      {"Vibrato for the Common Man", "庶民のビブラート"},
      {"Depth(Long Note)", "深さ(長い音符)"}
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
    title = SV:T("Vibrato for the Common Man"),
    message = "",
    buttons = "OkCancel",
    widgets = {
      {
        name = "sDepth", type = "Slider",
        label = "Depth",
        format = "%4.2f",
        minValue = 0,
        maxValue = 2.0,
        interval = 0.01,
        default = 0.2
      },
      {
        name = "sDepthLongNote", type = "Slider",
        label = SV:T("Depth(Long Note)"),
        format = "%4.2f",
        minValue = 0,
        maxValue = 2.0,
        interval = 0.01,
        default = 2.0
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
  local forceVibratoSec = 1.0
  local initialParam = {}
  initialParam["tF0VbrStart"] = 0.25
  initialParam["tF0VbrLeft"] = 0.2
  initialParam["tF0VbrRight"] = 0.2
  initialParam["pF0Vbr"] = 0
  initialParam["fF0Vbr"] = 5.5

  local selection = SV:getMainEditor():getSelection()
  local selectedNotes = selection:getSelectedNotes()
  if #selectedNotes == 0 then
    return
  end
  local scope = SV:getMainEditor():getCurrentGroup()
  local group = scope:getTarget()
  local automation = group:getParameter("Loudness")
  local points = automation:getAllPoints()
  local defaultParam = getNoteGroupReference(group):getVoice()
  local pointIntervalBlicks = sec2blick(pointInterval)
 
  for i = 1, #selectedNotes do
    local note = selectedNotes[i]
    local noteParam = note:getAttributes()
    local startpoint = note:getOnset()
    local endpoint = note:getEnd()
    local pStart = noteParam["tF0VbrStart"] or defaultParam["tF0VbrStart"] or initialParam["tF0VbrStart"]
    local pLeft = noteParam["tF0VbrLeft"] or defaultParam["tF0VbrLeft"] or initialParam["tF0VbrLeft"]
    local pRight = noteParam["tF0VbrRight"] or defaultParam["tF0VbrRight"] or initialParam["tF0VbrRight"]
    local pPhase = noteParam["pF0Vbr"] or defaultParam["pF0Vbr"] or initialParam["pF0Vbr"]
    local pFreq = noteParam["fF0Vbr"] or defaultParam["fF0Vbr"] or initialParam["fF0Vbr"]
    local delta = 2.0 * math.pi * pFreq * pointInterval

    automation:remove(startpoint, endpoint)
    startpoint = startpoint + sec2blick(pStart)

    local angle = pPhase
    for p = startpoint, endpoint, pointIntervalBlicks do
      local left = math.min(blick2sec(p - startpoint) / pLeft, 1.0)
      local secondFromStartpoint = blick2sec(p - startpoint)
      local right = math.min(blick2sec(endpoint - p) / pRight, 1.0)
      if secondFromStartpoint < forceVibratoSec then
        automation:add(p, math.sin(angle) * depth * left * right)
      else
        right = math.max(right, math.min((secondFromStartpoint - forceVibratoSec) / 0.2, depthLongNote))
        automation:add(p, math.sin(angle) * right)
      end
      angle = angle + delta
    end

  end

  SV:finish()
end
