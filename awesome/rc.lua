-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
local bashets = require("bashets")
local lain  = require("lain")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
-- Redshift
local redshift = require("redshift")
-- minitray
local minitray = require("minitray")
-- scratchdrop
local drop      = require("scratchdrop")
xdg_menu = require("archmenu")

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
-- Theme define colours, icons, and wallpapers
beautiful.init("/usr/share/awesome/themes/numixesque/theme.lua")

wp_path = "/home/vga/.config/awesome/"

gears.wallpaper.maximized(wp_path .. "wallhaven-164573.png", 2, true)
gears.wallpaper.maximized(wp_path .. "wallhaven-80061.jpg", 1, true)

-- This is used later as the default terminal and editor to run.
terminal = "urxvt"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
modkey = "Mod4"
altkey = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
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
    awful.layout.suit.magnifier,
    lain.layout.uselesstile,
    lain.layout.uselesstile.left,
    lain.layout.uselesstile.top
}
-- }}}

-- {{{ Redshift
-- set binary path (optional)
redshift.redshift = "/usr/bin/redshift"

-- set additional redshift arguments (optional)
redshift.options = "-c /home/vga/.config/redshift.conf"

-- 1 for dim, 0 for not dimmed
redshift.init(1)
-- }}}

-- {{{ Weather
markup = lain.util.markup
weathericon = wibox.widget.imagebox(beautiful.widget_weather)
yawn = lain.widgets.yawn(2461848, {
    settings = function()
        widget:set_markup(markup("#818d90", "" .. forecast:lower() .. ": " .. units .. "° "))
    end
})
-- }}}

 -- {{{ Tags
 -- Define a tag table which will hold all screen tags.
 tags = {
   names  = { "I", "II", "III", "IV", "V"},
   layout = { layouts[13], layouts[13], layouts[13], layouts[13], layouts[13]} }
   -- Each screen has its own tag table.
   tags[1] = awful.tag(tags.names, 1, tags.layout)

 tags2 = {
   names2  = { "I", "II", "III"},
   layout2 = { layouts[15], layouts[13], layouts[13]} }
   -- Each screen has its own tag table.
   tags2[2] = awful.tag(tags2.names2, 2, tags2.layout2)

 -- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "applications", xdgmenu },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.arch_icon, menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox
-- Create a textclock widget
clockicon = wibox.widget.imagebox(beautiful.widget_clock)
mytextclock = awful.widget.textclock('<span color="#818d90">%a, %m-%d %H:%M </span>', 60)

-- ALSA volume
volicon = wibox.widget.imagebox(beautiful.widget_vol)
volumewidget = lain.widgets.alsa({
    settings = function()
        if volume_now.status == "off" then
            volicon:set_image(beautiful.widget_vol_mute)
        elseif tonumber(volume_now.level) == 0 then
            volicon:set_image(beautiful.widget_vol_no)
        elseif tonumber(volume_now.level) <= 50 then
            volicon:set_image(beautiful.widget_vol_low)
        else
            volicon:set_image(beautiful.widget_vol)
        end
        widget:set_markup(markup("#818d90", "" .. volume_now.level .. "% "))
    end
})

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
    right_layout:add(weathericon)
    right_layout:add(yawn.widget)
    right_layout:add(volicon)
    right_layout:add(volumewidget)
    right_layout:add(clockicon)
    right_layout:add(mytextclock)
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

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
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Up",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "Down",
        function ()
            awful.client.focus.byidx( -1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),
    awful.key({ modkey }, "d", redshift.toggle),
    awful.key({ modkey,           }, "s", function() minitray.toggle() end ),
    awful.key({ modkey, "Control"   }, "w", function() awful.util.spawn_with_shell("urxvt -e ~/scripts/weather.sh") end),
    awful.key({ modkey, "Shift"   }, "s", function() awful.util.spawn_with_shell("systemctl suspend") end),
    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end),

    -- Dropdown terminal
    awful.key({ modkey, }, "z", function () drop(terminal) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),

    -- On the fly useless gaps change
    awful.key({ altkey, "Control" }, "+", function () lain.util.useless_gaps_resize( 1) end),
    awful.key({ altkey, "Control" }, "-", function () lain.util.useless_gaps_resize(-1) end),

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
    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Volume control
    awful.key({ }, "XF86AudioRaiseVolume",
    function ()
    	awful.util.spawn("amixer set Master 1%+")
    	volumewidget.update()
    end),
    awful.key({ }, "XF86AudioLowerVolume",
    function ()
    	awful.util.spawn("amixer set Master 1%-")
    	volumewidget.update()
    end),
    awful.key({ }, "XF86AudioMute",
    function ()
    	awful.util.spawn("amixer set Master playback toggle")
    	volumewidget.update()
    end),

    -- Prompt
    --awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey },            "r",
              function ()
                awful.util.spawn("dmenu_run -i -p 'Run command:' -nb '" ..
                beautiful.bg_normal .. "' -nf '" .. beautiful.fg_normal ..
                "' -sb '" .. beautiful.bg_focus ..
                "' -sf '" .. beautiful.fg_focus .. "'")
              end),
    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),

    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

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

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
  { rule = { },
    properties = { border_width = beautiful.border_width,
                   border_color = beautiful.border_normal,
                   focus = awful.client.focus.filter,
                   keys = clientkeys,
                   buttons = clientbuttons,
				 size_hints_honor = false,
         opacity = 1.0 }
	},
  { rule = { class = "Plugin-container" },
        properties = { floating = true,
        opacity = 1.0 }
  },
	{ rule = {class = "URxvt"},
 		properties = {opacity = 0.9}, callback = function (c)
        if not skipMovingUrxvt then
          awful.client.movetotag(tags2[2][1], c)
          skipMovingUrxvt = true
        end
      end
  },
  { rule = {type = "_NET_WM_WINDOW_TYPE_DOCK"},
    properites = {opacity = .75}
  },
	{ rule = {class = "Shutter"},
 		properties = {opacity = 1.0}
  },
	{ rule = {class = "Mirage"},
		properties = {opacity = 1.0}
  },
  { rule = { class = "Qpdfview" },
    properties = { }, callback = function (c)
      if not skipMovingQP then
        awful.client.movetotag(tags[1][2], c)
        skipMovingQP = true
      end
    end
  },
  { rule = { class = "Atom" },
    properties = { }, callback = function (c)
      if not skipMovingST then
        awful.client.movetotag(tags[1][3], c)
        skipMovingST = true
      end
    end,
  },
  { rule = { class = "Firefox" },
    properties = { opacity = 0.95 }, callback = function (c)
      if not skipMovingFF then
        awful.client.movetotag(tags[1][4], c)
        skipMovingFF = true
      end
    end
  },
  { rule = { class = "Galculator" },
    properties = { floating = true },
  },
  { rule = { class = "Thunar" },
    properties = { }, callback = function (c)
      if not skipMovingTH then
        awful.client.movetotag(tags[1][5], c)
        skipMovingTH = true
      end
    end
  },
  { rule = { class = "Pcmanfm" },
    properties = { floating = true },
  },
  { rule = { class = "libreoffice-writer" },
    properties = { opacity = 1.0 }, callback = function (c)
      if not skipMovingLO then
        awful.client.movetotag(tags[1][3], c)
        skipMovingLO = true
      end
    end
  },
  { rule = { class = "Gummi" },
    properties = { }, callback = function (c)
      if not skipMovingGU then
        awful.client.movetotag(tags[1][3], c)
        skipMovingGU = true
      end
    end
  },
  { rule = { class = "spotify" },
    properties = { }, callback = function (c)
      if not skipMovingSpot then
        awful.client.movetotag(tags2[2][3], c)
        skipMovingSpot = true
      end
    end
  },
  { rule = { class = "Transmission-gtk" },
    properties = { }, callback = function (c)
      if not skipMovingTM then
        awful.client.movetotag(tags[1][5], c)
        skipMovingTM = true
      end
    end
  },
  { rule = { class = "Gimp-2.8" },
    properties = { floating = true }
  },
  { rule = { class = "Gimp-2.8" },
    properties = { opacity = 1.0 }
  },
  { rule = { class = "Vlc" },
    properties = { opacity = 1.0 }, callback = function (c)
      if not skipMovingVLC then
        awful.client.movetotag(tags[1][5], c)
        skipMovingVLC = truebot
      end
    end
  }
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
    local titlebars_enabled = false
end)
-- }}}

--autostart functions/calls
function run_once(prg)
  awful.util.spawn_with_shell("pgrep -u $USER -x " .. prg .. " || (" .. prg .. ")")
end

function run_onceff()
  awful.util.spawn_with_shell("pgrep -u $USER -x firefox-develop || firefox-developer")
end

run_once("urxvt")
run_once("atom")
run_once("qpdfview")
run_once("thunar")
run_once("spotify")
run_once("dropbox")
run_once("xchat")
run_onceff("firefox-developer")

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- disable startup-notification globally
local oldspawn = awful.util.spawn
awful.util.spawn = function (s)
  oldspawn(s, false)
end
