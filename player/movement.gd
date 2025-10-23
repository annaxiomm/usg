extends CharacterBody3D

@export var walk_speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var current_speed: float = walk_speed
@export var fly_speed_vertical: float = 1.0
@export var fly_speed_horizontal: float = 12

@export var jump_height: float = 4
@export var gravity_modifier: float = 1.5

@export var mouse_sens: float = 0.1
@onready var head = $head

@export var fly: bool = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-deg_to_rad(event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor() and not fly:
		velocity += get_gravity() * gravity_modifier * delta 

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and not fly:
		velocity.y = jump_height
		
	if Input.is_action_pressed("sprint"):
		current_speed = sprint_speed
	else:
		current_speed = walk_speed

	if Input.is_action_just_pressed("fly"):
		if fly:
			fly = false
			current_speed = fly_speed_horizontal
			$CollisionShape3D.disabled = false
		else:
			fly = true
			current_speed = walk_speed
			$CollisionShape3D.disabled = true
			
	if fly:
		var fly_input := Input.get_axis("crouch", "jump")
		var fly_dir := (transform.basis * Vector3(0, fly_input, 0)).normalized()
		if fly_dir:
			velocity.y = fly_dir.y * current_speed
		else:
			velocity.y = move_toward(velocity.y, 0, current_speed)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
		

	move_and_slide()
	
