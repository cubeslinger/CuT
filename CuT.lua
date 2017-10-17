--
-- Addon       CuT.lua
-- Author      marcob@marcob.org
-- StartDate   28/05/2017
--
local addon, cut = ...

local function updateguicoordinates(win, x, y)
   if win ~= nil then
      local winname = win:GetName()
      if winname  == "cut" then
         cut.gui.x   =  cut.round(x)
         cut.gui.y   =  cut.round(y)
      end
   end
   return
end

function cut.changefontsize(newfontsize)

   local nfs   =  cut.gui.font.size + newfontsize
   if (nfs > 24)  then  nfs   =  24 end
   if (nfs < 6)   then  nfs   =  6  end

   if nfs ~=   cut.gui.font.size then
--       print(string.format("Font was %s, now is %s.", cut.gui.font.size, nfs))

      cut.gui.font.size =  nfs

      -- currencies
      local tbls  =  { cut.shown.currenttbl, cut.shown.todaytbl, cut.shown.weektbl }
      local TBL   =  {}
      local currency, tbl = nil, {}
      for _, TBL in pairs(tbls) do
         for currency, tbl in pairs(TBL) do
            tbl.frame:SetHeight(cut.gui.font.size)
            tbl.label:SetFontSize(cut.gui.font.size)
            tbl.icon:SetHeight(cut.gui.font.size)
            tbl.icon:SetWidth(cut.gui.font.size)
            tbl.value:SetFontSize(cut.gui.font.size)
         end
      end

      -- notorieties
      local tbls  =  { cut.shown.currentnotorietytbl, cut.shown.todaynotorietytbl, cut.shown.weeknotorietytbl }
      local TBL   = {}
      local notoriety, tbl = nil, {}
      for _, TBL in pairs(tbls) do
         for notoriety, tbl in pairs(TBL) do
            tbl.frame:SetHeight(cut.gui.font.size)
            tbl.label:SetFontSize(cut.gui.font.size)
            tbl.value:SetFontSize(cut.gui.font.size)
         end
      end

      cut.shown.windowtitle:SetFontSize(cut.gui.font.size)
      cut.shown.windowinfo:SetFontSize(cut.gui.font.size)
      cut.resizewindow(cut.shown.tracker, cut.shown.panel)
   end

   return
end

local function managepanels()

   local init  =  false
   local a, b  =  nil, nil
   for a,b in pairs(cut.frames.container) do init = true break end

   if init then

      cut.shown.panel   =  cut.shown.panel + 1
--       if cut.shown.panel > 6 then   cut.shown.panel = 1  end
      if cut.shown.panel > 3 then   cut.shown.panel = 1  end

      -- Hide everything
      cut.frames.container:SetVisible(false)
      cut.frames.todaycontainer:SetVisible(false)
      cut.frames.weekcontainer:SetVisible(false)
      --
      cut.frames.notorietycontainer:SetVisible(false)
      cut.frames.todaynotorietycontainer:SetVisible(false)
      cut.frames.weeknotorietycontainer:SetVisible(false)


      local table =  nil
      for _, table in ipairs( {  cut.shown.currenttbl,           cut.shown.todaytbl,           cut.shown.weektbl,
         cut.shown.currentnotorietytbl,  cut.shown.todaynotorietytbl,  cut.shown.weeknotorietytbl  }) do
            local var, val = nil
            for var, val in pairs(table) do table[var].frame:SetVisible(false) end
      end

      if cut.shown.panel == 1 and cut.shown.tracker == 1 then  table =  cut.shown.currenttbl          cut.frames.container:SetVisible(true)                 end
      if cut.shown.panel == 2 and cut.shown.tracker == 1 then  table =  cut.shown.todaytbl            cut.frames.todaycontainer:SetVisible(true)            end
      if cut.shown.panel == 3 and cut.shown.tracker == 1 then  table =  cut.shown.weektbl             cut.frames.weekcontainer:SetVisible(true)             end
      if cut.shown.panel == 1 and cut.shown.tracker == 2 then  table =  cut.shown.currentnotorietytbl cut.frames.notorietycontainer:SetVisible(true)        end
      if cut.shown.panel == 2 and cut.shown.tracker == 2 then  table =  cut.shown.todaynotorietytbl   cut.frames.todaynotorietycontainer:SetVisible(true)   end
      if cut.shown.panel == 3 and cut.shown.tracker == 2 then  table =  cut.shown.weeknotorietytbl    cut.frames.weeknotorietycontainer:SetVisible(true)    end

      local a, b, flag  =  nil, nil, false
      if table then
         for a, b in pairs (table)  do flag = true break end
         if flag then
            for var, val in pairs(table) do
               table[var].frame:SetVisible(true)
            end
         end
      end
      -- --------------------------------------------------------------------------

      cut.resizewindow(cut.shown.tracker, cut.shown.panel)
      --          cut.shown.windowinfo:SetText(string.format("%s", cut.shown.panellabel[cut.shown.panel]), true)
      local panel =  cut.shown.panel
      if cut.shown.tracker == 2 then panel = panel + 3 end
      local mylabel  =  cut.shown.panellabel[panel]
