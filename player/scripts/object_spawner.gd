#extends Node
#
#
#@onready var user_dir := DirAccess.open("user://objects/")
#@onready var builtin_dir := DirAccess.open("res://builtins/objects")
#@onready var place_raycast := $"../head/PlaceRayCast"
#
#@export var available_objects := []
#var cached_objects := {}
#
#var basic_object := preload("res://object/BasicObject.tscn")
#var loaded_object: GLTFDocument = null
#var loaded_state: GLTFState = null
#@export var object_to_load: String = "cube.glb"
#var loaded_object_name: String
#
#
#
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#print("functioning!")
	#if user_dir == null:
		#print("Failed to open user models directory. Creating one...")
		#
		#DirAccess.open("user://").make_dir("objects")
		#user_dir = DirAccess.open("user://objects/")
		#
	#scan_object_folders()
	#
	#
#func _process(_delta: float):
	## Load object if it isn't already loaded
	#if object_to_load != loaded_object_name:
		#load_new_object(object_to_load)
		#loaded_object_name = object_to_load
#
#func scan_object_folders() -> void:
	#available_objects = []
	#user_dir.list_dir_begin()
	#print(user_dir.get_current_dir())
	#print(user_dir.get_files())
	#for file: String in user_dir.get_files():
		#print(file)
		#if file.ends_with(".glb") or file.ends_with(".gltf"):
			#available_objects.append(file)
	#
		#
#func load_new_object(name: String):
	#var gltf_doc_load = GLTFDocument.new()
	#var gltf_state_load = GLTFState.new()
	#var filename: String
	#filename = "user://objects/" + name
		#
	#var error = gltf_doc_load.append_from_file(filename, gltf_state_load)
	#if error == OK:
		#loaded_object = gltf_doc_load
		#loaded_state = gltf_state_load
	#else:
		## Load "Model not found" object
		#print("failed to load object! loading default object instead...")
		#error = gltf_doc_load.append_from_file("res://assets/models/404.glb", gltf_state_load)
		#loaded_object = gltf_doc_load
		#loaded_state = gltf_state_load
	#
	#
	#
#func spawn_new_object(object: GLTFDocument):
	#
	#if place_raycast.is_colliding() and object != null:
		#var object_scene = object.generate_scene(loaded_state)
		#var tmp_object = basic_object.instantiate()
		#var tmp_position = place_raycast.get_collision_point()
		#tmp_position.y += 5
		#
		#tmp_object.position = tmp_position
		#
		## Generate collisions for each child mesh of the GLTF
		#for child: MeshInstance3D in object_scene.find_children("", "MeshInstance3D", true, false):
			#var collision_body = CollisionShape3D.new()
			#collision_body.shape = child.mesh.create_convex_shape()
			#collision_body.transform = child.transform
			#tmp_object.add_child(collision_body)
				#
			#tmp_object.add_child(object_scene)
		#
		#get_parent().get_parent().add_child(tmp_object)
	#else:
		#print("No object loaded!")
		#
		
extends Node

@onready var user_dir := DirAccess.open("user://objects/")
@onready var builtin_dir := DirAccess.open("res://builtins/objects")
@onready var place_raycast := $"../head/PlaceRayCast"

@export var available_objects := [] # Will store dictionaries: { "name": String, "source": String }
var cached_objects := {}

var basic_object := preload("res://object/BasicObject.tscn")
var loaded_object: GLTFDocument = null
var loaded_state: GLTFState = null
@export var object_to_load: String = "cube.glb"
var loaded_object_name: String
var loaded_object_source: String = "" # Either "user" or "builtin"


func _ready() -> void:
	if user_dir == null:
		print("Failed to open user models directory. Creating one...")
		DirAccess.open("user://").make_dir("objects")
		user_dir = DirAccess.open("user://objects/")
	
	scan_object_folders()


func _process(_delta: float):
	# Load object if it isn't already loaded
	if object_to_load != loaded_object_name:
		load_new_object(object_to_load)
		loaded_object_name = object_to_load

func scan_object_folders() -> void:
	available_objects = []

	# Scan user directory
	user_dir.list_dir_begin()
	for file in user_dir.get_files():
		if file.ends_with(".glb") or file.ends_with(".gltf"):
			available_objects.append({
				"name": file,
				"source": "user"
			})

	# Scan builtin directory
	builtin_dir.list_dir_begin()
	for file in builtin_dir.get_files():
		if file.ends_with(".glb") or file.ends_with(".gltf"):
			available_objects.append({
				"name": file,
				"source": "builtin"
			})



func load_new_object(name: String) -> void:
	var gltf_doc_load = GLTFDocument.new()
	var gltf_state_load = GLTFState.new()
	var filename: String
	var source: String = "user"

	# Check if object exists in user directory
	if user_dir.file_exists(name):
		filename = "user://objects/" + name
		source = "user"
	elif builtin_dir.file_exists(name):
		filename = "res://builtins/objects/" + name
		source = "builtin"
	else:
		# Fallback to default 404
		print("Object not found, loading default 404.")
		filename = "res://assets/models/404.glb"
		source = "builtin"

	var error = gltf_doc_load.append_from_file(filename, gltf_state_load)
	if error == OK:
		loaded_object = gltf_doc_load
		loaded_state = gltf_state_load
		loaded_object_source = source
	else:
		print("Failed to load object! Even fallback failed.")


func spawn_new_object(object: GLTFDocument):
	if place_raycast.is_colliding() and object != null:
		var object_scene = object.generate_scene(loaded_state)
		var tmp_object = basic_object.instantiate()
		var tmp_position = place_raycast.get_collision_point()
		tmp_position.y += 5
		tmp_object.position = tmp_position

		# Generate collisions for each child mesh of the GLTF
		for child: MeshInstance3D in object_scene.find_children("", "MeshInstance3D", true, false):
			var collision_body = CollisionShape3D.new()
			collision_body.shape = child.mesh.create_convex_shape()
			collision_body.transform = child.transform
			tmp_object.add_child(collision_body)
				
		tmp_object.add_child(object_scene)
		get_parent().get_parent().add_child(tmp_object)
	else:
		print("No object loaded!")
