extends Node

signal theme_changed(theme_name: String)

var _themes: Dictionary = {}
var _active_theme_name: String = "classic"
var _active_theme: Theme


class ThemePalette:
	var name: String = "classic"

	# Surfaces
	var window_bg: Color
	var panel: Color
	var pack_item_bg: Color
	var outline: Color

	# Titlebar
	var titlebar_bg: Color

	# Sidebar
	var sidebar_bg: Color
	var sidebar_hover_bg: Color
	var sidebar_indicator: Color

	# Text
	var primary_text: Color
	var secondary_text: Color
	var placeholder_text: Color

	# Text inputs
	var input_underline: Color
	var input_disabled_bg: Color

	# Accent & semantic colors
	var accent: Color
	var accent_hover: Color
	var accent_pressed: Color
	var focus: Color
	var danger: Color
	var warning: Color
	var success: Color

	# Dropdowns
	var dropdown_bg: Color
	var dropdown_box_bg: Color
	var dropdown_hover_text_color: Color

	# Buttons
	var button_hover_bg: Color
	var button_hover_outline: Color
	var button_hover_text_color: Color
	var button_pressed_bg: Color
	var button_pressed_outline: Color
	var button_pressed_text_color: Color

	# Icons
	var icon_color_override: Color
	var icon_hover_color: Color
	var icon_pressed_color: Color


class ThemeBoxes:
	# Surfaces
	var panel: StyleBoxFlat
	var sidebar_panel: StyleBoxFlat
	var pack_item: StyleBoxFlat

	# Buttons
	var button_normal: StyleBoxFlat
	var button_hover: StyleBoxFlat
	var button_pressed: StyleBoxFlat
	var button_disabled: StyleBoxFlat

	# Checkboxes & focus outline
	var checkbox_transparent: StyleBoxFlat
	var focus: StyleBoxFlat

	# Text inputs
	var input_normal: StyleBoxFlat
	var input_focus: StyleBoxFlat
	var input_disabled: StyleBoxFlat

	# Dropdowns & spinboxes
	var dropdown_normal: StyleBoxFlat
	var dropdown_hover: StyleBoxFlat
	var dropdown_pressed: StyleBoxFlat
	var spinbox_normal: StyleBoxFlat

	# Popups
	var popup: StyleBoxFlat
	var popup_hover: StyleBoxFlat
	var popup_separator: StyleBoxFlat

	# Dialogs
	var title_bar: StyleBoxFlat

	# Misc
	var transparent: StyleBoxFlat


class ThemeVariation:
	var palette: ThemePalette
	var theme: Theme
	var boxes: ThemeBoxes


func _ready() -> void:
	_build_themes()
	set_theme(_normalize_theme_name(LoadSettings.get_setting("THEME")), false)


func _build_boxes(palette: ThemePalette) -> ThemeBoxes:
	var boxes := ThemeBoxes.new()

	# Surfaces
	boxes.panel = _make_box(palette.panel, palette.outline, 4, 1, 6)
	boxes.sidebar_panel = _make_box(palette.sidebar_bg, Color(0, 0, 0, 0), 0, 0)
	boxes.pack_item = _make_box(palette.pack_item_bg, Color(0, 0, 0, 0), 0, 0)

	# Buttons
	boxes.button_normal = _make_box(palette.panel, palette.outline)
	boxes.button_hover = _make_box(palette.button_hover_bg, palette.button_hover_outline)
	boxes.button_pressed = _make_box(palette.button_pressed_bg, palette.button_pressed_outline)
	boxes.button_disabled = _make_box(palette.panel.lerp(palette.window_bg, 0.5), palette.outline)

	# Checkboxes & focus outline
	boxes.checkbox_transparent = _make_transparent_box()
	boxes.focus = _make_focus_box(palette.focus)

	# Text inputs
	boxes.input_normal = _make_underline_box(palette.panel, palette.input_underline)
	boxes.input_focus = _make_focus_box(palette.focus)
	boxes.input_disabled = _make_underline_box(palette.input_disabled_bg, palette.input_underline)

	# Dropdowns & spinboxes
	boxes.dropdown_normal = _make_box(palette.dropdown_box_bg, palette.outline)
	boxes.dropdown_hover = _make_box(palette.dropdown_box_bg.lerp(palette.accent, 0.10), palette.accent_hover)
	boxes.dropdown_pressed = _make_box(palette.dropdown_box_bg.lerp(palette.accent_pressed, 0.14), palette.accent_pressed)
	boxes.spinbox_normal = _make_underline_box(palette.dropdown_box_bg, palette.input_underline)

	# Popups
	boxes.popup = _make_box(palette.dropdown_bg, palette.outline, 4, 1, 4)
	boxes.popup_hover = _make_box(palette.panel.lerp(palette.accent, 0.08), palette.accent_hover, 4, 1, 4)
	boxes.popup_separator = _make_box(palette.outline, palette.outline, 0, 0, 0)

	# Dialogs
	boxes.title_bar = _make_titlebar_box(palette.sidebar_bg, palette.outline)

	# Misc
	boxes.transparent = _make_transparent_box()

	return boxes


