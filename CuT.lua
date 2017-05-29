--
-- Addon       CuT.lua
-- Author      marcob@marcob.org
-- StartDate   28/05/2017
--
local addon, cut = ...

cut.coinbase   =  {}

local function getcoins()
   local coins =  {}
   local currency =  nil
   for currency, _ in pairs(Inspect.Currency.List()) do
      local detail = Inspect.Currency.Detail(currency)
      coins[detail.name]=detail.stack
   end

   return coins
end

local function initcoinbase()
   cut.coinbase   =  getcoins()
end

local function currencyevent()

   local current  =  getcoins()
   local var, val =  nil, nil

   -- find changes
   for var, val in pairs(current) do
      if val   ~= cut.coinbase[var] then
--          print(string.format("  CuT: check var=[%s]=>val[%s]", var, val))
         local newvalue =  val - cut.coinbase[var]
         local sign     =  nil
         if newvalue >  0  then sign   =  "+"   else  sign  =  "-"   end
--          print(string.format("CuT: CHANGED var[%s](%s)(%s)=>(%s)(%s)", var, val, cut.coinbase[var], sign, newvalue))
         cut.updatecurrencies(var, newvalue)
      end
   end
end

Command.Event.Attach(Event.Addon.Load.End,   function() initcoinbase()  end, "CuT Initialize")
Command.Event.Attach(Event.Currency,         function() currencyevent() end, "CuT Currency Event")
