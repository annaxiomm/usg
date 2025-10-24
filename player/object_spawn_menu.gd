extends PanelContainer

@onready var object_spawner = $"../../../ObjectSpawner"
@onready var object_list = $VBoxContainer/ScrollContainer/HFlowContainer

signal object_menu_opened
signal object_menu_closed

var objects = []
var currently_open = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("spawn_object"):
		if currently_open:
			close()
			currently_open = false
		else:
			open()
			currently_open = true
	
func open() -> void:
	reload_objects()
	emit_signal("object_menu_opened")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	mouse_filter = Control.MOUSE_FILTER_STOP
	show()
	
func close() -> void:
	emit_signal("object_menu_closed")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	hide()


func reload_objects() -> void:
	object_spawner.scan_user_folder()
	objects = object_spawner.available_objects
	for i in object_list.get_children():
		i.queue_free()
	for i in objects:
		var label = Button.new()
		label.text = i
		if i == object_spawner.loaded_object_name:
			label.flat = true
			
		label.connect("pressed", Callable(self, "object_selected").bind(i))
		object_list.add_child(label)
		
func object_selected(name: String):
	$VBoxContainer/StatusBar/ObjectName.text = name
	object_spawner.load_new_object(name)


func _on_spawn_object_pressed() -> void:
	object_spawner.spawn_new_object(object_spawner.loaded_object)
	close()
