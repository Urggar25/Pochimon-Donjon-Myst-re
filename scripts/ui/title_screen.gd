extends Control

signal start_requested
signal load_requested

func _on_new_game_pressed() -> void:
	emit_signal("start_requested")

func _on_load_pressed() -> void:
	emit_signal("load_requested")