func get_active_theme_name() -> String:
	return _active_theme_name


func get_active_theme() -> Theme:
	return _active_theme


func get_active_palette() -> ThemePalette:
	var variation: ThemeVariation = _themes.get(_active_theme_name)
	return variation.palette if variation else null


func get_active_boxes() -> ThemeBoxes:
	var variation: ThemeVariation = _themes.get(_active_theme_name)
	return variation.boxes if variation else null


func set_theme(theme_name: String, persist: bool = true) -> void:
	var normalized_name := _normalize_theme_name(theme_name)
	if not _themes.has(normalized_name):
		normalized_name = "classic"

	_active_theme_name = normalized_name
	_active_theme = (_themes[normalized_name] as ThemeVariation).theme

	if persist and LoadSettings.get_setting("THEME") != normalized_name:
		LoadSettings.set_setting("THEME", normalized_name)

	theme_changed.emit(normalized_name)


func apply_to(root: Node) -> void:
	if root == null:
		return

	var palette: ThemePalette = get_active_palette()
	if palette == null:
		return

	_apply_runtime_overrides(root, palette)


func _build_themes() -> void:
	_themes.clear()

	for palette in [_create_classic_palette(), _create_dark_palette(), _create_light_palette()]:
		var boxes := _build_boxes(palette)
		var theme := _create_theme(palette, boxes)
		_register_theme(palette, boxes, theme)


func _register_theme(palette: ThemePalette, boxes: ThemeBoxes, theme: Theme) -> void:
	var variation := ThemeVariation.new()
	variation.palette = palette
	variation.boxes = boxes
	variation.theme = theme
	_themes[palette.name] = variation


func _normalize_theme_name(value: Variant) -> String:
	var normalized := str(value).strip_edges().to_lower()
	if normalized == "" or normalized == "null":
		return "classic"
	return normalized


func _create_classic_palette() -> ThemePalette:
	var palette := ThemePalette.new()
	palette.name = "classic"

	# Surfaces
	palette.window_bg = Color.html("#21262E") # main window
	palette.panel = Color.html("#1C1E22") # panels
	palette.pack_item_bg = palette.panel # pack item color
	palette.outline = Color.html("#1C1E22") # panel/button/dropdown border

	# Titlebar
	palette.titlebar_bg = Color.html("#262B32") # header color

	# Sidebar
	palette.sidebar_bg = Color.html("#363D4A") # sidebar
	palette.sidebar_hover_bg = Color.html("#3b4a5b") # sidebar button hover
	palette.sidebar_indicator = Color.html("#6AAEEA") # sidebar indicator

	# Text
	palette.primary_text = Color.html("#FFFFFF") # primary text
	palette.secondary_text = Color.html("#a0a6af") # secondary text
	palette.placeholder_text = palette.secondary_text # textbox placeholder text

	# Text inputs
	palette.input_underline = Color.html("#000000") # textbox underline
	palette.input_disabled_bg = Color.html("#2A2E35") # textbox disabled / checkbox unchecked

	# Accent & semantic colors
	palette.accent = Color.html("#FFFFFF") # link buttons / progress bar
	palette.accent_hover = Color.html("#8cc0f0") # link buttons hover
	palette.accent_pressed = Color.html("#4c90d4") # button click highlight
	palette.focus = Color.html("#FFFFFF") # keyboard selection outline
	palette.danger = Color.html("#bc3452") # red alert / delete button
	palette.warning = Color.html("#F4F700") # yellow alert
	palette.success = Color.html("#00F700") # green alert / check

	# Dropdowns
	palette.dropdown_bg = palette.panel.lerp(palette.primary_text, 0.06) # dropdown menu (popup) background
	palette.dropdown_box_bg = palette.panel.lerp(palette.primary_text, 0.02) # dropdown box / spinbox background
	palette.dropdown_hover_text_color = palette.accent_hover # dropdown box text color

	# Buttons
	palette.button_hover_bg = palette.panel.lerp(palette.accent, 0.10) # button hover background
	palette.button_hover_outline = palette.button_hover_bg # button hover outline
	palette.button_hover_text_color = palette.accent_hover # button label color on hover
	palette.button_pressed_bg = Color.html("#000000") # button background color while pressed
	palette.button_pressed_outline = palette.button_pressed_bg# button border color while pressed
	palette.button_pressed_text_color = palette.primary_text # button label color while pressed

	# Icons
	palette.icon_color_override = Color.html("#FFFFFF") # icon color modulation
	palette.icon_hover_color = palette.sidebar_indicator # child icon color on hover
	palette.icon_pressed_color = palette.accent_pressed # child icon color while pressed

	return palette


