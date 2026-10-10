extends Node

# Spawn de asteroides
const ASTEROID_SCENE := preload("res://scenes/asteroid/asteroid.tscn")

@export var spawn_interval := 0.1
@export var min_starbase_distance := 4000.0
@export var min_ship_distance := 4000.0
@export var max_ship_distance := 8000.0
@export var max_asteroids := 50

var spawn_timer := 0.0


func _process(delta: float) -> void:
	spawn_timer += delta

	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		_spawn_asteroid()


func _spawn_asteroid() -> void:
	if get_tree().get_nodes_in_group("asteroids").size() >= max_asteroids:
		return

	var main := get_tree().current_scene
	var ship := main.get_node_or_null("Ship")
	var starbase := main.get_node_or_null("Starbase")

	if ship == null:
		return

	var spawn_position := Vector2.ZERO
	var valid_position := false

	for i in range(100):
		var angle := randf_range(0.0, TAU)
		var distance := randf_range(min_ship_distance, max_ship_distance)

		var candidate: Vector2 = ship.global_position + Vector2.RIGHT.rotated(angle) * distance

		if candidate.distance_to(starbase.global_position) >= min_starbase_distance:
			spawn_position = candidate
			valid_position = true
			break

	if not valid_position:
		return

	var asteroid = ASTEROID_SCENE.instantiate()

	var random_level := randi_range(0, 3)
	asteroid.level = random_level

	main.add_child(asteroid)
	asteroid.global_position = spawn_position
