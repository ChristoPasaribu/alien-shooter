extends Node2D

var enemy_scene = preload("res://scenes/enemy.tscn")

@onready var spawn_timer = $SpawnTimer

func _ready():
	randomize()
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

func _on_spawn_timer_timeout():
	var enemy = enemy_scene.instantiate()
	get_tree().current_scene.add_child(enemy)
	
	var screen_size = get_viewport().get_visible_rect().size
	var side = randi() % 4
	var spawn_position = Vector2.ZERO
	var margin = 60.0
	
	match side:
		0:
			spawn_position = Vector2(randf_range(0, screen_size.x), -margin)
		1:
			spawn_position = Vector2(randf_range(0, screen_size.x), screen_size.y + margin)
		2:
			spawn_position = Vector2(-margin, randf_range(0, screen_size.y))
		3:
			spawn_position = Vector2(screen_size.x + margin, randf_range(0, screen_size.y))
	
	enemy.global_position = spawn_position
