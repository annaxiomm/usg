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
		
	scan_user_folder()
	
func _process(_delta: float):
	# Load object if it isn't already loaded
	if object_to_load != loaded_object_name:
		load_new_object(object_to_load)
		loaded_object_name = object_to_load
		
func scan_user_folder() -> void:
	available_objects = []
	user_dir.list_dir_begin()
	for file: String in user_dir.get_files():
		available_objects.append(file)
	
		
func load_new_object(name: String):
	var gltf_doc_load = GLTFDocument.new()
	var gltf_state_load = GLTFState.new()
	var filename = "user://objects/" + name
		
	var error = gltf_doc_load.append_from_file(filename, gltf_state_load)
	if error == OK:
		loaded_object = gltf_doc_load
		loaded_state = gltf_state_load
	else:
		# Load "Model not found" object
		print("failed to load object! loading default object instead...")
		error = gltf_doc_load.append_from_file("res://assets/models/404.glb", gltf_state_load)
		loaded_object = gltf_doc_load
		loaded_state = gltf_state_load
	
	
	
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


func spawn_new_object(object: GLTFDocument):
	if place_raycast.is_colliding() and object != null:
		var object_scene = object.generate_scene(loaded_state)

		# --- Compute bounding box for scaling ---
		var aabb := AABB()
		var first := true
		for mesh_instance: MeshInstance3D in object_scene.find_children("", "MeshInstance3D", true, false):
			var mesh = mesh_instance.mesh
			if mesh:
				var global_aabb = mesh.get_aabb() * mesh_instance.global_transform
				if first:
					aabb = global_aabb
					first = false
				else:
					aabb = aabb.merge(global_aabb)

		# --- Scale object so its largest dimension ≈ target_size ---
		var target_size := 1.5
		var max_dim = max(aabb.size.x, aabb.size.y, aabb.size.z)
		var scale_factor = target_size / max_dim
		object_scene.scale = Vector3.ONE * scale_factor

		# --- Create the RigidBody wrapper ---
		var tmp_object := basic_object.instantiate()
		tmp_object.position = place_raycast.get_collision_point() + Vector3.UP * 5

		# --- Add the scaled model ---
		tmp_object.add_child(object_scene)

		# --- Generate collisions (scaled) ---
		for mesh_instance: MeshInstance3D in object_scene.find_children("", "MeshInstance3D", true, false):
			if mesh_instance.mesh:
				var shape := mesh_instance.mesh.create_convex_shape()
				if shape:
					var collision_shape := CollisionShape3D.new()
					collision_shape.shape = shape
					# Apply same transform *and* scaling
					collision_shape.transform = mesh_instance.transform.scaled(object_scene.scale)
					tmp_object.add_child(collision_shape)
					
		tmp_object.set_meta("name", loaded_object_name)

		get_parent().get_parent().add_child(tmp_object)
