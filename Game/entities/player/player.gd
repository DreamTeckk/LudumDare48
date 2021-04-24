extends KinematicBody2D

class_name Player

export(float) var speed := 200.0
export(float) var jump_speed := 500.0
export(float) var max_health := 100.0
export(float) var gravity := 2000.0

var punchable_enemies := []

var health := max_health
var jumping := false
var is_repairing := false

var _velocity := Vector2.ZERO

signal repairs
signal stop_repairs

func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	
	_velocity.x = Input.get_action_strength("player_1_right") - Input.get_action_strength("player_1_left")
	_velocity.x *= speed
	if self.is_on_floor():
		_velocity.y = 0
		jumping = false
	else:
		_velocity.y += delta * gravity
	
	if is_on_floor():
		if Input.is_action_pressed("player_1_jump"):
			_velocity.y -= jump_speed
			jumping = true
	
	if Input.is_action_just_released("player_1_jump") and jumping:
		_velocity.y = 0
		jumping = false
		
	if Input.is_action_pressed("player_1_down"):
		$CollisionShape2D.disabled = true
	
	if Input.is_action_just_released("player_1_down"):
			$CollisionShape2D.disabled = true
			$CollisionShape2D.disabled = false
	
	self.move_and_slide(_velocity, Vector2.UP)
	
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("player_1_attack"):
		for enemy in punchable_enemies:
			var e : Enemy = enemy
			e.get_punched(500, -1 if e.global_position.x < self.global_position.x else 1)
		emit_signal("repairs")
		is_repairing = true
	
	if event.is_action_released("player_1_attack") and is_repairing:
		emit_signal("stop_repairs")
		is_repairing = false

func _on_PunchArea_body_entered(body: Node) -> void:
	if body.is_in_group("Enemy"):		
		punchable_enemies.append(body)


func _on_PunchArea_body_exited(body: Node) -> void:
	if body.is_in_group("Enemy") and punchable_enemies.has(body):
		var idx := punchable_enemies.find(body)
		punchable_enemies.remove(idx)
		
func take_damage(damage: int) -> void:
	health = clamp(health - damage, 0, max_health)
	print_debug(health)
