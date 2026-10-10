extends Control

@export var direction_icon: TextureRect
@export var distance_label: Label

@onready var main = get_tree().current_scene
var ship: Node2D
var starbase: Node2D
var camera: Camera2D


func _ready() -> void:
	ship = main.get_node_or_null("Ship") as Node2D
	starbase = main.get_node_or_null("Starbase") as Node2D
	camera = main.get_node_or_null("Camera") as Camera2D
	
	direction_icon.pivot_offset = direction_icon.size / 2.0

func _process(_delta: float) -> void:
	if not is_instance_valid(ship) or not is_instance_valid(starbase):
		direction_icon.hide()
		distance_label.hide()
		return

	direction_icon.show()
	distance_label.show()

	# Dirección y distancia en el mundo
	var direction: Vector2 = starbase.global_position - ship.global_position
	var distance: float = direction.length()

	# Adaptar la dirección a la orientación de la cámara
	var screen_direction: Vector2 = direction

	if is_instance_valid(camera):
		screen_direction = direction.rotated(-camera.global_rotation)

	# La textura de la flecha debe apuntar inicialmente hacia la derecha
	direction_icon.rotation = screen_direction.angle()

	# Mostrar distancia
	distance_label.text = "%0.1f km" % (distance / 1000.0)
