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

function cut.lockgui(value)

   if value == true or value == false then   cut.gui.locked =  value
   else                                      cut.gui.locked =  not cut.gui.locked
   end

   local icon  =  nil

   if cut.gui.locked == true then
      icon  =  "lock_on.png.dds"
      Library.LibDraggable.undraggify(cut.gui.window, updateguicoordinates)
   else
      icon  =  "lock_off.png.dds"
      Library.LibDraggable.draggify(cut.gui.window, updateguicoordinates)
   end

   cut.shown.lockbutton:SetTexture("Rift", icon)

--    print(string.format("value=(%s) cut.gui.locked=(%s)", value, cut.gui.locked))

   return
end

local function showtitlebar()

   local show  =  not cut.shown.titleframe:GetVisible()
   cut.shown.titleframe:SetVisible(show)

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
            tbl.standing:SetFontSize(cut.gui.font.size)
            tbl.percent:SetFontSize(cut.gui.font.size * .75)
         end
      end

      -- window title
      cut.shown.windowtitle:SetFontSize(cut.gui.font.size*.75)
      cut.shown.cutversion:SetFontSize(cut.round(cut.gui.font.size/2))
      cut.shown.windowinfo:SetFontSize(cut.gui.font.size*.75)
      cut.shown.titleicon:SetHeight(cut.gui.font.size*.75)
      cut.shown.titleicon:SetWidth(cut.gui.font.size*.75)
      cut.shown.corner:SetHeight(cut.gui.font.size)
      cut.shown.corner:SetWidth(cut.gui.font.size)
      cut.shown.lockbutton:SetHeight(cut.gui.font.size)
      cut.shown.lockbutton:SetWidth(cut.gui.font.size)
      cut.shown.iconizebutton:SetHeight(cut.gui.font.size)
      cut.shown.iconizebutton:SetWidth(cut.gui.font.size)
      cut.resizewindow(cut.shown.tracker, cut.shown.panel)
   end

   return
end

local function managepanels(tracker2set, panel2set)

   local init  =  false
   local a, b  =  nil, nil
   for a,b in pairs(cut.frames.container) do init = true break end

   if init then

      if tracker2set ~= nil and panel2set ~= nil then
         cut.shown.tracker =  tracker2set
         cut.shown.panel   =  panel2set
      else
         cut.shown.panel   =  cut.shown.panel + 1
         if cut.shown.panel > 3 then   cut.shown.panel = 1  end
      end

      -- Hide everything
      cut.frames.container:SetVisible(false)
      cut.frames.todaycontainer:SetVisible(false)
      cut.frames.weekcontainer:SetVisible(false)
      --
      cut.frames.notorietycontainer:SetVisible(false)
      cut.frames.todaynotorietycontainer:SetVisible(false)
      cut.frames.weeknotorietycontainer:SetVisible(false)

      local table =  nil
      for _, table in ipairs( {  cut.shown.currenttbl, cut.shown.todaytbl, cut.shown.weektbl, cut.shown.currentnotorietytbl, cut.shown.todaynotorietytbl, cut.shown.weeknotorietytbl  }) do
         local var, val = nil
         for var, val in pairs(table) do
            table[var].frame:SetVisible(false)
         end
      end

      -- Show the Containing Frame...
      if cut.shown.panel == 1 and cut.shown.tracker == 1 then  table =  cut.shown.currenttbl          cut.frames.container:SetVisible(true)                 end
      if cut.shown.panel == 2 and cut.shown.tracker == 1 then  table =  cut.shown.todaytbl            cut.frames.todaycontainer:SetVisible(true)            end
      if cut.shown.panel == 3 and cut.shown.tracker == 1 then  table =  cut.shown.weektbl             cut.frames.weekcontainer:SetVisible(true)             end
      if cut.shown.panel == 1 and cut.shown.tracker == 2 then  table =  cut.shown.currentnotorietytbl cut.frames.notorietycontainer:SetVisible(true)        end
      if cut.shown.panel == 2 and cut.shown.tracker == 2 then  table =  cut.shown.todaynotorietytbl   cut.frames.todaynotorietycontainer:SetVisible(true)   end
      if cut.shown.panel == 3 and cut.shown.tracker == 2 then  table =  cut.shown.weeknotorietytbl    cut.frames.weeknotorietycontainer:SetVisible(true)    end

      -- ..and all its contained frames.
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

      local panel =  cut.shown.panel

