class_name LogUnlocker
extends Node

@export var log_entry: LogEntry

func unlock() -> void:
	if log_entry == null:
		push_warning("LogUnlocker '%s' has no Log Entry assigned" % get_path())
		return
	LogDatabase.add_log(log_entry)
