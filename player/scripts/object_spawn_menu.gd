extends PanelContainer

@onready var object_spawner = $"../../../ObjectSpawner"
@onready var object_list = $VBoxContainer/ScrollContainer/HFlowContainer
@onready var game_state_manager = $"../../../../GameStateManager"

signal object_menu_opened
signal object_menu_closed

var objects = []
var currently_open = false

func _ready() -> void:
	hide()
	game_state_manager.connect("state_changed", _on_state_changed)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("spawn_object"):
		if currently_open:
			close()
		else:
			open()
	elif Input.is_action_just_pressed("pause") and currently_open:
		# pressing Esc closes the spawn menu first, doesn't pause the game
		close()


func open() -> void:
	reload_objects()
	currently_open = true
	show()
	emit_signal("object_menu_opened")
	game_state_manager.set_state(game_state_manager.GameState.SPAWN_MENU)


func close() -> void:
	currently_open = false
	hide()
	emit_signal("object_menu_closed")
	game_state_manager.set_state(game_state_manager.GameState.PLAYING)


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


func _on_state_changed(new_state):
	# Optional: automatically hide if game gets paused externally
	if new_state != game_state_manager.GameState.SPAWN_MENU and visible:
		hide()
		currently_open = false
