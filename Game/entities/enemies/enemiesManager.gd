extends Node

class_name EnemiesManager

var statics_spawn_points: Node
var movings_spawn_points: Node
var enemies_node: Node
# Spawn points where a static enemy (e.g.: Spider) is alive
var statics_spawn_in_use : Array
var moving_spawn_in_use : Array
var Spider_scene
var Bat_scene
var player: KinematicBody2D

var spawn_timer : Timer

var enemies_spawned := []

signal damage_struct
signal spawn_all_enemies
signal enemy_died

const EnemyDict = {
	"Spider" : {
		"cts": {
			"min_idx": 0,
			"max_idx": 65,
		},
		"name": "spider"
	},
	"Bat": {
		"cts": {
			"min_idx": 66,
			"max_idx": 99,
		},
		"name": "bat"
	}
}

func _init(statics_spawn_points: Node, movings_spawn_points: Node ,enemies_node: Node, player: KinematicBody2D) -> void:
	
	Spider_scene = load("res://entities/enemies/spider/spider.tscn")
	Bat_scene = load("res://entities/enemies/bat/bat.tscn")
	self.statics_spawn_points = statics_spawn_points
	self.movings_spawn_points = movings_spawn_points
	self.enemies_node = enemies_node
	self.player = player
	

func spawn_enemies(layer: int, difficulty: int, max_enemies: int) -> void:
	randomize()
	
	# How waves works :
	# 
	# If the wave can spawn an enemy, the manager choose a random monster type
	# and spawn it on a random monster-associated spawn point that is not already. 
	# in use.
	# 
	# The enemy spawn with a level = layer + enemy level modifier
	# 
	# The more we go down in layers, the stronger and te more numerous are
	# the enemies.
	
	# Spiders: (at least 25% of ennemies are spiders); 66% c.t.s
	# Bats: 33% c.t.s
	# ???
	
	if enemies_spawned.size() >= max_enemies:
		emit_signal("spawn_all_enemies")
		return
		
	var spawnables = [EnemyDict.Spider, EnemyDict.Bat] 
	
	var rand_idx = randi() % spawnables[spawnables.size() - 1].cts.max_idx + 1
	
	var enemy_to_spawn := ""
	# Check if there are no more space for spider 25% min. spawn rate after the iteration
	if (enemies_spawned.size() - enemies_spawned.count("spider")) / max_enemies > 0.75:
		spawn_spider()
		
	else: 
		for enemy in spawnables:
			if rand_idx >= enemy.cts.min_idx and rand_idx <= enemy.cts.max_idx:
				enemy_to_spawn = enemy.name
				continue
				
		match enemy_to_spawn:
			"spider": 
				spawn_spider()
				enemies_spawned.append("spider")
			"bat":
				spawn_bat()
				enemies_spawned.append("bat")
		
	
func spawn_spider() -> void:
	var rand_sp = null
	while statics_spawn_in_use.has(rand_sp) or rand_sp == null:
		rand_sp = randi() % statics_spawn_points.get_children().size()
		
	statics_spawn_in_use.append(rand_sp)
	
	var new_enemy : Enemy = Spider_scene.instance()
	
	new_enemy.spawn_point_idx = rand_sp
	
	new_enemy.connect("damage_struct", self, "_on_Enemy_Damage_Struct") 
	new_enemy.connect("end_spawn", self, "_on_Enemy_End_Spawn") 
	new_enemy.connect("died", self, "_on_Enemy_Died") 
	
	enemies_node.add_child(new_enemy)
	
	new_enemy.global_position = statics_spawn_points.get_child(rand_sp).global_position
	
func spawn_bat() -> void:
	var rand_sp = null
	while moving_spawn_in_use.has(rand_sp) or rand_sp == null:
		rand_sp = randi() % movings_spawn_points.get_children().size()
		
	moving_spawn_in_use.append(rand_sp)
	
	var new_enemy : Enemy = Bat_scene.instance()
	
	new_enemy.spawn_point_idx = rand_sp
	
	new_enemy.connect("damage_struct", self, "_on_Enemy_Damage_Struct") 
	new_enemy.connect("end_spawn", self, "_on_Enemy_End_Spawn") 
	new_enemy.connect("died", self, "_on_Enemy_Died") 
	
	new_enemy.set_target(player)
	
	enemies_node.add_child(new_enemy)
	
	new_enemy.global_position = movings_spawn_points.get_child(rand_sp).global_position


func _on_Enemy_End_Spawn(statics_spawn_point_idx: int) -> void:
	if statics_spawn_in_use.has(statics_spawn_point_idx):
		statics_spawn_in_use.remove(statics_spawn_in_use.find(statics_spawn_point_idx))
		
func _on_Enemy_Damage_Struct(damage: int) -> void:
	emit_signal("damage_struct", damage)

func _on_Enemy_Died() -> void:
	emit_signal("enemy_died")
