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
cut.gui.width           =  350
cut.gui.height          =  100
cut.gui.borders         =  {}
cut.gui.borders.left    =  4
cut.gui.borders.right   =  4
cut.gui.borders.bottom  =  4
cut.gui.borders.top     =  4
cut.gui.font            =  {}
cut.gui.font.size       =  14
cut.gui.font.name       =  "fonts/MonospaceTypewriter.ttf"
--
cut.coinbase            =  {}
cut.baseinit            =  false
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

function getcoins()
   local coins =  {}
   local currency =  nil
   for currency, _ in pairs(Inspect.Currency.List()) do
      local detail = Inspect.Currency.Detail(currency)
      coins[detail.name] = { stack=detail.stack, icon=detail.icon }
      --       print(string.format("CuT: (%s) (%s) (%s)", detail.name, detail.stack, detail.icon))
   end

   return coins
end

local function initcoinbase()
   print("InitCoinBase")
   cut.coinbase   =  getcoins()
   cut.baseinit   =  true

   local a,b = nil, nil
   for a,b in pairs(cut.coinbase) do print(string.format("CuT: cut.coinbase[%s]=%s", a, b)) end

--    Command.Event.Attach(Event.Currency, function() cut.currencyevent() end, "CuT Currency Event")

   return
end

function currencyevent()

   if cut.baseinit == false then initcoinbase() end

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


-- Command.Event.Attach(Event.Addon.Load.End, function() initcoinbase() end, "CuT Loaded")
Command.Event.Attach(Event.Currency, function() currencyevent() end, "CuT Currency Event")
