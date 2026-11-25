extends MarginContainer

@onready var creature_view = $CreatureView
@onready var email_view = $EmailView
@onready var audio_view = $AudioView

func _ready() -> void:
	for v in [creature_view, email_view, audio_view]:
		v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		v.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_hide_all()

func _hide_all() -> void:
	creature_view.visible = false
	email_view.visible = false
	audio_view.stop()
	audio_view.visible = false

func show_entry(entry: LogEntry) -> void:
	print("show_entry called: ", entry.title)
	_hide_all()
	if entry is CreatureLog:
		creature_view.show_entry(entry)
		creature_view.visible = true
	elif entry is EmailLog:
		email_view.show_entry(entry)
		email_view.visible = true
	elif entry is AudioLog:
		audio_view.show_entry(entry)
		audio_view.visible = true

	await get_tree().process_frame
	print("--- VIEW DEBUG --- panel size: ", size)
	for v in [creature_view, email_view, audio_view]:
		if v.visible:
			print(v.name, " pos=", v.position, " size=", v.size)
			for c in v.get_children():
				if c is Label:
					print("  ", c.name, " size=", c.size, " text='", c.text.left(20), "' color=", c.get_theme_color("font_color"))
				elif c is RichTextLabel:
					print("  ", c.name, " size=", c.size, " text='", c.text.left(20), "' color=", c.get_theme_color("default_color"))