--       if panel2set == nil then
         if cut.shown.tracker == 2 then panel = panel + 3 end
--       end

      local mylabel  =  cut.shown.panellabel[panel]
      if panel == 3 or panel == 6 then
         mylabel = mylabel .. "<font color=\'"  .. cut.html.green .. "\'>(" ..tostring(cut.today - cut.weekday) .. ")</font>"
      end

      cut.shown.windowinfo:SetText(string.format("%s", mylabel), true)
   end

   return
end


function cut.changetracker(tracker2set, panel2set)

   local icon  =  nil

   if tracker2set ~= nil and panel2set ~= nil then

--       print(string.format("cut.changetracker(tracker2set=(%s), panel2set=(%s))", tracker2set, panel2set))

      cut.shown.tracker =  tracker2set
      cut.shown.panel   =  panel2set

      if tracker2set == 1 then
         icon  =  "CharacterSheet_I1C4.dds"
      else
         icon  =  "AuctionHouse_I91.dds"
      end
   else
      if cut.shown.tracker == 1 then
         cut.shown.tracker =  2
         cut.shown.panel   =  cut.shown.panel - 1
         icon  =  "CharacterSheet_I1C4.dds"
      else
         cut.shown.tracker =  1
         cut.shown.panel   =  cut.shown.panel - 1
         icon  =  "AuctionHouse_I91.dds"
      end
   end

   -- change window Title
   cut.shown.windowtitle:SetText(string.format("%s", cut.html.title[cut.shown.tracker]), true)

   -- change Displayed Panel Name
   local mylabel = cut.shown.panellabel[cut.shown.panel]
   if cut.shown.tracker == 2 and panel2set == nil then mylabel = cut.shown.panellabel[cut.shown.panel + 3] end
   cut.shown.windowinfo:SetText(string.format("%s", mylabel), true)

   -- change corner icon
   cut.shown.corner:SetTexture("Rift", icon)

   managepanels(tracker2set, panel2set)

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
   cutwindow:EventAttach(Event.UI.Input.Mouse.Wheel.Forward, function() cut.changefontsize(1)   end,  "cutwindow_wheel_forward")
   cutwindow:EventAttach(Event.UI.Input.Mouse.Wheel.Back,    function() cut.changefontsize(-1)  end,  "cutwindow_wheel_backward")


   local titleframe =  UI.CreateFrame("Frame", "Cut_title_frame", cutwindow)
   titleframe:SetPoint("TOPLEFT",     cutwindow, "TOPLEFT",    0, -(cut.gui.font.size*1.5)+4)  -- move up, outside externalframe
   titleframe:SetPoint("TOPRIGHT",    cutwindow, "TOPRIGHT",   0, -(cut.gui.font.size*1.5)+4)  -- move up, outside externalframe
   titleframe:SetHeight(cut.gui.font.size*1.5)
   titleframe:SetBackgroundColor(unpack(cut.color.deepblack))
   titleframe:SetLayer(1)
   cut.shown.titleframe =  titleframe

      -- Title Icon
      titleicon = UI.CreateFrame("Texture", "cut_tile_icon", titleframe)
      titleicon:SetTexture("Rift", "loot_gold_coins.dds")
      titleicon:SetHeight(cut.gui.font.size)
      titleicon:SetWidth(cut.gui.font.size)
      titleicon:SetLayer(3)
      titleicon:SetPoint("CENTERLEFT", titleframe, "CENTERLEFT", cut.gui.borders.left*2, 0)
      cut.shown.titleicon   =  titleicon

      -- Window Title
      local windowtitle =  UI.CreateFrame("Text", "window_title", titleframe)
      windowtitle:SetFontSize(cut.gui.font.size)