func _create_dark_palette() -> ThemePalette:
	var palette := ThemePalette.new()
	palette.name = "dark"

	# Surfaces
	palette.window_bg = Color.html("#222226")
	palette.panel = Color.html("#333337")
	palette.pack_item_bg = palette.panel
	palette.outline = Color.html("#222226")

	# Titlebar
	palette.titlebar_bg = palette.window_bg

	# Sidebar
	palette.sidebar_bg = Color.html("#28282C")
	palette.sidebar_hover_bg = Color.html("#37363B")
	palette.sidebar_indicator = Color.html("#FFFFFF")

	# Text
	palette.primary_text = Color.html("#FFFFFF")
	palette.secondary_text = Color.html("#9B9B9D")
	palette.placeholder_text = palette.secondary_text

	# Text inputs
	palette.input_underline = Color.html("#000000")
	palette.input_disabled_bg = Color.html("#3A3A3F")

	# Accent & semantic colors
	palette.accent = Color.html("#FFFFFF")
	palette.accent_hover = Color.html("#8cc0f0")
	palette.accent_pressed = Color.html("#4c90d4")
	palette.focus = palette.accent
	palette.danger = Color.html("#bc344f")
	palette.warning = Color.html("#F4F700")
	palette.success = Color.html("#00F700")

	# Dropdowns
	palette.dropdown_bg = palette.panel.lerp(palette.primary_text, 0.06)
	palette.dropdown_box_bg = palette.panel.lerp(palette.primary_text, 0.02)
	palette.dropdown_hover_text_color = palette.accent_hover

	# Buttons
	palette.button_hover_bg = palette.panel.lerp(palette.accent, 0.10)
	palette.button_hover_outline = palette.sidebar_indicator
	palette.button_hover_text_color = palette.accent_hover
	palette.button_pressed_bg = palette.panel.lerp(palette.accent_pressed, 0.14)
	palette.button_pressed_outline = palette.button_pressed_bg
	palette.button_pressed_text_color = palette.accent_pressed

	# Icons
	palette.icon_color_override = Color.html("#FFFFFF")
	palette.icon_hover_color = palette.accent_hover
	palette.icon_pressed_color = palette.accent_pressed

	return palette


