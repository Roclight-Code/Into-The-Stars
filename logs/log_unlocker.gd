class_name LogUnlocker
extends Node

@export var log_entry: LogEntry

func unlock() -> void:
	if log_entry:
		LogDatabase.add_log(log_entry)
