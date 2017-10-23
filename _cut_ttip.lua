--
-- Addon       _cut_ttip.lua
-- Author      marcob@marcob.org
-- StartDate   23/10/2017
--

local addon, cut = ...

-- cut.ttframes =  {}

local tWINWIDTH   =  150
local tWINHEIGHT  =  cut.gui.font.size * 6

local function _newTT()

   --Global context (parent frame-thing).
   local ttcontext = UI.CreateContext("Tooltip_context")
   ttcontext:SetStrata("topmost")

   local ttwindow    =  UI.CreateFrame("Frame", "cut_ttip", ttcontext)
   ttwindow:SetWidth(tWINWIDTH)
   ttwindow:SetHeight(tWINHEIGHT)
   ttwindow:SetLayer(8)
   ttwindow:SetBackgroundColor(unpack(cut.color.black))
   cut.ttframes.ttwindow =  ttwindow

   -- TT CONTAINER FRAME
   local ttframe =  UI.CreateFrame("Frame", "cut_ttip_frame", cut.ttframes.ttwindow)
   ttframe:SetLayer(9)
   ttframe:SetPoint("TOPLEFT",      ttwindow,    "TOPLEFT",       cut.gui.borders.left,     cut.gui.borders.top)
   ttframe:SetPoint("TOPRIGHT",     ttwindow,    "TOPRIGHT",     -cut.gui.borders.right,    cut.gui.borders.top)
   ttframe:SetPoint("BOTTOMLEFT",   ttwindow,    "BOTTOMLEFT",    cut.gui.borders.right,   -cut.gui.borders.bottom)
   ttframe:SetPoint("BOTTOMRIGHT",  ttwindow,    "BOTTOMRIGHT",  -cut.gui.borders.right,   -cut.gui.borders.bottom)
   cut.ttframes.ttframe  =	ttframe

   -- TT Text Field
   local tttext     =  UI.CreateFrame("Text", "cut_ttip_text_frame", cut.ttframes.ttframe)
   tttext:SetFontSize(cut.gui.font.size * .75)
   tttext:SetText("", true)
   tttext:SetLayer(10)
   tttext:SetFontColor(1, 1, 1)
   tttext:SetAllPoints(cut.ttframes.ttframe)
   cut.ttframes.tttext   =  tttext

   cut.init.tt =  true

   return   cut.ttframes.ttwindow

end

local function showTT(o, var)

   if o and var then

      -- update tooltip
      cut.ttframes.tttext:SetText("")
      cut.ttframes.tttext:SetText(string.format("Var: %s\nIn: %s\nOut: %s\nBalance: %s", var, (cut.deltaup[var] or 0), (cut.deltadown[var] or 0), (cut.deltas[var] or 0)), true)
--       -- resize tooltip
--       cut.gui.ttobj:SetHeight((cut.ttframes.tttext:GetBottom() - cut.ttframes.tttext:GetTop()) + cut.gui.borders.top + cut.gui.borders.bottom)

      -- re-position tooltip
      local mouseData   =   Inspect.Mouse()
      cut.gui.ttobj:SetPoint("TOPLEFT", UIParent, "TOPLEFT", mouseData.x + 10, mouseData.y + 10)

      -- Show tooltip
      cut.gui.ttobj:SetVisible(true)

   else
      cut.gui.ttobj:SetVisible(false)
   end

   return
end

function cut.attachTT(o, var)

   if o and var then

      if not cut.init.tt then
         cut.gui.ttobj  =  _newTT()
         cut.gui.ttobj:SetVisible(false)
      end

      -- Mouse Hover IN    => show tooltip
      o:EventAttach(Event.UI.Input.Mouse.Cursor.In,   function() showTT(o, var)      end, "Event.UI.Input.Mouse.Cursor.In_"  .. o:GetName())
      -- Mouse Hover OUT   => show tooltip
      o:EventAttach(Event.UI.Input.Mouse.Cursor.Out,  function() showTT(nil, nil)   end, "Event.UI.Input.Mouse.Cursor.Out_" .. o:GetName())
   end

   return
end