func _create_light_palette() -> ThemePalette:
	var palette := ThemePalette.new()
	palette.name = "light"

	# Surfaces
	palette.window_bg = Color.html("#F4F5F9")
	palette.panel = Color.html("#FCFCFC")
	palette.pack_item_bg = palette.panel
	palette.outline = Color.html("#D6DCE3")

	# Titlebar
	palette.titlebar_bg = palette.window_bg

	# Sidebar
	palette.sidebar_bg = Color.html("#FCFCFC")
	palette.sidebar_hover_bg = Color.html("#BAD0F9")
	palette.sidebar_indicator = Color.html("#246BFE")

	# Text
	palette.primary_text = Color.html("#000000")
	palette.secondary_text = Color.html("#7B8899")
	palette.placeholder_text = Color.html("#5a5f66")

	# Text inputs
	palette.input_underline = Color.html("#A9B7C8")
	palette.input_disabled_bg = Color.html("#E4E7EB")

	# Accent & semantic colors
	palette.accent = Color.html("#000000")
	palette.accent_hover = Color.html("#6D9CFF")
	palette.accent_pressed = Color.html("#4c90d4")
	palette.focus = palette.accent
	palette.danger = Color.html("#EC6060")
	palette.warning = Color.html("#EBEA97")
	palette.success = Color.html("#A6EED4")

	# Dropdowns
	palette.dropdown_bg = palette.panel.lerp(palette.primary_text, 0.06)
	palette.dropdown_box_bg = palette.panel.lerp(palette.primary_text, 0.02)
	palette.dropdown_hover_text_color = palette.primary_text

	# Buttons
	palette.button_hover_bg = palette.panel.lerp(palette.accent, 0.10)
	palette.button_hover_outline = palette.accent_hover
	palette.button_hover_text_color = palette.accent_hover
	palette.button_pressed_bg = palette.panel.lerp(palette.accent_pressed, 0.14)
	palette.button_pressed_outline = palette.accent_pressed
	palette.button_pressed_text_color = palette.accent_pressed

	# Icons
	palette.icon_color_override = Color.html("#0B111C")
	palette.icon_hover_color = palette.sidebar_indicator
	palette.icon_pressed_color = palette.accent_pressed

	return palette


