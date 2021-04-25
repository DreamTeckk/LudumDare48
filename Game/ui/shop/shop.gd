extends CanvasLayer

const BUY_COLOR = Color8(47, 214, 47, 255)

var UpgradeDict := {
	"jump": {
		"level" : 0,
		"max_level" : 10,
		"price" : 100.0,
		"description" : "Give you an extra jump."
	},
	"bullet_velocity": {
		"level" : 0,
		"max_level" : 10,
		"price" : 100.0,
		"description" : "Increase the speed of your bullets."
	},
	"reload_time": {
		"level" : 0,
		"max_level" : 10,
		"price" : 100.0,
		"description" : "Shoot faster."
	},
	"caliber": {
		"level" : 0,
		"max_level" : 10,
		"price" : 100.0,
		"description" : "Your bullet are bigger, stronger, but slower."
	},
	"anti_knockback": {
		"level" : 0,
		"max_level" : 10,
		"price" : 100.0,
		"description" : "You are more resistant to enemies knockback."
	},
	"repaire_station": {
		"level" : 0,
		"max_level" : 10,
		"price" : 100.0,
		"description" : "The first upgrade give you a repaire station that heal the Drill when activated. Next upgrade increase the health point gain per second. BE CAREFUL, you can't shoot when reapairing the Drill"
	}
}

signal leave_shop

func _ready() -> void:
	$Control/JumpUpgrade/PriceContainer/Label.text = str(UpgradeDict.get('jump').price)
	$Control/BulletVelocityUpgrade/PriceContainer/Label.text = str(UpgradeDict.get('bullet_velocity').price)
	$Control/ReloadTime/PriceContainer/Label.text = str(UpgradeDict.get('reload_time').price)
	$Control/Caliber/PriceContainer/Label.text = str(UpgradeDict.get('caliber').price)
	$Control/AntiKBUpgrade/PriceContainer/Label.text = str(UpgradeDict.get('anti_knockback').price)
	$Control/RepairStationUpgrade/PriceContainer/Label.text = str(UpgradeDict.get('repaire_station').price)

	update_shop()

# Update shop UI
func update_shop() -> void:
	#JUMP
	if PlayerStats.money < UpgradeDict.get('jump').price:
		$Control/JumpUpgrade/JumpUpgradeButton.disabled = true
	else:
		$Control/JumpUpgrade/JumpUpgradeButton.disabled = false
	#BULLET VELOCITY
	if PlayerStats.money < UpgradeDict.get('bullet_velocity').price:
		$Control/BulletVelocityUpgrade/BulletVelocityUpgradeButton.disabled = true
	else:
		$Control/BulletVelocityUpgrade/BulletVelocityUpgradeButton.disabled = false
	#RELOAD TIME
	if PlayerStats.money < UpgradeDict.get('reload_time').price:
		$Control/ReloadTime/ReloadTimeUpgradeButton.disabled = true
	else:
		$Control/ReloadTime/ReloadTimeUpgradeButton.disabled = false
	#CALIBER
	if PlayerStats.money < UpgradeDict.get('caliber').price:
		$Control/Caliber/CaliberUpgradeButton.disabled = true
	else:
		$Control/Caliber/CaliberUpgradeButton.disabled = false
	#ANTI KNOCK BACK
	if PlayerStats.money < UpgradeDict.get('anti_knockback').price:
		$Control/AntiKBUpgrade/AntiKBUpgradeButton.disabled = true
	else:
		$Control/AntiKBUpgrade/AntiKBUpgradeButton.disabled = false
	#REPAIR STATION
	if PlayerStats.money < UpgradeDict.get('repaire_station').price:
		$Control/RepairStationUpgrade/RepairStationUpgradeButton.disabled = true
	else:
		$Control/RepairStationUpgrade/RepairStationUpgradeButton.disabled = false


