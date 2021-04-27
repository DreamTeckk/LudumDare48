extends Node

const EnemyManager = preload("res://entities/enemies/enemiesManager.gd")
var em : EnemiesManager

var GameOverScene = "res://scenes/game_over/game_over.tscn"

onready var HUD := $HUD

var spawn_timer : Timer
var max_struct_health := PlayerStats.structure_max_health
var struct_helath := max_struct_health

enum WAVE_STEPS {PRE_WAVE, WAVE, POST_WAVE, SHOP}
var current_wave_step = WAVE_STEPS.PRE_WAVE
# WAVE INFO
###########
# Layer is equals to completed levels + 1
var layer := 0
# Difficulty is used to defines enemies level
var difficulty := 0

var enemies_to_spawn := 5
var enemies_kiled := 0

var all_enemies_spawned := false
var enemies_level := 1

# READY
####################

func _process(delta: float) -> void:
	if current_wave_step == WAVE_STEPS.PRE_WAVE or current_wave_step == WAVE_STEPS.WAVE: 
		for bg in $Bgs.get_children().size():
			$Bgs.get_child(bg).rect_global_position.x -= 200.0 * delta
			if $Bgs.get_child(bg).rect_global_position.x <= -1280.0:
				$Bgs.get_child(bg).rect_global_position.x = 1280.0

func _ready() -> void:
	PlayerStats.reset_stats()
	$Player.respawn_point = $PlayerRespawn.global_position
	$RepairStation.hide()
	$HUD/Respawning.hide()	
	
	em = EnemiesManager.new($StaticsEnemiesSpawnPoints, $MovingEnemiesSpawnPoints, $Enemies, $Player)
	em.connect("damage_struct", self, "_on_Enemy_Damage_Struct")
	em.connect("spawn_all_enemies", self, "_on_Spawn_All_Enemies")
	em.connect("enemy_died", self, "_on_Enemy_Died")
	
	spawn_timer = Timer.new()
	spawn_timer.wait_time = 1.0
	spawn_timer.autostart = false
	spawn_timer.one_shot = true
	spawn_timer.connect("timeout", self, "_on_Spawn_Timer_Timeout")
	add_child(spawn_timer)
	
	HUD.get_node("CoinCounter").get_node("Label").text = str(PlayerStats.money)
	
	PlayerStats.connect("money_change", self, "_on_Money_Change")
	PlayerStats.connect("struct_max_health_change", self, "_on_Struct_Max_Health_Change")
	
	$Shop/Control.hide()
	
	start_anims()
	launch_wave_step(WAVE_STEPS.PRE_WAVE)

# STARTING FUNCTIONS
####################

func start_new_layer() -> void:
	em.enemies_spawned = []
	all_enemies_spawned = false
	enemies_kiled = 0
	var text = "Enemies remaining: %d / %d" % [enemies_to_spawn - enemies_kiled, enemies_to_spawn]
	HUD.set_wave_state(text)
	
	layer += 1
	PlayerStats.layers = layer
	text = "Layer: %d" % [PlayerStats.layers]
	HUD.set_layer_count(text)
	
	spawn_timer.start()

func start_anims() -> void:
	$Scenery/DrillAnimation.play("Drill")
	$Scenery/CaterpilarAnimation.play("Run")


# SHOP MANAGER
###################

func _on_Shop_leave_shop() -> void:
	$Shop/Control.hide()
	launch_wave_step(WAVE_STEPS.PRE_WAVE)
	if PlayerStats.repair_station_level >= 1:
		$RepairStation.show()

# SIGNALS CALL BACK
###################

func _on_Spawn_Timer_Timeout() -> void:
	if !all_enemies_spawned:
		# Try to spawn enemies
		em.spawn_enemies(layer, difficulty, enemies_to_spawn)
		spawn_timer.start()

func _on_Enemy_Damage_Struct(damage: int) -> void:
	struct_helath = clamp(struct_helath - damage, 0, max_struct_health)
	HUD.set_struct_helath(struct_helath, max_struct_health)
	if struct_helath <= 0:
		PlayerStats.game_over = true
		get_tree().change_scene(GameOverScene)

func _on_RepairStation_repair(health: int) -> void:
	struct_helath = clamp(struct_helath + health, 0, max_struct_health)
	HUD.set_struct_helath(struct_helath, max_struct_health)

func _on_Spawn_All_Enemies() -> void:
	all_enemies_spawned = true
	spawn_timer.stop()

func _on_Enemy_Died() -> void:
	enemies_kiled += 1
	PlayerStats.enemies_killed = PlayerStats.enemies_killed + 1
	var text = "Enemies remaining: %d / %d" % [enemies_to_spawn - enemies_kiled, enemies_to_spawn]
	HUD.set_wave_state(text)
	if enemies_kiled >= enemies_to_spawn:
		for e in $Enemies.get_children().size():
			$Enemis.get_child(e).queue_free()
		launch_wave_step(WAVE_STEPS.POST_WAVE)
		enemies_to_spawn += randi() % 5 + 1

func _on_Money_Change() -> void: 
	HUD.get_node("CoinCounter").get_node("Label").text = str(PlayerStats.money)

func _on_Struct_Max_Health_Change() -> void:
	struct_helath = round(struct_helath * (PlayerStats.structure_max_health / max_struct_health))
	max_struct_health = PlayerStats.structure_max_health
	HUD.set_struct_helath(struct_helath, max_struct_health)

func launch_wave_step(step) -> void:
	current_wave_step = step
	
	match current_wave_step:
		WAVE_STEPS.PRE_WAVE, WAVE_STEPS.POST_WAVE:
			$RepairStation.is_wave_running = true
			$Scenery/DrillAnimation.play("Drill")
			$Scenery/CaterpilarAnimation.play("Run")
			
			$StepsTimer.wait_time = 5.0
			$StepsTimer.start()
			
		WAVE_STEPS.WAVE:
			$RepairStation.is_wave_running = true
			start_new_layer()
		WAVE_STEPS.SHOP:
			$RepairStation.is_wave_running = false
			$Scenery/DrillAnimation.stop()
			$Scenery/CaterpilarAnimation.stop()
			$Shop.update_shop()
			$Shop/Control.show()

func _on_StepsTimer_timeout() -> void:
	launch_wave_step(current_wave_step + 1 if current_wave_step != WAVE_STEPS.size() else WAVE_STEPS.PRE_WAVE)


func _on_Player_respawned() -> void:
	$HUD/Respawning.hide()
	$HUD/Respawning/AnimationPlayer.stop()


func _on_Player_respawning() -> void:
	$HUD/Respawning.show()
	$HUD/Respawning/AnimationPlayer.play("flicker")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause"):
#		get_tree().paused = true
		pass


func _on_Player_get_hit() -> void:
	$Camera2D/AnimationPlayer.play("Shake")