--       if cut.shown.panel == 3 then
      if panel == 3 or panel == 6 then
         mylabel = mylabel .. "<font color=\'"  .. cut.html.green .. "\'>(" ..tostring(cut.today - cut.weekday) .. ")</font>"
      end

      cut.shown.windowinfo:SetText(string.format("%s", mylabel), true)
   end

   return
end

local function changetracker()

   if cut.shown.tracker == 1 then
      cut.shown.tracker =  2
      cut.shown.panel   =  cut.shown.panel - 1
   else
      cut.shown.tracker =  1
      cut.shown.panel   =  cut.shown.panel - 1
   end

   -- change window Title
   cut.shown.windowtitle:SetText(string.format("%s", cut.html.title[cut.shown.tracker]), true)

   -- change Displayed Panel Name
   local mylabel = cut.shown.panellabel[cut.shown.panel]
   if cut.shown.tracker == 2 then mylabel = cut.shown.panellabel[cut.shown.panel + 3] end
   cut.shown.windowinfo:SetText(string.format("%s", mylabel), true)

   managepanels()

   return
end


function cut.createwindow()

   --Global context (parent frame-thing).
   local cutwindow  =  UI.CreateFrame("Frame", "cut", UI.CreateContext("cut_context"))
   if cut.gui.x == nil or cut.gui.y == nil then
      -- first run, we position in the screen center
      cutwindow:SetPoint("CENTER", UIParent, "CENTER")
   else
      -- we have coordinates
      cutwindow:SetPoint("TOPLEFT", UIParent, "TOPLEFT", cut.gui.x or 0, cut.gui.y or 0)
   end
   cutwindow:SetLayer(-1)
   cutwindow:SetWidth(cut.gui.width)
   cutwindow:SetBackgroundColor(unpack(cut.color.black))
   cutwindow:EventAttach(Event.UI.Input.Mouse.Wheel.Forward, function() cut.changefontsize(2)   end,  "cutwindow_wheel_forward")
   cutwindow:EventAttach(Event.UI.Input.Mouse.Wheel.Back,    function() cut.changefontsize(-2)  end,  "cutwindow_wheel_backward")

   -- Window Title
   local windowtitle =  UI.CreateFrame("Text", "window_title", cutwindow)
   windowtitle:SetFontSize(cut.gui.font.size )
   windowtitle:SetText(string.format("%s", cut.html.title[1]), true)
   windowtitle:SetLayer(3)
   windowtitle:SetPoint("TOPLEFT",   cutwindow, "TOPLEFT", cut.gui.borders.left, -11)
   windowtitle:EventAttach( Event.UI.Input.Mouse.Left.Click, changetracker, "Change Tracker" )
   cut.shown.windowtitle   =  windowtitle

   -- Window Panel Info
   local windowinfo =  UI.CreateFrame("Text", "window_info", cutwindow)
   windowinfo:SetFontSize(cut.gui.font.size )
   windowinfo:SetFontSize(cut.gui.font.size -2 )
   local panel =  cut.shown.panel
   if cut.shown.tracker == 2 then panel = panel + 3 end
