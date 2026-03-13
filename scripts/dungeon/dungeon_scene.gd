extends Node2D

signal victory
signal defeat
signal exit_to_hub

const TILE_SIZE := 40

@onready var grid_view: Node2D = $GridView
@onready var info_label: Label = $CanvasLayer/UI/Panel/VBox/InfoLabel
@onready var turn_label: Label = $CanvasLayer/UI/Panel/VBox/TurnLabel
@onready var action_menu: VBoxContainer = $CanvasLayer/UI/Panel/VBox/ActionMenu
@onready var skill_button: OptionButton = $CanvasLayer/UI/Panel/VBox/ActionMenu/SkillRow/SkillPicker
@onready var target_button: OptionButton = $CanvasLayer/UI/Panel/VBox/ActionMenu/TargetRow/TargetPicker

var dungeon: Dictionary
var player_pos: Vector2i
var in_combat := false
var enemies: Array[Dictionary] = []
var items: Array[Dictionary] = []

var combat_system := CombatSystem.new()
var turn_queue: Array[Dictionary] = []
var turn_index := 0

func _ready() -> void:
	_load_or_generate_dungeon()
	_update_turn_label()
	_render_dungeon()
	_update_action_menu()

func _unhandled_input(event: InputEvent) -> void:
	if in_combat:
		return
	if event.is_action_pressed("ui_up"):
		_try_move(Vector2i.UP)
	elif event.is_action_pressed("ui_down"):
		_try_move(Vector2i.DOWN)
	elif event.is_action_pressed("ui_left"):
		_try_move(Vector2i.LEFT)
	elif event.is_action_pressed("ui_right"):
		_try_move(Vector2i.RIGHT)

func _load_or_generate_dungeon() -> void:
	if not GameState.pending_dungeon_state.is_empty():
		dungeon = GameState.pending_dungeon_state.duplicate(true)
	else:
		var config := DataManager.get_dungeon(GameState.selected_dungeon_id)
		dungeon = DungeonGenerator.new().generate(config)
	player_pos = dungeon.get("player_spawn", Vector2i.ONE)
	enemies = dungeon.get("enemies", [])
	items = dungeon.get("items", [])

func _render_dungeon() -> void:
	grid_view.queue_redraw()
	_update_info("Explorez le donjon. Flèches pour bouger.")

func _update_info(text: String) -> void:
	info_label.text = text

func _update_turn_label() -> void:
	turn_label.text = "Tour donjon: %d" % dungeon.get("turn_count", 0)

func _try_move(direction: Vector2i) -> void:
	var next := player_pos + direction
	if not dungeon.get("walkable", []).has(next):
		return
	player_pos = next
	_collect_item_if_any()
	_trigger_enemy_if_adjacent()
	_check_exit()
	dungeon["turn_count"] = dungeon.get("turn_count", 0) + 1
	_update_turn_label()
	_enemy_overworld_turn()
	GameState.pending_dungeon_state = _capture_dungeon_state()
	_render_dungeon()

func _collect_item_if_any() -> void:
	for i in range(items.size() - 1, -1, -1):
		if items[i].get("position", Vector2i.ZERO) == player_pos:
			GameState.add_item(items[i].get("id", "potion"), 1)
			_update_info("Objet ramassé: %s" % DataManager.get_item(items[i].get("id", "")).get("name", "Objet"))
			items.remove_at(i)

func _trigger_enemy_if_adjacent() -> void:
	for enemy in enemies:
		if enemy.get("hp", 0) <= 0:
			continue
		var dist := abs(enemy["position"].x - player_pos.x) + abs(enemy["position"].y - player_pos.y)
		if dist <= 1:
			_start_combat()
			return

func _enemy_overworld_turn() -> void:
	for enemy in enemies:
		if enemy.get("hp", 0) <= 0:
			continue
		var delta := player_pos - enemy["position"]
		var step := Vector2i.ZERO
		if abs(delta.x) > abs(delta.y):
			step.x = sign(delta.x)
		else:
			step.y = sign(delta.y)
		var target := enemy["position"] + step
		if dungeon.get("walkable", []).has(target) and target != player_pos:
			enemy["position"] = target

