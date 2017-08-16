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
   local title =  "<font color=\'"..cut.html.green.."\'>C</font><font color=\'"..cut.html.white.."\'>u</font><font color=\'"..cut.html.red.."\'>T</font>"
   local windowtitle =  UI.CreateFrame("Text", "window_title", cutwindow)
   windowtitle:SetFontSize(cut.gui.font.size )
   windowtitle:SetText(string.format("%s", title), true)
   windowtitle:SetLayer(3)
   windowtitle:SetPoint("TOPLEFT",   cutwindow, "TOPLEFT", cut.gui.borders.left, -11)

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

   -- CUT CONTAINER FRAME
   local cutframe =  UI.CreateFrame("Frame", "cut_frame", maskframe)
   cutframe:SetAllPoints(maskframe)
   cutframe:SetLayer(1)
   cut.frames.container =  cutframe

   -- RESIZER WIDGET
--    local corner = UI.CreateFrame("Texture", "corner", cutwindow)
--    corner:SetTexture("CuT", "indicator_player_ping.png.dds")   
   local corner=  UI.CreateFrame("Text", "corner", cutwindow)
   local text  =  "<font color=\'"..cut.html.red.."\'>o</font>"
   corner:SetText(text, true)
--    corner:SetWidth(cut.gui.font.size)
--    corner:SetHeight(cut.gui.font.size)
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


local function createnewline(currency, value, id)

   -- CUT currency container
   local currencyframe  =  UI.CreateFrame("Frame", "cut_currency_frame", cut.frames.container)
   currencyframe:SetHeight(cut.gui.font.size)
   currencyframe:SetLayer(2)

   local currencylabel  =  UI.CreateFrame("Text", "currency_label_" .. currency, currencyframe)
   currencylabel:SetFontSize(cut.gui.font.size)
   local textcurrency   =  ""
   if currency == "Platinum, Gold, Silver"   or 
      currency == "Platine, Or, Argent"      or          
      currency == "Platin, Gold, Silber"     then
      textcurrency="Money"
   else
      -- shorten Crafting Marks label
--       if currency:gmatch("Craftsman's")   then
--          textcurrency   =  currency
--          textcurrency:gsub("Craftsman's ", "")
--       else
         textcurrency   =  currency
--       end
   end
   currencylabel:SetText(string.format("%s:", textcurrency))
   currencylabel:SetLayer(3)
   currencylabel:SetPoint("TOPLEFT",   currencyframe, "TOPLEFT", cut.gui.borders.left, 0)

   local currencyicon = UI.CreateFrame("Texture", "currency_icon_" .. currency, currencyframe)
   currencyicon:SetTexture("Rift", (cut.coinbase[currency].icon or "reward_gold.png.dds"))
   currencyicon:SetWidth(cut.gui.font.size)
   currencyicon:SetHeight(cut.gui.font.size)
   currencyicon:SetLayer(3)
   currencyicon:SetPoint("TOPRIGHT",   currencyframe, "TOPRIGHT", -cut.gui.borders.right, 4)

   if currency == "Platinum, Gold, Silver"   or 
      currency == "Platine, Or, Argent"      or
      currency == "Platin, Gold, Silber"     then
      value = cut.printmoney(value)
      -- 
      -- "Platinum, Silver, Gold" doesn't seem to have a tooltip... so i hide it
      id    =  nil
   else
--       local sign = "+"
--       if value < 0   then  sign = "<font color=\'"..cut.html.red.."\'>-</font>"..value
--                      else  sign = "<font color=\'"..cut.html.green.."\'>+</font>"..value
--       end
      if value < 0   then  value = "<font color=\'"..cut.html.red.."\'>-</font>"..value
                     else  value = "<font color=\'"..cut.html.green.."\'>+</font>"..value
      end     
