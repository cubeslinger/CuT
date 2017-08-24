--
-- Addon       _cut_sortbykey.lua
-- StartDate   24/08/2017
--
local addon, cut  = ...

function cut.sortbykey(parent, tbl, today)
   local a,b, cnt = nil, nil, 0

   -- reset all Pinned Point of Full loot Frames objs
   for idx, obj in pairs(tbl) do
      -- ClearAll() reset also: height, width, so we save Height and then Set it again
      local height   =  obj:GetHeight()

      obj:ClearAll()
      obj:SetHeight(height)

      -- we hide them while we re-assemble the list
      obj:SetVisible(false)
   end

   local keys  =  {}
   local idx   = nil
   for idx, _ in pairs(tbl) do table.insert(keys, idx) end
--    table.sort(keys, function(a,b) print(string.format("a=%s b=%s", a, b)) return a < b  end)
   table.sort(keys, function(a,b) return a < b  end)

   local FIRST    =  true
   local LASTOBJ  =  nil

   for idx, _ in ipairs(keys) do
--       print(string.format("FIRST=%s LASTOBJ=%s keys=%s idx=%s keys[idx]=%s", FIRST, LASTOBJ, keys, idx, keys[idx]))
      if FIRST then
         FIRST = false
         tbl[keys[idx]]:SetPoint("TOPLEFT",   parent,   "TOPLEFT",  cut.gui.borders.left,   cut.gui.borders.top)
         tbl[keys[idx]]:SetPoint("TOPRIGHT",  parent,   "TOPRIGHT", -cut.gui.borders.right, cut.gui.borders.top)

         LASTOBJ = tbl[keys[idx]]
         tbl[keys[idx]]:SetVisible(true)
      else
         tbl[keys[idx]]:SetPoint("TOPLEFT",   LASTOBJ, "BOTTOMLEFT",   0, cut.gui.borders.top)
         tbl[keys[idx]]:SetPoint("TOPRIGHT",  LASTOBJ, "BOTTOMRIGHT",  0, cut.gui.borders.top)
         tbl[keys[idx]]:SetVisible(true)
         LASTOBJ = tbl[keys[idx]]
      end
   end

   if today then
      cut.shown.todayframes.last =  LASTOBJ
   else
      cut.shown.frames.last =  LASTOBJ
   end

   cut.resizewindow(today)

--    print("EXIT SORT TABLE")

   return
end
