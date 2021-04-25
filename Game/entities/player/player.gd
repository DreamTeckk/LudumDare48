extends KinematicBody2D

class_name Player

export(float) var speed := 200.0
export(float) var jump_speed := 500.0
export(float) var max_health := 100.0
export(float) var gravity := 2000.0

var punchable_enemies := []

var jumping := false
var is_repairing := false

var _velocity := Vector2.ZERO
var _damage_velocity := Vector2.ZERO

signal repairs
signal stop_repairs

func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	
	
	_damage_velocity.x = lerp(_damage_velocity.x, Vector2.ZERO.x, 0.1)
	_damage_velocity.y = lerp(_damage_velocity.y, Vector2.ZERO.y, 0.5)

	_velocity.x = (Input.get_action_strength("player_1_right") - Input.get_action_strength("player_1_left"))
	_velocity.x *= speed
	_velocity.x += + _damage_velocity.x 
	
	if self.is_on_floor():
		if Input.is_action_pressed("player_1_jump"):
			_velocity.y -= jump_speed
			jumping = true
		else :
			_velocity.y = 0.0
			jumping = false
	else:
		_velocity.y += delta * gravity

	_velocity.y += _damage_velocity.y
	
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

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		print(event.global_position)
	pass

func _on_PunchArea_body_exited(body: Node) -> void:
	if body.is_in_group("Enemy") and punchable_enemies.has(body):
		var idx := punchable_enemies.find(body)
		punchable_enemies.remove(idx)
		
func take_damage(direction: Vector2, strenght: int) -> void:
	_damage_velocity.x = direction.x * strenght
	_damage_velocity.y = direction.y * strenght
