extends KinematicBody2D

const BASE_VELOCITY := Vector2(300.0,300.0)
const BASE_DAMMAGE := 5.0
const BASE_PUNCH := 600.0

var velocity_level : int
var caliber_level : int

var velocity_level_factor := 0.4
var caliber_velocity_level_factor := 0.2
var caliber_damage_level_factor :=  0.2
var caliber_size_level_factor :=  0.5
var caliber_punch_level_factor := 1.0

var final_velocity : Vector2
var final_damage : float
var final_punch : float

var spawn_point: Vector2

var wait_to_die := false

func _ready() -> void:
	velocity_level = PlayerStats.bullet_velocity_level
	caliber_level = PlayerStats.caliber_level
	
	
	final_damage = BASE_DAMMAGE * (1.0 + (caliber_level * caliber_damage_level_factor))
	final_damage = floor(final_damage)
	
	final_punch = BASE_PUNCH * (1.0 + (caliber_level * caliber_punch_level_factor))
	
	self.scale = Vector2.ONE * (1.0 + (caliber_level *  caliber_size_level_factor))
	
	print(final_punch)

	
func setup() -> void:
	spawn_point = global_position
	final_velocity = BASE_VELOCITY * clamp(1.0 + (velocity_level * velocity_level_factor) - (caliber_level * caliber_velocity_level_factor), 0.1, INF)
	final_velocity *= Vector2(cos(rotation), sin(rotation))
	
func _physics_process(delta: float) -> void:
	move_and_slide(final_velocity)


func _on_VisibilityNotifier2D_screen_exited() -> void:
	wait_to_die = true
	queue_free()