func _create_theme(palette: ThemePalette, boxes: ThemeBoxes) -> Theme:
	var theme := Theme.new()

	# Base text color for every themed control type
	for type_name in ["Control", "Label", "RichTextLabel", "Button", "CheckButton", "CheckBox", "OptionButton", "LinkButton", "Panel", "PanelContainer", "LineEdit", "SpinBox", "PopupMenu"]:
		theme.set_color("font_color", type_name, palette.primary_text)

	# Labels
	theme.set_color("default_color", "RichTextLabel", palette.primary_text)
	theme.set_color("font_color", "Label", palette.primary_text)

	# Button colors
	theme.set_color("font_color", "Button", palette.primary_text)
	theme.set_color("font_hover_color", "Button", palette.button_hover_text_color)
	theme.set_color("font_pressed_color", "Button", palette.button_pressed_text_color)
	theme.set_color("font_focus_color", "Button", palette.primary_text)
	theme.set_color("font_disabled_color", "Button", palette.secondary_text)
	theme.set_color("icon_normal_color", "Button", palette.primary_text)
	theme.set_color("icon_hover_color", "Button", palette.accent_hover)
	theme.set_color("icon_pressed_color", "Button", palette.primary_text)
	theme.set_color("icon_focus_color", "Button", palette.primary_text)
	theme.set_color("icon_disabled_color", "Button", palette.secondary_text)

	# OptionButton colors
	theme.set_color("font_hover_color", "OptionButton", palette.dropdown_hover_text_color)
	theme.set_color("font_pressed_color", "OptionButton", palette.primary_text)
	theme.set_color("font_hover_pressed_color", "OptionButton", palette.dropdown_hover_text_color)
	theme.set_color("icon_hover_color", "OptionButton", palette.accent_hover)

	# PopupMenu colors & styleboxes
	theme.set_color("font_color", "PopupMenu", palette.primary_text)
	theme.set_color("font_hover_color", "PopupMenu", palette.primary_text)
	theme.set_color("font_disabled_color", "PopupMenu", palette.secondary_text)
	theme.set_color("font_accelerator_color", "PopupMenu", palette.secondary_text)
	theme.set_color("font_separator_color", "PopupMenu", palette.primary_text)
	theme.set_color("font_separator_outline_color", "PopupMenu", palette.window_bg)
	theme.set_stylebox("panel", "PopupMenu", boxes.popup)
	theme.set_stylebox("panel_disabled", "PopupMenu", boxes.popup)
	theme.set_stylebox("hover", "PopupMenu", boxes.popup_hover)
	theme.set_stylebox("separator", "PopupMenu", boxes.popup_separator)
	theme.set_stylebox("labeled_separator_left", "PopupMenu", boxes.transparent)
	theme.set_stylebox("labeled_separator_right", "PopupMenu", boxes.transparent)

	# LinkButton colors
	theme.set_color("font_color", "LinkButton", palette.accent)
	theme.set_color("font_hover_color", "LinkButton", palette.accent_hover)
	theme.set_color("font_pressed_color", "LinkButton", palette.accent_pressed)

	# LineEdit colors & styleboxes
	theme.set_color("font_color", "LineEdit", palette.primary_text)
	theme.set_color("font_placeholder_color", "LineEdit", palette.placeholder_text)
	theme.set_color("caret_color", "LineEdit", palette.accent)
	theme.set_color("selection_color", "LineEdit", palette.accent)
	theme.set_stylebox("read_only", "LineEdit", boxes.input_disabled)
	theme.set_color("font_uneditable_color", "LineEdit", palette.secondary_text)

	# SpinBox colors
	theme.set_color("font_color", "SpinBox", palette.primary_text)
	theme.set_color("caret_color", "SpinBox", palette.accent)
	theme.set_color("selection_color", "SpinBox", palette.accent)

	# Panel / PanelContainer / RichTextLabel styleboxes
	for type_name in ["Panel", "PanelContainer"]:
		theme.set_stylebox("panel", type_name, boxes.panel)
	theme.set_stylebox("panel", "RichTextLabel", boxes.transparent)

	# Tooltip
	theme.set_stylebox("panel", "TooltipPanel", boxes.popup)
	theme.set_color("font_color", "TooltipLabel", palette.primary_text)
	theme.set_font_size("font_size", "TooltipLabel", 14)

	# Shared base styleboxes per widget state
	for state in ["normal", "hover", "pressed", "hover_pressed"]:
		theme.set_stylebox(state, "Button", boxes.button_normal)
		theme.set_stylebox(state, "CheckButton", boxes.checkbox_transparent)
		theme.set_stylebox(state, "CheckBox", boxes.checkbox_transparent)
		theme.set_stylebox(state, "OptionButton", boxes.dropdown_normal)
		theme.set_stylebox(state, "LineEdit", boxes.input_normal)
		theme.set_stylebox(state, "SpinBox", boxes.spinbox_normal)

	theme.set_stylebox("focus", "CheckButton", boxes.focus)
	theme.set_stylebox("focus", "CheckBox", boxes.focus)

	# CheckButton & CheckBox hover+pressed colors
	theme.set_color("font_hover_pressed_color", "CheckButton", palette.accent_hover)
	theme.set_color("icon_hover_pressed_color", "CheckButton", palette.accent_hover)
	theme.set_color("font_hover_pressed_color", "CheckBox", palette.accent_hover)
	theme.set_color("icon_hover_pressed_color", "CheckBox", palette.accent_hover)

	# Button state overrides (hover / pressed / focus)
	theme.set_stylebox("hover", "Button", boxes.button_hover)
	theme.set_stylebox("pressed", "Button", boxes.button_pressed)
	theme.set_stylebox("focus", "Button", boxes.focus)

	# Disabled state overrides
	theme.set_stylebox("disabled", "Button", boxes.button_disabled)
	theme.set_stylebox("disabled", "CheckButton", boxes.checkbox_transparent)
	theme.set_stylebox("disabled", "CheckBox", boxes.checkbox_transparent)
	theme.set_stylebox("disabled", "OptionButton", boxes.dropdown_normal)
	theme.set_stylebox("disabled", "LineEdit", boxes.input_disabled)
	theme.set_stylebox("disabled", "SpinBox", boxes.input_disabled)
	theme.set_color("font_disabled_color", "LineEdit", palette.secondary_text)
	theme.set_color("font_disabled_color", "SpinBox", palette.secondary_text)

	# OptionButton state overrides
	theme.set_stylebox("hover", "OptionButton", boxes.dropdown_hover)
	theme.set_stylebox("pressed", "OptionButton", boxes.dropdown_pressed)
	theme.set_stylebox("focus", "OptionButton", boxes.focus)

	# LineEdit / SpinBox focus overrides
	theme.set_stylebox("focus", "LineEdit", boxes.input_focus)
	theme.set_stylebox("focus", "SpinBox", boxes.input_focus)

	return theme


