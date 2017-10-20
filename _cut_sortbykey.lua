--
-- Addon       _cut_sortbykey.lua
-- StartDate   24/08/2017
--
local addon, cut  = ...

function cut.sortbykey(parent, tbl, tracker, panel)
   local a,b, cnt = nil, nil, 0

   -- reset all Pinned Point of Full loot Frames objs
   for idx, obj in pairs(tbl) do

      -- ClearAll() reset also: height, width, so we save Height and then Set it again
      local height   =  obj.frame:GetHeight()

      obj.frame:ClearAll()
      obj.frame:SetHeight(height)

      -- we hide them while we re-assemble the list
      obj.frame:SetVisible(false)
   end

   local keys  =  {}
   local idx   = nil
   for idx, _ in pairs(tbl) do table.insert(keys, idx) end
   table.sort(keys, function(a,b) return a < b  end)

   local FIRST    =  true
   local LASTOBJ  =  nil

   for idx, _ in ipairs(keys) do
      if FIRST then
         FIRST = false
         tbl[keys[idx]].frame:SetPoint("TOPLEFT",   parent,   "TOPLEFT",  cut.gui.borders.left,   cut.gui.borders.top)
         tbl[keys[idx]].frame:SetPoint("TOPRIGHT",  parent,   "TOPRIGHT", -cut.gui.borders.right, cut.gui.borders.top)

         LASTOBJ = tbl[keys[idx]].frame
         tbl[keys[idx]].frame:SetVisible(true)
      else
         tbl[keys[idx]].frame:SetPoint("TOPLEFT",   LASTOBJ, "BOTTOMLEFT",   0, cut.gui.borders.top)
         tbl[keys[idx]].frame:SetPoint("TOPRIGHT",  LASTOBJ, "BOTTOMRIGHT",  0, cut.gui.borders.top)
         tbl[keys[idx]].frame:SetVisible(true)
         LASTOBJ = tbl[keys[idx]].frame
      end
   end

   if tracker == 1 and panel == 1 then cut.shown.frames.last                 =  LASTOBJ  end
   if tracker == 1 and panel == 2 then cut.shown.todayframes.last            =  LASTOBJ  end
   if tracker == 1 and panel == 3 then cut.shown.weekframes.last             =  LASTOBJ  end
   if tracker == 2 and panel == 1 then cut.shown.currentnotorietyframes.last =  LASTOBJ  end
   if tracker == 2 and panel == 2 then cut.shown.todaynotorietyframes.last   =  LASTOBJ  end
   if tracker == 2 and panel == 3 then cut.shown.weeknotorietyframes.last    =  LASTOBJ  end

   return
end
