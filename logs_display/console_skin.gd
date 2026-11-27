class_name ConsoleSkin
extends Resource

# Everything here is applied to buttons that are created while the game runs
# (the sidebar entries), so it can't be set on a node in the scene.
# Fonts and text colors come from the Theme assigned to LogsDisplay.
# Background color and scanlines are set on their own nodes in logs_display.tscn.

@export_group("Button images")
@export var button_normal: Texture2D
@export var button_hover: Texture2D     # shown while the mouse is over it
@export var button_pressed: Texture2D   # optional, falls back to hover
@export var slice_margin := 12          # 9-slice border in pixels, so one image stretches to any size

@export_group("Sounds")
@export var hover_sound: AudioStream
@export var click_sound: AudioStream
@export var console_enter_sound: AudioStream
@export var console_exit_sound: AudioStream
