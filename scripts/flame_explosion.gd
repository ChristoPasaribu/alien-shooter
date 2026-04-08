extends Area2D

@export var life_time := 1.0
var hit_bodies := []

@onready var life_timer = $LifeTimer

func _ready():
	body_entered.connect(_on_body_entered)
	life_timer.timeout.connect(_on_life_timer_timeout)
	life_timer.wait_time = life_time
	life_timer.start()
	damage_overlapping_enemies()

func _on_body_entered(body):
	apply_damage(body)

func damage_overlapping_enemies():
	var bodies = get_overlapping_bodies()
	for body in bodies:
		apply_damage(body)

func apply_damage(body):
	if not body.is_in_group("enemy"):
		return
	
	if body in hit_bodies:
		return
	
	hit_bodies.append(body)
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.add_alien_energy(player.get_random_alien_gain())
	
	body.queue_free()

func _on_life_timer_timeout():
	queue_free()
