extends Enemy

func _physics_process(delta: float) -> void:
	
	if self.is_on_floor():
		_velocity.y = 0
		_velocity.x = lerp(_velocity.x, 0, 0.3)
	else:
		_velocity.y += delta * gravity
		_velocity.x = lerp(_velocity.x, 0, 0.01)

func _ready() -> void:
	damage = 1.0
	weight = 0.0
	attack_speed = 2.0
	max_health = 50.0
	aggresive = false
	health = max_health
	reward = 1 * PlayerStats.difficulty
	set_physics_process(true)
	$Sprite.visible = true
	$AnimationPlayer.play("Spawn")
	setup_attack_timer()
	
func setup_attack_timer() -> void:
	timer = $AttackTimer
	timer.wait_time = attack_speed
	timer.start()

func _on_VisibilityNotifier2D_screen_exited() -> void:
	.die()
	die()

func die() -> void:
	PlayerStats.total_money += reward
	PlayerStats.money += reward
	emit_signal("died")
	$AnimationPlayer.play("Die")

func _on_BulletBox_body_entered(body: Node) -> void:
	if body.is_in_group("Bullet") and !body.wait_to_die:
		body.wait_to_die = true
		
		var direction = Vector2.ONE
		var angle = self.global_position.angle_to_point(body.spawn_point)
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

func attack() -> void:
	can_attack = false
	timer.start()
	$AnimationPlayer.play("Attack")

func _on_AttackTimer_timeout() -> void:
	can_attack = true

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "Spawn":
		setup_attack_timer()
	if anim_name == "Die":
		emit_signal("end_spawn", spawn_point_idx)
		self.queue_free()
	if anim_name == "Attack":
		emit_signal("damage_struct", damage)
