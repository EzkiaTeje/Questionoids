extends CharacterBody2D

const SHIP_LENGHT := 64.0

@export var mass := 1.0
@export var engine_acceleration := 500.0
@export var brake_deceleration := 500.0
@export var max_speed := 600.0
@export var rotation_speed := 3.5

@export var bullet_scene: PackedScene
@export var fire_rate := 0.2

@onready var can_shoot := true


func _check_shooting() -> void:
	if Input.is_action_just_pressed("shoot"):
		if not can_shoot:
			return
		
		can_shoot = false
		var bullet = bullet_scene.instantiate()
		get_tree().current_scene.add_child(bullet)

		# La bala aparece delante de la nave
		var forward := Vector2.UP.rotated(global_rotation)
		bullet.global_position = global_position + forward * SHIP_LENGHT / 2

		# La bala conserva la dirección del disparo
		bullet.direction = forward

		await get_tree().create_timer(fire_rate).timeout
		
		can_shoot = true


func _check_ship_movement(delta: float) -> void:
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


func _physics_process(delta: float) -> void:
	# mover nave
	_check_ship_movement(delta)
	
	# disparar balas
	_check_shooting()
