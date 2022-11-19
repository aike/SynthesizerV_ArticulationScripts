--[[

  Synthesizer V Articulation Scripts
  Release:Hiccup

  MIT License
  Copyright 2022, aike (@aike1000)

  https://github.com/aike/SynthesizerV_ArticulationScripts

--]]

local hiccupDuration = 25 / 1000  -- 25msec
local hiccupPitch = 4  -- 4 semitone

function getClientInfo()
  return {
    name = SV:T("Release:Hiccup"),
    author = "aike",
    versionNumber = 1,
    minEditorVersion = 65540
  }
end

function getTranslations(langCode)
  if langCode == "ja-jp" then
    return {
      {"Release:Hiccup", "リリース：しゃくりあげ"}
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

  local hiccupBlicks = SV:getProject():getTimeAxis():getBlickFromSeconds(hiccupDuration)
  for i = 1, #selectedNotes do
    local note = selectedNotes[i];
    local originalOnset = note:getOnset();
    local originalEnd = note:getEnd();
    local fullDuration = note:getDuration();

    if fullDuration < hiccupBlicks / 2 then
      goto continue
    end
      
    note:setDuration(fullDuration - hiccupBlicks)
    local hiccup = SV:create("Note")
    hiccup:setPitch(note:getPitch() + hiccupPitch)
    hiccup:setTimeRange(note:getEnd(), hiccupBlicks)
    hiccup:setLyrics("-")
    group:addNote(hiccup)
    selection:selectNote(hiccup)

    ::continue::
  end

  SV:finish()
end
