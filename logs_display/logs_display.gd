extends Control

@onready var creatures_section: CategorySection = $HBox/Sidebar/CreaturesSection
@onready var audio_section: CategorySection = $HBox/Sidebar/AudioSection
@onready var emails_section: CategorySection = $HBox/Sidebar/EmailsSection
@onready var content_panel = $HBox/ContentPanel

signal unread_changed(total: int)

@export var font_size := 28

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
	
		# TEMP TEST - delete later
	var test_email := EmailLog.new()
	test_email.title = "Test email"
	test_email.sender = "A"
	test_email.recipient = "B"
	LogDatabase.add_log(test_email)

func get_unread_total() -> int:
	return creatures_section.unread.size() + audio_section.unread.size() + emails_section.unread.size()

func _on_section_unread_changed() -> void:
	unread_changed.emit(get_unread_total())