--       windowtitle:SetText(string.format("%s", cut.html.title[1]), true)
      windowtitle:SetText(string.format("%s", cut.html.title[cut.shown.tracker]), true)
      windowtitle:SetLayer(3)
      windowtitle:SetPoint("CENTERLEFT",   titleicon, "CENTERRIGHT", cut.gui.borders.left*2, 0)
      windowtitle:EventAttach( Event.UI.Input.Mouse.Left.Click, function() cut.changetracker(nil, nil) end, "Change Tracker" )
      cut.shown.windowtitle   =  windowtitle

      -- CuT Version
      local titleversion =  UI.CreateFrame("Text", "cut_title_version", titleframe)
      titleversion:SetFontSize(cut.round(cut.gui.font.size * .75))
      titleversion:SetText(string.format("%s", 'v.'..cut.version), true)
      titleversion:SetLayer(3)
      titleversion:SetPoint("CENTERLEFT", windowtitle, "CENTERRIGHT", cut.gui.borders.left*2, 0)
      titleversion:EventAttach( Event.UI.Input.Mouse.Left.Click, function() cut.changetracker(nil, nil) end, "Change Tracker" )
      cut.shown.cutversion   =  titleversion

      -- Iconize Button
      local iconizebutton = UI.CreateFrame("Texture", "cut_iconize_button", titleframe)
      iconizebutton:SetTexture("Rift", "AlertTray_I54.dds")
      iconizebutton:SetHeight(cut.gui.font.size)
      iconizebutton:SetWidth(cut.gui.font.size)
      iconizebutton:SetLayer(3)
      iconizebutton:EventAttach( Event.UI.Input.Mouse.Left.Click, function() cut.showhidewindow() end, "CuT Iconize Button Pressed" )
      iconizebutton:SetPoint("CENTERRIGHT",   titleframe, "CENTERRIGHT", -cut.gui.borders.right, 0)
      cut.shown.iconizebutton =  iconizebutton

      -- Lock Button
      local lockbutton = UI.CreateFrame("Texture", "cut_lock_gui_button", titleframe)
      local icon  =  nil
      if cut.gui.locked then  icon  =  "lock_on.png.dds"
      else                    icon  =  "lock_off.png.dds"
      end
      lockbutton:SetTexture("Rift", icon)
      lockbutton:SetHeight(cut.gui.font.size)
      lockbutton:SetWidth(cut.gui.font.size)
      lockbutton:SetLayer(3)
      lockbutton:EventAttach( Event.UI.Input.Mouse.Left.Click, function() cut.lockgui() end, "CuT Lock Gui Button Pressed" )
      lockbutton:SetPoint("CENTERRIGHT",   iconizebutton, "CENTERRIGHT", -cut.gui.font.size, 0)
      cut.shown.lockbutton =  lockbutton

      -- Window Panel Info
      local windowinfo =  UI.CreateFrame("Text", "window_info", titleframe)
      windowinfo:SetFontSize(cut.gui.font.size)
      local panel =  cut.shown.panel
      if cut.shown.tracker == 2 then panel = panel + 3 end
      local mylabel  =  cut.shown.panellabel[panel]
      if panel == 3 or panel == 6 then
         mylabel = mylabel .. "<font color=\'"  .. cut.html.green .. "\'>(" ..tostring(cut.today - cut.weekday) .. ")</font>"
      end
      windowinfo:SetText(string.format("%s", mylabel), true)
      windowinfo:SetLayer(3)
      windowinfo:SetPoint("CENTERRIGHT",   lockbutton, "CENTERLEFT", -cut.gui.borders.right*2, 0)
      windowinfo:EventAttach( Event.UI.Input.Mouse.Left.Click, function() managepanels(nil, nil) end, "Flip Panels" )
      cut.shown.windowinfo  =  windowinfo

   -- EXTERNAL CUT CONTAINER FRAME
   local externalcutframe =  UI.CreateFrame("Frame", "External_cut_frame", cutwindow)
