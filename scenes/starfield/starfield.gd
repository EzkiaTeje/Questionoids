extends Node2D

@export var star_density := 1
@export var cell_size := 256.0
@export var min_star_size := 0.5
@export var max_star_size := 1.5

@export var camera: Camera2D


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var active_camera := get_viewport().get_camera_2d()
	if active_camera == null:
		return

	var viewport_size := get_viewport_rect().size
	var half_size := viewport_size * 0.5 * active_camera.zoom

	var top_left := active_camera.global_position - half_size
	var bottom_right := active_camera.global_position + half_size

	# Fondo negro para toda la zona visible
	draw_rect(Rect2(top_left, bottom_right - top_left), Color.BLACK)

	var min_x := floori(top_left.x / cell_size) - 1
	var min_y := floori(top_left.y / cell_size) - 1
	var max_x := floori(bottom_right.x / cell_size) + 1
	var max_y := floori(bottom_right.y / cell_size) + 1

	for x in range(min_x, max_x + 1):
		for y in range(min_y, max_y + 1):
			var cell := Vector2i(x, y)
			var rng := RandomNumberGenerator.new()
			rng.seed = hash(cell)

			for i in range(star_density):
				var star_position := Vector2(
					x * cell_size + rng.randf_range(0.0, cell_size),
					y * cell_size + rng.randf_range(0.0, cell_size)
				)
				var star_size := rng.randf_range(
					min_star_size, max_star_size
				)
				draw_circle(star_position, star_size, Color.WHITE)
