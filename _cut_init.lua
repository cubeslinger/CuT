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
--
cut.timer               =  {}
cut.timer.flag          =  false
cut.timer.start         =  0
cut.timer.duration      =  1  -- seconds
--
cut.shown               =  {}
cut.shown.objs          =  {}
cut.shown.objs.count    =  0
cut.shown.objs.last     =  nil
cut.shown.frames        =  {}
cut.shown.frames.count  =  0
cut.shown.frames.last   =  nil
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
   print(string.format("today yday = %s", today.yday))
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

--          local key, val = nil, nil
--          for key, val in pairs(cut.gui) do   print(string.format("Importing cut.gui.%s: %s", key, val)) end

      end

      -- Load old session data only if we are in the same day
      if sessiondate then
         lastsession =  sessiondate
         local today =  gettoday()
         if lastsession == today then
            if session then
               cut.session = session
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
      -- Purge "anomaly" currencies from saved ones
      if cut.session["Affinity"] then cut.session["Affinity"] = nil end
      if cut.session["Prize Tickets"] then cut.session["Prize Tickets"] = nil end
      session     =  cut.session
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
   local coinlist =  {}
   local currency =  nil
   for currency, _ in pairs(Inspect.Currency.List()) do
      local detail = Inspect.Currency.Detail(currency)
      coins[detail.name] = { stack=detail.stack, icon=detail.icon, id=detail.id }

      -- added coinlist to check for new currencies
      table.insert(coinlist, currency)

      --       print(string.format("CuT: (%s) (%s) (%s)", detail.name, detail.stack, detail.icon))
   end

   return coins, coinlist
end

local function currencyevent()
--    print("CURRENCY EVENT")

   local current, currentlist =  getcoins()
   local var, val, id =  nil, nil, nil
   local tbl      =  {}

   -- find changes
   for var, tbl in pairs(current) do
      val   =  tbl.stack
      id    =  tbl.id
      --
      -- is this a NEW currency, one we have never seen before?
      -- Begin
      --
         if table.getn(cut.coinlist) ~= table.getn(currentlist) then
            local newcoin  =  nil
            local coin     =  nil
            local itsnew   =  true
            for coin in pairs (currentlist) do
               for oldcoin in pairs (cut.coinlist) do
                  if oldcoin == coin then
                     itsnew = false
                     break
                  end
               end

               if itsnew then
                  local detail = Inspect.Currency.Detail(coin)
                  cut.coinbase[detail.name] = { stack=detail.stack, icon=detail.icon, id=detail.id }
               end
            end
         end
      -- End

      if val   ~= (cut.coinbase[var].stack or 0) then
         local newvalue =  val - (cut.coinbase[var].stack or 0)
         cut.updatecurrencies(var, newvalue, id)
      end
   end
end

local function initcoinbase()

   if not cut.baseinit then

      while not cut.baseinit do
--          print("INIT COIN BASE: BEGIN")
         cut.coinbase, cut.coinlist   =  getcoins()

         -- do we really have a coin base? let's count
         local cnt = 0
         local a,b = nil, nil
         for a,b in pairs(cut.coinbase) do
            cnt = cnt + 1

            --debug
--             print(string.format("CuT: cut.coinbase[%s]=%s", a, b))
         end

         if cnt > 0 then
--             print("INIT COIN BASE: DONE")
            cut.baseinit   =  true

            -- do we need to re-base to last session?
            local oldcoin     =  nil
            local oldvalue    =  nil
            for oldcoin, oldvalue in pairs(cut.session) do
--                print(string.format("re-basing cu.session[%s] = %s", oldcoin, oldvalue))
               cut.coinbase[oldcoin].stack = cut.coinbase[oldcoin].stack + ( -1 * oldvalue)
            end


            -- we are ready for events
            Command.Event.Attach(Event.Currency, currencyevent, "CuT Currency Event")
         else
            -- we don't have data yet, we wait 1 sec...
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
