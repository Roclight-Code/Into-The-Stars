extends Node3D

signal lidar_changed(is_on: bool)
signal energy_changed(value: float)
signal power_changed(is_on: bool)
signal lockout_changed(is_locked: bool)
signal lidar_forced_off

@export var max_energy := 100.0
@export var lidar_drain := 2.0          # % per second while lidar is on
@export var idle_recharge := 1.0        # % per second while generator is on, lidar off
@export var shutdown_recharge := 5.0    # % per second while generator is switched off
@export var unlock_threshold := 40.0    # must reach this after being fully drained

var energy := 100.0
var is_on := true
var locked := false
var lidar_active := false

func _process(delta: float) -> void:
	var rate := idle_recharge
	if not is_on:
		rate = shutdown_recharge
	elif lidar_active:
		rate = -lidar_drain

	var old := energy
	energy = clampf(energy + rate * delta, 0.0, max_energy)

	if energy <= 0.0 and not locked:
		_set_locked(true)
		_force_lidar_off()
	elif locked and energy >= unlock_threshold:
		_set_locked(false)

	if energy != old:
		energy_changed.emit(energy)

# --- called by other scripts ---

func can_use_rover() -> bool:        # movement, crank, etc.
	return is_on and not locked

func can_use_lidar() -> bool:
	return is_on and not locked

func set_lidar(on: bool) -> bool:    # returns whether the lidar is now on
	if on and not can_use_lidar():
		return false
	if lidar_active != on:
		lidar_active = on
		lidar_changed.emit(lidar_active)
	return lidar_active

func toggle_power() -> void:         # hook your switch to this
	is_on = not is_on
	if not is_on:
		_force_lidar_off()
	power_changed.emit(is_on)

# --- internal ---

func _set_locked(v: bool) -> void:
	locked = v
	lockout_changed.emit(locked)

func _force_lidar_off() -> void:
	if lidar_active:
		lidar_active = false
		lidar_changed.emit(false)
		lidar_forced_off.emit()
