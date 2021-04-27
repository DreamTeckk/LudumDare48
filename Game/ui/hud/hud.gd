extends CanvasLayer

func set_struct_helath(value: float, max_health: float) -> void:
	var new_health : float = floor((value / max_health) * 100)
	$StructHealthBar.value = new_health

func set_wave_state(label: String) -> void: 
	$WaveState.text = label

func set_layer_count(label: String) -> void:
	$LayerCounter.text = label
