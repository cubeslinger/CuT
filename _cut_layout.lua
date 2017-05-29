--
-- Addon       _cut_layout.lua
-- Author      marcob@marcob.org
-- StartDate   28/05/2017
--
local addon, cut = ...

cut.addon               =  Inspect.Addon.Detail(Inspect.Addon.Current())["name"]
cut.gui                 =  {}
cut.gui.x               =  nil
cut.gui.y               =  nil
cut.gui.width           =  250
cut.gui.height          =  100
cut.gui.borders         =  {}
cut.gui.borders.left    =  4
cut.gui.borders.right   =  4
cut.gui.borders.bottom  =  4
cut.gui.borders.top     =  4
cut.gui.font            =  {}
cut.gui.font.size       =  12
cut.gui.font.name       =  "fonts/MonospaceTypewriter.ttf"
--
cut.shown               =  {}
cut.shown.objs          =  {}
cut.frames              =  {}

local function updateguicoordinates(win, x, y)

   if win ~= nil then
      local winname = win:GetName()

      if winName == "cut" then
         cut.gui.x   =  cD.round(x)
         cut.gui.y   =  cD.round(y)
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
   cutwindow:SetHeight(cut.gui.height)
   cutwindow:SetBackgroundColor(0, 0, 0, .5)

   -- EXTERNAL CUT CONTAINER FRAME
   local externalcutframe =  UI.CreateFrame("Frame", "External_cut_frame", cutwindow)
   externalcutframe:SetPoint("TOPLEFT",     cutwindow, "TOPLEFT",     cut.gui.borders.left,    cut.gui.borders.top)
   externalcutframe:SetPoint("TOPRIGHT",    cutwindow, "TOPRIGHT",    - cut.gui.borders.right, cut.gui.borders.top)
   externalcutframe:SetPoint("BOTTOMLEFT",  cutwindow, "BOTTOMLEFT",  cut.gui.borders.left,    - cut.gui.borders.bottom)
   externalcutframe:SetPoint("BOTTOMRIGHT", cutwindow, "BOTTOMRIGHT", - cut.gui.borders.right, - cut.gui.borders.bottom)
   externalcutframe:SetBackgroundColor(.2, .2, .2, .5)
   externalcutframe:SetLayer(1)

   -- MASK FRAME
   local maskframe = UI.CreateFrame("Mask", "cut_mask_frame", externalcutframe)
   maskframe:SetAllPoints(externalcutframe)

   -- CUT CONTAINER FRAME
   local cutframe =  UI.CreateFrame("Frame", "cut_frame", maskframe)
--    local cutframe =  UI.Createframe("Frame", "cut_frame", maskframe)
   cutframe:SetAllPoints(maskframe)
   cutframe:SetLayer(1)
   cut.frames.container =  cutframe

   -- Enable Dragging
   Library.LibDraggable.draggify(cutwindow, updateguicoordinates)

   return cutwindow
end

function createnewline(currency, value)

   -- CUT currency container
   local currencyframe  =  UI.CreateFrame("Frame", "cut_currency_frame", cut.frames.container)
--    currencyframe:SetBackgroundColor(1, 0, 0, .5)
   currencyframe:SetLayer(2)

   -- setup Loot Item's Counter
   currencylabel  =  UI.CreateFrame("Text", "currency_label_" .. currency, currencyframe)
   currencylabel:SetFont(cut.addon, cut.gui.font.name)
   currencylabel:SetFontSize(cut.gui.font.size )
   currencylabel:SetText(string.format("%s:", currency))
   currencylabel:SetLayer(3)
   currencylabel:SetPoint("TOPLEFT",   currencyframe, "TOPLEFT", cut.gui.borders.left, 0)

   if currency == "Platinum, Gold, Silver" then value = cut.printmoney(value) end

   -- setup Loot Item's Counter
   currencyvalue  =  UI.CreateFrame("Text", "currency_value_" .. currency, currencyframe)
   currencyvalue:SetFont(cut.addon, cut.gui.font.name)
   currencyvalue:SetFontSize(cut.gui.font.size )
   currencyvalue:SetText(string.format("%s", value), true)
   currencyvalue:SetLayer(3)
   currencyvalue:SetPoint("TOPRIGHT",   currencyframe, "TOPRIGHT", -cut.gui.borders.right, 0)
   cut.shown.objs.currency =  currencyvalue

   return currencyframe

end

local function updatecurrencyvalue(currency, value)

   print(string.format("updatecurrencyvalue(%s, %s)", currency, value))
   if currency == "Platinum, Gold, Silver" then value = cut.printmoney(value) end

   cut.shown.objs[currency]:SetText(string.format("%s", value), true)

   return
end

function cut.updatecurrencies(currency, value)

   if not cut.gui.window then cut.gui.window = createwindow() end

   if cut.shown.objs.currency then
      print("...UPDATING...")
      updatecurrencyvalue(currency, value)
   else
      print("...CREATING...")
      local newline =   createnewline(currency, value)
      if #cut.shown.objs > 0  then
--          print("NOT First currencies")
         newline:SetPoint("TOPLEFT",   cut.shown.objs[#cut.shown.objs], "BOTTOMLEFT")
         newline:SetPoint("TOPRIGHT",  cut.shown.objs[#cut.shown.objs], "BOTTOMRIGHT")
      else
--          print("First currencies")
         newline:SetPoint("TOPLEFT",   cut.frames.container,   "TOPLEFT",  cut.gui.borders.left,   cut.gui.borders.top)
         newline:SetPoint("TOPRIGHT",  cut.frames.container,   "TOPRIGHT", -cut.gui.borders.right, cut.gui.borders.top)
      end
      cut.shown.objs.currency = newline
   end

   return
end
