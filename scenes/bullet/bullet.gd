extends Area2D

@export var speed := 1000.0
@export var lifetime := 3.0

var direction := Vector2.UP


func _ready() -> void:
	add_to_group("weapons")
	
	rotation = direction.angle() + PI / 2.0


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
