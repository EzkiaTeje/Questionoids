extends CharacterBody2D

@export var mass := 1.0
@export var engine_acceleration := 500.0
@export var brake_deceleration := 500.0
@export var max_speed := 600.0
@export var rotation_speed := 3.5


func _physics_process(delta):
	# Rotación
	var rotation_direction := Input.get_axis("turn_left", "turn_right")
	rotation += rotation_direction * rotation_speed * delta

	# Dirección hacia delante de la nave
	var forward := Vector2.UP.rotated(rotation)

	# Acelerar
	if Input.is_action_pressed("accelerate"):
		var acceleration := engine_acceleration / mass
		velocity += forward * acceleration * delta
		$AnimatedSprite2DEngine.play("accelerate")
	else:
		$AnimatedSprite2DEngine.stop()
		$AnimatedSprite2DEngine.frame = 0

	# Frenar
	if Input.is_action_pressed("brake"):
		if velocity.length() > 0.0:
			var deceleration := brake_deceleration / mass
			velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)

	# Velocidad máxima
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed

	move_and_slide()
