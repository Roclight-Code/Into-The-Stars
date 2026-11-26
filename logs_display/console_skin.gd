class_name ConsoleSkin
extends Resource

@export_group("Button images")
@export var button_normal: Texture2D
@export var button_hover: Texture2D     # shown while the mouse is over it
@export var button_pressed: Texture2D   # optional, falls back to hover
@export var slice_margin := 12          # 9-slice border in pixels, so one image stretches to any size

@export_group("Text")
@export var font: Font
@export var font_color := Color(0.6, 1.0, 0.75)
@export var font_hover_color := Color(1, 1, 1)
@export var text_color := Color(0.7, 1.0, 0.8)

@export_group("Sounds")
@export var hover_sound: AudioStream
@export var click_sound: AudioStream
@export var console_enter_sound: AudioStream
@export var console_exit_sound: AudioStream

@export_group("Screen")
@export var background_color := Color(0.0, 0.0, 0.0)
@export var scanline_color := Color(0.2, 1.0, 0.4)
