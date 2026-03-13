extends Node

signal state_changed

const DEFAULT_DUNGEON_ID := "green_cavern"
const RESOURCE_IDS := ["wood", "stone", "crystal"]

var team: Array[Dictionary] = []
var inventory: Dictionary = {}
var resources: Dictionary = {}
var camp: Dictionary = {}
var selected_dungeon_id: String = DEFAULT_DUNGEON_ID
var pending_dungeon_state: Dictionary = {}

func start_new_game() -> void:
	team.clear()
	inventory.clear()
	pending_dungeon_state.clear()
	selected_dungeon_id = DEFAULT_DUNGEON_ID
	resources = {
		"wood": 0,
		"stone": 0,
		"crystal": 0
	}
	camp = {
		"campfire_level": 1,
		"tent_level": 1,
		"scout_level": 1
	}
	_add_default_team()
	inventory["potion"] = 2
	emit_signal("state_changed")

func _add_default_team() -> void:
	for id in ["sprigoo", "emberix", "bublo"]:
		var creature: Dictionary = DataManager.get_creature(id)
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
		var max_hp: int = int(creature.get("max_hp", 1))
		creature["hp"] = mini(max_hp, int(creature.get("hp", 0)) + amount)
	emit_signal("state_changed")

func consume_item(item_id: String) -> bool:
	var count: int = int(inventory.get(item_id, 0))
	if count <= 0:
		return false
	inventory[item_id] = count - 1
	if inventory[item_id] <= 0:
		inventory.erase(item_id)
	emit_signal("state_changed")
	return true

func add_item(item_id: String, amount: int = 1) -> void:
	inventory[item_id] = int(inventory.get(item_id, 0)) + amount
	emit_signal("state_changed")

func add_resource(resource_id: String, amount: int = 1) -> void:
	if not resources.has(resource_id):
		resources[resource_id] = 0
	resources[resource_id] = int(resources[resource_id]) + amount
	emit_signal("state_changed")

func get_resource(resource_id: String) -> int:
	return int(resources.get(resource_id, 0))

func can_pay_resources(cost: Dictionary) -> bool:
	for key in cost.keys():
		if get_resource(key) < int(cost[key]):
			return false
	return true

func pay_resources(cost: Dictionary) -> bool:
	if not can_pay_resources(cost):
		return false
	for key in cost.keys():
		resources[key] = get_resource(key) - int(cost[key])
	emit_signal("state_changed")
	return true

func get_camp_bonus(kind: String) -> int:
	match kind:
		"rest_heal":
			return 3 + int(camp.get("campfire_level", 1)) + int(camp.get("tent_level", 1))
		"spawn_safety":
			return int(camp.get("scout_level", 1))
		_:
			return 0
