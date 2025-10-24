extends RigidBody3D

var sounds = [
	preload("res://assets/sounds/collision/c1.wav"),
	preload("res://assets/sounds/collision/c2.wav"),
	preload("res://assets/sounds/collision/c3.wav"),
	preload("res://assets/sounds/collision/c4.wav"),
	preload("res://assets/sounds/collision/c5.wav"),
	preload("res://assets/sounds/collision/c6.wav"),
	
]

var audio_player: AudioStreamPlayer3D

func play_random_sound():
	audio_player.stream = sounds[randi() % sounds.size()]
	audio_player.play()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audio_player = AudioStreamPlayer3D.new()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if position.y <= -50:
		queue_free()
		



func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	print("hello")
	play_random_sound()
