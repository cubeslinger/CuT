--
-- Addon       _cut_init.lua
-- Author      marcob@marcob.org
-- StartDate   30/05/2017
--
local addon, cut = ...

cut.addon               =  Inspect.Addon.Detail(Inspect.Addon.Current())["name"]
cut.version             =  Inspect.Addon.Detail(Inspect.Addon.Current())["toc"]["Version"]
--
cut.gui                 =  {}
cut.gui.x               =  nil
cut.gui.y               =  nil
cut.gui.width           =  280
cut.gui.minwidth        =  100
cut.gui.minheight       =  20
cut.gui.maxwidth        =  1000
cut.gui.maxheight       =  500
cut.gui.borders         =  {}
cut.gui.borders.left    =  2
cut.gui.borders.right   =  2
cut.gui.borders.bottom  =  2
cut.gui.borders.top     =  2
cut.gui.window          =  nil
cut.gui.font            =  {}
cut.gui.font.size       =  12
cut.gui.mmbtnx          =  nil
cut.gui.mmbtny          =  nil
cut.gui.mmbtnobj        =  nil
cut.gui.visible         =  false
cut.gui.mmbtnwidth      =  38
cut.gui.mmbtnheight     =  38

--
cut.init                =  {}
cut.init.day            =  false
cut.init.week           =  false
cut.init.coinbase       =  false
cut.init.startup        =  false
cut.init.newweek        =  false
cut.init.notorietytoday =  false
cut.init.notorietyweek  =  false
--
cut.deltas              =  {}
cut.notorietydeltas     =  {}
--
cut.save                =  {}
cut.save.day            =  {}
cut.save.week           =  {}
cut.save.notorietytoday =  {}
cut.save.notorietyweek  =  {}
--
cut.coinbase            =  {}
cut.today               =  0
cut.weekday             =  0
cut.coinname2idx        =  {}
cut.notorietyname2idx   =  {}
cut.notorietybase       =  {}
--
cut.timer               =  {}
cut.timer.flag          =  false
cut.timer.start         =  0
cut.timer.duration      =  60  -- seconds
--
cut.shown               =  {}
cut.shown.frames        =  {}
cut.shown.frames.last   =  nil
cut.shown.currenttbl    =  {}
--
cut.shown.todayframes      =  {}
cut.shown.todayframes.last =  nil
cut.shown.todaytbl         =  {}
--
cut.shown.weekframes       =  {}
cut.shown.weekframes.last  =  nil
cut.shown.weektbl          =  {}
--
cut.shown.currentnotorietyframes       =  {}
cut.shown.currentnotorietyframes.last  =  nil
cut.shown.currentnotorietytbl          =  {}
--
cut.shown.todaynotorietyframes      =  {}
cut.shown.todaynotorietyframes.last =  nil
cut.shown.todaynotorietytbl         =  {}
--
cut.shown.weeknotorietyframes       =  {}
cut.shown.weeknotorietyframes.last  =  nil
cut.shown.weeknotorietytbl          =  {}

--
cut.html                =  {}
cut.html.silver         =  '#c0c0c0'
cut.html.gold           =  '#ffd700'
cut.html.platinum       =  '#e5e4e2'
cut.html.white          =  '#ffffff'
cut.html.red            =  '#ff0000'
cut.html.green          =  '#00ff00'
cut.html.title          =  "<font color=\'"..cut.html.green.."\'>C</font><font color=\'"..cut.html.white.."\'>u</font><font color=\'"..cut.html.red.."\'>T</font>"
--
cut.shown.panel         =  1
cut.shown.windowinfo    =  nil
cut.shown.windowtitle   =  nil
cut.shown.panellabel    =  {  [1]   =  "Current Currencies",
                              [2]   =  "<font color=\'"  .. cut.html.red   .. "\'>Today Currencies</font>",
                              [3]   =  "<font color=\'"  .. cut.html.green .. "\'>Week Currencies</font>",
                              [4]   =  "Current Notoriey",
                              [5]   =  "<font color=\'"  .. cut.html.red   .. "\'>Today Notoriety</font>",
                              [6]   =  "<font color=\'"  .. cut.html.green .. "\'>Week Notoriety</font>"
                           }