--    local mylabel  =  cut.shown.panellabel[cut.shown.panel]
   local mylabel  =  cut.shown.panellabel[panel]
--    if cut.shown.panel == 3  or cut.shown.panel == 6 then
   if panel == 3 then
      mylabel = mylabel .. "<font color=\'"  .. cut.html.green .. "\'>(" ..tostring(cut.today - cut.weekday) .. ")</font>"
   end
   windowinfo:SetText(string.format("%s", mylabel), true)
   windowinfo:SetLayer(3)
   windowinfo:SetPoint("TOPRIGHT",   cutwindow, "TOPRIGHT", -cut.gui.borders.right, -11)
   windowinfo:EventAttach( Event.UI.Input.Mouse.Left.Click, managepanels, "Flip Panels" )
   cut.shown.windowinfo  =  windowinfo

   -- EXTERNAL CUT CONTAINER FRAME
   local externalcutframe =  UI.CreateFrame("Frame", "External_cut_frame", cutwindow)
   externalcutframe:SetPoint("TOPLEFT",     cutwindow, "TOPLEFT",     cut.gui.borders.left,    cut.gui.borders.top)
   externalcutframe:SetPoint("TOPRIGHT",    cutwindow, "TOPRIGHT",    - cut.gui.borders.right, cut.gui.borders.top)
   externalcutframe:SetPoint("BOTTOMLEFT",  cutwindow, "BOTTOMLEFT",  cut.gui.borders.left,    - cut.gui.borders.bottom)
   externalcutframe:SetPoint("BOTTOMRIGHT", cutwindow, "BOTTOMRIGHT", - cut.gui.borders.right, - cut.gui.borders.bottom)
   externalcutframe:SetBackgroundColor(unpack(cut.color.darkgrey))
   externalcutframe:SetLayer(1)

   -- MASK FRAME
   local maskframe = UI.CreateFrame("Mask", "cut_mask_frame", externalcutframe)
   maskframe:SetAllPoints(externalcutframe)

   -- Current Session Data Container
   -- CUT CONTAINER FRAME
   local cutframe =  UI.CreateFrame("Frame", "cut_frame", maskframe)
   cutframe:SetAllPoints(maskframe)
   cutframe:SetLayer(1)
   cutframe:SetBackgroundColor(unpack(cut.color.blue))
   cut.frames.container =  cutframe

   -- Whole Day Session Data Container
   local todaycutframe =  UI.CreateFrame("Frame", "cut_frame_today", maskframe)
   todaycutframe:SetAllPoints(maskframe)
   todaycutframe:SetLayer(1)
--    todaycutframe:SetBackgroundColor(unpack(cut.color.red))
   todaycutframe:SetBackgroundColor(unpack(cut.color.lightblue))
   cut.frames.todaycontainer =  todaycutframe
   cut.frames.todaycontainer:SetVisible(false)

   -- Whole Week Session Data Container
   local weekcutframe =  UI.CreateFrame("Frame", "cut_frame_week", maskframe)
   weekcutframe:SetAllPoints(maskframe)
   weekcutframe:SetLayer(1)
--    weekcutframe:SetBackgroundColor(unpack(cut.color.green))
   weekcutframe:SetBackgroundColor(unpack(cut.color.darkblue))
   cut.frames.weekcontainer =  weekcutframe
   cut.frames.weekcontainer:SetVisible(false)

   -- NOTORIETY
   local cutnotorietyframe =  UI.CreateFrame("Frame", "cut_notoriety_frame", maskframe)
   cutnotorietyframe:SetAllPoints(maskframe)
   cutnotorietyframe:SetLayer(1)
   cutnotorietyframe:SetBackgroundColor(unpack(cut.color.blue))
   cut.frames.notorietycontainer =  cutnotorietyframe
   cut.frames.notorietycontainer:SetVisible(false)

   -- Whole Day Session Data Container
   local todaycutnotorietyframe =  UI.CreateFrame("Frame", "cut_notoriety_frame_today", maskframe)
   todaycutnotorietyframe:SetAllPoints(maskframe)
   todaycutnotorietyframe:SetLayer(1)
