extends Control

@export var label_inventory_score: Label
@export var label_total_score: Label


func _ready() -> void:
	GameManager.inventory_score_updated.connect(_on_inventory_score_updated)
	GameManager.total_score_updated.connect(_on_total_score_updated)


func _on_inventory_score_updated(new_score: int) -> void:
	label_inventory_score.text = "INVENTORY: " + str(new_score)


func _on_total_score_updated(new_score: int) -> void:
	label_total_score.text = "SCORE: " + str(new_score)
