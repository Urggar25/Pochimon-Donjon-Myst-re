extends Control

signal back_to_title_requested

func _on_title_pressed() -> void:
	emit_signal("back_to_title_requested")
