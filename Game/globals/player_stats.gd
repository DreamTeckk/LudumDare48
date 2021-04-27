extends Node

var total_money := 0 
var damage_done := 0
var enemies_killed := 0
var layers := 0
var difficulty := 1

var game_over := false

var money : int = 0 setget _set_money
var structure_max_health := 100 setget _set_structure_max_health

var jump_level : int = 0
var bullet_velocity_level : int = 0
var reload_time_level : int = 0
var caliber_level : int = 0
var anti_knockback_level : int = 0
var repair_station_level : int = 0
var structure_health_level : int = 0
var damage_level : int = 0
var knockback_level : int = 0

signal money_change
signal struct_max_health_change

func _set_money(value: int) -> void:
	money = value
	emit_signal("money_change")

func _set_structure_max_health(value: int) -> void:
	structure_max_health = value
	emit_signal("struct_max_health_change")
	
func reset_stats() -> void:
	print('reset')
	jump_level = 0
	bullet_velocity_level = 0
	reload_time_level = 0
	caliber_level = 0
	anti_knockback_level = 0
	repair_station_level = 0
	structure_health_level = 0
	damage_level = 0
	knockback_level = 0
	difficulty = 1
	total_money = 0
	damage_done = 0
	enemies_killed = 0
	money = 0
	structure_max_health = 100
	game_over = false
