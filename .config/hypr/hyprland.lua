-- Hyprland Lua Config
-- Migrated from hyprland.conf + keymaps.conf

-- Environment Variables
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_SCREENSHOTS_DIR", os.getenv("HOME") .. "/Pictures/Screenshots")

hl.env("AQ_DRM_DEVICES", "/dev/dri/card2:/dev/dri/card1")
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Monitor
hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = "auto",
})

require("keymaps")

-- Autostart
hl.on("hyprland.start", function()
	hl.exec_cmd("~/.config/hypr/start.sh")
	hl.exec_cmd("wl-paste --type text --watch cliphist store")
	hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)

-- Look and Feel
hl.config({
	general = {
		gaps_in = 3,
		gaps_out = 5,
		border_size = 2,
		col = {
			active_border = "0xffd3869b",
			inactive_border = "0xff45475a",
		},
		resize_on_border = false,
		allow_tearing = false,
		layout = "dwindle",
	},
	cursor = {
		no_hardware_cursors = true,
	},
	decoration = {
		rounding = 10,
		active_opacity = 0.9,
		inactive_opacity = 0.9,
		shadow = {
			enabled = true,
			range = 4,
			render_power = 3,
			color = 0x33000000,
			color_inactive = 0x22000000,
		},
		blur = {
			enabled = true,
			size = 2,
			passes = 4,
			vibrancy = 0.1696,
		},
	},
	animations = {
		enabled = true,
	},
})

-- Bezier curves
hl.curve(
	"myBezier",
	{ type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } }
)
hl.curve(
	"default",
	{ type = "bezier", points = { { 0.25, 0.1 }, { 0.25, 1 } } }
)

-- Animations
hl.animation({
	leaf = "windows",
	enabled = true,
	speed = 7,
	bezier = "myBezier",
})
hl.animation({
	leaf = "windowsOut",
	enabled = true,
	speed = 7,
	bezier = "default",
	style = "popin 80%",
})
hl.animation({
	leaf = "border",
	enabled = true,
	speed = 10,
	bezier = "default",
})
hl.animation({
	leaf = "borderangle",
	enabled = true,
	speed = 8,
	bezier = "default",
})
hl.animation({
	leaf = "fade",
	enabled = true,
	speed = 7,
	bezier = "default",
})
hl.animation({
	leaf = "workspaces",
	enabled = true,
	speed = 6,
	bezier = "default",
})

-- Dwindle layout
hl.config({
	dwindle = {
		preserve_split = true,
		force_split = 2,
	},
})

-- Master layout
hl.config({
	master = {
		new_status = "master",
	},
})

-- Misc
hl.config({
	misc = {
		animate_manual_resizes = true,
		animate_mouse_windowdragging = true,
		enable_swallow = true,
		disable_hyprland_logo = true,
	},
})

-- Input
hl.config({
	input = {
		kb_layout = "us,eg",
		kb_variant = "",
		kb_model = "",
		kb_options = "grp:alt_shift_toggle",
		kb_rules = "",
		follow_mouse = 1,
		sensitivity = 0,
		touchpad = {
			natural_scroll = true,
		},
	},
})

-- Per-device config
hl.device({
	name = "epic-mouse-v1",
	sensitivity = -0.5,
})

-- Window rules
hl.window_rule({
	name = "suppress-maximize",
	match = { class = ".*" },
	suppress_event = "maximize",
})

-- Gestures
hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})