--
cut.frames              =  {}
cut.frames.container    =  {}
--
cut.color               =  {}
cut.color.black         =  {  0,  0,  0, .5}
cut.color.red           =  { .2,  0,  0, .5}
cut.color.green         =  { .0, .2,  0, .5}
cut.color.darkgrey      =  { .2, .2, .2, .5}
--
cut.session             =  {}



local function getdayoftheyear()
   local today = os.date("*t", os.time())
   return(today.yday)
end


function cut.loadvariables(_, addonname)
   if addon.name == addonname then

      if not cut.init.startup then

         if guidata then
            local a  =  guidata
            local key, val = nil, nil
            for key, val in pairs(a) do
               if val and  key ~= minwidth    and  key ~= minheight  and key ~= maxwidth    and key ~= maxheight  and
                           key ~= height      and  key ~= mmbtnobj   and key ~= mmbtnheight and key ~= mmbtnwidth then
                  cut.gui[key]   =  val
   --                print(string.format("Importing %s: %s", key, val))
               end
            end
            cut.gui.window =  nil
         end

         local dayoftheyear =  getdayoftheyear()

         -- Load Today session data only if we are in the same day
         cut.today   =  dayoftheyear
         if today then
            lastsession =  today
            if lastsession == dayoftheyear then
               if todaybase then
                  cut.save.day   =  todaybase
                  local flag, a, b = false, nil, nil
                  for a,b in pairs(cut.save.day) do flag = true break end
                  cut.init.day  =  flag
               end
            else
               cut.save.day   =  {}
               cut.init.day   =  true
            end
         else
            cut.save.day   =  {}
            cut.init.day   =  true
         end

         -- Load Week session data only if we are in the same week
         if weekday then
            if (dayoftheyear - weekday) <= 7 then
               if weekbase then
                  cut.save.week   =  weekbase
                  local flag, a, b = false, nil, nil
                  for a,b in pairs(cut.save.week) do flag = true break end
                  cut.init.week   =  flag
               end
               cut.weekday =  weekday
            else
               cut.weekday    =  getdayoftheyear()
               cut.init.week  =  true
               cut.save.week  =  {}
            end
         else
            cut.weekday    =  getdayoftheyear()
            cut.init.week  =  true
            cut.save.week  =  {}
         end


         -- Load Today Notoriety session data only if we are in the same day
         if notorietyday then
            if notorietyday   == dayoftheyear then
               if todaynotorietybase then
                  cut.save.notorietytoday   =  notorietytoday
                  local flag, a, b = false, nil, nil
                  for a,b in pairs(cut.save.notorietytoday) do flag = true break end
                  cut.init.notorietytoday  =  flag
               end
            else
               cut.save.notorietytoday =  {}
               cut.init.notorietytoday =  true
            end
         else
            cut.save.notorietytoday   =  {}
            cut.init.notorietytoday   =  true
         end

         -- Load Notoriety Week session data only if we are in the same week
         if notorietyday then
            if (dayoftheyear - notorietyday) <= 7 then
               if notorietyweek then
                  cut.save.notorietyweek   =  notorietyweek
                  local flag, a, b = false, nil, nil
                  for a,b in pairs(cut.save.notorietyweek) do flag = true break end
                  cut.init.notorietyweek   =  flag
               end
               cut.notorietyweekday    =  notorietyweekday
            else
               cut.notorietyweekday    =  getdayoftheyear()
               cut.init.notorietyweek  =  true
               cut.save.notorietyweek  =  {}
            end
         else
            cut.notorietyweekday    =  getdayoftheyear()
            cut.init.notorietyweek  =  true
            cut.save.notorietyweek  =  {}
         end
      end
   end

   return
end