func _start_combat() -> void:
	in_combat = true
	turn_queue = combat_system.build_turn_queue(GameState.team, enemies)
	turn_index = 0
	_update_action_menu()
	_update_info("Combat engagé !")

func _update_action_menu() -> void:
	action_menu.visible = in_combat
	if not in_combat:
		return
	if turn_queue.is_empty():
		_end_combat_if_needed()
		return
	var turn := turn_queue[turn_index]
	if turn["side"] == "enemy":
		_run_enemy_turn()
		return
	var actor := GameState.team[turn["index"]]
	var skills: Array = actor.get("skills", ["strike"])
	skill_button.clear()
	for skill_id in skills:
		var skill := DataManager.get_skill(skill_id)
		skill_button.add_item(skill.get("name", skill_id))
	target_button.clear()
	for i in enemies.size():
		if enemies[i].get("hp", 0) > 0:
			target_button.add_item("%s (%d PV)" % [enemies[i].get("name", "?"), enemies[i].get("hp", 0)], i)
	_update_info("Au tour de %s." % actor.get("name", "Allié"))

func _run_enemy_turn() -> void:
	var turn := turn_queue[turn_index]
	if enemies[turn["index"]].get("hp", 0) <= 0:
		_advance_turn()
		return
	var enemy := enemies[turn["index"]]
	var action := combat_system.enemy_choose_action(enemy, GameState.team)
	if action.is_empty():
		_advance_turn()
		return
	var result := combat_system.apply_skill(enemy, GameState.team[action["target"]], action["skill"])
	_update_info(result.get("log", "L'ennemi agit."))
	if GameState.is_team_defeated():
		emit_signal("defeat")
		return
	_advance_turn()

func _on_attack_pressed() -> void:
	if not in_combat or turn_queue.is_empty():
		return
	var turn := turn_queue[turn_index]
	if turn["side"] != "team":
		return
	var actor := GameState.team[turn["index"]]
	var skills: Array = actor.get("skills", ["strike"])
	if skills.is_empty() or target_button.item_count == 0:
		return
	var skill_id: String = skills[skill_button.selected]
	var target_index: int = target_button.get_item_id(target_button.selected)
	var result := combat_system.apply_skill(actor, enemies[target_index], skill_id)
	_update_info(result.get("log", "Action effectuée."))
	_advance_turn()

func _on_use_item_pressed() -> void:
	if not in_combat:
		return
	if not GameState.consume_item("potion"):
		_update_info("Aucune potion disponible.")
		return
	for creature in GameState.team:
		if creature.get("hp", 0) > 0:
			creature["hp"] = mini(creature.get("max_hp", 1), creature.get("hp", 0) + 8)
			_update_info("Potion utilisée sur %s." % creature.get("name", "?"))
			break
	_advance_turn()

func _on_flee_pressed() -> void:
	in_combat = false
	_update_info("Fuite vers le hub.")
	GameState.pending_dungeon_state = _capture_dungeon_state()
	emit_signal("exit_to_hub")

func _advance_turn() -> void:
	enemies = enemies.filter(func(e): return e.get("hp", 0) > 0)
	if enemies.is_empty():
		in_combat = false
		_update_info("Combat gagné ! Continuez jusqu'à la sortie.")
		_check_exit(true)
		return
	turn_queue = combat_system.build_turn_queue(GameState.team, enemies)
	if turn_queue.is_empty():
		_end_combat_if_needed()
		return
	turn_index = (turn_index + 1) % turn_queue.size()
	_update_action_menu()
	GameState.pending_dungeon_state = _capture_dungeon_state()
	_render_dungeon()

func _end_combat_if_needed() -> void:
	if GameState.is_team_defeated():
		emit_signal("defeat")
		return
	if enemies.is_empty():
		in_combat = false
		_update_info("Tous les ennemis sont vaincus.")

func _check_exit(force_win := false) -> void:
	if force_win or (player_pos == dungeon.get("exit_position", Vector2i.ZERO) and enemies.is_empty()):
		GameState.pending_dungeon_state.clear()
		emit_signal("victory")

func _capture_dungeon_state() -> Dictionary:
	dungeon["enemies"] = enemies
	dungeon["items"] = items
	dungeon["player_spawn"] = player_pos
	return dungeon.duplicate(true)

func _draw() -> void:
	pass