func _make_box(background: Color, border: Color, radius: int = 4, border_width: int = 1, content_margin: int = 0) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = background
	box.border_width_left = border_width
	box.border_width_top = border_width
	box.border_width_right = border_width
	box.border_width_bottom = border_width
	box.border_color = border
	box.corner_radius_top_left = radius
	box.corner_radius_top_right = radius
	box.corner_radius_bottom_left = radius
	box.corner_radius_bottom_right = radius
	box.content_margin_left = content_margin
	box.content_margin_top = content_margin
	box.content_margin_right = content_margin
	box.content_margin_bottom = content_margin
	return box


func _make_focus_box(color: Color) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = Color(0, 0, 0, 0)
	box.border_width_left = 1
	box.border_width_top = 1
	box.border_width_right = 1
	box.border_width_bottom = 1
	box.border_color = color
	box.corner_radius_top_left = 4
	box.corner_radius_top_right = 4
	box.corner_radius_bottom_left = 4
	box.corner_radius_bottom_right = 4
	return box


func _make_transparent_box() -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = Color(0, 0, 0, 0)
	box.border_width_left = 0
	box.border_width_top = 0
	box.border_width_right = 0
	box.border_width_bottom = 0
	box.content_margin_left = 0
	box.content_margin_top = 0
	box.content_margin_right = 0
	box.content_margin_bottom = 0
	return box


func _make_underline_box(background: Color, underline_color: Color) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = background
	box.border_width_left = 0
	box.border_width_top = 0
	box.border_width_right = 0
	box.border_width_bottom = 2
	box.border_color = underline_color
	box.corner_radius_top_left = 4
	box.corner_radius_top_right = 4
	box.corner_radius_bottom_left = 0
	box.corner_radius_bottom_right = 0
	return box


func _make_titlebar_box(background: Color, border: Color) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = background
	box.border_width_bottom = 1
	box.border_color = border
	box.corner_radius_top_left = 4
	box.corner_radius_top_right = 4
	box.content_margin_left = 10
	box.content_margin_top = 6
	box.content_margin_right = 6
	box.content_margin_bottom = 6
	return box


func _apply_runtime_overrides(root: Node, palette: ThemePalette) -> void:
	if root is Control:
		(root as Control).theme = _active_theme

	var boxes := get_active_boxes()
	_apply_node_recursive(root, palette, boxes)


func _apply_node_recursive(node: Node, palette: ThemePalette, boxes: ThemeBoxes) -> void:
	if node is Control:
		_apply_control_overrides(node as Control, palette, boxes)
	elif node is Sprite2D:
		_apply_sprite_overrides(node as Sprite2D, palette)

	for child in node.get_children():
		_apply_node_recursive(child, palette, boxes)


