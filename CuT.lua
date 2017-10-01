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

      local tbls  =  { cut.shown.currenttbl, cut.shown.todaytbl, cut.shown.weektbl }

      for _, TBL in pairs(tbls) do
         for currency, tbl in pairs(TBL) do
            tbl.frame:SetHeight(cut.gui.font.size)
            tbl.label:SetFontSize(cut.gui.font.size)
            tbl.icon:SetHeight(cut.gui.font.size)
            tbl.icon:SetWidth(cut.gui.font.size)
            tbl.value:SetFontSize(cut.gui.font.size)
         end
      end

      cut.shown.windowtitle:SetFontSize(cut.gui.font.size)
      cut.shown.windowinfo:SetFontSize(cut.gui.font.size)
      cut.resizewindow(cut.shown.panel)
   end

   return
end

-- local function createwindow()
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
--    cutwindow:SetBackgroundColor(0, 0, 0, .5)
   cutwindow:SetBackgroundColor(unpack(cut.color.black))
   cutwindow:EventAttach(Event.UI.Input.Mouse.Wheel.Forward, function() cut.changefontsize(2)   end,  "cutwindow_wheel_forward")
   cutwindow:EventAttach(Event.UI.Input.Mouse.Wheel.Back,    function() cut.changefontsize(-2)  end,  "cutwindow_wheel_backward")


   -- Window Title
--    local title =  "<font color=\'"..cut.html.green.."\'>C</font><font color=\'"..cut.html.white.."\'>u</font><font color=\'"..cut.html.red.."\'>T</font>"
   local windowtitle =  UI.CreateFrame("Text", "window_title", cutwindow)
   windowtitle:SetFontSize(cut.gui.font.size )
   windowtitle:SetText(string.format("%s", cut.html.title), true)
   windowtitle:SetLayer(3)
   windowtitle:SetPoint("TOPLEFT",   cutwindow, "TOPLEFT", cut.gui.borders.left, -11)
--    windowtitle:SetEffectGlow({})
   cut.shown.windowtitle   =  windowtitle


   local windowinfo =  UI.CreateFrame("Text", "window_info", cutwindow)
   windowinfo:SetFontSize(cut.gui.font.size )
   windowinfo:SetFontSize(cut.gui.font.size -2 )
   local mylabel  =  cut.shown.panellabel[cut.shown.panel]
   if cut.shown.panel == 3 then   mylabel = mylabel .. "<font color=\'"  .. cut.html.green .. "\'>(" ..tostring(cut.today - cut.weekday) .. ")</font>" end
--    windowinfo:SetText(string.format("%s", cut.shown.panellabel[cut.shown.panel]), true)
   windowinfo:SetText(string.format("%s", mylabel), true)
   windowinfo:SetLayer(3)
   windowinfo:SetPoint("TOPRIGHT",   cutwindow, "TOPRIGHT", -cut.gui.borders.right, -11)
   windowinfo:EventAttach( Event.UI.Input.Mouse.Left.Click, function()

                                                                  cut.shown.panel   =  cut.shown.panel + 1

                                                                  if cut.shown.panel > 3 then   cut.shown.panel = 1  end

                                                                  -- show Current Session
                                                                  if cut.shown.panel == 1 then
                                                                     cut.frames.container:SetVisible(true)
                                                                     cut.frames.todaycontainer:SetVisible(false)
                                                                     cut.frames.weekcontainer:SetVisible(false)
                                                                     local var, val = nil
                                                                     for var, val in pairs(cut.shown.todaytbl) do
                                                                        cut.shown.todaytbl[var].frame:SetVisible(false)
                                                                     end
                                                                     for var, val in pairs(cut.shown.weektbl) do
                                                                        cut.shown.weektbl[var].frame:SetVisible(false)
                                                                     end
                                                                     for var, val in pairs(cut.shown.currenttbl) do
                                                                        cut.shown.currenttbl[var].frame:SetVisible(true)
                                                                     end

                                                                  end
                                                                  -- show Today Session
                                                                  if cut.shown.panel == 2 then
                                                                     cut.frames.todaycontainer:SetVisible(true)
                                                                     cut.frames.container:SetVisible(false)
                                                                     cut.frames.weekcontainer:SetVisible(false)
                                                                     local var, val = nil
                                                                     for var, val in pairs(cut.shown.currenttbl) do
                                                                        cut.shown.currenttbl[var].frame:SetVisible(false)
                                                                     end
                                                                     for var, val in pairs(cut.shown.weektbl) do
                                                                        cut.shown.weektbl[var].frame:SetVisible(false)
                                                                     end
                                                                     for var, val in pairs(cut.shown.todaytbl) do
                                                                        cut.shown.todaytbl[var].frame:SetVisible(true)
                                                                     end
                                                                  end
                                                                  -- show Week Session
                                                                  if cut.shown.panel == 3 then
                                                                     cut.frames.weekcontainer:SetVisible(true)
                                                                     cut.frames.container:SetVisible(false)
                                                                     cut.frames.todaycontainer:SetVisible(false)
                                                                     local var, val = nil
                                                                     for var, val in pairs(cut.shown.currenttbl) do
                                                                        cut.shown.currenttbl[var].frame:SetVisible(false)
                                                                     end
                                                                     for var, val in pairs(cut.shown.todaytbl) do
                                                                        cut.shown.todaytbl[var].frame:SetVisible(false)
                                                                     end
                                                                     for var, val in pairs(cut.shown.weektbl) do
                                                                        cut.shown.weektbl[var].frame:SetVisible(true)
                                                                     end
                                                                  end

                                                                  cut.resizewindow(cut.shown.panel)
--                                                                   cut.shown.windowinfo:SetText(string.format("%s", cut.shown.panellabel[cut.shown.panel]), true)
                                                                  local mylabel  =  cut.shown.panellabel[cut.shown.panel]
                                                                  if cut.shown.panel == 3 then   mylabel = mylabel .. "<font color=\'"  .. cut.html.green .. "\'>(" ..tostring(cut.today - cut.weekday) .. ")</font>" end
                                                                  windowinfo:SetText(string.format("%s", mylabel), true)

                                                               end,
                                                               "Flip Panels" )
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
   cut.frames.container =  cutframe

   -- Whole Day Session Data Container
   local todaycutframe =  UI.CreateFrame("Frame", "cut_frame_today", maskframe)
   todaycutframe:SetAllPoints(maskframe)
   todaycutframe:SetLayer(1)
   todaycutframe:SetBackgroundColor(unpack(cut.color.red))
   cut.frames.todaycontainer =  todaycutframe
   cut.frames.todaycontainer:SetVisible(false)

   -- Whole Week Session Data Container
   local weekcutframe =  UI.CreateFrame("Frame", "cut_frame_week", maskframe)
   weekcutframe:SetAllPoints(maskframe)
   weekcutframe:SetLayer(1)
   weekcutframe:SetBackgroundColor(unpack(cut.color.green))
   cut.frames.weekcontainer =  weekcutframe
   cut.frames.weekcontainer:SetVisible(false)

   -- RESIZER WIDGET
   local corner=  UI.CreateFrame("Text", "corner", cutwindow)
   local text  =  "<font color=\'"..cut.html.red.."\'>o</font>"
   corner:SetText(text, true)
   corner:SetFontSize(cut.gui.font.size -2 )
   corner:SetLayer(4)
   corner:SetPoint("BOTTOMRIGHT", cutwindow, "BOTTOMRIGHT", 6, 7)
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


