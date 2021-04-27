extends KinematicBody2D

class_name Player

const BASE_RELOAD_TIME := 1.05
const ANTI_KNOCKBACK_BASE := 150.0 

export(float) var speed := 200.0
export(float) var jump_speed := 500.0
export(float) var max_health := 100.0
export(float) var gravity := 2000.0

var punchable_enemies := []

var respawn_point : Vector2

var jump_used := 0
var jumping := false
var pressing_jump := false

var is_repairing := false
var can_shoot := true

var _velocity := Vector2.ZERO
var _damage_velocity := Vector2.ZERO

enum Animation_State {RUN, FALL, IDLE, JUMP, FALL}
var _animation_state = Animation_State.IDLE

enum Weapon_Direction {WEST, EAST}
var _weapon_direction = Weapon_Direction.EAST

onready var Bullet_scene := load("res://entities/bullet/bullet.tscn")

signal repairs
signal respawning
signal respawned
signal stop_repairs
signal get_hit

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
			jump_used += 1
			_velocity.y -= jump_speed
			$AnimationPlayer.play("Jump")
			jumping = true
			pressing_jump = true
			$JumpAudio.play()
		else :
			_velocity.y = 0.0
			jump_used = 0
			_animation_state = Animation_State.IDLE
			jumping = false
			pressing_jump = false
	else:
		if Input.is_action_pressed("player_1_jump") and jump_used < PlayerStats.jump_level + 1 and !pressing_jump:
			$AnimationPlayer.play("Jump")
			jump_used += 1
			_velocity.y -= jump_speed
			pressing_jump = true
			jumping = true
			$JumpAudio.play()
		else:
			_velocity.y += delta * gravity

	_velocity.y += _damage_velocity.y
	
	if Input.is_action_just_released("player_1_jump") and jumping:
		pressing_jump = false
		_velocity.y = 0
		jumping = false
		
	if Input.is_action_pressed("player_1_down"):
		$CollisionShape2D.disabled = true
	
	if !Input.is_action_pressed("player_1_down"):
		$CollisionShape2D.disabled = false
	
	self.move_and_slide(_velocity, Vector2.UP)
	
	animate()
	
	# Player shoot
	if Input.is_action_pressed("player_1_attack"):
		emit_signal("stop_repairs") 
		if can_shoot:
			$Weapon/ShootAudio.play()
			$Weapon/WeaponAnimation.play("Shoot")
			var bullet : KinematicBody2D = Bullet_scene.instance()
			self.get_parent().add_child(bullet)
			bullet.position = $Weapon/Muzzle.global_position
			bullet.rotation = $Weapon/Muzzle.global_rotation
			bullet.setup()
			can_shoot = false
			$ReloadTimer.wait_time = BASE_RELOAD_TIME - float(PlayerStats.reload_time_level) * 0.1
			$ReloadTimer.start()	
	else:
		emit_signal("repairs") 
	
func animate() -> void:
	
	if _animation_state != Animation_State.JUMP and _animation_state != Animation_State.FALL:  
		if _velocity.x != 0.0 and _animation_state != Animation_State.RUN:
			$AnimationPlayer.play("Run")
			_animation_state = Animation_State.RUN
		elif _velocity.x == 0.0:
			$AnimationPlayer.play("Idle")
			_animation_state = Animation_State.IDLE
		
	if _animation_state == Animation_State.FALL:
		$Sprite.frame = $Sprite.hframes - 1
	
	if _weapon_direction == Weapon_Direction.EAST:
		$Sprite.flip_h = false
	else:
		$Sprite.flip_h = true
	
func _input(event: InputEvent) -> void:

	if event.is_action_released("player_1_attack") and is_repairing:
		emit_signal("stop_repairs")
		is_repairing = false

func _on_PunchArea_body_entered(body: Node) -> void:
	if body.is_in_group("Enemy"):		
		punchable_enemies.append(body)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouse:
		$Weapon.rotation = get_local_mouse_position().angle()
		_flip_weapon()
		
func _flip_weapon() -> void: 
	if $Weapon.rotation > deg2rad(90) or $Weapon.rotation < deg2rad(-90):
		_weapon_direction = Weapon_Direction.WEST
		$Weapon.flip_v = true
	else: 
		_weapon_direction = Weapon_Direction.EAST
		$Weapon.flip_v = false

func _on_PunchArea_body_exited(body: Node) -> void:
	if body.is_in_group("Enemy") and punchable_enemies.has(body):
		var idx := punchable_enemies.find(body)
		punchable_enemies.remove(idx)
		
func take_damage(direction: Vector2, strenght: int) -> void:
	# Hit from bottom
	$HitAudio.play()
	emit_signal("get_hit")
	if direction.y < 0:
		_damage_velocity.y = clamp(direction.y * strenght - ANTI_KNOCKBACK_BASE * PlayerStats.anti_knockback_level, 0, -INF)
	else:
		_damage_velocity.y = clamp(direction.y * strenght - ANTI_KNOCKBACK_BASE * PlayerStats.anti_knockback_level, 0, INF)
	
	if direction.x < 0:
		_damage_velocity.x = clamp(direction.x * strenght - ANTI_KNOCKBACK_BASE * PlayerStats.anti_knockback_level, 0, -INF)		
	else:
		_damage_velocity.x = clamp(direction.x * strenght - ANTI_KNOCKBACK_BASE * PlayerStats.anti_knockback_level, 0, INF)		

func _on_ReloadTimer_timeout() -> void:
	can_shoot = true


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "Jump":
		_animation_state = Animation_State.IDLE  


func _on_VisibilityNotifier2D_screen_exited() -> void:
	$FallAudio.play()
	$RespawnTime.start()
	emit_signal("respawning")
	set_physics_process(false)
	set_process_input(false)

func _on_RespawnTime_timeout() -> void:
	emit_signal("respawned")
	self.global_position = respawn_point
	set_physics_process(true)
	set_process_unhandled_input(true)
	set_process_input(true)
	set_process_unhandled_input(true)
	$RespawnAudio.play()
