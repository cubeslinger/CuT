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
cut.gui.borders         =  {}
cut.gui.borders.left    =  4
cut.gui.borders.right   =  4
cut.gui.borders.bottom  =  4
cut.gui.borders.top     =  4
cut.gui.window          =  nil
cut.gui.font            =  {}
cut.gui.font.size       =  14
cut.gui.font.name       =  "fonts/MonospaceTypewriter.ttf"
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


function loadvariables(_, addonname)
   if addon.name == addonname then
      if guidata then
         cut.gui        =  guidata
         cut.gui.window =  nil
      end
   end
   return
end

function savevariables(_, addonname)
   if addon.name == addonname then
      local a = cut.gui
      a.window =  nil
      guidata  =  a
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
   local coins =  {}
   local currency =  nil
   for currency, _ in pairs(Inspect.Currency.List()) do
      local detail = Inspect.Currency.Detail(currency)
      coins[detail.name] = { stack=detail.stack, icon=detail.icon }
      --       print(string.format("CuT: (%s) (%s) (%s)", detail.name, detail.stack, detail.icon))
   end

   return coins
end

local function currencyevent()
--    print("CURRENCY EVENT")

   local current  =  getcoins()
   local var, val =  nil, nil
   local tbl      =  {}

   -- find changes
   for var, tbl in pairs(current) do
      val   =  tbl.stack
      if val   ~= (cut.coinbase[var].stack or 0) then
         local newvalue =  val - (cut.coinbase[var].stack or 0)
         cut.updatecurrencies(var, newvalue)
      end
   end
end

local function initcoinbase()

   if not cut.baseinit then

      while not cut.baseinit do
--          print("INIT COIN BASE: BEGIN")
         cut.coinbase   =  getcoins()

         -- do we really have a coint base, let's count
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

Command.Event.Attach(Event.Unit.Availability.Full, initcoinbase, "CuT: Init Coin Base")
Command.Event.Attach(Event.Addon.SavedVariables.Load.End,   loadvariables,    "Load CuT Session Variables")
Command.Event.Attach(Event.Addon.SavedVariables.Save.Begin, savevariables,    "Save CuT Session Variables")
