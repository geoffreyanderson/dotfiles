-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
-- Vicious lib
require("vicious")

-- Load Debian menu entries
require("debian.menu")

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/usr/share/awesome/themes/default/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "x-terminal-emulator"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ "1:web", "2:social", "3:music", "4:art", "5:game", "6:remote", 7, 8, 9 }, s, layouts[2])
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "Debian", debian.menu.Debian_menu.Debian },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = "right" })

-- Create a battery widget
-- batwidget = awful.widget.progressbar()
-- batwidget:set_width(8)
-- batwidget:set_height(10)
-- batwidget:set_vertical(true)
-- batwidget:set_background_color("#494B4F")
-- batwidget:set_border_color(nil)
-- batwidget:set_color("#AECF96")
-- batwidget:set_gradient_colors({ "#AECF96", "#88A175", "#FF5656" })
-- vicious.register(batwidget, vicious.widgets.bat, "$2", 61, "BAT0")

-- Initialize Battery widget
batwidget = widget({ type = "textbox" })
vicious.register(batwidget, vicious.widgets.bat, " [BAT: $2] ", 61, "BAT0")

-- Initialize Memory widget
memwidget = widget({ type = "textbox" })
vicious.register(memwidget, vicious.widgets.mem, " [MEM: $1%] ", 13)

-- Initialize CPU widget
cpuwidget = widget({ type = "textbox" })
vicious.register(cpuwidget, vicious.widgets.cpu, " [CPU: $1%] ")

-- Create a systray
mysystray = widget({ type = "systray" })

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
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if not c:isvisible() then
                                                  awful.tag.viewonly(c:tags()[1])
                                              end
                                              client.focus = c
                                              c:raise()
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
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mylauncher,
            mytaglist[s],
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],
        mytextclock,
        batwidget,
        memwidget,
        cpuwidget,
        s == 1 and mysystray or nil,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
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
    -- MMKeys
    awful.key({ }, "XF86AudioLowerVolume", function () awful.util.spawn("amixer set Master playback 3-") end),
    awful.key({ }, "XF86AudioRaiseVolume", function () awful.util.spawn("amixer set Master playback 3+") end),
    awful.key({ }, "XF86AudioMute", function () awful.util.spawn("amixer set Master playback 0") end),
    awful.key({ }, "XF86AudioPlay", function () awful.util.spawn("banshee --toggle-playing") end),
    awful.key({ }, "XF86AudioStop", function () awful.util.spawn("banshee --stop") end),
    awful.key({ }, "XF86AudioPrev", function () awful.util.spawn("banshee --previous") end),
    awful.key({ }, "XF86AudioNext", function () awful.util.spawn("banshee --next") end),

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
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
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

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
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
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

floatapps = 
{
    ["MPlayer"] = true,
    ["Vlc"] = true,
    ["gimp"] = true,
    ["gcalculator"] = true
}
apptags =
{
    ["Gimp"] = { screen = 1, tag = 4},
    ["Chrome"] = { screen = 1, tag = 1},
    ["Google-chrome"] = { screen = 1, tag = 1},
    ["Chromium Browser"] = { screen = 1, tag = 1},
    ["Firefox"] = { screen = 1, tag = 1},
    ["banshee"] = { screen = 1, tag = 3},
    ["Rhythmbox"] = { screen = 1, tag = 3},
    ["Empathy"] = { screen = 1, tag = 2},
    ["Pidgin"] = { screen = 1, tag = 2},
    ["Gwibber"] = { screen = 1, tag = 2}
}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" }, properties = { floating = true } },
    { rule = { class = "VLC" }, properties = { floating = true } },
    { rule = { class = "gimp" }, properties = { floating = true, tag = tags[1][4] } },
    { rule = { class = "Chrome" }, properties = { tag = tags[1][1] } },
    { rule = { class = "Firefox" }, properties = { tag = tags[1][1] } },
    { rule = { class = "Chromium Browser" }, properties = { tag = tags[1][1] } },
    { rule = { class = "Google-chrome" }, properties = { tag = tags[1][1] } },
    { rule = { class = "banshee" }, properties = { tag = tags[1][3] } },
    { rule = { class = "Rhythmbox" }, properties = { tag = tags[1][3] } },
    { rule = { class = "Gwibber" }, properties = { tag = tags[1][2] } },
    { rule = { class = "Empathy" }, properties = { tag = tags[1][2] } },
    { rule = { class = "Pidgin" }, properties = { tag = tags[1][2] } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
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
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- -- {{{ Volume level
-- volicon = widget({ type = "imagebox" })
-- volicon.image = image(beautiful.widget_vol)
-- -- initialize widgets
-- volbar = awful.widget.progressbar()
-- volwidget = widget({ type = "textbox" })
-- -- Progressbar properties
-- volbar:set_vertical(true):set_ticks(true)
-- volbar:set_height(12):set_width(8):set_ticks_size(2)
-- volbar:set_background_color(beautiful.fg_off_widget)
-- volbar:set_gradient_colors({ beautiful.fg_widget, beautiful.fg_center_widget, beautiful.fg_end_widget})
-- -- Enable caching
-- vicious.cache(vicious.widgets.volume)
-- -- Register widgets
-- vicious.register(volbar, vicious.widgets.volume, "$1", 2, "PCM")
-- vicious.register(volwidget, vicious.widgets.volume, " $1%", 2, "PCM")
-- -- Register buttons
-- volbar.widget:buttons(awful.util.table.join(
--     awful.button({ }, 1, function () exec("gnome-sound-applet") end),
--     awful.button({ }, 4, function () exec("amixer -q set PCM 2dB+", false) end),
--     awful.button({ }, 5, function () exec("amixer -q set PCM 2dB-", false) end)
-- ))
-- -- Register assigned buttons
-- volwidget:buttons(volbar.widget:buttons())
-- -- }}}


-- Kick off system tray apps
do
    extraprogs = {
        "nm-applet",
        "gnome-sound-applet", 
        "gnome-power-manager", 
        "gnome-keyring-daemon"
    }

    for _,i in pairs(extraprogs) do
--         os.execute(i)
           awful.util.spawn_with_shell("pgrep -u $USER -x " .. i .. " || (" .. i .. ")")
    end
end

-- {{{ Arrange signal handler
for s = 1, screen.count() do 
    screen[s]:add_signal("arrange", function ()
        local clients = awful.client.visible(s)
        local layout = awful.layout.getname(awful.layout.get(s))

        for _, c in pairs(clients) do -- Floaters are always on top
            if awful.client.floating.get(c) or layout == "floating" then
                if not c.fullscreen then
                    c.above       =  true
                end
            else
                c.above = false
            end
        end
    end)
end
-- }}}
