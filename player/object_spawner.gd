extends Node


@onready var user_dir := DirAccess.open("user://objects/")
@onready var place_raycast := $"../head/PlaceRayCast"

@export var available_objects := []
var cached_objects := {}

var basic_object := preload("res://object/BasicObject.tscn")
var loaded_object: GLTFDocument = null
var loaded_state: GLTFState = null
@export var object_to_load: String = "cube.glb"
var loaded_object_name: String



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
	if object_to_load != loaded_object_name:
		load_new_object(object_to_load)
		loaded_object_name = object_to_load
		
	
	if Input.is_action_just_pressed("spawn_object"):
		spawn_new_object(loaded_object)
		
func load_new_object(name: String):
	var gltf_doc_load = GLTFDocument.new()
	var gltf_state_load = GLTFState.new()
	var filename = "user://objects/" + name
		
	var error = gltf_doc_load.append_from_file(filename, gltf_state_load)
	if error == OK:
		loaded_object = gltf_doc_load
		loaded_state = gltf_state_load
	else:
		print("failed to load object! loading default object instead...")
		error = gltf_doc_load.append_from_file("res://assets/models/404.glb", gltf_state_load)
		loaded_object = gltf_doc_load
		loaded_state = gltf_state_load
	
	
	
func spawn_new_object(object: GLTFDocument):
	
	if place_raycast.is_colliding() and object != null:
		var object_scene = object.generate_scene(loaded_state)
		var tmp_object = basic_object.instantiate()
		var tmp_position = place_raycast.get_collision_point()
		tmp_position.y += 5
		
		tmp_object.position = tmp_position
		for child: MeshInstance3D in object_scene.find_children("", "MeshInstance3D", true, false):
			var collision_body = CollisionShape3D.new()
			collision_body.shape = child.mesh.create_convex_shape()
			collision_body.transform = child.transform
			tmp_object.add_child(collision_body)
				
			tmp_object.add_child(object_scene)
		
		get_parent().get_parent().add_child(tmp_object)
	else:
		print("No object loaded!")
		