--    todaycutnotorietyframe:SetBackgroundColor(unpack(cut.color.red))
   todaycutnotorietyframe:SetBackgroundColor(unpack(cut.color.lightblue))
   cut.frames.todaynotorietycontainer =  todaycutnotorietyframe
   cut.frames.todaynotorietycontainer:SetVisible(false)

   -- Whole Week Session Data Container
   local weekcutnotorietyframe =  UI.CreateFrame("Frame", "cut_notoriety_frame_week", maskframe)
   weekcutnotorietyframe:SetAllPoints(maskframe)
   weekcutnotorietyframe:SetLayer(1)
--    weekcutnotorietyframe:SetBackgroundColor(unpack(cut.color.green))
   weekcutnotorietyframe:SetBackgroundColor(unpack(cut.color.darkblue))
   cut.frames.weeknotorietycontainer =  weekcutnotorietyframe
   cut.frames.weeknotorietycontainer:SetVisible(false)


   -- RESIZER WIDGET
   local corner=  UI.CreateFrame("Texture", "corner", cutwindow)
   corner:SetTexture("Rift", "chat_resize_(normal).png.dds")
   corner:SetHeight(cut.gui.font.size)
   corner:SetWidth(cut.gui.font.size)
   corner:SetLayer(4)
   corner:SetPoint("BOTTOMRIGHT", cutwindow, "BOTTOMRIGHT")
   corner:EventAttach(Event.UI.Input.Mouse.Left.Down,      function()  local mouse = Inspect.Mouse()
                                                                        corner.pressed = true
                                                                        corner.basex   =  cutwindow:GetLeft()
                                                                        corner.basey   =  cutwindow:GetTop()
                                                            end,
                                                            "Event.UI.Input.Mouse.Left.Down")
   corner:EventAttach(Event.UI.Input.Mouse.Cursor.Move,    function()  if corner.pressed then
                                                                           local mouse = Inspect.Mouse()
                                                                           cut.gui.width  = cut.round(mouse.x - corner.basex)
                                                                           cut.gui.height = cut.round(mouse.y - corner.basey)
                                                                           cut.gui.window:SetWidth(cut.gui.width)
                                                                           cut.gui.window:SetHeight(cut.gui.height)
--                                                                            print(string.format("POST Width[%s] Height[%s]", cut.gui.width, cut.gui.height))
                                                                        end
                                                            end,
                                                            "Event.UI.Input.Mouse.Cursor.Move")

   corner:EventAttach(Event.UI.Input.Mouse.Left.Upoutside, function()  corner.pressed = false end, "Event.UI.Input.Mouse.Left.Upoutside")
   corner:EventAttach(Event.UI.Input.Mouse.Left.Up,        function()  corner.pressed = false end, "Event.UI.Input.Mouse.Left.Up")


   -- Enable Dragging
   Library.LibDraggable.draggify(cutwindow, updateguicoordinates)

   return cutwindow
end


