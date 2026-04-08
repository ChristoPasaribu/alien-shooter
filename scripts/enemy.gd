extends CharacterBody2D

@export var speed := 120.0
var player: Node2D = null

func _ready():
	add_to_group("enemy")
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if player == null:
		return
	
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
