extends Node2D

@export var tile_size := 40
@export var grid_color := Color(0.2, 0.2, 0.2, 1.0)

func _draw() -> void:
	var dungeon_scene := get_parent()
	if dungeon_scene == null or dungeon_scene.dungeon.is_empty():
		return
	var dungeon: Dictionary = dungeon_scene.dungeon
	var walkable: Array = dungeon.get("walkable", [])
	for cell in walkable:
		draw_rect(Rect2(cell * tile_size, Vector2(tile_size, tile_size)), Color(0.12, 0.12, 0.14), true)
		draw_rect(Rect2(cell * tile_size, Vector2(tile_size, tile_size)), grid_color, false)

	var exit_pos: Vector2i = dungeon.get("exit_position", Vector2i.ZERO)
	draw_rect(Rect2(exit_pos * tile_size, Vector2(tile_size, tile_size)), Color(0.1, 0.6, 0.2), true)

	for item in dungeon_scene.items:
		draw_circle(item.get("position", Vector2i.ZERO) * tile_size + Vector2(tile_size / 2.0, tile_size / 2.0), tile_size * 0.2, Color.GOLD)

	for enemy in dungeon_scene.enemies:
		draw_circle(enemy.get("position", Vector2i.ZERO) * tile_size + Vector2(tile_size / 2.0, tile_size / 2.0), tile_size * 0.33, Color.CRIMSON)

	draw_circle(dungeon_scene.player_pos * tile_size + Vector2(tile_size / 2.0, tile_size / 2.0), tile_size * 0.35, Color.DEEP_SKY_BLUE)
