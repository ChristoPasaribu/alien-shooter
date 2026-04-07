extends Area2D

@export var speed := 700.0
var direction: Vector2 = Vector2.ZERO
var has_hit := false

func _ready():
	body_entered.connect(_on_body_entered)
	if direction != Vector2.ZERO:
		rotation = direction.angle()

func _physics_process(delta):
	if direction == Vector2.ZERO:
		return
	
	global_position += direction.normalized() * speed * delta

func _on_body_entered(body):
	if has_hit:
		return
	
	if body.is_in_group("enemy"):
		has_hit = true
		body.queue_free()
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
