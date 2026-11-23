extends VBoxContainer

@onready var header: Label = $Header
@onready var picture: TextureRect = $Picture
@onready var body: RichTextLabel = $Body

func show_entry(entry: CreatureLog) -> void:
	header.text = entry.title
	picture.texture = entry.picture
	body.text = entry.body
