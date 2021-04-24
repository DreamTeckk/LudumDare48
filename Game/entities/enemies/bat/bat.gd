extends Enemy

var target : KinematicBody2D

func _ready() -> void:
	speed = 200.0
	damage = 1
	weight = 10.0
	attack_speed = 2.0
	max_health = 10
	aggresive = true
	health = max_health
	set_physics_process(true)
	setup_attack_timer()

func set_target(target: KinematicBody2D) -> void:
	self.target = target

func setup_attack_timer() -> void:
	timer = $AttackTimer
	timer.wait_time = attack_speed
	timer.start()
	
	emit_signal("end_spawn", spawn_point_idx)
	
func move() -> void:
	if target != null:
		if can_attack:
			self.global_rotation = lerp_angle(self.global_rotation, self.global_position.angle_to_point(target.global_position), 0.1)
		else:
			self.global_rotation = lerp_angle(self.global_rotation, target.global_position.angle_to_point(self.global_position), 0.05)
			
		_velocity =  lerp(_velocity,  Vector2(-speed, 0).rotated(self.global_rotation), 0.05)

func _on_AttackTimer_timeout() -> void:
	can_attack = true

func _on_Attackbox_body_entered(body: Node) -> void:
	if can_attack:
		if body.is_in_group("Player"):
			var p : Player = body
			can_attack = false
			timer.start()
			p.take_damage(damage)
