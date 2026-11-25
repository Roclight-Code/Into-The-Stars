extends Control

@onready var creatures_section: CategorySection = $HBox/Sidebar/CreaturesSection
@onready var audio_section: CategorySection = $HBox/Sidebar/AudioSection
@onready var emails_section: CategorySection = $HBox/Sidebar/EmailsSection
@onready var content_panel = $HBox/ContentPanel

signal unread_changed(total: int)

@export var font_size := 28
@export var skin: ConsoleSkin

func _fit_to_viewport() -> void:
	position = Vector2.ZERO
	size = get_viewport_rect().size

func _ready() -> void:
	_fit_to_viewport()
	get_viewport().size_changed.connect(_fit_to_viewport)
	await get_tree().process_frame
	var ui_theme := Theme.new()
	ui_theme.default_font_size = font_size
	theme = ui_theme
	for s in [creatures_section, audio_section, emails_section]:
		s.set_skin(skin)
	for e in LogDatabase.creatures: creatures_section.add_entry(e)
	for e in LogDatabase.audio: audio_section.add_entry(e)
	for e in LogDatabase.emails: emails_section.add_entry(e)

	for section in [creatures_section, audio_section, emails_section]:
		section.entry_selected.connect(_on_entry_selected)
		section.unread_changed.connect(_on_section_unread_changed)

	LogDatabase.log_added.connect(_on_log_added)

func _on_log_added(entry: LogEntry) -> void:
	if entry is CreatureLog:
		creatures_section.add_entry(entry, true)
	elif entry is AudioLog:
		audio_section.add_entry(entry, true)
	elif entry is EmailLog:
		emails_section.add_entry(entry, true)
	# backlight pulse will go here later

func _on_entry_selected(entry: LogEntry) -> void:
	content_panel.show_entry(entry)

func _unlock_folder(path: String) -> void:
	for file in DirAccess.get_files_at(path):
		var f := file.trim_suffix(".remap")
		if f.ends_with(".tres"):
			var entry = load(path.path_join(f))
			if entry is LogEntry:
				LogDatabase.add_log(entry)

func get_unread_total() -> int:
	return creatures_section.unread.size() + audio_section.unread.size() + emails_section.unread.size()

func _on_section_unread_changed() -> void:
	unread_changed.emit(get_unread_total())

func console_entered() -> void:
	_play_sound(skin.console_enter_sound if skin else null)

func console_exited() -> void:
	_play_sound(skin.console_exit_sound if skin else null)

func _play_sound(stream: AudioStream) -> void:
	if stream == null:
		return
	var p := AudioStreamPlayer.new()
	p.stream = stream
	add_child(p)
	p.finished.connect(p.queue_free)
	p.play()

func use_speaker(speaker) -> void:
	content_panel.audio_view.use_speaker(speaker)