local function createnewline(currency, value, panel, id)
--    print(string.format("createnewline: c=%s, v=%s, panel=%s, id=%s", currency, value, panel, id))
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

   if not cut.gui.window then cut.gui.window = createwindow() end

   if cut.shown.weektbl[currency] then
      updatecurrencyvalue(currency, value, cut.shown.weektbl[currency].value, id)
   else
      local t  =  {}
      t  =  createnewline(currency, value, 3, id)
      cut.shown.weekframes.last           =  t.frame
      cut.shown.weektbl[currency]         =  t
   end

   cut.sortbykey(cut.frames.weekcontainer, cut.shown.weektbl, 3)

   return
end

function cut.updatecurrenciestoday(currency, value, id)

--    print(string.format(">> cut.save.day[%s].stack=%s", currency, cut.save.day[currency].stack))

   if not cut.gui.window then cut.gui.window = createwindow()  end

   if cut.shown.todaytbl[currency] then
      updatecurrencyvalue(currency, value, cut.shown.todaytbl[currency].value, id)
   else
      local t  =  {}
      t  =  createnewline(currency, value, 2, id)
      cut.shown.todayframes.last          =  t.frame
      cut.shown.todaytbl[currency]        =  t
   end

   cut.sortbykey(cut.frames.todaycontainer, cut.shown.todaytbl, 2)

--    print(string.format("<< cut.save.day[%s].stack=%s", currency, cut.save.day[currency].stack))

   return
end

function cut.updateothers(var, val)

   if table.contains(cut.save.day, var) then
--       print(string.format("pre  cut.save.day[%s].stack=%s", var, cut.save.day[var].stack))
      cut.updatecurrenciestoday(var, (cut.save.day[var].stack + val), cut.save.day[var].id)
--       print(string.format("post cut.save.day[%s].stack=%s", var, cut.save.day[var].stack))
   else
--       cut.save.day[var]   =  { stack=val, icon=cut.coinbase[var].icon, id=cut.coinbase[var].id, smax=cut.coinbase[var].stackMax }
      cut.save.day[var]   =  { stack=0, icon=cut.coinbase[var].icon, id=cut.coinbase[var].id, smax=cut.coinbase[var].stackMax }
      cut.updatecurrenciestoday(var, val, cut.save.day[var].id)
   end

   if table.contains(cut.save.week, var) then
      cut.updatecurrenciesweek(var, (val + cut.save.week[var].stack), cut.save.week[var].id)
   else
--       cut.save.week[var]    =  { stack=val, icon=cut.coinbase[var].icon, id=cut.coinbase[var].id, smax=cut.coinbase[var].stackMax }
      cut.save.week[var]    =  { stack=0, icon=cut.coinbase[var].icon, id=cut.coinbase[var].id, smax=cut.coinbase[var].stackMax }
      cut.updatecurrenciesweek(var, val, cut.save.week[var].id)
   end

   return
end

function cut.updatecurrencies(currency, value, id)

   if not cut.gui.window then cut.gui.window = createwindow() end

   if cut.shown.currenttbl[currency] then
      updatecurrencyvalue(currency, value, cut.shown.currenttbl[currency].value, id)
   else
      local t  =  {}
      t  =  createnewline(currency, value, 1, id)
      cut.shown.frames.last            =  t.frame
      cut.shown.currenttbl[currency]   =  t
   end

   cut.sortbykey(cut.frames.container, cut.shown.currenttbl, 1)

   cut.updateothers(currency, value)

   return
end


-- Load/Save variable and Coinbases initialization -- begin
Command.Event.Attach(Event.Unit.Availability.Full,          cut.startmeup,       "CuT: Init Coin Base")
Command.Event.Attach(Event.Addon.SavedVariables.Load.End,   cut.loadvariables,   "CuT: Load Variables")
Command.Event.Attach(Event.Addon.SavedVariables.Save.Begin, cut.savevariables,   "CuT: Save Variables")
-- Load/Save variable and Coinbases initialization -- end
