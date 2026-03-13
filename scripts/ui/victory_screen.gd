extends Control

signal back_to_hub_requested

func _on_hub_pressed() -> void:
	emit_signal("back_to_hub_requested")
