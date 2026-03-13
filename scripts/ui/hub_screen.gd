extends Control

signal enter_dungeon_requested
signal back_to_title_requested

@onready var team_label: Label = $Margin/VBox/TeamLabel
@onready var inventory_label: Label = $Margin/VBox/InventoryLabel
@onready var resources_label: Label = $Margin/VBox/ResourcesLabel
@onready var camp_label: Label = $Margin/VBox/CampLabel
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

	resources_label.text = "Ressources: Bois %d | Pierre %d | Cristal %d" % [
		GameState.get_resource("wood"),
		GameState.get_resource("stone"),
		GameState.get_resource("crystal")
	]
	camp_label.text = "Camp: Feu niv.%d | Tente niv.%d | Éclaireurs niv.%d" % [
		int(GameState.camp.get("campfire_level", 1)),
		int(GameState.camp.get("tent_level", 1)),
		int(GameState.camp.get("scout_level", 1))
	]

func _on_enter_dungeon_pressed() -> void:
	emit_signal("enter_dungeon_requested")

func _on_rest_pressed() -> void:
	var heal_amount: int = GameState.get_camp_bonus("rest_heal")
	GameState.heal_team_partial(heal_amount)
	status_label.text = "Repos au camp (+%d PV)." % heal_amount

func _on_upgrade_fire_pressed() -> void:
	_upgrade_camp("campfire_level", {"wood": 5, "stone": 3}, "Feu amélioré")

func _on_upgrade_tent_pressed() -> void:
	_upgrade_camp("tent_level", {"wood": 6, "crystal": 2}, "Tente améliorée")

func _on_upgrade_scout_pressed() -> void:
	_upgrade_camp("scout_level", {"stone": 4, "crystal": 4}, "Éclaireurs renforcés")

func _upgrade_camp(stat: String, cost: Dictionary, success_text: String) -> void:
	if int(GameState.camp.get(stat, 1)) >= 5:
		status_label.text = "Niveau maximal atteint pour %s." % stat
		return
	if not GameState.pay_resources(cost):
		status_label.text = "Ressources insuffisantes: %s" % [str(cost)]
		return
	GameState.camp[stat] = int(GameState.camp.get(stat, 1)) + 1
	GameState.emit_signal("state_changed")
	status_label.text = success_text

func _on_save_pressed() -> void:
	status_label.text = "Sauvegarde OK." if SaveManager.save_game() else "Échec de sauvegarde."

func _on_title_pressed() -> void:
	emit_signal("back_to_title_requested")
