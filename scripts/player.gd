extends CharacterBody2D

@export var speed := 250.0
@export var alien_energy := 0.0
@export var alien_energy_max := 100.0
@export var alien_kill_gain_min := 3
@export var alien_kill_gain_max := 5
@export var transform_drain_rate := 10.0
@export var normal_shoot_interval := 0.35
@export var hybrid_shoot_interval := 0.2
@export var human_detect_radius := 250.0
@export var hybrid_detect_radius := 500.0

var bullet_scene = preload("res://scenes/bullet.tscn")
var fireball_scene = preload("res://scenes/fireball.tscn")

var is_alien_form := false

@onready var shoot_timer = $ShootTimer
@onready var detect_area = $DetectArea
@onready var muzzle_up = $MuzzleUp
@onready var muzzle_down = $MuzzleDown
@onready var muzzle_left = $MuzzleLeft
@onready var muzzle_right = $MuzzleRight
@onready var detect_collision = $DetectArea/CollisionShape2D
@onready var alien_bar = get_tree().current_scene.get_node("UI/AlienBar")

func get_random_alien_gain() -> int:
	return randi_range(alien_kill_gain_min, alien_kill_gain_max)

func update_detect_range():
	var shape = detect_collision.shape as CircleShape2D
	if shape == null:
		return
	
	if is_alien_form:
		shape.radius = hybrid_detect_radius
	else:
		shape.radius = human_detect_radius

func _ready():
	add_to_group("player")
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	update_alien_bar()
	update_shoot_timer()
	update_detect_range()

func _physics_process(delta):
	var move_dir = Vector2.ZERO
	
	move_dir.x = Input.get_axis("ui_left", "ui_right")
	move_dir.y = Input.get_axis("ui_up", "ui_down")
	move_dir = move_dir.normalized()
	
	velocity = move_dir * speed
	move_and_slide()
	
	# DEBUG COLLISION
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		print("Player collided with: ", collision.get_collider().name)
	
	if Input.is_action_just_pressed("transform"):
		if is_alien_form:
			stop_alien_form()
		elif alien_energy > 0:
			start_alien_form()
	
	if is_alien_form:
		alien_energy -= transform_drain_rate * delta
		if alien_energy <= 0:
			alien_energy = 0
			stop_alien_form()
		update_alien_bar()

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
		if is_alien_form:
			flame_attack(nearest_enemy)
		else:
			shoot(nearest_enemy)

func shoot(target):
	var bullet = bullet_scene.instantiate()
	var selected_muzzle = get_muzzle_for_target(target)
	
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = selected_muzzle.global_position
	bullet.direction = (target.global_position - selected_muzzle.global_position).normalized()

func flame_attack(target):
	var fireball = fireball_scene.instantiate()
	var selected_muzzle = get_muzzle_for_target(target)
	
	get_tree().current_scene.add_child(fireball)
	fireball.global_position = selected_muzzle.global_position
	
	var dir = (target.global_position - selected_muzzle.global_position).normalized()
	fireball.direction = dir

func get_muzzle_for_target(target):
	var dir = (target.global_position - global_position).normalized()
	
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			return muzzle_right
		else:
			return muzzle_left
	else:
		if dir.y > 0:
			return muzzle_down
		else:
			return muzzle_up

func add_alien_energy(amount):
	alien_energy = clamp(alien_energy + amount, 0.0, alien_energy_max)
	update_alien_bar()

func update_alien_bar():
	if alien_bar:
		alien_bar.max_value = alien_energy_max
		alien_bar.value = alien_energy

func start_alien_form():
	is_alien_form = true
	update_shoot_timer()
	update_detect_range()
	modulate = Color(0.6, 1.0, 0.6, 1.0)

func stop_alien_form():
	is_alien_form = false
	update_shoot_timer()
	update_detect_range()
	modulate = Color(1, 1, 1, 1)

func update_shoot_timer():
	if is_alien_form:
		shoot_timer.wait_time = hybrid_shoot_interval
	else:
		shoot_timer.wait_time = normal_shoot_interval