local function createnewcurrencyline(currency, value, panel, id)
--    print(string.format("createnewcurrencyline: c=%s, v=%s, panel=%s, id=%s", currency, value, panel, id))
   local flag           =  ""
   local currencyframe  =  nil
   local base           =  {}
   if panel == 1 then
      flag = "_current_"
      currencyframe  =  UI.CreateFrame("Frame", "cut_currency_frame" .. flag, cut.frames.container)      -- CUT currency container
      base  =  cut.coinbase
   end
   if panel == 2 then
      flag = "_today_"
      currencyframe  =  UI.CreateFrame("Frame", "cut_currency_frame" .. flag, cut.frames.todaycontainer)
      base  =  cut.save.day
   end
   if panel == 3 then
      flag = "_week_"
      currencyframe  =  UI.CreateFrame("Frame", "cut_currency_frame" .. flag, cut.frames.weekcontainer)
      base  =  cut.save.week
   end

   currencyframe:SetHeight(cut.gui.font.size)
   currencyframe:SetLayer(2)

   local currencylabel  =  UI.CreateFrame("Text", "currency_label_" .. flag .. currency, currencyframe)
   currencylabel:SetFontSize(cut.gui.font.size)
   currencylabel:SetText(string.format("%s:", currency))
   currencylabel:SetLayer(3)
   currencylabel:SetPoint("TOPLEFT",   currencyframe, "TOPLEFT", cut.gui.borders.left, 0)

   local currencyicon = UI.CreateFrame("Texture", "currency_icon_" .. flag .. currency, currencyframe)
   if table.contains(base, currency) then currencyicon:SetTexture("Rift", (base[currency].icon or "reward_gold.png.dds")) end
   currencyicon:SetWidth(cut.gui.font.size)
   currencyicon:SetHeight(cut.gui.font.size)
   currencyicon:SetLayer(3)
   currencyicon:SetPoint("TOPRIGHT",   currencyframe, "TOPRIGHT", -cut.gui.borders.right, 4)

   if string.find(id, ',') then
      -- Mouse Hover IN    => show tooltip
      currencyicon:EventAttach(Event.UI.Input.Mouse.Cursor.In,   function() Command.Tooltip(id)    end, "Event.UI.Input.Mouse.Cursor.In_"  .. currencyicon:GetName())
      -- Mouse Hover OUT   => hide tooltip
      currencyicon:EventAttach(Event.UI.Input.Mouse.Cursor.Out,  function() Command.Tooltip(nil)   end, "Event.UI.Input.Mouse.Cursor.Out_" .. currencyicon:GetName())
   end

   if id == "coin" then
      value = cut.printmoney(value)
   else
      if value < 0   then  value = "<font color=\'"..cut.html.red.."\'>"..value.."</font>"
      else                 value = "<font color=\'"..cut.html.green.."\'>"..value.."</font>"
      end
   end

   local currencyvalue  =  UI.CreateFrame("Text", "currency_value_" .. flag .. currency, currencyframe)
   currencyvalue:SetFontSize(cut.gui.font.size )
   currencyvalue:SetText(string.format("%s", value), true)
   currencyvalue:SetLayer(3)
   currencyvalue:SetPoint("TOPRIGHT",   currencyicon, "TOPLEFT", -cut.gui.borders.right, -4)

   local t  =  {  frame=currencyframe, label=currencylabel, icon=currencyicon, value=currencyvalue }
   return t
end

local function createnewnotorietyline(notoriety, value, panel, id)

--    print(string.format("createnewnotorietyline: c=%s, v=%s, panel=%s, id=%s", notoriety, value, panel, id))

   local flag           =  ""
   local notorietyframe =  nil
   local container      =  nil