# JUMP
##########################
func _on_JumpUpgradeButton_pressed() -> void:
	if PlayerStats.jump_level < UpgradeDict.get('jump').max_level:
		if PlayerStats.money >= UpgradeDict.get('jump').price:
			PlayerStats.jump_level += 1
			PlayerStats.money -= UpgradeDict.get('jump').price
			UpgradeDict.get('jump').price = ceil(UpgradeDict.get('jump').price * (1.0 + float(PlayerStats.jump_level) / 10))
			$Control/JumpUpgrade/PriceContainer/Label.text = str(UpgradeDict.get('jump').price)
			update_shop()
			for level in range(PlayerStats.jump_level):
				$Control/JumpUpgrade/Levels.get_child(level).color = BUY_COLOR


func _on_JumpUpgradeButton_mouse_entered() -> void:
	print(UpgradeDict.get('jump').price)
	show_upgrade_info(UpgradeDict.get('jump').description)


func _on_JumpUpgradeButton_mouse_exited() -> void:
	if !$Control/JumpUpgrade/JumpUpgradeButton.get_global_rect().has_point($Control/JumpUpgrade/JumpUpgradeButton.get_global_mouse_position()):
		$Control/Popup.hide()



# BULLET VELOCITY
##########################
func _on_BulletVelocityUpgradeButton_pressed() -> void:
	if PlayerStats.bullet_velocity_level < UpgradeDict.get('bullet_velocity').max_level:
		if PlayerStats.money >= UpgradeDict.get('bullet_velocity').price:
			PlayerStats.bullet_velocity_level += 1
			PlayerStats.money -= UpgradeDict.get('bullet_velocity').price
			UpgradeDict.get('bullet_velocity').price = ceil(UpgradeDict.get('bullet_velocity').price * (1.0 + float(PlayerStats.bullet_velocity_level) / 10))
			$Control/BulletVelocityUpgrade/PriceContainer/Label.text = str(UpgradeDict.get('bullet_velocity').price)
			update_shop()
			for level in range(PlayerStats.bullet_velocity_level):
				$Control/BulletVelocityUpgrade/Levels.get_child(level).color = BUY_COLOR


func _on_BulletVelocityUpgradeButton_mouse_entered() -> void:
	show_upgrade_info(UpgradeDict.get('bullet_velocity').description)


func _on_BulletVelocityUpgradeButton_mouse_exited() -> void:
	if !$Control/BulletVelocityUpgrade/BulletVelocityUpgradeButton.get_global_rect().has_point($Control/BulletVelocityUpgrade/BulletVelocityUpgradeButton.get_global_mouse_position()):
		$Control/Popup.hide()


# RELOAD TIME
##########################
func _on_ReloadTimeUpgradeButton_pressed() -> void:
	if PlayerStats.reload_time_level < UpgradeDict.get('reload_time').max_level:
		if PlayerStats.money >= UpgradeDict.get('reload_time').price:
			PlayerStats.reload_time_level += 1
			PlayerStats.money -= UpgradeDict.get('reload_time').price
			UpgradeDict.get('reload_time').price = ceil(UpgradeDict.get('reload_time').price * (1.0 + float(PlayerStats.reload_time_level) / 10))
			$Control/ReloadTime/PriceContainer/Label.text = str(UpgradeDict.get('reload_time').price)
			update_shop()
			for level in range(PlayerStats.reload_time_level):
				$Control/ReloadTime/Levels.get_child(level).color = BUY_COLOR


func _on_ReloadTimeUpgradeButton_mouse_entered() -> void:
	show_upgrade_info(UpgradeDict.get('reload_time').description)


func _on_ReloadTimeUpgradeButton_mouse_exited() -> void:
	if !$Control/ReloadTime/ReloadTimeUpgradeButton.get_global_rect().has_point($Control/ReloadTime/ReloadTimeUpgradeButton.get_global_mouse_position()):
		$Control/Popup.hide()


