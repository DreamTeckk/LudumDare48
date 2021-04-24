extends CanvasLayer

func set_struct_helath(value: float, max_health: float) -> void:
	var new_health : float = floor((value / max_health) * 100)
	$StructHealthBar.value = new_health

func set_time_label(label: String) -> void: 
	$Timer.text = label