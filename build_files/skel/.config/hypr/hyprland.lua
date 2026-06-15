-- Default Hyprland config for bluefin-dx-hypr.
-- Override per-user by editing ~/.config/hypr/hyprland.lua.
-- Hyprland 0.55+ prefers hyprland.lua over hyprland.conf when both are present.

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

local mod         = "SUPER"
local terminal    = "alacritty"
local menu        = "fuzzel"
local fileManager = "nautilus"
local browser     = "flatpak run app.zen_browser.zen"

-- `wayle shell` runs the panel, notifications, OSD, systray, wallpaper, and idle daemon in one process.
hl.on("hyprland.start", function()
    hl.exec_cmd("wayle shell")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)

hl.config({
    input = {
        kb_layout    = "us",
        follow_mouse = 1,
        touchpad = {
            natural_scroll = true,
        },
    },
    general = {
        gaps_in     = 4,
        gaps_out    = 8,
        border_size = 2,
        layout      = "dwindle",
    },
    decoration = {
        rounding = 6,
    },
})

-- --- Shell / core ---
hl.bind(mod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + E",      hl.dsp.exec_cmd(fileManager))
hl.bind(mod .. " + B",      hl.dsp.exec_cmd(browser))
hl.bind(mod .. " + Space",  hl.dsp.exec_cmd(menu))
hl.bind(mod .. " + V",      hl.dsp.exec_cmd([[sh -c 'cliphist list | fuzzel --dmenu | cliphist decode | wl-copy']]))

-- --- Window / session ---
hl.bind(mod .. " + Q",                hl.dsp.window.close())
hl.bind(mod .. " + CTRL + SHIFT + Q", hl.dsp.exit())
hl.bind(mod .. " + Escape",           hl.dsp.exec_cmd("hyprlock"))

-- --- Window focus (rtds, niri-style) ---
hl.bind(mod .. " + R", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + S", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + T", hl.dsp.focus({ direction = "down" }))
hl.bind(mod .. " + D", hl.dsp.focus({ direction = "up" }))

-- --- Move window in direction ---
hl.bind(mod .. " + SHIFT + R", hl.dsp.window.move({ direction = "left" }))
hl.bind(mod .. " + SHIFT + S", hl.dsp.window.move({ direction = "right" }))
hl.bind(mod .. " + SHIFT + T", hl.dsp.window.move({ direction = "down" }))
hl.bind(mod .. " + SHIFT + D", hl.dsp.window.move({ direction = "up" }))

-- --- Workspaces 1-9 ---
for i = 1, 9 do
    hl.bind(mod .. " + " .. i,         hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

-- --- Workspace navigation ---
hl.bind(mod .. " + J",   hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + K",   hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mod .. " + C",   hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + L",   hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mod .. " + Tab", hl.dsp.focus({ workspace = "previous" }))
hl.bind(mod .. " + SHIFT + J", hl.dsp.window.move({ workspace = "e+1" }))
hl.bind(mod .. " + SHIFT + K", hl.dsp.window.move({ workspace = "e-1" }))
hl.bind(mod .. " + SHIFT + C", hl.dsp.window.move({ workspace = "e+1" }))
hl.bind(mod .. " + SHIFT + L", hl.dsp.window.move({ workspace = "e-1" }))
hl.bind("CTRL + SHIFT + Right", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("CTRL + SHIFT + Left",  hl.dsp.focus({ workspace = "e-1" }))

-- --- Monitor focus ---
hl.bind(mod .. " + Left",  hl.dsp.focus({ monitor = "l" }))
hl.bind(mod .. " + Right", hl.dsp.focus({ monitor = "r" }))
hl.bind(mod .. " + Up",    hl.dsp.focus({ monitor = "u" }))
hl.bind(mod .. " + Down",  hl.dsp.focus({ monitor = "d" }))

-- --- Move window to monitor ---
hl.bind(mod .. " + SHIFT + Left",  hl.dsp.window.move({ monitor = "l" }))
hl.bind(mod .. " + SHIFT + Right", hl.dsp.window.move({ monitor = "r" }))
hl.bind(mod .. " + SHIFT + Up",    hl.dsp.window.move({ monitor = "u" }))
hl.bind(mod .. " + SHIFT + Down",  hl.dsp.window.move({ monitor = "d" }))

-- --- Move current workspace to monitor ---
hl.bind(mod .. " + CTRL + SHIFT + Left",  hl.dsp.workspace.move({ monitor = "l" }))
hl.bind(mod .. " + CTRL + SHIFT + Right", hl.dsp.workspace.move({ monitor = "r" }))
hl.bind(mod .. " + CTRL + SHIFT + Up",    hl.dsp.workspace.move({ monitor = "u" }))
hl.bind(mod .. " + CTRL + SHIFT + Down",  hl.dsp.workspace.move({ monitor = "d" }))

-- --- Sizing & state ---
hl.bind(mod .. " + F",             hl.dsp.window.fullscreen({ mode = 1 }))
hl.bind(mod .. " + SHIFT + F",     hl.dsp.window.fullscreen({ mode = 0 }))
hl.bind(mod .. " + semicolon",     hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + minus",         hl.dsp.window.resize({ x = -100, y = 0 }))
hl.bind(mod .. " + equal",         hl.dsp.window.resize({ x = 100,  y = 0 }))
hl.bind(mod .. " + SHIFT + minus", hl.dsp.window.resize({ x = 0,    y = -100 }))
hl.bind(mod .. " + SHIFT + equal", hl.dsp.window.resize({ x = 0,    y = 100 }))

-- --- Scratchpad (special workspace) ---
hl.bind(mod .. " + slash",         hl.dsp.workspace.toggle_special())
hl.bind(mod .. " + SHIFT + slash", hl.dsp.window.move({ workspace = "special", silent = true }))

-- --- Volume / brightness ---
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),  { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),  { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set 5%+"),                     { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"),                     { locked = true, repeating = true })

-- --- Screenshots ---
hl.bind("Print",        hl.dsp.exec_cmd([[grim -g "$(slurp)" - | wl-copy]]))
hl.bind("CTRL + Print", hl.dsp.exec_cmd("grim - | wl-copy"))
hl.bind("ALT + Print",  hl.dsp.exec_cmd([[grim -g "$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')" - | wl-copy]]))
