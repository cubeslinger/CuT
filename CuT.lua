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
--       coins[detail.name]=detail.stack
      coins[detail.name] = { stack=detail.stack, icon=detail.icon }
--       print(string.format("CuT: (%s) (%s) (%s)", detail.name, detail.stack, detail.icon))
   end

   return coins
end

local function currencyevent()    

   local current  =  getcoins()
   local var, val =  nil, nil
   local tbl      =  {}

   -- find changes
--    for var, val in pairs(current) do
   for var, tbl in pairs(current) do
      val   =  tbl.stack
--       if val   ~= cut.coinbase[var] then
      if val   ~= (cut.coinbase[var].stack or 0) then
--          print(string.format("  CuT: check var=[%s]=>val[%s]", var, val))
--          local newvalue =  val - (cut.coinbase[var] or 0)
         local newvalue =  val - (cut.coinbase[var].stack or 0)
--          print(string.format("CuT: CHANGED var[%s](%s)(%s)=>(%s)", var, val, cut.coinbase[var], newvalue))
         cut.updatecurrencies(var, newvalue)
      end
   end
end

local function initcoinbase()
   cut.coinbase   =  getcoins()
   
   -- now we can wait
   Command.Event.Attach(Event.Currency,         function() currencyevent() end, "CuT Currency Event")   
end



Command.Event.Attach(Event.Addon.Load.End,   function() initcoinbase()  end, "CuT Initialize")

