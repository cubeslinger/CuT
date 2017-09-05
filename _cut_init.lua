--
-- Addon       _cut_layout.lua
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
--
cut.startupinit         =  false
cut.daysave           =  {}
cut.weeksave            =  {}
--
cut.coinbase            =  {}
cut.baseinit            =  false
cut.todaybase           =  {}
cut.todayinit           =  false
cut.weekbase            =  {}
cut.weekinit            =  false
cut.weekday             =  0
cut.coinname2idx        =  {}
--
cut.timer               =  {}
cut.timer.flag          =  false
cut.timer.start         =  0
cut.timer.duration      =  60  -- seconds
--
cut.shown               =  {}
cut.shown.frames        =  {}
cut.shown.frames.count  =  0
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
cut.shown.panellabel    =  {  [1]   =  "Current",
                              [2]   =  "<font color=\'"  .. cut.html.red   .. "\'>Today</font>",
                              [3]   =  "<font color=\'"  .. cut.html.green .. "\'>Week</font>"
                           }
--
cut.frames              =  {}
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
      if not cut.startupinit then
         if guidata then
            local a  =  guidata
            local key, val = nil, nil
            for key, val in pairs(a) do
               if val and key ~= minwidth and key ~= minheight and key ~= maxwidth and key ~= maxheight and key ~= height then
                  cut.gui[key]   =  val
   --                print(string.format("Importing %s: %s", key, val))
               end
            end
            cut.gui.window =  nil
         end

         local dayoftheyear =  getdayoftheyear()

         -- Load Today session data only if we are in the same day
         if today then
            lastsession =  today
            if lastsession == dayoftheyear then
               if todaybase then
                  cut.todaybase    =  todaybase
                  local flag, a, b = false, nil, nil
                  for a,b in pairs(cut.todaybase) do flag = true break end
                  cut.todayinit  =  flag
                  cut.daysave  =  cut.todaybase
               end
            end
         end

         -- Load Week session data only if we are in the same week
         if weekday then
            if (dayoftheyear - weekday) <= 7 then
               if weekbase then
                  cut.weekbase   =  weekbase
                  local flag, a, b = false, nil, nil
                  for a,b in pairs(cut.weekbase) do flag = true break end
                  cut.weekinit   =  flag
                  cut.weeksave  =  cut.weekbase
               end
               cut.weekday =  weekday
            else
               cut.weekday  =  getdayoftheyear()
            end
         end
      end
   end

   return
end

function cut.savevariables(_, addonname)
   if addon.name == addonname then

      -- Save GUI prefrences
      local a = cut.gui
      a.window    =  nil
      a.minwidth  =  nil
      a.minheight =  nil
      a.maxwidth  =  nil
      a.maxheight =  nil
      a.height    =  nil
      guidata     =  a

      -- Save Today Session data
      -- workaround for currencies that at first appearence have stack=0
      -- like: Affinity, Ticket Prize, ...
      local tbl   =  {}
      local a,b   =  nil, nil
      for a,b in pairs(cut.daysave) do
         if b.stack ~= 0 then
            tbl[a]   =  b
         end
      end
      todaybase   =  tbl
      today       =  getdayoftheyear()

      -- Save Week Session data
      -- workaround for currencies that at first appearence have stack=0
      -- like: Affinity, Ticket Prize, ...
      local tbl   =  {}
      local a,b   =  nil, nil
      for a,b in pairs(cut.weeksave) do
         if b.stack ~= 0 then
            tbl[a]   =  b
         end
      end
      weekbase =  tbl
      weekday  =  getdayoftheyear()

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

function cut.updateothers(var, val)
   print("-------------------------------------")
   print(string.format("cut.updateothers var=%s val=%s", var, val))
--    print(string.format("cut.todaybase[var].stack=%s", cut.todaybase[var].stack))

   if table.contains(cut.todaybase, var) then
      print(string.format("PRE  cut.todaybase[var].stack=%s", cut.todaybase[var].stack))
      print(string.format("PRE  cut.daysave[var].stack=%s", cut.daysave[var].stack))
      local a = cut.todaybase[var].stack
      print(string.format("MID  cut.todaybase[var].stack=%s a=%s", cut.todaybase[var].stack, a))
      print(string.format("MID  cut.daysave[var].stack=%s a=%s", cut.daysave[var].stack, a))
      cut.daysave[var].stack   =  val + a
      print(string.format("POST cut.todaybase[var].stack=%s", cut.todaybase[var].stack))
      print(string.format("POST cut.daysave[var].stack=%s", cut.daysave[var].stack))
      cut.updatecurrenciestoday(var, cut.daysave[var].stack, cut.todaybase[var].id)
      print("updatecurrenciestoday update: "..var.." "..cut.daysave[var].stack)
   else
      cut.todaybase[var]   =  { stack=val, icon=cut.coinbase[var].icon, id=cut.coinbase[var].id, smax=cut.coinbase[var].stackMax }
      cut.daysave[var]  =  cut.todaybase[var]
      cut.updatecurrenciestoday(var, val, cut.coinbase[var].id)
      print("updatecurrenciestoday create: "..var.." "..val)
   end

