class_name CategorySection
extends VBoxContainer

signal entry_selected(entry: LogEntry)
signal unread_changed

@export var category_name: String = "Category"

@onready var header: Button = $Header
@onready var list: VBoxContainer = $List

var expanded := false
var unread: Dictionary = {}  # LogEntry -> Button

func _ready() -> void:
	list.visible = false
	header.alignment = HORIZONTAL_ALIGNMENT_LEFT
	header.pressed.connect(_toggle)
	_update_header()

func _toggle() -> void:
	expanded = not expanded
	list.visible = expanded
	_update_header()

func add_entry(entry: LogEntry, is_new := false) -> void:
	var button := Button.new()
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.text = ("* " if is_new else "") + entry.title
	button.pressed.connect(_on_entry_pressed.bind(entry, button))
	list.add_child(button)
	if is_new:
		unread[entry] = button
		_update_header()
		unread_changed.emit()

func _on_entry_pressed(entry: LogEntry, button: Button) -> void:
	if unread.has(entry):
		unread.erase(entry)
		button.text = entry.title
		_update_header()
		unread_changed.emit()
	entry_selected.emit(entry)

func _update_header() -> void:
	var arrow := "v " if expanded else "> "
	var badge := " (%d)" % unread.size() if unread.size() > 0 else ""
	header.text = arrow + category_name + badge
