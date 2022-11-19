--[[

  Synthesizer V Articulation Scripts
  Release:Fall

  MIT License
  Copyright 2022, aike (@aike1000)

  https://github.com/aike/SynthesizerV_ArticulationScripts

--]]

local fallDuration = 100 / 1000  -- 100msec
local fallPitch = 1  -- 1 semitone

function getClientInfo()
  return {
    name = SV:T("Release:Fall"),
    author = "aike",
    versionNumber = 1,
    minEditorVersion = 65540
  }
end

function getTranslations(langCode)
  if langCode == "ja-jp" then
    return {
      {"Release:Fall", "リリース：フォール"}
    }
  end
  return {}
end


function main()
  local selection = SV:getMainEditor():getSelection()
  local selectedNotes = selection:getSelectedNotes()
  if #selectedNotes == 0 then
    return
  end
  local scope = SV:getMainEditor():getCurrentGroup()
  local group = scope:getTarget()

  local fallBlicks = SV:getProject():getTimeAxis():getBlickFromSeconds(fallDuration)
  for i = 1, #selectedNotes do
    local note = selectedNotes[i];
    local originalOnset = note:getOnset();
    local originalEnd = note:getEnd();
    local fullDuration = note:getDuration();

    if fullDuration < fallBlicks / 2 then
      goto continue
    end
      
    note:setDuration(fullDuration - fallBlicks)
    local fall = SV:create("Note")
    fall:setPitch(note:getPitch() - fallPitch)
    fall:setTimeRange(note:getEnd(), fallBlicks)
    fall:setLyrics("-")
    group:addNote(fall)
    selection:selectNote(fall)

    ::continue::
  end

  SV:finish()
end
