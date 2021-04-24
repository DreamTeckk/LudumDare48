extends Node

const EnemyManager = preload("res://entities/enemies/enemiesManager.gd")

var em : EnemiesManager

onready var HUD := $HUD

var time := 0.0
var max_struct_health := 100.0
var struct_helath := max_struct_health

## Wave info

# Layer is equals to completed levels + 1
var layer := 1
var enemies_spawned := 0
var enemies_to_spawn := 10
var enemies_level := 1

func _ready() -> void:
	em = EnemiesManager.new($StaticsEnemiesSpawnPoints, $MovingEnemiesSpawnPoints, $Enemies, $Player)
	em.connect("damage_struct", self, "_on_Enemy_Damage_Struct")
	em.connect("spawn_enemy", self, "_on_Spawn_Enemy")

func _on_Chrono_timeout() -> void:
	time += 1.0
	
	# Try to spawn enemies
	em.spawn_enemies(floor(time / 60) + 1)
	
	# Update Timer
	var seconds := fmod(time, 60)
	var minutes := time / 60
	var timer_text := "%02d:%02d" % [minutes, seconds]
	HUD.set_time_label(timer_text)

func _on_Enemy_Damage_Struct(damage: int) -> void:
	struct_helath = clamp(struct_helath - damage, 0, max_struct_health)
	HUD.set_struct_helath(struct_helath, max_struct_health)

func _on_Spawn_Enemy() -> void:
	enemies_spawned = clamp(enemies_spawned + 1, 0, enemies_to_spawn)

func _on_RepairStation_repair(health: int) -> void:
	struct_helath = clamp(struct_helath + health, 0, max_struct_health)
	HUD.set_struct_helath(struct_helath, max_struct_health)