--    if panel == 4 then
--       flag = "_current_"
--       notorietyframe  =  UI.CreateFrame("Frame", "cut_notoriety" .. flag .. "frame", cut.frames.notorietycontainer)      -- CUT notoriety container
--    end
--    if panel == 5 then
--       flag = "_today_"
--       notorietyframe  =  UI.CreateFrame("Frame", "cut_notoriety" .. flag  .. "frame", cut.frames.todaynotorietycontainer)
--    end
--    if panel == 6 then
--       flag = "_week_"
--       notorietyframe  =  UI.CreateFrame("Frame", "cut_notoriety" .. flag  .. "frame", cut.frames.weeknotorietycontainer)
--    end

   if panel == 4 then   flag = "_current_"   container   =  cut.frames.notorietycontainer       end
   if panel == 5 then   flag = "_today_"     container   =  cut.frames.todaynotorietycontainer  end
   if panel == 6 then   flag = "_week_"      container   =  cut.frames.weeknotorietycontainer   end

   notorietyframe  =  UI.CreateFrame("Frame", "cut_notoriety" .. flag  .. "frame", container)
   notorietyframe:SetHeight(cut.gui.font.size)
   notorietyframe:SetLayer(2)

   --
   -- Color Faction Name by Reputation standing
   --
   local color          =  { r = .98,    g = .98,     b = .98,     }
   local desc           =  '<unknown>'
   local notorietylabel =  UI.CreateFrame("Text", "notoriety_label_" .. flag .. notoriety, notorietyframe)
   if cut.notorietybase[notoriety] then
      local notorietyid    =  cut.notorietybase[notoriety].id
      local notorietytotal =  Inspect.Faction.Detail(notorietyid).notoriety
      desc, color          =  cut.notorietycolor(notorietytotal)      
      print(string.format("notoriety(%s) total(%s) color(%s,%s,%s) desc(%s)", notoriety, notorietytotal, color.r, color.g, color.b, desc))
   end 

   notorietylabel:SetFontColor(color.r, color.g, color.b)
   notorietylabel:SetFontSize(cut.gui.font.size)
   notorietylabel:SetText(string.format("%s:", notoriety))
   notorietylabel:SetLayer(3)
   notorietylabel:SetPoint("TOPLEFT",   notorietyframe, "TOPLEFT", cut.gui.borders.left, 0)

   --
   -- Notoriety Standing Name
   --
   local notorietystanding =  UI.CreateFrame("Text", "notoriety_standing_" .. flag .. notoriety, notorietyframe)
   notorietystanding:SetFontSize(cut.gui.font.size )
   notorietystanding:SetFontColor(color.r, color.g, color.b)
   notorietystanding:SetWidth(cut.gui.font.size*4)
   notorietystanding:SetText(string.format("%s", (desc or '<unknown>')), true)
   notorietystanding:SetLayer(3)
   notorietystanding:SetPoint("TOPRIGHT",  notorietyframe, "TOPRIGHT", -cut.gui.borders.right, 0)

   --
   -- Notoriety Value
   --
   if value < 0   then  value = "<font color=\'"..cut.html.red.."\'>"..value.."</font>"
   else                 value = "<font color=\'"..cut.html.green.."\'>"..value.."</font>"
   end

   local notorietyvalue  =  UI.CreateFrame("Text", "notoriety_value_" .. flag .. notoriety, notorietyframe)
   notorietyvalue:SetFontSize(cut.gui.font.size )
   notorietyvalue:SetText(string.format("%s", value), true)
   notorietyvalue:SetLayer(3)
--    notorietyvalue:SetPoint("TOPRIGHT",  notorietyframe, "TOPRIGHT", -cut.gui.borders.right, 0)
   notorietyvalue:SetPoint("TOPRIGHT",  notorietystanding, "TOPLEFT", -cut.gui.borders.right, 0)

   local t  =  {  frame=notorietyframe, label=notorietylabel, value=notorietyvalue, standing=notorietystanding }

   return t
end


local function updatecurrencyvalue(currency, value, field, id)
--    print(string.format("updatecurrencyvalue: currency=%s, value=%s, field=%s, id=%s", currency, value, field, id))
   if id == "coin" then
      value    =  cut.printmoney(value)
   else
      if value < 0   then  value = "<font color=\'"..cut.html.red.."\'>"..value.."</font>"
      else  value = "<font color=\'"..cut.html.green.."\'>"..value.."</font>"
      end
   end

   field:SetText(string.format("%s", value), true)

   return
end

function cut.updatecurrenciesweek(currency, value, id)

   if not cut.gui.window then cut.gui.window = cut.createwindow() end

   if cut.shown.weektbl[currency] then
      updatecurrencyvalue(currency, value, cut.shown.weektbl[currency].value, id)
   else
      local t  =  {}
      t  =  createnewcurrencyline(currency, value, 3, id)
      cut.shown.weekframes.last           =  t.frame
      cut.shown.weektbl[currency]         =  t
   end

   cut.sortbykey(cut.frames.weekcontainer, cut.shown.weektbl, 1, 3)

   return
