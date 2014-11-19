-- Author: Geoffrey Anderson
-- This is the base config for the awesome window manager that I've
-- thrown some of my own tweaks into to mix in with my workflow :)
-- This file should live at: $HOME/.config/awesome/rc.lua

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
-- Vicious lib
vicious = require("vicious")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}



-- {{{ Variable definitions
local home = os.getenv("HOME")
-- Themes define colours, icons, and wallpapers
beautiful.init("/usr/share/awesome/themes/default/theme.lua")

-- This is used later as the default terminal and editor to run.
-- terminal = "/usr/bin/terminator"
terminal = "/usr/bin/urxvt"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
--    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
--    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
--    awful.layout.suit.spiral,
--    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}


-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ "1:web", "2:social", "3:music", "4:IM", "5:game", "6:remote", 7, 8, 9 }, s, layouts[2])
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e 'man awesome'" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock()

-- {{{ Widgets to display usage of different resources
-- Initialize Battery widget
batwidget = wibox.widget.textbox()
vicious.register(batwidget, vicious.widgets.bat, " [BAT: $2] ", 61, "BAT0")

-- Initialize Memory widget
memwidget = wibox.widget.textbox()
vicious.register(memwidget, vicious.widgets.mem, " [MEM: $1] ", 13)

-- Initialize CPU widget
cpuwidget = wibox.widget.textbox()
vicious.register(cpuwidget, vicious.widgets.cpu, " [CPU: $1] ")
-- }}}

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
--     mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })

    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(cpuwidget)
    right_layout:add(memwidget)
    right_layout:add(batwidget)
    right_layout:add(mytextclock)
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    -- Set up any floating windows to be ALWAYS on top (this is like my old XMonad config :))
    screen[s]:connect_signal("arrange", function ()
        for _, c in pairs(awful.client.visible(s)) do
            if awful.client.floating.get(c) or awful.layout.getname(awful.layout.get(s)) == "floating" then
                if not c.fullscreen then
                    c.above       =  true
                end
            else
                c.above = false
            end
        end
    end)

    mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    -- temporarily map mod+up/down to control volume
    awful.key({ modkey, }, "Down", function () awful.util.spawn("amixer set Master playback 5%-") end),
    awful.key({ modkey, }, "Up", function () awful.util.spawn("amixer set Master playback 5%+") end),
    -- MMKeys
    awful.key({ }, "XF86AudioLowerVolume", function () awful.util.spawn("amixer set Master playback 5%-") end),
    awful.key({ }, "XF86AudioRaiseVolume", function () awful.util.spawn("amixer set Master playback 5%+") end),
    awful.key({ }, "XF86AudioMute", function () awful.util.spawn("amixer set Master playback 0") end),
    awful.key({ }, "XF86AudioPlay", function () awful.util.spawn("banshee --toggle-playing") end),
    awful.key({ }, "XF86AudioStop", function () awful.util.spawn("banshee --stop") end),
    awful.key({ }, "XF86AudioPrev", function () awful.util.spawn("banshee --previous") end),
    awful.key({ }, "XF86AudioNext", function () awful.util.spawn("banshee --next") end),

    awful.key({ modkey, "Control" }, "Up", function () awful.util.spawn(home .. "/sandbox/pianobar-scripts/pianobar-status") end),
    awful.key({ modkey, "Control" }, "Down", function () awful.util.spawn(home .. "/sandbox/pianobar-scripts/pianobar-toggle") end),
    awful.key({ modkey, "Control" }, "Left", function () awful.util.spawn(home .. "/sandbox/pianobar-scripts/pianobar-stop") end),
    awful.key({ modkey, "Control" }, "Right", function () awful.util.spawn(home .. "/sandbox/pianobar-scripts/pianobar-next") end),
    awful.key({ modkey, "Control" }, "=", function () awful.util.spawn(home .. "/sandbox/pianobar-scripts/pianobar-love") end),
    awful.key({ modkey, "Control" }, "-", function () awful.util.spawn(home .. "/sandbox/pianobar-scripts/pianobar-ban") end),


    -- Poor man's sleep button
    awful.key({ }, "XF86Sleep", function () awful.util.spawn("sudo pm-suspend") end),

    -- The following XF86 button bindings depend on jupiter and are for eeePC (1016P) ONLY
    -- Poor man's wifi toggle (F2)
    awful.key({ }, "XF86WLAN", function () awful.util.spawn("sudo /usr/lib/jupiter/scripts/wifi") end),
    -- Poor man's touchpad toggle (F3)
    awful.key({ }, "XF86TouchpadToggle", function () awful.util.spawn("sudo /usr/lib/jupiter/scripts/touchpad") end),
    -- Poor man's fullscreen -- TODO: add full screen call via awful here (F4)
    -- awful.key({ }, "XF86Launch5", function () awful.util.spawn("") end),
 
    -- For brightness on eeePC, *could* do 'sudo setpci -s 00:02.0 f4.b=XX' where XX is hex.
    -- Poor man's brightnessdown toggle (F5)
    -- awful.key({ }, "XF86BrightnessDown", function () awful.util.spawn("") end),
    -- Poor man's brightnessup toggle (F6)
    -- awful.key({ }, "XF86BrightnessUp", function () awful.util.spawn("") end),
    -- Poor man's screen off (F7) -- what's the best way to turn display on/off on eeePC..
    -- awful.key({ }, "CODE_FOR_F7 (keycode 252)", function () awful.util.spawn("") end),

    -- Poor man's display toggle (F8)
    awful.key({ }, "XF86Display", function () awful.util.spawn("sudo /usr/lib/jupiter/scripts/vga-out") end),
    -- Poor man's system monitor (F9)
    awful.key({ }, "XF86Launch1", function () awful.util.spawn("gnome-system-monitor") end),
    -- TODO: figure out why F10/F11/F12 can't be picked up and used for mute/voldown/volup.

    awful.key({ modkey,           }, "i",      function()
        local c = client.focus
        if not c then
            return
        end

        local geom = c:geometry()

        local t = ""
        if c.class then t = t .. "Class: " .. c.class .. "\n" end
        if c.instance then t = t .. "Instance: " .. c.instance .. "\n" end
        if c.role then t = t .. "Role: " .. c.role .. "\n" end
        if c.name then t = t .. "Name: " .. c.name .. "\n" end
        if c.type then t = t .. "Type: " .. c.type .. "\n" end
        if geom.width and geom.height and geom.x and geom.y then
            t = t .. "Dimensions: " .. "x:" .. geom.x .. " y:" .. geom.y .. " w:" .. geom.width .. " h:" .. geom.height
        end

        naughty.notify({
            text = t,
            timeout = 30,
        })
    end),

    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),

    -- This is like alt+tabbing between 2 tags
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),

    -- This opens the menu defined in .awesomerc
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    -- awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    -- awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    -- I'm used to doing "mod+Shift+Enter" to open a terminal from my XMonad days.. :P
    awful.key({ modkey, "Shift"   }, "Return", function () awful.util.spawn(terminal) end),

	awful.key({ modkey, "Control" }, "r", awesome.restart),
	awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    -- Prompt to start programs (similar to dmenu)
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    awful.key({ }, "Print", function () awful.util.spawn("scrot -e 'mv $f ~/screenshots/ 2>/dev/null '") end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",      function (c) c.minimized = not c.minimized    end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.toggletag(tag)
                          end
                      end
                  end))
