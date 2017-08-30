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
               cut.weekinit  =  flag
            end
            cut.weekday =  weekday
         else
            cut.weekday  =  getdayoftheyear()
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
      for a,b in pairs(cut.todaybase) do
         if b.stack ~= 0 then
            tbl[a]   =  b
         end
      end
      todaybase     =  tbl
      today =  getdayoftheyear()

      -- Save Week Session data
      -- workaround for currencies that at first appearence have stack=0
      -- like: Affinity, Ticket Prize, ...
      local tbl   =  {}
      local a,b   =  nil, nil
      for a,b in pairs(cut.weekbase) do
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
      coins[detail.name] = { stack=detail.stack, icon=detail.icon, id=detail.id }
--       print(string.format("CuT: %s =>(%s) (%s) (%s)", currency, detail.name, detail.stack, detail.icon))

      cut.coinname2idx[detail.name] =  currency
   end

   return coins
end

local function currencyevent()
--    print("CURRENCY EVENT")

   local current  =  getcoins()
   local var, val =  nil, nil, nil
   local tbl      =  {}

   -- find changes
   for var, tbl in pairs(current) do
      val   =  tbl.stack

      -- Current Session value Update
      if table.contains(cut.coinbase, var) then
         if val   ~= (cut.coinbase[var].stack or 0) then
            local newvalue =  val - (cut.coinbase[var].stack or 0)
            cut.updatecurrencies(var, newvalue, cut.coinbase[var].id)
         end
      else
         local newvalue =  nil
         local newicon  =  nil
         local newid    =  nil
         -- let's see if we have a baseline in Today TBL for this new value
         if table.contains(cut.todaybase, var) then
            newvalue =  val - cut.todaybase[var].stack
            newicon  =  cut.todaybase[var].icon
            newid    =  cut.todaybase[var].id
         end
         -- let's see if we have a baseline in Week TBL for this new value
         if newvalue == nil and table.contains(cut.weekbase, var) then
            newvalue =  val - cut.weekbase[var].stack
            newicon  =  cut.weekbase[var].icon
            newid    =  cut.weekbase[var].id
         end
         --
         if newvalue ~= nil then
            -- we found a base in other tables, let's use that
            cut.coinbase[var] =  { stack=newvalue, icon=newicon, id=newid }
            cut.updatecurrencies(var, newvalue, newid)
         else
            -- we found nothing let's create from scratch this new currency
            local detail = Inspect.Currency.Detail(cut.coinname2idx[var])
            cut.coinbase[var] =  { stack=detail.stack, icon=detail.icon, id=detail.id }
            cut.updatecurrencies(var, val, detail.id)
         end
      end


      -- Whole Day Session value Update
      if table.contains(cut.todaybase, var) then
         if val   ~= (cut.todaybase[var].stack or 0) then
            local newvalue =  val - (cut.todaybase[var].stack or 0)
            cut.updatecurrenciestoday(var, newvalue, cut.todaybase[var].id)
         end
      else
         local detail = Inspect.Currency.Detail(cut.coinname2idx[var])
         cut.todaybase[var] =  { stack=detail.stack, icon=detail.icon, id=detail.id }
         cut.updatecurrenciestoday(var, val, detail.id)
      end

      -- Whole Week Session value Update
      if table.contains(cut.weekbase, var) then
         if val   ~= (cut.weekbase[var].stack or 0) then
            local newvalue =  val - (cut.weekbase[var].stack or 0)
            cut.updatecurrenciesweek(var, newvalue, cut.weekbase[var].id)
         end
      else
         local detail = Inspect.Currency.Detail(cut.coinname2idx[var])
         cut.weekbase[var] =  { stack=detail.stack, icon=detail.icon, id=detail.id }
         cut.updatecurrenciesweek(var, val, detail.id)
      end

   end

   -- set the right size for pane
   cut.resizewindow(cut.shown.panel)


end

-- local function initcoinbase()
function cut.initcoinbase()

   if not cut.baseinit then

      while not cut.baseinit do
