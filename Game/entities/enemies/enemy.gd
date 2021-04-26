extends KinematicBody2D

class_name Enemy

const FROM_COLOR : Color = Color8(46, 167, 71, 255)
const TO_COLOR : Color = Color8(102, 7, 7, 255)


var speed : float
var damage : float
var weight : float
var attack_speed : float
var max_health : float
var health : float
var dead := false
var aggresive : bool
var gravity := 2000.0
var timer: Timer
var can_attack := false
var spawn_point_idx : int
var reward : int

var color_r_diff : float
var color_g_diff : float
var color_b_diff : float

var _velocity := Vector2.ZERO

signal damage_struct
signal end_spawn
signal died

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
	
	color_r_diff = TO_COLOR.r8 - FROM_COLOR.r8
	color_g_diff = TO_COLOR.g8 - FROM_COLOR.g8
	color_b_diff = TO_COLOR.b8 - FROM_COLOR.b8
	
	set_physics_process(false)
	
func move() -> void:
	pass

func get_punched(punch_velocity: Vector2) -> void:
	# Hit from bottom
	if punch_velocity.y < 0.0:
		_velocity.y = clamp(punch_velocity.y - weight, -INF, 0)
	else:
		_velocity.y = clamp(punch_velocity.y - weight, 0, INF)
	
	if punch_velocity.x < 0.0:
		_velocity.x = clamp(punch_velocity.x - weight, -INF, 0)
	else:
		_velocity.x = clamp(punch_velocity.x - weight, 0, INF)
func die() -> void:
	dead = true
		

func attack() -> void:
	pass