--    end                 
   end
   
   -- "Platinum, Silver, Gold" doesn't seem to have a tooltip... so i hide it
   if currency == "Affinity" or currency == "Affinität" or currency = "Affinité" then id = nil end
   --
   -- ToolTip
   -- Mouse Hover IN    => show tooltip
   currencyicon:EventAttach(Event.UI.Input.Mouse.Cursor.In,   function() Command.Tooltip(id) end, "Event.UI.Input.Mouse.Cursor.In_"  .. currencyicon:GetName())
   -- Mouse Hover OUT   => show tooltip
   currencyicon:EventAttach(Event.UI.Input.Mouse.Cursor.Out,  function() Command.Tooltip(nil) end, "Event.UI.Input.Mouse.Cursor.Out_" .. currencyicon:GetName())
   --
   --
   

   local currencyvalue  =  UI.CreateFrame("Text", "currency_value_" .. currency, currencyframe)
   currencyvalue:SetFontSize(cut.gui.font.size )
   currencyvalue:SetText(string.format("%s", value), true)
   currencyvalue:SetLayer(3)
   currencyvalue:SetPoint("TOPRIGHT",   currencyicon, "TOPLEFT", -cut.gui.borders.right, -4)

   cut.shown.objs[currency]   =  currencyvalue
   cut.shown.frames.count     =  1 + cut.shown.frames.count -- last frame shown by number

   return currencyframe
end

local function updatecurrencyvalue(currency, value)

--    print(string.format("updatecurrencyvalue(%s, %s)", currency, value))
   if currency == "Platinum, Gold, Silver"   or
      currency == "Platine, Or, Argent"      or 
      currency == "Platin, Gold, Silber"     then 
      value = cut.printmoney(value) 
   else
--       local sign = "+"
--       if value < 0   then  sign = "<font color=\'"..cut.html.red.."\'>-</font>"..value
--                      else  sign = "<font color=\'"..cut.html.green.."\'>+</font>"..value
--       end
--       local sign = "+"
      if value < 0   then  value = "<font color=\'"..cut.html.red.."\'>-</font>"..value
                     else  value = "<font color=\'"..cut.html.green.."\'>+</font>"..value
      end
   end      

   cut.shown.objs[currency]:SetText(string.format("%s", value), true)
--    print(string.format("SHOWING %s = %s", currency, value))

   return
end

function cut.updatecurrencies(currency, value, id, restoresession)
   
   if restoresession then
--       print("RESTORING "..currency.." - "..value)
   end

   if not cut.gui.window then 
      cut.gui.window = createwindow() 

      local oldcoin     =  nil
      local oldvalue    =  nil
      for oldcoin, oldvalue in pairs(cut.session) do
--          print(string.format("Reading cu.session[%s] = %s", oldcoin, oldvalue))
         cut.updatecurrencies(oldcoin, oldvalue, id, true)
      end      
   end

   if cut.shown.objs[currency] then
--       print("...UPDATING..."..currency.." - "..value)
      updatecurrencyvalue(currency, value)
   else
--       print("...CREATING..."..currency.." - "..value)
      local newline =   createnewline(currency, value, id)
      if cut.shown.frames.count > 1  then
--          print("NOT First currencies"..currency.." - "..value)
         newline:SetPoint("TOPLEFT",   cut.shown.frames.last, "BOTTOMLEFT",   0, cut.gui.borders.top)
         newline:SetPoint("TOPRIGHT",  cut.shown.frames.last, "BOTTOMRIGHT",  0, cut.gui.borders.top)
      else
--          print("First currencies"..currency.." - "..value)
         newline:SetPoint("TOPLEFT",   cut.frames.container,   "TOPLEFT",  cut.gui.borders.left,   cut.gui.borders.top)
         newline:SetPoint("TOPRIGHT",  cut.frames.container,   "TOPRIGHT", -cut.gui.borders.right, cut.gui.borders.top)
      end

      cut.shown.frames.last   =  newline
   end

   -- adjust window size
   cut.gui.window:SetHeight( (cut.shown.frames.last:GetBottom() - cut.gui.window:GetTop() ) + cut.gui.borders.top + cut.gui.borders.bottom*4)
   
--    if not restoresession then
--       if cut.session[currency] then
--          cut.session[currency] = cut.session[currency] + value
--       else
--          cut.session[currency] = value
--       end
--       print(string.format("storing cu.session[%s] = %s", currency, cut.session[currency]))
--    end

   if not restoresession then
      cut.session[currency] = value
--       print(string.format("storing cu.session[%s] = %s", currency, cut.session[currency]))
   end
   

   return
end
