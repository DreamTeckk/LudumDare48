extends Node

class_name EnemiesManager

var statics_spawn_points: Node
var movings_spawn_points: Node
var enemies_node: Node
# Spawn points where a static enemy (e.g.: Spider) is alive
var statics_spawn_in_use : Array
var spawn_in_use : Array
var Spider_scene
var Bat_scene
var player: KinematicBody2D

signal damage_struct
signal spawn_enemy

func _init(statics_spawn_points: Node, movings_spawn_point: Node ,enemies_node: Node, player: KinematicBody2D) -> void:
	Spider_scene = load("res://entities/enemies/spider/spider.tscn")
	Bat_scene = load("res://entities/enemies/bat/bat.tscn")
	self.statics_spawn_points = statics_spawn_points
	self.movings_spawn_points = movings_spawn_points
	self.enemies_node = enemies_node
	self.player = player
	

func spawn_enemies(difficulty: int = 0) -> void:
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
	
	if randi() % 1 < difficulty and statics_spawn_points.get_children().size() > statics_spawn_in_use.size():
		var rand_sp = null
		while statics_spawn_in_use.has(rand_sp) or rand_sp == null:
			rand_sp = randi() % statics_spawn_points.get_children().size()
			
		statics_spawn_in_use.append(rand_sp)
		
		var new_enemy : Enemy = Spider_scene.instance()
		
		new_enemy.spawn_point_idx = rand_sp
		
		new_enemy.connect("damage_struct", self, "_on_Enemy_Damage_Struct") 
		new_enemy.connect("end_spawn", self, "_on_Enemy_End_Spawn") 
#		new_enemy.set_target(player)
		
		enemies_node.add_child(new_enemy)
		
		new_enemy.global_position = statics_spawn_points.get_child(rand_sp).global_position
		

func _on_Enemy_Damage_Struct(damage: int) -> void:
	emit_signal("damage_struct", damage)

func _on_Enemy_End_Spawn(statics_spawn_point_idx: int) -> void:
	if statics_spawn_in_use.has(statics_spawn_point_idx):
		statics_spawn_in_use.remove(statics_spawn_in_use.find(statics_spawn_point_idx))
