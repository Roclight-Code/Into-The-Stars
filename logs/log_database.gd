extends Node

signal log_added(entry: LogEntry)

var creatures: Array[CreatureLog] = []
var emails: Array[EmailLog] = []
var audio: Array[AudioLog] = []

func add_log(entry: LogEntry) -> void:
	if entry is CreatureLog:
		if creatures.has(entry):
			return
		creatures.append(entry)
	elif entry is EmailLog:
		if emails.has(entry):
			return
		emails.append(entry)
	elif entry is AudioLog:
		if audio.has(entry):
			return
		audio.append(entry)
	else:
		push_warning("LogDatabase: unknown log type")
		return
	log_added.emit(entry)