--    externalcutframe:SetPoint("TOPLEFT",     titleframe, "BOTTOMLEFT",     cut.gui.borders.left,    cut.gui.borders.top)
--    externalcutframe:SetPoint("TOPRIGHT",    titleframe, "BOTTOMRIGHT",    - cut.gui.borders.right, cut.gui.borders.top)
   externalcutframe:SetPoint("TOPLEFT",     titleframe, "BOTTOMLEFT",     cut.gui.borders.left,    0)
   externalcutframe:SetPoint("TOPRIGHT",    titleframe, "BOTTOMRIGHT",    - cut.gui.borders.right, 0)
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
   cut.frames.container =  cutframe

   -- Whole Day Session Data Container
   local todaycutframe =  UI.CreateFrame("Frame", "cut_frame_today", maskframe)
   todaycutframe:SetAllPoints(maskframe)
   todaycutframe:SetLayer(1)
   cut.frames.todaycontainer =  todaycutframe
   cut.frames.todaycontainer:SetVisible(false)

   -- Whole Week Session Data Container
   local weekcutframe =  UI.CreateFrame("Frame", "cut_frame_week", maskframe)
   weekcutframe:SetAllPoints(maskframe)
   weekcutframe:SetLayer(1)
   cut.frames.weekcontainer =  weekcutframe
   cut.frames.weekcontainer:SetVisible(false)

   -- NOTORIETY
   local cutnotorietyframe =  UI.CreateFrame("Frame", "cut_notoriety_frame", maskframe)
   cutnotorietyframe:SetAllPoints(maskframe)
   cutnotorietyframe:SetLayer(1)
   cut.frames.notorietycontainer =  cutnotorietyframe
   cut.frames.notorietycontainer:SetVisible(false)

   -- Whole Day Session Data Container
   local todaycutnotorietyframe =  UI.CreateFrame("Frame", "cut_notoriety_frame_today", maskframe)
   todaycutnotorietyframe:SetAllPoints(maskframe)
   todaycutnotorietyframe:SetLayer(1)
   cut.frames.todaynotorietycontainer =  todaycutnotorietyframe
   cut.frames.todaynotorietycontainer:SetVisible(false)

   -- Whole Week Session Data Container
   local weekcutnotorietyframe =  UI.CreateFrame("Frame", "cut_notoriety_frame_week", maskframe)
   weekcutnotorietyframe:SetAllPoints(maskframe)
   weekcutnotorietyframe:SetLayer(1)
   cut.frames.weeknotorietycontainer =  weekcutnotorietyframe
   cut.frames.weeknotorietycontainer:SetVisible(false)

   -- RESIZER WIDGET
   local corner=  UI.CreateFrame("Texture", "corner", cutwindow)
--    corner:SetTexture("Rift", "chat_resize_(normal).png.dds")
--    corner:SetTexture("Rift", "chat_resize_(over).png.dds")
   corner:SetTexture("Rift", "AuctionHouse_I91.dds")
   corner:SetHeight(cut.gui.font.size)
   corner:SetWidth(cut.gui.font.size)
   corner:SetLayer(4)
   corner:SetPoint("BOTTOMRIGHT", cutwindow, "BOTTOMRIGHT", cut.gui.font.size/2, cut.gui.font.size/2)
   corner:EventAttach(Event.UI.Input.Mouse.Right.Down,      function()  local mouse = Inspect.Mouse()
                                                                        corner.pressed = true
                                                                        corner.basex   =  cutwindow:GetLeft()
                                                                        corner.basey   =  cutwindow:GetTop()

                                                                        showtitlebar()
                                                            end,
                                                            "Event.UI.Input.Mouse.Right.Down")
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

   corner:EventAttach(Event.UI.Input.Mouse.Right.Upoutside, function()  corner.pressed = false end, "Event.UI.Input.Mouse.Right.Upoutside")
   corner:EventAttach(Event.UI.Input.Mouse.Right.Up,        function()  corner.pressed = false end, "Event.UI.Input.Mouse.Right.Up")
   corner:EventAttach(Event.UI.Input.Mouse.Left.Click, function() cut.changetracker(nil, nil) end, "Change Tracker" )
   cut.shown.corner  =  corner

--    -- Enable Dragging
--    Library.LibDraggable.draggify(cutwindow, updateguicoordinates)

--    lockgui(cut.gui.locked)

   return cutwindow
end


local function createnewcurrencyline(currency, value, panel, id)
   local flag           =  ""
--    local currencyframe  =  nil
   local base           =  {}
   local container      =  nil
   if panel == 1 then   flag = "_current_"   container   =  cut.frames.container       base  =  cut.coinbase   end
   if panel == 2 then   flag = "_today_"     container   =  cut.frames.todaycontainer  base  =  cut.save.day   end
   if panel == 3 then   flag = "_week_"      container   =  cut.frames.weekcontainer   base  =  cut.save.week  end

   local currencyframe  =  UI.CreateFrame("Frame", "cut_currency_frame" .. flag, container)
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
   currencyicon:SetLayer(5)
   currencyicon:SetPoint("TOPRIGHT",   currencyframe, "TOPRIGHT", -cut.gui.borders.right, 4)

   -- come currencies don't have a Toooltip, usually the don't
   -- have a "," in their ID, like: "coin", "affinity", "credits",
   -- etc...
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
   currencyvalue:SetLayer(5)
   currencyvalue:SetPoint("TOPRIGHT",   currencyicon, "TOPLEFT", -cut.gui.borders.right, -4)
   cut.attachTT(currencyvalue, currency, panel, id)

   local t  =  {  frame=currencyframe, label=currencylabel, icon=currencyicon, value=currencyvalue }

   return t
