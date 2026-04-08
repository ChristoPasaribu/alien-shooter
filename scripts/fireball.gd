extends Area2D

@export var speed := 500.0
@export var max_distance := 400.0

var direction: Vector2 = Vector2.ZERO
var start_position: Vector2
var explosion_scene = preload("res://scenes/flame_explosion.tscn")
var has_hit := false

func _ready():
	body_entered.connect(_on_body_entered)
	start_position = global_position
	
	if direction != Vector2.ZERO:
		rotation = direction.angle()

func _physics_process(delta):
	if direction == Vector2.ZERO:
		return
	
	global_position += direction.normalized() * speed * delta
	
	if global_position.distance_to(start_position) >= max_distance:
		explode()

func _on_body_entered(body):
	if has_hit:
		return
	
	if body.is_in_group("enemy"):
		has_hit = true
		
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player.add_alien_energy(player.get_random_alien_gain())
		
		body.queue_free()
		explode()

func explode():
	var explosion = explosion_scene.instantiate()
	get_tree().current_scene.add_child(explosion)
	explosion.global_position = global_position
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
