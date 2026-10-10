extends Area2D

# Movimiento y rotación del asteroide
@export var speed := 100.0
@export var lifetime := 120.0
@export var rotation_speed := 0.5

var direction := Vector2.ZERO

# Dibujo del asteroide y colisión
const SMALL_RADIUS := 16.0
const SMALL_POINTS := 8.0
const MEDIUM_RADIUS := 50.0
const MEDIUM_POINTS := 12.0
const BIG_RADIUS := 150.0
const BIG_POINTS := 15.0
const HUGE_RADIUS := 300
const HUGE_POINTS := 20.0
const OUTLINE_THICKNESS := 1.4

var polygon_points := PackedVector2Array()

@onready var collision_polygon: CollisionPolygon2D = $CollisionPolygon2D

# Nivel del asteroide
enum AsteroidLevel { SMALL, MEDIUM, BIG, HUGE }

@export var level: AsteroidLevel = AsteroidLevel.BIG
const ASTEROID_SCENE: PackedScene = preload("res://scenes/asteroid/asteroid.tscn")

# Despawn a distancia de la nave
@export var despawn_distance := 8000.0

var ship: Node2D


func _ready() -> void:
	add_to_group("asteroids")
	
	var main := get_tree().current_scene
	ship = main.get_node_or_null("Ship")
	
	# Dirección aleatoria fija para que se mueva en línea recta.
	direction = Vector2.RIGHT.rotated(randf_range(0.0, TAU))

	# Dibujar el asteroide y aplica la colisión nueva
	match level:
		AsteroidLevel.SMALL:
			_generate_shape(SMALL_RADIUS, SMALL_POINTS)
		AsteroidLevel.MEDIUM:
			_generate_shape(MEDIUM_RADIUS, MEDIUM_POINTS)
		AsteroidLevel.BIG:
			_generate_shape(BIG_RADIUS, BIG_POINTS)
		AsteroidLevel.HUGE:
			_generate_shape(HUGE_RADIUS, HUGE_POINTS)

	collision_polygon.set_deferred("polygon", polygon_points)
	queue_redraw()
	
	# Destruir el asteroide cuando termine su vida útil.
	await get_tree().create_timer(lifetime).timeout
	queue_free()


func _physics_process(delta: float) -> void:
	# Mover el asteroide
	position += direction * speed * delta
	
	# Rotar el asteroide
	rotation += rotation_speed * delta
	
	if not is_instance_valid(ship):
		return
		
	# Destruir si está demasiado lejos de la nave.
	if global_position.distance_to(ship.global_position) > despawn_distance:
		queue_free()
		return


func _generate_shape(radius: float, points: float) -> void:
	polygon_points.clear()

	var angle_step := TAU / points
	for i in range(points):
			var angle := i * angle_step
			var point_radius := radius * randf_range(0.7, 1.0)
			var point := Vector2.RIGHT.rotated(angle) * point_radius
			polygon_points.append(point)


func _draw() -> void:
	if polygon_points.size() < 3:
		return

	draw_colored_polygon(polygon_points, Color.BLACK)

	for i in range(polygon_points.size()):
		var next_i := (i + 1) % polygon_points.size()
		draw_line(polygon_points[i], polygon_points[next_i], Color.WHITE, OUTLINE_THICKNESS)


func _destroy_asteroid() -> void:
	print("hit")
	if level == AsteroidLevel.SMALL:
		queue_free()
		return

	var next_level := level - 1

	for i in range(3):
		var asteroid = ASTEROID_SCENE.instantiate()
		asteroid.level = next_level

		get_parent().add_child(asteroid)
		asteroid.global_position = global_position

	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("weapons"):
		area.queue_free()
		_destroy_asteroid()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("ships"):
		body.destroy_ship()
		_destroy_asteroid()
