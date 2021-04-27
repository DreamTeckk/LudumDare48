extends Control

func _on_DamageUpgradeButton_pressed() -> void:
	$ButtonAudio.play()
	self.hide()
