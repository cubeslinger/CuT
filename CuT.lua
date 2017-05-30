--
-- Addon       CuT.lua
-- Author      marcob@marcob.org
-- StartDate   28/05/2017
--
local addon, cut = ...

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

local function initcoinbase()
   print("InitCoinBase")
   cut.coinbase   =  getcoins()
   cut.baseinit   =  true

   local a,b = nil, nil
   for a,b in pairs(cut.coinbase) do print(string.format("CuT: cut.coinbase[%s]=%s", a, b)) end

   return
end

local function currencyevent()

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

Command.Event.Attach(Event.Currency,         function() currencyevent() end, "CuT Currency Event")
