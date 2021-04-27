extends CanvasLayer

var GameScene := "res://scenes/levels/level_1/level_1.tscn"

func _ready() -> void:
	$Controls.hide()

func _on_StartButton_pressed() -> void:
	$ButtonAudio.play()
	$FadeIn/AnimationPlayer.play("fadein")

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	get_tree().change_scene(GameScene)


func _on_ControlsButton_pressed() -> void:
	$ButtonAudio.play()
	$Controls.show()
