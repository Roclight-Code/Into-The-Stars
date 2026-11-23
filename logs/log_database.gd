extends Node

signal log_added(entry: LogEntry)

var creatures: Array[CreatureLog] = []
var emails: Array[EmailLog] = []
var audio: Array[AudioLog] = []

func add_log(entry: LogEntry) -> void:
	if entry is CreatureLog:
		creatures.append(entry)
	elif entry is EmailLog:
		emails.append(entry)
	elif entry is AudioLog:
		audio.append(entry)
	else:
		push_warning("LogDatabase: unknown log type")
		return
	log_added.emit(entry)
