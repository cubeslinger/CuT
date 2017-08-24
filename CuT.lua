--
-- Addon       _cut_layout.lua
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


local function createwindow()

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

   -- Window Title
--    local title =  "<font color=\'"..cut.html.green.."\'>C</font><font color=\'"..cut.html.white.."\'>u</font><font color=\'"..cut.html.red.."\'>T</font>"
   local windowtitle =  UI.CreateFrame("Text", "window_title", cutwindow)
   windowtitle:SetFontSize(cut.gui.font.size )
   windowtitle:SetText(string.format("%s", cut.html.title), true)
   windowtitle:SetLayer(3)
   windowtitle:SetPoint("TOPLEFT",   cutwindow, "TOPLEFT", cut.gui.borders.left, -11)
   windowtitle:EventAttach( Event.UI.Input.Mouse.Left.Click,   function()
                                                                  if cut.frames.container:GetVisible() == true then
                                                                     cut.frames.container:SetVisible(false)
                                                                     cut.frames.todaycontainer:SetVisible(true)
                                                                     local var, val = nil
                                                                     for var, val in pairs(cut.shown.fullframes) do
                                                                        cut.shown.fullframes[var]:SetVisible(false)
                                                                     end
                                                                     for var, val in pairs(cut.shown.todayfullframes) do
                                                                        cut.shown.todayfullframes[var]:SetVisible(true)
                                                                     end
                                                                     cut.resizewindow(true)
                                                                  else
                                                                     cut.frames.container:SetVisible(true)
                                                                     cut.frames.todaycontainer:SetVisible(false)
                                                                     local var, val = nil
                                                                     for var, val in pairs(cut.shown.todayfullframes) do
                                                                        cut.shown.todayfullframes[var]:SetVisible(false)
                                                                     end
                                                                     for var, val in pairs(cut.shown.fullframes) do
                                                                        cut.shown.fullframes[var]:SetVisible(true)
                                                                     end
                                                                     cut.resizewindow(false)
                                                                  end
                                                               end,
                                                               "Flip Panels" )

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


local function createnewline(currency, value, today)
   local flag  =  ""
   if today then flag = "_today_" end

   -- CUT currency container
   local currencyframe  =  nil
   if today then
      currencyframe  =  UI.CreateFrame("Frame", "cut_currency_frame" .. flag, cut.frames.todaycontainer)
   else
      currencyframe  =  UI.CreateFrame("Frame", "cut_currency_frame", cut.frames.container)
   end
   currencyframe:SetHeight(cut.gui.font.size)
   currencyframe:SetLayer(2)

   local currencylabel  =  UI.CreateFrame("Text", "currency_label_" .. flag .. currency, currencyframe)
   currencylabel:SetFontSize(cut.gui.font.size)
   local textcurrency   =  ""
   if currency == "Platinum, Gold, Silver"   or
      currency == "Platine, Or, Argent"      or
      currency == "Platin, Gold, Silber"     then
      textcurrency="Money"
   else
         textcurrency   =  currency
   end
   currencylabel:SetText(string.format("%s:", textcurrency))
   currencylabel:SetLayer(3)
   currencylabel:SetPoint("TOPLEFT",   currencyframe, "TOPLEFT", cut.gui.borders.left, 0)

   local currencyicon = UI.CreateFrame("Texture", "currency_icon_" .. flag .. currency, currencyframe)
   currencyicon:SetTexture("Rift", (cut.coinbase[currency].icon or "reward_gold.png.dds"))
   currencyicon:SetWidth(cut.gui.font.size)
   currencyicon:SetHeight(cut.gui.font.size)
   currencyicon:SetLayer(3)
   currencyicon:SetPoint("TOPRIGHT",   currencyframe, "TOPRIGHT", -cut.gui.borders.right, 4)

   if currency == "Platinum, Gold, Silver"   or
      currency == "Platine, Or, Argent"      or
      currency == "Platin, Gold, Silber"     then
      value = cut.printmoney(value)
   else
      if value < 0   then  value = "<font color=\'"..cut.html.red.."\'>"..value.."</font>"
                     else  value = "<font color=\'"..cut.html.green.."\'>"..value.."</font>"
      end
   end

   local currencyvalue  =  UI.CreateFrame("Text", "currency_value_" .. flag .. currency, currencyframe)
   currencyvalue:SetFontSize(cut.gui.font.size )
   currencyvalue:SetText(string.format("%s", value), true)
   currencyvalue:SetLayer(3)
   currencyvalue:SetPoint("TOPRIGHT",   currencyicon, "TOPLEFT", -cut.gui.borders.right, -4)

   if today then
      cut.shown.todayobjs[currency] =  currencyvalue
      cut.shown.todayframes.count   =  1 + cut.shown.todayframes.count -- last frame shown by number (today)
   else
      cut.shown.objs[currency]      =  currencyvalue
      cut.shown.frames.count        =  1 + cut.shown.frames.count -- last frame shown by number
   end

   return currencyframe
end

-- local function updatecurrencyvalue(currency, value, field, parent, framelist)
local function updatecurrencyvalue(currency, value, field)

--    print(string.format("updatecurrencyvalue(%s, %s)", currency, value))
   if currency == "Platinum, Gold, Silver"   or
      currency == "Platine, Or, Argent"      or
      currency == "Platin, Gold, Silber"     then
      value    =  cut.printmoney(value)
   else
      if value < 0   then  value = "<font color=\'"..cut.html.red.."\'>"..value.."</font>"
      else  value = "<font color=\'"..cut.html.green.."\'>"..value.."</font>"
      end
   end

   field:SetText(string.format("%s", value), true)

   return
end


function cut.updatecurrenciestoday(currency, value)

   if not cut.gui.window then
      cut.gui.window = createwindow()
   end

   if cut.shown.todayobjs[currency] then
      updatecurrencyvalue(currency, value, cut.shown.todayobjs[currency])
   else
      --       print("...CREATING..."..currency.." - "..value)
      local newline =   createnewline(currency, value, true)
      cut.shown.todayfullframes[currency] = newline
      cut.shown.todayframes.last   =  newline
   end

   cut.sortbykey(cut.frames.todaycontainer, cut.shown.todayfullframes, true)

   return
end

function cut.updatecurrencies(currency, value)

   if not cut.gui.window then
      cut.gui.window = createwindow()
   end

   if cut.shown.objs[currency] then
      updatecurrencyvalue(currency, value, cut.shown.objs[currency])
   else
--       print("...CREATING..."..currency.." - "..value)
      local newline =   createnewline(currency, value, false)
      cut.shown.fullframes[currency] = newline
      cut.shown.frames.last   =  newline
   end

   cut.sortbykey(cut.frames.container, cut.shown.fullframes, false)

   return
end

-- Load/Save variable and Coinbases initialization -- begin
Command.Event.Attach(Event.Unit.Availability.Full,          cut.initcoinbase,     "CuT: Init Coin Base")
Command.Event.Attach(Event.Addon.SavedVariables.Load.End,   cut.loadvariables,    "CuT: Load Variables")
Command.Event.Attach(Event.Addon.SavedVariables.Save.Begin, cut.savevariables,    "CuT: Save Variables")
-- end
