extends Node

signal state_changed

const DEFAULT_DUNGEON_ID := "green_cavern"

var team: Array[Dictionary] = []
var inventory: Dictionary = {}
var selected_dungeon_id: String = DEFAULT_DUNGEON_ID
var pending_dungeon_state: Dictionary = {}

func start_new_game() -> void:
	team.clear()
	inventory.clear()
	pending_dungeon_state.clear()
	selected_dungeon_id = DEFAULT_DUNGEON_ID
	_add_default_team()
	inventory["potion"] = 2
	emit_signal("state_changed")

func _add_default_team() -> void:
	for id in ["sprigoo", "emberix", "bublo"]:
		var creature := DataManager.get_creature(id)
		if creature.is_empty():
			continue
		creature["id"] = id
		creature["hp"] = creature.get("max_hp", 10)
		team.append(creature)

func is_team_defeated() -> bool:
	for creature in team:
		if creature.get("hp", 0) > 0:
			return false
	return true

func heal_team_partial(amount: int) -> void:
	for creature in team:
		var max_hp := creature.get("max_hp", 1)
		creature["hp"] = mini(max_hp, creature.get("hp", 0) + amount)
	emit_signal("state_changed")

func consume_item(item_id: String) -> bool:
	var count := inventory.get(item_id, 0)
	if count <= 0:
		return false
	inventory[item_id] = count - 1
	if inventory[item_id] <= 0:
		inventory.erase(item_id)
	emit_signal("state_changed")
	return true

func add_item(item_id: String, amount: int = 1) -> void:
	inventory[item_id] = inventory.get(item_id, 0) + amount
	emit_signal("state_changed")
