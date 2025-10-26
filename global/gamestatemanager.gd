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
			get_tree().paused = false
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

		GameState.SPAWN_MENU:
			get_tree().paused = false
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

		GameState.PAUSED:
			get_tree().paused = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


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