function cut.savevariables(_, addonname)
   if addon.name == addonname then

      -- Save GUI prefrences
      local a = cut.gui
      a.window       =  nil
      a.minwidth     =  nil
      a.minheight    =  nil
      a.maxwidth     =  nil
      a.maxheight    =  nil
      a.height       =  nil
      a.mmbtnobj     =  nil
      a.mmbtnheight  =  nil
      a.mmbtnwidth   =  nil

      -- Save Window position, size, ...
      guidata     =  a

      -- Save Currencies Today Session data
      local tbl   =  {}
      local a,b   =  nil, nil
      for a,b in pairs(cut.save.day) do
         tbl[a]   =  b
         if cut.deltas[a] then
            tbl[a].stack = tbl[a].stack + cut.deltas[a]
         end
      end

      todaybase   =  tbl
      today       =  getdayoftheyear()

      -- Save Currencies Week Session data
      local tbl   =  {}
      local a,b   =  nil, nil
      for a,b in pairs(cut.save.week) do
         tbl[a]   =  b
         if cut.deltas[a] then
            tbl[a].stack = tbl[a].stack + cut.deltas[a]
         end
      end

      weekbase =  tbl
      weekday  =  cut.weekday

      -- Save Notorieties Today Session data
      local tbl   =  {}
      local a,b   =  nil, nil
      for a,b in pairs(cut.save.notorietytoday) do
         tbl[a]   =  b
         if cut.notorietydeltas[a] then
            tbl[a].stack = tbl[a].stack + cut.notorietydeltas[a]
         end
      end

      notorietytoday =  tbl
      notorietyday   =  getdayoftheyear()

      -- Save Notorieties Week Session data
      local tbl   =  {}
      local a,b   =  nil, nil
      for a,b in pairs(cut.save.notorietyweek) do
         tbl[a]   =  b
         if cut.notorietydeltas[a] then
            tbl[a].stack = tbl[a].stack + cut.notorietydeltas[a]
         end
      end

      notorietyweek     =  tbl
      notorietyweekday  =  cut.weekday


   end

   return
end

local function waitforcoins()

   local now = Inspect.Time.Frame()

-- first run
   if cut.timer.start == nil then
      cut.timer.start = now
      cut.timer.flag  = true
   else
      if (now - cut.timer.start) >= cut.timer.duration then
         cut.timer.flag    =  false
         cut.timer.start   =  nil
         Command.Event.Detach(Event.System.Update.Begin, waitforcoins,  "Event.System.Update.Begin")
      end
   end

   return
end

local function getcoins()
   local coins    =  {}
   local currency =  nil
   for currency, _ in pairs(Inspect.Currency.List()) do
      local detail = Inspect.Currency.Detail(currency)
      coins[detail.name] = { stack=detail.stack, icon=detail.icon, id=detail.id, smax=detail.stackMax }
      --       print(string.format("CuT: %s =>(%s) (%s) (%s) stackMax=%s", currency, detail.name, detail.stack, detail.icon, detail.stackMax))

      cut.coinname2idx[detail.name] =  currency
   end

   return coins
end

local function getnotorieties()
   local notorieties    =  {}
   local notoriety =  nil
   for notoriety, _ in pairs(Inspect.Faction.List()) do
      local detail = Inspect.Faction.Detail(notoriety)
      if detail then
         notorieties[detail.name] = { stack=detail.notoriety, id=detail.id }

   --       local a,b = nil, nil
   --       for a,b in pairs(detail) do
   --          print(string.format("CuT Notoriety:   key=(%s) val=(%s)", a, b))
   --       end
   --
   --       print(string.format("CuT Notoriety: id=%s =>(name=%s) (stack=%s)", notorieties[detail.name].id, detail.name, notorieties[detail.name].stack))

         cut.notorietyname2idx[detail.name] =  notoriety
      else
         print(string.format("Notoriety detail is NIL for: (%s)", notoriety))
      end
   end

   return notorieties
end

-- local function currencyevent(handle, params)
function cut.currencyevent(handle, params)
--    if params then
--       for a,b in pairs(params) do
--          print(string.format("CuT: currencyevent params key=%s value=%s", a, b))
--       end
--    else
--       print(string.format("CuT: currencyevent params handle=%s params=%s", handle, params))
--    end
--       print("CURRENCY EVENT")

   local current  =  getcoins()
   local var, val =  nil, nil, nil
   local tbl      =  {}
   local updated  =  false

   -- find changes
   for var, tbl in pairs(current) do
      val   =  tbl.stack

      --[[ -- CURRENT  -------------------------------------- BEGIN ]]--
            -- Current Session value Update
      if table.contains(cut.coinbase, var) then
         if cut.coinbase[var].stack == 0 then
            cut.coinbase[var].stack =  val
            --             print(string.format("Rebased currency: %s from 0 to %s.", var, val))
         else
            if val   ~= (cut.coinbase[var].stack) then
               local newvalue =  val - (cut.coinbase[var].stack)
               cut.updatecurrencies(var, newvalue, cut.coinbase[var].id)
               cut.deltas[var]   =  newvalue
