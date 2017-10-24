--
-- Addon       _cut_ttip.lua
-- Author      marcob@marcob.org
-- StartDate   23/10/2017
--

local addon, cut = ...

local tWINWIDTH   =  150
local tWINHEIGHT  =  cut.gui.font.size * 8

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
   tttext:SetFontSize(cut.gui.font.size)
   tttext:SetText("", true)
   tttext:SetLayer(10)
   tttext:SetFontColor(1, 1, 1)
   tttext:SetAllPoints(cut.ttframes.ttframe)
   cut.ttframes.tttext   =  tttext

   cut.init.tt =  true

   return   cut.ttframes.ttwindow

end

local function showTT(o, var, panel, id)

   if o and var then

      local tip   =  ""
      local tips  =  {  ["1"] =  {  ["1"] = (cut.balance.current[var].income  or 0),
                                    ["2"] = (cut.balance.current[var].outcome or 0),
                                    ["3"] = (cut.balance.current[var].income  or 0) + (cut.balance.current[var].outcome or 0)
                                 },
                        ["2"] =  {  ["1"] = (cut.balance.today[var].income    or 0),
                                    ["2"] = (cut.balance.today[var].outcome   or 0),
                                    ["3"] = (cut.balance.today[var].income    or 0) + (cut.balance.today[var].outcome   or 0)
                                 },
                        ["3"] =  {  ["1"] = (cut.balance.week[var].income     or 0),
                                    ["2"] = (cut.balance.week[var].outcome    or 0),
                                    ["3"] = (cut.balance.week[var].income     or 0) + (cut.balance.week[var].outcome    or 0)
                                 }
                     }

      -- update tooltip
      cut.ttframes.tttext:SetText("")

      print("ID ["..id.."] panel["..panel.."]")
      if id == 'coin'  then
         tip   =  string.format( "%s\nIn: %s\nOut: %s\nBalance: %s",
            var,
            cut.printmoney(tips[tostring(panel)]["1"]),
            cut.printmoney(tips[tostring(panel)]["2"]),
            cut.printmoney(tips[tostring(panel)]["3"]) )
      else
         tip   =  string.format( "%s\nIn: %s\nOut: %s\nBalance: %s",
            var,
            tips[tostring(panel)]["1"],
            tips[tostring(panel)]["2"],
            tips[tostring(panel)]["3"] )
      end

      cut.ttframes.tttext:SetText( tip, true)

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

function cut.attachTT(o, var, panel, id)

   if o and var then

      if not cut.init.tt then
         cut.gui.ttobj  =  _newTT()
         cut.gui.ttobj:SetVisible(false)
      end

      -- Mouse Hover IN    => show tooltip
      o:EventAttach(Event.UI.Input.Mouse.Cursor.In,   function() showTT(o, var, panel, id)   end, "Event.UI.Input.Mouse.Cursor.In_"  .. o:GetName())
      -- Mouse Hover OUT   => show tooltip
      o:EventAttach(Event.UI.Input.Mouse.Cursor.Out,  function() showTT(nil, nil, nil, nil)  end, "Event.UI.Input.Mouse.Cursor.Out_" .. o:GetName())
   end

   return
end
