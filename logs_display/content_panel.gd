extends MarginContainer

@onready var creature_view = $CreatureView
@onready var email_view = $EmailView
@onready var audio_view = $AudioView

func _ready() -> void:
	_hide_all()

func _hide_all() -> void:
	creature_view.visible = false
	email_view.visible = false
	audio_view.stop()
	audio_view.visible = false

func show_entry(entry: LogEntry) -> void:
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