--    print(string.format("cut.weekbase[var].stack=%s", cut.weekbase[var].stack))
   if table.contains(cut.weekbase, var) then
      cut.weeksave[var].stack =  cut.weekbase[var].stack + val
      cut.updatecurrenciesweek(var, cut.weeksave[var].stack, cut.weekbase[var].id)
      print("updatecurrenciesweek update: "..var.." "..cut.weekbase[var].stack)
   else
      cut.weekbase[var]    =  { stack=val, icon=cut.coinbase[var].icon, id=cut.coinbase[var].id, smax=cut.coinbase[var].stackMax }
      cut.weeksave[var]   =  cut.weekbase[var]
      cut.updatecurrenciesweek(var, val, cut.coinbase[var].id)
      print("updatecurrenciesweek create: "..var.." "..val)
   end

--    print(string.format("cut.todaybase[var].stack=%s", cut.todaybase[var].stack))
   print("-------------------------------------")

   return
end


local function currencyevent()
      print("CURRENCY EVENT")

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
               cut.updateothers(var, newvalue)
               print("currencyevent (1) ["..var.."]=>"..newvalue.."]")
            end
         end
      else
         -- we found nothing let's create from scratch this new currency
         local detail = Inspect.Currency.Detail(cut.coinname2idx[var])
         cut.coinbase[var] =  { stack=detail.stack, icon=detail.icon, id=detail.id, smax=detail.stackMax }
         cut.updatecurrencies(var, val, detail.id)
         cut.updateothers(var, val)
         print("currencyevent (2) ["..var.."]=["..val.."]")
      end
      --[[ CURRENT  -------------------------------------- END ]]--
            end

      -- set the right size for pane
      cut.resizewindow(cut.shown.panel)

      return
   end

function cut.initcoinbase()

   if not cut.baseinit then

      while not cut.baseinit do
         cut.coinbase   =  getcoins()

         -- do we really have a coin base? let's count
         local cnt, a,b = 0, nil, nil
         for a,b in pairs(cut.coinbase) do cnt = cnt + 1 break end

         if cnt > 0 then
            cut.baseinit   =  true
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

function cut.startmeup()

   if not cut.startupinit then

      -- if we have session data, we restore it in the today pane
      if cut.todayinit then
         for currency, tbl in pairs(cut.todaybase) do
            if tbl.stack   ~= 0  then  cut.updatecurrenciestoday(currency, tbl.stack, tbl.id)   end
         end
      end

      -- if we have week data, we restore it in the Week panel
      if cut.weekinit then
         for currency, tbl in pairs(cut.weekbase) do
            if tbl.stack ~= 0 then  cut.updatecurrenciesweek(currency, tbl.stack, tbl.id) end
         end
      end

      -- let's initialize Current database
      cut.initcoinbase()

      -- since Today and Week Panes start hidden, the shown empty window would be too tall.
      -- so i resize it accordingly
      if cut.gui.window then cut.resizewindow(cut.shown.panel) end

      -- say "Hello World"
      Command.Console.Display("general", true, string.format("%s - v.%s", cut.html.title, cut.version), true)

      -- ...don't come around here no more...
      cut.startupinit   =  true

      -- we are ready for events
      Command.Event.Attach(Event.Currency, currencyevent, "CuT Currency Event")

   end

   return
end

function cut.resizewindow(panel)

   if table.contains(cut.gui, "window") then
      local bottom   =  cut.gui.window:GetTop() + cut.gui.font.size

      if panel == 1 then if cut.shown.frames.last        then bottom = cut.shown.frames.last:GetBottom()       end end
      if panel == 2 then if cut.shown.todayframes.last   then bottom = cut.shown.todayframes.last:GetBottom()  end end
      if panel == 3 then if cut.shown.weekframes.last    then bottom = cut.shown.weekframes.last:GetBottom()   end end

      cut.gui.window:SetHeight( (bottom - cut.gui.window:GetTop() ) + cut.gui.borders.top + cut.gui.borders.bottom*4)
   end

   return
end