# CALIBER
##########################
func _on_CaliberUpgradeButton_pressed() -> void:
	if PlayerStats.caliber_level < UpgradeDict.get('caliber').max_level:
		if PlayerStats.money >= UpgradeDict.get('caliber').price:
			PlayerStats.caliber_level += 1
			PlayerStats.money -= UpgradeDict.get('caliber').price
			UpgradeDict.get('caliber').price = ceil(UpgradeDict.get('caliber').price * (1.0 + float(PlayerStats.caliber_level) / 10))
			$Control/Caliber/PriceContainer/Label.text = str(UpgradeDict.get('caliber').price)
			update_shop()
			for level in range(PlayerStats.caliber_level):
				$Control/Caliber/Levels.get_child(level).color = BUY_COLOR


func _on_CaliberUpgradeButton_mouse_entered() -> void:
	show_upgrade_info(UpgradeDict.get('caliber').description)	


func _on_CaliberUpgradeButton_mouse_exited() -> void:
	if !$Control/Caliber/CaliberUpgradeButton.get_global_rect().has_point($Control/Caliber/CaliberUpgradeButton.get_global_mouse_position()):
		$Control/Popup.hide()


# ANTI KNOCK BACK
##########################
func _on_AntiKBUpgrade_pressed() -> void:
	if PlayerStats.anti_knockback_level < UpgradeDict.get('anti_knockback').max_level:
		if PlayerStats.money >= UpgradeDict.get('anti_knockback').price:
			PlayerStats.anti_knockback_level += 1
			PlayerStats.money -= UpgradeDict.get('anti_knockback').price
			UpgradeDict.get('anti_knockback').price = ceil(UpgradeDict.get('anti_knockback').price * (1.0 + float(PlayerStats.anti_knockback_level) / 10))
			$Control/AntiKBUpgrade/PriceContainer/Label.text = str(UpgradeDict.get('anti_knockback').price)
			update_shop()
			for level in range(PlayerStats.anti_knockback_level):
				$Control/AntiKBUpgrade/Levels.get_child(level).color = BUY_COLOR


func _on_AntiKBUpgrade_mouse_entered() -> void:
	show_upgrade_info(UpgradeDict.get('anti_knockback').description)



func _on_AntiKBUpgrade_mouse_exited() -> void:
	if !$Control/AntiKBUpgrade/AntiKBUpgradeButton.get_global_rect().has_point($Control/AntiKBUpgrade/AntiKBUpgradeButton.get_global_mouse_position()):
		$Control/Popup.hide()


# REPAIR STATION
##########################
func _on_RepairStationUpgradeButton_pressed() -> void:
	if PlayerStats.repair_station_level < UpgradeDict.get('repaire_station').max_level:
		if PlayerStats.money >= UpgradeDict.get('repaire_station').price:
			PlayerStats.repair_station_level += 1
			PlayerStats.money -= UpgradeDict.get('repaire_station').price
			UpgradeDict.get('repaire_station').price = ceil(UpgradeDict.get('repaire_station').price * (1.0 + float(PlayerStats.repair_station_level) / 10))
			$Control/RepairStationUpgrade/PriceContainer/Label.text = str(UpgradeDict.get('repaire_station').price)
			update_shop()
			for level in range(PlayerStats.repair_station_level):
				$Control/RepairStationUpgrade/Levels.get_child(level).color = BUY_COLOR


func _on_RepairStationUpgradeButton_mouse_entered() -> void:
	show_upgrade_info(UpgradeDict.get('repaire_station').description)


func _on_RepairStationUpgradeButton_mouse_exited() -> void:
	if !$Control/RepairStationUpgrade/RepairStationUpgradeButton.get_global_rect().has_point($Control/RepairStationUpgrade/RepairStationUpgradeButton.get_global_mouse_position()):
		$Control/Popup.hide()

func show_upgrade_info(text: String) -> void:
	$Control/Popup/Label.text = text
	$Control/Popup.show() 


func _on_ContinueButton_pressed() -> void:
	emit_signal("leave_shop")
