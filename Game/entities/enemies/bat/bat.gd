extends Enemy

var target : KinematicBody2D

func _ready() -> void:
	speed = 200.0
	damage = 500.0
	weight = 10.0
	attack_speed = 2.0
	max_health = 20.0
	aggresive = true
	health = max_health
	reward = 3 * PlayerStats.difficulty
	set_physics_process(true)
	setup_attack_timer()
	$AnimationPlayer.play("Fly")

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
			var direction = Vector2.ONE
			var angle = p.global_position.angle_to_point(self.global_position)
			direction = Vector2.ONE.rotated(angle)
			p.take_damage(direction, damage)

func die() -> void:
	PlayerStats.total_money += reward
	PlayerStats.money += reward
	$AnimationPlayer.play("Die")
	
func _on_BulletBox_body_entered(body: Node) -> void:
	if body.is_in_group("Bullet") and !body.wait_to_die:
		print("hit")
		body.wait_to_die = true
		
		var direction = Vector2.ONE
		var angle = self.global_position.angle_to_point(body.global_position)
		var punch_velocity = Vector2(cos(angle), sin(angle)) * body.final_punch
		print(punch_velocity)
		
		health = clamp(health - body.final_damage,0 , max_health)
		var health_percent := health / max_health
		
		$ColorRect.color = Color8(
			round($ColorRect.color.r8 + color_r_diff * health_percent), 
			round($ColorRect.color.g8 + color_g_diff * health_percent),
			round($ColorRect.color.b8 + color_b_diff * health_percent), 255)
		
		body.queue_free()
		
		if health <= 0:
			die()
		
		.get_punched(punch_velocity)


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "Die":
		self.queue_free()
