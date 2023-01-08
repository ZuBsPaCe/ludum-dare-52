extends CanvasLayer


const GameState := preload("res://Scripts/GameState.gd").GameState


signal switch_game_state(new_state)


func _on_MainMenuButton_pressed():
	emit_signal("switch_game_state", GameState.PAUSE)
