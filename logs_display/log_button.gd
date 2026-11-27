class_name LogButton
extends Button

var skin: ConsoleSkin : set = set_skin

func _ready() -> void:
	focus_mode = Control.FOCUS_NONE
	alignment = HORIZONTAL_ALIGNMENT_LEFT
	mouse_entered.connect(func(): _play(skin.hover_sound if skin else null))
	pressed.connect(func(): _play(skin.click_sound if skin else null))

func set_skin(value: ConsoleSkin) -> void:
	skin = value
	if skin == null:
		return
	if skin.button_normal:
		var hover_tex := skin.button_hover if skin.button_hover else skin.button_normal
		var down_tex := skin.button_pressed if skin.button_pressed else hover_tex
		add_theme_stylebox_override("normal", _box(skin.button_normal))
		add_theme_stylebox_override("hover", _box(hover_tex))
		add_theme_stylebox_override("pressed", _box(down_tex))
		add_theme_stylebox_override("hover_pressed", _box(down_tex))
		add_theme_stylebox_override("focus", StyleBoxEmpty.new())

func _box(tex: Texture2D) -> StyleBoxTexture:
	var sb := StyleBoxTexture.new()
	sb.texture = tex
	var m := float(skin.slice_margin)
	sb.texture_margin_left = m
	sb.texture_margin_right = m
	sb.texture_margin_top = m
	sb.texture_margin_bottom = m
	return sb

func _play(stream: AudioStream) -> void:
	if stream == null:
		return
	var p := AudioStreamPlayer.new()
	p.stream = stream
	add_child(p)
	p.finished.connect(p.queue_free)
	p.play()
