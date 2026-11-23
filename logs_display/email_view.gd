extends VBoxContainer

@onready var from_label: Label = $From
@onready var to_label: Label = $To
@onready var subject_label: Label = $Subject
@onready var body: RichTextLabel = $Body

func show_entry(entry: EmailLog) -> void:
	from_label.text = "FROM: " + entry.sender
	to_label.text = "TO: " + entry.recipient
	subject_label.text = "SUBJECT: " + entry.title
	body.text = entry.body
