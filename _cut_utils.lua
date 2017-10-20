--
-- Addon       _cut_utils.lua
-- Author      marcob@marcob.org
-- StartDate   28/05/2017
--
local addon, cut = ...


function cut.round(num, digits)
   local floor = math.floor
   local mult = 10^(digits or 0)

   return floor(num * mult + .5) / mult
end

function cut.printmoney(money)

   local sign     =  nil
   if money < 0 then
      sign = "-"
      money = money * -1
   end

   local s        =  money
   local g        =  0
   local p        =  0
   local t        =  ""
   local size     =  0

   if s  == nil   then  s = 0 end

   if s > 0 then
      while s > 99 do
         s = s -100
         g = g + 1
      end

      while g > 99 do
         g = g - 100
         p = p + 1
      end
   end

   -- silver
   t = "<font color=\'"..cut.html.white.."\'>"..tostring(s).."</font><font color=\'"..cut.html.silver.."\'>s</font>"
   -- gold
   if g > 0 then
      t = "<font color=\'"..cut.html.white.."\'>"..tostring(g).."</font><font color=\'"..cut.html.gold.."\'>g</font>"..t
   end
   -- platinum
   if p > 0 then
      t = "<font color=\'"..cut.html.white.."\'>"..tostring(p).."<font color=\'"..cut.html.platinum.."\'>p</font>"..t
   end

   if sign then
      t = "<font color=\'"..cut.html.red.."\'>"..sign.."</font>"..t
   else
      t = "<font color=\'"..cut.html.green.."\'>+</font>"..t
   end

   return(t)
end

function table.contains(table, element)
   for var, _ in pairs(table) do
      if var == element then
         return true
      end
   end
   return false
end


function cut.updateguicoordinates(win, newx, newy)

   if win ~= nil then
      local winName = win:GetName()

      if winName == "mmBtnIconBorder" then
         cut.gui.mmbtnx =  cut.round(newx)
         cut.gui.mmbtny =  cut.round(newy)
      end
   end

   return
end

function cut.showhidewindow(params)
   if cut.gui.visible == true then  cut.gui.visible   =  false
                              else  cut.gui.visible   =  true
   end

   cut.gui.window:SetVisible(cut.gui.visible)

   return
end
