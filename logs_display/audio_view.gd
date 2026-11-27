extends VBoxContainer

@onready var header: Label = $Header
@onready var play_button: Button = $Controls/PlayButton
@onready var progress: ProgressBar = $Controls/ProgressBar
@onready var body: RichTextLabel = $Body
@onready var player = $Player   # untyped, so it can be either kind of player

func use_speaker(speaker) -> void:
	if player and player.finished.is_connected(_on_finished):
		player.finished.disconnect(_on_finished)
	player = speaker
	player.finished.connect(_on_finished)

var active := false  # true while audio is actually playing (not paused)

func _ready() -> void:
	play_button.text = "Play"
	progress.max_value = 1.0
	progress.show_percentage = false
	play_button.pressed.connect(_on_play_pressed)
	player.finished.connect(_on_finished)
	set_process(false)

func show_entry(entry: AudioLog) -> void:
	stop()
	player.stream = entry.stream
	header.text = entry.title
	body.text = entry.body

func stop() -> void:
	player.stop()
	player.stream_paused = false
	active = false
	progress.value = 0.0
	play_button.text = "Play"
	set_process(false)

func _on_play_pressed() -> void:
	if player.stream == null:
		return
	if active:
		player.stream_paused = true
		active = false
		play_button.text = "Play"
		set_process(false)
	else:
		if player.stream_paused:
			player.stream_paused = false
		else:
			player.play()
		active = true
		play_button.text = "Pause"
		set_process(true)

func _on_finished() -> void:
	stop()

func _process(_delta: float) -> void:
	if player.stream == null:
		return
	var length: float = player.stream.get_length()
	if length > 0.0:
		progress.value = player.get_playback_position() / length
