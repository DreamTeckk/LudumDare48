extends CanvasLayer

var GameScene := "res://scenes/levels/level_1/level_1.tscn"
var MenuScene := "res://scenes/menu/menu.tscn"

var pts_per_layer := 100
var pts_per_money := 5
var pts_per_damage := 1
var pts_per_kill := 10

func _ready() -> void:

	$Scores/layerScore/Label.text = "Layer Drilled(%d): %d" % [PlayerStats.layers - 1 , (PlayerStats.layers - 1) * pts_per_layer]
	$Scores/moneyScore/Label.text = "Money Earned(%d): %d" % [PlayerStats.total_money, PlayerStats.total_money * pts_per_money]
	$Scores/damageScore/Label.text = "Damage Dealted(%d): %d" % [PlayerStats.damage_done, PlayerStats.damage_done * pts_per_damage]
	$Scores/killScore/Label.text = "Enemies Killed(%d): %d" % [PlayerStats.enemies_killed, PlayerStats.enemies_killed * pts_per_kill]
	
	var total := 0
	total += (PlayerStats.layers - 1) * pts_per_layer
	total += PlayerStats.total_money * pts_per_money
	total += PlayerStats.damage_done * pts_per_damage
	total += PlayerStats.enemies_killed * pts_per_kill
	
	$Scores/Total/Label2.text = "%d pts" % [total]

func _on_RestartButton_pressed() -> void:
	$ButtonAudio.play()
	$FadeIn/AnimationPlayer.play("fadein")

func _on_MenuButton_pressed() -> void:
	$ButtonAudio.play()
	get_tree().change_scene(MenuScene)


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	get_tree().change_scene(GameScene)
