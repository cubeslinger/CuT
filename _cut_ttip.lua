--
-- Addon       _cut_ttip.lua
-- Author      marcob@marcob.org
-- StartDate   23/10/2017
--

local addon, cut = ...

local function _newTT()

   --Global context (parent frame-thing).
   local ttcontext = UI.CreateContext("Tooltip_context")
   ttcontext:SetStrata("topmost")

   local ttwindow    =  UI.CreateFrame("Frame", "cut_ttip", ttcontext)
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
   ttframe:SetBackgroundColor(unpack(cut.color.darkgrey))
   cut.ttframes.ttframe  =	ttframe

   -- TT Currency Name
   local tttext1     =  UI.CreateFrame("Text", "cut_ttip_text_1", cut.ttframes.ttframe)
   tttext1:SetFontSize(cut.gui.font.size)
   tttext1:SetText("", true)
   tttext1:SetLayer(10)
   tttext1:SetFontColor(unpack(cut.color.yellow))
   tttext1:SetPoint( "TOPCENTER", cut.ttframes.ttframe, "TOPCENTER")
   cut.ttframes.tttext1 =  tttext1

   -- TT Line Saparator 0
   local linesep0     =  UI.CreateFrame("Texture", "cut_ttip_separator_1", cut.ttframes.ttframe)
   linesep0:SetTexture("Rift", "line_window_break.png.dds")
   linesep0:SetHeight(cut.gui.font.size/2)
   linesep0:SetLayer(10)
   linesep0:SetPoint( "TOPLEFT",    cut.ttframes.ttframe, "TOPLEFT",    0, cut.ttframes.ttframe:GetTop() + tttext1:GetHeight()   +  cut.gui.borders.top * 3)
   linesep0:SetPoint( "TOPRIGHT",   cut.ttframes.ttframe, "TOPRIGHT",   0, cut.ttframes.ttframe:GetTop() + tttext1:GetHeight()   +  cut.gui.borders.top * 3)
   cut.ttframes.linesep0 =  linesep0

   -- TT In Label
   local tttext2     =  UI.CreateFrame("Text", "cut_ttip_text_2", cut.ttframes.ttframe)
   tttext2:SetFontSize(cut.gui.font.size)
   tttext2:SetText("", true)
   tttext2:SetLayer(10)
   tttext2:SetFontColor(1, 1, 1)
   tttext2:SetPoint( "TOPLEFT", cut.ttframes.linesep0, "TOPLEFT")
   cut.ttframes.tttext2   =  tttext2

   -- TT In value
   local tttext3     =  UI.CreateFrame("Text", "cut_ttip_text_3", cut.ttframes.ttframe)
   tttext3:SetFontSize(cut.gui.font.size)
   tttext3:SetText("", true)
   tttext3:SetLayer(10)
   tttext3:SetFontColor(1, 1, 1)
   tttext3:SetPoint( "TOPRIGHT", cut.ttframes.linesep0, "TOPRIGHT")
   cut.ttframes.tttext3   =  tttext3

   -- TT Out Label
   local tttext4     =  UI.CreateFrame("Text", "cut_ttip_text_4", cut.ttframes.ttframe)
   tttext4:SetFontSize(cut.gui.font.size)
   tttext4:SetText("", true)
   tttext4:SetLayer(10)
   tttext4:SetFontColor(1, 1, 1)
   tttext4:SetPoint( "TOPLEFT", cut.ttframes.tttext2, "BOTTOMLEFT")
   cut.ttframes.tttext4   =  tttext4

   -- TT Out value
   local tttext5     =  UI.CreateFrame("Text", "cut_ttip_text_5", cut.ttframes.ttframe)
   tttext5:SetFontSize(cut.gui.font.size)
   tttext5:SetText("", true)
   tttext5:SetLayer(10)
   tttext5:SetFontColor(1, 1, 1)
   tttext5:SetPoint( "TOPRIGHT", cut.ttframes.tttext3, "BOTTOMRIGHT")
   cut.ttframes.tttext5   =  tttext5

   -- TT Line Saparator 1
   local linesep1     =  UI.CreateFrame("Texture", "cut_ttip_separator_1", cut.ttframes.ttframe)
   linesep1:SetTexture("Rift", "line_window_break.png.dds")
   linesep1:SetHeight(cut.gui.font.size/2)
   linesep1:SetLayer(10)
   linesep1:SetPoint( "TOPLEFT",  cut.ttframes.tttext4, "BOTTOMLEFT",    0, 2)
   linesep1:SetPoint( "TOPRIGHT", cut.ttframes.tttext5, "BOTTOMRIGHT",   0, 2)
   cut.ttframes.linesep1 =  linesep1

   -- TT Balance Label
   local tttext6     =  UI.CreateFrame("Text", "cut_ttip_text_6", cut.ttframes.ttframe)
   tttext6:SetFontSize(cut.gui.font.size)
   tttext6:SetText("", true)
   tttext6:SetLayer(10)
   tttext6:SetFontColor(1, 1, 1)
   tttext6:SetPoint( "TOPLEFT", cut.ttframes.linesep1, "BOTTOMLEFT")
   cut.ttframes.tttext6   =  tttext6

   -- TT Balance value
   local tttext7     =  UI.CreateFrame("Text", "cut_ttip_text_7", cut.ttframes.ttframe)
   tttext7:SetFontSize(cut.gui.font.size)
   tttext7:SetText("", true)
   tttext7:SetLayer(10)
   tttext7:SetFontColor(1, 1, 1)
   tttext7:SetPoint( "TOPRIGHT", cut.ttframes.linesep1, "BOTTOMRIGHT")
   cut.ttframes.tttext7   =  tttext7

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
      cut.ttframes.tttext1:SetText(var, true)
      cut.ttframes.tttext2:SetText("In :", true)
      cut.ttframes.tttext3:SetText("")
      cut.ttframes.tttext4:SetText("Out:", true)
      cut.ttframes.tttext5:SetText("")
      cut.ttframes.tttext6:SetText("Bal:", true)
      cut.ttframes.tttext7:SetText("")

      if id == "coin"  then
         cut.ttframes.tttext3:SetText( cut.printmoney(tips[tostring(panel)]["1"]), true )
         cut.ttframes.tttext5:SetText( cut.printmoney(tips[tostring(panel)]["2"]), true )
         cut.ttframes.tttext7:SetText( cut.printmoney(tips[tostring(panel)]["3"]), true )
      else
         cut.ttframes.tttext3:SetText( tostring(tips[tostring(panel)]["1"]), true )
         cut.ttframes.tttext5:SetText( tostring(tips[tostring(panel)]["2"]), true )
         cut.ttframes.tttext7:SetText( tostring(tips[tostring(panel)]["3"]), true )
      end



      -- resize tooltip
      -- Vertical
      cut.gui.ttobj:SetHeight((cut.ttframes.tttext7:GetBottom() - cut.ttframes.tttext1:GetTop()) + (cut.gui.borders.top*2) + (cut.gui.borders.bottom))
      -- Orizontal
      local w  =  {  cut.ttframes.tttext1:GetWidth() + cut.gui.borders.left + (cut.gui.borders.left*2) + (cut.gui.borders.right*2),
                     cut.ttframes.tttext2:GetWidth() + cut.ttframes.tttext3:GetWidth() + (cut.gui.borders.left*2) + (cut.gui.borders.right*2),
                     cut.ttframes.tttext4:GetWidth() + cut.ttframes.tttext5:GetWidth() + (cut.gui.borders.left*2) + (cut.gui.borders.right*2),
                     cut.ttframes.tttext6:GetWidth() + cut.ttframes.tttext7:GetWidth() + (cut.gui.borders.left*2) + (cut.gui.borders.right*2)
                  }
      local W  =  0
      for _, width in ipairs(w) do  if width > W then W = width end end
      cut.gui.ttobj:SetWidth(W)

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
