extends Node2D

@export var tile_size := 40
@export var grid_color := Color(0.18, 0.22, 0.28, 0.6)

const BG_COLOR := Color("#0d1117")
const FLOOR_COLOR := Color("#1d2a35")
const FLOOR_ALT_COLOR := Color("#243445")
const EXIT_COLOR := Color("#4cd964")
const PLAYER_COLOR := Color("#6dd3ff")
const SPAWN_COLOR := Color("#9b59ff")

func _draw() -> void:
	var dungeon_scene := get_parent()
	if dungeon_scene == null or dungeon_scene.dungeon.is_empty():
		return
	var dungeon: Dictionary = dungeon_scene.dungeon
	var width: int = int(dungeon.get("width", 0))
	var height: int = int(dungeon.get("height", 0))

	draw_rect(Rect2(Vector2.ZERO, Vector2(width * tile_size, height * tile_size)), BG_COLOR, true)

	var walkable: Array = dungeon.get("walkable", [])
	for cell in walkable:
		cell = Vector2i(cell)
		var alt := (cell.x + cell.y) % 2 == 0
		var color := FLOOR_ALT_COLOR if alt else FLOOR_COLOR
		draw_rect(Rect2(cell * tile_size, Vector2(tile_size, tile_size)), color, true)
		draw_rect(Rect2(cell * tile_size, Vector2(tile_size, tile_size)), grid_color, false)

	var spawn_points: Array = dungeon.get("spawn_points", [])
	for point in spawn_points:
		draw_circle(point * tile_size + Vector2(tile_size / 2.0, tile_size / 2.0), tile_size * 0.08, SPAWN_COLOR)

	var exit_pos: Vector2i = dungeon.get("exit_position", Vector2i.ZERO)
	draw_rect(Rect2(exit_pos * tile_size, Vector2(tile_size, tile_size)), EXIT_COLOR, true)
	draw_string(ThemeDB.fallback_font, Vector2(exit_pos * tile_size) + Vector2(10, 26), "↗", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("#0b2a11"))

	for resource in dungeon_scene.resources:
		var center: Vector2 = resource.get("position", Vector2i.ZERO) * tile_size + Vector2(tile_size / 2.0, tile_size / 2.0)
		var id: String = resource.get("id", "wood")
		var color := Color("#b88952")
		if id == "stone":
			color = Color("#95a5a6")
		elif id == "crystal":
			color = Color("#55efc4")
		draw_circle(center, tile_size * 0.18, color)

	for item in dungeon_scene.items:
		draw_circle(item.get("position", Vector2i.ZERO) * tile_size + Vector2(tile_size / 2.0, tile_size / 2.0), tile_size * 0.2, Color.GOLD)

	for enemy in dungeon_scene.enemies:
		draw_circle(enemy.get("position", Vector2i.ZERO) * tile_size + Vector2(tile_size / 2.0, tile_size / 2.0), tile_size * 0.33, Color.CRIMSON)

	draw_circle(dungeon_scene.player_pos * tile_size + Vector2(tile_size / 2.0, tile_size / 2.0), tile_size * 0.35, PLAYER_COLOR)
