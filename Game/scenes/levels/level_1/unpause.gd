extends Node

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause"):
		get_tree().paused = false