end

-- I believe this maps the mouse keys for manipulating windows
clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Define properties for applications.  When any of the applications listed
-- below are opened, they'll be assigned to a specific screen and tag number
-- (e.g. tag[1][4] is screen 1, tag 4).  Additionally, any applications that
-- should always float by default, have the "floating = true" property.
-- My paradigm is:
--  tag1: web browsers
--  tag2: chat clients/social media stuff (e.g. twitter)
--  tag3: music applications
--  tag4: art applications
--  tag5: games
-- And floats are generally video, art, and calculator applications.

awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" }, properties = { floating = true } },
    { rule = { class = "VLC" }, properties = { floating = true } },
    { rule = { class = "gcalculator" }, properties = { floating = true } },
    { rule = { class = "gimp" }, properties = { floating = true, tag = tags[1][9] } },
    { rule = { class = "Chrome" }, properties = { floating = false, tag = tags[1][1] } },
    { rule = { class = "Firefox" }, properties = { floating = false, tag = tags[1][1] } },
    { rule = { class = "Chromium Browser" }, properties = { floating = false, tag = tags[1][1] } },
    { rule = { class = "Google-chrome" }, properties = { floating = false, tag = tags[1][1] } },
    { rule = { class = "banshee" }, properties = { floating = false, tag = tags[1][3] } },
    { rule = { class = "Rhythmbox" }, properties = { floating = false, tag = tags[1][3] } },
    { rule = { class = "Gwibber" }, properties = { foating = false, tag = tags[1][2] } },
    { rule = { class = "Turpial" }, properties = { foating = false, tag = tags[1][2] } },
    { rule = { class = "Empathy" }, properties = { floating = false, tag = tags[1][4] } },
    { rule = { class = "Pidgin" }, properties = { floating = false, tag = tags[1][4] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- Kick off system tray and background apps
do
    extraprogs = {
        "nm-applet",
        "bluetooth-applet",
        "gnome-sound-applet", 
        "/usr/libexec/gnome-fallback-mount-helper",
        "xfce4-power-manager", 
        "gnome-keyring-daemon",
        "xscreensaver",
        "feh --bg-max /home/geoff/Pictures/stern_face.jpg",
        "jupiter",
    }

    for _,i in pairs(extraprogs) do
           -- pgrep doesn't work because of terminal width or something (e.g. pgrep fails to find 'bluetooth-applet' but find 'bluetooth-apple')
           -- awful.util.spawn_with_shell("pgrep -u $USER -x " .. i .. " || (" .. i .. ")")
           awful.util.spawn_with_shell("ps -F -u $USER | grep -v grep | grep " .. i .. " || (" .. i .. ")")
    end
end
