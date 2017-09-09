--
-- Addon       _cut_minimapbutton.lua
-- Author      marcob@marcob.org
-- StartDate   07/09/2017
--

local addon, cut = ...

function cut.createminimapbutton()

   -- avoid creating multiple minimap buttons...
   if not cut.gui.mmbtnobj then
      --       print(string.format("cut.createMiniMapButton: cut.gui.mmbtnobj=%s", cut.gui.mmbtnobj))

      --Global context (parent frame-thing).
      mmbtncontext = UI.CreateContext("button_context")

      -- MiniMapButton Border
      mmbuttonborder = UI.CreateFrame("Texture", "mmBtnIconBorder", mmbtncontext)
      mmbuttonborder:SetTexture("Rift", "sml_icon_border_(over)_yellow.png.dds")
      mmbuttonborder:SetHeight(cut.gui.mmbtnheight)
      mmbuttonborder:SetWidth(cut.gui.mmbtnwidth)
      mmbuttonborder:SetLayer(1)
      mmbuttonborder:EventAttach(Event.UI.Input.Mouse.Left.Click, function() cut.showhidewindow() end, "Show/Hide Pressed" )

      if cut.gui.mmbtnx == nil or cut.gui.mmbtny == nil then
         -- first run, we position in the screen center
         mmbuttonborder:SetPoint("CENTER", UIParent, "CENTER")
      else
         -- we have coordinates
         mmbuttonborder:SetPoint("TOPLEFT", UIParent, "TOPLEFT", cut.gui.mmbtnx, cut.gui.mmbtny)
      end

      -- MiniMapButton Icon
      mmbutton = UI.CreateFrame("Texture", "mmBtnIcon", mmbuttonborder)
      mmbutton:SetTexture("Rift", "loot_gold_coins.dds")
      mmbutton:SetLayer(1)
      mmbutton:SetPoint("TOPLEFT",     mmbuttonborder, "TOPLEFT",      12,  12)
      mmbutton:SetPoint("BOTTOMRIGHT", mmbuttonborder, "BOTTOMRIGHT", -12, -12)

      -- Enable Dragging
      Library.LibDraggable.draggify(mmbuttonborder, cut.updateguicoordinates)

      cut.gui.mmbtnobj   =  mmbuttonborder
   else
      mmbutton = cut.gui.mmbtnobj
   end

   return mmbutton
end
