--[[

  Synthesizer V Articulation Scripts
  Transition:Preparation

  MIT License
  Copyright 2022, aike (@aike1000)

  https://github.com/aike/SynthesizerV_ArticulationScripts

--]]

local preparationTime = 50 / 1000  -- 50msec

local preparationBlicks
local flatList

function getClientInfo()
  return {
    name = SV:T("Transition:Preparation"),
    author = "aike",
    versionNumber = 1,
    minEditorVersion = 65540
  }
end

function getTranslations(langCode)
  if langCode == "ja-jp" then
    return {
      {"Transition:Preparation", "トランジション：プレパレーション"}
    }
  end
  return {}
end

function main()
  preparationBlicks = SV:getProject():getTimeAxis():getBlickFromSeconds(preparationTime)
   makeFlatList()
  setOvershoot()
  SV:finish()
end
  
function setOvershoot()
  local selection = SV:getMainEditor():getSelection()
  local selectedNotes = selection:getSelectedNotes()
  for i = #selectedNotes, 1, -1 do
    process(selectedNotes[i])
  end

  local selectedGroups = selection:getSelectedGroups()
  for i = 1, #selectedGroups do
    local group = selectedGroups[i]:getTarget() 
    for j = group:getNumNotes(), 1, -1 do
      process(group:getNote(j))
    end
  end
end

function process(note)
  local previousNote = findPreviousNote(note)
  if previousNote then
    local noteNo = note:getPitch()
    local previousNoteNo = previousNote:getPitch();
    if noteNo == previousNoteNo then
      return
    end

    local originalOnset = note:getOnset();
    local originalEnd = note:getEnd();
    local fullDuration = note:getDuration();
    if fullDuration < preparationBlicks * 2 then
      return
    end
     
    local newNote = note:clone()
    note:setDuration(preparationBlicks)
    newNote:setTimeRange(note:getEnd(), fullDuration - preparationBlicks)
    newNote:setLyrics("-")
    if noteNo > previousNoteNo then
      note:setPitch(previousNoteNo - 1)
    else 
      note:setPitch(previousNoteNo + 1)
    end
    note:getParent():addNote(newNote)

    local selection = SV:getMainEditor():getSelection()
    if note:getParent():getName() == "main" then
      selection:selectNote(newNote)
    end
  end
end


function compareNotes(n1, n2)
  return n1.onset < n2.onset
end

-- グループで階層化されているノートと通常のノートをマージしてひとつのリストにする
function makeFlatList()
  flatList = {}
  local track = SV:getMainEditor():getCurrentTrack()
  for i = 1, track:getNumGroups() do
    local ref = track:getGroupReference(i)
    local group = ref:getTarget()
    for j = 1, group:getNumNotes() do
      local note = group:getNote(j)
      table.insert(flatList, {note = note, onset = ref:getOnset() + note:getOnset()})
    end
  end
  table.sort(flatList, compareNotes)
  for i = 1, #flatList do
    local noteno = flatList[i].note:getPitch()
  end
end

function findPreviousNote(note)
  local parentID = note:getParent():getUUID()
  for i = 2, #flatList do
    if parentID == flatList[i].note:getParent():getUUID() 
    and note:getIndexInParent() == flatList[i].note:getIndexInParent() then
      return flatList[i - 1].note
    end
  end
  return nil
end

