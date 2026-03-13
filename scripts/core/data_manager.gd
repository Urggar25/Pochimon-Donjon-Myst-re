extends Node

const DATA_DIR := "res://data/"

var creatures: Dictionary = {}
var skills: Dictionary = {}
var items: Dictionary = {}
var enemies: Dictionary = {}
var dungeons: Dictionary = {}

func _ready() -> void:
	load_all_data()

func load_all_data() -> void:
	creatures = _load_json("creatures.json")
	skills = _load_json("skills.json")
	items = _load_json("items.json")
	enemies = _load_json("enemies.json")
	dungeons = _load_json("dungeons.json")

func _load_json(file_name: String) -> Dictionary:
	var path := DATA_DIR + file_name
	if not FileAccess.file_exists(path):
		push_error("Data file missing: %s" % path)
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Cannot open data file: %s" % path)
		return {}
	var json := JSON.new()
	var parse_result := json.parse(file.get_as_text())
	if parse_result != OK:
		push_error("Invalid JSON in %s: %s" % [path, json.get_error_message()])
		return {}
	if typeof(json.data) != TYPE_DICTIONARY:
		push_error("JSON root should be a dictionary: %s" % path)
		return {}
	return json.data

func get_creature(id: String) -> Dictionary:
	return creatures.get("creatures", {}).get(id, {}).duplicate(true)

func get_skill(id: String) -> Dictionary:
	return skills.get("skills", {}).get(id, {}).duplicate(true)

func get_item(id: String) -> Dictionary:
	return items.get("items", {}).get(id, {}).duplicate(true)

func get_enemy_template(id: String) -> Dictionary:
	return enemies.get("enemies", {}).get(id, {}).duplicate(true)

func get_dungeon(id: String) -> Dictionary:
	return dungeons.get("dungeons", {}).get(id, {}).duplicate(true)
