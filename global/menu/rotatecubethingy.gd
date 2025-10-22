extends Node3D

@export var rotation_speed: float = 0.2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"../AnimationPlayer".play("rotate-loop")
