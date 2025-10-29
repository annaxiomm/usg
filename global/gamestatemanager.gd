extends Node

enum GameState { PLAYING, SPAWN_MENU, PAUSED }

var state: GameState = GameState.PLAYING

signal state_changed(new_state: GameState)

func set_state(new_state: GameState) -> void:
	if state == new_state:
		return
	
	state = new_state
	emit_signal("state_changed", state)

	match state:
		GameState.PLAYING:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			get_parent().get_node("Player").unpause_movement()

		GameState.SPAWN_MENU:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			get_parent().get_node("Player").pause_movement()

		GameState.PAUSED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			get_parent().get_node("Player").pause_movement()


func _unhandled_input(event):

	if event.is_action_pressed("pause"):
		match state:
			GameState.SPAWN_MENU:
				# If the menu is open, don't pause — the menu will handle closing itself.
				return
			GameState.PLAYING:
				set_state(GameState.PAUSED)
			GameState.PAUSED:
				set_state(GameState.PLAYING)