end

local function createnewnotorietyline(notoriety, value, panel, id)

   local flag           =  ""
   local notorietyframe =  nil
   local container      =  nil

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
      desc, color, percent =  cut.notorietycolor(notorietytotal)
   end
   notorietylabel:SetFontSize(cut.gui.font.size)
   notorietylabel:SetText(string.format("%s:", notoriety))
   notorietylabel:SetLayer(3)
   notorietylabel:SetPoint("CENTERLEFT",   notorietyframe, "CENTERLEFT", cut.gui.borders.left, 0)
   --
   -- Notoriety Standing Name
   --
   local notorietystanding =  UI.CreateFrame("Text", "notoriety_standing_" .. flag .. notoriety, notorietyframe)
   notorietystanding:SetFontSize(cut.gui.font.size )
   notorietystanding:SetFontColor(color.r, color.g, color.b)
   notorietystanding:SetWidth(cut.gui.font.size*5)
   notorietystanding:SetText(string.format("%s", (desc or '<unknown>')), true)
   notorietystanding:SetLayer(3)
   notorietystanding:SetPoint("CENTERRIGHT",  notorietyframe, "CENTERRIGHT", -cut.gui.borders.right, 0)
   --
   -- Notoriety Percent
   --
   local notorietypercent =  UI.CreateFrame("Text", "notoriety_percent_" .. flag .. notoriety, notorietyframe)
   notorietypercent:SetFontSize(cut.gui.font.size * .75)
--    notorietypercent:SetFontColor(color.r, color.g, color.b)
   notorietypercent:SetWidth(cut.gui.font.size*3)
   notorietypercent:SetText(string.format("%s%%", percent), true)
   notorietypercent:SetLayer(3)
   notorietypercent:SetPoint("CENTERRIGHT",  notorietystanding, "CENTERLEFT", -cut.gui.borders.right, 0)
   --
   -- Notoriety Value
   --
--    if value < 0   then  value = "<font color=\'"..cut.html.red.."\'>"..value.."</font>"
--    else                 value = "<font color=\'"..cut.html.green.."\'>"..value.."</font>"
--    end

   local notorietyvalue  =  UI.CreateFrame("Text", "notoriety_value_" .. flag .. notoriety, notorietyframe)
   notorietyvalue:SetFontSize(cut.gui.font.size )
   notorietyvalue:SetFontColor(unpack(cut.color.green))
   notorietyvalue:SetText(string.format("%s", value), true)
   notorietyvalue:SetLayer(3)
   notorietyvalue:SetPoint("CENTERRIGHT",  notorietypercent, "CENTERLEFT", -cut.gui.borders.right, 0)

   local t  =  {  frame=notorietyframe, label=notorietylabel, value=notorietyvalue, standing=notorietystanding, percent=notorietypercent }

   return t
end


local function updatecurrencyvalue(currency, value, field, id)

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

   return
end

function cut.updatecurrencies(currency, value, id)

   if not cut.gui.window then cut.gui.window = cut.createwindow() end

   -- Session
   if cut.shown.currenttbl[currency] then
      updatecurrencyvalue(currency, value, cut.shown.currenttbl[currency].value, id)
   else
      local t  =  {}
      t  =  createnewcurrencyline(currency, value, 1, id)
      cut.shown.frames.last            =  t.frame
      cut.shown.currenttbl[currency]   =  t
   end

   cut.sortbykey(cut.frames.container, cut.shown.currenttbl, 1, 1)

   -- Today
   if table.contains(cut.save.day, currency) then
      cut.updatecurrenciestoday(currency, (cut.save.day[currency].stack + value), cut.save.day[currency].id)
   else
      cut.save.day[currency]   =  { stack=0, icon=cut.coinbase[currency].icon, id=cut.coinbase[currency].id, smax=cut.coinbase[currency].stackMax }
      cut.updatecurrenciestoday(currency, value, cut.save.day[currency].id)
   end

   -- Week
   if table.contains(cut.save.week, currency) then
      cut.updatecurrenciesweek(currency, (value + cut.save.week[currency].stack), cut.save.week[currency].id)
   else
      cut.save.week[currency]    =  { stack=0, icon=cut.coinbase[currency].icon, id=cut.coinbase[currency].id, smax=cut.coinbase[currency].stackMax }
      cut.updatecurrenciesweek(currency, value, cut.save.week[currency].id)
   end

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

