extends Node2D

@export var star_density := 12
@export var cell_size := 256.0
@export var min_star_size := 0.5
@export var max_star_size := 1.5


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var viewport_size := get_viewport_rect().size
	var canvas_transform := get_viewport().get_canvas_transform()
	var inverse_transform := canvas_transform.affine_inverse()

	var top_left := inverse_transform * Vector2.ZERO
	var bottom_right := inverse_transform * viewport_size

	var min_x := floori(top_left.x / cell_size) - 1
	var min_y := floori(top_left.y / cell_size) - 1
	var max_x := floori(bottom_right.x / cell_size) + 1
	var max_y := floori(bottom_right.y / cell_size) + 1

	draw_rect(
		Rect2(
			get_viewport().get_canvas_transform().affine_inverse() * Vector2.ZERO,
			get_viewport_rect().size
		),
		Color.BLACK
	)

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
