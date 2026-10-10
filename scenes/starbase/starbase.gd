extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("ships"):
		body.destroy_ship()


func _on_area_2d_landing_pad_body_entered(body: Node2D) -> void:
	if body.is_in_group("ships"):
		print("Landing granted.")