func _apply_control_overrides(control: Control, palette: ThemePalette, boxes: ThemeBoxes) -> void:
	if control is RichTextLabel:
		var label_color := palette.secondary_text if _is_muted_text_node(control.name) else palette.primary_text
		control.add_theme_color_override("default_color", label_color)
		control.add_theme_color_override("font_color", label_color)
	elif control is Label:
		control.add_theme_color_override("font_color", palette.primary_text)

	if control is CheckButton or control is CheckBox:
		for state in ["normal", "hover", "pressed", "hover_pressed", "disabled", "disabled_pressed"]:
			control.add_theme_stylebox_override(state, boxes.checkbox_transparent)
		control.add_theme_stylebox_override("focus", boxes.focus)
	elif control is OptionButton:
		control.add_theme_stylebox_override("normal", boxes.dropdown_normal)
		control.add_theme_stylebox_override("hover", boxes.dropdown_hover)
		control.add_theme_stylebox_override("pressed", boxes.dropdown_pressed)
		control.add_theme_stylebox_override("disabled", boxes.dropdown_normal)
		control.add_theme_stylebox_override("focus", boxes.focus)
	elif control is Button:
		control.add_theme_stylebox_override("normal", boxes.button_normal)
		control.add_theme_stylebox_override("hover", boxes.button_hover)
		control.add_theme_stylebox_override("pressed", boxes.button_pressed)
		control.add_theme_stylebox_override("disabled", boxes.button_disabled)
		control.add_theme_stylebox_override("focus", boxes.focus)

	if control is LinkButton:
		control.add_theme_color_override("font_color", palette.accent)
		control.add_theme_color_override("font_hover_color", palette.accent_hover)
		control.add_theme_color_override("font_pressed_color", palette.accent_pressed)

	if control is Panel or control is PanelContainer:
		var panel_box: StyleBoxFlat = boxes.panel
		if control.name == "Sidebar":
			panel_box = boxes.sidebar_panel
		elif control.name == "TitleBar":
			panel_box = boxes.title_bar
		elif control.is_in_group("pack_item_panel"):
			panel_box = boxes.pack_item
		control.add_theme_stylebox_override("panel", panel_box)

	if control is LineEdit or control is SpinBox:
		# GET THE INTERNAL LINE EDIT FOR SPINBOXES
		var target_control = control.get_line_edit() if control is SpinBox else control

		target_control.add_theme_color_override("font_color", palette.primary_text)
		target_control.add_theme_color_override("font_disabled_color", palette.secondary_text)
		target_control.add_theme_color_override("font_uneditable_color", palette.secondary_text)
		target_control.add_theme_color_override("font_placeholder_color", palette.placeholder_text)
		target_control.add_theme_color_override("caret_color", palette.accent)
		target_control.add_theme_color_override("selection_color", palette.accent)

		var normal_box: StyleBoxFlat = boxes.spinbox_normal if control is SpinBox else boxes.input_normal
		target_control.add_theme_stylebox_override("normal", normal_box)
		target_control.add_theme_stylebox_override("focus", boxes.input_focus)
		target_control.add_theme_stylebox_override("disabled", boxes.input_disabled)
		target_control.add_theme_stylebox_override("read_only", boxes.input_disabled)

	if control is ColorRect:
		_apply_color_rect_override(control as ColorRect, palette)
	elif control is TextureRect and _is_ui_icon(control.name):
		var owner_ctrl := control.get_parent()
		if owner_ctrl is Button and (owner_ctrl as Button).disabled:
			(control as TextureRect).modulate = palette.secondary_text
		else:
			(control as TextureRect).modulate = palette.icon_color_override


func _apply_color_rect_override(rect: ColorRect, palette: ThemePalette) -> void:
	if rect.name == "BackgroundColor":
		rect.color = palette.window_bg
	elif rect.name == "HelpScreen":
		rect.color = palette.window_bg
	elif rect.name == "ColorRect" and _has_ancestor_named(rect, "Titlebar"):
		rect.color = palette.titlebar_bg
	elif rect.name == "Background":
		if _has_ancestor_in_group(rect, "recent_world_item_panel"):
			rect.color = palette.panel
		elif _has_ancestor_in_group(rect, "pack_item_panel"):
			rect.color = palette.pack_item_bg
		elif _has_ancestor_named(rect, "PackItem"):
			rect.color = palette.pack_item_bg
		elif _has_ancestor_named(rect, "Sidebar") or _has_ancestor_named(rect, "SidebarToggleButton") or _has_ancestor_named(rect, "Import") or _has_ancestor_named(rect, "Save"):
			if _has_ancestor_named(rect, "NavItem"):
				rect.color = palette.sidebar_hover_bg if _is_hovered_sidebar_node(rect) else palette.sidebar_bg
			else:
				rect.color = palette.sidebar_bg
		else:
			rect.color = palette.panel


func _is_muted_text_node(node_name: String) -> bool:
	return node_name.ends_with("Desc") or node_name == "NoWorldLoadedLabel" or node_name == "MessageLabel" or node_name == "VersionLabel"


func _has_ancestor_named(control: Node, ancestor_name: String) -> bool:
	var current := control.get_parent()
	while current != null:
		if current.name == ancestor_name:
			return true
		current = current.get_parent()
	return false


func _has_ancestor_in_group(control: Node, group_name: String) -> bool:
	var current := control.get_parent()
	while current != null:
		if current.is_in_group(group_name):
			return true
		current = current.get_parent()
	return false


func _apply_sprite_overrides(sprite: Sprite2D, palette: ThemePalette) -> void:
	if _is_ui_icon(sprite.name):
		sprite.modulate = palette.icon_color_override


func _is_ui_icon(node_name: String) -> bool:
	return node_name in ["Icon", "DependencyInfo"]


func _is_hovered_sidebar_node(control: Node) -> bool:
	var current := control
	while current != null:
		if current.has_meta("hovered") and bool(current.get_meta("hovered")):
			return true
		current = current.get_parent()
	return false