local function updatenotorietystanding(id, factionname, standing, perc)

   local color          =  { r = .98,    g = .98,     b = .98,     }
   local desc           =  '<unknown>'
   local percent        =  0
   local notorietytotal =  Inspect.Faction.Detail(id).notoriety

   desc, color, percent =  cut.notorietycolor(notorietytotal)

   standing:SetFontColor(color.r, color.g, color.b)
   standing:SetText(desc)

   perc:SetText(string.format("%s%%", percent))
   perc:SetFontColor(color.r, color.g, color.b)

   return
end

function cut.updatenotorietyweek(notoriety, value, id)

   if not cut.gui.window then cut.gui.window = cut.createwindow() end

   if cut.shown.weeknotorietytbl[notoriety] then
      updatenotorietyvalue(notoriety, value, cut.shown.weeknotorietytbl[notoriety].value, id)
      updatenotorietystanding(   id,
                                 cut.shown.weeknotorietytbl[notoriety].label,
                                 cut.shown.weeknotorietytbl[notoriety].standing,
                                 cut.shown.weeknotorietytbl[notoriety].percent
                             )
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

   if not cut.gui.window then cut.gui.window = cut.createwindow()  end

   if cut.shown.todaynotorietytbl[notoriety] then
      updatenotorietyvalue(notoriety, value, cut.shown.todaynotorietytbl[notoriety].value, id)
      updatenotorietystanding(   id,
                                 cut.shown.todaynotorietytbl[notoriety].label,
                                 cut.shown.todaynotorietytbl[notoriety].standing,
                                 cut.shown.todaynotorietytbl[notoriety].percent
                             )
   else
      local t  =  {}
      t  =  createnewnotorietyline(notoriety, value, 5, id)
      cut.shown.todaynotorietyframes.last    =  t.frame
      cut.shown.todaynotorietytbl[notoriety] =  t
   end

   cut.sortbykey(cut.frames.todaynotorietycontainer, cut.shown.todaynotorietytbl, 2, 2)

   return
end

function cut.updatenotoriety(notoriety, value, id)

   if not cut.gui.window then cut.gui.window = cut.createwindow() end

   if cut.shown.currentnotorietytbl[notoriety] then
      updatenotorietyvalue(   notoriety,
                              value,
                              cut.shown.currentnotorietytbl[notoriety].value,
                              id
                          )
   else
      local t  =  {}
      t  =  createnewnotorietyline(notoriety, value, 4, id)
      cut.shown.currentnotorietyframes.last     =  t.frame
      cut.shown.currentnotorietytbl[notoriety]  =  t
   end

   cut.sortbykey(cut.frames.container, cut.shown.currentnotorietytbl, 2, 1)

   if table.contains(cut.save.notorietytoday, notoriety) then
      cut.updatenotorietytoday(notoriety, (cut.save.notorietytoday[notoriety].stack + value), cut.save.notorietytoday[notoriety].id)
   else
      cut.save.notorietytoday[notoriety]   =  { stack=0, id=cut.notorietybase[notoriety].id }
      cut.updatenotorietytoday(notoriety, value, cut.save.notorietytoday[notoriety].id)
   end

   if table.contains(cut.save.notorietyweek, notoriety) then
      cut.updatenotorietyweek(notoriety, (value + cut.save.notorietyweek[notoriety].stack), cut.save.notorietyweek[notoriety].id)
   else
      cut.save.notorietyweek[notoriety]    =  { stack=0, id=cut.notorietybase[notoriety].id }
      cut.updatenotorietyweek(notoriety, value, cut.save.notorietyweek[notoriety].id)
   end

   return
end

-- Load/Save variable and Coinbases initialization -- begin
Command.Event.Attach(Event.Unit.Availability.Full,          cut.startmeup,       "CuT: Init Coin Base")
Command.Event.Attach(Event.Addon.SavedVariables.Load.End,   cut.loadvariables,   "CuT: Load Variables")
Command.Event.Attach(Event.Addon.SavedVariables.Save.Begin, cut.savevariables,   "CuT: Save Variables")
-- Load/Save variable and Coinbases initialization -- end
