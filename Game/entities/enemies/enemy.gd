extends KinematicBody2D

class_name Enemy

var speed : float
var damage : int
var weight : float
var attack_speed : float
var max_health : int
var health : int
var dead := false
var aggresive : bool
var gravity := 2000.0
var timer: Timer
var can_attack := false
var spawn_point_idx : int

var _velocity := Vector2.ZERO

signal damage_struct
signal end_spawn

func _physics_process(delta: float) -> void:
	if health <= 0: 
		die()

	move()
	
	if can_attack:
		if !aggresive:
			if is_on_floor():
				attack()
	
	move_and_slide(_velocity, Vector2.UP)

func _ready() -> void:
	set_physics_process(false)
	
func move() -> void:
	pass

func get_punched(damage: float, direction: int) -> void:
	_velocity.y = -damage
	_velocity.x = damage * direction

func die() -> void:
	dead = true
	emit_signal("end_spawn", spawn_point_idx)
	self.queue_free()

func attack() -> void:
	if aggresive :
		pass
	else:
		emit_signal("damage_struct", damage)
	can_attack = false
	timer.start()
