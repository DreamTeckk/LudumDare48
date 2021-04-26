extends Node

const EnemyManager = preload("res://entities/enemies/enemiesManager.gd")
var em : EnemiesManager

onready var HUD := $HUD

var spawn_timer : Timer
var max_struct_health := 100.0
var struct_helath := max_struct_health

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

func _ready() -> void:
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
	
	start_anims()
	start_new_layer()

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
	
	spawn_timer.start()
#	$Shop/Control.hide()

func start_anims() -> void:
	$Scenery/DrillAnimation.play("Drill")
	$Scenery/CaterpilarAnimation.play("Run")


# NEXT WAVE MANAGER
###################


# SHOP MANAGER
###################

func _on_Shop_leave_shop() -> void:
	$Shop/Control.hide()



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

func _on_RepairStation_repair(health: int) -> void:
	struct_helath = clamp(struct_helath + health, 0, max_struct_health)
	HUD.set_struct_helath(struct_helath, max_struct_health)

func _on_Spawn_All_Enemies() -> void:
	all_enemies_spawned = true
	spawn_timer.stop()

func _on_Enemy_Died() -> void:
	enemies_kiled += 1
	PlayerStats.enemies_killed += 1
	var text = "Enemies remaining: %d / %d" % [enemies_to_spawn - enemies_kiled, enemies_to_spawn]
	HUD.set_wave_state(text)
	if enemies_kiled >= enemies_to_spawn:
		enemies_to_spawn += randi() % 15 + 10
		print("wave clear")
