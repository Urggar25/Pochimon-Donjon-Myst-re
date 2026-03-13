extends Node

const SAVE_PATH := "user://savegame.json"

func save_game() -> bool:
	var payload := {
		"team": GameState.team,
		"inventory": GameState.inventory,
		"selected_dungeon_id": GameState.selected_dungeon_id,
		"pending_dungeon_state": GameState.pending_dungeon_state,
		"resources": GameState.resources,
		"camp": GameState.camp
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(payload))
	return true

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return false
	var data: Dictionary = json.data
	GameState.team = data.get("team", [])
	GameState.inventory = data.get("inventory", {})
	GameState.selected_dungeon_id = data.get("selected_dungeon_id", GameState.DEFAULT_DUNGEON_ID)
	GameState.pending_dungeon_state = data.get("pending_dungeon_state", {})
	GameState.resources = data.get("resources", {"wood": 0, "stone": 0, "crystal": 0})
	GameState.camp = data.get("camp", {"campfire_level": 1, "tent_level": 1, "scout_level": 1})
	GameState.emit_signal("state_changed")
	return true
