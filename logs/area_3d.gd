extends Area3D

@onready var unlocker: LogUnlocker = $LogUnlocker
@onready var unlocker2: LogUnlocker = $LogUnlocker2
@onready var unlocker3: LogUnlocker = $LogUnlocker3
@onready var unlocker4: LogUnlocker = $LogUnlocker4

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body.has_method("sit_down"):
		unlocker.unlock()
		unlocker2.unlock()
		unlocker3.unlock()
		unlocker4.unlock()
#A test for the log unlocker function