--                print("currencyevent (1) ["..var.."]=>"..newvalue.."]==>["..cut.deltas[var].."]")
            end
         end
      else
         -- we found nothing let's create from scratch this new currency
         local detail = Inspect.Currency.Detail(cut.coinname2idx[var])
         cut.coinbase[var] =  { stack=detail.stack, icon=detail.icon, id=detail.id, smax=detail.stackMax }
         cut.updatecurrencies(var, val, detail.id)
         cut.deltas[var]   =  val
--          print("currencyevent (2) ["..var.."]=["..val.."]==>["..cut.deltas[var].."]")
      end
      --[[ CURRENT  -------------------------------------- END ]]--
   end

   -- set the right size for pane
   cut.resizewindow(cut.shown.panel)

   return
end

-- local function notorietyevent(handle, params)
function cut.notorietyevent(handle, params)
--    if params then
--       for a,b in pairs(params) do
--          print(string.format("CuT: currencyevent params key=%s value=%s", a, b))
--       end
--    else
--       print("CuT: notorietyevent params is NIL")
--       print(string.format("CuT: currencyevent params handle=%s params=%s", handle, params))
--    end

   local current  =  getnotorieties()
   local var, val =  nil, nil
   local tbl      =  {}
   local updated  =  false

   -- find changes
   for var, tbl in pairs(current) do
      val   =  tbl.stack

      --[[ -- CURRENT  -------------------------------------- BEGIN ]]--
            -- Current Session value Update
      if table.contains(cut.notorietybase, var) then
         if cut.notorietybase[var].stack == 0 then
            cut.notorietybase[var].stack =  val
            --             print(string.format("Rebased notoriety: %s from 0 to %s.", var, val))
         else
            if val   ~= (cut.notorietybase[var].stack) then
               local newvalue =  val - (cut.notorietybase[var].stack)
               --                cut.updatecurrencies(var, newvalue, cut.notorietybase[var].id)
               cut.updatenotoriety(var, newvalue, cut.notorietybase[var].id)
               cut.notorietydeltas[var]   =  newvalue
               --                print("notorietyevent (1) ["..var.."]=>"..newvalue.."]==>["..cut.notorietydeltas[var].."]")
            end
         end
      else
         -- we found nothing let's create from scratch this new currency
         local detail = Inspect.Faction.Detail(cut.notorietyname2idx[var])
         cut.notorietybase[var] =  { stack=detail.notoriety, id=detail.id }
         cut.updatenotoriety(var, val, detail.id)
         cut.notorietydeltas[var]   =  val
         --          print("notorietyevent (2) ["..var.."]=["..val.."]==>["..cut.notorietydeltas[var].."]")
      end
      --[[ CURRENT  -------------------------------------- END ]]--
   end

   -- set the right size for pane
   cut.resizewindow(cut.shown.panel)

   return
end


function cut.initcoinbase()

   if not cut.init.coinbase then

      while not cut.init.coinbase do
         cut.coinbase   =  getcoins()

         -- do we really have a coin base? let's count
         local cnt, a,b = 0, nil, nil
         for a,b in pairs(cut.coinbase) do cnt = cnt + 1 break end

         if cnt > 0 then
            cut.init.coinbase   =  true
         else
            -- we don't have data yet, we wait cut.timer.duration secs...
            if not cut.timer.flag then
               Command.Event.Attach(Event.System.Update.Begin, waitforcoins,  "Event.System.Update.Begin")
            end
         end
      end
   end

   return
end

function cut.initnotorietybase()

   if not cut.init.notorietybase then

      while not cut.init.notorietybase do
         cut.notorietybase   =  getnotorieties()

         -- do we really have a notoriety base? let's count
         local cnt, a, b = 0, nil, nil
         for a,b in pairs(cut.notorietybase) do cnt = cnt + 1 break end

--          if cnt > 0 then
            cut.init.notorietybase   =  true
--          else
--             -- we don't have data yet, we wait cut.timer.duration secs...
--             if not cut.timer.flag then
--                Command.Event.Attach(Event.System.Update.Begin, waitfornotorietys,  "Event.System.Update.Begin")
--             end
--          end
      end
   end

   return
end