end

function cut.updatecurrenciestoday(currency, value, id)

--    print(string.format(">> cut.save.day[%s].stack=%s", currency, cut.save.day[currency].stack))

   if not cut.gui.window then cut.gui.window = cut.createwindow()  end

   if cut.shown.todaytbl[currency] then
      updatecurrencyvalue(currency, value, cut.shown.todaytbl[currency].value, id)
   else
      local t  =  {}
      t  =  createnewcurrencyline(currency, value, 2, id)
      cut.shown.todayframes.last          =  t.frame
      cut.shown.todaytbl[currency]        =  t
   end

   cut.sortbykey(cut.frames.todaycontainer, cut.shown.todaytbl, 1, 2)

--    print(string.format("<< cut.save.day[%s].stack=%s", currency, cut.save.day[currency].stack))

   return
end

function cut.updateothercurreciesview(var, val)

   if table.contains(cut.save.day, var) then
--       print(string.format("pre  cut.save.day[%s].stack=%s", var, cut.save.day[var].stack))
      cut.updatecurrenciestoday(var, (cut.save.day[var].stack + val), cut.save.day[var].id)
--       print(string.format("post cut.save.day[%s].stack=%s", var, cut.save.day[var].stack))
   else
      cut.save.day[var]   =  { stack=0, icon=cut.coinbase[var].icon, id=cut.coinbase[var].id, smax=cut.coinbase[var].stackMax }
      cut.updatecurrenciestoday(var, val, cut.save.day[var].id)
   end

   if table.contains(cut.save.week, var) then
      cut.updatecurrenciesweek(var, (val + cut.save.week[var].stack), cut.save.week[var].id)
   else
      cut.save.week[var]    =  { stack=0, icon=cut.coinbase[var].icon, id=cut.coinbase[var].id, smax=cut.coinbase[var].stackMax }
      cut.updatecurrenciesweek(var, val, cut.save.week[var].id)
   end

   return
end

function cut.updatecurrencies(currency, value, id)

   if not cut.gui.window then cut.gui.window = cut.createwindow() end

   if cut.shown.currenttbl[currency] then
      updatecurrencyvalue(currency, value, cut.shown.currenttbl[currency].value, id)
   else
      local t  =  {}
      t  =  createnewcurrencyline(currency, value, 1, id)
      cut.shown.frames.last            =  t.frame
      cut.shown.currenttbl[currency]   =  t
   end

   cut.sortbykey(cut.frames.container, cut.shown.currenttbl, 1, 1)

   cut.updateothercurreciesview(currency, value)

   return
end

local function updatenotorietyvalue(notoriey, value, field, id)

   if value < 0   then
      value = "<font color=\'"..cut.html.red.."\'>"..value.."</font>"
   else
      value = "<font color=\'"..cut.html.green.."\'>"..value.."</font>"
   end

   field:SetText(string.format("%s", value), true)

   return
end

local function updatenotorietystanding(id, factionname, standing)

   local color          =  { r = .98,    g = .98,     b = .98,     }
   local desc           =  '<unknown>'
   local notorietytotal =  Inspect.Faction.Detail(id).notoriety
   desc, color          =  cut.notorietycolor(notorietytotal)
   print(string.format("desc(%s) color(%s)", desc, color))

   factionname:SetFontColor(color.r, color.g, color.b)
   standing:SetFontColor(color.r, color.g, color.b)
   standing:SetText(desc)

   return
end

function cut.updatenotorietyweek(notoriety, value, id)

   if not cut.gui.window then cut.gui.window = cut.createwindow() end

   if cut.shown.weeknotorietytbl[notoriety] then
      updatenotorietyvalue(notoriety, value, cut.shown.weeknotorietytbl[notoriety].value, id)
      updatenotorietystanding(id, cut.shown.weeknotorietytbl[notoriety].label, cut.shown.todaynotorietytbl[notoriety].standing)
   else
      local t  =  {}
      t  =  createnewnotorietyline(notoriety, value, 6, id)
      cut.shown.weeknotorietyframes.last     =  t.frame
      cut.shown.weeknotorietytbl[notoriety]  =  t
   end

   cut.sortbykey(cut.frames.weeknotorietycontainer, cut.shown.weeknotorietytbl, 2, 3)

   return
