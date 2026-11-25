extends Area3D

@onready var unlocker: LogUnlocker = $LogUnlocker

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body.has_method("sit_down"):
		unlocker.unlock()
