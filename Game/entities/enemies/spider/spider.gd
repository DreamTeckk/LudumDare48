extends Enemy

func _physics_process(delta: float) -> void:
	
	if self.is_on_floor():
		_velocity.y = 0
		_velocity.x = lerp(_velocity.x, 0, 0.3)
	else:
		_velocity.y += delta * gravity
		_velocity.x = lerp(_velocity.x, 0, 0.01)

func _ready() -> void:
	speed = 200.0
	damage = 1
	weight = 10.0
	attack_speed = 1.0
	max_health = 10
	aggresive = false
	health = max_health
	set_physics_process(true)
	setup_attack_timer()
	
func setup_attack_timer() -> void:
	timer = $AttackTimer
	timer.wait_time = attack_speed
	timer.start()

func _on_AttackTimer_timeout() -> void:
	can_attack = true

func _on_VisibilityNotifier2D_screen_exited() -> void:
	.die()
