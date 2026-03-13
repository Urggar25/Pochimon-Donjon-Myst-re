extends RefCounted
class_name DungeonGenerator

func generate(config: Dictionary) -> Dictionary:
	var width: int = config.get("width", 18)
	var height: int = config.get("height", 12)
	var enemy_count: int = config.get("enemy_count", 4)
	var item_count: int = config.get("item_count", 2)

	var rng := RandomNumberGenerator.new()
	rng.randomize()

	var walkable := []
	for y in height:
		for x in width:
			var is_border := x == 0 or y == 0 or x == width - 1 or y == height - 1
			if is_border:
				continue
			if rng.randf() < 0.12:
				continue
			walkable.append(Vector2i(x, y))

	if walkable.is_empty():
		walkable.append(Vector2i(1, 1))

	var player_spawn := walkable.pick_random()
	var exit_pos := _pick_free_position(walkable, [player_spawn], rng)

	var enemies: Array[Dictionary] = []
	for i in enemy_count:
		var template_id := config.get("enemy_pool", ["mushboom"]).pick_random()
		var template := DataManager.get_enemy_template(template_id)
		if template.is_empty():
			continue
		template["id"] = template_id
		template["hp"] = template.get("max_hp", 8)
		template["position"] = _pick_free_position(walkable, _occupied_positions(enemies, player_spawn, exit_pos), rng)
		enemies.append(template)

	var items: Array[Dictionary] = []
	for i in item_count:
		var item_id := config.get("item_pool", ["potion"]).pick_random()
		items.append({
			"id": item_id,
			"position": _pick_free_position(walkable, _occupied_positions(enemies, player_spawn, exit_pos, items), rng)
		})

	return {
		"width": width,
		"height": height,
		"walkable": walkable,
		"player_spawn": player_spawn,
		"exit_position": exit_pos,
		"enemies": enemies,
		"items": items,
		"turn_count": 0
	}

func _occupied_positions(enemies: Array, player_spawn: Vector2i, exit_pos: Vector2i, items: Array = []) -> Array[Vector2i]:
	var list: Array[Vector2i] = [player_spawn, exit_pos]
	for enemy in enemies:
		list.append(enemy.get("position", Vector2i.ZERO))
	for item in items:
		list.append(item.get("position", Vector2i.ZERO))
	return list

func _pick_free_position(walkable: Array, occupied: Array[Vector2i], rng: RandomNumberGenerator) -> Vector2i:
	var attempts := 100
	while attempts > 0:
		var candidate: Vector2i = walkable[rng.randi_range(0, walkable.size() - 1)]
		if not occupied.has(candidate):
			return candidate
		attempts -= 1
	return walkable[0]
