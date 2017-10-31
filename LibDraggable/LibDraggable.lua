--[[ LibDraggable
  Library.LibDraggable.draggify(window)

  Notes: modified for FishItUp! by marcob@marcob.org
         1) moves frames and not windows anymore.
         2) reacts on RIGHT mouse clicks and not LEFT.
         3) added undraggify() method
]]--

if not Library then Library = {} end
local Draggable = {}
if not Library.LibDraggable then Library.LibDraggable = Draggable end

Draggable.DebugLevel = 0
Draggable.Version = "0.5-130712-20:34:32"

Draggable.printf = Library.printf.printf

Draggable.windows = {}

function Draggable.draggify(window, callback)
   if window   then
      local newtab = { dragging = false, x = 0, y = 0 }
      Draggable.windows[window] = newtab
      newtab.callback = callback
      local border = window
      border:EventAttach(Event.UI.Input.Mouse.Right.Down,      function(...) Draggable.rightdown(window, ...)        end, "draggable_right_down")
      border:EventAttach(Event.UI.Input.Mouse.Cursor.Move,     function(...) Draggable.mousemove(window, ...)        end, "draggable_mouse_move")
      border:EventAttach(Event.UI.Input.Mouse.Right.Up,        function(...) Draggable.rightup(window, ...)          end, "draggable_right_up")
      border:EventAttach(Event.UI.Input.Mouse.Right.Upoutside, function(...) Draggable.rightupoutside(window, ...)   end, "draggable_right_upoutside")
      Draggable.windows[window] = newtab
   end
end

function Draggable.undraggify(window, callback)
   if window   then
      local border = window

      Draggable.windows[window] = nil

      local a, b     =  nil, nil
      local EVENTS   =  { Event.UI.Input.Mouse.Right.Down,  Event.UI.Input.Mouse.Cursor.Move, Event.UI.Input.Mouse.Right.Up, Event.UI.Input.Mouse.Right.Upoutside }
      local event    =  nil
      local eventlist=  {}

      for _, event in ipairs(EVENTS) do
         local eventlist =  border:EventList(event)
         for a,b in pairs(eventlist) do
--             local c, d  =  nil, nil
--             for c, d in pairs(b) do print(string.format("a[%s] c[%s] d[%s]", a, c, d)) end
            border:EventDetach(event, b.handler, b.label)
         end
      end
   end
end


function Draggable.rightdown(window, event, ...)
   local win = Draggable.windows[window]
   if not win then
      Draggable.windows[window] = { dragging = false, x = 0, y = 0 }
      win = Draggable.windows[window]
   end
   win.dragging = true
   win.win_x = window:GetLeft()
   win.win_y = window:GetTop()
   local l, t, r, b = window:GetBounds()
   window:ClearAll()
   window:SetPoint("TOPLEFT", UIParent, "TOPLEFT", l, t)
   window:SetWidth(r - l)
   window:SetHeight(b - t)
   win.ev_x = Inspect.Mouse().x
   win.ev_y = Inspect.Mouse().y
end

function Draggable.mousemove(window, event, ...)
   local event, x, y = ...
   local win = Draggable.windows[window]
   if win and win.dragging then
      local win = Draggable.windows[window]
      local new_x = win.win_x + x - win.ev_x
      local new_y = win.win_y + y - win.ev_y
      window:SetPoint("TOPLEFT", UIParent, "TOPLEFT", new_x, new_y)
      if win.callback then
         win.callback(window, new_x, new_y)
      end
   end
end

function Draggable.rightup(window, event, ...)
   local win = Draggable.windows[window]
   if win then
      win.dragging = false
      win.ev_x = nil
      win.ev_y = nil
  end
end

function Draggable.rightupoutside(window, event, ...)
   local win = Draggable.windows[window]
   if win then
      win.dragging = false
      win.ev_x = nil
      win.ev_y = nil
   end
end
