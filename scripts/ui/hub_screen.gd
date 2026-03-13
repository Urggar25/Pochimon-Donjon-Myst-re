extends Control

signal enter_dungeon_requested
signal back_to_title_requested

@onready var team_label: Label = $Margin/VBox/TeamLabel
@onready var inventory_label: Label = $Margin/VBox/InventoryLabel
@onready var status_label: Label = $Margin/VBox/StatusLabel

func _ready() -> void:
	_refresh()
	GameState.state_changed.connect(_refresh)

func _exit_tree() -> void:
	if GameState.state_changed.is_connected(_refresh):
		GameState.state_changed.disconnect(_refresh)

func _refresh() -> void:
	var team_lines: Array[String] = []
	for creature in GameState.team:
		team_lines.append("%s - PV %d/%d" % [creature.get("name", "?"), creature.get("hp", 0), creature.get("max_hp", 0)])
	team_label.text = "Équipe:\n" + "\n".join(team_lines)

	var inv_lines: Array[String] = []
	for id in GameState.inventory.keys():
		var item := DataManager.get_item(id)
		inv_lines.append("%s x%d" % [item.get("name", id), GameState.inventory[id]])
	inventory_label.text = "Inventaire: " + (", ".join(inv_lines) if not inv_lines.is_empty() else "vide")

func _on_enter_dungeon_pressed() -> void:
	emit_signal("enter_dungeon_requested")

func _on_rest_pressed() -> void:
	GameState.heal_team_partial(4)
	status_label.text = "L'équipe se repose (+4 PV)."

func _on_save_pressed() -> void:
	status_label.text = "Sauvegarde OK." if SaveManager.save_game() else "Échec de sauvegarde."

func _on_title_pressed() -> void:
	emit_signal("back_to_title_requested")
