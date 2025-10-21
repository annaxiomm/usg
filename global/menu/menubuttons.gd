extends Node

@export var hover_scale: Vector2 = Vector2(1.2, 1.2)  
@export var duration: float = 0.15                 
var original_scale: Vector2

@export var game_scene: PackedScene


func _on_start_pressed() -> void:
	get_tree().change_scene_to_packed(game_scene)
