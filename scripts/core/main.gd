extends Node

@onready var container: Node = $ScreenContainer

var current_screen: Node

func _ready() -> void:
	show_title()

func _switch_to(scene_path: String) -> Node:
	if current_screen:
		current_screen.queue_free()
	var scene := load(scene_path) as PackedScene
	current_screen = scene.instantiate()
	container.add_child(current_screen)
	return current_screen

func show_title() -> void:
	var screen = _switch_to("res://scenes/ui/TitleScreen.tscn")
	screen.start_requested.connect(_on_start_requested)
	screen.load_requested.connect(_on_load_requested)

func show_hub() -> void:
	var screen = _switch_to("res://scenes/ui/HubScreen.tscn")
	screen.enter_dungeon_requested.connect(_on_enter_dungeon_requested)
	screen.back_to_title_requested.connect(show_title)

func show_dungeon() -> void:
	var screen = _switch_to("res://scenes/dungeon/DungeonScene.tscn")
	screen.victory.connect(_on_victory)
	screen.defeat.connect(_on_defeat)
	screen.exit_to_hub.connect(show_hub)

func show_victory() -> void:
	var screen = _switch_to("res://scenes/ui/VictoryScreen.tscn")
	screen.back_to_hub_requested.connect(show_hub)

func show_defeat() -> void:
	var screen = _switch_to("res://scenes/ui/DefeatScreen.tscn")
	screen.back_to_title_requested.connect(show_title)

func _on_start_requested() -> void:
	GameState.start_new_game()
	show_hub()

func _on_load_requested() -> void:
	if SaveManager.load_game():
		show_hub()

func _on_enter_dungeon_requested() -> void:
	show_dungeon()

func _on_victory() -> void:
	show_victory()

func _on_defeat() -> void:
	show_defeat()
