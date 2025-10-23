extends Node


@onready var user_dir := DirAccess.open("user://objects/")
@onready var place_raycast := $"../head/PlaceRayCast"

@export var available_objects := []
var cached_objects := {}

var basic_object := preload("res://object/BasicObject.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("functioning!")
	if user_dir == null:
		print("Failed to open user models directory. Creating one...")
		
		DirAccess.open("user://").make_dir("objects")
		user_dir = DirAccess.open("user://objects/")
		
	user_dir.list_dir_begin()
	for file: String in user_dir.get_files():
		available_objects.append(file)
	
	print(available_objects)
	
func _process(_delta: float):
	if Input.is_action_just_pressed("spawn_object"):
		spawn_new_object("cube.glb")
	
func spawn_new_object(name: String):
	if place_raycast.is_colliding():
		var tmp_object = basic_object.instantiate()
		var tmp_position = place_raycast.get_collision_point()
		tmp_position.y += 5
		
		tmp_object.position = tmp_position
		
		var gltf_doc_load = GLTFDocument.new()
		var gltf_state_load = GLTFState.new()
		var filename = "user://objects/" + name
		print(filename)
		var error = gltf_doc_load.append_from_file(filename, gltf_state_load)
		
		if error == OK:
			var object_root_node = gltf_doc_load.generate_scene(gltf_state_load)
			for child: MeshInstance3D in object_root_node.find_children("", "MeshInstance3D", true, false):
				var collision_body = CollisionShape3D.new()
				collision_body.shape = child.mesh.create_convex_shape()
				collision_body.transform = child.transform
				tmp_object.add_child(collision_body)
				
			print(object_root_node.get_children())
				
			tmp_object.add_child(object_root_node)
			
			
		else:
			print("failed to load object!")
		
		get_parent().get_parent().add_child(tmp_object)
		