function cut.startmeup()

   if not cut.init.startup then

      -- Create/Display/Hide Mini Map Button Window
      if cut.gui.mmbtnobj  == nil then
         cut.gui.mmbtnobj  =  cut.createminimapbutton()
         cut.gui.mmbtnobj:SetVisible(true)
      end

      -- if we have session data, we restore it in the today pane
      if cut.init.day then
         for currency, tbl in pairs(cut.save.day) do
            if tbl.stack   ~= 0  then  cut.updatecurrenciestoday(currency, tbl.stack, tbl.id)   end
         end
      end

      -- if we have week data, we restore it in the Week panel
      if cut.init.week then
         for currency, tbl in pairs(cut.save.week) do
            if tbl.stack ~= 0 then  cut.updatecurrenciesweek(currency, tbl.stack, tbl.id) end
         end
      end

      -- if we have Notoriety session data, we restore it in the Notoriety today pane
      if cut.init.notorietyday then
         for currency, tbl in pairs(cut.save.notorietyday) do
            if tbl.stack   ~= 0  then  cut.updatenotorietytoday(currency, tbl.stack, tbl.id)   end
         end
      end

      -- if we have Notoriety week data, we restore it in the Notoriety Week panel
      if cut.init.notorietyweek then
         for currency, tbl in pairs(cut.save.notorietyweek) do
            if tbl.stack ~= 0 then  cut.updatenotorietyweek(currency, tbl.stack, tbl.id) end
         end
      end


      -- let's initialize Current Currencies database
      cut.initcoinbase()

      -- let's initialize Current Notorieties database
      cut.initnotorietybase()

      -- create window if needed
      if not cut.gui.window then cut.gui.window = cut.createwindow() end

      -- since Today and Week Panes start hidden, the shown empty window would be too tall.
      -- so i resize it accordingly
      if cut.gui.window then cut.resizewindow(cut.shown.panel) end

      -- say "Hello World"
      Command.Console.Display("general", true, string.format("%s - v.%s", cut.html.title, cut.version), true)

      -- restore user defined window visibility
      cut.gui.window:SetVisible(cut.gui.visible)

      -- ...don't come around here no more...
      cut.init.startup   =  true

--       -- TEST -- BEGIN
--       -- Show Available Currency Categories
--       local a, b = nil, nil
--       local c, d = nil, nil
--       for a, b in pairs(Inspect.Currency.Category.List()) do
--          local id, tbl = nil, nil
--          tbl  =  Inspect.Currency.Category.Detail(a)
--          print(string.format("Name=[%s], ID=[%s]", tbl.name, tbl.id))
--       end
--       -- TEST -- END

      -- we are ready for events
--       Command.Event.Attach(Event.Currency,            function(params) currencyevent(params)    end,    "CuT Currency Event")
--       Command.Event.Attach(Event.Faction.Notoriety,   function(params) notorietyevent(params)   end,   "CuT Notoriety Event")
      Command.Event.Attach(Event.Currency,            function(handle, params) cut.currencyevent(handle, params) end,    "CuT Currency Event")
      Command.Event.Attach(Event.Faction.Notoriety,   function(handle, params) cut.notorietyevent(handle, params) end,   "CuT Notoriety Event")


   end

   return
end

function cut.resizewindow(panel)

   if table.contains(cut.gui, "window") then
      local bottom   =  cut.gui.window:GetTop() + cut.gui.font.size

      if panel == 1 then if cut.shown.frames.last                 then bottom = cut.shown.frames.last:GetBottom()                   end end
      if panel == 2 then if cut.shown.todayframes.last            then bottom = cut.shown.todayframes.last:GetBottom()              end end
      if panel == 3 then if cut.shown.weekframes.last             then bottom = cut.shown.weekframes.last:GetBottom()               end end
      if panel == 4 then if cut.shown.currentnotorietyframes.last then bottom = cut.shown.currentnotorietyframes.last:GetBottom()   end end
      if panel == 5 then if cut.shown.todaynotorietyframes.last   then bottom = cut.shown.todaynotorietyframes.last:GetBottom()     end end
      if panel == 6 then if cut.shown.weeknotorietyframes.last    then bottom = cut.shown.weeknotorietyframes.last:GetBottom()      end end

      cut.gui.window:SetHeight( (bottom - cut.gui.window:GetTop() ) + cut.gui.borders.top + cut.gui.borders.bottom*4)
   end

   return
end