end

function cut.updatenotorietytoday(notoriety, value, id)

   --    print(string.format(">> cut.save.notorietytoday[%s].stack=%s", notoriety, cut.save.notorietytoday[notoriety].stack))

   if not cut.gui.window then cut.gui.window = cut.createwindow()  end

   if cut.shown.todaynotorietytbl[notoriety] then
      updatenotorietyvalue(notoriety, value, cut.shown.todaynotorietytbl[notoriety].value, id)
      updatenotorietystanding(id, cut.shown.todaynotorietytbl[notoriety].label, cut.shown.todaynotorietytbl[notoriety].standing)
   else
      local t  =  {}
      t  =  createnewnotorietyline(notoriety, value, 5, id)
      cut.shown.todaynotorietyframes.last    =  t.frame
      cut.shown.todaynotorietytbl[notoriety] =  t
   end

   cut.sortbykey(cut.frames.todaynotorietycontainer, cut.shown.todaynotorietytbl, 2, 2)

   --    print(string.format("<< cut.save.notorietytoday[%s].stack=%s", notoriety, cut.save.notorietytoday[notoriety].stack))

   return
end


local function updateothernotorietyviews(var, val)

--    print(string.format("updateothernotorietyviews(var=%s, val=%s)", var, val))

   if table.contains(cut.save.notorietytoday, var) then
      --       print(string.format("pre  cut.save.notorietytoday[%s].stack=%s", var, cut.save.notorietytoday[var].stack))
      cut.updatenotorietytoday(var, (cut.save.notorietytoday[var].stack + val), cut.save.notorietytoday[var].id)
      --       print(string.format("post cut.save.notorietytoday[%s].stack=%s", var, cut.save.notorietytoday[var].stack))
   else
      cut.save.notorietytoday[var]   =  { stack=0, id=cut.notorietybase[var].id }
      cut.updatenotorietytoday(var, val, cut.save.notorietytoday[var].id)
   end

   if table.contains(cut.save.notorietyweek, var) then
      cut.updatenotorietyweek(var, (val + cut.save.notorietyweek[var].stack), cut.save.notorietyweek[var].id)
   else
      cut.save.notorietyweek[var]    =  { stack=0, id=cut.notorietybase[var].id }
      cut.updatenotorietyweek(var, val, cut.save.notorietyweek[var].id)
   end

   return
end

function cut.updatenotoriety(notoriety, value, id)

   if not cut.gui.window then cut.gui.window = cut.createwindow() end

   if cut.shown.currentnotorietytbl[notoriety] then
      updatenotorietyvalue(notoriety, value, cut.shown.currentnotorietytbl[notoriety].value, id)
   else
      local t  =  {}
      t  =  createnewnotorietyline(notoriety, value, 4, id)
--       local a, b =   nil, nil
--       for a, b in pairs (t) do
--          print(string.format("cut.updatenotorieties key=%s val=%s", a, b ))
--       end
      cut.shown.currentnotorietyframes.last     =  t.frame
      cut.shown.currentnotorietytbl[notoriety]  =  t
   end

   cut.sortbykey(cut.frames.container, cut.shown.currentnotorietytbl, 2, 1)

   updateothernotorietyviews(notoriety, value)

   return
end


-- Load/Save variable and Coinbases initialization -- begin
Command.Event.Attach(Event.Unit.Availability.Full,          cut.startmeup,       "CuT: Init Coin Base")
Command.Event.Attach(Event.Addon.SavedVariables.Load.End,   cut.loadvariables,   "CuT: Load Variables")
Command.Event.Attach(Event.Addon.SavedVariables.Save.Begin, cut.savevariables,   "CuT: Save Variables")
-- Load/Save variable and Coinbases initialization -- end
