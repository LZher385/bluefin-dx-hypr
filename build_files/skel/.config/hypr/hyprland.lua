-- Default Hyprland config for bluefin-dx-hypr.
-- Override per-user by editing ~/.config/hypr/hyprland.lua.

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

local mod         = "SUPER"
local terminal    = "alacritty"
local menu        = "fuzzel"
local fileManager = "nautilus"
local browser     = "flatpak run app.zen_browser.zen"

-- Autostart
-- `wayle shell` runs the panel, notifications, OSD, systray, wallpaper, and idle daemon in one process.
hl.on("hyprland.start", function()
    hl.exec_cmd("wayle shell")
    hl.exec_cmd("kanshi")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.dsp.focus({ workspace = "1" })
end)

hl.config({
    input = {
        kb_layout    = "us",
        follow_mouse = 1,
        touchpad = {
            natural_scroll = false,
        },
    },
    general = {
        gaps_in          = 4,
        gaps_out         = 8,
        border_size      = 2,
        layout           = "dwindle",
        resize_on_border = true,
    },
    decoration = {
        rounding = 6,
    },
    animations = {
        enabled = true,
        bezier = {
            { name = "snap",      points = { 0.05, 0.9, 0.1, 1.0 } },
            { name = "overshoot", points = { 0.3,  1.3, 0.6, 1.0 } },
        },
        animation = {
            { name = "windowsIn",        enabled = true, speed = 4,  curve = "overshoot", style = "popin 80%" },
            { name = "windowsOut",       enabled = true, speed = 3,  curve = "snap",      style = "popin 80%" },
            { name = "windowsMove",      enabled = true, speed = 4,  curve = "snap" },
            { name = "fade",             enabled = true, speed = 4 },
            { name = "border",           enabled = true, speed = 6 },
            { name = "borderangle",      enabled = true, speed = 60, curve = "linear" },
            { name = "workspaces",       enabled = true, speed = 4,  curve = "snap",      style = "slide" },
            { name = "specialWorkspace", enabled = true, speed = 4,                       style = "slidevert" },
        },
    },
    dwindle = {
        preserve_split       = true,
        force_split          = 2,
        special_scale_factor = 0.9,
    },
})

-- --- Shell / core ---
hl.bind(mod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + E",      hl.dsp.exec_cmd(fileManager))
hl.bind(mod .. " + B",      hl.dsp.exec_cmd(browser))
hl.bind(mod .. " + Space",         hl.dsp.exec_cmd(menu))
hl.bind(mod .. " + SHIFT + Space", hl.dsp.exec_cmd([[sh -c '"$HOME"/.config/hypr/scripts/file-search.sh']]))
hl.bind(mod .. " + W",             hl.dsp.exec_cmd([[sh -c '"$HOME"/.config/hypr/scripts/window-switcher.sh']]))
hl.bind(mod .. " + V",             hl.dsp.exec_cmd([[sh -c 'cliphist list | fuzzel --dmenu | cliphist decode | wl-copy']]))

-- --- Window / session ---
hl.bind(mod .. " + Q",                hl.dsp.window.close())
hl.bind(mod .. " + CTRL + SHIFT + Q", hl.dsp.exec_cmd([[sh -c 'choice=$(printf "Lock\nLogout\nSuspend\nReboot\nShutdown" | fuzzel --dmenu --prompt "Power: "); case "$choice" in Lock) hyprlock;; Logout) hyprctl dispatch '"'"'hl.dsp.exit()'"'"';; Suspend) systemctl suspend;; Reboot) systemctl reboot;; Shutdown) systemctl poweroff;; esac']]))
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

-- --- Workspaces 1-10 ---
-- Add `hl.workspace_rule({ workspace = "N", monitor = "DP-3" })` per workspace
-- if you want to pin specific workspaces to specific monitors. Hyprland treats
-- `monitor` as a preference and falls back to a connected output if the
-- preferred one is absent, so kanshi profile switches need no extra logic.
for i = 1, 10 do
    local key = (i == 10) and "0" or tostring(i)
    local workspace = tostring(i)
    hl.bind(mod .. " + " .. key,         hl.dsp.focus({ workspace = workspace }))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace }))
end

-- --- Workspace navigation ---
hl.bind(mod .. " + J",   hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + K",   hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mod .. " + C",   hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + L",   hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mod .. " + Tab", hl.dsp.focus({ workspace = "previous" }))
hl.bind(mod .. " + N",         hl.dsp.focus({ workspace = "empty" }))
hl.bind(mod .. " + SHIFT + N", hl.dsp.window.move({ workspace = "empty" }))
hl.bind(mod .. " + U",         hl.dsp.exec_raw("focusurgentorlast"))
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
hl.bind(mod .. " + F",                 hl.dsp.window.fullscreen({ mode = 1 }))
hl.bind(mod .. " + SHIFT + F",         hl.dsp.window.fullscreen({ mode = 0 }))
hl.bind(mod .. " + semicolon",         hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + SHIFT + semicolon", hl.dsp.window.pseudo())

-- --- Mouse drag (floating: move/resize freely; tiled: swap/adjust split) ---
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag({ action = "move" }))
hl.bind(mod .. " + mouse:273", hl.dsp.window.drag({ action = "resize" }))


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
-- mod+P: select area, then choose Copy or Save via fuzzel.
hl.bind(mod .. " + P",  hl.dsp.exec_cmd([[sh -c 'geom=$(slurp) || exit; f=$(mktemp --suffix=.png); grim -g "$geom" "$f" || { rm -f "$f"; exit; }; choice=$(printf "Copy to clipboard\nSave as file" | fuzzel --dmenu --prompt "Screenshot: "); case "$choice" in "Copy to clipboard") wl-copy < "$f"; rm "$f";; "Save as file") mkdir -p ~/Pictures/Screenshots; mv "$f" ~/Pictures/Screenshots/screenshot-$(date +%Y%m%d-%H%M%S).png;; *) rm "$f";; esac']]))
hl.bind("CTRL + Print", hl.dsp.exec_cmd("grim - | wl-copy"))
hl.bind("ALT + Print",  hl.dsp.exec_cmd([[grim -g "$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')" - | wl-copy]]))
