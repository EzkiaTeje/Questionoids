extends CharacterBody2D

# Tamaño de nave
const SHIP_LENGHT := 64.0

# Movimiento
@export var mass := 1.0
@export var engine_acceleration := 500.0
@export var brake_deceleration := 500.0
@export var max_speed := 600.0
@export var rotation_speed := 3.5

# Cámara
@export var camera: Camera2D

# Disparo
@export var bullet_scene: PackedScene
@export var fire_rate := 0.15

@onready var can_shoot := true

# Destrucción
var ship_destroyed := false


func _ready() -> void:
	add_to_group("ships")


func _physics_process(delta: float) -> void:
	# mover nave
	_check_ship_movement(delta)
	
	# disparar balas
	_check_shooting()


func _check_ship_movement(delta: float) -> void:
	if not ship_destroyed:
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


func destroy_ship() -> void:
	if ship_destroyed:
		return

	ship_destroyed = true

	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	$AnimatedSprite2DEngine.visible = false
	$AnimatedSprite2DShip.play("destroy")


func _on_animated_sprite_2d_ship_animation_finished() -> void:
	if $AnimatedSprite2DShip.animation == "destroy":
		var world := get_tree().current_scene

		camera.reparent(world, true)
		camera.global_position = global_position
		
		queue_free()