--          print("INIT COIN BASE: BEGIN")
         cut.coinbase   =  getcoins()

         -- do we really have a coin base? let's count
         local cnt = 0
         local a,b = nil, nil
         for a,b in pairs(cut.coinbase) do cnt = cnt + 1 break end

         if cnt > 0 then
--             print("INIT COIN BASE: DONE")


               -- debug
               --[[
               local a,b = nil, nil
               for a,b in pairs(cut.coinbase) do
                  print(string.format("a=%s b=%s", a, b))
                  if b then
                     local c,d = nil, nil
                     for c,d in pairs(b) do
                        print(string.format("  c=%s d=%s", c, d))
                     end
                  end
               end
               ]]--

            -- trying to get Strange Currecnies right... if it's zero at start we check again
            -- for: Affinity, Prize Tickets
            local strangecurrencies =  { "Affinity", "Prize Tickets" }
            local c                 =  nil
            for   _, c in pairs(strangecurrencies) do
               if cut.coinbase[c].stack == 0 then
                  cut.coinbase[c] = nil
--                   print(string.format("CoinBase check, removed = %s", c))
               end
            end

            cut.baseinit   =  true

            if not cut.todayinit then
               cut.todaybase  =  cut.coinbase
               cut.todayinit  =  true
            end

            -- if we have session, we restore it in the today pane
            local currency =  nil
            local value    =  0
            local id       =  nil
            for currency, tbl in pairs(cut.todaybase) do
               if cut.coinbase[currency] then
--                   print(string.format("TODAY: currency=%s stack=%s, icon=%s, id=%s", currency, cut.todaybase[currency].stack, cut.todaybase[currency].icon, cut.todaybase[currency].id))
                  value =  cut.coinbase[currency].stack - tbl.stack
                  id    =  cut.coinbase[currency].id
               end

               -- value = 0      => there's been no variation in value since when we saved
               if value ~= 0 then   cut.updatecurrenciestoday(currency, value, id)   end
            end
--             print("END restore Today data")
            -- end restore today data

            if not cut.weekinit then
               cut.weekbase  =  cut.coinbase
               cut.weekinit  =  true
            end

            -- if we have week data, we restore it in the Week panel
            local currency =  nil
            local value    =  0
            local id       =  nil
            for currency, tbl in pairs(cut.weekbase) do
               if cut.coinbase[currency] then
--                   print(string.format("WEEK: currency=%s stack=%s, icon=%s, id=%s", currency, cut.weekbase[currency].stack, cut.weekbase[currency].icon, cut.weekbase[currency].id))
                  value =  cut.coinbase[currency].stack - tbl.stack
                  id    =    cut.coinbase[currency].id
               end

               -- value = 0      => there's been no variation in value since when we saved
               if value ~= 0 then   cut.updatecurrenciesweek(currency, value, id) end
            end
--             print("END restore Week data")
            -- end restore week data


            -- since Today Pane starts hidden, the shown empty window would be too tall
            -- so i resize it accordingly
            if cut.gui.window then cut.resizewindow(cut.shown.panel) end

            -- we are ready for events
            Command.Event.Attach(Event.Currency, currencyevent, "CuT Currency Event")

            -- say "Hello World"
            Command.Console.Display("general", true, string.format("%s - v.%s", cut.html.title, cut.version), true)

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

function cut.resizewindow(panel)

   local bottom   =  cut.gui.window:GetTop() + cut.gui.font.size

   if panel == 1 then if cut.shown.frames.last        then bottom = cut.shown.frames.last:GetBottom()       end end
   if panel == 2 then if cut.shown.todayframes.last   then bottom = cut.shown.todayframes.last:GetBottom()  end end
   if panel == 3 then if cut.shown.weekframes.last    then bottom = cut.shown.weekframes.last:GetBottom()   end end

   cut.gui.window:SetHeight( (bottom - cut.gui.window:GetTop() ) + cut.gui.borders.top + cut.gui.borders.bottom*4)

   return
end

--[[
Error: CuT/_cut_init.lua:241: attempt to index a nil value
    In CuT / CuT Currency Event, event Event.Currency
stack traceback:
	[C]: in function '__index'
	CuT/_cut_init.lua:241: in function <CuT/_cut_init.lua:218>    
    ]]--
