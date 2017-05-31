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
   windowtitle:SetFont(cut.addon, cut.gui.font.name)
   windowtitle:SetFontSize(cut.gui.font.size )
   windowtitle:SetText(string.format("%s", title), true)
   windowtitle:SetLayer(3)
   windowtitle:SetPoint("TOPLEFT",   cutwindow, "TOPLEFT", cut.gui.borders.left, -12)

   -- EXTERNAL CUT CONTAINER FRAME
   local externalcutframe =  UI.CreateFrame("Frame", "External_cut_frame", cutwindow)
   externalcutframe:SetPoint("TOPLEFT",     cutwindow, "TOPLEFT",     cut.gui.borders.left,    cut.gui.borders.top)
   externalcutframe:SetPoint("TOPRIGHT",    cutwindow, "TOPRIGHT",    - cut.gui.borders.right, cut.gui.borders.top)
   externalcutframe:SetPoint("BOTTOMLEFT",  cutwindow, "BOTTOMLEFT",  cut.gui.borders.left,    - cut.gui.borders.bottom)
   externalcutframe:SetPoint("BOTTOMRIGHT", cutwindow, "BOTTOMRIGHT", - cut.gui.borders.right, - cut.gui.borders.bottom)
--    externalcutframe:SetBackgroundColor(.2, .2, .2, .5)
   externalcutframe:SetBackgroundColor(unpack(cut.color.darkgrey))
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


local function createnewline(currency, value)

   -- CUT currency container
   local currencyframe  =  UI.CreateFrame("Frame", "cut_currency_frame", cut.frames.container)
   currencyframe:SetHeight(cut.gui.font.size)
   currencyframe:SetLayer(2)

   local currencylabel  =  UI.CreateFrame("Text", "currency_label_" .. currency, currencyframe)
   currencylabel:SetFont(cut.addon, cut.gui.font.name)
   currencylabel:SetFontSize(cut.gui.font.size)
   local textcurrency   =  ""
   if currency == "Platinum, Gold, Silver"   then textcurrency="Money"
                                             else textcurrency=currency
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

   if currency == "Platinum, Gold, Silver" then
      value = cut.printmoney(value)
   else
      local sign = "+"
      if value < 0   then  sign = "<font color=\'"..cut.html.red.."\'>-</font>"
                     else  sign = "<font color=\'"..cut.html.green.."\'>+</font>"
      end
   end

   local currencyvalue  =  UI.CreateFrame("Text", "currency_value_" .. currency, currencyframe)
   currencyvalue:SetFont(cut.addon, cut.gui.font.name)
   currencyvalue:SetFontSize(cut.gui.font.size )
   currencyvalue:SetText(string.format("%s%s", (sign or ""), value), true)
   currencyvalue:SetLayer(3)
   currencyvalue:SetPoint("TOPRIGHT",   currencyicon, "TOPLEFT", -cut.gui.borders.right, -4)

   cut.shown.objs[currency]   =  currencyvalue
   cut.shown.frames.count     =  1 + cut.shown.frames.count -- last frame shown by number

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

   if cut.shown.objs[currency] then
--       print("...UPDATING...")
      updatecurrencyvalue(currency, value)
   else
--       print("...CREATING...")
      local newline =   createnewline(currency, value)
      if cut.shown.frames.count > 1  then
--          print("NOT First currencies")
         newline:SetPoint("TOPLEFT",   cut.shown.frames.last, "BOTTOMLEFT",   0, 1)
         newline:SetPoint("TOPRIGHT",  cut.shown.frames.last, "BOTTOMRIGHT",  0, 1)
      else
--          print("First currencies")
         newline:SetPoint("TOPLEFT",   cut.frames.container,   "TOPLEFT",  cut.gui.borders.left,   cut.gui.borders.top)
         newline:SetPoint("TOPRIGHT",  cut.frames.container,   "TOPRIGHT", -cut.gui.borders.right, cut.gui.borders.top)
      end

      cut.shown.frames.last   =  newline
   end

   -- adjust window size
   cut.gui.window:SetHeight( (cut.shown.frames.last:GetBottom() - cut.gui.window:GetTop() ) + cut.gui.borders.top + cut.gui.borders.bottom*2)

   return
end

--[[
    Error: Incorrect function usage.
   Parameters: "Text", "window_title", nil
   Parameter types: string, string, nil
   Function documentation:
   Creates a new frame. Frames are the blocks that all addon UIs are made out of. Since all frames must have a parent, you'll need to create a Context before any frames. See UI.CreateContext.
   List of valid frame types:
   Frame: The base type. No special capabilities. Useful for spacing, organization, input handling, and solid color squares.
   Mask: Obscures the contents of child frames that do not fall within the mask boundaries.
   Text: Displays text.
   Texture: Displays a static texture image.
   RiftButton: A standard Rift button widget.
   RiftCheckbox: A standard Rift checkbox widget.
   RiftScrollbar: A standard Rift scrollbar widget.
   RiftSlider: A standard Rift slider widget.
   RiftTextfield: A standard Rift textfield widget.
   RiftWindow: A standard Rift window widget.
   frame = UI.CreateFrame(type, name, parent)   -- Frame <- string, string, Element
   Parameters:
   name:	A descriptive name for this element. Used for error reports and performance information. May be shown to end-users.
   parent:	The new parent for this frame.
   type:	The type of your new frame. Current supported types: Frame, Text, Texture.
   Return values:
   frame:	Your new frame.
   In CuT / CuT Currency Event, event Event.Currency
   stack traceback:
   [C]: ?
   [C]: in function 'createFrame_core'
   CuT/CuT.lua:37: in function 'createwindow'
   CuT/CuT.lua:124: in function 'updatecurrencies'
   CuT/_cut_init.lua:120: in function <CuT/_cut_init.lua:108>
    ]]--
