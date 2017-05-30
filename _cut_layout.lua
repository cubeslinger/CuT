--
-- Addon       _cut_layout.lua
-- Author      marcob@marcob.org
-- StartDate   28/05/2017
--
local addon, cut = ...

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

local function createnewline(currency, value)

   -- CUT currency container
   local currencyframe  =  UI.CreateFrame("Frame", "cut_currency_frame", cut.frames.container)
   currencyframe:SetLayer(2)

   local currencylabel  =  UI.CreateFrame("Text", "currency_label_" .. currency, currencyframe)
   currencylabel:SetFont(cut.addon, cut.gui.font.name)
   currencylabel:SetFontSize(cut.gui.font.size )
   currencylabel:SetText(string.format("%s:", currency))
   currencylabel:SetLayer(3)
   currencylabel:SetPoint("TOPLEFT",   currencyframe, "TOPLEFT", cut.gui.borders.left, 0)

   if currency == "Platinum, Gold, Silver" then value = cut.printmoney(value) end

   local currencyvalue  =  UI.CreateFrame("Text", "currency_value_" .. currency, currencyframe)
   currencyvalue:SetFont(cut.addon, cut.gui.font.name)
   currencyvalue:SetFontSize(cut.gui.font.size )
   currencyvalue:SetText(string.format("%s", value), true)
   currencyvalue:SetLayer(3)
   currencyvalue:SetPoint("TOPLEFT",   currencylabel, "TOPRIGHT", cut.gui.borders.left, 0)

   local currencyicon = UI.CreateFrame("Texture", "currency_icon_" .. currency, currencyframe)
   currencyicon:SetTexture("Rift", (cut.coinbase[currency].icon or "reward_gold.png.dds"))
   currencyicon:SetWidth(cut.gui.font.size  + 2)
   currencyicon:SetHeight(cut.gui.font.size + 2)
   currencyicon:SetLayer(3)
   currencyicon:SetPoint("TOPLEFT",   currencyvalue, "TOPRIGHT", -cut.gui.borders.right, 0)


   cut.shown.objs[currency]   =  currencyvalue

--    cut.shown.frames[currency] =  currencyframe
   cut.shown.frames.count     =  1 + cut.shown.frames.count -- last frame shown by number
--    cut.shown.frames.last      =  currencyframe              -- last frame shown by currecny name

--    local a,b = nil, nil
--    for a,b in pairs(cut.shown.objs) do print(string.format("CuT: cut.shown.objs.%s=%s", a, b)) end

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
      print("...UPDATING...")
      updatecurrencyvalue(currency, value)
   else
      print("...CREATING...")
      local newline =   createnewline(currency, value)
      if cut.shown.frames.count > 1  then
         print("NOT First currencies")
         newline:SetPoint("TOPLEFT",   cut.shown.frames.last, "BOTTOMLEFT")
         newline:SetPoint("TOPRIGHT",  cut.shown.frames.last, "BOTTOMRIGHT")
      else
         print("First currencies")
         newline:SetPoint("TOPLEFT",   cut.frames.container,   "TOPLEFT",  cut.gui.borders.left,   cut.gui.borders.top)
         newline:SetPoint("TOPRIGHT",  cut.frames.container,   "TOPRIGHT", -cut.gui.borders.right, cut.gui.borders.top)
      end

      cut.shown.frames.last   =  newline

--       cut.shown.objs[currency] = newline
   end

   return
end



--[[
Error: Incorrect function usage.
  Parameters: (userdata: 59f5f450), "TOPLEFT", nil, "BOTTOMLEFT"
  Parameter types: userdata, string, nil, string
Function documentation:
	Pins a point on this frame to a location on another frame. This is a rather complex function and you should look at examples to see how to use it.
	This function can take many different forms. In general, it looks like this: SetPoint(point_on_this_frame, target_frame, point_on_target_frame [, x_offset, y_offset]).
	The first part is the point on this frame that will be attached. Usually, these are string identifiers. "TOPLEFT", "TOPCENTER", "TOPRIGHT", "CENTERLEFT", "CENTER", "CENTERRIGHT", "BOTTOMLEFT", "BOTTOMCENTER", "BOTTOMRIGHT". You may also use a string identifier that refers to a single axis - "TOP", "BOTTOM", "LEFT", "RIGHT", "CENTERX", "CENTERY". If you want more direct numeric control you can use number pairs. 0,0 is equivalent to "TOPLEFT", 1,1 is equivalent to "BOTTOMRIGHT", 0.5,nil is equivalent to "CENTERX".
	The second part is the frame to attach to, as well as the point on that frame to attach to. The frame is simply passing in the frame table. The point is the same identifier or number pair as the first parameter.
	Optionally, you may include an X or Y offset to the point.
	This connection is permanent, and if the target frame moves, this frame will move along with it.
	Caveat: If the target is a frame set to the "restricted" SecureMode, and the client is currently in "secure" mode, then unexpected behavior may occur.
	Not permitted on a frame with "restricted" SecureMode while the addon environment is secured.
		Frame:SetPoint(...)   -- ...
Parameters:
		...:	This function's parameters are complicated. Read the above summary for details.
    In CuT / CuT Currency Event, event Event.Currency
stack traceback:
	[C]: ?
	[C]: in function 'SetPoint'
	CuT/_cut_layout.lua:129: in function 'updatecurrencies'
	CuT/CuT.lua:44: in function 'currencyevent'
	CuT/CuT.lua:52: in function <CuT/CuT.lua:52>
         ]]--
