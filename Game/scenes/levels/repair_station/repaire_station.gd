extends Node2D

var activable := false

const HEALTH_REPAIR_BASE := 1

signal repair

func _on_ActivationArea_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		var player: Player = body
		player.connect("repairs", self, "_on_Player_Repairs")
		player.connect("stop_repairs", self, "_on_Player_Stop_Repairs")

func _on_ActivationArea_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		var player: Player = body
		player.disconnect("repairs", self, "_on_Player_Repairs")
		player.disconnect("stop_repairs", self, "_on_Player_Stop_Repairs")
		activable = false
		$RepairTimer.stop()
		

func _on_Player_Repairs() -> void:
	activable = true
	if $RepairTimer.is_stopped():
		$RepairTimer.start()

func _on_Player_Stop_Repairs() -> void:
	activable = false
	$RepairTimer.stop()

func _on_RepairTimer_timeout() -> void:
	if activable:
		print_debug("player repairs")
		emit_signal("repair", HEALTH_REPAIR_BASE * (PlayerStats.repair_station_level + 1))
