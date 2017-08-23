--
-- Addon       _cut_layout.lua
-- Author      marcob@marcob.org
-- StartDate   30/05/2017
--
local addon, cut = ...

cut.addon               =  Inspect.Addon.Detail(Inspect.Addon.Current())["name"]
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
cut.coinname2idx        =  {}
--
cut.timer               =  {}
cut.timer.flag          =  false
cut.timer.start         =  0
cut.timer.duration      =  10  -- seconds
--
cut.shown               =  {}
cut.shown.objs          =  {}
cut.shown.objs.count    =  0
cut.shown.objs.last     =  nil
cut.shown.frames        =  {}
cut.shown.frames.count  =  0
cut.shown.frames.last   =  nil
cut.shown.todayobjs        =  {}
cut.shown.todayobjs.count  =  0
cut.shown.todayobjs.last   =  nil
cut.shown.todayframes      =  {}
cut.shown.todayframes.count=  0
cut.shown.todayframes.last =  nil
cut.shown.fullframes       =  {}
cut.shown.todayfullframes  =  {}

--
cut.frames              =  {}
--
cut.html                =  {}
cut.html.silver         =  '#c0c0c0'
cut.html.gold           =  '#ffd700'
cut.html.platinum       =  '#e5e4e2'
cut.html.white          =  '#ffffff'
cut.html.red            =  '#ff0000'
cut.html.green          =  '#00ff00'
--
cut.color               =  {}
cut.color.black         =  { 0,  0,  0, .5}
cut.color.red           =  { .8,  0,  0, .5}
cut.color.darkgrey      =  {.2, .2, .2, .5}
--
cut.session             =  {}



local function gettoday()
   local today = os.date("*t", os.time())
   print(string.format("today os.date(*t, os.time) = %s", today))

   --[[
      {year = 1998, month = 9, day = 16, yday = 259, wday = 4,
       hour = 23, min = 48, sec = 10, isdst = false}
      ]]--

   -- returns year day (yday)
--    print(string.format("today yday = %s", today.yday))
   return(today.yday)
end


local function loadvariables(_, addonname)
   if addon.name == addonname then
      if guidata then
--          cut.gui        =  guidata
         local a  =  guidata
         local key, val = nil, nil
         for key, val in pairs(a) do
            if val and key ~= minwidth and key ~= minheight and key ~= maxwidth and key ~= maxheight then
               cut.gui[key]   =  val
--                print(string.format("Importing %s: %s", key, val))
            end
         end
         cut.gui.window =  nil

      end

      -- Load old session data only if we are in the same day
      if sessiondate then
         lastsession =  sessiondate
         local today =  gettoday()
         if lastsession == today then
            if session then
               cut.session    =  session
               local flag, a, b = false, nil, nil
               for a,b in pairs(cut.session) do flag = true break end
               cut.todayinit  =  flag
            end
         end
      end

   end
   return
end

local function savevariables(_, addonname)
   if addon.name == addonname then

      -- Save GUI prefrences
      local a = cut.gui
      a.window    =  nil
      a.minwidth  =  nil
      a.minheight =  nil
      a.maxwidth  =  nil
      a.maxheight =  nil
      guidata     =  a

      -- Save Session data
--       -- Purge "anomaly" currencies from saved ones
--       if cut.session["Affinity"] then cut.session["Affinity"] = nil end
--       if cut.session["Prize Tickets"] then cut.session["Prize Tickets"] = nil end
--       session     =  cut.todaybase

      -- we save only what has really changed
      local tobesaved   =  {}
      for var, tbl in pairs(cut.todaybase) do
         if cut.todaybase[var].stack ~= cut.coinbase[var].stack then
            tobesaved[var] = cut.todaybase[var]
         end
      end
      session     =  tobesaved
      sessiondate =  gettoday()
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
      print(string.format("CuT: %s =>(%s) (%s) (%s)", currency, detail.name, detail.stack, detail.icon))

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
            cut.updatecurrencies(var, newvalue)
         end
      else
         local detail = Inspect.Currency.Detail(cut.coinname2idx[var])
         cut.coinbase[var] =  { stack=detail.stack, icon=detail.icon, id=detail.id }
         cut.updatecurrencies(var, val)
      end


      -- Whole Day Session value Update
      if table.contains(cut.todaybase, var) then
         if val   ~= (cut.todaybase[var].stack or 0) then
            local newvalue =  val - (cut.todaybase[var].stack or 0)
            cut.updatecurrenciestoday(var, newvalue)
         end
      else
         local detail = Inspect.Currency.Detail(cut.coinname2idx[var])
         cut.todaybase[var] =  { stack=detail.stack, icon=detail.icon, id=detail.id }
         cut.updatecurrenciestoday(var, val)
      end

   end
end

local function initcoinbase()

   if not cut.baseinit then

      while not cut.baseinit do
--          print("INIT COIN BASE: BEGIN")
         cut.coinbase   =  getcoins()

         -- do we really have a coin base? let's count
         local cnt = 0
         local a,b = nil, nil
         for a,b in pairs(cut.coinbase) do cnt = cnt + 1 break end

         if cnt > 0 then
            print("INIT COIN BASE: DONE")
            cut.baseinit   =  true

            if not cut.todayinit then
               cut.todaybase  =  cut.coinbase
               cut.todayinit  =  true
            end

            -- if we have session, we restore it in the today pane
            local currency =  nil
            local value    =  nil
            for currency, tbl in pairs(cut.session) do
--                print(string.format("LOAD: currency=%s tbl=%s", currency, tbl))
               if cut.coinbase[currency] then
                  value =  cut.coinbase[currency].stack - tbl.stack
--                   print(string.format("LOAD: tbl.stack=%s - cut.coinbase[currency].stack=%s => %s", tbl.stack, cut.coinbase[currency].stack, value))
               else
                  value =  tbl.stack
--                   print(string.format("LOAD: currency=%s value=%s", currency, value))
               end

               -- value = 0      => there's been no variation in value since when we saved
               if value ~= 0 then
                  cut.updatecurrenciestoday(currency, value)
               end
            end
            -- end restore

            -- we are ready for events
            Command.Event.Attach(Event.Currency, currencyevent, "CuT Currency Event")
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

Command.Event.Attach(Event.Unit.Availability.Full,          initcoinbase,     "CuT: Init Coin Base")
Command.Event.Attach(Event.Addon.SavedVariables.Load.End,   loadvariables,    "CuT: Load Variables")
Command.Event.Attach(Event.Addon.SavedVariables.Save.Begin, savevariables,    "CuT: Save Variables")

--[[Error: CuT/_cut_init.lua:213: attempt to index local 'detail' (a nil value)
    In CuT / CuT Currency Event, event Event.Currency
   stack traceback:
   [C]: in function '__index'
   CuT/_cut_init.lua:213: in function <CuT/_cut_init.lua:178>
]]--
