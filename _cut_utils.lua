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
   
   local silver   =  '#c0c0c0'
   local gold     =  '#ffd700'
   local platinum =  '#e5e4e2'
   local white    =  '#ffffff'
   local red      =  '#ff0000'
   local green    =  '#00ff00'
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
   t = "<font color=\'"..white.."\'>"..tostring(s).."</font><font color=\'"..silver.."\'>s</font>"
   -- gold
   if g > 0 then
      t = "<font color=\'"..white.."\'>"..tostring(g).."</font><font color=\'"..gold.."\'>g</font>"..t
   end
   -- platinum
   if p > 0 then
      t = "<font color=\'"..white.."\'>"..tostring(p).."<font color=\'"..platinum.."\'>p</font>"..t
   end
   
   if sign then
      t = "<font color=\'"..red.."\'>"..sign.."</font>"..t
   else
      t = "<font color=\'"..green.."\'>+</font>"..t
      
   end

   return(t)
end
