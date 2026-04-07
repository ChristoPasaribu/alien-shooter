extends CharacterBody2D

@export var speed := 250.0
var bullet_scene = preload("res://scenes/bullet.tscn")

@onready var muzzle = $Muzzle
@onready var detect_area = $DetectArea
@onready var shoot_timer = $ShootTimer

func _ready():
	add_to_group("player")
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)

func _physics_process(delta):
	var move_dir = Vector2.ZERO
	
	move_dir.x = Input.get_axis("ui_left", "ui_right")
	move_dir.y = Input.get_axis("ui_up", "ui_down")
	
	move_dir = move_dir.normalized()
	velocity = move_dir * speed
	move_and_slide()

func _on_shoot_timer_timeout():
	var bodies = detect_area.get_overlapping_bodies()
	var nearest_enemy = null
	var nearest_distance = INF
	
	for body in bodies:
		if not body.is_in_group("enemy"):
			continue
		
		var distance = global_position.distance_to(body.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_enemy = body
	
	if nearest_enemy != null:
		shoot(nearest_enemy)

func shoot(target):
	var bullet = bullet_scene.instantiate()
	var selected_muzzle = get_muzzle_for_target(target)
	
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = selected_muzzle.global_position
	bullet.direction = (target.global_position - selected_muzzle.global_position).normalized()
	
func get_muzzle_for_target(target):
	var dir = (target.global_position - global_position).normalized()
	
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			return $MuzzleRight
		else:
			return $MuzzleLeft
	else:
		if dir.y > 0:
			return $MuzzleDown
		else:
			return $MuzzleUp
